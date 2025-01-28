trigger amsUpdateAttendenceStatus on Employee_Leave__c (after insert,after update) {
    System.enqueuejob(new updateAttendenceStatusCtrl(Trigger.New,Trigger.NewMap));
}