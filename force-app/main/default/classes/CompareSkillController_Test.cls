/****************************************************************************************************
  Purpose  :  Employ Compare Skill control      
  Author   :  Pars                                                      Date : 20/04/2020                                      
  Version     Author                   Date                 Release #           Purpose   
----------------------------------------------------------------------------------------------------------------------------------------------------------------- 
  1.0 -            Name                    20/04/2020      Initial             Initial Development             
  1.1 -            Name                    23/05/2020      05222020  

*/
@isTest
public class CompareSkillController_Test {
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

        Opportunity opportunityRecord = TestDataFactory.createOpportunity(accountId);
        
            
        Test.startTest();
        String managerId = employeeList.get(0).Id;
        Project__c projectRecord = TestDataFactory.createProject(accountId,u1[0].Id,opportunityRecord.Id);
        insert projectRecord;
        
        String projectId= projectRecord.id;
        String employeeId = employeeList.get(1).Id;
        
        
            
        TeamAllocation__c teamAllocation = TestDataFactory.createTeamAllocation(projectId,employeeId);
        insert teamAllocation;
        
		teamAllocationRecords.add(teamAllocation);   
        CompareSkillController.getUnMatchedEmployeeSkillSet(employeeId);
        Test.stopTest();
    }
}