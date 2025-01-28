global class BillingRevenueAttainmentEmployeeBatch implements Database.Batchable<SObject> {
    private Set<Id> recordIds;
    string financialYearP;

    
    public BillingRevenueAttainmentEmployeeBatch(Set<Id> recordIds,string financialYear) {
        this.recordIds = recordIds;
        this.financialYearP=financialYear;
    }
    
   
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        Integer fiscalYearStartMonth = 4; // April
    Integer fiscalYearStartYear = Integer.valueOf(financialYearP);
    Date fiscalYearStartDate = Date.newInstance(fiscalYearStartYear, fiscalYearStartMonth, 1);
    Date fiscalYearEndDate = fiscalYearStartDate.addYears(1).addDays(-1);
   String query = 'SELECT Id, Invoice_Amount__c, Invoice_Date__c, OpportunityName__r.Owner.Name, OpportunityName__r.CurrencyIsoCode, OpportunityName__r.Name, OpportunityName__r.Opportunity_Category__c FROM Billing__c WHERE OpportunityName__r.StageName = \'Opportunity Won\' AND OpportunityName__r.Owner.Name != null AND OpportunityName__r.Opportunity_Category__c != Null AND Invoice_Date__c != null AND Invoice_Amount__c != null '+'AND Invoice_Date__c >= :fiscalYearStartDate'+' AND Invoice_Date__c <= :fiscalYearEndDate';
        system.debug('query'+query);
        // Reset the quarterly attainment fields to zero before starting the batch
        List<Revenue_Stream_Employee__c> resetRevenueStreams = [
            SELECT Id, Q1_Revenue_Attainment__c, Q2_Revenue_Attainment__c,
            Q3_Revenue_Attainment__c, Q4_Revenue_Attainment__c, Currency__c
            FROM Revenue_Stream_Employee__c 
        ];
        
        for (Revenue_Stream_Employee__c resetRevenueStream : resetRevenueStreams) {
            resetRevenueStream.Q1_Revenue_Attainment__c = 0;
            resetRevenueStream.Q2_Revenue_Attainment__c = 0;
            resetRevenueStream.Q3_Revenue_Attainment__c = 0;
            resetRevenueStream.Q4_Revenue_Attainment__c = 0;
        }
        
        update resetRevenueStreams; // Update the reset records
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<Billing__c> scope) {
        Set<String> employeeNames = new Set<String>();
        Map<Id, Decimal> billClosedYear = new Map<Id, Decimal>();
        // Determine the currencies involved
        Set<String> billingCurrencies = new Set<String>();
        Set<String> employeeCurrencies = new Set<String>();
        
        for (Billing__c bill : scope) {
            employeeNames.add(bill.OpportunityName__r.Owner.Name);
            billClosedYear.put(bill.Id, bill.Invoice_Date__c.year());
            billingCurrencies.add(bill.OpportunityName__r.CurrencyIsoCode);
        }
        
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
            Q3_Revenue_Attainment__c, Q4_Revenue_Attainment__c, Finance_Year__c, Currency__c
            FROM Revenue_Stream_Employee__c
            WHERE Employees__r.Name IN :employeeNames AND Finance_Year__c =: financialYearP
        ];
        
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
        Decimal milestoneYear = billClosedYear.get(bill.Id);
        system.debug('billid:'+bill.Id);
        system.debug('amount:'+milestoneAmount);
        
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

                // Convert the opportunity amount to USD
                Decimal billingAmountInUSD = milestoneAmount;
                Decimal conversionRateToUSD = 1; // Default to 1 if no conversion rate found

                if (!billingCurrency.equals('USD')) {
                    if (conversionRates.containsKey(billingCurrency)) {
                        conversionRateToUSD = conversionRates.get(billingCurrency);
                        billingAmountInUSD = milestoneAmount / conversionRateToUSD;
                    }
                }

                // Convert the opportunity amount from USD to employee's currency
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

                if (employeeAttainmentMap.containsKey(quarter)) {
                    employeeAttainmentMap.put(quarter, employeeAttainmentMap.get(quarter) + milestoneAmount);
                } else {
                    employeeAttainmentMap.put(quarter, milestoneAmount);
                }
            }
        }
    }      
        List<Revenue_Stream_Employee__c> revenueStreamEmployeesToUpdate = new List<Revenue_Stream_Employee__c>();
        for (Revenue_Stream_Employee__c revenueStream : relevantRevenueStreams) {
            String employeeName = revenueStream.Employees__r.Name;
            Map<Integer, Decimal> employeeAttainmentMap = quarterlyAttainmentMap.get(employeeName);
            
            if (employeeAttainmentMap != null && employeeRevenueStreamMap.containsKey(employeeName)) {
                Decimal q1BillAttainment = employeeAttainmentMap.containsKey(1) ? Math.round(employeeAttainmentMap.get(1)) : 0;
                Decimal q2BillAttainment = employeeAttainmentMap.containsKey(2) ? Math.round(employeeAttainmentMap.get(2)) : 0;
                Decimal q3BillAttainment = employeeAttainmentMap.containsKey(3) ? Math.round(employeeAttainmentMap.get(3)) : 0;
                Decimal q4BillAttainment = employeeAttainmentMap.containsKey(4) ? Math.round(employeeAttainmentMap.get(4)) : 0;
                
                Revenue_Stream_Employee__c updatedRevenueStream = new Revenue_Stream_Employee__c();
                updatedRevenueStream.Id = revenueStream.Id;
                updatedRevenueStream.Q1_Revenue_Attainment__c = revenueStream.Q1_Revenue_Attainment__c + q1BillAttainment;
                updatedRevenueStream.Q2_Revenue_Attainment__c = revenueStream.Q2_Revenue_Attainment__c + q2BillAttainment;
                updatedRevenueStream.Q3_Revenue_Attainment__c = revenueStream.Q3_Revenue_Attainment__c + q3BillAttainment;
                updatedRevenueStream.Q4_Revenue_Attainment__c = revenueStream.Q4_Revenue_Attainment__c + q4BillAttainment;
                revenueStreamEmployeesToUpdate.add(updatedRevenueStream);
            }
        }
                        

        
        if (!revenueStreamEmployeesToUpdate.isEmpty()) {
            Database.update(revenueStreamEmployeesToUpdate);
        }
    }
    
    global void finish(Database.BatchableContext context) {
        
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
}