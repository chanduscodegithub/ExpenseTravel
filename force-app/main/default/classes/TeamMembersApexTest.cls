/**
* Test class for : TeamMember.apxc
* */
@IsTest
public class TeamMembersApexTest {
    
    @isTest static void testTeamAllocation (){
        
        /*  Account acc = new Account();
        acc.Name='ANZ';
        acc.Type='Enterprise Account';
        acc.Industry='Financial Services';
        acc.CRMIT_Relationship__c='Direct - Active';
        acc.Customer_Region__c='ANZ';
        acc.CurrencyIsoCode='';
        
        insert acc;
        
        
        Opportunity opp = new Opportunity();
        opp.Name='Homerepair SF Project';
        opp.Opportunity_Source__c='Existing Customer - New';
        //opp.CurrencyIsoCode='';
        // opp.Next_Contact_Date__c=new Date().addDays(10);//date.parse('06/07/2012');
        opp.CloseDate=date.parse('02/05/2020');
        opp.Opportunity_Status__c='Opportunity Identified';
        opp.Technology_Domain__c='Analytics';
        opp.Skills_Required__c='Communities';
        opp.StageName='Open';
        // opp.Micro_Vertical__c='Aerospace and Defence';
        opp.Amount=5;
        opp.AccountId=acc.Id;
        insert opp;
        
        
        Role__c rol = new Role__c();
        rol.Name='CX Cloud Developer';
        insert rol;
        
        
        User u =new User();
        u.CompanyName='testuser';
        insert u;
        
        
        Project__c proj =new Project__c();
        proj.Name='UAt';
        proj.Country__c='India';
        proj.StartDate__c=date.parse('12/04/2019');
        proj.EndDate__c=date.parse('12/04/202');
        proj.ProjectManager__c=u.Id;
        proj.Opportunity__c=opp.Id;
        insert proj;
        
        
        Employee__c emp = new Employee__c();
        emp.Name='Viswanath Reddy A';
        emp.EmployeeID__c='CO508';
        emp.DateofJoin__c=date.parse('11/06/2020');
        emp.Department__c='Delivery';
        emp.ReportingTo__c='Ram';
        emp.Gender__c='Male';
        emp.MobileNo__c='(758) 771-0091';
        emp.Email_ID__c='abc@gmail.com';
        insert emp;  
        
        
        TeamAllocation__c team =new TeamAllocation__c();
        team.Project__c='UAt';
        team.EmployeeName__c='viswanath';
        team.Billing_Status__c='Billable';
        team.ReportingTo__c=u.Id;
        team.StartDate__c=date.parse('12/02/2020');
        team.EndDate__c=date.parse('10/05/2020');
        team.AllocationPercentage__c=0.50;
        team.EmployeeName__c=emp.Id;
        team.Project__c=proj.Id;
        insert team; */
        
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
         TeamAllocation__c teamAllocation2 = TestDataFactory.createTeamAllocation(projectId,employeeId,'Bench');
        insert teamAllocation2;
        
        Test.startTest();
        
        TeamMembersApex.getTeamMembers(projectRecord.Id);
        TeamMembersApex.getOpprotunityInfo(projectRecord.Id);
        
        Test.stopTest();
        
    }
    
}