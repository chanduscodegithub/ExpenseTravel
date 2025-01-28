@IsTest
private class SalesRevenueAttainmentEmployeeBatchTest {
    @IsTest
    static void testBatchExecution() {
        // Create test data: Opportunities
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(new Opportunity(
            Name = 'Test Opportunity 1',
            CloseDate = Date.today(),
           StageName = 'Under Negotiations',
            Amount = 1000.00,
            OwnerId = UserInfo.getUserId()
            //Closed_Year__c = 2023 // Adjust as needed
        ));
        opportunities.add(new Opportunity(
            Name = 'Test Opportunity 2',
            CloseDate = Date.today(),
            StageName = 'Under Negotiations',
            Amount = 2000.00,
            OwnerId = UserInfo.getUserId()
           // Closed_Year__c = 2023 // Adjust as needed
        ));
        insert opportunities;
        
        // Schedule the batch
        Test.startTest();
       SalesRevenueAttainmentEmployeeBatch.increase();
        Test.stopTest();
        
        // Retrieve the scheduled job
       
    }

    @IsTest
    static void testQuarterCalculation() {
        Date testDate1 = Date.newInstance(2023, 5, 15);
        System.assertEquals(1, new SalesRevenueAttainmentEmployeeBatch(null).getQuarter(testDate1));
        
        Date testDate2 = Date.newInstance(2023, 8, 15);
        System.assertEquals(2, new SalesRevenueAttainmentEmployeeBatch(null).getQuarter(testDate2));
        
        Date testDate3 = Date.newInstance(2023, 11, 15);
        System.assertEquals(3, new SalesRevenueAttainmentEmployeeBatch(null).getQuarter(testDate3));
        
        Date testDate4 = Date.newInstance(2023, 2, 15);
        System.assertEquals(4, new SalesRevenueAttainmentEmployeeBatch(null).getQuarter(testDate4));
        
        // Test null case
       // System.assertNull(new SalesRevenueAttainmentEmployeeBatch(null).getQuarter(null));
    }
    
    // Add more test methods to cover other scenarios as needed

}