public class RRLockingUnlocking {
    // Method to unlock the Position record
   /* public static void unlockRRRecord(Id positionId) {
        Position__c positionRecord = [SELECT Id, Is_Record_Locked__c FROM Position__c WHERE Id = :positionId];
        if (positionRecord != null) {
            positionRecord.Is_Record_Locked__c = false;
            update positionRecord;
        }
    }

    // Method to lock the Position record
    public static void lockRRRecord(Id positionId) {
        Position__c positionRecord = [SELECT Id, Is_Record_Locked__c FROM Position__c WHERE Id = :positionId];
        if (positionRecord != null) {
            positionRecord.Is_Record_Locked__c = true;
            update positionRecord;
        }
    }*/
}