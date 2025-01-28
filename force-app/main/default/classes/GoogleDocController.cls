public class GoogleDocController {
    @AuraEnabled
    public static String replaceVariablesAndDownload(String recordId, String documentId) {
        try {
            // Fetch the record details from Salesforce
            SObject record = Database.query(
                'SELECT Candidate_Name__c, Date__c, Candidate_Email__c, Salary__c, Address__c, Designation__c FROM Offer_Letter__c WHERE Id = :recordId'
            );

            // Prepare placeholders and their values
            Map<String, String> variables = new Map<String, String> {
                'CandidateName' => (String) record.get('Candidate_Name__c'),
                'Date' => String.valueOf(record.get('Date__c')),
                'Email' => (String) record.get('Candidate_Email__c'),
                'Salary' => String.valueOf(record.get('Salary__c')),
                'Address' => (String) record.get('Address__c'),
                'Designation' => (String) record.get('Designation__c')
            };

            // 1. Duplicate the Google Doc template
            String duplicateId = GoogleDriveIntegrationNew.createDuplicateTemplate(documentId);
            System.debug('Duplicated Document ID: ' + duplicateId);

            // Instantiate the Http class
            Http http = new Http();

            // 2. Replace variables in the duplicated document (Batch request optimization)
            List<Map<String, Object>> replaceRequests = new List<Map<String, Object>>();
            for (String key : variables.keySet()) {
                replaceRequests.add(new Map<String, Object> {
                    'replaceAllText' => new Map<String, Object> {
                        'containsText' => new Map<String, Object> {'text' => '<<' + key + '>>', 'matchCase' => true},
                        'replaceText' => variables.get(key)
                    }
                });
            }
			String replaceEndpoint = 'callout:GoogleAPI/v1/documents/' + duplicateId + ':batchUpdate';
			HttpRequest replaceReq = new HttpRequest();
			replaceReq.setEndpoint(replaceEndpoint);
			replaceReq.setMethod('POST');
			replaceReq.setHeader('Content-Type', 'application/json');
			replaceReq.setBody(JSON.serialize(new Map<String, Object> {
				'requests' => replaceRequests
			}));

			HttpResponse replaceRes = http.send(replaceReq);
			System.debug('Replace Response Status: ' + replaceRes.getStatusCode());
			System.debug('Replace Response Body: ' + replaceRes.getBody());

			if (replaceRes.getStatusCode() != 200) {
				throw new AuraHandledException('Failed to replace variables: ' + replaceRes.getBody());
			}

            // Return the exported file content as Base64
            String base64EncodedFile = GoogleDriveIntegrationNew.exportGoogleDocAsPdf(duplicateId);
			
			// 4. Delete the duplicated file from Google Drive after downloading
            GoogleDriveIntegrationNew.deleteFileFromDrive(duplicateId);
			return base64EncodedFile;

        } catch (Exception e) {
            // Handle any unexpected errors
            throw new AuraHandledException('Error occurred: ' + e.getMessage());
        }
    }

	@AuraEnabled
	public static String sendEmailWithAttachment(String recordId,String documentId) {
		try {
			System.debug('recordId'+recordId+'documentId'+documentId);
			// Generate the PDF
			String base64EncodedFile = replaceVariablesAndDownload(recordId,documentId);

			// Fetch recipient email from the record
			SObject record = Database.query(
				'SELECT Candidate_Email__c FROM Offer_Letter__c WHERE Id = :recordId'
			);
			String emailAddress = (String) record.get('Candidate_Email__c');

			// Create an email attachment
			Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
			attachment.setFileName('Offer_Letter.pdf');
			attachment.setBody(EncodingUtil.base64Decode(base64EncodedFile));
			attachment.setContentType('application/pdf');

			// Send email with the attachment
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(new String[] {emailAddress});
			mail.setSubject('Your Offer Letter');
			mail.setPlainTextBody('Dear Candidate,\n\nPlease find your offer letter attached.\n\nBest regards,\nYour Company');
			mail.setFileAttachments(new Messaging.EmailFileAttachment[] {attachment});

			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
			return 'Email sent successfully';
		} catch (Exception e) {
			System.debug('Error during email sending: ' + e.getMessage());
			throw new AuraHandledException('Error sending email with attachment: ' + e.getMessage());
		}
	}

}