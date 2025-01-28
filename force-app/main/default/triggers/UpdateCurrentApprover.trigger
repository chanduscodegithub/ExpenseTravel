trigger UpdateCurrentApprover on Position__c (after insert, after update) {
    // Set to hold Resource Requisition IDs that need to be updated
    Set<Id> requisitionIds = new Set<Id>();
    
    for (Position__c requisition : Trigger.new) {
        requisitionIds.add(requisition.Id);
    }
    
    // Query to find the latest ProcessInstanceWorkitem for each Resource Requisition
    List<ProcessInstanceWorkitem> workItems = [
        SELECT ActorId, ProcessInstance.TargetObjectId
        FROM ProcessInstanceWorkitem 
        WHERE ProcessInstance.TargetObjectId IN :requisitionIds
        ORDER BY CreatedDate DESC
    ];
    
    // Map to hold the latest approver for each requisition
    Map<Id, Id> requisitionToApproverMap = new Map<Id, Id>();
    
    for (ProcessInstanceWorkitem workItem : workItems) {
        if (!requisitionToApproverMap.containsKey(workItem.ProcessInstance.TargetObjectId)) {
            requisitionToApproverMap.put(workItem.ProcessInstance.TargetObjectId, workItem.ActorId);
        }
    }
    
    // List to hold the Resource Requisition records to update
    List<Position__c> requisitionsToUpdate = new List<Position__c>();
    
    for (Id requisitionId : requisitionIds) {
        if (requisitionToApproverMap.containsKey(requisitionId)) {
            Position__c requisitionToUpdate = new Position__c(
                Id = requisitionId, 
                APP__c = requisitionToApproverMap.get(requisitionId)
            );
            requisitionsToUpdate.add(requisitionToUpdate);
        }
    }
    
    // Update the Resource Requisition records
    if (!requisitionsToUpdate.isEmpty()) {
        update requisitionsToUpdate;
    }
}