global class Covid19AssessmentReminderCRMITRem implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'select Name,Employee_Id__c,Email__c,User__r.Id, Last_Covid_Assessment_Date__c from Service_Resource__c where Covid_19_Safe__c=true AND Last_Covid_Assessment_Date__c != today AND Email__c!=null AND Active__c=true ORDER BY Employee_Id__c ASC';
        //String query = 'select Name,Email__c,User__r.Id, Last_Covid_Assessment_Date__c from Service_Resource__c where Last_Covid_Assessment_Date__c != today AND Email__c!=null AND Active__c=true AND (Employee_Id__c=\'C0472\' OR Employee_Id__c=\'C0584\' OR Employee_Id__c=\'C0518\' OR Employee_Id__c=\'C0107\' OR Employee_Id__c=\'CI002\' OR Employee_Id__c=\'C0295\'  OR Employee_Id__c=\'C0003\'  OR Employee_Id__c=\'C0297\'  OR Employee_Id__c=\'C0529\'  OR Employee_Id__c=\'C0490\' OR Employee_Id__c=\'C0260\' OR Employee_Id__c=\'C0024\')';
        return Database.getQueryLocator(query);	
    }
    
    global void execute(Database.BatchableContext BC, List<Service_Resource__c> scope)
    {   
        EmailTemplate nonSFUsersEmailTemplate1 = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName = 'Covid_19_Assesment_reminder_for_Non_SF_Users_Apex_Batch_CRMIT'];
        
        System.debug('Service Resources Size - '+scope.size());
        
        Map<Integer,String> dateMonth = new Map<Integer,String>();
        dateMonth.put(1, 'Jan');
        dateMonth.put(2, 'Feb');
        dateMonth.put(3, 'Mar');
        dateMonth.put(4, 'Apr');
        dateMonth.put(5, 'May');
        dateMonth.put(6, 'Jun');
        dateMonth.put(7, 'Jul');
        dateMonth.put(8, 'Aug');
        dateMonth.put(9, 'Sep');
        dateMonth.put(10, 'Oct');
        dateMonth.put(11, 'Nov');
        dateMonth.put(12, 'Dec');
        Date todaysDate = Date.today();
        String todayDateString = dateMonth.get(todaysDate.month())+' '+todaysDate.day()+', '+todaysDate.year();
        System.debug('todayDateString - '+todayDateString);
        
        
        List<OrgWideEmailAddress> owa = new List<OrgWideEmailAddress>();
        try{
            owa = [select id, Address, DisplayName from OrgWideEmailAddress where Address='noreply@crmit.com'];
            system.debug('owa - '+owa);
        }
        catch(Exception e){ 
            owa = null;
            System.debug('OWA Empty - '+e.getMessage());
        }
        Integer count = 0;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        String htmlsubject2NonSFUsers = nonSFUsersEmailTemplate1.Subject;
        String htmlbody2NonSFUsers = nonSFUsersEmailTemplate1.HtmlValue;
        
        htmlbody2NonSFUsers = htmlbody2NonSFUsers.replace('{!todaysDate}', todayDateString);
        htmlsubject2NonSFUsers = htmlsubject2NonSFUsers.replace('{!todaysDate}', todayDateString);
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        if(owa.size()>0){
            email.setOrgWideEmailAddressId(owa[0].Id); 
        }
        else{
            email.setSenderDisplayName('NoReply-ActNow');
        }
        email.setSubject(htmlsubject2NonSFUsers);
        email.setToAddresses(new String[] {'crmitteam@crmit.com'});
        email.setHtmlBody(htmlbody2NonSFUsers);
        email.setSaveAsActivity(false);
        email.setTemplateId(nonSFUsersEmailTemplate1.Id);
        mails.add(email);
        if(mails.size()>0){
            Messaging.sendEmail(mails);
        }
    } 
    
    global void finish(Database.BatchableContext BC){
        
    }
}