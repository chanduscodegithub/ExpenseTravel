@IsTest 
public class CommunityHomePageCompContlr_Test {
    @testsetup static void setup(){
        Role__c role = TestDataFactory.createRole();
        insert role;
        Integer numberOfRecord = 2;
        List<Account> listOfAccount = TestDataFactory.createAccount(numberOfRecord);
        insert listOfAccount;
        String accountId = listOfAccount.get(0).Id;
        List<User> u1=[select Id,UserRoleId from User where Id = :UserInfo.getUserId()];
        List<Employee__c> employeeList = TestDataFactory.createEmployee(numberOfRecord,role.id,u1[0].Id);
        insert employeeList;
        
        Opportunity opportunityRecord = TestDataFactory.createOpportunity(accountId);
        
        String managerId = employeeList.get(0).Id;
        Project__c projectRecord = TestDataFactory.createProject(accountId,u1[0].Id,opportunityRecord.Id);
        
        insert projectRecord;
        
        String projectId= projectRecord.id;
        String employeeId = employeeList.get(1).Id;
        
        
        TeamAllocation__c teamAllocation = TestDataFactory.createTeamAllocation(projectId,employeeId);
        teamAllocation.EndDate__c=Date.today()+2;
        insert teamAllocation;
        
    }
    static testmethod void getProjectListMethod() {
        Test.startTest();
        List<Project__c> l = CommunityHomePageCompContlr.getProjectList();
        system.assertEquals(1, l.size());
        Test.stopTest();
    }
    static testmethod void getTeamAllocationListMethod() {
        Test.startTest();
         CommunityHomePageCompContlr.getTeamAllocationList();
      
        Test.stopTest();
    }
    static testmethod void getSupportRequestListMethod() {
        Test.startTest();
        CommunityHomePageCompContlr.getSupportRequestList();
       
        Test.stopTest();
    }
    static testmethod void getTAwithoutKPIListMethod() {
        Test.startTest();
         CommunityHomePageCompContlr.getTAwithoutKPIList();
       
        Test.stopTest();
    }
    static testmethod void getEmployeeSRInprogressMethod() {
        Test.startTest();
        String empID= [SELECT Id FROM Employee__c LIMIT 1].Id;
        CommunityHomePageCompContlr.getEmployeeSRInprogress(empID);
       
        Test.stopTest();
    }
    static testmethod void getEmployeeSRCompleteMethod() {
        Test.startTest();
        String empID= [SELECT Id FROM Employee__c LIMIT 1].Id;
        CommunityHomePageCompContlr.getEmployeeSRComplete(empID);
        
        Test.stopTest();
    }
    static testmethod void getTeamAllocationwithoutKPIsMethod() {
        Test.startTest();
        String empID= [SELECT Id FROM Employee__c LIMIT 1].Id;
        CommunityHomePageCompContlr.getTeamAllocationwithoutKPIs(empID);
        
        Test.stopTest();
    }
    
    static testmethod void getTeamAllocationwithKPIsMethod() {
        Test.startTest();
        String empID= [SELECT Id FROM Employee__c LIMIT 1].Id;
        CommunityHomePageCompContlr.getTeamAllocationwithKPIs(empID);
        
        Test.stopTest();
    }
    
    
}