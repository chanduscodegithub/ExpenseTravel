trigger UpdateHire on Job_Application__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (Trigger.isAfter) {
        Set<Id> positionIds = new Set<Id>();

        if (Trigger.isInsert || Trigger.isUpdate) {
            // Collect the Position IDs from the Job Application records
            for (Job_Application__c jobApp : Trigger.new) {
                if (jobApp.Position__c != null) {
                    positionIds.add(jobApp.Position__c);
                }
            }
        } else if (Trigger.isDelete) {
            // Collect the Position IDs from the Job Application records being deleted
            for (Job_Application__c jobApp : Trigger.old) {
                if (jobApp.Position__c != null) {
                    positionIds.add(jobApp.Position__c);
                }
            }
        }

        if (!positionIds.isEmpty()) {
            resourceRequisitionHireStatus.updatePositionStatus(positionIds);
        }
    }
}