public with sharing class GoogleDriveController {

    // Named Credential name configured in Salesforce
    private static final String GOOGLE_DRIVE_NAMED_CREDENTIAL = 'Google_Drive';

    // Google Drive API endpoint for file upload
    private static final String GOOGLE_DRIVE_UPLOAD_URL = '/drive/v3/files';

    // Method to upload a file to Google Drive
    @AuraEnabled
    public static void uploadFileToGoogleDrive(String fileName, String base64FileContent) {
        Blob fileBody = EncodingUtil.base64Decode(base64FileContent);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(getEndpointWithQueryParams(GOOGLE_DRIVE_UPLOAD_URL));
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + getAccessToken());
        req.setHeader('Content-Type', 'application/json');

        // Create the file metadata JSON with the parent folder ID
        String bodyJson = '{' +
                            '"name": "' + fileName + '",' +
                            '"parents": ["YOUR_PARENT_FOLDER_ID_HERE"]' +
                          '}';
        req.setBody(bodyJson);

        req.setBodyAsBlob(fileBody);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            System.debug('File uploaded successfully to Google Drive.');
            // Handle success
        } else {
            System.debug('Error uploading file to Google Drive: ' + res.getBody());
            // Handle error
        }
    }

    // Helper method to get endpoint with query params
    private static String getEndpointWithQueryParams(String endpoint) {
        return 'callout:' + GOOGLE_DRIVE_NAMED_CREDENTIAL + '/services/data' + endpoint;
    }

    // Helper method to get OAuth access token using Named Credential
    private static String getAccessToken() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:' + GOOGLE_DRIVE_NAMED_CREDENTIAL + '/services/oauth2/token');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type=refresh_token');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) responseMap.get('access_token');
        } else {
            System.debug('Error getting access token from Google Drive: ' + res.getBody());
            // Handle error
            return null;
        }
    }
}