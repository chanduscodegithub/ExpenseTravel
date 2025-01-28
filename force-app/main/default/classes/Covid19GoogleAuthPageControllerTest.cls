@isTest
public class Covid19GoogleAuthPageControllerTest {

    static testmethod void test(){
    Covid_19_Metadata__c covidMetadata=new Covid_19_Metadata__c();
    covidMetadata.URL_for_Non_SF_Users_Assessment_Page__c='https://empinfo-crmitcsmportal.cs44.force.com/CRMITSolutionsCOVID19/s/self-assessment-page';
    insert covidMetadata;
       
    Google_OAuth__c googleOauth=new Google_OAuth__c ();
    googleOauth.Client_Id__c='509963558760-p45ivh8p491v770ljn5oq00cn8rnv7h9.apps.googleusercontent.com';
    googleOauth.Note_1__c='If you are experiencing a life-threatening emergency, such as severe shortness of breath or high fever, call 911';
    googleOauth.Note_2__c='By using this tool, you agree to its terms and that Interface Inc. will not be liable for any harm relating to your use. Recommendations provided by this tool do not constitute medical advice and should not be used to diagnose or treat medical conditions';
    insert googleOauth;
    system.assertEquals('509963558760-p45ivh8p491v770ljn5oq00cn8rnv7h9.apps.googleusercontent.com',googleOauth.Client_Id__c);
       Test.startTest();
       Covid19GoogleAuthPageController covidGoogle=new Covid19GoogleAuthPageController();
       //covidGoogle.Covid19GoogleAuthPageController();
       Test.stopTest();
    }
    
    
    
}