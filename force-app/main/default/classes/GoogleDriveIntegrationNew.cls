public class GoogleDriveIntegrationNew {
    
    private static final String GOOGLE_DRIVE_API_ENDPOINT = 'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart&supportsAllDrives=true';
    private static final String GOOGLE_DRIVE_FOLDER_ENDPOINT = 'https://www.googleapis.com/drive/v3/files/';
    private static final String GOOGLE_REFRESH_TOKEN_ENDPOINT = 'https://oauth2.googleapis.com/token';

    @AuraEnabled
    public static GoogleDriveFile uploadFileToGoogleDrive(String fileName, String fileData, String agreementType, String vendorName,String consultantName,String region) {
        System.debug('This is fileName' + fileName + 'region is'+region+ ' And the file data is ' + fileData + ' Agreement Type: ' + agreementType + ' Vendor Name: ' + vendorName);
        GoogleDriveTokens__c googleTokenSettings = GoogleDriveTokens__c.getInstance('GoogleTokenRecord');
       
        Map<String, Map<String, String>> folderStructure = new Map<String, Map<String, String>>{
            'India' => new Map<String, String>{
                'Corp-to-Corp' => '17dcAfIQyqiL2NevCNOiaTCM3JZG6UA6w',
                'Independent' => '1O7dBIYjGsY_FOV_nOcPwlVNNTYHBJBTF'
            },
            'USA' => new Map<String, String>{
                'Corp-to-Corp' => '1A8agk_s0G_duGaF1KXCMCInMv2Jm7Et6',
                'Independent' => '1EwwtDlq9SBb7sBqnZurOMMvfYBypm9iP'
            },
            'Australia' => new Map<String, String>{
                'Corp-to-Corp' => '1Xpmca5m1sMjtuCgnP0QcE0tgf2rEh-7A',
                'Independent' => '1T3AzGNv-YTkOvE3MnEgPZ6XJ7YXxZcNv'
            }
        };

        // Check for valid region
        if (!folderStructure.containsKey(region)) {
            System.debug('folderStruc'+folderStructure.get(region));
            throw new IllegalArgumentException('Invalid region specified.');
        }

        Map<String, String> agreementFolders = folderStructure.get(region);
        String folderId;
        String CorpParentFolderId = agreementFolders.get('Corp-to-Corp');
        String IndependentParentFolderId = agreementFolders.get('Independent');

        if (agreementType == 'Corp-to-Corp') {
            folderId = getOrCreateVendorFolder(vendorName, getAccessToken(),CorpParentFolderId);
        } else {
            folderId = getOrCreateVendorFolder(consultantName, getAccessToken(),IndependentParentFolderId);
        }

        if (String.isEmpty(fileName) || String.isEmpty(fileData) || String.isEmpty(folderId)) {
            throw new IllegalArgumentException('File name, file data, and folder ID are required.');
        }

        try {
            return uploadFile(fileName, fileData, folderId, getAccessToken());
        } catch (CalloutException e) {
            if (e.getMessage().contains('401')) {
                System.debug('Access token expired, refreshing token and retrying upload');
                String newToken = refreshAccessToken();
                return uploadFile(fileName, fileData, folderId, newToken);
            } else {
                throw e;
            }
        }
    }

    @AuraEnabled
    public static String getPdfContent(String fileId) {
        fileId='1xLmE8Pt0Q0UPaP91A4RuoOOZDrLF9SSm';
        String newToken = refreshAccessToken();
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://www.googleapis.com/drive/v3/files/' + fileId + '?alt=media');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + newToken);

        Http http = new Http();
        HttpResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            return EncodingUtil.base64Encode(res.getBodyAsBlob());
        } 
        else {
            throw new AuraHandledException('Failed to fetch PDF content2: ' + res.getBody());
        }
    }

    private static String getOrCreateVendorFolder(String vendorName, String accessToken,String parentFolderId) {
        try {
            String vendorFolderId = findVendorFolder(vendorName, parentFolderId, accessToken);
            if (vendorFolderId == null) {
                vendorFolderId = createFolder(vendorName, parentFolderId, accessToken);
            }
            return vendorFolderId;
        } catch (Exception e) {
            if (e.getMessage().contains('401')) { 
                String newToken = refreshAccessToken();
                String vendorFolderId = findVendorFolder(vendorName, parentFolderId, newToken);
                if (vendorFolderId == null) {
                    vendorFolderId = createFolder(vendorName, parentFolderId, newToken);
                }
                return vendorFolderId;
            } else {
                throw new AuraHandledException('Error: ' + e.getMessage());
            }
        }
    }

    public static String createDuplicateTemplate(String fileId) {
        try {
            String accessToken = getAccessToken(); // Get the access token
            if (String.isEmpty(accessToken)) {
                throw new AuraHandledException('Access token is missing or invalid');
            }
            return duplicateTemplate(fileId, accessToken);
        } catch (CalloutException e) {
            // Log the exception for better debugging
            System.debug('CalloutException: ' + e.getMessage());

            // Handle token expiration (401 Unauthorized)
            if (e.getMessage().contains('401')) {
                System.debug('Access token expired, refreshing token and retrying fetch');
                String newToken = refreshAccessToken(); // Refresh the access token
                if (String.isEmpty(newToken)) {
                    throw new AuraHandledException('Failed to refresh access token');
                }
                return duplicateTemplate(fileId, newToken); // Retry fetching with the new token
            } else {
                throw e; // Re-throw the exception if it's not token-related
            }
        }
    }

    private static String duplicateTemplate(String documentId, String accessToken) {
        try {
            // Endpoint to duplicate the file on Google Drive
            String duplicateEndpoint = 'https://www.googleapis.com/drive/v3/files/' + documentId + '/copy';

            // Create the HTTP request to duplicate the template
            HttpRequest duplicateReq = new HttpRequest();
            duplicateReq.setEndpoint(duplicateEndpoint);
            duplicateReq.setMethod('POST');
            duplicateReq.setHeader('Authorization', 'Bearer ' + accessToken); // Adding OAuth access token
            duplicateReq.setHeader('Content-Type', 'application/json');
            duplicateReq.setBody(JSON.serialize(new Map<String, String>{ 'name' => 'UpdatedDocument' }));

            // Send the HTTP request
            Http http = new Http();
            HttpResponse duplicateRes = http.send(duplicateReq);

            // Debug response details
            System.debug('Response Status: ' + duplicateRes.getStatusCode());
            System.debug('Response Body: ' + duplicateRes.getBody());

            // Handle specific status codes
            if (duplicateRes.getStatusCode() == 401) {
                System.debug('Received 401 Unauthorized. Access token might have expired.');
                throw new CalloutException('401 Unauthorized');
            } else if (duplicateRes.getStatusCode() != 200) {
                System.debug('Received an unexpected status code: ' + duplicateRes.getStatusCode());
                throw new AuraHandledException('Failed to duplicate template: ' + duplicateRes.getBody());
            }

            // Parse the response to get the duplicated file ID
            Map<String, Object> duplicateResponse = (Map<String, Object>) JSON.deserializeUntyped(duplicateRes.getBody());
            String duplicateId = (String) duplicateResponse.get('id');
            System.debug('Duplicate ID: ' + duplicateId);

            // Return the ID of the duplicated file
            return duplicateId;

        } catch (CalloutException e) {
            System.debug('CalloutException: ' + e.getMessage());
            throw e; // Re-throw CalloutException
        } catch (Exception e) {
            System.debug('General Exception: ' + e.getMessage());
            throw new AuraHandledException('Error duplicating template: ' + e.getMessage());
        }
    }

    // Method to export Google Doc as PDF and return Base64-encoded content
    public static String exportGoogleDocAsPdf(String duplicateId) {
        try {
            // Get the access token
            String accessToken = getAccessToken();
            if (String.isEmpty(accessToken)) {
                throw new AuraHandledException('Access token is missing or invalid');
            }

            // Call method to export the document as PDF
            return exportDocumentAsPdf(duplicateId, accessToken);
        } catch (CalloutException e) {
            // Log the exception for better debugging
            System.debug('CalloutException: ' + e.getMessage());

            // Handle token expiration (401 Unauthorized)
            if (e.getMessage().contains('401')) {
                System.debug('Access token expired, refreshing token and retrying export');
                // Refresh the access token
                String newToken = refreshAccessToken();
                if (String.isEmpty(newToken)) {
                    throw new AuraHandledException('Failed to refresh access token');
                }
                // Retry the export operation with the new token
                return exportDocumentAsPdf(duplicateId, newToken);
            } else {
                // Re-throw other exceptions if it's not token-related
                throw e;
            }
        }
    }

    // Method to export the document as PDF and return Base64-encoded content
    private static String exportDocumentAsPdf(String duplicateId, String accessToken) {
        try {
            // Construct the endpoint to export the document as PDF
            String exportEndpoint = 'https://www.googleapis.com/drive/v3/files/' + duplicateId + '/export?mimeType=application/pdf';

            // Prepare the HTTP request
            HttpRequest exportReq = new HttpRequest();
            exportReq.setEndpoint(exportEndpoint);
            exportReq.setMethod('GET');
            exportReq.setHeader('Authorization', 'Bearer ' + accessToken); // Add the authorization header

            // Send the HTTP request
            Http http = new Http();
            HttpResponse exportRes = http.send(exportReq);

            // Debugging the response status
            System.debug('Export Response Status: ' + exportRes.getStatusCode());

            // Check for successful export (status code 200)
            if (exportRes.getStatusCode() == 200) {
                // Return the exported file content as Base64 encoding
                return EncodingUtil.base64Encode(exportRes.getBodyAsBlob());
            } else {
                // Throw an exception if the export failed
                throw new AuraHandledException('Failed to export document: ' + exportRes.getBody());
            }
        } catch (CalloutException e) {
            // Log and re-throw CalloutException
            System.debug('CalloutException: ' + e.getMessage());
            throw e;
        } catch (Exception e) {
            // Handle other exceptions
            System.debug('General Exception: ' + e.getMessage());
            throw new AuraHandledException('Error exporting document: ' + e.getMessage());
        }
    }
   
    // Method to delete the file from Google Drive
    @AuraEnabled
    public static void deleteFileFromDrive(String fileId) {
        try {
            System.debug('FileId is'+fileId);
            // Construct the endpoint to delete the file
            String deleteEndpoint = 'https://www.googleapis.com/drive/v3/files/' + fileId;

            // Create the HTTP request to delete the file
            HttpRequest deleteReq = new HttpRequest();
            deleteReq.setEndpoint(deleteEndpoint);
            deleteReq.setMethod('DELETE');
            deleteReq.setHeader('Authorization', 'Bearer ' + getAccessToken()); // Use the current access token

            // Send the DELETE request
            Http http = new Http();
            HttpResponse deleteRes = http.send(deleteReq);

            // Check if the deletion was successful (status code 204)
            if (deleteRes.getStatusCode() == 204) {
                System.debug('File deleted successfully from Drive: ' + fileId);
            } else if (deleteRes.getStatusCode() == 401) {
                // If 401 Unauthorized, refresh the access token and retry the request
                System.debug('Received 401 Unauthorized. Access token might have expired. Refreshing token and retrying delete.');
                
                // Refresh the access token
                String newAccessToken = refreshAccessToken();
                if (String.isEmpty(newAccessToken)) {
                    throw new AuraHandledException('Failed to refresh access token');
                }

                // Retry the delete request with the new access token
                deleteReq.setHeader('Authorization', 'Bearer ' + newAccessToken);
                deleteRes = http.send(deleteReq);

                // Check again for successful deletion after retry
                if (deleteRes.getStatusCode() == 204) {
                    System.debug('File deleted successfully from Drive after refreshing token: ' + fileId);
                } else {
                    System.debug('Failed to delete the file after refreshing token: ' + deleteRes.getBody());
                    throw new AuraHandledException('Failed to delete the file after refreshing token: ' + deleteRes.getBody());
                }
            } else {
                // Handle other failure cases
                System.debug('Failed to delete the file from Drive: ' + deleteRes.getBody());
                throw new AuraHandledException('Failed to delete the file from Drive: ' + deleteRes.getBody());
            }
        } catch (CalloutException e) {
            // Log and re-throw CalloutException
            System.debug('CalloutException: ' + e.getMessage());
            throw e;
        } catch (Exception e) {
            // Handle other exceptions
            System.debug('General Exception: ' + e.getMessage());
            throw new AuraHandledException('Error deleting file from Drive: ' + e.getMessage());
        }
    }


    @AuraEnabled
    // Fetch template from Google Drive with handling for expired token
    public static Blob fetchTemplateFromDrive(String fileId) {
        try {
            String accessToken = getAccessToken(); // Get the access token
            return getDocxContent(fileId, accessToken);
        } catch (CalloutException e) {
            // Handle token expiration (401 Unauthorized)
            if (e.getMessage().contains('401')) {
                System.debug('Access token expired, refreshing token and retrying fetch');
                String newToken = refreshAccessToken(); // Refresh the access token
                return getDocxContent(fileId, newToken); // Retry fetching with the new token
            } else {
                throw e; // Re-throw the exception if it's not token-related
            }
        }
    }

    

    // Get the content of the DOCX file from Google Drive
    public static Blob getDocxContent(String fileId, String accessToken) {
        String endpoint = 'https://www.googleapis.com/drive/v3/files/' + fileId + '?alt=media';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);
        
        Http http = new Http();
        HttpResponse res = http.send(req);
        
        if (res.getStatusCode() == 200) {
            return res.getBodyAsBlob(); // Successfully retrieved the file
        } else {
            throw new AuraHandledException('Failed to fetch template from Google Drive: ' + res.getStatus());
        }
    }

    public static String findVendorFolder(String folderName, String parentFolderId, String accessToken) {
        // Build the search query
        String query = 'name = \'' + folderName + '\' and \'' + parentFolderId + '\' in parents and mimeType = \'application/vnd.google-apps.folder\' and trashed = false';
        String endpoint = GOOGLE_DRIVE_FOLDER_ENDPOINT + '?q=' + EncodingUtil.urlEncode(query, 'UTF-8') + '&fields=files(id,name)'+ '&supportsAllDrives=true&includeItemsFromAllDrives=true'; // Remove webViewLink, only request id and name

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> files = (List<Object>) jsonResponse.get('files');
            if (!files.isEmpty()) {
                Map<String, Object> file = (Map<String, Object>) files[0]; // Get the first matching folder
                system.debug('file: ' + file);

                // Get and return the folder ID
                String folderId = (String) file.get('id');
                if (folderId != null) {
                    return folderId;  // Return the folder ID
                } else {
                    throw new CalloutException('No ID found for the folder.');
                }
            }
        } else {
            throw new CalloutException('Failed to find folder: ' + response.getBody());
        }
        return null;
    }
