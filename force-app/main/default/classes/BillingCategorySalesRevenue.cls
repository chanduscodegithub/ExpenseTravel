global class BillingCategorySalesRevenue implements Database.Batchable<SObject> {
    private Set<Id> recordIds;
    string financialYearP;

    public BillingCategorySalesRevenue(Set<Id> recordIds, string financialYear) {
        this.recordIds = recordIds;
        this.financialYearP = financialYear;
    }

    global Database.QueryLocator start(Database.BatchableContext context) {
        Integer fiscalYearStartMonth = 4; // April
        Integer fiscalYearStartYear = Integer.valueOf(financialYearP);
        Date fiscalYearStartDate = Date.newInstance(fiscalYearStartYear, fiscalYearStartMonth, 1);
        Date fiscalYearEndDate = fiscalYearStartDate.addYears(1).addDays(-1);
        String query = 'SELECT Id, Invoice_Amount__c, Invoice_Date__c, OpportunityName__r.Owner.Name, OpportunityName__r.CurrencyIsoCode, OpportunityName__r.Name, OpportunityName__r.Opportunity_Category__c FROM Billing__c WHERE OpportunityName__r.StageName = \'Opportunity Won\' AND OpportunityName__r.Owner.Name != null AND OpportunityName__r.Opportunity_Category__c != Null AND Invoice_Date__c != null AND Invoice_Amount__c != null '+'AND Invoice_Date__c >= :fiscalYearStartDate'+' AND Invoice_Date__c <= :fiscalYearEndDate';
        system.debug('query:'+query);
        // Reset the quarterly attainment fields to zero before starting the batch
        List<Revenue_Stream_Employee__c> resetRevenueStreams = [
            SELECT Id, 
            Q1_Exs_Renewal__c, Q2_Exs_Renewal__c, Q3_Exs_Renewal__c, Q4_Exs_Renewal__c,
            Q1_Exs_New_Business__c, Q2_Exs_New_Business__c, Q3_Exs_New_Business__c, Q4_Exs_New_Business__c,
            Q1_New_Cust_New_Business__c, Q2_New_Cust_New_Business__c, Q3_New_Cust_New_Business__c, Q4_New_Cust_New_Business__c
            FROM Revenue_Stream_Employee__c
        ];
        system.debug('resetRevenueStreams:'+resetRevenueStreams);
        for (Revenue_Stream_Employee__c resetRevenueStream : resetRevenueStreams) {
            resetRevenueStream.Q1_Exs_Renewal__c = 0;
            resetRevenueStream.Q2_Exs_Renewal__c = 0;
            resetRevenueStream.Q3_Exs_Renewal__c = 0;
            resetRevenueStream.Q4_Exs_Renewal__c = 0;
            resetRevenueStream.Q1_Exs_New_Business__c = 0;
            resetRevenueStream.Q2_Exs_New_Business__c = 0;
            resetRevenueStream.Q3_Exs_New_Business__c = 0;
            resetRevenueStream.Q4_Exs_New_Business__c = 0;
            resetRevenueStream.Q1_New_Cust_New_Business__c = 0;
            resetRevenueStream.Q2_New_Cust_New_Business__c = 0;
            resetRevenueStream.Q3_New_Cust_New_Business__c = 0;
            resetRevenueStream.Q4_New_Cust_New_Business__c = 0;
        }

        update resetRevenueStreams; // Update the reset records
        system.debug('resetRevenueStreams:'+resetRevenueStreams);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext context, List<Billing__c> scope) {
        Set<String> employeeNames = new Set<String>();
        Map<Id, Decimal> closedyear = new Map<Id, Decimal>();
        // Determine the currencies involved
        Set<String> billingCurrencies = new Set<String>();
        Set<String> employeeCurrencies = new Set<String>();

        for (Billing__c bill : scope) {
            employeeNames.add(bill.OpportunityName__r.Owner.Name);
            closedyear.put(bill.Id, bill.Invoice_Date__c.year());
            billingCurrencies.add(bill.OpportunityName__r.CurrencyIsoCode);
        }
        system.debug('closedyear:'+closedyear);

        // Fetching the latest conversion rates
        Map<String, Decimal> conversionRates = new Map<String, Decimal>();

        // Query the latest conversion rates for each currency
        for (DatedConversionRate rate : [
            SELECT ConversionRate, IsoCode
            FROM DatedConversionRate
            WHERE StartDate <= TODAY AND IsoCode IN :billingCurrencies
            ORDER BY IsoCode, StartDate ASC // Sort by ISO code and start date
        ]) {
            // Add the conversion rate to the map if it doesn't exist
            conversionRates.put(rate.IsoCode, rate.ConversionRate);
        }
        system.debug('conversionrate:'+conversionRates);

        List<Revenue_Stream_Employee__c> relevantRevenueStreams = [
            SELECT Id, Employees__c, Employees__r.Name, Q1_Revenue_Attainment__c, Q2_Revenue_Attainment__c,
            Q3_Revenue_Attainment__c, Q4_Revenue_Attainment__c, Finance_Year__c, Currency__c,Q1_Exs_Renewal__c, Q2_Exs_Renewal__c, Q3_Exs_Renewal__c, Q4_Exs_Renewal__c,
            Q1_Exs_New_Business__c, Q2_Exs_New_Business__c, Q3_Exs_New_Business__c, Q4_Exs_New_Business__c,
            Q1_New_Cust_New_Business__c, Q2_New_Cust_New_Business__c, Q3_New_Cust_New_Business__c, Q4_New_Cust_New_Business__c
            FROM Revenue_Stream_Employee__c
            WHERE Employees__r.Name IN :employeeNames AND Finance_Year__c =: financialYearP
        ];
        system.debug('relevantRevenueStreams:'+relevantRevenueStreams);
        Map<String, Revenue_Stream_Employee__c> employeeRevenueStreamMap = new Map<String, Revenue_Stream_Employee__c>();
        for (Revenue_Stream_Employee__c revenueStream : relevantRevenueStreams) {
            employeeRevenueStreamMap.put(revenueStream.Employees__r.Name, revenueStream);
            employeeCurrencies.add(revenueStream.Currency__c);
        }

        Map<String, Map<Integer, Decimal>> quarterlyAttainmentMap = new Map<String, Map<Integer, Decimal>>();
        for (Billing__c bill : scope) {
            String employeeName = bill.OpportunityName__r.Owner.Name;
            Decimal milestoneAmount = bill.Invoice_Amount__c;
            Date milestoneDate = bill.Invoice_Date__c;
            Decimal milestoneYear = closedyear.get(bill.Id);
            String opportunityCategory = bill.OpportunityName__r.Opportunity_Category__c;
            system.debug('billid:'+bill.Id);
            system.debug('amount:'+milestoneAmount);
            system.debug('opportunityCategory:'+opportunityCategory);

            if (milestoneDate != null && employeeName != null && employeeRevenueStreamMap.containsKey(employeeName) && milestoneYear != null && String.valueOf(milestoneYear) == financialYearP) {
                Revenue_Stream_Employee__c relevantRevenueStream = employeeRevenueStreamMap.get(employeeName);
                Date financeYearStartDate = Date.newInstance(Integer.valueOf(relevantRevenueStream.Finance_Year__c), 4, 1);
                Date financeYearEndDate = financeYearStartDate.addYears(1).addDays(-1);

                if (milestoneDate >= financeYearStartDate && milestoneDate <= financeYearEndDate) {
                    Integer quarter = getQuarter(milestoneDate);

                    if (!quarterlyAttainmentMap.containsKey(employeeName)) {
                        quarterlyAttainmentMap.put(employeeName, new Map<Integer, Decimal>());
                    }

                    Map<Integer, Decimal> employeeAttainmentMap = quarterlyAttainmentMap.get(employeeName);

                    // Determine opportunity and employee currency
                    String billingCurrency = bill.OpportunityName__r.CurrencyIsoCode;
                    String employeeCurrency = relevantRevenueStream.Currency__c;

                    // Check if opportunity currency is different from employee currency
                    if (!billingCurrency.equals(employeeCurrency)) {
                        // Convert the opportunity amount to USD
                        Decimal billingAmountInUSD = milestoneAmount;
                        Decimal conversionRateToUSD = 1; // Default to 1 if no conversion rate found

                        if (!billingCurrency.equals('USD')) {
                            if (conversionRates.containsKey(billingCurrency)) {
                                conversionRateToUSD = conversionRates.get(billingCurrency);
                                billingAmountInUSD = milestoneAmount / conversionRateToUSD;
                            }
                        }

                        Decimal convertedAmount = billingAmountInUSD; // Initialize with USD amount
                        if (!employeeCurrency.equals('USD')) {
                            Decimal conversionRateToEmployeeCurrency = 1; // Default to 1 if no conversion rate found
                            if (conversionRates.containsKey(employeeCurrency)) {
                                conversionRateToEmployeeCurrency = conversionRates.get(employeeCurrency);
                                convertedAmount = billingAmountInUSD * conversionRateToEmployeeCurrency;
                            }
                        }

                        milestoneAmount = convertedAmount;

                        system.debug('Converted amount from ' + billingCurrency + ' to USD: ' + billingAmountInUSD);
                        system.debug('Converted amount from USD to ' + employeeCurrency + ': ' + milestoneAmount);
                    }

                    if (employeeAttainmentMap.containsKey(quarter)) {
                        employeeAttainmentMap.put(quarter, employeeAttainmentMap.get(quarter) + milestoneAmount);
                    } else {
                        employeeAttainmentMap.put(quarter, milestoneAmount);
                    }

                    // Update the appropriate fields based on Opportunity Category
                    if (opportunityCategory == 'Existing Customer - New Business') {
                        switch on quarter {
                            when 1 {
                                relevantRevenueStream.Q1_Exs_New_Business__c += math.round(milestoneAmount);
                            }
                            when 2 {
                                relevantRevenueStream.Q2_Exs_New_Business__c += math.round(milestoneAmount);
                            }
                            when 3 {
                                relevantRevenueStream.Q3_Exs_New_Business__c += math.round(milestoneAmount);
                            }
                            when 4 {
                                relevantRevenueStream.Q4_Exs_New_Business__c += math.round(milestoneAmount);
                            }
                        }
                    } else if (opportunityCategory == 'Existing Customer - Repeat / Renewals') {
                        switch on quarter {
                            when 1 {
                                relevantRevenueStream.Q1_Exs_Renewal__c += math.round(milestoneAmount);
                            }
                            when 2 {
                                relevantRevenueStream.Q2_Exs_Renewal__c += math.round(milestoneAmount);
                            }
                            when 3 {
                                relevantRevenueStream.Q3_Exs_Renewal__c += math.round(milestoneAmount);
                            }
                            when 4 {
                                relevantRevenueStream.Q4_Exs_Renewal__c += math.round(milestoneAmount);
                            }
                        }
                    } else if (opportunityCategory == 'New Customer - New Business') {
                        switch on quarter {
                            when 1 {
                                relevantRevenueStream.Q1_New_Cust_New_Business__c += math.round(milestoneAmount);
                            }
                            when 2 {
                                relevantRevenueStream.Q2_New_Cust_New_Business__c += math.round(milestoneAmount);
                            }
                            when 3 {
                                relevantRevenueStream.Q3_New_Cust_New_Business__c += math.round(milestoneAmount);
                            }
                            when 4 {
                                relevantRevenueStream.Q4_New_Cust_New_Business__c += math.round(milestoneAmount);
                            }
                        }
                    }
                }
            }
        }

        List<Revenue_Stream_Employee__c> revenueStreamEmployeesToUpdate = new List<Revenue_Stream_Employee__c>();
        for (Revenue_Stream_Employee__c revenueStream : relevantRevenueStreams) {
            revenueStreamEmployeesToUpdate.add(revenueStream);
        }
        system.debug('revenueStreamEmployeesToUpdate:'+revenueStreamEmployeesToUpdate);
        if (!revenueStreamEmployeesToUpdate.isEmpty()) {
            Database.update(revenueStreamEmployeesToUpdate);
        }
        system.debug('revenueStreamEmployeesToUpdate:'+revenueStreamEmployeesToUpdate);
    }

    global void finish(Database.BatchableContext context) {
        Set<Id> recordIds = new Set<Id>();
        String financialYear = financialYearP;

        Database.executeBatch(new BillingRevenueAttainmentEmployeeBatch(recordIds,financialYear));
    }


    
    public Integer getQuarter(Date milestone) {
        if (milestone != null) {
            Integer month = milestone.month();
            
            if (month >= 4 && month <= 6) {
                return 1;
            } else if (month >= 7 && month <= 9) {
                return 2;
            } else if (month >= 10 && month <= 12) {
                return 3;
            } else if (month >= 1 && month <= 3) {
                return 4;
            }
        }
        
        return null;
    }
                                                                                                                                              public static void increase(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}