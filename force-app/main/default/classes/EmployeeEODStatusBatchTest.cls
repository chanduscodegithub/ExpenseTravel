/*
Developer : Venkatasiva (C0386)
Description : Test class for Covid19QuestionnaireAndRatings.
*/
@isTest
public class EmployeeEODStatusBatchTest {
    
    private static testMethod void covid19QuestionnaireAndRatingsTest() {
        
        List<Service_Resource__c> lstService_Resource= new List<Service_Resource__c>();
        for(Integer i=0 ;i <10;i++)
        {
            Service_Resource__c sr = new Service_Resource__c();
            sr.Name='Test1';
            sr.Region__c='US';
            sr.Country__c='US';
            sr.Site__c='NY-Site02';
            sr.Gender__c='Male';
            //sr.Status__c='';
            sr.Score__c=5;
            sr.Age__c=45;
            sr.Covid_19_Safe__c=true;
            sr.Covid_19_Suspect__c=true;
            sr.Covid_19_Patient__c=true;
            sr.Rating__c='1';
            lstService_Resource.add(sr);
        }
	     insert lstService_Resource;
         system.assertEquals('Test1', lstService_Resource[0].Name);
        
        Test.StartTest(); 
        EmployeeEODStatusBatch obj = new EmployeeEODStatusBatch();
        DataBase.executeBatch(obj);
       	Test.stopTest();
      }

}