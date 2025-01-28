public with sharing class GoogleOAuthController {
    // Define the constants for OAuth credentials and redirect URI
    private static final String CLIENT_ID = '373274262289-95aaam7lbgk45b2pmg3jqd5b9kn8qmv9.apps.googleusercontent.com';
    private static final String CLIENT_SECRET = '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';
    private static final String REDIRECT_URI = 'https://sftd1--pms.sandbox.lightning.force.com/apex/OAuth2CallbackPage';

    public String authCode { get; set; }

    public PageReference processAuthCode() {
        if (authCode != null) {
            String accessToken = getAccessToken(authCode);
            // Store the access token securely
            // Redirect to another page or display a success message
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Authorization code not found.'));
        }
        return null;
    }

    private String getAccessToken(String authCode) {
        String tokenUrl = 'https://oauth2.googleapis.com/token';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(tokenUrl);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        String body = 'code=' + EncodingUtil.urlEncode(authCode, 'UTF-8') +
                      '&client_id=' + CLIENT_ID +
                      '&client_secret=' + CLIENT_SECRET +
                      '&redirect_uri=' + REDIRECT_URI +
                      '&grant_type=authorization_code';
        req.setBody(body);

        Http http = new Http();
        HttpResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
            return (String) result.get('access_token');
        } else {
            throw new AuraHandledException('Failed to get access token: ' + res.getBody());
        }
    }
}