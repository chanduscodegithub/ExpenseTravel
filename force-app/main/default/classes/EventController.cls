public without sharing class EventController {
    
    @AuraEnabled(cacheable=true)
    public static List<Attendance__c> getAttendence() {
        return [SELECT Id,Name,Status_Of_Day__c,Regularization__c,Date__c FROM Attendance__c where Employee_User__c =:UserInfo.getUserId() and Date__c != TODAY and Days_of_the_week__c != 'Saturday' and Days_of_the_week__c != 'Sunday' ORDER BY Date__c DESC ];
    }
}