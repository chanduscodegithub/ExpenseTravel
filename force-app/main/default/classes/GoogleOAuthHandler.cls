public class GoogleOAuthHandler {
    private static final String CLIENT_ID = '373274262289-95aaam7lbgk45b2pmg3jqd5b9kn8qmv9.apps.googleusercontent.com';
    private static final String CLIENT_SECRET = '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';
     private static final String REDIRECT_URI = 'https://sftd1--pms.sandbox.lightning.force.com/apex/GDriveAuthConsent';
    private static final String AUTHORIZATION_URL = 'https://accounts.google.com/o/oauth2/auth';
    private static final String TOKEN_URL = 'https://oauth2.googleapis.com/token';
    private static final String SCOPE = 'https://www.googleapis.com/auth/drive';


    @AuraEnabled
    public static String getAuthorizationUrl() {
        String state = 'state_parameter_passthrough_value';
        String responseType = 'code';
        String accessType = 'offline';
        String prompt = 'consent';

        String authorizationUrl = AUTHORIZATION_URL + '?response_type=' + responseType +
                                  '&client_id=' + CLIENT_ID +
                                  '&redirect_uri=' + REDIRECT_URI +
                                  '&scope=' + SCOPE +
                                  '&state=' + state +
                                  '&access_type=' + accessType +
                                  '&prompt=' + prompt;

        return authorizationUrl;
    }

    @RemoteAction
    public static void handleCallback(String code) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(TOKEN_URL);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String body = 'client_id=' + CLIENT_ID +
                      '&client_secret=' + CLIENT_SECRET +
                      '&code=' + code +
                      '&redirect_uri=' + REDIRECT_URI +
                      '&grant_type=authorization_code';
        request.setBody(body);

        Http http = new Http();
        HttpResponse response = http.send(request);
        Map<String, Object> responseBody = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());

        String accessToken = (String) responseBody.get('access_token');
        String refreshToken = (String) responseBody.get('refresh_token');
        Integer expiresIn = (Integer) responseBody.get('expires_in');
        Long expirationTime = System.currentTimeMillis() + (expiresIn * 1000);

        // Save the tokens and expiration time in the custom setting or custom metadata
        GoogleDriveSettings__c settings = GoogleDriveSettings__c.getOrgDefaults();
        settings.Access_Token__c = accessToken;
        settings.Refresh_Token__c = refreshToken;
        settings.Expiration_Time__c = expirationTime;
        upsert settings;
    }
}