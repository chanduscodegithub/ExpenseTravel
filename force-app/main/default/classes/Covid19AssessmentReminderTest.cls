@isTest
public class Covid19AssessmentReminderTest {

    public static void init(){
             
        EmailTemplate et = new EmailTemplate();
        et.Subject='Request to take Covid-19 Self-Assesment for {!todaysDate}';
        et.HtmlValue='Hi {!Service_Resource__r.Name},<br><br> Request you to click <a href= "https://empinfo-crmitcsmportal.cs44.force.com/CRMITSolutionsCOVID19/s/signin-page">here</a> to take the Covid-19 self-assessment for {!todaysDate}.<br><br>If you are unfortunately infected with Covid-19 already, please click <a href="https://empinfo-crmitcsmportal.cs44.force.com/CRMITSolutionsCOVID19/s/direct-report-page">here</a> to report directly. We will soon reach out to you to see how we can help you best. <br><br>Take Care.<br><br> Regards,<br> HR Team';
        et.Body='<body> <p>my name22</p></body>';
        et.DeveloperName='Covid_19_Assessment_Page_Non_SF_Users';
        et.Name='My template';
        et.FolderId = UserInfo.getUserId();
        et.TemplateType='text';
        insert et;
        EmailTemplate et1 = new EmailTemplate();
        et1.Subject='Covid-19 Self-Assesment Reminder for {!todaysDate}';
        et1.HtmlValue='Dear {!Service_Resource__r.Name},<br><br> This is a gentle reminder for you to take covid-19 self assessment.<br><br> Request you to click <a href= "https://empinfo-crmitcsmportal.cs44.force.com/CRMITSolutionsCOVID19/s/signin-page">here</a> to take the Covid-19 self-assessment for {!todaysDate}.<br><br>If you are unfortunately infected with Covid-19 already, please click <a href="https://empinfo-crmitcsmportal.cs44.force.com/CRMITSolutionsCOVID19/s/direct-report-page">here</a> to report directly. We will soon reach out to you to see how we can help you best. <br><br>Take Care.<br><br> Regards,<br> HR Team';
        et1.Body='<body> <p>my name22</p></body>';
        et1.DeveloperName='Covid_19_Assesment_reminder_for_Non_SF_Users';
        et1.Name='My template2';
        et1.FolderId = UserInfo.getUserId();
        et1.TemplateType='text';
        insert et1;
    }
    
    
    static testMethod void testBatch(){
          List<Service_Resource__c> SRLst=new List<Service_Resource__c>();
          List<Service_Resource__c> SRLst1=new List<Service_Resource__c>(); 
          for(Integer i=0;i<100;i++){
             Service_Resource__c SR=new Service_Resource__c();
             SR.Name='GKS' +i;
             SR.Email__c='gkumar@crmit.com';
             SR.Last_Covid_Assessment_Date__c=system.Today().addDays(2);
             SR.Covid_19_Safe__c=true;
             SRLst.add(SR);      
        }
        insert SRLst;
        system.assertEquals('gkumar@crmit.com', SRLst[0].Email__c);
        for(Integer i=0;i<100;i++){
             Service_Resource__c SR1=new Service_Resource__c();
             SR1.Name='GKS22' +i;
             SR1.Email__c='gkumar22@crmit.com';
             SR1.Last_Covid_Assessment_Date__c=null;
             SR1.Covid_19_Safe__c=true;
             SRLst1.add(SR1);      
        }
        insert SRLst1;    
        system.assertEquals('gkumar22@crmit.com', SRLst1[0].Email__c);
        Map<Integer,String> dateMonth = new Map<Integer,String>();
        dateMonth.put(1, 'Jan');
        dateMonth.put(2, 'Feb');
        dateMonth.put(3, 'Mar');
        dateMonth.put(4, 'Apr');
        dateMonth.put(5, 'May');
        dateMonth.put(6, 'Jun');
        dateMonth.put(7, 'Jul');
        dateMonth.put(8, 'Aug');
        dateMonth.put(9, 'Sep');
        dateMonth.put(10, 'Oct');
        dateMonth.put(11, 'Nov');
        dateMonth.put(12, 'Dec');
        Date todaysDate = Date.today();
        String todayDateString = dateMonth.get(todaysDate.month())+' '+todaysDate.day()+', '+todaysDate.year();
        System.debug('todayDateString - '+todayDateString);
        
        Test.startTest();
        Covid19AssessmentReminder obj=new Covid19AssessmentReminder();
        DataBase.executeBatch(obj);
        Test.stopTest();
        
    
  }
    
}