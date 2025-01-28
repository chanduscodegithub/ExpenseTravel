@isTest
public class UpdateProjectTest {

    @isTest
    public static void createTestData() {
         Profile profile2Id = [SELECT Id FROM Profile WHERE Name = 'ASEAN Sales' LIMIT 1];
        User u = new User();
        u.FirstName = 'Jyoshnatrs';
        u.LastName = 'A';
        u.Email = 'jyoshna.a@crmit.com';
        u.Username = 'jyoshnards.a@crmit.com';
        u.Alias = 'ja';
        u.TimeZoneSidKey = 'Europe/London';
        u.LocaleSidKey = 'en_GB';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.LanguageLocaleKey = 'en_US';
        u.ProfileId = profile2Id.Id;
        insert u;
        
        system.runAs(u){
           // Create a test Customer Engagement record
        Project__c ce = new Project__c(Name='Test CE');
        insert ce;

        // Create a test Employee record
        Employee__c emp = new Employee__c(Name='Test Employee', Cost_per_Hour__c=100);
        insert emp;
            
            

         Team_Timesheet__c TT= new Team_Timesheet__c();
            TT.Employee_Name__c=emp.Id;
            TT.Week_Start_Date__c=system.today();
            TT.Status__c='Submitted';
            insert TT;
            
             // Create a test Team Allocation record
        TeamAllocation__c ta = new TeamAllocation__c( RatePerHour__c=50, Resource_Role__c='Architect',
                                                     EmployeeName__c=emp.Id, Project__c=ce.Id, StartDate__c=system.today().addDays(-30),EndDate__c=system.today().addDays(30));
        insert ta;
        
        Timesheet_Utils__c tu=new Timesheet_Utils__c();
            tu.Actual_Hours__c=20;
            tu.Employee__c=emp.Id;
            tu.Timesheet__c=TT.Id;
            tu.Team_Allocation__c=ta.Id;
            insert tu;
       

        // Create a test Timesheet Approval record
        Timesheet_Approval__c tsa = new Timesheet_Approval__c(Total_Hours__c=10, Timesheet__c=TT.id,
                                                               Customer_Engagement__c=ce.Id,
                                                               Employee__c=emp.Id);
        insert tsa;
        
        Test.startTest();
        tsa.Approval_Status__c='Approved';
        update tsa;
        Test.stopTest();
            }
        
    }

   
}