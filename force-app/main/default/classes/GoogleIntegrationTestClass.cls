@isTest
public class GoogleIntegrationTestClass {
 //Test For googleAuthService
    @isTest
    public static void testCreateAuthURL() {
        // Create a mock instance of GoogleDriveTokens__c
        GoogleDriveTokens__c mockToken = new GoogleDriveTokens__c(
            Name = 'GoogleTokenRecord',
            Client_Key__c = 'MockClientKey',
            Client_Secret__c = 'MockClientSecret'
            // Add other required fields as needed
        );
        // Insert the mock instance
        insert mockToken;

        // Use System.runAs to ensure the test runs with proper permissions
        System.runAs(new User(Id = UserInfo.getUserId())) {
            Test.startTest();
            // Assign the mock data to the custom setting instance
            GoogleAuthService.googleToken = mockToken;

            // Call the method under test
            String authURL = GoogleAuthService.createAuthURL();

            Test.stopTest();

            // Add assertions to validate the generated authURL
            System.assertNotEquals(null, authURL, 'Auth URL should not be null');
            // Add more assertions as needed
        }
    }


@isTest
    public static void testGetAccessToken() {
        // Create mock data for GoogleDriveTokens__c
        GoogleDriveTokens__c mockToken = new GoogleDriveTokens__c(
            Name = 'GoogleTokenRecord',
            Client_Key__c = 'MockClientKey',
            Client_Secret__c = 'MockClientSecret'
            // Add other required fields as needed
        );
        insert mockToken;

        // Set up mock code for testing
        String mockCode = 'mockAuthorizationCode';

        // Set up mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        // Assign the mock data to the custom setting instance
        googleAuthService.googleToken = mockToken;

        // Call the method under test
        Boolean isAuthSaved = googleAuthService.getAccessToken(mockCode);
        Test.stopTest();

        // Add assertions based on the expected outcome of getAccessToken
        System.assertEquals(true, isAuthSaved, 'Auth should be saved successfully');
        // Verify other conditions based on your implementation
    }

   
    // Mock HTTP response generator
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock HTTP response
            HttpResponse res = new HttpResponse();
            res.setBody('{"access_token":"mockAccessToken","refresh_token":"mockRefreshToken"}');
            res.setStatusCode(200);
            return res;
        }
    }


  //Test For googleDriveIntegration
@isTest
    static void testUploadFileS() {
        // Create a ContentVersion record to be used in the test
       		ContentVersion file = new ContentVersion();
            file.Title = 'File Name';
            file.PathOnClient = 'file_' + Datetime.now().getTime() + '.txt';
            file.VersionData = Blob.valueOf('My Content in file_' + 
            Datetime.now().getTime() + '.txt');
            file.Origin = 'H';
            insert file; 
            
    List<ContentDocument> condocList = [SELECT Id,LatestPublishedVersionId from ContentDocument where LatestPublishedVersionId =: file.id limit 1];
        
        // Create a GoogleDriveTokens__c record
        GoogleDriveTokens__c testTokenSettings = new GoogleDriveTokens__c(
            Name = 'GoogleTokenRecord',
            AccessToken__c = 'MockAccessToken', // Replace with a mock access token
            FolderId__c = 'MockFolderId' // Replace with a mock folder ID
            // Add other necessary fields as needed
        );
        insert testTokenSettings;

        // Set the mock callout class
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        Test.startTest();
        // Call the method under test
        googleDriveIntegration.uploadFileS(condocList[0].Id);
        Test.stopTest();

        // Add assertions based on your requirements
        // For example, verify behavior or check if the response was handled appropriately
    }


 @isTest
    static void testGetMIMEType() {
        // Test null input
        String nullFileType = null;
        String nullMimeType = MIMEHelper.getMIMEType(nullFileType);
        System.assertEquals('application/octet-stream', nullMimeType, 'Null input should return default MIME type');

        // Test PDF file type
        String pdfFileType = 'pdf';
        String pdfMimeType = MIMEHelper.getMIMEType(pdfFileType);
        System.assertEquals('application/pdf', pdfMimeType, 'PDF file type should return correct MIME type');

        // Test JPEG file type
        String jpegFileType = 'jpeg';
        String jpegMimeType = MIMEHelper.getMIMEType(jpegFileType);
        System.assertEquals('image/jpeg', jpegMimeType, 'JPEG file type should return correct MIME type');

        // Test PNG file type
        String pngFileType = 'png';
        String pngMimeType = MIMEHelper.getMIMEType(pngFileType);
        System.assertEquals('image/png', pngMimeType, 'PNG file type should return correct MIME type');

        // Test Text file type
        String textFileType = 'text';
        String textMimeType = MIMEHelper.getMIMEType(textFileType);
        System.assertEquals('text/plain', textMimeType, 'Text file type should return correct MIME type');

        // Test Word file types
        String docxFileType = 'docx';
        String docxMimeType = MIMEHelper.getMIMEType(docxFileType);
        System.assertEquals('application/msword', docxMimeType, 'DOCX file type should return correct MIME type');

        String docFileType = 'doc';
        String docMimeType = MIMEHelper.getMIMEType(docFileType);
        System.assertEquals('application/msword', docMimeType, 'DOC file type should return correct MIME type');

        String wordFileType = 'WORD';
        String wordMimeType = MIMEHelper.getMIMEType(wordFileType);
        System.assertEquals('application/msword', wordMimeType, 'WORD file type should return correct MIME type');
		
        String csvFileType = 'csv';
        String csvMimeType = MIMEHelper.getMIMEType(csvFileType);
        System.assertEquals('text/csv', csvMimeType, 'csv file type should return correct MIME type');

		String excelFileType = 'EXCEL';
        String excelMimeType = MIMEHelper.getMIMEType(excelFileType);
        System.assertEquals('application/vnd.ms-excel', excelMimeType, 'EXCEL file type should return correct MIME type');

		String pptFileType = 'ppt';
        String pptMimeType = MIMEHelper.getMIMEType(pptFileType);
        System.assertEquals('application/vnd.ms-powerpoint', pptMimeType, 'ppt file type should return correct MIME type');

        

        String unknownFileType = 'randomType';
        String unknownMimeType = MIMEHelper.getMIMEType(unknownFileType);
        System.assertEquals('application/octet-stream', unknownMimeType, 'Unknown file type should return default MIME type');
    }
	

    }