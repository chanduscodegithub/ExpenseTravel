public with sharing class QuotaTargetController {
    
    @AuraEnabled(cacheable=true)
    public static List<String> getFinancialYears() {
        List<String> financialYears = new List<String>();
        
        // Query to fetch distinct Financial Years from Revenue_Stream_Employee__c object
        for (AggregateResult result : [SELECT Finance_Year__c FROM Revenue_Stream_Employee__c WHERE Finance_Year__c != null GROUP BY Finance_Year__c]) {
            financialYears.add((String)result.get('Finance_Year__c'));
        }
        
        return financialYears;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getRegions() {
        List<String> regions = new List<String>();
        
        // Query to fetch distinct Regions from Revenue_Stream_Employee__c object
        for (AggregateResult result : [SELECT Region__c FROM Revenue_Stream_Employee__c WHERE Region__c != null GROUP BY Region__c]) {
            regions.add((String)result.get('Region__c'));
        }
        
        return regions;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getCategories() {
        List<String> categories = new List<String>();
        
        // Query to fetch distinct Categories from Revenue_Stream_Employee__c object
        for (AggregateResult result : [SELECT Type__c FROM Revenue_Stream_Employee__c WHERE Type__c != null GROUP BY Type__c]) {
            categories.add((String)result.get('Type__c'));
        }
        
        return categories;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Revenue_Stream_Employee__c> getQuotaTargets(String financialYear, List<String> regions, List<String> categories) {
        // Query to fetch Quota Target records based on selected criteria
        String query = 'SELECT Id, Name, Finance_Year__c, Region__c, Type__c FROM Revenue_Stream_Employee__c WHERE';
        
        // Add filter for Financial Year
        query += ' Financial_Year__c = \'' + financialYear + '\'';
        
        // Add filter for Region(s)
        if (regions != null && !regions.isEmpty()) {
            query += ' AND Region__c IN (';
            for (Integer i = 0; i < regions.size(); i++) {
                query += '\'' + regions[i] + '\'';
                if (i < regions.size() - 1) {
                    query += ', ';
                }
            }
            query += ')';
        }
        
        // Add filter for Category(s)
        if (categories != null && !categories.isEmpty()) {
            query += ' AND Type__c IN (';
            for (Integer i = 0; i < categories.size(); i++) {
                query += '\'' + categories[i] + '\'';
                if (i < categories.size() - 1) {
                    query += ', ';
                }
            }
            query += ')';
        }
        
        // Execute the query
        return Database.query(query);
    }
}