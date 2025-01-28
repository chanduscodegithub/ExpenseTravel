trigger TimeOffTrigger on Individual_Time_off__c (before insert) {
    AMSAllTriggerHandler.timeOffError(trigger.new);
}