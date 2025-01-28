public class UpdateCurrentApproverHandler {
    
    public static void updateCurrentApprover(List<Position__c> newList, Map<Id,Position__c> oldMap) {
        Set<Id> requisitionIds = new Set<Id>();
        
        // Collect the IDs of Resource Requisitions where Status__c is changed
        for (Position__c requisition : newList) {
            if (requisition.Status__c != oldMap.get(requisition.Id).Status__c) {
                requisitionIds.add(requisition.Id);
            }
        }
        
        if (!requisitionIds.isEmpty()) {
            // Fetch the latest pending ProcessInstance for each requisition
            List<ProcessInstance> processInstances = [
                SELECT Id, TargetObjectId
                FROM ProcessInstance
                WHERE TargetObjectId IN :requisitionIds AND Status = 'Pending'
                ORDER BY CreatedDate DESC
            ];
            
            // Collect the ProcessInstance IDs
            Set<Id> processInstanceIds = new Set<Id>();
            for (ProcessInstance instance : processInstances) {
                processInstanceIds.add(instance.Id);
            }
            
            if (!processInstanceIds.isEmpty()) {
                // Fetch the latest pending ProcessInstanceStep for each process instance
                List<ProcessInstanceStep> processInstanceSteps = [
                    SELECT Id, ProcessInstanceId, ActorId
                    FROM ProcessInstanceStep
                    WHERE ProcessInstanceId IN :processInstanceIds AND StepStatus = 'Pending'
                    ORDER BY CreatedDate DESC
                ];
                
                // Create a map to store the current approver (user) for each requisition
                Map<Id, Id> requisitionToApproverMap = new Map<Id, Id>();
                for (ProcessInstanceStep step : processInstanceSteps) {
                    for (ProcessInstance instance : processInstances) {
                        if (instance.Id == step.ProcessInstanceId) {
                            requisitionToApproverMap.put(instance.TargetObjectId, step.ActorId);
                            break;
                        }
                    }
                }
                
                // Update the Cu_Approver__c field for each requisition
                for (Position__c requisition : newList) {
                    if (requisitionToApproverMap.containsKey(requisition.Id)) {
                        requisition.Approver__c = requisitionToApproverMap.get(requisition.Id);
                    }
                }
            }
        }
    }
}