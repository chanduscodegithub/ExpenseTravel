/*
Developer : Venkatasiva (C0386)
Description : Test class for Covid19QuestionnaireAndRatings.
*/
@isTest
public class Covid19QuestionnaireAndRatingsTest {

    
    private static testMethod void covid19QuestionnaireAndRatingsTest() {
        
        String region = 'US';
        String country= 'US';
        String site = 'All'; 
        Covid_19_Questionnaire__c ques=new Covid_19_Questionnaire__c(Region__c='US',Site__c='ALL',Country__c='US');
        insert ques;
        system.assertEquals('US',ques.Region__c);
        Test.StartTest(); 
       	List<Covid_19_Questionnaire__c> QuestionnaireList= Covid19QuestionnaireAndRatings.getQuestionnaireLineItems(region, country, site); 
        Test.stopTest();
      }
    
}