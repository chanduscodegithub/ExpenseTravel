global class TimesheetUtilizationBatch implements Database.Batchable<sObject>{
	global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Name FROM Team_Timesheet__c WHERE (Status__c=\'Approved\' OR Status__c=\'Submitted\') AND Util_Created__c=0 limit 50';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Team_Timesheet__c> scope){
        for(Team_Timesheet__c eachTS: scope){
            ProcessTimesheetUtilization.processUtil(eachTS.Id);
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
}