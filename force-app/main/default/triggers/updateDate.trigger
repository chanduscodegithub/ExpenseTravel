trigger updateDate on et4ae5__IndividualEmailResult__c (after insert) {

    Set<Id> contactIds = new Set<Id>();
    Set<Id> leadIds = new Set<Id>();

    for (et4ae5__IndividualEmailResult__c sfmc : Trigger.new) {
        if (sfmc.et4ae5__Contact_ID__c != null) {
            contactIds.add(sfmc.et4ae5__Contact_ID__c);
        } if (sfmc.et4ae5__Lead_ID__c != null) {
            leadIds.add(sfmc.et4ae5__Lead_ID__c);
        }
    }

    Map<Id, Contact> contactsMap = new Map<Id, Contact>([SELECT Id, Email FROM Contact WHERE Id IN :contactIds]);
    Map<Id, Lead> leadsMap = new Map<Id, Lead>([SELECT Id, Email FROM Lead WHERE Id IN :leadIds]);

    List<Task> newEmailActivities = new List<Task>();

    for (et4ae5__IndividualEmailResult__c sfmc : Trigger.new) {
        if (sfmc.et4ae5__Contact_ID__c != null) {
            Contact contact = contactsMap.get(sfmc.et4ae5__Contact_ID__c);
            Task newEmailActivity = createTask(sfmc, contact.Id);
            newEmailActivities.add(newEmailActivity);
        } if (sfmc.et4ae5__Lead_ID__c != null) {
            Lead lead = leadsMap.get(sfmc.et4ae5__Lead_ID__c);
            Task newEmailActivity = createTask(sfmc, lead.Id);
            newEmailActivities.add(newEmailActivity);
        }
    }

    if (!newEmailActivities.isEmpty()) {
        insert newEmailActivities;
    }


public Task createTask(et4ae5__IndividualEmailResult__c sfmc, Id whoId) {
    Task newEmailActivity = new Task();
    newEmailActivity.Subject = sfmc.et4ae5__SubjectLine__c;
    newEmailActivity.TaskSubtype = 'Email';
    newEmailActivity.WhoId = whoId;
    newEmailActivity.Status = 'Completed';
    newEmailActivity.Email_Name__c = sfmc.Name;
    newEmailActivity.From_Name__c = sfmc.et4ae5__FromName__c;
    newEmailActivity.From_Address__c = sfmc.et4ae5__FromAddress__c;
    newEmailActivity.ActivityDate = Date.newInstance(sfmc.et4ae5__DateSent__c.year(), sfmc.et4ae5__DateSent__c.month(), sfmc.et4ae5__DateSent__c.day());
    return newEmailActivity;
}
}