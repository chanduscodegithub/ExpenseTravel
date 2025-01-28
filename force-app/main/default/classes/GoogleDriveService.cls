public class GoogleDriveService {
    private static final String API_KEY = '373274262289-95aaam7lbgk45b2pmg3jqd5b9kn8qmv9.apps.googleusercontent.com';
    private static final String FOLDER_ID = '1aOXMUYXPvMeDHADrJqztI7nOVzlADhTK';
    
    @AuraEnabled(cacheable=true)
    public static List<String> listFilesInFolder() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://www.googleapis.com/drive/v3/files?q=\'' + FOLDER_ID + '\'+in+parents&key=' + API_KEY);
        req.setMethod('GET');
        req.setHeader('Accept', 'application/json');

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> files = (List<Object>) result.get('files');
            List<String> fileUrls = new List<String>();
            for (Object file : files) {
                Map<String, Object> fileInfo = (Map<String, Object>) file;
                String fileId = (String) fileInfo.get('id');
                String fileUrl = 'https://drive.google.com/uc?export=download&id=' + fileId;
                fileUrls.add(fileUrl);
            }
            return fileUrls;
        } else {
            throw new FileRetrievalException('Failed to list files from Google Drive');
        }
    }

    public class FileRetrievalException extends Exception {}
}