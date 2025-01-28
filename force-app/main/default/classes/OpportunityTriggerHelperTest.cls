/*************************************************************************************************************
 * @name            OpportunityTriggerHelperTest
 * @author          Rohit Pal <rohit.pal@crmit.com>
 * @created         03 / 07 / 2020
 * @description     Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ----------------------------------------------
 * @version     1.0     2020-07-03      Rohit Pal               Test Class For OpportunityTriggerHelper class
 *
**************************************************************************************************************/
@isTest(SeeAllData=false)
private class OpportunityTriggerHelperTest {
    /**
    * @description : Creating Opporunity test data 
    * @author Rohit Pal | 3/7/2020 
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
        Opportunity objOpportunity1 = new Opportunity();
        objOpportunity1.Name = 'New Test Opportunity';
        objOpportunity1.AccountId = objAccount.Id;
        objOpportunity1.Opportunity_Source__c ='Salesforce - PS'; 
        objOpportunity1.CurrencyIsoCode = 'INR';
        objOpportunity1.Next_Contact_Date__c = System.today()+7;
        objOpportunity1.CloseDate = system.today()+30;
        objOpportunity1.StageName = 'Opportunity Identified';
        objOpportunity1.Opportunity_Status__c='Open';
        objOpportunity1.Technology_Domain__c = 'Salesforce';
        objOpportunity1.Skills_Required__c = 'Sales Cloud';
        objOpportunity1.Industry_Vertical__c='Business Services';
        objOpportunity1.Micro_Vertical__c = 'Architecture & Planning ';
        //
        insert objOpportunity1;

    }

    /**
    * @description 
    * @author Rohit Pal | 3/7/2020 
    * @return tescreateOpportunity 
    **/
    static testMethod void tescreateOpportunity(){

        Opportunity objOpportunity = [SELECT Id,
                                             Name,
                                             Opportunity_Stream__c,
                                             Opportunity_Status__c
                                     FROM Opportunity 
                                     WHERE Opportunity_Stream__c =null LIMIT 1];
    
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
            objOpportunity.Opportunity_Stream__c = 'RFP Process';
            objOpportunity.Opportunity_Status__c = 'Won';
            update objOpportunity;
        }
    } 
}