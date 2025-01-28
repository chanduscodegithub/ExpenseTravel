global class Covid19AssessmentReminder implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'select Name,Employee_Id__c,Email__c,User__r.Id, Last_Covid_Assessment_Date__c from Service_Resource__c where Covid_19_Safe__c=true AND Last_Covid_Assessment_Date__c != today AND Email__c!=null AND Active__c=true ORDER BY Employee_Id__c ASC';
        //String query = 'select Name,Email__c,User__r.Id, Last_Covid_Assessment_Date__c from Service_Resource__c where Last_Covid_Assessment_Date__c != today AND Email__c!=null AND Active__c=true AND (Employee_Id__c=\'C0472\' OR Employee_Id__c=\'C0584\' OR Employee_Id__c=\'C0518\' OR Employee_Id__c=\'C0107\' OR Employee_Id__c=\'CI002\' OR Employee_Id__c=\'C0295\'  OR Employee_Id__c=\'C0003\'  OR Employee_Id__c=\'C0297\'  OR Employee_Id__c=\'C0529\'  OR Employee_Id__c=\'C0490\' OR Employee_Id__c=\'C0260\' OR Employee_Id__c=\'C0024\')';
        return Database.getQueryLocator(query);	
    }
    
    global void execute(Database.BatchableContext BC, List<Service_Resource__c> scope)
    {   
        //Boolean isUpdate = false;
        //EmailTemplate emailTemplate1 = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName = 'Covid_19_self_assesment_reminder'];
        //EmailTemplate emailTemplate2 = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName = 'Covid_19_self_assesment'];
        EmailTemplate nonSFUsersEmailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName = 'Covid_19_Assessment_Page_Non_SF_Users_Apex_Batch'];
        EmailTemplate nonSFUsersEmailTemplate1 = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName = 'Covid_19_Assesment_reminder_for_Non_SF_Users_Apex_Batch'];
        
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
            //owa = [select id, Address, DisplayName from OrgWideEmailAddress where Address='sales4crmit@gmail.com' OR Address='noreply-recruitment@crmit.com' OR Address='noreply@crmit.com'];
            owa = [select id, Address, DisplayName from OrgWideEmailAddress where Address='noreply@crmit.com'];
            system.debug('owa - '+owa);
        }
        catch(Exception e){ 
            owa = null;
            System.debug('OWA Empty - '+e.getMessage());
        }
        Integer count = 0;
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for(Service_Resource__c sr : (List<Service_Resource__c>)scope) {
            //count++;
            System.debug('Each Service Resource - '+sr.Name+' - '+sr.Employee_Id__c);
            //String htmlsubject1 = emailTemplate1.Subject;
            //String htmlsubject2 = emailTemplate2.Subject;
            //String htmlbody1 = emailTemplate1.HtmlValue;
            //String htmlbody2 = emailTemplate2.HtmlValue;
            
            String htmlsubject1NonSFUsers = nonSFUsersEmailTemplate.Subject;
            String htmlsubject2NonSFUsers = nonSFUsersEmailTemplate1.Subject;
            String htmlbody1NonSFUsers = nonSFUsersEmailTemplate.HtmlValue;
            String htmlbody2NonSFUsers = nonSFUsersEmailTemplate1.HtmlValue;

            if(sr.Last_Covid_Assessment_Date__c==null || sr.Last_Covid_Assessment_Date__c.Date() == date.today().addDays(-1)){
                /*if(sr.SF_User__c == true){
system.debug('sr.Last_Covid_Assessment_Date__c '+sr.Last_Covid_Assessment_Date__c);
htmlbody2 = htmlbody2.replace('{!Service_Resource__r.Name}', sr.Name);
htmlbody2 = htmlbody2.replace('{!Service_Resource__r.Id}', sr.Id);
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
if(owa!=null){
                    email.setOrgWideEmailAddressId(owa.Id);
                }
                else{
                    email.setSenderDisplayName('NoReply-ActNow');
                }
email.setSubject(htmlsubject2);
email.setToAddresses(new String[] {sr.Email__c});
email.setSaveAsActivity(false);
email.setHtmlBody(htmlbody2);
//email.setTargetObjectId(sr.User__r.Id);
email.setTemplateId(emailTemplate2.Id);
mails.add(email);
system.debug('sr.Last_Covid_Assessment_Date__c '+sr.Last_Covid_Assessment_Date__c);
}
else{*/
                htmlbody1NonSFUsers = htmlbody1NonSFUsers.replace('{!Service_Resource__r.Name}', sr.Name);
                htmlbody1NonSFUsers = htmlbody1NonSFUsers.replace('{!todaysDate}', todayDateString);
                htmlsubject1NonSFUsers = htmlsubject1NonSFUsers.replace('{!todaysDate}', todayDateString);
                //htmlbody1NonSFUsers = htmlbody1NonSFUsers.replace('{!Service_Resource__r.Id}', sr.Id);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(owa.size()>0){
                    //if(count<41){
                       email.setOrgWideEmailAddressId(owa[0].Id); 
                    /*}
                    else if(count<85){
                        email.setOrgWideEmailAddressId(owa[1].Id); 
                    }
                    else{
                        email.setOrgWideEmailAddressId(owa[2].Id); 
                    }*/
                    
                }
                else{
                    email.setSenderDisplayName('NoReply-ActNow');
                }
                
                email.setSubject(htmlsubject1NonSFUsers);
                email.setToAddresses(new String[] {sr.Email__c});
                email.setSaveAsActivity(false);
                email.setHtmlBody(htmlbody1NonSFUsers);
                //email.setTargetObjectId(sr.User__r.Id);
                email.setTemplateId(nonSFUsersEmailTemplate.Id);
                mails.add(email);
                //}
            }else /*if(sr.Last_Covid_Assessment_Date__c.Date() == date.today().addDays(-2))*/{
                /*if(sr.SF_User__c == true){
system.debug('sr.Last_Covid_Assessment_Date__c '+sr.Last_Covid_Assessment_Date__c);
htmlbody1 = htmlbody1.replace('{!Service_Resource__r.Name}', sr.Name);
Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
if(owa!=null){
                    email.setOrgWideEmailAddressId(owa.Id);
                }
                else{
                    email.setSenderDisplayName('NoReply-ActNow');
                }
email.setSubject(htmlsubject1);
email.setToAddresses(new String[] {sr.Email__c});
email.setHtmlBody(htmlbody1);
email.setSaveAsActivity(false);
//email.setTargetObjectId(sr.User__r.Id);
email.setTemplateId(emailTemplate1.Id);
mails.add(email);
}
else{*/
                htmlbody2NonSFUsers = htmlbody2NonSFUsers.replace('{!Service_Resource__r.Name}', sr.Name);
                htmlbody2NonSFUsers = htmlbody2NonSFUsers.replace('{!todaysDate}', todayDateString);
                htmlsubject2NonSFUsers = htmlsubject2NonSFUsers.replace('{!todaysDate}', todayDateString);
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(owa.size()>0){
                    //if(count<41){
                       email.setOrgWideEmailAddressId(owa[0].Id); 
                    /*}
                    else if(count<85){
                        email.setOrgWideEmailAddressId(owa[1].Id); 
                    }
                    else{
                        email.setOrgWideEmailAddressId(owa[2].Id); 
                    }*/
                    
                }
                else{
                    email.setSenderDisplayName('NoReply-ActNow');
                }
                email.setSubject(htmlsubject2NonSFUsers);
                email.setToAddresses(new String[] {sr.Email__c});
                email.setHtmlBody(htmlbody2NonSFUsers);
                email.setSaveAsActivity(false);
                //email.setTargetObjectId(sr.User__r.Id);
                email.setTemplateId(nonSFUsersEmailTemplate1.Id);
                mails.add(email);
                //}
            }
            /*else{
isUpdate = true;
system.debug('sr.Last_Covid_Assessment_Date__c '+sr.Last_Covid_Assessment_Date__c);
sr.Active__c = false;

}*/
        }
        if(mails.size()>0){
            Messaging.sendEmail(mails);
        }
        /*if(isUpdate){
update scope;
}*/
    } 
    
    global void finish(Database.BatchableContext BC){
        
    }
}