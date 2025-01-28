public with sharing class FinancialPlanningController {
    @AuraEnabled(cacheable=true)
    public static List<String> getFinancialYears() {
        Integer currentYear = Date.today().year();
        Integer startYear = 2023;
        List<String> years = new List<String>();

        for (Integer year = startYear; year <= currentYear; year++) {
            years.add(String.valueOf(year));
        }

        return years;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Financial_Planning__c> getFinancialPlanningRecords(String year) {
        List<Financial_Planning__c> records = new List<Financial_Planning__c>();
        
        try {
            year = String.escapeSingleQuotes(year); // Prevent SOQL injection
            
            records = [SELECT Id, Name, Total_Region_Amount__c, FP_Year__c
                       FROM Financial_Planning__c
                       WHERE FP_Year__c = :year];
            
            List<Financial_Planning__c> sortedRecords = new List<Financial_Planning__c>();
            Map<String, Integer> sortOrderMap = new Map<String, Integer>{
                'FY-2023-Budget' => 1,
                    'FY-2023-Quota' => 2,
                    'FY-2023-Aspirational Goals' => 3
                    };
                        
                        // Sort the records based on the defined order
                        for (String sortOrderKey : sortOrderMap.keySet()) {
                            for (Financial_Planning__c record : records) {
                                if (record.Name == sortOrderKey) {
                                    sortedRecords.add(record);
                                }
                            }
                        }
            
            // Add remaining records not present in the defined order
            for (Financial_Planning__c record : records) {
                if (!sortedRecords.contains(record)) {
                    sortedRecords.add(record);
                }
            }
            
            records = sortedRecords;
        } catch (Exception ex) {
            // Handle the exception or log the error
            System.debug('An error occurred: ' + ex.getMessage());
            return records;
        }
        
        return records;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Revenue_Stream_Region__c> getRevenueStreamRegions(String financialPlanningName) {
        List<Financial_Planning__c> financialPlanningRecords = [SELECT Id FROM Financial_Planning__c WHERE Name LIKE :financialPlanningName + '%'];

        if (financialPlanningRecords.isEmpty()) {
            return new List<Revenue_Stream_Region__c>();
        }

        Id financialPlanningId = financialPlanningRecords[0].Id;

        return [
            SELECT Id, Opportunity_Region__c,Q1_attainmnet_colour__c,Q2_attainmnet_colour__c,Q4_attainmnet_colour__c, Q1_Revenue_Attainment__c, Quarter_1_Target__c, Quarter_2_Target__c, Q3_Revenue_Attainment__c, Quarter_3_Target__c, Q3_Attainment__c, Q4_Revenue_Attainment__c, Quarter_4_Target__c, Q4_Attainmnet__c,Yearly_Actual__c,Yearly_Attainment__c,Yearly_Target__c,Yearly_attainment_color__c,Gross_Margin_Attainment__c,Annual_Gross_Margin__c,Actual_Gross_Margin__c,
            Currency__c	
            FROM Revenue_Stream_Region__c
            WHERE Revenue_Stream_Forecasting__c = :financialPlanningId
        ];
    }

    @AuraEnabled(cacheable=true)
    public static List<Revenue_Stream_Employee__c> getRevenueStreamEmployees(String financialPlanningName) {
        List<Financial_Planning__c> financialPlanningRecords = [SELECT Id FROM Financial_Planning__c WHERE Name LIKE :financialPlanningName + '%' ];
        

        if (financialPlanningRecords.isEmpty()) {
            return new List<Revenue_Stream_Employee__c>();
        }

        Id financialPlanningId = financialPlanningRecords[0].Id;

        return [
            SELECT Id, Employees__r.Name, Q1_Revenue_Attainment__c,Q1_Percent__c, Q1_Target__c,Q2_Percentage__c, Q2_Revenue_Attainment__c, Q2_Target__c, Q2_Attainment__c, Q3_Revenue_Attainment__c, Q3_Target__c, Q3_Attainment__c, Q4_Revenue_Attainment__c, Q4_Target__c, Q4_Attainmnet__c,Yearly_Actual__c,Yearly_Attainment__c,Yearly_Target__c,Yearly_Attainment_color__c,Actual_Gross_Margin__c,
            Annual_Gross_Margin__c,Gross_Margin_Attainment__c,CurrencyIsoCode	
            FROM Revenue_Stream_Employee__c
            WHERE Revenue_Stream_Forecasting__c = :financialPlanningId
        ];
    }
    
}