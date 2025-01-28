global class SalesRevenueAttainmentEmployeeBatch implements Database.Batchable<SObject> {
    private Set<Id> recordIds;
    
    string financialYearP;
    
    // Constructor to accept recordIds and financialYear as parameters
    public SalesRevenueAttainmentEmployeeBatch(Set<Id> recordIds, string financialYear) {
        this.recordIds = recordIds;
        this.financialYearP = financialYear;
    }
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        Integer fiscalYearStartMonth = 4; // April
        Integer fiscalYearStartYear = Integer.valueOf(financialYearP);
        Date fiscalYearStartDate = Date.newInstance(fiscalYearStartYear, fiscalYearStartMonth, 1);
        Date fiscalYearEndDate = fiscalYearStartDate.addYears(1).addDays(-1);
        
        String query = 'SELECT Id, Owner.Name, Closed_Year__c, CloseDate, CurrencyIsoCode, Amount, Name FROM Opportunity ' +
            'WHERE CloseDate != null AND StageName = \'Opportunity Won\' AND Owner.Name != null ' +
            'AND CloseDate >= :fiscalYearStartDate AND CloseDate <= :fiscalYearEndDate';
        
        // Reset the quarterly attainment fields to zero before starting the batch
        List<Revenue_Stream_Employee__c> resetRevenueStreams = [
            SELECT Id, Q1_Opportunity_Actuals__c, Q2_Opportunity_Actuals__c,
            Q3_Opportunity_Actuals__c, Q4_Opportunity_Actuals__c, Currency__c
            FROM Revenue_Stream_Employee__c 
        ];
        
        for (Revenue_Stream_Employee__c resetRevenueStream : resetRevenueStreams) {
            resetRevenueStream.Q1_Opportunity_Actuals__c = 0;
            resetRevenueStream.Q2_Opportunity_Actuals__c = 0;
            resetRevenueStream.Q3_Opportunity_Actuals__c = 0;
            resetRevenueStream.Q4_Opportunity_Actuals__c = 0;
        }
        
        update resetRevenueStreams; // Update the reset records
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<Opportunity> scope) {
        
        try{
            Set<String> employeeNames = new Set<String>();
            Map<Id, Decimal> oppclosedyear = new Map<Id, Decimal>();
            
            // Determine the currencies involved
            Set<String> opportunityCurrencies = new Set<String>();
            Set<String> employeeCurrencies = new Set<String>();
            
            for (Opportunity opp : scope) {
                employeeNames.add(opp.Owner.name);
                oppclosedyear.put(opp.Id, opp.Closed_Year__c);
                opportunityCurrencies.add(opp.CurrencyIsoCode);
            }
            
            // Fetching the latest conversion rates
            Map<String, Decimal> conversionRates = new Map<String, Decimal>();
            
            // Query the latest conversion rates for each currency
            for (DatedConversionRate rate : [
                SELECT ConversionRate, IsoCode
                FROM DatedConversionRate
                WHERE StartDate <= TODAY AND IsoCode IN :opportunityCurrencies
                ORDER BY IsoCode, StartDate ASC // Sort by ISO code and start date
            ]) {
                // Add the conversion rate to the map if it doesn't exist
                conversionRates.put(rate.IsoCode, rate.ConversionRate);
            }
            system.debug('conversionrate:'+conversionRates);
            
            List<Revenue_Stream_Employee__c> relevantRevenueStreams = [
                SELECT Id, Employees__c, Employees__r.Name, Q1_Opportunity_Actuals__c, Q2_Opportunity_Actuals__c,
                Q3_Opportunity_Actuals__c, Q4_Opportunity_Actuals__c, Finance_Year__c, Currency__c
                FROM Revenue_Stream_Employee__c
                WHERE Employees__r.Name IN :employeeNames AND Finance_Year__c =: financialYearP
            ];
            
            Map<String, Revenue_Stream_Employee__c> employeeRevenueStreamMap = new Map<String, Revenue_Stream_Employee__c>();
            for (Revenue_Stream_Employee__c revenueStream : relevantRevenueStreams) {
                employeeRevenueStreamMap.put(revenueStream.Employees__r.Name, revenueStream);
                employeeCurrencies.add(revenueStream.Currency__c);
            }
            
            Map<String, Map<Integer, Decimal>> quarterlyAttainmentMap = new Map<String, Map<Integer, Decimal>>();
            for (Opportunity opp : scope) {
                String employeeName = opp.Owner.name;
                Decimal milestoneAmount = opp.Amount;
                Date milestoneDate = opp.CloseDate;
                Decimal milestoneYear = oppclosedyear.get(opp.Id);
                system.debug('oppid:'+opp.Id);
                system.debug('amount:'+milestoneAmount);
                
                if (milestoneDate != null && employeeName != null && employeeRevenueStreamMap.containsKey(employeeName) && milestoneYear != null && String.valueOf(milestoneYear) == financialYearP) {
                    Revenue_Stream_Employee__c relevantRevenueStream = employeeRevenueStreamMap.get(employeeName);
                    Date financeYearStartDate = Date.newInstance(Integer.valueOf(relevantRevenueStream.Finance_Year__c), 4, 1);
                    Date financeYearEndDate = financeYearStartDate.addYears(1).addDays(-1);
                    
                    if (milestoneDate >= financeYearStartDate && milestoneDate <= financeYearEndDate) {
                        Integer quarter = getQuarter(milestoneDate);
                        system.debug('milestoneAmount:'+milestoneAmount);
                        System.debug('quarter:::'+quarter);
                        
                        if (!quarterlyAttainmentMap.containsKey(employeeName)) {
                            quarterlyAttainmentMap.put(employeeName, new Map<Integer, Decimal>());
                        }
                        
                        Map<Integer, Decimal> employeeAttainmentMap = quarterlyAttainmentMap.get(employeeName);
                        
                        // Determine opportunity and employee currency
                        // Determine opportunity and employee currency
                        String opportunityCurrency = opp.CurrencyIsoCode;
                        String employeeCurrency = relevantRevenueStream.Currency__c;
                        
                        // Check if opportunity currency is different from employee currency
                        if (!opportunityCurrency.equals(employeeCurrency)) {
                            // Convert the opportunity amount to USD
                            Decimal opportunityAmountInUSD = milestoneAmount;
                            Decimal conversionRateToUSD = 1; // Default to 1 if no conversion rate found
                            
                            if (!opportunityCurrency.equals('USD')) {
                                if (conversionRates.containsKey(opportunityCurrency)) {
                                    conversionRateToUSD = conversionRates.get(opportunityCurrency);
                                    opportunityAmountInUSD = milestoneAmount / conversionRateToUSD;
                                }
                            }
                            
                            // Convert the opportunity amount from USD to employee's currency
                            Decimal convertedAmount = opportunityAmountInUSD; // Initialize with USD amount
                            if (!employeeCurrency.equals('USD')) {
                                Decimal conversionRateToEmployeeCurrency = 1; // Default to 1 if no conversion rate found
                                if (conversionRates.containsKey(employeeCurrency)) {
                                    conversionRateToEmployeeCurrency = conversionRates.get(employeeCurrency);
                                    convertedAmount = opportunityAmountInUSD * conversionRateToEmployeeCurrency;
                                }
                            }
                            
                            milestoneAmount = convertedAmount;
                            
                            
                            system.debug('Converted amount from ' + opportunityCurrency + ' to USD: ' + opportunityAmountInUSD);
                            system.debug('Converted amount from USD to ' + employeeCurrency + ': ' + milestoneAmount);
                            
                        }
                        
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
                    Decimal q1Attainment = employeeAttainmentMap.containsKey(1) ? math.round(employeeAttainmentMap.get(1)) : 0;
                    Decimal q2Attainment = employeeAttainmentMap.containsKey(2) ? math.round(employeeAttainmentMap.get(2)) : 0;
                    Decimal q3Attainment = employeeAttainmentMap.containsKey(3) ? math.round(employeeAttainmentMap.get(3)) : 0;
                    Decimal q4Attainment = employeeAttainmentMap.containsKey(4) ? math.round(employeeAttainmentMap.get(4)) : 0;
                    
                    Revenue_Stream_Employee__c updatedRevenueStream = new Revenue_Stream_Employee__c();
                    updatedRevenueStream.Id = revenueStream.Id;
                    updatedRevenueStream.Q1_Opportunity_Actuals__c = revenueStream.Q1_Opportunity_Actuals__c + q1Attainment;
                    updatedRevenueStream.Q2_Opportunity_Actuals__c = revenueStream.Q2_Opportunity_Actuals__c + q2Attainment;
                    updatedRevenueStream.Q3_Opportunity_Actuals__c = revenueStream.Q3_Opportunity_Actuals__c + q3Attainment;
                    updatedRevenueStream.Q4_Opportunity_Actuals__c = revenueStream.Q4_Opportunity_Actuals__c + q4Attainment;
                    revenueStreamEmployeesToUpdate.add(updatedRevenueStream);
                    system.debug('q4actual:'+updatedRevenueStream.Q4_Opportunity_Actuals__c);
                    system.debug('q3actual:'+ updatedRevenueStream.Q3_Opportunity_Actuals__c);
                }
                
            }
            if (!revenueStreamEmployeesToUpdate.isEmpty()) {
                Database.update(revenueStreamEmployeesToUpdate);
            } 
        }catch(Exception e){
            System.debug(e);
        }
        
    }
    
    
    global void finish(Database.BatchableContext context) {
        Set<Id> recordIds = new Set<Id>();
        String financialYear = financialYearP;
        
        
        Database.executeBatch(new BillingCategorySalesRevenue(recordIds,financialYearP));
        
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