@isTest
public class TimesheetControllerTest {
    @isTest
    public static void getEmployeeTest(){
        List<User> newUser = TestDataFactory.createUsers(1,'System Administrator');
        System.runAs(newUser[0]){
            Employee__c empUser = new Employee__c();
            empUser.Name='Maaz Rahman';
            empUser.Email_ID__c = 'anusonia.jose@crmit.com';
            insert empUser;
            TimesheetController.getEmployee(empUser.id);
            /*Employee__c  newEmployee =TimesheetController.getEmployee();
system.assertEquals('A Jyoshna', newEmployee.Name);*/
        }
        
    }
    
    @isTest
    public static void getTeam_SheetTest(){
        TimesheetController.TeamAlloc_TimeSheet_Wrapper TATS = new TimesheetController.TeamAlloc_TimeSheet_Wrapper(); 
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
            Employee__c empUser = new Employee__c();
            empUser.Name='A Jyoshna';
            empUser.Email_ID__c = 'anusonia.jose@crmit.com';
            insert empUser;   
            
            Project__c pt = new Project__c();
            pt.Region__c='USA';
            pt.Country__c='Australia';
            insert pt;
            TeamAllocation__c Ta= new  TeamAllocation__c();
            Ta.ReportingTo__c=u.Id;
            Ta.Project__c=pt.Id;
            Ta.Billing_Status__c='Billable';
           Ta.Resource_Role__c='Administrator';
            Ta.StartDate__c=system.today()-6;
            Ta.AllocationPercentage__c=50;
            insert Ta;
            
            
            List<Delivery__c> allTS = new List<Delivery__c>();
            
            String empId;
            string year = '2022';
            string month = '03';
            string month1 = '04';
            string day = '5';
            string day2 = '7';
            String day0 = '6';
            string hour = '12';
            string minute = '20';
            string second = '20';
            string startString = year + '-' + month1
                + '-' + day0 ;
            // String startString='29-04-2022';
            String endString=year + '-' + month1
                + '-' + day2 ;
            String createDate = year + '-' + month1
                + '-' + day0;
            Team_Timesheet__c TT= new Team_Timesheet__c();
            TT.Employee_Name__c=empUser.Id;
            TT.Week_Start_Date__c=Date.valueOf(createDate);
            TT.Status__c='Rejected';
            insert TT;
            Delivery__c dt = new Delivery__c();
            //dt.Submitted__c = True;
            dt.Employee_Name__c = empUser.Id;
            dt.Team_Timesheet__c=TT.Id;
            dt.Date__c=Date.valueOf(createDate);
            dt.Time_in_Hours__c=4;
            dt.Customer_Engagement__c=pt.Id;
            dt.Team_Allocation__c=Ta.Id;
            dt.Category__c='CRMIT Holiday';
            dt.Sub_Category__c='CRMIT Holiday';
            dt.Description__c='Test';
            insert dt; 
            
            /* Delivery__c dt = new Delivery__c();
//dt.Submitted__c = True;
dt.Date__c =  Date.valueOf(createDate);
dt.Employee_Name__c = empUser.Id;
insert dt;*/
          
             Timesheet_Approval__c tsa = new Timesheet_Approval__c(Total_Hours__c=10, Timesheet__c=TT.id,
                                                               Customer_Engagement__c=pt.Id,
                                                               Employee__c=empUser.Id);
        insert tsa;
            
            
            String userId=String.valueOf(u.Id);
            TATS =  Timesheetcontroller.getTeam_Sheet(empUser.id,startString,endString);
            System.assertEquals(false, TATS.Submitted);
            Timesheetcontroller.deleteExisting(dt.Id);
            Timesheetcontroller.userData(userId);
        }
    }
   
    @isTest
    public static void SaveTs_Test(){
        
        Profile profile2Id = [SELECT Id FROM Profile WHERE Name = 'ASEAN Sales' LIMIT 1];
       
        UserRole r = new UserRole(DeveloperName = 'Partner', Name = 'Partner');
		insert r;
        
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
        u.UserRoleId=r.Id;
        insert u;
        //system.runAs(u){
       
        system.runAs(u){
            


		 Employee__c empUser = new Employee__c();
        empUser.Name='A Jyoshna';
        empUser.Email_ID__c = 'anusonia.jose@crmit.com';
        empUser.SF_User__c=u.Id;
        insert empUser;             
           
            string year = '2022';
            string month = '03';
            string month1 = '04';
            string day = '5';
            string day2 = '7';
            String day0 = '6';
            string hour = '12';
            string minute = '20';
            string second = '20';
            string startString = year + '-' + month1
                + '-' + day0 ;
            // String startString='29-04-2022';
            String endString=year + '-' + month1
                + '-' + day2 ;
            String createDate = year + '-' + month1
                + '-' + day0 ;
            Project__c pt = new Project__c();
            pt.Region__c='USA';
            pt.Country__c='Australia';
            insert pt;
            TeamAllocation__c Ta= new  TeamAllocation__c();
            Ta.ReportingTo__c=u.Id;
            Ta.Project__c=pt.Id;
            Ta.Billing_Status__c='Billable';
            Ta.AllocationPercentage__c=50;
            Ta.Resource_Role__c='Administrator';
            Ta.StartDate__c=system.today()-6;
            insert Ta;
            Team_Timesheet__c TT= new Team_Timesheet__c();
            TT.Employee_Name__c=empUser.Id;
            TT.Status__c='Rejected';
            TT.Week_Start_Date__c=Date.valueOf(createDate);
            insert TT;
            Delivery__c dt = new Delivery__c();
            //dt.Submitted__c = True;
            dt.Employee_Name__c = empUser.Id;
            dt.Team_Timesheet__c=TT.Id;
            dt.Date__c=Date.valueOf(createDate);
            dt.Time_in_Hours__c=4;
            dt.Customer_Engagement__c=pt.Id;
            dt.Team_Allocation__c=Ta.Id;
            dt.Category__c='CRMIT Holiday';
            dt.Sub_Category__c='CRMIT Holiday';
            dt.Description__c='Test';
            dt.Category__c='Leave';
            dt.Sub_Category__c='Casual Leaves';
            insert dt;   
            
             Delivery__c dt1 = new Delivery__c();
            //dt.Submitted__c = True;
            dt1.Employee_Name__c = empUser.Id;
            dt1.Team_Timesheet__c=TT.Id;
            dt1.Date__c=Date.valueOf(createDate);
            dt1.Time_in_Hours__c=4;
            dt1.Customer_Engagement__c=pt.Id;
            dt1.Team_Allocation__c=Ta.Id;
            dt1.Category__c='CRMIT Holiday';
            dt1.Sub_Category__c='CRMIT Holiday';
            dt1.Description__c='Test';
            //dt1.Category__c='Leave';
            //dt1.Sub_Category__c='Casual Leaves';
            insert dt1;  
            
             // Create a test Customer Engagement record
        Project__c ce = new Project__c(Name='Test CE');
        insert ce;

        // Create a test Employee record
        Employee__c emp = new Employee__c(Name='Test Employee', Cost_per_Hour__c=100);
        insert emp;
            
            
             Timesheet_Approval__c tsa = new Timesheet_Approval__c(Total_Hours__c=10, Timesheet__c=TT.id,
                                                               Customer_Engagement__c=ce.Id,
                                                               Employee__c=emp.Id);
        insert tsa;
            
            List<Account> newAccount = TestDataFactory.createAccount(1);
            insert newAccount[0];
            
            
            Opportunity opnew = TestDataFactory.createOpportunity(newAccount[0].Id);
            opnew.Opportunity_Region__c = 'ASEAN';
            insert opnew;
            
            Project__c prjctnew = TestDataFactory.createProject( newAccount[0].Id ,u.id ,opnew.Id);
            insert prjctnew;
            
            
            String requestString = '[{"key": "'+prjctnew.id+ '","projectName":"'+ prjctnew.Name +'","manager":"'+u.Name+'","region":"ASEAN","status":"Billable","eachProject":[{"key":10000000000,"eachDate":{"tsId":"'+dt.Id+'","tsName":"'+dt.Name+'","project":"'+prjctnew.Name+'","projectId":"'+pt.Id+'","projectAllocId":"'+Ta.Id+'", "region":"ASEAN","reportingManager":"'+u.Name+'", "billingStatus":"Billable","date":"'+createDate+'","category":"Development","sub_category":"Configuration","work_hour":"10", "description":"Test","taEnd":"'+endString+'", "taStart":"'+startString+'","existing":false}}]}]';
            Timesheetcontroller.saveTS(requestString,true,empUser.Id,startString,u.Id,TT.Id);
            String requestString1 = '[{"key": "'+prjctnew.id+ '","projectName":"'+ prjctnew.Name +'","manager":"'+u.Name+'","region":"USA","status":"Billable","eachProject":[{"key":10000000000,"eachDate":{"tsId":"'+dt.Id+'","tsName":"'+dt.Name+'","project":"'+prjctnew.Name+'","projectId":"'+pt.Id+'","projectAllocId":"'+Ta.Id+'", "region":"ASEAN","reportingManager":"'+u.Name+'", "billingStatus":"Billable","date":"'+createDate+'","category":"Development","sub_category":"Configuration","work_hour":"8", "description":"Test","taEnd":"'+endString+'", "taStart":"'+startString+'","existing":true}}]}]';
            //Timesheetcontroller.saveTS(requestString1,true,empUser.Id,startString,u.Id,TT.Id);  
            Timesheetcontroller.saveTS(requestString1,false,empUser.Id,startString,u.Id,TT.Id);
            Timesheetcontroller.prevRec(TT.Id);
            
            
        }  
        
        /* @isTest
public static void  deleteExisting_Test(){
Employee__c empUser = new Employee__c();
empUser.Name='A Jyoshna';
empUser.Email_ID__c = 'anusonia.jose@crmit.com';
insert empUser;
string year = '2022';
string month1 = '04';
String day0 = '6';
string hour = '12';
string minute = '20';
string second = '20';
String createDate = year + '-' + month1
+ '-' + day0 + ' ' + hour + ':' + 
minute + ':' + second;
Team_Timesheet__c TT= new Team_Timesheet__c();
TT.Employee_Name__c=empUser.Id;
TT.Week_Start_Date__c=Date.valueOf(createDate);
insert TT;
Delivery__c dt = new Delivery__c();
//dt.Submitted__c = True;
dt.Employee_Name__c = empUser.Id;
dt.Team_Timesheet__c=TT.Id;
insert dt; 
Timesheetcontroller.deleteExisting(dt.Id);

}*/
    } 
    
    
}