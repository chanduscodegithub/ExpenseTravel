/*************************************************************************************************************
 * @name			BidSurveyNotificationReminderTest
 * @author			Rohit Pal   <rohit.pal@crmit.com>
 * @created			04 / 07 / 2020
 * @description		Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2020-07-04		Rohit Pal			    
 *
**************************************************************************************************************/
@isTest(SeeAllData=false)
private class BidSurveyNotificationReminderTest {
   
    /**
    * @description : Creating Opporunity test data 
    * @author Rohit Pal | 4/7/2020 
    * @return void 
    **/
    @TestSetup
    static void testData(){
        //
        Account objAccount = new Account();
        objAccount.Name = 'Test Account';
        objAccount.Type = 'Enterprise Account';
        objAccount.Industry ='Health Care';
        objAccount.Micro_Vertical__c ='Hospitality';
        insert objAccount;
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'New Test Opportunity 1';
        objOpportunity.AccountId = objAccount.Id;
        objOpportunity.Opportunity_Source__c ='Salesforce - PS'; 
        objOpportunity.CurrencyIsoCode = 'INR';
        objOpportunity.Next_Contact_Date__c = System.today()+7;
        objOpportunity.CloseDate = system.today()+30;
        objOpportunity.StageName = 'Opportunity Identified';
        objOpportunity.Opportunity_Status__c='Open';
        objOpportunity.Technology_Domain__c = 'Salesforce';
        objOpportunity.Skills_Required__c = 'Sales Cloud';
        objOpportunity.Opportunity_Stream__c = 'RFP Process';
        objOpportunity.Industry_Vertical__c='Business Services';
        objOpportunity.Micro_Vertical__c = 'Architecture & Planning ';
        //
        insert objOpportunity;
        //
        RFPProcess__c objRFPProcess = new RFPProcess__c();
        objRFPProcess.Opportunity__c = objOpportunity.id;
        objRFPProcess.AccountName__c = objAccount.id;
        objRFPProcess.RFPStatus__c = 'Open';
        insert objRFPProcess;
        //
        Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
        app.setObjectId(objRFPProcess.id);
        app.setComments('Approving request.');
        app.setNextApproverIds(new Id[] {UserInfo.getUserId()});
        System.debug('@@@@@@ app >>' +app );
        Approval.ProcessResult result = Approval.process(app);
        System.debug('@@@@@@ >>' +result );
        //
        ProcessInstance objProcessInstance = [SELECT Id,
                                                     TargetObjectId, 
                                                     CreatedDate 
                                              FROM ProcessInstance 
                                              WHERE TargetObjectId = :objRFPProcess.Id];

        RFPProcess__c objRFPProcess1 = new RFPProcess__c();
        objRFPProcess1.Opportunity__c = objOpportunity.id;
        objRFPProcess1.AccountName__c = objAccount.id;
        objRFPProcess1.RFPSubmissionDate__c = System.today();
        objRFPProcess1.RFPStatus__c = 'Bid';
        insert objRFPProcess1;
    }
    /**
    * @description 
    * @author Rohit Pal | 4/7/2020 
    * @return TestupdateRFPProcess 
    **/
    static testMethod void TestupdateRFPProcess(){

        List<RFPProcess__c> lstRFPProcess = [SELECT Id,
                                                    Name,
                                                    RFPStatus__c
                                             FROM RFPProcess__c];
        List<ProcessInstance> objProcessInstance = [SELECT Id,
                                                          TargetObjectId, 
                                                          CreatedDate 
                                                   FROM ProcessInstance 
                                                   WHERE TargetObjectId  IN :lstRFPProcess];
        //
        user objUserName = [SELECT Id,Name FROM User where Id =: UserInfo.getUserId()]; 
        Profile objProfile = [SELECT Id FROM Profile WHERE name = 'System Administrator' LIMIT 1];
        User objUser = new User();
        objUser.firstName = 'test1';
        objUser.lastName = 'test2';
        objUser.Alias ='test';
        objUser.profileId = objProfile.id;
        objUser.username = 'testlkmh@test.com';
        objUser.email = 'test@test.com';
        objUser.TimeZoneSidKey ='America/New_York';
        objUser.LocaleSidKey ='en_US';
        objUser.EmailEncodingKey ='UTF-8';
        objUser.LanguageLocaleKey ='en_US';
        //Execute batch class in user mode
        system.runAs(objUser){
            BidSurveyNotificationReminder.setUserFullName.add(objUserName.Name);
            BidSurveyNotificationReminder.sendApprovalReminderEmail();
            String CRON_EXP = '0 0 0 15 3 ? 2022';
            String jobId = System.schedule('ScheduledApexTest',CRON_EXP, new BidSurveyNotificationScheduler()); 
        }
    } 
}