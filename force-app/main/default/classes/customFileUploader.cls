public class customFileUploader{
    
    //folderId : 1ju21jRwr66cwgi_sku3oE7Oblqhslq5s
    //dependent class : GoogleDriveIntegrationNew line number 680
    private final static String folderId = '1ju21jRwr66cwgi_sku3oE7Oblqhslq5s';
    //private final static String folderId = '1tUWCdaAASOB9ERMd0IvfZXXUvHrcCL';
    //
    public class MyCustomException extends Exception {}
    
    @AuraEnabled(cacheable=true)
    public static Project__c getProjectDetails(String recordId){
        List<Project__c> cusEngagement= [Select Id,StartDate__c,EndDate__c from Project__c where Opportunity__c =: recordId order by createdDate desc limit 1];
        
        if(cusEngagement.size() == 0){
            throw new MyCustomException('No customer engagement found for selected opportunity');
        }else{
            return cusEngagement[0];
        }
    }
    
    @AuraEnabled
    public static String createTalentLoading(String talentLoadObj,String talendLoadChildWrap,String base64, String filename){
        try{
            List<Talent_Loading__c> talentLoading = (List<Talent_Loading__c>) JSON.deserialize(talentLoadObj, List<Talent_Loading__c>.class);
            
            List<wrapTalendLoadChild> talendLoadChild = (List<wrapTalendLoadChild>) JSON.deserialize(talendLoadChildWrap, List<wrapTalendLoadChild>.class);
            
            if(talentLoading.size() > 0 ){
                insert talentLoading;
                
                Map<String,Talent_Loading__c> talentLoadingMapped = new Map<String,Talent_Loading__c>();
                
                for(Talent_Loading__c loading : talentLoading){
                    talentLoadingMapped.put(loading.Role__c,loading);
                } 
                
                List<Talent_Loading_Line__c> childList = new List<Talent_Loading_Line__c>();
                
                for(wrapTalendLoadChild talentChild : talendLoadChild){
                    Talent_Loading_Line__c childElement = new Talent_Loading_Line__c();
                    childElement.Talent_Loading__c = talentLoadingMapped.get(talentChild.Role).Id; 
                    childElement.Month__c = talentChild.Month;
                    childElement.Hour__c = Decimal.valueOf(talentChild.Hour);
                    childList.add(childElement);
                }
                
                if(childList.size() > 0 ){
                    insert childList;
                    return 'success';
                }
            }
            return null;
        }catch(Exception exp){
            throw new AuraHandledException(exp.getMessage());
        }        
    }
    
    public static String uploadFile(String base64, String filename) {
        try{
            //System.debug('filename'+filename);
            String accessToken = GoogleDriveIntegrationNew.getAccessToken();
            //System.debug('accessToken:::'+accessToken);
            
            GoogleDriveIntegrationNew.GoogleDriveFile fileDetails = GoogleDriveIntegrationNew.uploadFile(filename, base64, folderId, accessToken);
            //System.debug('fileDetails:::'+fileDetails);
            
            return fileDetails.fileUrl;
        }
        catch(Exception e){
            
            
            if (e.getMessage().contains('401')) { 
                String accessToken=GoogleDriveIntegrationNew.refreshAccessToken();
                GoogleDriveIntegrationNew.GoogleDriveFile fileDetails = GoogleDriveIntegrationNew.uploadFile(filename, base64, folderId, accessToken);
                //System.debug('fileDetails:::'+fileDetails);
                
                return fileDetails.fileUrl;
                
            }else{
                //System.debug('exp:::'+e);
                return e.getMessage();
            }
        }
        
    }
    
    public class wrapTalendLoadChild{ 
        @AuraEnabled
        public String Role;
        @AuraEnabled
        public String Month;
        @AuraEnabled
        public String Hour;
    }
}