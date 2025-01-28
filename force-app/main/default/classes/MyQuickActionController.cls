public with sharing class MyQuickActionController {
    @AuraEnabled
    public static Boolean hasSelectedCandidate(Id resourceRequisitionId) {
        System.debug('Id is'+resourceRequisitionId);
        List<Job_Application__c> jobApplications = [
            SELECT Picklist__c
            FROM Job_Application__c
            WHERE Position__c = :resourceRequisitionId
            AND Picklist__c = 'Candidate Selected'
            LIMIT 1
        ];
        return !jobApplications.isEmpty();
    }
}