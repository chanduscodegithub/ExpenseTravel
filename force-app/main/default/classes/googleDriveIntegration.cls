public class googleDriveIntegration {     

    public static GoogleDriveTokens__c googleTokenSettings = GoogleDriveTokens__c.getInstance('GoogleTokenRecord');
    String accesstoken ;
    private static final String GOOGLE_DRIVE_API_ENDPOINT = 'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart&supportsAllDrives=true';
    
     public static void uploadFileS(String contentDocId) {
        ContentVersion cv = [SELECT Id, Title, VersionData,FileType FROM ContentVersion WHERE ContentDocumentId =: contentDocId];
        String folderId = googleTokenSettings.FolderId__c;
    	String fileName = cv.Title;
    	String fileType = cv.FileType;
        String body = '--foo_bar_baz\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n {\r\n"name":'+'"'+fileName+'",'+'\r\n"parents":'+'["'+folderId+'"]}\r\n\r\n--foo_bar_baz\r\nContent-Transfer-Encoding: base64\r\nContent-Type:'+MIMEHelper.getMIMEType(fileType)+'\r\n\r\n' + EncodingUtil.base64Encode(cv.VersionData) + '\r\n--foo_bar_baz--';
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String accessToken = googleTokenSettings.AccessToken__c;
        request.setEndpoint(GOOGLE_DRIVE_API_ENDPOINT);
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'multipart/related; boundary=foo_bar_baz');
        request.setHeader('Content-Length', Blob.valueOf(body).size() + '');
        request.setHeader('supportsAllDrives','true');
        request.setMethod('POST');
        request.setBody(body);
        HttpResponse response = new HttpResponse();
        response = http.send(request);
        system.debug('>>>>response body'+response.getBody());
    }
}