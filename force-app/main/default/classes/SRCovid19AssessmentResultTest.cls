@isTest
public class SRCovid19AssessmentResultTest {
    
    Private static testMethod void SRCovid19AssessmentResultTest() {
        
        Service_Resource__c sr = new Service_Resource__c();
        sr.Email__c = 'gks@gmail.com';
        sr.Rating__c = 'Low Risk';
        string str='2020-05-19T11:55:49.000+0000';
        Datetime dt1=(DateTime)JSON.deserialize('"' + str + '"', DateTime.class);
        string str2='2020-05-19T11:55:00.000+0000';
        Datetime dtt2=(DateTime)JSON.deserialize('"' + str2 + '"', DateTime.class); 
        sr.Last_Opt_in_Date_Time__c=dt1;
        sr.Last_Covid_Assessment_Date__c=dtt2;
        sr.Covid_19_Suspect__c = true;
        sr.Covid_19_Safe__c=false;  
        insert sr;
        
        Covid_19_Questionnaire__c ques=new Covid_19_Questionnaire__c();
        ques.Active__c=true;
        ques.Region__c=sr.Region__c;
        ques.Country__c=sr.Country__c;
        ques.Site__c=sr.Site__c;
        ques.Used__c=true;
        insert ques;
        
        Test.startTest(); 
        List<SR_Covid_19_Assessment_Check__c> assessmentLst=new List<SR_Covid_19_Assessment_Check__c>();
        SR_Covid_19_Assessment_Check__c assessment = new SR_Covid_19_Assessment_Check__c();
        assessment.Email__c = 'gks@gmail.com';
        assessment.Mark_as_Suspect__c=true;
        assessment.Score__c= Decimal.valueOf('3');
        assessment.Rating__c='Low Risk' ;
        string s1='2020-05-19T11:55:49.000+0000';
        Datetime dt=(DateTime)JSON.deserialize('"' + s1 + '"', DateTime.class);
        string s2='2020-05-19T11:55:00.000+0000';
        Datetime dt2=(DateTime)JSON.deserialize('"' + s2 + '"', DateTime.class); 
        assessment.Screening_Date__c= dt;
        assessment.Last_Opt_in_Date_Time__c= dt2;
        assessment.Covid_19_Questionnaire__c=ques.id;
        assessmentLst.add(assessment);
        insert assessmentLst;
        system.assertEquals('gks@gmail.com', assessmentLst[0].Email__c);
        assessment.Service_Resource__c = sr.Id;    
        Test.stopTest();
        
    }
    
}