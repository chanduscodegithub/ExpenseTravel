/*------------------------------------------------------------
Author       :  Manoj R M
Company      :  CRMIT Pvt. Ltd.
Description  :  This class is used to polling the status of a resume parsing.
Inputs       :  Mentioned before each methods.
Test Class   :  _

History
<Date>         <Authors Name>        <Brief Description of Change>
------------------------------------------------------------------*/
public without sharing class PdfParserQueue implements Queueable,Database.AllowsCallouts {
    
    public String location;
    public String accessToken;
    public String jobApplicationRecordId;
    public String fileExtension;
    public String fileTitle;
    private class CustomException extends Exception {
    }
    public PdfParserQueue(String accessToken,String location,String jobApplicationRecordId,String fileExtension,String fileTitle)
    {
        this.accessToken=accessToken;
        this.location=location;
        this.jobApplicationRecordId=jobApplicationRecordId;
        this.fileExtension=fileExtension;
        this.fileTitle=fileTitle;
    }
    public void execute(QueueableContext context) {
        try
        {
            Resume_Insights__c credentials = Resume_Insights__c.getInstance();
            if(credentials?.Adobe_Client_Id__c==null || credentials?.Adobe_Client_Secret__c==null)
            {
                throw new CustomException('Adobe Client Id and Client Secret is missing!');
            }
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(location);
            request.setMethod('GET');
            request.setHeader('Authorization', 'Bearer '+accessToken);
            request.setHeader('x-api-key', credentials.Adobe_Client_Id__c);
            request.setTimeout(2 * 60 * 1000);
            HttpResponse response = http.send(request);

            if(response.getStatusCode() == 200) {
                if(fileExtension=='pdf')
                    pdfExtractStatus(response);
                /* else if(fileExtension=='doc' || fileExtension=='docx')
                    docConvertStatus(response); */
            }
            else 
                throw new CustomException('Error while polling status. Status Code - '+response.getStatusCode());
        }
        Catch(Exception e)
        {
            System.debug('Error in PdfParserQueue class.');
            System.debug('Error Message - '+e.getMessage());
            System.debug('Error Line number-'+e.getLineNumber());
            System.debug('Error Stack Trace-'+e.getStackTraceString());
            //throw new AuraHandledException(e.getMessage());
            Log__c log = new Log__c(Method_Name__c='execute', Class_Name__c='PdfParserQueue', Line_Number__c=e.getLineNumber(), Reason__c=e.getMessage(),Stack_Trace__c=e.getStackTraceString());
            insert log;
            PdfParser.errorEmail(jobApplicationRecordId,log.Id);
        } 
    }

    public void pdfExtractStatus(HttpResponse response)
    {
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        if(String.valueOf(results.get('status'))=='done')
        {
            String contentJson = JSON.serialize(results.get('content'));
            Map<String, Object> contentMap = (Map<String, Object>) JSON.deserializeUntyped(contentJson);
            String downloadUri=String.valueOf(contentMap.get('downloadUri'));
            System.debug('downloadUri--'+downloadUri);
            PdfParser.extractPdfJSON(downloadUri,jobApplicationRecordId,fileTitle);
        }
        else if(String.valueOf(results.get('status'))=='failed')
        {
            String errorJson = JSON.serialize(results.get('error'));
            Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(errorJson);
            throw new CustomException(String.valueOf(errorMap.get('message')));
        }
        else if(String.valueOf(results.get('status'))=='in progress')
        {
            Integer delayInMinutes = 1;
            ID jobID = System.enqueueJob(new PdfParserQueue(accessToken,location,jobApplicationRecordId,fileExtension,fileTitle), delayInMinutes);
        }

    }

}