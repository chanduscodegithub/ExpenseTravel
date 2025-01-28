public class ClearTaxGSTAPI {
    //Add baseURL in Remote Site Settings
    public static Clear_Tax_GST_SALES_API__c salesSetting = Clear_Tax_GST_SALES_API__c.getInstance();
    public static Clear_Tax_GST_Purchase_API__c purchaseSetting = Clear_Tax_GST_Purchase_API__c.getInstance();
    public static  ClearTaxIntegration__c clearTxSetting = ClearTaxIntegration__c.getInstance();
    public static Decimal delaySeconds;
    public static String templateId;
    public static String tenant;
    public static String templateType;
    public static String baseURL = clearTxSetting.Endpoint_URL__c;
    public static String authToken = clearTxSetting.X_Cleartax_Auth_Token__c;
    public static String preSignedUrl;
    public static String activityId;
    public static String errorFileUrl;
    public static String fileName; //filename
    public static Blob fileContent; //content
    public static String fileRecordId;
    public static List<Attachment> attachment = new List<Attachment>(); //attachment record
    public static List<ContentDocumentLink> file = new List<ContentDocumentLink>(); //file record
    public static String responseMessage;
    public static String validationMessage;
    public static String responseBody;
   public static Integer statusCode;
    public static GST_Return_Files__c gstFile;
    
    
    @AuraEnabled()
    public static String getPreSignedURL(String recordId) {
        //fileRecordId = recordId; //used for the delayed method

		//Get the GST Return Files Record
        gstFile = [Select Id,Name,Transaction_Type__c from GST_Return_Files__c WHERE Id = :recordId LIMIT 1];
 		
		//Already Existing attachment
        attachment = [SELECT Id, Name, ParentId, Body,LastModifiedDate FROM Attachment WHERE ParentId = :recordId ORDER BY LastModifiedDate DESC LIMIT 1];
        
        //Takes the Recently Uploaded File   
		file = [SELECT Id, ContentDocumentId,ContentDocument.LatestPublishedVersion.ContentModifiedDate, ContentDocument.LatestPublishedVersion.VersionData ,ContentDocument.LatestPublishedVersion.Title
                FROM ContentDocumentLink
                WHERE LinkedEntityId =: recordId
                ORDER BY ContentDocument.LatestPublishedVersion.ContentModifiedDate DESC
                LIMIT 1];
        
       //If only Attachment Exists
		 if(attachment.size() > 0 && file.size() == 0){
            System.debug('only attachment is there');
            fileName = attachment[0].Name;
            fileContent = attachment[0].Body;
        }
		//If Both Attachment and File is There , It takes the Recently Uploaded File
        else if(file.size() > 0 && attachment.size() > 0){
            System.debug('In the else if part');
            fileName = file[0].ContentDocument.LatestPublishedVersion.Title+'.csv';
            fileContent = file[0].ContentDocument.LatestPublishedVersion.VersionData;
        }
        else{
            System.debug('In the else part for fileName');
            if(attachment.size() > 0){
                fileName =  attachment[0].Name;
                fileContent = attachment[0].Body;
            }
            else if(attachment.size() == 0 && file.size() >0){
                fileName = file[0].ContentDocument.LatestPublishedVersion.Title;
                fileContent = file[0].ContentDocument.LatestPublishedVersion.VersionData;
            }
			//If No Files or attachments are there, throw validation message
            else if(attachment.size() == 0 && file.size() == 0){
                validationMessage = 'Please upload a file or attachment';
                return validationMessage;
            }
            
        }
     
  // Checking if the GST Return Files record is Sales or Purchase   
  
        if(gstFile.Transaction_Type__c == 'Sales'){
            //If sales
            templateId = salesSetting.templateId__c;
            tenant = salesSetting.tenant__c;
            templateType = salesSetting.templateType__c;
            
        }else{
            //If Purchase
            templateId = purchaseSetting.templateId__c;
            tenant = purchaseSetting.tenant__c;
            templateType = purchaseSetting.templateType__c;
        }
        system.debug('TemplateType >>'+templateType);
        System.debug('File>> '+fileName);
        System.debug('File Body>>'+fileContent);
        
		//API CALL FROM HERE ... (1st one)
        Http http = new Http();
		//HTTP Request 
        HttpRequest request = new HttpRequest();
        request.setEndpoint(baseURL + '/integration/v1/generatePreSign/' + templateType +'?fileName='+ EncodingUtil.urlEncode(fileName, 'UTF-8'));
        request.setMethod('GET');
        request.setHeader('x-cleartax-auth-token', authToken);
        request.setHeader('fileContentType', 'CSV');

        //HTTP Response
        HttpResponse response = http.send(request);

		statusCode = response.getStatusCode();
        responseBody = response.getBody();

		// Deserialize the JSON string into collections of primitive data types.
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String status = (String) jsonResponse.get('status');
            String preSignedS3Url = (String) jsonResponse.get('preSignedS3Url');
            String errorCode = (String) jsonResponse.get('errorCode');
            String errorMessage = (String) jsonResponse.get('errorMessage');

		//For a successfully processed request (may be a success or validation error).
        if (response.getStatusCode() == 200) {
            //If STATUS is CREATED --- Pre-signed URL is generated.
            if (status == 'CREATED') {
                preSignedUrl = preSignedS3Url;
                System.debug('Pre-signed URL: ' + preSignedS3Url);
                uploadFileToStorage(preSignedUrl); //call the 2nd api
                
            	} 
			else {
				// Error occurred ****
                System.debug('Error code: ' + errorCode);
                System.debug('Error message: ' + errorMessage);
            
				validationMessage = errorCode+' | '+errorMessage;
                return validationMessage;
            }
		 }
		else {

            System.debug('Request failed with status code ' + response.getStatusCode());

   
            //SEND EMAIL
			sendEmailWhenError(statusCode,responseBody);
			return 'ErrorMailSent';

            
            
        }
        
        return 'Success';
        
    }
    
    //2nd API CALL Method
    public static void uploadFileToStorage(String preSignedUrl) {
   
		Http http = new Http();
        
        HttpRequest request = new HttpRequest();

        HttpResponse response = new HttpResponse();

        statusCode = response.getStatusCode();
        responseBody = response.getBody();
        
        String endpoint = preSignedUrl;
     
        request.setEndpoint(endpoint);
        request.setMethod('PUT');
        request.setHeader('Content-Type','application/vnd.ms-excel');
        request.setHeader('Accept', 'application/json'); 
        request.setBodyAsBlob(fileContent);
        
        //System.debug(request.getBody());
        
        
        response = http.send(request);

		//File Successfully uploaded
        if (response.getStatusCode() == 200) {
            System.debug('Success - HTTP Status Code - 200');
            triggerFileIngestion(preSignedUrl);
            
        }else{
            System.debug('Error - HTTP Status Code - 404');
            sendEmailWhenError(statusCode,responseBody);
             return;
        }
        
    }
    
	//3rd API CALL Method
    public static void triggerFileIngestion(String preSignedUrl){
        
		//POST Request Body
        ClearTaxPostJson2Apex requestBody = new ClearTaxPostJson2Apex(); //Wrapper Class

        requestBody.userInputArgs = new ClearTaxPostJson2Apex.UserInputArgs();
        requestBody.userInputArgs.templateId = templateId;
        requestBody.fileInfo = new ClearTaxPostJson2Apex.FileInfo();
        requestBody.fileInfo.s3FileUrl = preSignedUrl;
        requestBody.fileInfo.userFileName = fileName;

        String requestBodyJson = JSON.serialize(requestBody);

        System.debug('requestBodyJson:::'+requestBodyJson);
        
        
        Http http = new Http();

        HttpRequest request = new HttpRequest();

        request.setEndpoint(baseUrl+'/integration/v1/ingest/file/'+templateType);
        request.setHeader('x-cleartax-auth-token', authToken);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('POST');
        request.setBody(requestBodyJson); 

      //  request.setTimeout(120000); //2mins

        HttpResponse response = http.send(request);
        
        statusCode = response.getStatusCode();
        responseBody = response.getBody();
        
        //201 - Triggered ingestion successfully. 200 - Sometimes this code comes in Postman 
        if (response.getStatusCode() == 201 || response.getStatusCode() == 200) {
            System.debug('Response Body: ' + response.getBody());
            
            
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String actId = (String) jsonResponse.get('activityId');
            activityId = actId;
            
            System.debug('Activity ID: ' + activityId);
            delaySeconds = clearTxSetting.delaySeconds__c; 
            // Delay for 5 seconds
            DateTime start = System.Now();
            while(System.Now().getTime() < start.getTime()+delaySeconds){
            }
            
			getFileIngestionStatus(activityId);
            
            //Integer delaySeconds = 10;
            
            // Call the delayedMethod asynchronously after the specified delay
           // DateTime futureTime = System.now().addSeconds(delaySeconds);
           // System.enqueueJob(new DelayedMethodWrapper(futureTime,activityId,fileRecordId));
            
        } else {
            System.debug('The status code returned was not expected: ' + response.getStatusCode() + ' ' + response.getStatus());
            sendEmailWhenError(statusCode,responseBody);
            System.debug('Body:::: ' + response.getBody());
        }
    }


    public static void getFileIngestionStatus(String activityId){
        Http http = new Http();
		
        HttpRequest request = new HttpRequest();
        
        request.setEndpoint(baseUrl+'/integration/v1/ingest/file/'+templateType+'/status/'+activityId+'?tenant='+tenant);
        request.setMethod('GET');
        request.setHeader('x-cleartax-auth-token', authToken);
        request.setTimeout(120000);
        
        HttpResponse response = http.send(request);
        
        statusCode = response.getStatusCode();
        responseBody = response.getBody();
        System.debug('Response Body: ' + statusCode +':::'+ response.getBody());
        
        if (response.getStatusCode() == 200) {
            // Log the response body
            System.debug('Response Body: ' + response.getBody());
            
            
            // Extract specific fields from the response
            Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String status = (String) responseData.get('status');
            System.debug('Status >> '+status);

            //Response__c 
			//File uploaded to Clear Tax
			if(((Map<String, Object>) responseData.get('fileError')) == null && activityId != null){
                responseMessage = 'File Successfully Uploaded to Clear Tax';
                
            }
			//Error in File
            else if(((Map<String, Object>) responseData.get('fileError')) != null && activityId != null){
                responseMessage = (String) ((Map<String, Object>) responseData.get('fileError')).get('status'); 
            }
            else{
                responseMessage = 'Unplanned Error';
            }
            

			//Error_URL field
            if((Map<String, Object>) responseData.get('fileError') == null){
                errorFileUrl = null;
                
            }
            else{
                errorFileUrl = (String) ((Map<String, Object>) responseData.get('fileError')).get('errorFileUrl');
                
            }
            List<Object> processingStats = ((List<Object>) responseData.get('processingStats'));
            
            // Log specific fields
            System.debug('Status: ' + status);
            System.debug('Error File URL: ' + errorFileUrl);
            System.debug('ProcessingStats: '+processingStats);	
            
            gstFile.Response__c = responseMessage;
            gstFile.ErrorURLStore__c = errorFileUrl;
            update gstFile;
        }
        
        
        else {
            
			
            //Status code is mostly 200 (even for error file) so rare case to come in else part
            // Log the response body
            System.debug('Error Response Body: ' + response.getBody());
            
			sendEmailWhenError(statusCode,responseBody);

            
            // Extract specific fields from the response
            Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String status = (String) responseData.get('status');
            
            if((Map<String, Object>) responseData.get('fileError') == null){
                errorFileUrl = null;
            }
            else{
                errorFileUrl = (String) ((Map<String, Object>) responseData.get('fileError')).get('errorFileUrl');
                
            }
            
            List<Object> processingStats = ((List<Object>) responseData.get('processingStats'));
            // Debugging information
            System.debug('Request failed with status code ' + response.getStatusCode());
            
            gstfile.Response__c = status;
            gstFile.ErrorURLStore__c = errorFileUrl;
            update gstFile;
            
        }
    }


    
    public static void sendEmailWhenError(Integer statusCode, string responseBody){
           Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
			message.toAddresses = new String[] { 'lavanya.pushpakar@crmit.com' }; //ADD The System Admin user Email 
			message.optOutPolicy = 'FILTER'; //Sends email even if they have opted outed for the email
			message.subject = 'Error In Clear Tax API Call';
			message.plainTextBody = 'Status Code: '+statusCode+'Error Message: '+responseBody;
			Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
			Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);

			if (results[0].success) {
   			 	System.debug('The email was sent successfully.');
			} else {
   				 System.debug('The email failed to send: ' + results[0].errors[0].message);
			}
    }
    
}