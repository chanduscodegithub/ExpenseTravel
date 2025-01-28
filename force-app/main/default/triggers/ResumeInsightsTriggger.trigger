/*------------------------------------------------------------
Author       :  Manoj R M
Company      :  CRMIT Pvt. Ltd.
Description  :  This trigger is used to update job application with resume details.
Inputs       :  Mentioned before each methods.
Test Class   :  _

History
<Date>         <Authors Name>        <Brief Description of Change>
------------------------------------------------------------------*/
trigger ResumeInsightsTriggger on Job_Application__c (after insert,after update) {
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        Map<String,Id> mapResumeJobapp=new Map<String,Id>();
        Set<Id> candidateChangedJobApp=new Set<Id>();
        for(Job_Application__c jobApp : Trigger.New)
        {
            Job_Application__c oldJobApp=Trigger.oldMap.get(jobApp.Id);
            if(jobApp.Resume_Uploaded_To_G_Drive__c!=oldJobApp.Resume_Uploaded_To_G_Drive__c && jobApp.Resume_Uploaded_To_G_Drive__c==true)
            {
                if(jobApp.Candidate_Email_Formula__c=='')
                {
                    jobApp.addError('Please update email in candidate record.');
                    continue;
                }
                String candidateEmail=jobApp.Candidate_Email_Formula__c+'%';
            	mapResumeJobapp.put(candidateEmail,jobApp.Id);
            }
            if(jobApp.Candidate__c!=oldJobApp.Candidate__c || (jobApp.Resume_Uploaded_To_G_Drive__c!=oldJobApp.Resume_Uploaded_To_G_Drive__c && jobApp.Resume_Uploaded_To_G_Drive__c==false))
            {
				candidateChangedJobApp.add(jobApp.Id);
            }
            
        }
        Set<Id> resetJobApp=new Set<Id>(candidateChangedJobApp);
        resetJobApp.removeAll(mapResumeJobapp.values());
        if(mapResumeJobapp.size()>0)
        {
            JobApplicationTriggerHandler.updateJobApplication(mapResumeJobapp);
        } 
        
        if(candidateChangedJobApp.size()>0)
        { 
            for(Job_Application_Analysis__c jobAppAna : [SELECT Id,Job_Application__c FROM Job_Application_Analysis__c WHERE Job_Application__c IN :candidateChangedJobApp])
            {
                resetJobApp.remove(jobAppAna.Job_Application__c);
                Trigger.newMap.get(jobAppAna.Job_Application__c).addError('Resume already analyzed. You can\'t change candidate or uncheck Resume Uploaded to GDrive');
            }
            JobApplicationTriggerHandler.resetJobApplication(resetJobApp);
		}
        
    }
    if(Trigger.isAfter && Trigger.isInsert)
    {
        Map<String,Id> mapResumeJobapp=new Map<String,Id>();
        for(Job_Application__c jobApp : Trigger.New)
        {
            if(jobApp.Resume_Uploaded_To_G_Drive__c==true)
            {
                if(jobApp.Candidate_Email_Formula__c=='')
                {
                    jobApp.addError('Please update email in candidate record.');
                    continue;
                }
                String candidateEmail=jobApp.Candidate_Email_Formula__c+'%';
            	mapResumeJobapp.put(candidateEmail,jobApp.Id);
            }
            
        }
        if(mapResumeJobapp.size()>0)
        {
            JobApplicationTriggerHandler.updateJobApplication(mapResumeJobapp);
        }  
    }

}