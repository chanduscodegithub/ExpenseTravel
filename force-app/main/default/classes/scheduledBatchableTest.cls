@isTest
public with sharing class scheduledBatchableTest {
    @isTest
    public static void testscheduledBatchableTest() {
        Test.startTest();
        scheduledBatchable sh1 = new scheduledBatchable();
        String sch = '0 0 1 * * ?'; 
        system.schedule('UpdateTARecords', sch, sh1); 
        Test.stopTest();
    }
}