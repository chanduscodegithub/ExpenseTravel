@isTest
public class TeamTimeSheetEmailBatchClassTest {
    @isTest
    public static void EmailBatchTest()
    {
        string day = '17';
        string year = '2022';
        string month = '05';
        String createDate = year + '-' + month
            + '-' + day;
        List<User> newUser = TestDataFactory.createUsers(1,'System Administrator');
        System.runAs(newUser[0]){
            Employee__c empUser = new Employee__c();
            empUser.Name='Yuvathi';
            empUser.Email_ID__c = 'lakkaraju.yuvathi@crmit.com';
            insert empUser;
            Team_Timesheet__c TT= new Team_Timesheet__c();
            TT.Employee_Name__c=empUser.Id;
            TT.Status__c='Draft';
            TT.Week_Start_Date__c=Date.valueOf(createDate);
            insert TT;
            Test.startTest();
            TeamTimeSheetEmailBatchClass bc= new TeamTimeSheetEmailBatchClass();
            Database.executeBatch(bc);
            Test.stopTest();
        }
        
    }
    
}