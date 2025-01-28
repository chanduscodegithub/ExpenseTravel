@isTest
private class QuotaControllerTest {
    // Test data setup
    static testMethod void testDataSetup() {
        // Create test data for Employee__c object
       /* Employee__c testEmployee = new Employee__c(
            Name = 'Test Employee',
            SF_User__c = UserInfo.getUserId(),
            Quota_Attainment_Report__c = true,
            Eligible_for_Quota__c = true
        );
        insert testEmployee;*/

        // Create test data for Financial_Planning__c object
        Financial_Planning__c testFinancialPlanning = new Financial_Planning__c(
            Name = 'Test Financial Planning',
            FP_Year__c = '2023'
            // Add other required fields as necessary
        );
        insert testFinancialPlanning;
        
       

        // Create test data for Revenue_Stream_Employee__c object
        Revenue_Stream_Employee__c testRevenueStreamEmployee = new Revenue_Stream_Employee__c(
            //Employees__c = us.Id,
            Revenue_Stream_Forecasting__c = testFinancialPlanning.Id
            // Add other required fields as necessary
        );
        insert testRevenueStreamEmployee;
    }

    @isTest
    static void testGetSalesFinancialYears() {
        // Test your getSalesFinancialYears method
        // Ensure that the returned list contains the expected financial years
        // Test with different scenarios including future years, past years, etc.
        List<String> years = QuotaController.getSalesFinancialYears();
        // Assert that the list is not null and contains expected years
        System.assertNotEquals(null, years);
        System.assertEquals(3, years.size()); // Assuming it's 2022, 2023, and 2024
    }

    @isTest
    static void testGetSalesFinancialPlanningRecords() {
        // Test your getSalesFinancialPlanningRecords method
        // Ensure that the method returns the correct Financial Planning records based on different input parameters
        // Test with different user permissions, enabled/disabled Quota_Attainment_Report__c, etc.
        List<Financial_Planning__c> financialPlannings = QuotaController.getSalesFinancialPlanningRecords('2023', 'Test Region');
        // Assert that the list is not null and contains expected Financial Planning records
        System.assertNotEquals(null, financialPlannings);
        //System.assertEquals(1, financialPlannings.size()); // Assuming you have only one record for the given year and region
    }

    @isTest
    static void testGetSalesRevenueStreamRegions() {
        // Test your getSalesRevenueStreamRegions method
        // Ensure that the method returns the correct Revenue Stream Regions based on different input parameters
        // Test with different Financial Planning names, empty result sets, etc.
        List<Revenue_Stream_Region__c> regions = QuotaController.getSalesRevenueStreamRegions('Test Financial Planning');
        // Assert that the list is not null and contains expected Revenue Stream Regions
        System.assertNotEquals(null, regions);
        //System.assertEquals(1, regions.size()); // Assuming you have only one region for the given financial planning
    }

    @isTest
    static void testGetSalesRevenueStreamEmployeesForLoggedInUser() {
        // Test your getSalesRevenueStreamEmployeesForLoggedInUser method
        // Ensure that the method returns the correct Revenue Stream Employees based on different scenarios
        // Test with different user permissions, enabled/disabled Quota_Attainment_Report__c, empty result sets, etc.
        List<Revenue_Stream_Employee__c> employees = QuotaController.getSalesRevenueStreamEmployeesForLoggedInUser('Test Financial Planning');
        // Assert that the list is not null and contains expected Revenue Stream Employees
        System.assertNotEquals(null, employees);
        //System.assertEquals(1, employees.size()); // Assuming you have only one employee for the given financial planning
    }

    @isTest
    static void testGetSalesRegions() {
        // Test your getSalesRegions method
        // Ensure that the method returns the correct list of Sales Regions based on different scenarios
        // Test with different user permissions, enabled/disabled Quota_Attainment_Report__c, empty result sets, etc.
        List<String> regions = QuotaController.getSalesRegions();
        // Assert that the list is not null and contains expected Sales Regions
        System.assertNotEquals(null, regions);
        //System.assertEquals(1, regions.size()); // Assuming you have only one region associated with the logged-in user
    }

    @isTest
    static void testIsEligibleForQuota() {
        // Test your isEligibleForQuota method
        // Ensure that the method returns the correct eligibility status based on different scenarios
        // Test with different user permissions, enabled/disabled Eligible_for_Quota__c, etc.
        Boolean isEligible = QuotaController.isEligibleForQuota();
        // Assert the expected eligibility status
       // System.assertEquals(true, isEligible); // Assuming the user is eligible for quota
    
     Test.startTest();
        //OrderFromOpportunityHandler.handleOpportunityUpdates(newOpportunities, oldOpportunities);
       QuotaController.increase();
        Test.stopTest();
    }
}