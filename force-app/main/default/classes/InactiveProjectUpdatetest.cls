@isTest
private class InactiveProjectUpdatetest {
    static testmethod void test() {
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
       
         Project__c projectRecord = new Project__c();
        Date givenStartDate = Date.today() - 20;
        Date givenEndDate = Date.today() + 5;
        projectRecord.Region__c='ANZ';
        projectRecord.Country__c='Australia';
        projectRecord.startDate__c=givenStartDate;
        projectRecord.EndDate__c=givenEndDate;
        projectRecord.Account__c = accountId;
        projectRecord.Opportunity__c = opportunityRecord.Id;
      
        insert projectRecord;
        
        String projectId= projectRecord.id;
        String employeeId = employeeList.get(1).Id;
        
        
        TeamAllocation__c teamAllocation = TestDataFactory.createTeamAllocation(projectId,employeeId);
        teamAllocation.Resource_Role__c='Administrator';
        insert teamAllocation;
        
        
        Test.startTest();
        SchedulableContext sc = null;
        InactiveProjectschedulable tsc = new InactiveProjectschedulable();
        tsc.execute(sc);
        Test.stopTest();
        
    }
}