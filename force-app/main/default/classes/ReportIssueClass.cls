public without sharing class ReportIssueClass {
    @AuraEnabled
    public static String createIssue(String s,String base64, String filename){
        Reported_Issue__c ri=new Reported_Issue__c(Description__c=s,User__c=UserInfo.getUserId(),Application_Name__c='Timesheet',Status__c='New');
        System.debug('Before Insert -- >'+ri);
        insert ri;
        NoteAndAttachment na=new NoteAndAttachment();
        if(base64!='' && filename!=null){
          ContentVersion cv = createContentVersion(base64, filename);
        ContentDocumentLink cdl = createContentLink(cv.Id, ri.id);
        }
        List<OrgWideEmailAddress> owa = new List<OrgWideEmailAddress>();
        if(ri?.Id!=null){
          // New Org Wide Email has to be created
          owa = [select id, Address, DisplayName from OrgWideEmailAddress where Address='salesplusplus_helpdesk@crmit.com'];
          String refID = [select Name from Reported_Issue__c where id=:ri.id]?.Name;
          String body='Apologies for the inconvenience. We have made a note of your issue and would get in touch with you, if needed. Please use the ID: '+refID+' for all future references. \n\nRegards\nSupport - Timesheet App';
          List<String> empEmail=new List<String>();
          String[] ccAddress=new String[]{'salesplusplus_helpdesk@crmit.com'};
          empEmail.add([select Email_ID__c from Employee__c where SF_User__c = :UserInfo.getUserId()]?.Email_ID__c);
          Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
          if(owa?.size()>0){
            mail.setOrgWideEmailAddressId(owa[0].Id); 
          }
          else{
            mail.setSenderDisplayName('NoReply-Timesheet');
          }
          mail.setSubject('No Reply - Reported Issue');
          mail.setPlainTextBody(body);
          mail.setToAddresses(empEmail);
          mail.setCcAddresses(ccAddress);
          mail.setReplyTo('salesplusplus_helpdesk@crmit.com');
          if(!Test.isRunningTest()){
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
          }
          return [select Name from Reported_Issue__c where id=:ri.id]?.Name;
        }else{
          return null;
        }
    }
  private static ContentVersion createContentVersion(String base64, String filename) {
    ContentVersion cv = new ContentVersion();
    cv.VersionData = EncodingUtil.base64Decode(base64);
    cv.Title = filename;
    cv.PathOnClient = filename;
    try {
      insert cv;
      return cv;
    } catch(DMLException e) {
      System.debug(e);
      return null;
    }
  }
  private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
              if (contentVersionId == null || recordId == null) { return null; }
    ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.ContentDocumentId = [
      SELECT ContentDocumentId 
      FROM ContentVersion 
      WHERE Id =: contentVersionId
    ].ContentDocumentId;
    cdl.LinkedEntityId = recordId;
    
    cdl.ShareType = 'V';
    try {
      insert cdl;
      return cdl;
    } catch(DMLException e) {
      System.debug(e);
      return null;
    }
  }
}