@AuraEnabled
public static List<Map<String, String>> fetchFileNamesAndUrls(String folderId) {
    // Validate the folderId
    if (String.isEmpty(folderId)) {
        throw new CalloutException('Folder ID cannot be null or empty.');
    }

    System.debug('FolderId'+folderId);
    String query = '\'' + folderId + '\' in parents and trashed = false';
    String filesEndpoint = GOOGLE_DRIVE_FOLDER_ENDPOINT +
    '?q=' + EncodingUtil.urlEncode(query, 'UTF-8') +
    '&fields=files(id,name,webViewLink,mimeType,modifiedTime,description,version)&supportsAllDrives=true&includeItemsFromAllDrives=true';



    // Create an HTTP request
    HttpRequest filesRequest = new HttpRequest();
    filesRequest.setEndpoint(filesEndpoint);
    filesRequest.setHeader('Authorization', 'Bearer ' + refreshAccessToken());
    filesRequest.setMethod('GET');

    // Create an HTTP instance and send the request
    Http http = new Http();
    HttpResponse filesResponse = http.send(filesRequest);

    // Process the response
    if (filesResponse.getStatusCode() == 200) {
        Map<String, Object> filesResponseJson = (Map<String, Object>) JSON.deserializeUntyped(filesResponse.getBody());
        List<Object> filesList = (List<Object>) filesResponseJson.get('files');

        // Extract file names and URLs
        List<Map<String, String>> fileDetails = new List<Map<String, String>>();
        for (Object fileObj : filesList) {
            Map<String, Object> file = (Map<String, Object>) fileObj;

            // Prepare file details
            Map<String, String> fileDetail = new Map<String, String>();
            fileDetail.put('id', (String) file.get('id'));
            fileDetail.put('name', (String) file.get('name'));
            fileDetail.put('url', (String) file.get('webViewLink')); // URL to view the file
            fileDetail.put('type', (String) file.get('mimeType'));
            fileDetail.put('modifiedTime', (String) file.get('modifiedTime'));
            fileDetail.put('description', (String) file.get('description'));
            fileDetail.put('version', (String) file.get('version'));

            fileDetails.add(fileDetail);
        }
        return fileDetails;
    } else {
        throw new CalloutException('Failed to fetch files: ' + filesResponse.getBody());
    }
}




    public static String findFolder(String folderName, String parentFolderId, String accessToken) {
        //String query = 'name = \'' + folderName + '\' and \'' + parentFolderId + '\' in parents and mimeType = \'application/vnd.google-apps.folder\' and trashed = false';
        String query = 'name = \'' + folderName + '\' and \'' + parentFolderId + '\' in parents and trashed = false';
        String endpoint = GOOGLE_DRIVE_FOLDER_ENDPOINT + '?q=' + EncodingUtil.urlEncode(query, 'UTF-8') + '&fields=files(id,name,webViewLink)';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> files = (List<Object>) jsonResponse.get('files');
            if (!files.isEmpty()) {
                Map<String, Object> file = (Map<String, Object>) files[0];
                system.debug('file: ' + file);
                
                // Get the file URL
                String fileUrl = (String) file.get('webViewLink');
                if (fileUrl != null) {
                    return fileUrl;  // Return the web view link
                } else {
                    throw new CalloutException('No URL found for the file.');
                }
            }
        } else {
            throw new CalloutException('Failed to find folder: ' + response.getBody());
        }
        return null;
    }

    public static String findFileInMultipleFolders(String fileName, List<String> parentFolderIds, String accessToken) {
        // Build the search query for all folders in one call
        String folderConditions = '';
        for (String folderId : parentFolderIds) {
            if (folderConditions != '') {
                folderConditions += ' or ';
            }
            folderConditions += '\'' + folderId + '\' in parents';  
        }
        //Google Drive has a limit on the length of query strings, so this approach could break if searching in a large number of folders 
        //Not recommended if more than 20-30 folders to be searched.

        // Build the full query to search for the file in all folders
        String query = 'name = \'' + fileName + '\' and (' + folderConditions + ') and trashed = false';
        String endpoint = GOOGLE_DRIVE_FOLDER_ENDPOINT + '?q=' + EncodingUtil.urlEncode(query, 'UTF-8') + '&fields=files(id,name,webViewLink,mimeType)';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> files = (List<Object>) jsonResponse.get('files');

            if (!files.isEmpty()) {
                for (Object objFile : files) {
                    Map<String, Object> file = (Map<String, Object>) objFile;
                    
                    // Return the file URL if it's a file (not a folder)
                    String mimeType = (String) file.get('mimeType');
                    if (mimeType != 'application/vnd.google-apps.folder') {
                        String fileUrl = (String) file.get('webViewLink');
                        if (fileUrl != null) {
                            return fileUrl;  // Return the file link (WebViewLinl) of the found file
                        }
                    }
                }
            }
        } else {
            throw new CalloutException('Failed to find file: ' + response.getBody());
        }

        // If no file is found
        return null;
    }

    public static List<String> findMultipleFilesInFolder(List<String> fileNames, String parentFolderId, String accessToken) {
       
        List<String> fileLinks = new List<String>();
        String fileConditions = '';
        for (String fileName : fileNames) {
            if (fileConditions != '') {
                fileConditions += ' or ';
            }
            fileConditions += 'name = \'' + fileName + '\'';  
        }

        String query = '(' + fileConditions + ') and \'' + parentFolderId + '\' in parents and trashed = false';
        String endpoint = GOOGLE_DRIVE_FOLDER_ENDPOINT + '?q=' + EncodingUtil.urlEncode(query, 'UTF-8') + '&fields=files(id,name,webViewLink,mimeType)';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> files = (List<Object>) jsonResponse.get('files');

            if (!files.isEmpty()) {
                for (Object objFile : files) {
                    Map<String, Object> file = (Map<String, Object>) objFile;
                    // Check if it's a file (not a flder)
                    String mimeType = (String) file.get('mimeType');
                    if (mimeType != 'application/vnd.google-apps.folder') {
                        String fileUrl = (String) file.get('webViewLink');
                        if (fileUrl != null) {
                            fileLinks.add(fileUrl);
                        }
                    }
                }
            }
        } else {
            throw new CalloutException('Failed to find files: ' + response.getBody());
        }

        return fileLinks;
    }
    
    public static Map<String,String> findMultipleFilesInFolderNewMethod(Set<String> fileNames, String parentFolderId, String accessToken) {
       
        List<String> fileLinks = new List<String>();
        Map<String,String> mapOfPositionNamesAndFiles = new Map<String,String>();
        String fileConditions = '';
        for (String fileName : fileNames) {
            if (fileConditions != '') {
                fileConditions += ' or ';
            }
            fileConditions += 'name = \'' + fileName + '\'';  
        }

        String query = '(' + fileConditions + ') and \'' + parentFolderId + '\' in parents and trashed = false';
        String endpoint = GOOGLE_DRIVE_FOLDER_ENDPOINT + '?q=' + EncodingUtil.urlEncode(query, 'UTF-8') + '&fields=files(id,name,webViewLink,mimeType)';

        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setMethod('GET');

        HttpResponse response = http.send(request);

        if (response.getStatusCode() == 200) {
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            List<Object> files = (List<Object>) jsonResponse.get('files');

            if (!files.isEmpty()) {
                for (Object objFile : files) {
                    Map<String, Object> file = (Map<String, Object>) objFile;
                    // Check if it's a file (not a flder)
                    String mimeType = (String) file.get('mimeType');
                    String fileName = (String) file.get('name');
                    for(String positionName : fileNames){
                        if(positionName == fileName){
                            if (mimeType != 'application/vnd.google-apps.folder') {
                                String fileUrl = (String) file.get('webViewLink');
                                if (fileUrl != null) {
                                    mapOfPositionNamesAndFiles.put(positionName,fileUrl);
                                }
                            } 
                        }
                    }
                    
                }
            }
        } else {
            throw new CalloutException('Failed to find files: ' + response.getBody());
        }

        return mapOfPositionNamesAndFiles;
    }

    /**
    * This method creates a new folder in Google Drive using the Google Drive API.
    * It sends a POST request to the Google Drive API to create a folder under the specified parent folder.
    * 
    * Author: Vineet Kishore
    * 
    * @param folderName - The name of the folder to be created.
    * @param parentFolderId - The ID of the parent folder where the new folder will be created.
    * @param accessToken - The OAuth2 access token for authentication.
    * 
    * @return String - The ID of the newly created folder.
    * @throws CalloutException - If the folder creation fails.
    */
    private static String createFolder(String folderName, String parentFolderId, String accessToken) {
        // Construct the request body with folder details, including name, parent folder, and MIME type
        String body = '{\r\n"name":"' + folderName + '",\r\n"parents":["' + parentFolderId + '"],\r\n"mimeType":"application/vnd.google-apps.folder"\r\n}';

        // Create a new HTTP instance for making the request
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        // Set the Google Drive API endpoint for folder creation with support for all drives
        request.setEndpoint(GOOGLE_DRIVE_FOLDER_ENDPOINT + '?supportsAllDrives=true');
        
        // Set the Authorization header with the OAuth2 Bearer token
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        
        // Set the Content-Type to application/json for the request body
        request.setHeader('Content-Type', 'application/json');
        
        // Set the HTTP method to POST for creating the folder
        request.setMethod('POST');
        
        // Set the body of the request containing the folder details
        request.setBody(body);

        // Send the HTTP request and capture the response
        HttpResponse response = http.send(request);

        // If the response status code is 200 (OK), the folder was created successfully
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON response to extract the folder ID
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            
            // Return the folder ID from the response
            return (String) jsonResponse.get('id');
        } else {
            // Throw an exception if folder creation fails
            throw new CalloutException('Failed to create folder: ' + response.getBody());
        }
    }


    /**
    * This method uploads a file to Google Drive using the Google Drive API.
    * The file is uploaded as a multipart/related request to the Google Drive API endpoint.
    * 
    * Author: Vineet Kishore
    * 
    * @param fileName - The name of the file to be uploaded.
    * @param fileData - The file data encoded in base64 format.
    * @param folderId - The ID of the folder where the file will be uploaded.
    * @param accessToken - The OAuth2 access token for authentication.
    * 
    * @return GoogleDriveFile - An object representing the uploaded file, containing its ID, URL, and name.
    * @throws CalloutException - If the file upload fails.
    */

    public static GoogleDriveFile uploadFile(String fileName, String fileData, String folderId, String accessToken) {
        // Build the body for the multipart/related request
        String body = '--foo_bar_baz\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n' +
                    '{\r\n"name":"' + fileName + '",\r\n"parents":["' + folderId + '"]}\r\n\r\n' +
                    '--foo_bar_baz\r\nContent-Transfer-Encoding: base64\r\nContent-Type:' +
                    MIMEHelper.getMIMEType(fileName) + '\r\n\r\n' + fileData +
                    '\r\n--foo_bar_baz--';

        // Create a new HTTP instance for making the request
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        // Set the Google Drive API endpoint for uploading files
        request.setEndpoint(GOOGLE_DRIVE_API_ENDPOINT);
        
        // Set the Authorization header with the OAuth2 Bearer token
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        
        // Set the Content-Type for the multipart request
        request.setHeader('Content-Type', 'multipart/related; boundary=foo_bar_baz');
        
        // Set the Content-Length header based on the size of the request body
        request.setHeader('Content-Length', String.valueOf(Blob.valueOf(body).size()));
        
        // Set the HTTP method to POST for file upload
        request.setMethod('POST');
        
        // Set the body of the request, containing the file metadata and base64-encoded data
        request.setBody(body);

        // Send the HTTP request and capture the response
        HttpResponse response = http.send(request);
        system.debug('response' + response); // Debug log for inspecting the response

        // If the response status code is 200 (OK), the file was uploaded successfully
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON response to extract file details
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            
            // Retrieve the file ID, file name, and construct the file URL
            String fileId = (String) jsonResponse.get('id');
            String fileUrl = constructFileUrl(fileId); 
            String filname = (String) jsonResponse.get('name');
            
            // Debug log to inspect the fileId and fileUrl
            system.debug('fileId' + fileId);
            system.debug('fileUrl' + fileUrl);
            
            // Return a GoogleDriveFile object containing the file details
            return new GoogleDriveFile(fileId, fileUrl, filname); 
        } else {
            // Throw an exception if the file upload fails
            throw new CalloutException('Failed to upload file: ' + response.getBody());
        }
    }


    /**
    * Uploads only a PDF file to Google Drive using Google Drive API v3.
    * This method handles the multipart upload of the file along with metadata like the file name and folder ID.
    * The file is uploaded to a specified folder in Google Drive.
    *
    * This functionality was added as part of the **Policy Module** to allow the uploading of policy documents
    * directly to Google Drive. This ensures that policy documents are centrally stored
    * and can be easily accessed by authorized users.
    *
    * @param fileName The name of the file being uploaded (e.g., "Policy_Document.pdf").
    * @param fileData The file content, encoded as a Base64 string (the file's binary data).
    * @param folderId The ID of the Google Drive folder where the file should be uploaded.
    * @param accessToken The OAuth 2.0 access token for authenticating the API request with Google Drive.
    * @return A success message or a URL to the uploaded file on Google Drive.
    * @throws CalloutException If the upload fails, an exception is thrown with the error message from the API.
    * @Author Vineet Kishore 
    * @Date-- 21 Jan 2025
    */

    public static String uploadPdfFile(String fileName, String fileData, String folderId, String description, String accessToken) {
        // Decode the Base64 file data
        Blob fileBlob = EncodingUtil.base64Decode(fileData);
        
        // Prepare the metadata JSON with the description
        String metadataJson = '{' +
            '"name": "' + fileName + '", ' +
            '"parents": ["' + folderId + '"], ' + // Add the folderId in the parents field
            '"description": "' + description + '"' + // Add the description here
        '}';
        // Define boundary for the multipart request
        String boundary = 'foo_bar_baz';

        // Create the multipart request body
        String body = '--' + boundary + '\r\n' +
            'Content-Type: application/json; charset=UTF-8\r\n\r\n' +
            metadataJson + '\r\n\r\n' +
            '--' + boundary + '\r\n' +
            'Content-Type: application/pdf\r\n' +
            'Content-Transfer-Encoding: base64\r\n\r\n' +
            EncodingUtil.base64Encode(fileBlob) + '\r\n' +  // Attach the file content here
            '--' + boundary + '--';

        // Send the HTTP request
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(GOOGLE_DRIVE_API_ENDPOINT);
        request.setHeader('Authorization', 'Bearer ' + accessToken);
        request.setHeader('Content-Type', 'multipart/related; boundary=' + boundary);
        request.setMethod('POST');
        request.setBody(body);

        HttpResponse response = http.send(request);
        System.debug('Response: ' + response.getBody());

        // Check if the upload was successful
        if (response.getStatusCode() == 200) {
            // Parse the response to get file details
            Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String fileId = (String) jsonResponse.get('id');
            String fileUrl = constructFileUrl(fileId);  // Construct the file URL (assuming you have a method to do this)
            String fileNameFromResponse = (String) jsonResponse.get('name');
            
            // Return a success message or the file URL
            return 'File uploaded successfully: ' + fileUrl;
        } else {
            throw new CalloutException('Failed to upload file: ' + response.getBody());
        }
    }


    /**
    * Uploads a new version of an existing file in Google Drive and sets the "Keep Forever" flag for the latest revision.
    * This method first uploads the new version of the file, then fetches the latest revision ID, 
    * and finally sets the "Keep Forever" flag for that revision to ensure it is not deleted automatically by Google Drive.
    * 
    * This functionality is useful for managing versioning of files in Google Drive where the latest revision needs to be preserved.
    * 
    * Author: Vineet
    * Date: 20th January 2025
    * 
    * @param fileId The ID of the file in Google Drive that needs to be updated.
    * @param fileContent The new file content encoded in Base64.
    * @return A success message indicating that the new version has been uploaded and marked as "Keep Forever".
    * @throws AuraHandledException If the upload, revision fetch, or "Keep Forever" update fails, an exception is thrown.
    */

    @AuraEnabled
    public static String uploadNewVersion(String fileId, String fileContent) {
        // Define the Google Drive API endpoint to upload a new version of the file
        String uploadEndpoint = 'https://www.googleapis.com/upload/drive/v3/files/' + fileId + '?uploadType=media';
        
        // Decode the Base64-encoded file content into a Blob for uploading
        Blob fileBlob = EncodingUtil.base64Decode(fileContent);
        
        // Step 1: Upload the new version of the file to Google Drive
        HttpRequest uploadReq = new HttpRequest();
        uploadReq.setEndpoint(uploadEndpoint);  // Set the API endpoint for file upload
        uploadReq.setMethod('PATCH');           // Use PATCH to update the existing file
        uploadReq.setHeader('Authorization', 'Bearer ' + refreshAccessToken());  // Include the access token for authentication
        uploadReq.setHeader('Content-Type', 'application/pdf');  // Set the content type to PDF (or the appropriate type)
        uploadReq.setBodyAsBlob(fileBlob);  // Attach the file content as the request body

        Http http = new Http();
        HttpResponse uploadRes = http.send(uploadReq);

        // Check if the upload was successful (HTTP status code 200)
        if (uploadRes.getStatusCode() != 200) {
            System.debug('Google Drive API Error during upload: ' + uploadRes.getBody());
            throw new AuraHandledException('Failed to upload new version: ' + uploadRes.getBody());
        }

        // Step 2: Fetch the latest revision ID for the uploaded file
        String revisionListEndpoint = 'https://www.googleapis.com/drive/v3/files/' + fileId + '/revisions';
        HttpRequest revisionReq = new HttpRequest();
        revisionReq.setEndpoint(revisionListEndpoint);  // Set the API endpoint for fetching revisions
        revisionReq.setMethod('GET');  // Use GET to retrieve the file's revision history
        revisionReq.setHeader('Authorization', 'Bearer ' + refreshAccessToken());  // Include the access token for authentication
        
        HttpResponse revisionRes = http.send(revisionReq);

        // Check if the revision fetch was successful (HTTP status code 200)
        if (revisionRes.getStatusCode() != 200) {
            System.debug('Google Drive API Error while fetching revisions: ' + revisionRes.getBody());
            throw new AuraHandledException('Failed to fetch revisions: ' + revisionRes.getBody());
        }

        // Parse the response to get the latest revision ID
        Map<String, Object> revisionResponse = (Map<String, Object>) JSON.deserializeUntyped(revisionRes.getBody());
        List<Object> revisions = (List<Object>) revisionResponse.get('revisions');
        
        // Ensure that revisions exist for the file
        if (revisions == null || revisions.isEmpty()) {
            throw new AuraHandledException('No revisions found for the file.');
        }

        // Get the latest revision ID from the list of revisions
        Map<String, Object> latestRevision = (Map<String, Object>) revisions[revisions.size() - 1];
        String latestRevisionId = (String) latestRevision.get('id');

        // Step 3: Set the "Keep Forever" flag to true for the latest revision
        String keepForeverEndpoint = 'https://www.googleapis.com/drive/v3/files/' + fileId + '/revisions/' + latestRevisionId;
        HttpRequest keepForeverReq = new HttpRequest();
        keepForeverReq.setEndpoint(keepForeverEndpoint);  // Set the API endpoint for updating revision settings
        keepForeverReq.setMethod('PATCH');  // Use PATCH to modify the revision metadata
        keepForeverReq.setHeader('Authorization', 'Bearer ' + refreshAccessToken());  // Include the access token for authentication
        keepForeverReq.setHeader('Content-Type', 'application/json');  // Use JSON for metadata updates
        keepForeverReq.setBody('{"keepForever": true}');  // Set the "Keep Forever" flag to true for the latest revision

        HttpResponse keepForeverRes = http.send(keepForeverReq);

        // Check if setting "Keep Forever" was successful (HTTP status code 200)
        if (keepForeverRes.getStatusCode() != 200) {
            System.debug('Google Drive API Error while setting Keep Forever: ' + keepForeverRes.getBody());
            throw new AuraHandledException('Failed to set Keep Forever: ' + keepForeverRes.getBody());
        }

        // Return a success message indicating that the new version was uploaded and marked as "Keep Forever"
        return 'New version uploaded successfully';
    }



    public class GoogleDriveFile {
        @AuraEnabled
        public String fileId;
        @AuraEnabled
        public String fileUrl;
         @AuraEnabled
        public String filename;//Added by yuvathi to get name of the uploaded file
        public GoogleDriveFile(String fileId, String fileUrl,String filename ) {
            this.fileId = fileId;
            this.fileUrl = fileUrl;
            this.filename=filename;
        }
    }

    public static String getAccessToken() {
        GoogleDriveTokens__c googleTokenSettings = GoogleDriveTokens__c.getInstance('GoogleTokenRecord');
        return googleTokenSettings.AccessToken__c;
    }

    private static String constructFileUrl(String fileId) {
        String baseUrl = 'https://drive.google.com/file/d/';
        String viewOnlyUrl = baseUrl + fileId + '/view';
        return viewOnlyUrl;
    }

    // @future(callout=true)
    public static String refreshAccessToken() {
        GoogleDriveTokens__c googleTokenSettings = GoogleDriveTokens__c.getInstance('GoogleTokenRecord');
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(GOOGLE_REFRESH_TOKEN_ENDPOINT);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String body = 'client_id=' + googleTokenSettings.Client_Key__c + '&client_secret=' + googleTokenSettings.Client_Secret__c + '&refresh_token=' + googleTokenSettings.RefreshToken__c + '&grant_type=refresh_token';
        request.setBody(body);
        try {
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                Map<String, Object> tokenResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                String newAccessToken = (String) tokenResponse.get('access_token');
                googleTokenSettings.AccessToken__c = newAccessToken;
                // update googleTokenSettings;
                return newAccessToken;
            } else {
                System.debug('Failed to refresh access token: ' + response.getBody());
                return null; 
            }
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
            return null; 
        }
    }

    // Fetch all template files from a specific Google Drive folder
    @AuraEnabled
    public static List<Map<String, String>> getTemplateFiles(String folderId) {
        List<Map<String, String>> templateOptions = new List<Map<String, String>>();
        
        // Call a common method to fetch the template files, passing the initial access token
        String accessToken = getAccessToken();
        
        // Attempt to fetch template files with the provided token
        return fetchTemplateFilesWithToken(folderId, accessToken);
    }

    // Common method to fetch template files using either access token or refresh token
    private static List<Map<String, String>> fetchTemplateFilesWithToken(String folderId, String accessToken) {
        List<Map<String, String>> folderOptions = new List<Map<String, String>>();
        String query = '\'' + folderId + '\' in parents and mimeType=\'application/vnd.google-apps.folder\'';
        String endpoint = 'https://www.googleapis.com/drive/v3/files?q=' + EncodingUtil.urlEncode(query, 'UTF-8') + '&fields=files(id,name,modifiedTime)';

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + accessToken);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            List<Object> files = (List<Object>) result.get('files');

            for (Object file : files) {
                Map<String, Object> fileMap = (Map<String, Object>) file;
                Map<String, String> folderDetails = new Map<String, String>();
                folderDetails.put('folderId', (String) fileMap.get('id'));
                folderDetails.put('folderName', (String) fileMap.get('name'));
                folderDetails.put('modifiedTime', (String) fileMap.get('modifiedTime'));
                folderOptions.add(folderDetails);
            }
        } else {
            throw new AuraHandledException('Error fetching folders: ' + res.getStatus());
        }
        return folderOptions;
    }
}