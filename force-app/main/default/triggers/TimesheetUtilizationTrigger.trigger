trigger TimesheetUtilizationTrigger on Team_Timesheet__c (after insert, after update) {
    new TimesheetUtilizationTriggerHelper().run();
}