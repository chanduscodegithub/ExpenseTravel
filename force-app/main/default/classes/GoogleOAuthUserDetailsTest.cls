/*
Developer : Venkatasiva (C0386)
Description : Test class for Covid19QuestionnaireAndRatings.
*/
@isTest
public class GoogleOAuthUserDetailsTest {
    
     private class RestMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"id":"116396","aud":"Client Id","email":"testemail@gmail.com"}';

            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }

    private static testMethod void GoogleOAuthUserDetailsTest() {
        
        String idToken = 'Token';
        system.assertEquals('Token', idToken);
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.StartTest(); 
       	GoogleOAuthUserDetails.getClientIdAndMailId(idToken);        
        Test.stopTest();
      }
    
}