public class GoogleDriveBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    List<id> contentDocs = new List<id>();
    public static GoogleDriveTokens__c googleToken = GoogleDriveTokens__c.getInstance('GoogleTokenRecord');
    public Database.QueryLocator start(Database.BatchableContext context) {
    DateTime dT = System.now();
     System.debug('Today Date'+dT);
    //Date d = Date.newInstance(dT.year(), dT.month(), dT.day());
    Integer days = (Integer)googleToken.Days__c;
    DateTime purgeDate = dT.addDays(-days); // 3 months ago
    System.debug('Purging all TSA files before ' + purgeDate);

    Set<Id> TSAIds = new Set<Id>();
    for (Timesheet_Approval__c tsa : [SELECT Id FROM Timesheet_Approval__c WHERE CreatedDate <= :purgeDate]) {
        TSAIds.add(tsa.Id);
    }
    System.debug('TSA Ids to delete files: ' + TSAIds);

    return Database.getQueryLocator([SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN :TSAIds]);
}


    
    public void execute(Database.BatchableContext context, List<sObject> scope) {
        
        //Uploading Files to Drive
        for (sObject record : scope) {
            ContentDocumentLink link = (ContentDocumentLink)record;
            System.debug('Link:'+link);
            googleDriveIntegration.uploadFileS(link.ContentDocumentId);
            contentDocs.add(link.ContentDocumentId);
        }
        
        //Deletion from SF
        List<ContentDocument> ConDocList =[SELECT Id FROM ContentDocument where Id IN: contentDocs];
        delete ConDocList; 
        
        
        
    }    
        
    
    public void finish(Database.BatchableContext context) {
        // Optionally, add any cleanup or post-processing logic here
       
    } 
}