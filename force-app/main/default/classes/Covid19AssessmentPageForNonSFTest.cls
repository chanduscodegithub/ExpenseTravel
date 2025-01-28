@isTest
public class Covid19AssessmentPageForNonSFTest {
    
     private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"id":"116396","aud":"509963558760-p45ivh8p491v770ljn5oq00cn8rnv7h9.apps.googleusercontent.com","email":"ramakrishna.pm@crmit.com"}';
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            return res;
        }
    }
    
    
    @testSetup static void setup(){
         Covid_19_Metadata__c covid19=new Covid_19_Metadata__c();
         covid19.Show_Risk_Score__c=false;
         insert covid19;
         
         Google_OAuth__c gOauth=new Google_OAuth__c();
         gOauth.Client_Id__c='509963558760-p45ivh8p491v770ljn5oq00cn8rnv7h9.apps.googleusercontent.com';
         gOauth.Client_Secret__c='Ync8Mpj6GN5W4H6WPsq7MOnn';
         gOauth.Note_1__c='If you are experiencing a life-threatening emergency, such as severe shortness of breath or high fever, call 911';
         gOauth.Note_2__c='By using this tool, you agree to its terms and that Interface Inc. will not be liable for any harm relating to your use. Recommendations provided by this tool do not constitute medical advice and should not be used to diagnose or treat medical conditions';
         insert gOauth;
         system.assertEquals('509963558760-p45ivh8p491v770ljn5oq00cn8rnv7h9.apps.googleusercontent.com',gOauth.Client_Id__c);
        
    }
    
    
     static testMethod void fetchSymptomQuestionsTest() {
         Google_OAuth__c gOauth=[select Client_Id__c,Client_Secret__c,Note_1__c,Note_2__c from Google_OAuth__c where Client_Id__c='509963558760-p45ivh8p491v770ljn5oq00cn8rnv7h9.apps.googleusercontent.com' LIMIT 1];
         Covid19AssessmentPageForNonSFUsersApex.WrapQuestionPicklist wrapQuesPick1 = new Covid19AssessmentPageForNonSFUsersApex.WrapQuestionPicklist();                   
         GoogleOAuthWrapper googleOAuthWrap = new GoogleOAuthWrapper();
         googleOAuthWrap.email='ramakrishna.pm@crmit.com';
                           
         Service_Resource__c sr1=new  Service_Resource__c();
         sr1.Name='Ramakrishna Reddy PM';
         sr1.Covid_19_Patient__c=false;
         sr1.Covid_19_Suspect__c=false;
         sr1.Region__c='US';
         sr1.Country__c='US';
         sr1.Site__c='NY-Site02';
         sr1.Email__c='ramakrishna.pm@crmit.com';
         insert sr1;
         
         wrapQuesPick1.isServiceResource = true;
         wrapQuesPick1.showRiskScore=false;
         wrapQuesPick1.isCovid19Patient=false;
         wrapQuesPick1.todayDate = Date.today();
         wrapQuesPick1.headerNote=gOauth.Note_1__c+ ' ' +gOauth.Note_2__c;
         wrapQuesPick1.serviceResourceURL=sr1.id;
         
         Covid_19_Questionnaire__c ques=new Covid_19_Questionnaire__c();
         ques.Active__c=true;
         ques.Region__c=sr1.Region__c;
         ques.Country__c=sr1.Country__c;
         ques.Site__c=sr1.Site__c;
         insert ques;
         
         wrapQuesPick1.covidQuestionnaire=ques;
         
         List<Covid_19_Questionnaire_Line_Item__c> lineItemList=new List<Covid_19_Questionnaire_Line_Item__c>();
         
         Covid_19_Questionnaire_Line_Item__c lineItem=new Covid_19_Questionnaire_Line_Item__c();
         lineItem.API_Name__c='Fatigue__c';
         lineItem.Question__c='Do you have a rash on skin or discoloration of fingers or toes?';
         lineItem.Field_Type__c='Picklist';
         lineItem.Picklist_Values__c='Tag1,Tag2';
         lineItem.Sequence_Number__c=decimal.valueOf(2);
         lineItem.Weightage__c =decimal.valueOf(1);
         lineItem.Covid_19_Questionnaire__c=ques.id;
         lineItemList.add(lineItem);
         
         Covid_19_Questionnaire_Line_Item__c lineItem1=new Covid_19_Questionnaire_Line_Item__c();
         lineItem1.API_Name__c='Fatigue__c';
         lineItem1.Question__c='Are you experiencing Serious Lightheadedness or Disorientation ? OR Are you experiencing Severe shortness of breath? OR Do you have Severe persistent pain and pressure in chest?';
         lineItem1.Field_Type__c='Picklist';
         lineItem1.Picklist_Values__c='Tag1';
         lineItem1.Sequence_Number__c=decimal.valueOf(2);
         lineItem1.Weightage__c =decimal.valueOf(1);
         lineItem1.Covid_19_Questionnaire__c=ques.id;
         lineItemList.add(lineItem1);
         
         insert lineItemList;
         
         String idToken = 'Token';   
         Test.setMock(HttpCalloutMock.class,new RestMock());
         
         Test.StartTest(); 
         wrapQuesPick1=Covid19AssessmentPageForNonSFUsersApex.fetchSymptomQuestions(idToken);
         Test.stopTest();
         
    }
    
    
    
    static testMethod void storeTechAssessmentResultsTest() {

        Map<String,String> resultDetailsMap = new Map<String,String>();
        resultDetailsMap.put('Conjunctivitis__c','No');
        resultDetailsMap.put('Diarrhea__c','No');
        resultDetailsMap.put('Headache__c','No');
        resultDetailsMap.put('Is_your_Body_Temperature_37_5C__c','No');
        String score = '5';
        String risk = 'Low Risk' ;
        String recommendation = 'Follow the standard Covid-19 preventive measures defined by your local health authority.  Monitor health constantly and do not miss your daily self-assessments. It is for your safety and well being.' ;
         String idToken = 'Token';   
       	String optInDateTimeString='15/04/2020 15:44';
        List<Covid_19_Assessment_Rating_Line_Item__c> covid19AssessmentResultList=new List<Covid_19_Assessment_Rating_Line_Item__c>();
        
            
        Covid_19_Assessment_Rating_Line_Item__c assessment=new Covid_19_Assessment_Rating_Line_Item__c();
        assessment.Risk_Rating_API__c='Rating__c';
        assessment.Risk_Score_API__c='Score__c';
        assessment.Mark_as_Suspect__c=true;
        assessment.Upper_Limit__c=24;
        covid19AssessmentResultList.add(assessment);
        insert covid19AssessmentResultList;
        
        Covid_19_Questionnaire__c covidQuestionnaire=new Covid_19_Questionnaire__c();
         covidQuestionnaire.Active__c=true;
         covidQuestionnaire.Region__c='US';
         covidQuestionnaire.Country__c='US';
         covidQuestionnaire.Site__c='NY-Site02';
         insert covidQuestionnaire;
        
        
         Test.setMock(HttpCalloutMock.class,new RestMock());
         Test.StartTest(); 
         Covid19AssessmentPageForNonSFUsersApex.storeTechAssessmentResults(resultDetailsMap,score,risk,recommendation,idToken,covidQuestionnaire,covid19AssessmentResultList,optInDateTimeString);
         
         Test.stopTest();
         
         
    }
    
}