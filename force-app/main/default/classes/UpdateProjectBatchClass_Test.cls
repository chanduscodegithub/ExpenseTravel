@isTest
public class UpdateProjectBatchClass_Test {
    
    static testmethod void testUpdateProject() {
        
        Role__c role = TestDataFactory.createRole();
        insert role;
        List<User> u1=[select Id,UserRoleId from User where Id = :UserInfo.getUserId()];
        Integer numberOfRecord = 2;
        List<Account> listOfAccount = TestDataFactory.createAccount(numberOfRecord);
        insert listOfAccount;
        String accountId = listOfAccount.get(0).Id;
        
        List<Employee__c> employeeList = TestDataFactory.createEmployee(numberOfRecord,role.id,u1[0].Id);
        insert employeeList;
        
        Opportunity opportunityRecord = TestDataFactory.createOpportunity(accountId);
        
        String managerId = employeeList.get(0).Id;
        Project__c projectRecord = TestDataFactory.createProject(accountId,u1[0].Id,opportunityRecord.Id);
        projectRecord.StartDate__c=Date.today()-1;
        projectRecord.EndDate__c=Date.today()-1;
        insert projectRecord;
        
        String projectId= projectRecord.id;
        String employeeId = employeeList.get(1).Id;
        
        
        TeamAllocation__c teamAllocation = TestDataFactory.createTeamAllocation(projectId,employeeId);
        teamAllocation.StartDate__c=Date.today()-1;
        teamAllocation.EndDate__c=Date.today()-1;
        insert teamAllocation;
        
        Test.startTest();
        UpdateProjectBatchClass obj = new UpdateProjectBatchClass();
        Database.executeBatch(obj);
        Test.stopTest();
        
    }
    
}