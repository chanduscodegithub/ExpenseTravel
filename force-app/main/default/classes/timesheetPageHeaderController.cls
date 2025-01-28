public without sharing class timesheetPageHeaderController {
    public class header_wrapper{
        @AuraEnabled
        public Team_Timesheet__c tsData {get;set;}
        @AuraEnabled
        public Boolean isManager;
    }
    @AuraEnabled
    public static header_wrapper getTimesheetDetails(String recID){
        header_wrapper allData = new header_wrapper();
        try {
            allData.tsData = [SELECT Name, Status__c, OwnerId, Reporting_Manager__c FROM Team_Timesheet__c WHERE Id=:recID];
            allData.isManager = allData.tsData.Reporting_Manager__c == UserInfo.getUserId() ? true : false;
        } catch (Exception e) {
            System.debug('Exception: '+e.getMessage() + ' at ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return allData;
    }
}