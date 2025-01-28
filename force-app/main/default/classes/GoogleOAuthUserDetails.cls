public class GoogleOAuthUserDetails {
    public static GoogleOAuthWrapper getClientIdAndMailId(String idToken){
        GoogleOAuthWrapper googleOAuthWrap = new GoogleOAuthWrapper();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://oauth2.googleapis.com/tokeninfo?id_token='+idToken);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            googleOAuthWrap.clientId = String.valueOf(results.get('aud'));
            googleOAuthWrap.email = String.valueOf(results.get('email'));
            if(googleOAuthWrap.email!=null){
                googleOAuthWrap.email = googleOAuthWrap.email.trim();
                googleOAuthWrap.email = googleOAuthWrap.email.replaceAll('\\s+', '');
                googleOAuthWrap.email = googleOAuthWrap.email.toLowerCase();
            }
            System.debug('clientId - '+googleOAuthWrap.clientId);
            System.debug('email - '+googleOAuthWrap.email);
            return googleOAuthWrap;
        }
        else{
            return null;
        }
    }
}