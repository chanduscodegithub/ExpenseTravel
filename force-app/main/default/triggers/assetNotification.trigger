trigger assetNotification on Position__c (before update) {
    List<Position__c> changedRecords = new List<Position__c>();
    Map<Id, Position__c> changedOldMap = new Map<Id, Position__c>();

    for (Position__c jobApp : Trigger.new) {
        Boolean newValue = jobApp.Assets_Provided__c;
        Boolean oldValue = Trigger.oldMap.get(jobApp.Id).Assets_Provided__c;

        System.debug('Record Id: ' + jobApp.Id + ' | New Value: ' + newValue + ' | Old Value: ' + oldValue);

        if (newValue && !oldValue) {
            System.debug('Field changed from false to true for Id: ' + jobApp.Id);
            changedRecords.add(jobApp);
            changedOldMap.put(jobApp.Id, Trigger.oldMap.get(jobApp.Id));
        }
    }

    if (!changedRecords.isEmpty()) {
        assetEmailTriggerHandler.sendEmails(changedRecords, changedOldMap);
    }
}