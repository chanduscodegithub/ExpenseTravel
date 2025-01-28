public class googleAuthService {
    public static GoogleDriveTokens__c googleToken = GoogleDriveTokens__c.getInstance('GoogleTokenRecord');
    public static boolean authSaved{get;set;}
    public static boolean authNotSaved{get;set;}
    public static boolean disableAuth{get;set;}
    public static Boolean IscloseWindow{get; set; }
   
    //Client Id
    private static string key = googleToken.Client_Key__c;
    //Client Secret
    private Static string secret = googleToken.Client_Secret__c;
    //API Redirect. Use your Lightning Tab or Lightning community URL
    private Static string redirect_uri = 'https://sftd1--c.vf.force.com/apex/GoogleDriveRedirectVFPage';
    private static string authUrl='https://accounts.google.com/o/oauth2/auth';
    private static string scope='https://www.googleapis.com/auth/drive';
    private static string tokenUrl='https://accounts.google.com/o/oauth2/token';
    
    
    @AuraEnabled
    public static String createAuthURL() {
        String key = EncodingUtil.urlEncode(key,'UTF-8');
        String uri = EncodingUtil.urlEncode(redirect_uri,'UTF-8');
        String authuri = '';
        authuri = authUrl+'?'+
            'client_id='+key+
            '&response_type=code'+
            '&scope='+scope+
            '&redirect_uri='+uri+
            '&access_type=offline'+
            '&prompt=consent';
        return authuri;
    }
    //gets called in Vf page controller
    @RemoteAction
    @AuraEnabled
    public static void saveAuthCode(){
       
         String authorisation = ApexPages.currentPage().getParameters().get('code');
         System.debug('authorisation'+authorisation);
         getAccessToken(authorisation);
        
      

}
    
     @AuraEnabled
    public static boolean getAccessToken(String code)
    {
        //Getting access token from google
        
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(tokenUrl);
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        
        String messageBody ='code='+code+'&client_id='+key+
            '&client_secret='+secret+
            '&redirect_uri='+redirect_uri+
            '&grant_type=authorization_code';
        req.setHeader('Content-length', String.valueOf(messageBody.length()));
        req.setBody(messageBody);
        req.setTimeout(60*1000);
        system.debug('messageBody:'+messageBody);
        
        Http callout = new Http();
        String responseText;
        HttpResponse response = callout.send(req);
        responseText = response.getBody();
        system.debug('responseText:'+responseText);
        Map<String,object> responseMap =(Map<String,object>)JSON.deserializeUntyped(responseText) ;  
        String accesstoken =  String.valueOf(responseMap.get('access_token'));
        system.debug('accesstoken:'+accesstoken);
        
        String refreshtoken =  String.valueOf(responseMap.get('refresh_token'));
        system.debug('refreshtoken:'+refreshtoken);
       
        
        googleToken.AccessToken__c = accesstoken;
        googleToken.RefreshToken__c = refreshtoken;
       
        try {
            upsert googleToken;
            authSaved = true;
            authNotSaved = false;
            disableAuth = true;
            IscloseWindow = true;
        } catch (Exception e) {
       
        authSaved = false;
        authNotSaved =true;
        disableAuth = true;
        System.debug('Error upserting Google Token: ' + e.getMessage());
        IscloseWindow = true;
         }
    
    return authSaved;
 }
    
    //Run Batch 
    
    @AuraEnabled
    public static Id executeBatchJob(){
        Id batchJobId = Database.executeBatch(new GoogleDriveBatch(), 1);
        return batchJobId;
    }

    @AuraEnabled
    public static AsyncApexJob getBatchJobStatus(Id jobID){
        AsyncApexJob jobInfo = [SELECT Status, NumberOfErrors,JobItemsProcessed,TotalJobItems FROM AsyncApexJob WHERE Id = :jobID];
        return jobInfo;
    }

}