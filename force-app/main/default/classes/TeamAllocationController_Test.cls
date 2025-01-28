@IsTest
public  class TeamAllocationController_Test {
    @IsTest
    static void testProjectDetails(){
        
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
        TeamAllocationController.findProject(teamAllocation.Id);
        TeamAllocationController.findAllLastYearAllocated(teamAllocation.Id);
        TeamAllocationController.myActiveTeamAllocationRecords(teamAllocation.Id);
        TeamAllocationController.myActiveProject(employeeId,'myActiveProject');
        TeamAllocationController.myActiveProject(employeeId,'myBillableProject');
        TeamAllocationController.myActiveProject(employeeId,'myNonBillableProject');
        Test.stopTest();
    }
    
}