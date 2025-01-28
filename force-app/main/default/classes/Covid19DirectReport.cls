public class Covid19DirectReport {
    
    public String clientId {get; set;}
    
    public Covid19DirectReport(){
        Google_OAuth__c googleOauth = Google_OAuth__c.getInstance();
        clientId = googleOauth.Client_Id__c; 
    }
    
    @RemoteAction
    public static String updateCovid19PatientFields(String idToken){
        String email;
        String clientId;
        Google_OAuth__c googleOAuth = Google_OAuth__c.getInstance();
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://oauth2.googleapis.com/tokeninfo?id_token='+idToken);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        if (response.getStatusCode() == 200) {
            // Deserialize the JSON string into collections of primitive data types.
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            clientId = String.valueOf(results.get('aud'));
            email = String.valueOf(results.get('email'));
            System.debug('clientId - '+clientId);
            System.debug('email - '+email);
        }
        
        if(clientId!=googleOAuth.Client_Id__c || email==null || email==''){
            System.debug('Invalid Email or OAuth');
            return 'fail';
        }
        
        email = email.trim();
        email = email.replaceAll('\\s+', '');
        email = email.toLowerCase();
        Service_Resource__c srRecord = [SELECT Id, Covid_19_Safe__c,Covid_19_Suspect__c ,Covid_19_Patient__c, Covid_19_Start_DateTime__c FROM Service_Resource__c where Email__c=:email];
        if(srRecord.Covid_19_Patient__c == false){
            srRecord.Covid_19_Patient__c = true;
            srRecord.Covid_19_Safe__c = false;
            srRecord.Covid_19_Suspect__c = false;
            srRecord.Covid_19_Start_DateTime__c = DateTime.now();
            update srRecord;
            return 'success';
        }
        return 'fail';
    }
}