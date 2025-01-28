public class ResignationSampleTest {
    public static void execMethod(){
        Resignation__c resgnRec = ResignationTestDataFactory.createResignation('Better Career', 'Remark: Approval Test for HR');
        ResignationTestDataFactory.submitForApproval(resgnRec, UserInfo.getUserId());
    }
    public static void deleteAll(){
        delete [SELECT Id FROM Resignation__c WITH SYSTEM_MODE];
    }
    public static void recallTest(){
        // Resignation__c r = [SELECT Id FROM Resignation__c WHERE Resignation_Status__c = 'Applied' LIMIT 1];
        ResignationTestDataFactory.recallRecord('a6ZDX0000000fOd2AI', 'Changed my decision');
    }
}