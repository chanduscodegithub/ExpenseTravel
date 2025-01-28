trigger TotalJobApplicationsTrigger on Job_Application__c (after insert,after update, after delete, after undelete) {
    Set<Id> positionIds = new Set<Id>();
/**
    for (Job_Application__c jobApp : Trigger.new) {
        if (jobApp.Position__c != null) {
            positionIds.add(jobApp.Position__c);
        }
    }
     if (Trigger.isUpdate) {
        for (Job_Application__c jobApp : Trigger.old) {
            if (jobApp.Position__c != null) {
                positionIds.add(jobApp.Position__c);
            }
        }
     }
    
    if (Trigger.isDelete) {
        for (Job_Application__c jobApp : Trigger.old) {
            if (jobApp.Position__c != null) {
                positionIds.add(jobApp.Position__c);
            }
        }
    }
    
   List<Position__c> positions = [SELECT Id, (SELECT Id FROM Job_Applications__r) FROM Position__c WHERE Id IN :positionIds];
    
    List<Position__c> positionsToUpdate = new List<Position__c>();
    for (Position__c pos : positions) {
        pos.Total_Job_Applications__c = pos.Job_Applications__r.size();
        positionsToUpdate.add(pos);
    }
    
    if (positionsToUpdate.size() > 0) {
        update positionsToUpdate;
    }
**/
}