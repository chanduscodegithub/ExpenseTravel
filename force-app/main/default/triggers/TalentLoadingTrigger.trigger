trigger TalentLoadingTrigger on Talent_Loading__c (before insert, before update) {
    Set<Id> talentLoadingIds = new Set<Id>();

    // Collect the Talent Loading record IDs
    for (Talent_Loading__c ta : Trigger.new) {
        talentLoadingIds.add(ta.Id);
    }

    // Query child records and group them by Talent Loading record
    Map<Id, List<Talent_Loading_Line__c>> childRecordsMap = new Map<Id, List<Talent_Loading_Line__c>>();
    for (Talent_Loading_Line__c childRecord : [SELECT Talent_Loading__c, Hour__c FROM Talent_Loading_Line__c WHERE Talent_Loading__c IN :talentLoadingIds]) {
        if (!childRecordsMap.containsKey(childRecord.Talent_Loading__c)) {
            childRecordsMap.put(childRecord.Talent_Loading__c, new List<Talent_Loading_Line__c>());
        }
        childRecordsMap.get(childRecord.Talent_Loading__c).add(childRecord);
    }

    // Update the Talent Loading records
    for (Talent_Loading__c ta : Trigger.new) {
        // Retrieve the child records for the current Talent Loading record
        List<Talent_Loading_Line__c> childRecords = childRecordsMap.get(ta.Id);

        Decimal totalHours = 0;
        if (childRecords != null) {
            // Calculate the sum of Hours__c field
            for (Talent_Loading_Line__c childRecord : childRecords) {
                if (childRecord.Hour__c == null) {
                    childRecord.Hour__c = 0;
                }
                totalHours += childRecord.Hour__c;
            }
        }

        // Check if the Talent Loading record is used in Team Allocation
        Boolean isMapped = [SELECT COUNT() FROM TeamAllocation__c WHERE Talent_Loading__c = :ta.Id] > 0;
		
        // Update the RoleForm__c field with the mapped/unmapped label
         ta.RoleForm__c = ta.Role__c + ' | ' + totalHours + ' hrs | ' + (isMapped ? 'Mapped | '+ta.MappedHours__c+' hrs' : 'Unmapped');
    }
}