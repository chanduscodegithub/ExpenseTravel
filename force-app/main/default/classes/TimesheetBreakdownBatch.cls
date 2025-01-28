global class TimesheetBreakdownBatch implements Database.Batchable<sObject>{
	global Database.QueryLocator start(Database.BatchableContext BC){
        //String query = 'SELECT Id FROM Team_Timesheet__c';
        String query = 'SELECT Id, Name FROM Team_Timesheet__c WHERE Billable_hours__c = null OR Non_Billable_hours__c = null OR Leave_Hours__c = null limit 100';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Team_Timesheet__c> scope){
        for(Team_Timesheet__c eachParentTS : scope){
            ProcessTimeSheetBreakdown.processTS(eachParentTS.Id);
        }
    }
    global void finish(Database.BatchableContext BC){
        
    }
}