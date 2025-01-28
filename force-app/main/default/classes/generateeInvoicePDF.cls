public class generateeInvoicePDF {
    public static void eInvoicepdf(List<AcctSeed__Billing__c> billlist){
        system.debug('billlist>>>'+billlist);
        ClearTaxIntegration__c cleartaxendurl = ClearTaxIntegration__c.getOrgDefaults();
        system.debug('cleartaxendurl>>>'+cleartaxendurl);
        List<SObject> attachments=new  List<SObject>();
        for(AcctSeed__Billing__c bl:billlist){
            HTTPRequest req = new HTTPRequest();
            req.setEndPoint(cleartaxendurl.Endpoint_URL__c+'/einv/v2/eInvoice/download?template='+cleartaxendurl.PDF_Template_Id__c+'&irns='+bl.Irn__c);
            req.setHeader('Accept','application/octet-stream');
            req.setHeader('Content-Type','application/pdf');
            req.setHeader('Connection','Keep-Alive');
            req.setHeader('User-Agent','Apache-HttpClient/4.5.5 (Java/16.0.1)');
            req.setHeader('X-Cleartax-Auth-Token',cleartaxendurl.X_Cleartax_Auth_Token__c);
            req.setHeader('gstin',cleartaxendurl.gstin__c);
            req.setHeader('owner_id',cleartaxendurl.owner_id__c);
            //req.setbody(jsonRequestBody);
            req.setMethod('GET');
            system.debug('req>>>'+req);
            Http http = new Http();
            
            HTTPResponse res = http.send(req);
            Blob pdfContent = res.getBodyAsBlob();  //Blob property
            
            System.debug('resbody>>'+res.getBody());
            system.debug('responseStatus>>'+res.getStatus());
            system.debug('responseCode>>'+res.getStatusCode());
           
            Attachment attachment = new Attachment();
           // String base64Content = ( String ) JSON.deserialize( res.getBody(), String.class );
            attachment.Body = pdfContent;
            attachment.Name = 'eInvoice.pdf';
            //attachment.IsPrivate = isPrivate;
           // attachment.ContentType = contentType;
            attachment.ParentId = Bl.Id;
            attachments.add(attachment);
            
        }
        shouldIRun.stopTrigger();
        Update billlist;
        system.debug('billlist>'+billlist);
        insert attachments;
        system.debug('attachments>'+attachments);

    }
}