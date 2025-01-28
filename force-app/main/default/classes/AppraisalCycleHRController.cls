public with sharing class AppraisalCycleHRController {
  @AuraEnabled(cacheable=true)
  public static string appraisalYear(String year){
    try {
       Appraisal__c appraisalRecord= [Select Id, QPR_Year__c from Appraisal__c where QPR_Year__c= :year LIMIT 1] ;
       if(appraisalRecord != null){
        system.debug('The record Id is'+appraisalRecord.Id);
        return appraisalRecord.Id;
       }else {
        return 'No case record found';
       }
        
    } catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
  }
   @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getPicklistValues() {
        List<Schema.PicklistEntry> entries = Appraisal__c.QPR_Year__c.getDescribe().getPicklistValues();
        List<Map<String, String>> values = new List<Map<String, String>>();
        for (Schema.PicklistEntry entry : entries) {
           
            Map<String, String> valueMap = new Map<String, String>();
          
            valueMap.put('label', entry.getLabel());
            valueMap.put('value', entry.getValue());
           
            values.add(valueMap);
        }
        
        return values;
    }
     @AuraEnabled(cacheable=true)
    public static boolean chkthisyeardata() {
        String year= String.valueOf(Date.Today().Year());
        try {
       Appraisal__c appraisalRecord= [Select Id, QPR_Year__c from Appraisal__c where QPR_Year__c= :year LIMIT 1] ;
       if(appraisalRecord != null){
       
        return false;
       }else {
        return true;
       }
        
    }catch (Exception e) {
        throw new AuraHandledException(e.getMessage());
    }
    }
  
}