@isTest
public class timesheetPageHeaderControllerTest {
     @isTest
    public static void getTimesheetDetailsTest(){
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
            Ta.AllocationPercentage__c=50;
            insert Ta;
    
            
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
            TT.Reporting_Manager__c=u.Id;
            TT.Status__c='Submitted';
            insert TT;
            timesheetPageHeaderController.getTimesheetDetails(TT.Id);
        }
    }
    }