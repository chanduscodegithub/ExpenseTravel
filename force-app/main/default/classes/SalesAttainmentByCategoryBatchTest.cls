@IsTest
private class SalesAttainmentByCategoryBatchTest {
    
    @IsTest
    static void testBatchExecution() {
        // Create test data: Opportunities
        List<Opportunity> opportunities = new List<Opportunity>();
        opportunities.add(new Opportunity(
            Name = 'Test Opportunity 1',
            CloseDate = Date.today(),
            StageName = 'Opportunity Won',
            Opportunity_Status__c = 'Won',
            Win_Loss__c = 'Good lead',
            Amount = 1000.00,
            OwnerId = UserInfo.getUserId(),
            Opportunity_Category__c = 'Existing Customer - New Business'
        ));
        opportunities.add(new Opportunity(
            Name = 'Test Opportunity 2',
            CloseDate = Date.today(),
            StageName = 'Opportunity Won',
            Opportunity_Status__c = 'Won',
            Win_Loss__c = 'Good lead',
            Amount = 2000.00,
            OwnerId = UserInfo.getUserId(),
            Opportunity_Category__c = 'Existing Customer - Repeat / Renewals'
        ));
        insert opportunities;
        
        // Schedule the batch
        Test.startTest();
        SalesRevenueAttainmentByCategoryBatch.increase();
        Test.stopTest();
        
        // Retrieve the scheduled job
        // Add assertions if needed
    }

    @IsTest
    static void testQuarterCalculation() {
        Date testDate1 = Date.newInstance(2023, 5, 15);
        System.assertEquals(1, new SalesRevenueAttainmentByCategoryBatch(null).getQuarter(testDate1));
        
        Date testDate2 = Date.newInstance(2023, 8, 15);
        System.assertEquals(2, new SalesRevenueAttainmentByCategoryBatch(null).getQuarter(testDate2));
        
        Date testDate3 = Date.newInstance(2023, 11, 15);
        System.assertEquals(3, new SalesRevenueAttainmentByCategoryBatch(null).getQuarter(testDate3));
        
        Date testDate4 = Date.newInstance(2023, 2, 15);
        System.assertEquals(4, new SalesRevenueAttainmentByCategoryBatch(null).getQuarter(testDate4));
    }    
 
}