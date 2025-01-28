@isTest
public class UpdateTABatchClass_Test {
    static testmethod void testUpdateTA() {

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
        insert projectRecord;
        
        String projectId= projectRecord.id;
        String employeeId = employeeList.get(1).Id;
        
        
        TeamAllocation__c teamAllocation = TestDataFactory.createTeamAllocation(projectId,employeeId);
        insert teamAllocation;
         
        
        Test.startTest();
        
       UpdateTABatchClass obj = new UpdateTABatchClass();
       Database.executeBatch(obj);
       Test.stopTest();

    }
}