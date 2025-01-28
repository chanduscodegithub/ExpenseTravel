public class FetchingFieldsController {
    @AuraEnabled(cacheable = true)
    public static List<et4ae5__IndividualEmailResult__c> getIndividualEmailResult(String recordId) {
        return [select id,et4ae5__Lead__r.id,Name,et4ae5__FromName__c,et4ae5__FromAddress__c, et4ae5__SubjectLine__c, et4ae5__DateSent__c from et4ae5__IndividualEmailResult__c where et4ae5__Lead__r.id =:recordId or et4ae5__Contact__r.id =: recordId];
    }

}