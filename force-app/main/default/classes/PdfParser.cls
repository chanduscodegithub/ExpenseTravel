/*------------------------------------------------------------
Author       :  Manoj R M
Company      :  CRMIT Pvt. Ltd.
Description  :  _
Inputs       :  Mentioned before each methods.
Test Class   :  _

History
<Date>         <Authors Name>        <Brief Description of Change>
------------------------------------------------------------------*/
public without sharing class PdfParser {
    static final Resume_Insights__c credentials = Resume_Insights__c.getInstance();
    static String logFileBodyGlobal='';
    /**
      * @description Custom Exception.
      */

    private class CustomException extends Exception {
    }

    private class ResumeMissingException extends Exception {
    }

    /**This method used to parse resume
      * @param {String} jobApplicationRecordId - The Job Application record id.
      * @param {String} selectedResumeId - ContentDocumentId of the selected resume.
      * @author Manoj
      * @since Dec 07 2023
      */
    @AuraEnabled
    public static ResumeMissingException parse(String recordId)
    {
        String jobApplicationRecordId;
        try
        {
            String jobApplicationPrefix = Schema.getGlobalDescribe().get('Job_Application__c').getDescribe().getKeyPrefix();
            String interviewPrefix = Schema.getGlobalDescribe().get('Review__c').getDescribe().getKeyPrefix();
            if (recordId != null && recordId.startsWithIgnoreCase(interviewPrefix)) 
            {
                Review__c interviewRecord=[SELECT Id,Job_Application__c FROM Review__c WHERE Id=:recordId LIMIT 1];
                jobApplicationRecordId= interviewRecord.Job_Application__c;
            }
            else
            {
                jobApplicationRecordId=recordId;
            }
            if([SELECT Id FROM Job_Application_Analysis__c WHERE Job_Application__c=:jobApplicationRecordId].size()>0)
            {
                throw new CustomException('This application is already analyzed.');
            }
            List<Attachment> att=new List<Attachment>();
            /*ContentVersion file = [SELECT Title, VersionData,FileExtension FROM ContentVersion WHERE IsLatest = TRUE and ContentDocumentId=:selectedResumeId LIMIT 1];
            String fileTitle=file.Title; 
            String resumePlainTextFileName='PlainText_'+fileTitle.removeStart('PDF_');
            att=[SELECT Body FROM Attachment WHERE parentId=:jobApplicationRecordId AND Name =:resumePlainTextFileName ORDER by Createddate DESC LIMIT 1]; */
            //
            //att=[SELECT Body FROM Attachment WHERE parentId=:jobApplicationRecordId AND Name LIKE 'PlainText_%' ORDER by Createddate DESC LIMIT 1];
            //
            //if(att!=null && att.size()>0) analyzeCvGeneric(att[0].Body.toString(),jobApplicationRecordId);
            
            Job_Application__c jobApp=[SELECT Id,GDrive_Resume__c,Resume_Uploaded_to_G_Drive__c,Candidate_Email_Formula__c FROM Job_Application__c WHERE Id=:jobApplicationRecordId LIMIT 1];
            if(jobApp.Resume_Uploaded_to_G_Drive__c==false || jobApp.GDrive_Resume__c==null)
            {
                updateJobApplication(jobApplicationRecordId);
                throw new ResumeMissingException('Please verify that the resume is correctly uploaded to Google Drive.');
            }
            List<Google_Drive_CVs__x> googleDriveFile=new List<Google_Drive_CVs__x>([SELECT Id,Name__c,MimeType__c,ExternalId FROM Google_Drive_CVs__x WHERE Id=:jobApp.GDrive_Resume__c LIMIT 1]);
            if(googleDriveFile==null || googleDriveFile.size()==0)
            {
                updateJobApplication(jobApplicationRecordId);
                throw new ResumeMissingException('Resume has been renamed or deleted from Google Drive.');
            }
            String fileId=googleDriveFile[0].ExternalId.substringAfterLast(':');
            String fileMimeType=googleDriveFile[0].MimeType__c;
            String fileTitle=googleDriveFile[0].Name__c;
            if(!fileTitle.startsWith(jobApp.Candidate_Email_Formula__c))
            {
                updateJobApplication(jobApplicationRecordId);
                throw new ResumeMissingException('Please verify that the resume is correctly uploaded to Google Drive.');
            }
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:Google_Drive_Resume_Insights/drive/v3/files/'+fileId+'?alt=media'); 
            request.setMethod('GET');
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200) {
                String accessToken=getAccessToken(jobApplicationRecordId);
                if(fileMimeType=='application/pdf')
                    parsePdf(accessToken,jobApplicationRecordId,response.getBodyAsBlob(),'pdf',fileTitle);
                else if(fileMimeType=='application/msword' || fileMimeType=='application/vnd.openxmlformats-officedocument.wordprocessingml.document')
                {
                    Blob convertedPdfBlob=apyHubConvertWordToPdf(jobApplicationRecordId,EncodingUtil.base64Encode(response.getBodyAsBlob()),fileTitle);
                    parsePdf(accessToken,jobApplicationRecordId,convertedPdfBlob,'pdf',fileTitle);
                }  
            }
            else
            {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                String errorJSON = JSON.serialize((Map<String, Object>)results.get('error'));
                Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(errorJSON);
                String errorMessage=(String)errorMap.get('message');
                if(errorMessage.contains('File not found'))
                {
                    throw new ResumeMissingException('File not found in the Google Drive.');
                }
                throw new CustomException('Error - '+errorMessage+'. Status code - '+response.getStatusCode());
            } 
                
            
            return null; 
        }
        Catch(ResumeMissingException e)
        {
            System.debug('Error in PdfParser class, parse method.');
            System.debug('Error Message - '+e.getMessage());
            System.debug('Error Line number-'+e.getLineNumber());
            System.debug('Error Stack Trace-'+e.getStackTraceString());
            return e;
        } 
        Catch(CustomException e)
        {
            System.debug('Error in PdfParser class, parse method.');
            System.debug('Error Message - '+e.getMessage());
            System.debug('Error Line number-'+e.getLineNumber());
            System.debug('Error Stack Trace-'+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        Catch(Exception e)
        {
            System.debug('Error in PdfParser class, parse method.');
            System.debug('Error Message - '+e.getMessage());
            System.debug('Error Line number-'+e.getLineNumber());
            System.debug('Error Stack Trace-'+e.getStackTraceString());
            Log__c log = new Log__c(Method_Name__c='parse', Class_Name__c='PdfParser', Line_Number__c=e.getLineNumber(), Reason__c=e.getMessage(),Stack_Trace__c=e.getStackTraceString());
            //throw new AuraHandledException(e.getMessage());
            insert log;
            errorEmail(jobApplicationRecordId,log.Id);
            return null;
        } 
    }
    @future(callout=true)
    public static void parsePdf(String accessToken,String jobApplicationRecordId,Blob resumeVersionData,String fileExtension,String fileTitle)
    {
        try
        {
            Map<String,Object> assetInfo=createAsset(accessToken,jobApplicationRecordId,fileExtension);
            uploadFile(accessToken,jobApplicationRecordId,String.valueOf(assetInfo.get('assetID')),String.valueOf(assetInfo.get('uploadUri')),resumeVersionData,fileExtension);
            String location=extractPdf(accessToken,jobApplicationRecordId,String.valueOf(assetInfo.get('assetID')));
            System.enqueueJob(new PdfParserQueue(accessToken,location,jobApplicationRecordId,fileExtension,fileTitle), 1); // delayInMinutes=1
        }
        Catch(Exception e)
        {
            System.debug('Error in PdfParser class, parsePdf method.');
            System.debug('Error Message - '+e.getMessage());
            System.debug('Error Line number-'+e.getLineNumber());
            System.debug('Error Stack Trace-'+e.getStackTraceString());
            Log__c log = new Log__c(Method_Name__c='parsePdf', Class_Name__c='PdfParser', Line_Number__c=e.getLineNumber(), Reason__c=e.getMessage(),Stack_Trace__c=e.getStackTraceString());
            //throw new AuraHandledException(e.getMessage());
            insert log;
            errorEmail(jobApplicationRecordId,log.Id);
        }
    }

    /**This method used to convert Document to PDF using Apyhub API
      * @param {String} jobApplicationRecordId - The Job Application record id.
      * @param {String} resumeVersionDataString - VersionData of the resume document.
      * @param {String} fileTitle - File name of the document.
      * @return {Blob} Converted PDF's Blob
      * @author Manoj
      * @since Dec 07 2023
      */
    public static Blob apyHubConvertWordToPdf(String jobApplicationRecordId,String resumeVersionDataString,String fileTitle)
    {
        if(credentials?.Apyhub_Token__c==null)
        {
            throw new CustomException('Apyhub token is missing!');
        }
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.apyhub.com/convert/word-base64/pdf-file?output=test-sample.pdf&landscape=false');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('apy-token',credentials.Apyhub_Token__c);
        request.setBody('{"base64": "'+resumeVersionDataString+'"}');
        request.setTimeout(2 * 60 * 1000);
        HttpResponse response = http.send(request);

        /*ContentVersion resumePdf = new ContentVersion();
        resumePdf.VersionData=response.getBodyAsBlob();
        resumePdf.Title = 'PDF_'+fileTitle;
        resumePdf.PathOnClient = 'PDF_'+fileTitle+'.pdf';
        resumePdf.FirstPublishLocationId=jobApplicationRecordId;
        Insert resumePdf;
        System.debug('resumePdf Id-'+resumePdf.Id);*/
        return response.getBodyAsBlob();
    }


    /**This method used to get access token of Adobe API
      * @param {String} jobApplicationRecordId - The Job Application record id.
      * @return {String} Access Token of Adobe API
      * @author Manoj
      * @since Dec 07 2023
      */
    public static String getAccessToken(String jobApplicationRecordId)
    {
        if(credentials?.Adobe_Client_Id__c==null || credentials?.Adobe_Client_Secret__c==null)
        {
            throw new CustomException('Adobe Client Id and Client Secret is missing!');
        }
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://ims-na1.adobelogin.com/ims/token/v3');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String requestBody='grant_type=client_credentials&client_id='+credentials.Adobe_Client_Id__c+'&client_secret='+credentials.Adobe_Client_Secret__c+'&scope=openid,AdobeID,DCAPI';
        request.setBody(requestBody);
        request.setTimeout(2 * 60 * 1000);
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            return String.valueOf(results.get('access_token'));
        }  
        else
        {
            throw new CustomException('Error while getting access token. Status code - '+response.getStatusCode());
        }       
    }
    
    public static Map<String, Object> createAsset(String accessToken,String jobApplicationRecordId,String fileExtension)
    {
        if(credentials?.Adobe_Client_Id__c==null || credentials?.Adobe_Client_Secret__c==null)
        {
            throw new CustomException('Adobe Client Id and Client Secret is missing!');
        }
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://pdf-services-ue1.adobe.io/assets');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer '+accessToken);
        request.setHeader('x-api-key', credentials.Adobe_Client_Id__c);

        String fileMimeType='';
        if(fileExtension=='pdf') fileMimeType='application/pdf';
        else if(fileExtension=='docx') fileMimeType='application/vnd.openxmlformats-officedocument.wordprocessingml.document';    
        else if(fileExtension=='doc') fileMimeType='application/msword';
            
        request.setBody('{"mediaType": "'+fileMimeType+'"}');
        request.setTimeout(2 * 60 * 1000);
        HttpResponse response = http.send(request);
        if(response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            return results;
        }
        else
        {
            throw new CustomException('Error while creating asset. Status code - '+response.getStatusCode()); 
        }      
    }
    
    public static void uploadFile(String accessToken,String jobApplicationRecordId,String assetId,String uploadUri,Blob resumeVersionData,String fileExtension)
    {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(uploadUri);
        request.setMethod('PUT');
       
        String contentType='';
        if(fileExtension=='pdf') contentType='application/pdf';    
        else if(fileExtension=='docx') contentType='application/vnd.openxmlformats-officedocument.wordprocessingml.document';      
        else if(fileExtension=='doc') contentType='application/msword';
            
        request.setHeader('Content-Type', contentType);
        request.setBodyAsBlob(resumeVersionData);
        request.setTimeout(2 * 60 * 1000);
        HttpResponse response = http.send(request);
        if(response.getStatusCode() != 200) {
            throw new CustomException('Error while uploading the file. Status code - '+response.getStatusCode()); 
        }
            
    }

    public static String extractPdf(String accessToken,String jobApplicationRecordId,String assetId)
    {
        if(credentials?.Adobe_Client_Id__c==null || credentials?.Adobe_Client_Secret__c==null)
        {
            throw new CustomException('Adobe Client Id and Client Secret is missing!');
        }
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://pdf-services-ue1.adobe.io/operation/extractpdf');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Authorization', 'Bearer '+accessToken);
        request.setHeader('x-api-key', credentials.Adobe_Client_Id__c);
        String requestBody='{'+
                        '"assetID": "'+assetId+'",'+
                        '"getCharBounds": false,'+
                        '"includeStyling": false,'+
                        '"elementsToExtract": ['+
                        '"text",'+
                        '"tables"'+
                        '],'+
                        '"tableOutputFormat": "xlsx",'+
                        '"renditionsToExtract": ['+
                        '"tables",'+
                        '"figures"'+
                        ']'+
                        '}';
        request.setBody(requestBody);
        System.debug('requestBody--'+requestBody);
        request.setTimeout(2 * 60 * 1000);
        HttpResponse response = http.send(request);
        System.debug('Response-'+response.getBody());
        System.debug('request-'+request);
        
        if(response.getStatusCode() == 201) {
            System.debug('Location--'+response.getHeader('location'));
            String location=response.getHeader('location');
            return location;
        }
        else
        {
            throw new CustomException('Error while extracting/creating pdf. Status code - '+response.getStatusCode()); 
        }        
    }
    
    public static void extractPdfJSON(String downloadUri,String jobApplicationRecordId,String fileTitle) 
    {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(downloadUri);
        request.setMethod('GET');
        request.setTimeout(2 * 60 * 1000);
        HttpResponse response = http.send(request);
        System.debug('Response-'+response.getBody());
        if(response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String resumeText=convertJSONtoText(response.getBody());
            delete [SELECT Body FROM Attachment WHERE parentId=:jobApplicationRecordId AND Name LIKE 'PlainText_%' ORDER by Createddate DESC];
            Attachment resumeTextAtt = new Attachment();
            resumeTextAtt.Name = +'PlainText_'+fileTitle;
            resumeTextAtt.parentId = jobApplicationRecordId;
            resumeTextAtt.body = Blob.valueOf(resumeText);
            resumeTextAtt.ContentType = 'text/plain';
            Insert resumeTextAtt;
            analyzeCvGeneric(resumeText,jobApplicationRecordId);
        }
        else
        {
            throw new CustomException('Error while extracting JSON. Status code - '+response.getStatusCode()); 
        } 
    }

    /**This method used to analyze resume and create job application insights
      * @param {String} jobApplicationRecordId - The Job Application record id.
      * @param {String} resumeText - plain text of the resume.
      * @author Manoj
      * @since Dec 07 2023
      */
    @future(callout=true)
    public static void analyzeCvGeneric(String resumeText,String jobApplicationRecordId)
    {
        //Savepoint sp = Database.setSavepoint();
        String logFileBody='';
        try{
            
            //String resumeText=convertJSONtoText(jsonText);
            System.debug('resumeText--'+resumeText);
            Prompt_Context__c pc=[Select Id,Object_Api_Name__c,Context_Name__c From Prompt_Context__c Where Context_Name__c='Resumes' Limit 1];
            Job_Application__c jobAppRecord=[SELECT Id,Position__c FROM Job_Application__c WHERE Id=:jobApplicationRecordId LIMIT 1];
            Position__c resourceReqRecord=[SELECT Id,Job_Role__c, Esse__c, Essential_Administration_Skills__c, Essential_Tools__c, Essential_Certifications__c, SF_Clouds__c, Additional_Tech_Skills__c, Additional_Administration_Skills__c, Additional_Certifications__c, Additional_Tools__c, Verticals__c FROM Position__c WHERE Id=:jobAppRecord.Position__c LIMIT 1];
            //String ObjectApiName=pc.Object_Api_Name__c;
            String ObjectApiName='Job_Application_Analysis__c';
            Type resumeAnalysisObject=Type.forName(ObjectApiName);
            sObject resumeAnalysisRecord=(sObject)resumeAnalysisObject.newInstance();
            if(resourceReqRecord.Job_Role__c==null)
            {
                throw new CustomException('Please specify Job Role in Job Application.');
            }
            for(Prompt__c prompt : [SELECT Id, Sequence__c, Active__c, Prompt_Content__c, Prompt_Context__c, Prompt_Response_Format__c,Name FROM Prompt__c Where Prompt_Context__c=:pc.Id And Active__c=true Order by Sequence__c ASC])
            {
                logFileBody=logFileBody+promptRequest(prompt,resumeAnalysisRecord,resumeText,resourceReqRecord);
            }
            System.debug('resumeAnalysisRecord-'+resumeAnalysisRecord);
            
            resumeAnalysisRecord.put('Job_Application__c',jobApplicationRecordId);
            //calculateOverallScore(resumeAnalysisRecord,resourceReqRecord.Job_Role__c);
            calculateOverallScoreNew(resumeAnalysisRecord,resourceReqRecord.Job_Role__c,resourceReqRecord);
            insert resumeAnalysisRecord;
            
            updateCandidateRecord(resumeAnalysisRecord,jobApplicationRecordId);

            Job_Application__c jobApp=new Job_Application__c();
            jobApp.Id=jobApplicationRecordId;
            jobApp.Picklist__c='Candidate AI Screened';
            jobApp.Resume_Analyzed__c=true;
            update jobApp;

            List<Attachment> attlist = new List<Attachment>();
            Attachment promptAtt = new Attachment();
            promptAtt.Name = 'Chat Gpt Logs';
            promptAtt.parentId = resumeAnalysisRecord.Id;
            promptAtt.body = Blob.valueOf(logFileBody);
            promptAtt.ContentType = 'text/plain';
            attlist.add(promptAtt);
            Insert attlist;
            notifyUsers(resumeAnalysisRecord.Id,jobApplicationRecordId);
        }
        Catch(Exception e)
        {
            System.debug('Error in PdfParser class, parse method.');
            System.debug('Error Message - '+e.getMessage());
            System.debug('Error Line number-'+e.getLineNumber());
            System.debug('Error Stack Trace-'+e.getStackTraceString());
            //Database.rollback(sp);
            Log__c log = new Log__c(Method_Name__c='analyzeCvGeneric', Class_Name__c='PdfParser', Line_Number__c=e.getLineNumber(), Reason__c=e.getMessage(),Stack_Trace__c=e.getStackTraceString());
            //throw new AuraHandledException(e.getMessage());
            insert log;
            if(logFileBodyGlobal!='')
            {
                List<Attachment> attlist = new List<Attachment>();
                Attachment promptAtt = new Attachment();
                promptAtt.Name = 'Chat Gpt Logs';
                promptAtt.parentId = log.Id;
                promptAtt.body = Blob.valueOf(logFileBodyGlobal);
                promptAtt.ContentType = 'text/plain';
                attlist.add(promptAtt);
                Insert attlist;
            }
            errorEmail(jobApplicationRecordId,log.Id);
        } 
    }

    /**This method used to replace dynamic values in the prompt
      * @param {String} prompt - The prompt in which we need to change dynamic value.
      * @param {Integer} startIndex - start index of an prompt string to find dynamic field.
	  * @param {Position__c} resourceReqRecord - Resource Requisition record.
      * @author Manoj
      * @since Feb 01 2024
      */
    public static String replaceDynamicValues(String prompt, Integer startIndex, Position__c resourceReqRecord)
    {
        Integer openParenthesesIndex=prompt.indexOf('{',startIndex);
        if(openParenthesesIndex==-1) return prompt;
        Integer closeParenthesesIndex=prompt.indexOf('}',openParenthesesIndex);
        if(closeParenthesesIndex==-1) return prompt;
        String dynamicField=prompt.substring(openParenthesesIndex+1,closeParenthesesIndex);
        if(dynamicField=='CurrentDate') prompt.replace('{CurrentDate}', System.now().format('MMM yyyy'));
        else 
        {
            if(resourceReqRecord.get(dynamicField)!=null) prompt=prompt.replace('{'+dynamicField+'}',String.valueOf(resourceReqRecord.get(dynamicField)));
            else prompt=prompt.replace('{'+dynamicField+'}','');    
        }
        prompt=replaceDynamicValues(prompt,closeParenthesesIndex+1,resourceReqRecord);
        return prompt;
    }

    /**This method used to update candidate record
      * @param {sObject} resumeAnalysisRecord - Instance of an Job Application Insights Object.
      * @param {String} jobApplicationRecordId - The Job Application record id.
      * @author Manoj
      * @since Dec 07 2023
      */
    public static void updateCandidateRecord(sObject resumeAnalysisRecord,String jobApplicationRecordId)
    {
        System.debug('resumeAnalysisRecord-'+resumeAnalysisRecord);
        Job_Application__c jobApp=[SELECT Id,Candidate__c FROM Job_Application__c WHERE Id=:jobApplicationRecordId LIMIT 1];
        Candidate__c candidate=[SELECT Id, Mobile__c, Phone__c,Email__c, Current_Employer__c, Current_Location__c, Current_Role__c, LinkedIn_Profile_URL__c,Candidate_Current_Location__c,Minimum_Tenure_in_a_Company__c,Maximum_Tenure_in_a_Company__c,
                                Average_Tenure_in_a_Company__c,Years_of_Experience__c,Number_of_Companies_Worked_for__c,Trailblazer_Link__c FROM Candidate__c WHERE Id=:jobApp.Candidate__c LIMIT 1];
        System.debug('candidate-'+candidate);
        if((candidate.Mobile__c==null || candidate.Mobile__c=='') && resumeAnalysisRecord.get('Phone_Number__c')!=null)
            Candidate.Mobile__c=String.valueOf(resumeAnalysisRecord.get('Phone_Number__c'));
        if((candidate.Email__c==null || candidate.Email__c=='') && resumeAnalysisRecord.get('Email_Address__c')!=null)
            Candidate.Email__c=String.valueOf(resumeAnalysisRecord.get('Email_Address__c'));
        if(resumeAnalysisRecord.get('Current_Location__c')!=null)
            Candidate.Candidate_Current_Location__c=String.valueOf(resumeAnalysisRecord.get('Current_Location__c'));
        if((candidate.LinkedIn_Profile_URL__c==null || candidate.LinkedIn_Profile_URL__c=='') && resumeAnalysisRecord.get('LinkedIn_Url__c')!=null)
            Candidate.LinkedIn_Profile_URL__c=String.valueOf(resumeAnalysisRecord.get('LinkedIn_Url__c'));
        if(resumeAnalysisRecord.get('Current_Employer__c')!=null)
            Candidate.Current_Employer__c=String.valueOf(resumeAnalysisRecord.get('Current_Employer__c'));
        if(resumeAnalysisRecord.get('Latest_Role__c')!=null)
            Candidate.Current_Role__c=String.valueOf(resumeAnalysisRecord.get('Latest_Role__c'));
        
        if(resumeAnalysisRecord.get('Min_Time_Spent_in_a_Company__c')!=null)
            Candidate.Minimum_Tenure_in_a_Company__c=(Decimal)resumeAnalysisRecord.get('Min_Time_Spent_in_a_Company__c');
        if(resumeAnalysisRecord.get('Max_Time_Spent_in_a_Company__c')!=null)
            Candidate.Maximum_Tenure_in_a_Company__c=(Decimal)resumeAnalysisRecord.get('Max_Time_Spent_in_a_Company__c');
        if(resumeAnalysisRecord.get('Average_Tenure__c')!=null)
            Candidate.Average_Tenure_in_a_Company__c=(Decimal)resumeAnalysisRecord.get('Average_Tenure__c');
        if(resumeAnalysisRecord.get('Total_Experience_Months__c')!=null)
            Candidate.Years_of_Experience__c=((Decimal)resumeAnalysisRecord.get('Total_Experience_Months__c'))/12;
        if(resumeAnalysisRecord.get('Companies_Worked_for__c')!=null)
            Candidate.Number_of_Companies_Worked_for__c=String.valueOf(resumeAnalysisRecord.get('Companies_Worked_for__c')).split(';').size();
        if(resumeAnalysisRecord.get('Trailhead_Url__c')!=null)
            Candidate.Trailblazer_Link__c=String.valueOf(resumeAnalysisRecord.get('Trailhead_Url__c'));
        update candidate;
        System.debug('candidate-'+candidate);
    }
    
    /**This method used to calculate candidate overall score and section wise scores.
      * @param {sObject} resumeAnalysisRecord - Instance of an Job Application Insights Object.
      * @param {String} jobRoleId - The Job Role record id.
      * @param {Position__c} resourceReqRecord - Resource Requisition record.
      * @author Manoj
      * @since Feb 01 2024
      */
    public static void calculateOverallScoreNew(sObject resumeAnalysisRecord,String jobRoleId,Position__c resourceReqRecord)
    {   
        List<SkillFields> skillsFieldList=new List<SkillFields>();
        skillsFieldList.add(new SkillFields('Essential_Tech_Skills_Analysis__c','Essential_Tech_Skills_Weightage__c','Essential_Tech_Score__c','Esse__c','Missing_Tech_Skills__c'));
        skillsFieldList.add(new SkillFields('Essential_Admin_Skills_Analysis__c','Essential_Administration_Skill_Weightage__c','Essential_Administration_Skills_Score__c','Essential_Administration_Skills__c','Missing_Admin_Skills__c'));
        skillsFieldList.add(new SkillFields('Essential_Tools_Analysis__c','Essential_Tools_Weightage__c','Essental_Tools_Score__c','Essential_Tools__c','Missing_Tools__c'));
        skillsFieldList.add(new SkillFields('Essential_Certifications_Analysis__c','Essential_Certifications_Weightage__c','Essential_Certifications_Score__c','Essential_Certifications__c','Missing_Certifications__c'));
        skillsFieldList.add(new SkillFields('Salesforce_Clouds_Analysis__c','Salesforce_Clouds_Weightage__c','Salesforce_Clouds_Score__c','SF_Clouds__c','Missing_Clouds__c'));
        skillsFieldList.add(new SkillFields('Advanced_Tech_Skills_Analysis__c','Advanced_Tech_Skills_Weightage__c','Advanced_Tech_Score__c','Additional_Tech_Skills__c','Missing_Tech_Skills_Additional__c'));
        skillsFieldList.add(new SkillFields('Advanced_Admin_Skills_Analysis__c','Advanced_Administration_Skills_Weightage__c','Advanced_Administration_Skills_Score__c','Additional_Administration_Skills__c','Missing_Admin_Skills_Additional__c'));
        skillsFieldList.add(new SkillFields('Advanced_Tools_Analysis__c','Advanced_Tools_Weightage__c','Advanced_Tools_Score__c','Additional_Tools__c','Missing_Tools_Additional__c'));
        skillsFieldList.add(new SkillFields('Advanced_Certitfications_Analysis__c','Advanced_Certifications_Weightage__c','Advanced_Certifications_Score__c','Additional_Certifications__c','Missing_Certifications_Additional__c'));
        skillsFieldList.add(new SkillFields('Verticals_Analysis__c','Verticals_Weightage__c','Verticals_Score__c','Verticals__c','Missing_Verticals__c'));
        Job_Role__c jobRole=[SELECT Id, Advanced_Certifications_Weightage__c, Essential_Tools_Weightage__c, Essential_Tech_Skills_Weightage__c, Essential_Certifications_Weightage__c, Advanced_Tools_Weightage__c, Advanced_Administration_Skills_Weightage__c, Essential_Administration_Skill_Weightage__c, Advanced_Tech_Skills_Weightage__c,Salesforce_Clouds_Weightage__c,Verticals_Weightage__c FROM Job_Role__c WHERE Id=:jobRoleId LIMIT 1];
        Decimal overallScore=0;
        for(SkillFields skill : skillsFieldList)
        {
            String skillsFoundField=skill.skillsFoundField;
            String skillsWieghtageField=skill.skillsWieghtageField;
            String skillsField=skill.skillsField;
            String skillsNotFoundField=skill.skillsNotFoundField;
            
            if(resumeAnalysisRecord.get(skillsFoundField)!=null && String.valueOf(resumeAnalysisRecord.get(skillsFoundField)).split(';').size()>0 && resourceReqRecord.get(skillsField)!=null && String.valueOf(resourceReqRecord.get(skillsField)).split(',').size()>0)
            {
                List<String> skillsList=String.valueOf(resourceReqRecord.get(skillsField)).split(',');
                List<String> skillsFoundList=String.valueOf(resumeAnalysisRecord.get(skillsFoundField)).split(';');
                for(Integer i=0;i<skillsList.size();i++)
                {
                    skillsList.set(i,skillsList[i].trim());
                }
                for(Integer i=0;i<skillsFoundList.size();i++)
                {
                    skillsFoundList.set(i,skillsFoundList[i].trim());
                }
                Set<String> skillsFoundSet=new Set<String>(skillsFoundList);
                Set<String> skillsSet=new Set<String>(skillsList);
                Set<String> temp=new Set<String>(skillsFoundSet);
                Set<String> skillsNotFoundSet=new Set<String>(skillsList);
                temp.removeAll(skillsSet);
                skillsFoundSet.removeAll(temp);
                skillsNotFoundSet.removeAll(skillsFoundSet);
               
                Decimal skillsWeightage=(jobRole.get(skillsWieghtageField)!=null) ? Decimal.valueOf(String.valueOf(jobRole.get(skillsWieghtageField))) : 0;
                Decimal totalSkillsCount=skillsList.size();
                Decimal skillsFoundCount=skillsFoundSet.size();
                
                Decimal skillScore=((skillsFoundCount/totalSkillsCount)*skillsWeightage).setScale(2);
                resumeAnalysisRecord.put(skill.skillsScoreField,String.valueOf(skillScore));
                resumeAnalysisRecord.put(skillsFoundField,String.join(skillsFoundSet,';'));
                resumeAnalysisRecord.put(skillsNotFoundField,String.join(skillsNotFoundSet,';'));
                overallScore=overallScore+skillScore;
                System.debug(skill.skillsScoreField+'--'+skillScore);
                System.debug('totalSkillsCount-'+totalSkillsCount);
                System.debug('skillsFoundCount-'+skillsFoundCount);
            }
            else
            {
                if(resourceReqRecord.get(skillsField)!=null && String.valueOf(resourceReqRecord.get(skillsField)).split(',').size()>0)
                {
                    List<String> skillsList=String.valueOf(resourceReqRecord.get(skillsField)).split(',');
                    Set<String> skillsNotFoundSet=new Set<String>(skillsList);
                    resumeAnalysisRecord.put(skillsNotFoundField,String.join(skillsNotFoundSet,';'));
                    resumeAnalysisRecord.put(skill.skillsScoreField,'0');
                	System.debug(skill.skillsScoreField+'--'+'0');
                }
                resumeAnalysisRecord.put(skillsFoundField,'');
                resumeAnalysisRecord.put(skill.skillsScoreField,'0');
                System.debug(skill.skillsScoreField+'--'+'0');  
            }
        }
        resumeAnalysisRecord.put('Overall_Score__c',overallScore);
        System.debug('Overall_Score__c--'+overallScore);
       	System.debug('resumeAnalysisRecord--'+resumeAnalysisRecord);
    }
    
    public static void calculateOverallScore(sObject resumeAnalysisRecord,String jobRoleId)
    {   
        List<SkillFields> skillsFieldList=new List<SkillFields>();
        skillsFieldList.add(new SkillFields('Essential_Tech_Skills_Analysis__c','Essential_Tech_Skills_Weightage__c','Essential_Tech_Score__c','Esse__c','Missing_Tech_Skills__c'));
        skillsFieldList.add(new SkillFields('Essential_Admin_Skills_Analysis__c','Essential_Administration_Skill_Weightage__c','Essential_Administration_Skills_Score__c','Essential_Administration_Skills__c','Missing_Admin_Skills__c'));
        skillsFieldList.add(new SkillFields('Essential_Tools_Analysis__c','Essential_Tools_Weightage__c','Essental_Tools_Score__c','Essential_Tools__c','Missing_Tools__c'));
        skillsFieldList.add(new SkillFields('Essential_Certifications_Analysis__c','Essential_Certifications_Weightage__c','Essential_Certifications_Score__c','Essential_Certifications__c','Missing_Certifications__c'));
        skillsFieldList.add(new SkillFields('Salesforce_Clouds_Analysis__c','Salesforce_Clouds_Weightage__c','Salesforce_Clouds_Score__c','SF_Clouds__c','Missing_Clouds__c'));
        skillsFieldList.add(new SkillFields('Advanced_Tech_Skills_Analysis__c','Advanced_Tech_Skills_Weightage__c','Advanced_Tech_Score__c','Additional_Tech_Skills__c','Missing_Tech_Skills_Additional__c'));
        skillsFieldList.add(new SkillFields('Advanced_Admin_Skills_Analysis__c','Advanced_Administration_Skills_Weightage__c','Advanced_Administration_Skills_Score__c','Additional_Administration_Skills__c','Missing_Admin_Skills_Additional__c'));
        skillsFieldList.add(new SkillFields('Advanced_Tools_Analysis__c','Advanced_Tools_Weightage__c','Advanced_Tools_Score__c','Additional_Tools__c','Missing_Tools_Additional__c'));
        skillsFieldList.add(new SkillFields('Advanced_Certitfications_Analysis__c','Advanced_Certifications_Weightage__c','Advanced_Certifications_Score__c','Additional_Certifications__c','Missing_Certifications_Additional__c'));
        skillsFieldList.add(new SkillFields('Verticals_Analysis__c','Verticals_Weightage__c','Verticals_Score__c','Verticals__c','Missing_Verticals__c'));
        Job_Role__c jobRole=[SELECT Id, Advanced_Certifications_Weightage__c, Essential_Tools_Weightage__c, Essential_Tech_Skills_Weightage__c, Essential_Certifications_Weightage__c, Advanced_Tools_Weightage__c, Advanced_Administration_Skills_Weightage__c, Essential_Administration_Skill_Weightage__c, Advanced_Tech_Skills_Weightage__c,Salesforce_Clouds_Weightage__c,Verticals_Weightage__c FROM Job_Role__c WHERE Id=:jobRoleId LIMIT 1];
        Decimal overallScore=0;
        for(SkillFields skill : skillsFieldList)
        {
            String skillsFoundField=skill.skillsFoundField;
            String skillsWieghtageField=skill.skillsWieghtageField;
            String skillsFound=String.valueOf(resumeAnalysisRecord.get(skillsFoundField));
            
            if(resumeAnalysisRecord.get(skillsFoundField)!=null && skillsFound.split(';')!=null && skillsFound.split(';').size()>0 && jobRole.get(skillsWieghtageField)!=null)
            { 
                Decimal skillsWeightage=Decimal.valueOf(String.valueOf(jobRole.get(skillsWieghtageField)));
                Decimal totalSkillsCount=skillsFound.split(';').size();
                Decimal skillsNotFoundCount=skillsFound.countMatches('Not Found');
                Decimal skillsFoundCount=totalSkillsCount-skillsNotFoundCount;
                Decimal skillScore=((skillsFoundCount/totalSkillsCount)*skillsWeightage).setScale(2);
                resumeAnalysisRecord.put(skill.skillsScoreField,String.valueOf(skillScore));
                overallScore=overallScore+skillScore;
                System.debug(skill.skillsScoreField+'--'+skillScore);
            }
            else
            {
                resumeAnalysisRecord.put(skill.skillsScoreField,'0');
                System.debug(skill.skillsScoreField+'--'+'0');
            }
        }
        resumeAnalysisRecord.put('Overall_Score__c',overallScore);
        System.debug('Overall_Score__c--'+overallScore);
       	System.debug('resumeAnalysisRecord--'+resumeAnalysisRecord);
    }
    
    public class SkillFields
    {
        public String skillsFoundField{get;set;}
        public String skillsWieghtageField{get;set;}
        public String skillsScoreField{get;set;}
        public String skillsField{get;set;}
        public String skillsNotFoundField{get;set;}
        
        SkillFields(String skillsFoundField,String skillsWieghtageField,String skillsScoreField,String skillsField,String skillsNotFoundField)
        {
            this.skillsFoundField=skillsFoundField;
            this.skillsWieghtageField=skillsWieghtageField;
            this.skillsScoreField=skillsScoreField;
            this.skillsField=skillsField;
            this.skillsNotFoundField=skillsNotFoundField;
        } 
    }

    /**This method used to send request to openai to analyze resume based on prompts
      * @param {Prompt__c} prompt - prompt record.
      * @param {sObject} resumeAnalysisRecord - Instance of an Job Application Insights Object.
      * @param {String} resumeText - plain text of the resume.
      * @author Manoj
      * @since Dec 07 2023
      */
    public static String promptRequest(Prompt__c prompt,sObject resumeAnalysisRecord,String resumeText,Position__c resourceReqRecord)
    {  
        if(credentials?.Open_Ai_Api_Key__c==null)
        {
            throw new CustomException('OpenAi api key is missing!');
        }
        String promptContent=prompt.Prompt_Content__c;
        //promptContent=promptContent.replace('{CurrentDate}', System.now().format('MMM yyyy'));
        promptContent=replaceDynamicValues(promptContent,0,resourceReqRecord);
        System.debug('promptContent--'+promptContent);
        String promptResponseFormat=prompt.Prompt_Response_Format__c;
        String finalPrompt=promptContent+''+promptResponseFormat+'\n'+resumeText;
        finalPrompt=finalPrompt.remove('"').replaceAll('\r','').replaceAll('\n','');

        String logFileBody=prompt.Name+'\n\n'+'Request : '+finalPrompt+'\n\n';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://api.openai.com/v1/chat/completions');
        request.setMethod('POST');
        request.setHeader('Authorization','Bearer '+credentials.Open_Ai_Api_Key__c);
        request.setHeader('Content-Type', 'application/json');
        String requestBody='{'+
            //'"model": "gpt-3.5-turbo",'+
            '"model": "gpt-4-1106-preview",'+
            '"messages": ['+
            '{'+
            '"role": "user",'+
            '"content": "'+finalPrompt+'"'+
            '}'+
            ']'+
            '}';
        request.setBody(requestBody);
        System.debug('requestBody--'+requestBody);
        request.setTimeout(2 * 60 * 1000);
        HttpResponse response = http.send(request);
        System.debug('Response-'+response.getBody());
        if(response.getStatusCode() == 200) {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            System.debug('results - '+results);
            String choicesJSON = JSON.serialize(((List<Object>)results.get('choices'))[0]);
            Map<String, Object> choiceMap = (Map<String, Object>) JSON.deserializeUntyped(choicesJSON);
            String messageJSON = JSON.serialize(choiceMap.get('message'));
            Map<String, Object> messageMap = (Map<String, Object>) JSON.deserializeUntyped(messageJSON);
            System.debug('chatgpt result content--'+String.valueOf(messageMap.get('content')));
            String contentString=String.valueOf(messageMap.get('content'));
            logFileBody=logFileBody+'Response : '+contentString+'\n\n';
            logFileBodyGlobal=logFileBodyGlobal+logFileBody;
            contentString=contentString.removeStart('```json').replaceAll('\r','').replaceAll('\n','').removeEnd('```');
            formatPromptResponse(promptResponseFormat,contentString,resumeAnalysisRecord);
            return logFileBody;
        }
        else 
        {
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String errorJSON = JSON.serialize(((Map<String, Object>)results.get('error')));
            Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(errorJSON);
            String errorMessage = String.valueOf(errorMap.get('message'));
            throw new CustomException(errorMessage); 
        }
        //return response.getBody();
    }

    public static void formatPromptResponse(String request,String response,sObject resumeAnalysisRecord)
    {
        System.debug('Request--'+request);
        System.debug('Response--'+response);
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(request);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);
        for(String requestKey : requestMap.keySet())
        {
            String eachFieldApiNameString=JSON.serialize(requestMap.get(requestKey));
            Map<String,Object> eachFieldApiName=(Map<String,Object>) JSON.deserializeUntyped(eachFieldApiNameString);
            String fieldApiName=String.valueOf(eachFieldApiName.get('value'));
            System.debug('testTotal fieldApiName - '+fieldApiName);
            String eachFieldValueString=JSON.serialize(responseMap.get(requestKey));
            Map<String,Object> eachFieldValue=(Map<String,Object>) JSON.deserializeUntyped(eachFieldValueString);
        	System.debug('testTotal eachFieldValueString - '+eachFieldValueString);
            addFieldValue(resumeAnalysisRecord,eachFieldValue,fieldApiName);
        }
        
    }
    
    public static void addFieldValue(sObject resumeAnalysisRecord,Map<String,Object> eachFieldValue,String fieldApiName)
    {
        if(eachFieldValue!=null)
        {
            System.debug('eachFieldValue-'+eachFieldValue);
            System.debug('fieldApiName-'+fieldApiName);
            if(String.valueOf(eachFieldValue.get('type'))=='List<String>')
                resumeAnalysisRecord.put(fieldApiName,String.join((List<Object>)(eachFieldValue.get('value')),';'));
            else
                resumeAnalysisRecord.put(fieldApiName,eachFieldValue.get('value')); 
        }     
    }

    /**This method used to convert JSON resume to plain text
      * @param {String} jsonText - JSON version of the resume.
      * @return {String} Plain text of the resume
      * @author Manoj
      * @since Dec 07 2023
      */
    public static string convertJSONtoText(String jsonText)
    {
        String text='';
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(jsonText);
        List<Object> choicesList=(List<Object>)results.get('elements');
        for(Object obj : choicesList)
        {
            Map<String, Object> objMap=(Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
            if(objMap.get('Text')!=null)
            text=text+String.valueOf(objMap.get('Text'))+'\n';
        }
        return text;
    }
    
    /**This method used to get related files of the job application
      * @param {String} jobApplicationRecordId - The Job Application record id.
      * @return {List<FilesWrapper>} related files of the job application
      * @author Manoj
      * @since Dec 07 2023
      */
    @AuraEnabled
    public static List<FilesWrapper> getRelatedFiles(String jobApplicationRecordId)
    {
        try{
            if([SELECT Id FROM Job_Application_Analysis__c WHERE Job_Application__c=:jobApplicationRecordId].size()>0)
            {
                throw new CustomException('This application is already analyzed.');
            }
            List<FilesWrapper> listFiles=new List<FilesWrapper>();
            for(ContentDocumentLink cdl : [SELECT Id, LinkedEntityId, ContentDocumentId,ContentDocument.Title,ContentDocument.LastModifiedDate FROM ContentDocumentLink where LinkedEntityId = :jobApplicationRecordId])
            {
                FilesWrapper fw=new FilesWrapper();
                fw.Id=cdl.ContentDocumentId;
                fw.Title=cdl.ContentDocument.Title;
                fw.lastModifiedDate=formatDate(cdl.ContentDocument.LastModifiedDate);
                fw.selected=false;
                listFiles.add(fw);
            }
            return listFiles;

        }
        Catch(Exception e)
        {
            System.debug('Error in PdfParser class, getRelatedFiles method.');
            System.debug('Error Message - '+e.getMessage());
            System.debug('Error Line number-'+e.getLineNumber());
            System.debug('Error Stack Trace-'+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        } 
        
    }

    /**This method used to notify users on the error
      * @param {String} jobApplicationRecordId - The Job Application record id.
      * @param {String} logId - Log record id.
      * @author Manoj
      * @since Dec 07 2023
      */
    public static void errorEmail(String jobApplicationRecordId,String logId)
    {
        Job_Application__c jobApp=[SELECT Id,Candidate__r.First_Name__c,Candidate__r.Last_Name__c FROM Job_Application__c WHERE Id=:jobApplicationRecordId LIMIT 1];
        Log__c errorLog=[SELECT Id,Name,Method_Name__c,Class_Name__c,Line_Number__c,Reason__c FROM Log__c WHERE Id=:logId LIMIT 1];
        String jobApplicationInsightUrl=credentials.CRMIT_Community_Base_URL__c+'/CRMITCommunity/s/job-application/'+jobApplicationRecordId;
        String htmlBody='<p>Hi '+UserInfo.getFirstName()+' '+UserInfo.getLastName()+',</p>'+
                        '<p>Error occured while processing the Resume Analysis for <a href="'+jobApplicationInsightUrl+'">'+jobApp.Candidate__r.First_Name__c+' '+jobApp.Candidate__r.Last_Name__c+'</a>.</p>'+
                        '<p><b>Error Details</b></p>'+
                        '<p style="padding-left:20px"><ol><li>Error Message - '+errorLog.Reason__c+'</li>'+
                        '<li>Error Log Id - '+errorLog.Id+'</li></ol></p><br/>'+
                        '<p>Thanks</p>';
        Messaging.SingleEmailMessage[] mailList=new Messaging.SingleEmailMessage[]{};    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Error Occured in Resume Analysis');
        mail.setHtmlBody(htmlBody);
        mail.setSaveAsActivity(false);
        mail.setToAddresses(new list<string>{UserInfo.getUserEmail()});
        mail.setCcAddresses(new list<string>{'manoj.mahadevaswamy@crmit.com','mudit.sharma@crmit.com'});
        mail.setUseSignature(false);
        mailList.add(mail);    
        Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(mailList); 
    }

    /**This method used to notify users on the completion of pdf parsing
      * @param {String} jobApplicationRecordId - The Job Application record id.
      * @param {String} targetId - Job Application Insights record id.
      * @author Manoj
      * @since Dec 07 2023
      */
    public static void notifyUsers(String targetId,String jobApplicationRecordId) {
        Job_Application__c jobApp=[SELECT Id,Candidate__r.First_Name__c,Candidate__r.Last_Name__c FROM Job_Application__c WHERE Id=:jobApplicationRecordId LIMIT 1];
        String jobApplicationUrl=credentials.CRMIT_Community_Base_URL__c+'/CRMITCommunity/s/job-application/'+jobApplicationRecordId;
        String htmlBody='<p>Hi '+UserInfo.getFirstName()+' '+UserInfo.getLastName()+',</p>'+
                        '<p>Resume Analysis completed for <a href="'+jobApplicationUrl+'">'+jobApp.Candidate__r.First_Name__c+' '+jobApp.Candidate__r.Last_Name__c+'</a>.</p>'+
                        '<p>Thanks</p>';

        Messaging.SingleEmailMessage[] mailList=new Messaging.SingleEmailMessage[]{};    
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Resume Analysis Completion');
        mail.setHtmlBody(htmlBody);
        mail.setSaveAsActivity(false);
        mail.setToAddresses(new list<string>{UserInfo.getUserEmail()});
        mail.setCcAddresses(new list<string>{'manoj.mahadevaswamy@crmit.com','mudit.sharma@crmit.com'});
        mail.setUseSignature(false);
        mailList.add(mail);    
        Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(mailList); 

        /* CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='Resume_Analyzer' LIMIT 1];   
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle('Resume Analysis Completion');
        String notificationBody='Resume Analysis completed for '+jobApp.Candidate__r.First_Name__c+' '+jobApp.Candidate__r.Last_Name__c+'.';
        notification.setBody(notificationBody);
        notification.setNotificationTypeId(notificationType.Id);
        notification.setTargetId(targetId);
        try {
            notification.send(new Set<String>{UserInfo.getUserId()});
            System.debug('Notification Sent-'+UserInfo.getUserId());
        }
        catch (Exception e) {
            System.debug('Problem sending notification: ' + e.getMessage());
        } */
    }

    /**This method used to handle Ask a question
      * @param {String} jobApplicationRecordId - The Job Application record id.
      * @param {String} promptMessage - user's prompt
      * @return {String} returns an openai gpt response
      * @author Manoj
      * @since Dec 07 2023
      */
    @AuraEnabled
    public static String userPrompt(String promptMessage,String recordId,String insightRecordId)
    {
        try
        {
            if(credentials?.Open_Ai_Api_Key__c==null)
            {
                throw new CustomException('OpenAi api key is missing!');
            }
            String jobApplicationRecordId='';
            String jobApplicationPrefix = Schema.getGlobalDescribe().get('Job_Application__c').getDescribe().getKeyPrefix();
            String interviewPrefix = Schema.getGlobalDescribe().get('Review__c').getDescribe().getKeyPrefix();
            if (recordId != null && recordId.startsWithIgnoreCase(interviewPrefix)) 
            {
                Review__c interviewRecord=[SELECT Id,Job_Application__c FROM Review__c WHERE Id=:recordId LIMIT 1];
                jobApplicationRecordId= interviewRecord.Job_Application__c;
            }
            else
            {
                jobApplicationRecordId=recordId;
            }
            Job_Application__c jobApp=[SELECT Id,Number_of_Questions_Asked__c FROM Job_Application__c WHERE Id=:jobApplicationRecordId LIMIT 1];
            Job_Application_Analysis__c jaa=[SELECT Id,Number_of_Questions_Asked__c FROM Job_Application_Analysis__c WHERE Id=:insightRecordId LIMIT 1];
            Integer askQuestionLimit=(credentials?.Ask_Question_Limit__c!=null)?(Integer)credentials.Ask_Question_Limit__c:20;
            if(jaa.Number_of_Questions_Asked__c!=null && jaa.Number_of_Questions_Asked__c >= askQuestionLimit)
            {
                throw new CustomException('You have exceeded the limit of '+askQuestionLimit+' questions for this resume.');
            }
            List<Attachment> listAtt=[Select Body From Attachment where parentId=:jobApplicationRecordId and Name LIKE 'PlainText_%' Order by Createddate DESC limit 1];
            if(listAtt==null || listAtt.size()==0)
            {
                throw new CustomException('No Resume Plain Text attachment found.');
            }
            String resumeText = listAtt[0].Body.toString();
            String finalPrompt='Given this CV: '+ resumeText + 'answer this question in 100 words: ' + promptMessage + 'If the question is missing, improper, or irrelevant, return:' + 
                'Ask me anything about this Candidate like their experience with a specific tool, their experience with project management, or their experience with various coding langauges for example.';  

            finalPrompt=finalPrompt.remove('"').replaceAll('\r','').replaceAll('\n',''); 
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://api.openai.com/v1/chat/completions');
            request.setMethod('POST');
            request.setHeader('Authorization','Bearer '+credentials.Open_Ai_Api_Key__c);
            request.setHeader('Content-Type', 'application/json');
            String requestBody='{'+
                //'"model": "gpt-3.5-turbo",'+
                '"model": "gpt-4-1106-preview",'+
                '"messages": ['+
                '{'+
                '"role": "user",'+
                '"content": "'+finalPrompt+'"'+
                '}'+
                ']'+
                '}';
            request.setBody(requestBody);
            request.setTimeout(2 * 60 * 1000);
            HttpResponse response = http.send(request);
            System.debug('responseBody-'+response.getBody());
            if(response.getStatusCode() == 200) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                String choicesJSON = JSON.serialize(((List<Object>)results.get('choices'))[0]);
                Map<String, Object> choiceMap = (Map<String, Object>) JSON.deserializeUntyped(choicesJSON);
                String messageJSON = JSON.serialize(choiceMap.get('message'));
                Map<String, Object> messageMap = (Map<String, Object>) JSON.deserializeUntyped(messageJSON);
                String contentString=String.valueOf(messageMap.get('content'));
                contentString=contentString.removeStart('```json').removeEnd('```');
                jaa.Number_of_Questions_Asked__c=(jaa.Number_of_Questions_Asked__c!=null)?(jaa.Number_of_Questions_Asked__c+1):1;
                update jaa;
                jobApp.Number_of_Questions_Asked__c=(jobApp.Number_of_Questions_Asked__c!=null)?(jobApp.Number_of_Questions_Asked__c+1):1;
                update jobApp;
                return contentString;
            }
            else
            {
                throw new CustomException('Error occured. Status code - '+response.getStatusCode()); 
            } 
        }
        Catch(Exception e)
        {
            System.debug('Error in PdfParser class, userPrompt method.');
            System.debug('Error Message - '+e.getMessage());
            System.debug('Error Line number-'+e.getLineNumber());
            System.debug('Error Stack Trace-'+e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public static void updateJobApplication(String jobApplicationRecordId)
    {
        Job_Application__c jobApplicationRecord=new Job_Application__c();
        jobApplicationRecord.Id=jobApplicationRecordId;
        jobApplicationRecord.Resume_Uploaded_to_G_Drive__c=false;
        jobApplicationRecord.GDrive_Resume__c=null;
        jobApplicationRecord.GDrive_Resume_URL__c=null;
        update jobApplicationRecord;
    }
    public static String formatDate(DateTime inputDate)
    {
        return inputDate.format('MMM dd, yyyy');
    }

    public class FilesWrapper
    {
        @AuraEnabled
        public String Id{get;set;}
        @AuraEnabled
        public String Title{get;set;}
        @AuraEnabled
        public String lastModifiedDate{get;set;}
        @AuraEnabled
        public Boolean selected{get;set;}
    } 

}