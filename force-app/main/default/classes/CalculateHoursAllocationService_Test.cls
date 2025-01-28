@isTest
public class CalculateHoursAllocationService_Test {
    @IsTest
    static void BillableHours_Test(){
        Role__c role = TestDataFactory.createRole();
        insert role;
        List<User> u1=[select Id,UserRoleId from User where Id = :UserInfo.getUserId()];
        List<TeamAllocation__c> teamAllocationRecords = new List<TeamAllocation__c>();
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
        teamAllocationRecords.add(teamAllocation);
        Test.startTest();
        CalculateHoursAllocationService.calculateHoursAllocated(teamAllocationRecords);
        Test.stopTest();
    }
    
    @IsTest
    static void BillableHours_Update_Test(){
         Role__c role = TestDataFactory.createRole();
        insert role;
         List<User> u1=[select Id,UserRoleId from User where Id = :UserInfo.getUserId()];
        Map<Id,TeamAllocation__c> newRecordMap=new Map<Id,TeamAllocation__c>();
        Map<Id,TeamAllocation__c> oldRecordMap=new Map<Id,TeamAllocation__c>();
        
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
        
        TeamAllocation__c oldTeamAllocationRecord = new TeamAllocation__c();
        oldTeamAllocationRecord.Id = teamAllocation.Id;
        oldTeamAllocationRecord.AllocationPercentage__c = teamAllocation.AllocationPercentage__c;
        oldRecordMap.put(oldTeamAllocationRecord.Id,oldTeamAllocationRecord);
        
        teamAllocation.AllocationPercentage__c=20;
        newRecordMap.put(teamAllocation.Id,teamAllocation);
        
        Test.startTest();
        CalculateHoursAllocationService.calculateAllocatedHoursOnUpdate(newRecordMap, oldRecordMap);
        Test.stopTest();
    }
    @IsTest
    static void BillableHours_Trigger_Test(){
        
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
        insert teamAllocation;
        
        Test.startTest();
        teamAllocation.AllocationPercentage__c=20;
        update  teamAllocation;
        Test.stopTest();
        
    }
}