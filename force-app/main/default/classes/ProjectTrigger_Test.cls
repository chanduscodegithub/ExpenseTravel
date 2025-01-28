@isTest
public class ProjectTrigger_Test {
     
    static testmethod void testUpdateProject() {
        
        User thisUser = [SELECT Id,Email FROM User WHERE Id = :UserInfo.getUserId()];
        User secondUser = [SELECT Id,Email FROM User WHERE Id !=:UserInfo.getUserId() LIMIT 1];
        
        Role__c role = TestDataFactory.createRole();
        insert role;
        
        List<User> userList = [Select Id from User LIMIT 1];
        Integer numberOfRecord = 2;
        List<Account> listOfAccount = TestDataFactory.createAccount(numberOfRecord);
         List<User> u1=[select Id,UserRoleId from User where Id = :UserInfo.getUserId()];
       // System.debug('user role'+u1[0].UserRoleId);
        System.runAs(u1[0]) {
        insert listOfAccount;
        }
       
        String accountId = listOfAccount.get(0).Id;
        List<User> users = TestDataFactory.createUsers(1,'Standard User');
        insert users;
        List<Contact> contacts = TestDataFactory.createContactWithAccount(1,accountId);//integer numberOfContact,Id accountId
        insert contacts;
        //Params -- Integer numberToCreate,String communityProfileName,Contact contactInfo
        List<User> partnerUsers = TestDataFactory.createPartnerUsers(1,'Partner Community Login User_Manager',contacts[0]);
        insert partnerUsers;
        List<Employee__c> employeeList = TestDataFactory.createEmployee(numberOfRecord,role.id,partnerUsers[0].Id);
        insert employeeList;
        
        Opportunity opportunityRecord = TestDataFactory.createOpportunity(accountId);
        
        String managerId = employeeList.get(0).Id;
        Project__c projectRecord = TestDataFactory.createProject(accountId,partnerUsers[0].Id,opportunityRecord.Id);
        insert projectRecord;
        
        String projectId= projectRecord.id;
        String employeeId = employeeList.get(1).Id;
        
        
        TeamAllocation__c teamAllocation = TestDataFactory.createTeamAllocation(projectId,employeeId);
        insert teamAllocation;
        teamAllocation.AllocationPercentage__c = 67;
        update teamAllocation;
        Support_SLA__c support =new Support_SLA__c();
        support.Customer_Name__c=accountId;
        support.Name='Test Support SLA 1';
        insert support ;
        update support;
        case newcase =new case();
        newcase.Status='open';
        newcase.Opportunity_Engagement_Name__c=projectId;
        insert newcase;
        Test.startTest();
        projectRecord.FuturePointOfContactFunctional__c = thisUser.Id;
        projectRecord.FuturePointOfContactTechnical__c = thisUser.Id;
        projectRecord.EndDate__c = Date.today() + 6;
        projectRecord.ProjectManager__c = partnerUsers[0].id;
        update projectRecord;
        Test.stopTest();
    }
}