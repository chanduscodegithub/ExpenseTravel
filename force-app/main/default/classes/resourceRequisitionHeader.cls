public with sharing class resourceRequisitionHeader {
    @AuraEnabled(cacheable=true)
    public static Position__c fetchRecordDetails(Id recordId) {
        try {
            Position__c positionRecord = [
                SELECT Id, Name, Position_Title__c 
                FROM Position__c 
                WHERE Id = :recordId
                LIMIT 1
            ];
            return positionRecord;
        } catch (Exception e) {
            throw new AuraHandledException('Unable to fetch record details: ' + e.getMessage());
        }
    }
}