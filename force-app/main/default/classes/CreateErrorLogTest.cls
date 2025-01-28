@IsTest
public class CreateErrorLogTest {
    @IsTest
    public static void testCreateLog() {
        // Create test data
        String req = 'Test Request';
        String res = 'Test Response';
        Integer resCode = 200;
        String resStatus = 'Success';
        
        // Mock the user ID
        User u = new User();
        u.Id = UserInfo.getUserId();
        System.runAs(u) {
            // Call the method under test
            Test.startTest();
            CreateErrorLog.createLog(req, res, resCode, resStatus);
            Test.stopTest();
        }
        
        // Verify the created Error_Logs__c record
        List<Error_Logs__c> errorLogs = [SELECT Request_Body__c, Response_Body__c, Response_Code__c, Response_Status__c, User__c FROM Error_Logs__c];
        System.assertEquals(1, errorLogs.size());
        Error_Logs__c errorLog = errorLogs[0];
        System.assertEquals(req, errorLog.Request_Body__c);
        System.assertEquals(res, errorLog.Response_Body__c);
        System.assertEquals(resCode, errorLog.Response_Code__c);
        System.assertEquals(resStatus, errorLog.Response_Status__c);
        System.assertEquals(u.Id, errorLog.User__c);
    }
}