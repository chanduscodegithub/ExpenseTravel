trigger UpdateModeInActivity on Attendance_Activity__c (after insert) {
    Set<Id> AllAtdIds = new Set<Id>();
    for(Attendance_Activity__c activity : Trigger.New){
        AllAtdIds.add(activity.Attendance__c);
    }
    if(AllAtdIds.size() > 0){
        attendenceTimerCmpCtrl.updateModes(AllAtdIds); 
    } 
}