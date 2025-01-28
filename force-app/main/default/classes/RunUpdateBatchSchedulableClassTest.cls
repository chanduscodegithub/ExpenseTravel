@istest
public class RunUpdateBatchSchedulableClassTest {
    public static testMethod void testschedule() {
        Test.StartTest();
        RunUpdateBatchSchedulableClass testsche = new RunUpdateBatchSchedulableClass();
        String sch = '0 0 23 * * ?';
        system.schedule('Test status Check', sch, testsche );
        Test.stopTest();
    }
}