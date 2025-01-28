public without sharing class carouselclass {
    @AuraEnabled(cacheable=true)
    public static List<Message__c> getmessages() {
        return [ SELECT id,Message_body__c From Message__c WHERE Status__c='Active' and Application_Name__c='Timesheet' ORDER BY CreatedDate ASC];
    }
}