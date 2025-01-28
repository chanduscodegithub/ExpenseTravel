trigger TimesheetApprovalFileTrigger on ContentDocumentLink (after insert) {

		
   Id tsaIds;
    
    // Collect the timesheet Approval Ids from the new ContentDocumentLinks
    for (ContentDocumentLink link : Trigger.new) {
        system.debug('tsaIds before if>>'+link.LinkedEntityId);
        if (link.LinkedEntityId.getSObjectType() == Timesheet_Approval__c.SObjectType) {
            String sObjName = link.LinkedEntityId.getSObjectType().getDescribe().getName();
            System.debug('sObjName::'+sObjName);
            system.debug('tsaIds after if>>'+link.LinkedEntityId.getSObjectType());
            tsaIds=link.LinkedEntityId;
            system.debug('tsaIds 1111 if>>'+link.LinkedEntityId);
        }
    }
    system.debug('tsaIds>>'+tsaIds);
    if(tsaIds == null){
        return;
    }
    // Query to check if there are existing ContentDocumentLinks for the same Timesheet
    Map<Id,Integer> tsFileCounts = new Map<Id,Integer>();
    for (ContentDocumentLink existingLink : [SELECT LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: tsaIds]) {
        Id tsaId = existingLink.LinkedEntityId;
        if (!tsFileCounts.containsKey(tsaId)) {
            tsFileCounts.put(tsaId, 1);
        } else {
            tsFileCounts.put(tsaId, tsFileCounts.get(tsaId) + 1);
        }
    }
    
    // Check if there are multiple files associated with the same Account
    for (ContentDocumentLink newLink : Trigger.new) {
       // if (newLink.LinkedEntityId.getSObjectType() == Team_Timesheet__c.SObjectType) {
            Id tsaId1 = newLink.LinkedEntityId;
            if (tsFileCounts.containsKey(tsaId1) && tsFileCounts.get(tsaId1) > 1) {
                newLink.addError('Only one file is allowed for this Timesheet.');
            }
       // }
    }
}