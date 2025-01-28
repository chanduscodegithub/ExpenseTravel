trigger EmpLeaveBalanceTrigger on Employee_Leave_Balance__c (before insert) {
     AMSAllTriggerHandler.preventDuplicateLeaveBalance(Trigger.new);
}