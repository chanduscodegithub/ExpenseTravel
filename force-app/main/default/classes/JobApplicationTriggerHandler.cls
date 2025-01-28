public without sharing class JobApplicationTriggerHandler {
    static final Resume_Insights__c credentials = Resume_Insights__c.getInstance();
    
    /**This method used to update Job Application with resume details
      * @param {Map<String,Id>} mapResumeJobapp - Map of Candidate email and associated job application Id.
      * @author Manoj
      * @since Feb 01 2024
      */
    @future(callout=true)
    public static void updateJobApplication(Map<String,Id> mapResumeJobapp)
    {
        List<Job_Application__c> updateJobApp=new List<Job_Application__c>();
        List<Google_Drive_CVs__x> googleDriveCvs=new List<Google_Drive_CVs__x>();
        googleDriveCvs=[SELECT Id,Name__c,CreationDate__c,DisplayURL FROM Google_Drive_CVs__x WHERE Name__c LIKE :mapResumeJobapp.keySet() ORDER BY CreationDate__c DESC];
        Boolean found=false;
        Set<Id> resumeNotFoundJobapp=new Set<Id>();
        for(String email:mapResumeJobapp.keySet())
        {
            found=false;
            for(Google_Drive_CVs__x gDriveCv : googleDriveCvs)
            {
                if(gDriveCv.Name__c.startsWith(email.removeEnd('%')))
                {
                    Job_Application__c jobApp=new Job_Application__c();
                    jobApp.Id=mapResumeJobapp.get(email);
                    jobApp.GDrive_Resume__c=gDriveCv.Id;
                    jobApp.GDrive_Resume_URL__c=gDriveCv.DisplayURL;
                    updateJobApp.add(jobApp);
                    found=true;
                    break;
                }
            }
            if(!found)
            {
                Job_Application__c jobApp=new Job_Application__c();
                jobApp.Id=mapResumeJobapp.get(email);
                jobApp.Resume_Uploaded_to_G_Drive__c=false;
                jobApp.GDrive_Resume__c=null;
                jobApp.GDrive_Resume_URL__c=null;
                updateJobApp.add(jobApp);
                resumeNotFoundJobapp.add(mapResumeJobapp.get(email));   
            }
        }
        if(updateJobApp!=null && updateJobApp.size()>0)
            update updateJobApp;
        if(resumeNotFoundJobapp!=null && resumeNotFoundJobapp.size()>0)
            errorEmail(resumeNotFoundJobapp);
    }
    
    /**This method used to reset resume details in Job Application.
      * @param {Set<Id>} resetJobAp - Set of Job Application Ids to reset.
      * @author Manoj
      * @since Feb 01 2024
      */
    public static void resetJobApplication(Set<Id> resetJobApp)
    {
        delete [SELECT Body FROM Attachment WHERE parentId IN :resetJobApp AND Name LIKE 'PlainText_%' ORDER by Createddate DESC];
        List<Job_Application__c> jobAppList=new List<Job_Application__c>();
        for(Id jobAppId : resetJobApp)
        {
            Job_Application__c jobApp=new Job_Application__c();
            jobApp.Id=jobAppId;
            jobApp.Resume_Uploaded_to_G_Drive__c=false;
            jobApp.GDrive_Resume__c=null;
            jobApp.GDrive_Resume_URL__c='';
            jobAppList.add(jobApp);
        }
        if(jobAppList!=null && jobAppList.size()>0)
        {
            update jobAppList;
        }
    }
	
    /**This method used to send resume not found email.
      * @param {Set<Id>} jobApplicationRecordIds - The set of record ids of the job application.
      * @author Manoj
      * @since Feb 01 2024
      */
    public static void errorEmail(Set<Id> jobApplicationRecordIds)
    {
        Messaging.SingleEmailMessage[] mailList=new Messaging.SingleEmailMessage[]{};  
        for(Job_Application__c jobApp : [SELECT Id,Candidate__r.First_Name__c,Candidate__r.Last_Name__c FROM Job_Application__c WHERE Id IN :jobApplicationRecordIds])
        {
            String jobApplicationInsightUrl=credentials.CRMIT_Community_Base_URL__c+'/CRMITCommunity/s/job-application/'+jobApp.Id;
            String htmlBody='<p>Hi '+UserInfo.getFirstName()+' '+UserInfo.getLastName()+',</p>'+
                            '<p>Resume not found in google drive for <a href="'+jobApplicationInsightUrl+'">'+jobApp.Candidate__r.First_Name__c+' '+jobApp.Candidate__r.Last_Name__c+'</a>.</p>'+
                            '<p>Thanks</p>';  
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Resume not found in Google Drive');
            mail.setHtmlBody(htmlBody);
            mail.setSaveAsActivity(false);
            mail.setToAddresses(new list<string>{UserInfo.getUserEmail()});
            mail.setCcAddresses(new list<string>{'manoj.mahadevaswamy@crmit.com'});
            mail.setUseSignature(false);
            mailList.add(mail); 
        }  
        Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(mailList); 
    }
    Public static void updateinterviews(set<Id>Ids)
    {
        List<Position__c> updateTotalInterviews= new List<Position__c>();
        List<AggregateResult> agg = [select Position__c,Sum(Number_of_Interviews__c)amt from Job_Application__c where Position__c in:Ids group by Position__c];
        for(AggregateResult a:agg)
        {
            Position__c p = new Position__c();
            p.Id=(id)a.get('Position__c');
            p.Total_No_Of_Interviews__c=(decimal)a.get('amt'); 
            updateTotalInterviews.add(p);
        }
        update updateTotalInterviews;
    }

}