@isTest
public class EmployeeBillableStatusService_Test {
    @IsTest
    static void BillableStatus_Insert_Test(){
        Role__c role = TestDataFactory.createRole();
        insert role;
        List<User> u1=[select Id,UserRoleId from User where Id = :UserInfo.getUserId()];
        List<TeamAllocation__c> teamAllocationRecords = new List<TeamAllocation__c>();
        Integer numberOfRecord = 2;
        List<Account> listOfAccount = TestDataFactory.createAccount(numberOfRecord);
        insert listOfAccount;
        String accountId = listOfAccount.get(0).Id;
        
        List<Employee__c> employeeList = TestDataFactory.createEmployee(numberOfRecord,role.Id,u1[0].Id);
        insert employeeList;
        List<Id> employeeIds=new List<Id>();
        for(Employee__c eachEmployee:employeeList){
            employeeIds.add(eachEmployee.Id);
        }
        Opportunity opportunityRecord = TestDataFactory.createOpportunity(accountId);
        
        String managerId = employeeList.get(0).Id;
        Project__c projectRecord = TestDataFactory.createProject(accountId,u1[0].Id,opportunityRecord.Id);
        insert projectRecord;
        
        String projectId= projectRecord.id;
        String employeeId = employeeList.get(1).Id;
        
        
            
        TeamAllocation__c teamAllocation = TestDataFactory.createTeamAllocation(projectId,employeeId);
        insert teamAllocation;
        Map<Id,TeamAllocation__c> teamAllocationMap=new Map<Id,TeamAllocation__c>();
		teamAllocationMap.put(teamAllocation.Id,teamAllocation);       
        Test.startTest();
        EmployeeBillableStatusService.updateEmployee(employeeIds,teamAllocationMap);
        Test.stopTest();
    }
    @IsTest
    static void ShadowStatus_Insert_Test(){
        Role__c role = TestDataFactory.createRole();
        insert role;
        List<User> u1=[select Id,UserRoleId from User where Id = :UserInfo.getUserId()];
        List<TeamAllocation__c> teamAllocationRecords = new List<TeamAllocation__c>();
        Integer numberOfRecord = 2;
        List<Account> listOfAccount = TestDataFactory.createAccount(numberOfRecord);
        insert listOfAccount;
        String accountId = listOfAccount.get(0).Id;
        
        List<Employee__c> employeeList = TestDataFactory.createEmployee(numberOfRecord,role.Id,u1[0].Id);
        insert employeeList;
        List<Id> employeeIds=new List<Id>();
        for(Employee__c eachEmployee:employeeList){
            employeeIds.add(eachEmployee.Id);
        }
        Opportunity opportunityRecord = TestDataFactory.createOpportunity(accountId);
        
        String managerId = employeeList.get(0).Id;
        Project__c projectRecord = TestDataFactory.createProject(accountId,u1[0].Id,opportunityRecord.Id);
        insert projectRecord;
        
        String projectId= projectRecord.id;
        String employeeId = employeeList.get(1).Id;
        
        
            
        TeamAllocation__c teamAllocation = TestDataFactory.createTeamAllocation(projectId,employeeId);
        teamAllocation.Billing_Status__c='Shadow Dev';
        insert teamAllocation;
        Map<Id,TeamAllocation__c> teamAllocationMap=new Map<Id,TeamAllocation__c>();
		teamAllocationMap.put(teamAllocation.Id,teamAllocation);       
        Test.startTest();
        EmployeeBillableStatusService.updateEmployee(employeeIds,teamAllocationMap);
        Test.stopTest();
    }
    @IsTest
    static void BillableStatus_Insert_ForInactive_TeamAllocation_Test(){
        List<TeamAllocation__c> teamAllocationRecords = new List<TeamAllocation__c>();
        Role__c role = TestDataFactory.createRole();
        insert role;
        List<User> u1=[select Id,UserRoleId from User where Id = :UserInfo.getUserId()];
        Integer numberOfRecord = 2;
        List<Account> listOfAccount = TestDataFactory.createAccount(numberOfRecord);
        insert listOfAccount;
        String accountId = listOfAccount.get(0).Id;
        
        List<Employee__c> employeeList = TestDataFactory.createEmployee(numberOfRecord,role.Id,u1[0].Id);
        insert employeeList;
        List<Id> employeeIds=new List<Id>();
        for(Employee__c eachEmployee:employeeList){
            employeeIds.add(eachEmployee.Id);
        }
        Opportunity opportunityRecord = TestDataFactory.createOpportunity(accountId);
        
        String managerId = employeeList.get(0).Id;
        Project__c projectRecord = TestDataFactory.createProject(accountId,u1[0].Id,opportunityRecord.Id);
        insert projectRecord;
        
        String projectId= projectRecord.id;
        String employeeId = employeeList.get(1).Id;
            
        TeamAllocation__c teamAllocation = TestDataFactory.createTeamAllocation(projectId,employeeId);
        insert teamAllocation;
        
        System.debug([select id,BillingStatus__c,Designation__c,Designation__r.Grade__c from Employee__c where id =:employeeId]);
        
        teamAllocation.StartDate__c =  Date.today() - 20;
        teamAllocation.EndDate__c =  Date.today() - 10;
        update teamAllocation;
        Map<Id,TeamAllocation__c> teamAllocationMap=new Map<Id,TeamAllocation__c>();
		teamAllocationMap.put(teamAllocation.Id,teamAllocation);       
        Test.startTest();
        EmployeeBillableStatusService.updateEmployee(employeeIds,teamAllocationMap);
        Test.stopTest();
        System.debug([select id,BillingStatus__c,Designation__c,Designation__r.Grade__c from Employee__c where id =:employeeId]);
        
    }
}