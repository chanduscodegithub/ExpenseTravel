public without sharing class ResourceRequisitionTriggerHandler {
    
    public static void autoPopulateSkills(Map<string,Position__c> updateResourceReq) {
        Map<Id,Job_Role__c> jobRoleMap = new Map<Id,Job_Role__c>([SELECT Id,Name, Essential_Tech_Skills__c, Essential_Tools__c, Essential_Administration_Skills__c, Essential_Certifications__c,Salesforce_Clouds__c,Advanced_Tech_Skills__c,Additional_Administration_Skills__c,Advanced_Certifications__c,Verticals__c,Advanced_Tools__c
                                                                  FROM Job_Role__c WHERE Name IN :updateResourceReq.keyset()]);
        Map<String,Position_title__mdt> Pt= new  Map<String,Position_title__mdt>();
        List<Position_title__mdt> listEmailDomain = [select Id, Name__c, Level__c,Band__c from Position_title__mdt where Name__c IN :updateResourceReq.keyset()];
        for(Position_title__mdt t:listEmailDomain)
        {
            Pt.put(t.Name__c,t); 
        }
        Map<String,Job_Role__c> jobRoles = new Map<String,Job_Role__c>();
        for (Job_Role__c req : jobRoleMap.Values()) {
            jobRoles.put(req.Name,req);
        }
        
        for (Position__c req : updateResourceReq.Values()) {
            if(Pt.containsKey(req.Position_Title__c))
            {
                req.Corporate_Grade_Level__c=Pt.get(req.Position_Title__c).Level__c;
                req.Corporate_Grade_Band__c=Pt.get(req.Position_Title__c).Band__c;
            }
            else
            {
                req.Corporate_Grade_Level__c=null;
                req.Corporate_Grade_Band__c=null; 
            }
            if (jobRoles.containsKey(req.Position_Title__c)) {
                Job_Role__c matchingJobRole = jobRoles.get(req.Position_Title__c);
                req.Job_Role__c=matchingJobRole.Id;
                req.Esse__c = matchingJobRole.Essential_Tech_Skills__c;
                req.Essential_Tools__c = matchingJobRole.Essential_Tools__c;
                req.Essential_Administration_Skills__c = matchingJobRole.Essential_Administration_Skills__c;
                req.Essential_Certifications__c = matchingJobRole.Essential_Certifications__c;
                req.SF_Clouds__c=matchingJobRole.Salesforce_Clouds__c;
                req.Additional_Tech_Skills__c= matchingJobRole.Advanced_Tech_Skills__c;
                req.Additional_Administration_Skills__c=matchingJobRole.Additional_Administration_Skills__c;
                req.Additional_Certifications__c=matchingJobRole.Advanced_Certifications__c; 
                req.Additional_Tools__c=matchingJobRole.Advanced_Tools__c;
                req.Verticals__c=matchingJobRole.Verticals__c;
                
            }
            else
            {
                req.Job_Role__c=null;
                req.Esse__c = null;
                req.Essential_Tools__c = null;
                req.Essential_Administration_Skills__c = null;
                req.Essential_Certifications__c = null;
                req.SF_Clouds__c=null;
                req.Additional_Tech_Skills__c= null;
                req.Additional_Administration_Skills__c=null;
                req.Additional_Certifications__c=null;
                req.Additional_Tools__c=null;
                req.Verticals__c=null;
            }
        }
        
        
    }
    
    @future(callout=true)
    public static void populateJdLink(String jsonString) {
        
        system.debug('jsonString'+jsonString);
        set<Id> ids= new set<Id>();
        Set<String> fileIds = new Set<String>();
        
        //List<Position__c> UpdateJdLink = new List<Position__c>();
        Map<String,Position__c> accountList = (Map<String,Position__c>)Json.deserialize(jsonString,Map<String,Position__c>.class);
        List<Position__c> updatejd= new  List<Position__c>(); 
        //List<Attachment> Attfiles= new  List<Attachment>();
        //Map<String,Position__c> updateJdLink = new Map<String,Position__c>(); 
        //List<Google_Drive_CVs__x> googleDriveJds=new List<Google_Drive_CVs__x>();
        //Map<String,Google_Drive_CVs__x> googleDriveJdsMap= new Map<String,Google_Drive_CVs__x>();
        //googleDriveJds=[SELECT Id,Name__c,CreationDate__c,DisplayURL,MimeType__c,ExternalId FROM Google_Drive_CVs__x WHERE Name__c IN :accountList.keySet()];
        //system.debug('googleDriveJds'+googleDriveJds);
        
        /*for(Google_Drive_CVs__x Jd :googleDriveJds)
{ 
googleDriveJdsMap.put(Jd.Name__c,Jd );
}*/
        Set<String>positionNames = new Set<String>();
        for(String ps:accountList.keySet())
        {
            positionNames.add(ps);
            /*Position__c p = new Position__c();
            
            String url = FindJobRole.getjdlink(ps);
            //system.debug('googleDriveJds'+googleDriveJdsMap.get(ps).DisplayURL);
            p.Id= accountList.get(ps).Id;
            p.JD_Link__c=url;
            //p.JD_Link__c=googleDriveJdsMap.get(ps).DisplayURL;
            updatejd.add(p);*/   
        }
        Map<String,String>getPositionUrlsWithNames = FindJobRole.getJdUrlsWithPositions(positionNames);
        for(String positionTitle : getPositionUrlsWithNames.keySet()){
            Position__c position = accountList.get(positionTitle);
            position.JD_Link__c = getPositionUrlsWithNames.get(positionTitle);
            updatejd.add(position);
        }
        if(updatejd.size()>0)
        {
            try{
                update updatejd;
            }
            catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
            }
            
        } 
        
        
    }
}