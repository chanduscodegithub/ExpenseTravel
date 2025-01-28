public class ListenerHelper {
    public class ErrorResp{
        public String message;
        public Integer lineNo;
        public ErrorResp(String message, Integer lineNo){
            this.message = message;
            this.lineNo = lineNo;
        }
    }
    public class MessageResp{
        public String message;
        public String recID;
        public MessageResp(String message, String recID){
            this.message = message;
            this.recID = recID;
        }
    }
    public static String buildResponse(Boolean isError, String prop1, String prop2){
        if(isError){
            ErrorResp errObj = new ErrorResp(prop1, Integer.valueOf(prop2));
            return JSON.serialize(errObj);
        }else{
            MessageResp msgObj = new MessageResp(prop1, prop2);
            return JSON.serialize(msgObj);
        }
    }
    @future
    public static void sendEmail(String name, String email, Id recId){
        OrgWideEmailAddress orgWideEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address='salesplusplus@crmit.com' WITH SYSTEM_MODE LIMIT 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {email});
        mail.setSubject('You have been assigned to a Prospect meeting.');
        //mail.setSenderDisplayName(orgWideEmail.DisplayName);
        String body = 'Hello ' + name + ',\n\n';
        if(recId.getSObjectType() == Schema.Lead.SObjectType){
            Lead lead = [SELECT Name, Email FROM Lead WHERE Id = :recId];
            body = body + lead.Name+' has expressed interest in asvp and wants to have a call.\n\n';
            body += 'More details on the Prospect below:\n';
            body += 'Name: ' + lead.Name + '\n';
            body += 'Email: ' + lead.Email + '\n';
            body += 'You can view the Lead record by clicking on this link:\n';
            String leadUrl = URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Lead/' + recId + '/view';
            body += '[Lead Record] '+leadUrl;
        }else if(recId.getSObjectType() == Schema.Contact.SObjectType){
            Contact con = [SELECT Name, Email FROM Contact WHERE Id = :recId];
            body = body + con.Name+' has expressed interest in asvp and wants to have a call.\n\n';
            body += 'More details on the Prospect below:\n';
            body += 'Name: ' + con.Name + '\n';
            body += 'Email: ' + con.Email + '\n';
            body += 'You can view the Contact record by clicking on this link:\n';
            String conUrl = URL.getOrgDomainUrl().toExternalForm() + '/lightning/r/Contact/' + recId + '/view';
            body += '[Contact Record] '+conUrl;
        }
        body += '\n\nPlease contact the prospect and update the status of the call.\n\n';
        body += 'Thank you for your cooperation.\n\n';
        body += 'Sincerely,\n';
        body += 'Sales++\n';
        body += 'This is an auto-generated email. Please do not reply.';
        mail.setOrgWideEmailAddressId(orgWideEmail.Id);
        mail.setPlainTextBody(body);
        if(!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    @future
    public static void sendLeadEmail(Id recId){
        Lead lead = [SELECT Name, Email, Company, Country, Company_Name__c, LeadSource, Source_URL__c FROM Lead WHERE Id = :recId];
        EmailTemplate leadEnquiryTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = 'Lead_Enquiry'];
        OrgWideEmailAddress orgWideEmail = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address='salesplusplus@crmit.com' WITH SYSTEM_MODE LIMIT 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'marketing@crmit.com','dinesh.poduval@crmit.com','salesplusplus@crmit.com','greg.lombard@crmit.com','umamaheshwar.koneru@crmit.com','kaniti.prasanth@crmit.com'});
        mail.setOrgWideEmailAddressId(orgWideEmail.Id);
        mail.setTemplateId(leadEnquiryTemplate.Id);
        mail.setTargetObjectId(lead.Id);
        if(!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
}