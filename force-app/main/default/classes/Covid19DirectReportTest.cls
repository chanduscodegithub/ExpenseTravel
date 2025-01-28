@isTest
public class Covid19DirectReportTest {

     private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"id":"116396","aud":"509963558760-p45ivh8p491v770ljn5oq00cn8rnv7h9.apps.googleusercontent.com","email":"testemail@gmail.com"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    @testSetup static void setup(){
          Google_OAuth__c gOauth=new Google_OAuth__c();
          gOauth.Client_Id__c='509963558760-p45ivh8p491v770ljn5oq00cn8rnv7h9.apps.googleusercontent.com';
          insert gOauth;
    }
    public static testmethod void testIt(){       
          Service_Resource__c sr=new  Service_Resource__c();
          sr.Email__c='testemail@gmail.com';
          sr.Covid_19_Safe__c=true;
          sr.Covid_19_Suspect__c=true;
          sr.Covid_19_Patient__c=false;
          sr.Covid_19_Start_DateTime__c = DateTime.now();
          insert sr;
         system.assertEquals(true, sr.Covid_19_Safe__c);
         String idToken = 'Token';   
         Test.setMock(HttpCalloutMock.class,new RestMock());
         Test.StartTest(); 
         Covid19DirectReport CovidDir=new Covid19DirectReport();
         Covid19DirectReport.updateCovid19PatientFields(idToken);      
         Test.stopTest();
    
    }
    
}