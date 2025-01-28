public without sharing class FindJobRole {
    @AuraEnabled(cacheable=true)
    public static Boolean Findrole(String rolename) {
        system.debug('rolename'+rolename); 
        List<Job_Role__c> Jr=[SELECT Id,Name, Essential_Tech_Skills__c, Essential_Tools__c, Essential_Administration_Skills__c, Essential_Certifications__c,Salesforce_Clouds__c,Advanced_Tech_Skills__c,Additional_Administration_Skills__c,Advanced_Certifications__c,Verticals__c,Advanced_Tools__c
                              FROM Job_Role__c WHERE Name=:rolename];
        system.debug('Jr'+Jr);                                                         
        if(Jr.size()>0)
        {
            return true;
        }    
        else {
            return false;
        }                                                         
    }
    @AuraEnabled
    public static void updateContactRecord( Position__c jobfields){
        update jobfields;
        
    }
    
    //  @AuraEnabled(cacheable=true)
    // public static string getjdlink( String title){
    //   GoogleDriveIntegrationNew.findFolder(title,'1rltCeE_3cq-9KnXQUA7qVfghHyfA9Yua',getAccessToken());
    //   //String url= [SELECT Id,Name__c,CreationDate__c,DisplayURL,MimeType__c,ExternalId FROM Google_Drive_CVs__x WHERE Name__c=:title].DisplayURL;
    //  // return url;
    //  return 'true';
    
    // }
    // 

    public static Map<String,String> getJdUrlsWithPositions(Set<String> fileNames){
        try{
            return GoogleDriveIntegrationNew.findMultipleFilesInFolderNewMethod(fileNames, '1rltCeE_3cq-9KnXQUA7qVfghHyfA9Yua', getAccessToken());
        } 
        catch (Exception e) {
            if (e.getMessage().contains('401')) { 
                String newToken=GoogleDriveIntegrationNew.refreshAccessToken();
                return GoogleDriveIntegrationNew.findMultipleFilesInFolderNewMethod(fileNames, '1rltCeE_3cq-9KnXQUA7qVfghHyfA9Yua', newToken);
            } else {
                throw new AuraHandledException('err: ' + e.getMessage());
            }
        }
    }
    
    // public static Map<String,String> getJdUrlsWithPositions(Set<String> fileNames){
        
    //     Map<String, String> fileUrlMap = new Map<String, String>();
    //     try{
    //         fileUrlMap = GoogleDriveIntegrationNew.findMultipleFilesInFolderNewMethod(fileNames, '1rltCeE_3cq-9KnXQUA7qVfghHyfA9Yua', getAccessToken());
    //     }
    //     catch (Exception e) {
    //         if (e.getMessage().contains('401')) { 
    //             String newToken = GoogleDriveIntegrationNew.refreshAccessToken();
    //             fileUrlMap = GoogleDriveIntegrationNew.findMultipleFilesInFolderNewMethod(fileNames, '1rltCeE_3cq-9KnXQUA7qVfghHyfA9Yua', newToken);
    //             GoogleDriveTokens__c googleTokenSettings = GoogleDriveTokens__c.getInstance('GoogleTokenRecord');
    //             googleTokenSettings.AccessToken__c = newToken;
    //             update googleTokenSettings;
    //         } else {
    //             throw new AuraHandledException('err: ' + e.getMessage());
    //         }
    //     }
    //     return fileUrlMap;
    // }

    @AuraEnabled(cacheable=true)
    public static String getjdlink(String title) {
        
        List<String> fileNames = new List<String>{'file1.txt', 'file2.docx', 'file3.pdf'};
            try {
                
                String jobDescriptionUrl=GoogleDriveIntegrationNew.findFolder(title, '1-6c7SG2Aku0pNgB35doVGLILyt8FRw_v', getAccessToken());
                
                List<String> foundFileLinks = GoogleDriveIntegrationNew.findMultipleFilesInFolder(fileNames, '1-6c7SG2Aku0pNgB35doVGLILyt8FRw_v', getAccessToken());
                for (String fileLink : foundFileLinks) {
                    System.debug('Found File Link: ' + fileLink);
                }
                
                System.debug('The final JD URL is' + jobDescriptionUrl);
                return jobDescriptionUrl;
            } catch (Exception e) {
                if (e.getMessage().contains('401')) { 
                    String newToken=GoogleDriveIntegrationNew.refreshAccessToken();
                    
                    List<String> foundFileLinks = GoogleDriveIntegrationNew.findMultipleFilesInFolder(fileNames, '1-6c7SG2Aku0pNgB35doVGLILyt8FRw_v', newToken);
                    for (String fileLink : foundFileLinks) {
                        System.debug('Found File Link: ' + fileLink);
                    }
                    
                    String jobDescriptionUrl=GoogleDriveIntegrationNew.findFolder(title, '1-6c7SG2Aku0pNgB35doVGLILyt8FRw_v', newToken);
                    System.debug('The final JD URL is' + jobDescriptionUrl);
                    return jobDescriptionUrl;
                } else {
                    throw new AuraHandledException('err: ' + e.getMessage());
                }
            }
    }
    
    private static String getAccessToken() {
        GoogleDriveTokens__c googleTokenSettings = GoogleDriveTokens__c.getInstance('GoogleTokenRecord');
        return googleTokenSettings.AccessToken__c;
    }
    
    
    @AuraEnabled
    public static void sendApproval(String recordId,Id manager) {
        // Position__c p=[SELECT Id,Hiring_Manager__c from Position__c where id=:recordId];
        if(manager!=null)
        {
            Position__c p = new Position__c();
            p.id=recordId;
            p.Hiring_Manager__c=manager;
            update p;
        }
        //system.debug('p.Hiring_Manager__c'+p.Hiring_Manager__c);
        Approval.ProcessSubmitRequest req1 = 
            new Approval.ProcessSubmitRequest();
        String loggedUserId = UserInfo.getUserId();
        req1.setComments('Submitting request for approval.');
        req1.setObjectId(recordId);
        req1.setSubmitterId(loggedUserId); 
        req1.setProcessDefinitionNameOrId('RR_Approval_process_Testing');
        req1.setSkipEntryCriteria(true);
        try{
            Approval.ProcessResult result = Approval.process(req1);
        }
        catch(Exception e)
        {
            system.debug('e.getMessage()'+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}