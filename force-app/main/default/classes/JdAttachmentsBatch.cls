public class JdAttachmentsBatch implements Database.Batchable<sObject>,Database.AllowsCallOuts,Database.Stateful {
    public Map<String,Position__c> RRlist;
    static final Resume_Insights__c credentials = Resume_Insights__c.getInstance();
      private class CustomException extends Exception {
    }

    public JdAttachmentsBatch(Map<String,Position__c> JD)
    {
        this.RRlist=JD;
    }
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        List<String> positionNames = new List<String>(RRlist.keySet());
        String query = 'SELECT Id, Name__c, CreationDate__c, DisplayURL, MimeType__c, ExternalId FROM Google_Drive_CVs__x WHERE Name__c IN :positionNames';
        return Database.getQueryLocator(query);
        
    }
    public void execute(Database.BatchableContext bc, List<Google_Drive_CVs__x> googleDriveJds){
       // List<Attachment> Attfiles= new List<Attachment>();
        system.debug('googleDriveJds'+googleDriveJds);
        String fileId =googleDriveJds[0].ExternalId.substringAfterLast(':');
        String fileMimeType=googleDriveJds[0].MimeType__c;
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:Google_Drive_Resume_Insights/drive/v3/files/'+fileId+'?alt=media'); 
        request.setMethod('GET');
        //request.setheader('Content-Type', 'application/json; charset=UTF-8');
        request.setHeader('Accept','text/plain;charset=UTF-8;');
        HttpResponse response = http.send(request);
        System.debug('MimeType__c'+googleDriveJds[0].MimeType__c);
        String Base64data=EncodingUtil.base64Encode(response.getBodyAsBlob());
          //System.debug('response.getBody()'+response.getBody());
        if(response.getStatusCode() == 200) {
                       
         if(credentials?.Apyhub_Token__c==null)
        {
            throw new CustomException('Apyhub token is missing!');
        }
             
        Http http1 = new Http();
        HttpRequest request1 = new HttpRequest();
        request1.setEndpoint('https://api.apyhub.com/convert/word-base64/pdf-file?output=test-sample.pdf&landscape=false');
        request1.setMethod('POST');
        request1.setHeader('Content-Type', 'application/json');
        request1.setHeader('apy-token',credentials.Apyhub_Token__c);
        request1.setBody('{"base64": "'+Base64data+'"}');
       // request1.setBodyAsBlob(EncodingUtil.base64Encode(response.getBodyAsBlob());
        request1.setTimeout(2 * 60 * 1000);
        HttpResponse response1 = http.send(request1);
          if (response1.getStatusCode() == 200) {
                Blob pdfBlob = response1.getBodyAsBlob();

                // Create the attachment
               /* Attachment attachment = new Attachment();
                attachment.ParentId = RRlist.get(googleDriveJds[0].Name__c).Id; // The ID of the parent record (e.g., Account, Case)
                attachment.Name = googleDriveJds[0].Name__c+'.pdf';
                attachment.Body = pdfBlob;
                attachment.ContentType = 'application/pdf';
                insert attachment;
              ContentVersion cv = new ContentVersion();
              cv.Title = googleDriveJds[0].Name__c;
              cv.PathOnClient = googleDriveJds[0].Name__c+'.pdf';
              cv.VersionData = pdfBlob;
              Insert cv;*/
              String Name=googleDriveJds[0].Name__c+'.pdf';
               Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                attach.setContentType('application/pdf');
                attach.setFileName(Name);
                 attach.Body = pdfBlob;
 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {'lakkaraju.yuvathi@crmit.com'});
        mail.setSubject('Generate PDF from Apex Salesforce');
        mail.setHtmlBody('Generate PDF from Apex Salesforce');
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attach}); 
        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        
              
            } else {
                System.debug('Failed to convert Word to PDF: ' + response1.getStatus());
            }
        }
        
    }
    public void finish(Database.BatchableContext bc){
  
    }
}