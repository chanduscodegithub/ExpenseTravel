@isTest
public with sharing class TestDataFactory {

    public static Project__c createProject(String accountId,String projectManagerId,String opportunityRecord){
        Project__c projectRecord = new Project__c();
        Date givenStartDate = Date.today() - 20;
        Date givenEndDate = Date.today() + 5;
        projectRecord.Region__c='ANZ';
        projectRecord.Country__c='Australia';
        projectRecord.startDate__c=givenStartDate;
        projectRecord.EndDate__c=givenEndDate;
        projectRecord.Account__c = accountId;
        projectRecord.ProjectManager__c = projectManagerId;
        projectRecord.Opportunity__c = opportunityRecord;
        return projectRecord;
    }
    //Pass only Partner Community profiles here
    public static List<User> createPartnerUsers(Integer numberToCreate,String communityProfileName,Contact contactInfo){
        //Enable Contacts account to be a Partner
        Account account = [SELECT ID, Name FROM Account WHERE Id =: contactInfo.AccountId];
        account.isPartner = true;
        update account;
        Profile p = [SELECT id, Name FROM Profile WHERE Name =:communityProfileName AND UserType = 'PowerPartner'];
        List<User> usersToCreate = new List<User>();
        for(Integer i=0;i<numberToCreate;i++){
            User u = new User();
            u.Alias = 'standt'+i;
            //u.UserRoleId=role_Id;
            u.Email=contactInfo.email; 
            u.EmailEncodingKey='UTF-8'; 
            u.LastName='Testing Apex'+i;
            u.LanguageLocaleKey='en_US';
            u.LocaleSidKey='en_US';
            u.ProfileId = p.Id;
            u.TimeZoneSidKey='America/Los_Angeles';
            u.UserName=contactInfo.email;
            u.ContactId = contactInfo.Id;
            usersToCreate.add(u);
        }
        return usersToCreate;
    }
    
    public static List<User> createUsers(Integer numberToCreate,String profileName){
        Profile p = [SELECT id, Name FROM Profile WHERE Name =:profileName];
        List<User> usersToCreate = new List<User>();
        for(Integer i=0;i<numberToCreate;i++){
            User u = new User();
            u.Alias = 'standt'+i;
            u.Email='standarduser'+i+'@crmit.com'; 
            u.EmailEncodingKey='UTF-8'; 
            u.LastName='Testing Apex'+i;
            u.LanguageLocaleKey='en_US';
            u.LocaleSidKey='en_US';
            u.ProfileId = p.Id;
            u.TimeZoneSidKey='America/Los_Angeles';
            u.UserName='standarduser'+i+'@crmitinternal.com';
            usersToCreate.add(u);
        }
        return usersToCreate;
    }
    public static User getAdminUser(){
        String uniqueUserName = 'adminuser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        UserRole ur=[SELECT Id, PortalType FROM UserRole where PortalType='Partner' limit 1];
        User u = new User(Alias = 'adminus',
                          UserRoleId=ur.Id,
                          Email='adminuser@testorg.com',
                          EmailEncodingKey='UTF-8',
                          LastName='Testing',
                          LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US',
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        return u;
    }
    public static List<Employee__c> createEmployee(Integer numberOfEmployee,String roleId, Id userId){
        List<Employee__c>  employeeList = new List<Employee__c>();
        for(Integer i=0;i<numberOfEmployee;i++){
            Employee__c employee = new Employee__c();
            employee.Name='Test Employee' + i;
            employee.EmployeeID__c='C00'+i;
            employee.BillingStatus__c='Billable';
            employee.Country__c='Australia';
            employee.City__c ='Sydney';
            employee.Department__c='Delivery';
            employee.Email_ID__c='test.test'+i+'@blah.com';
            employee.Designation__c = roleId;
            employee.Certifications__c='SF Certified Administrator';
            employee.Skill_Sets__c='Service Cloud';
            employee.TrailblazerRank__c='HIKER - 1/200';
            employee.SF_User__c = userId;//mandatory field to update code
            employeeList.add(employee);
        }
        return employeeList;
    }
    public Static List<Account> createAccount(Integer numberOfAccount){ 
        User thisUser =getAdminUser();
        //insert thisUser;
        List<Account> accountList = new List<Account>();
        for(Integer i=0;i<numberOfAccount;i++){
            Account a = new Account();
            a.Name = 'Test '+i;
            a.Type = 'Enterprise Account';
            a.Industry ='Health Care';
           // a.OwnerId=thisUser.Id;
            AccountList.add(a);
        }
        return accountList;
    }
    public Static List<Account> createPortalAccount(Integer numberOfAccount){ 
        User thisUser =getAdminUser();
        insert thisUser;
        List<Account> accountList = new List<Account>();
        for(Integer i=0;i<numberOfAccount;i++){
            Account a = new Account();
            a.Name = 'Test '+i;
            a.Type = 'Enterprise Account';
            a.Industry ='Health Care';
            a.OwnerId=thisUser.Id;
            a.isPartner = true;
            AccountList.add(a);
        }
        return accountList;
    }
    
    
    public Static TeamAllocation__c createTeamAllocation(String projectId,String employeeId){
        Date givenStartDate = Date.today();
         Date givenEndDate = Date.today() -1;
        TeamAllocation__c teamAllocation = new TeamAllocation__c();
        teamAllocation.Project__c= projectId;
        teamAllocation.EmployeeName__c= employeeId;
        teamAllocation.StartDate__c=givenStartDate;
        teamAllocation.EndDate__c=givenEndDate;
        teamAllocation.Billing_Status__c='Billable';
        return teamAllocation;
    }
     public Static TeamAllocation__c createTeamAllocation(String projectId,String employeeId,String billableStatus){
        Date givenStartDate = Date.today() - 20;
         Date givenEndDate = Date.today() + 5;
        TeamAllocation__c teamAllocation = new TeamAllocation__c();
        teamAllocation.Project__c= projectId;
        teamAllocation.EmployeeName__c= employeeId;
        teamAllocation.StartDate__c=givenStartDate;
        teamAllocation.EndDate__c=givenEndDate;
        teamAllocation.Billing_Status__c=billableStatus;
        return teamAllocation;
    }

    public Static Opportunity createOpportunity(String accountId){
        Date givenCloseDate = Date.today() + 10;
        Opportunity opportunityRecord = new Opportunity();
        opportunityRecord.Opportunity_Region__c='ANZ';
        opportunityRecord.Name='test';
        opportunityRecord.Opportunity_Source__c='Existing Customer - New	';
        opportunityRecord.Currency__c='';
        opportunityRecord.Next_Contact_Date__c=givenCloseDate;
        opportunityRecord.StageName='Contracts Sent';
        opportunityRecord.Opportunity_Status__c='Open';
        opportunityRecord.Technology_Domain__c='Salesforce';
        opportunityRecord.Skills_Required__c='Sales Cloud	';
        opportunityRecord.CloseDate =givenCloseDate;
        opportunityRecord.AccountId=accountId;
        opportunityRecord.FNA_Status__c='Approval to start';
        opportunityRecord.Industry_Vertical__c = 'Business Services';//Job__c.Status__c.getDescribe().getPicklistValues();
        opportunityRecord.Micro_Vertical__c = 'Internet';
        opportunityRecord.Amount = 90;
        return opportunityRecord;
  }
    
    public static List<Contact> createContact(integer numberOfContact){
        List<Contact> contactList = new List<Contact>();
        for(Integer i=0;i<numberOfContact;i++){
            Contact contact = new Contact();
            contact.FirstName = 'Test First '+i;
            contact.LastName = 'Test Last '+i;
            contact.Email = 'test'+i+'@blah.com';
            contact.Contact_Region__c='ANZ';
            contactList.add(contact);
        }
        return contactList;
    }
    public static List<Contact> createContactWithAccount(integer numberOfContact,Id accountId){
        List<Contact> contactList = new List<Contact>();
        for(Integer i=0;i<numberOfContact;i++){
            Contact contact = new Contact();
            contact.FirstName = 'Test First '+i;
            contact.LastName = 'Test Last '+i;
            contact.Email = 'test'+i+'@blah.com';
            contact.Contact_Region__c='ANZ';
            contact.AccountId = accountId;
            contactList.add(contact);
        }
        return contactList;
    }
    
    public static Role__c createRole(){
        Role__c role=new Role__c();
        role.Name='Test Employee Role';
        role.ExperienceRequired__c='1 Year';
        role.Grade__c='L1';
        role.CertificationsRequired__c='SF Certified Administrator;SF Certified Advanced Administrator;SF Certified Application Architect;SF Certified Force.com Developer';
        role.SkillRequired__c='Service Cloud;Salesforce CPQ;SF Configurations';
        role.Trailblazer_Rank__c='EXPLORER - 5/300';
        role.RatePerHour__c=30.00;
        return role;	
        
    }
}