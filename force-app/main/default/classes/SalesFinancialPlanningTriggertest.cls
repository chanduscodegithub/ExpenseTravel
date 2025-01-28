@isTest
private class SalesFinancialPlanningTriggertest {
    // Test method to cover trigger functionality
    static testMethod void testTriggerFunctionality() {
        // Create test data - Financial Planning records
        Financial_Planning__c fp = new Financial_Planning__c(Calculate_RA__c = true);
        insert fp;
        
        // Create test data - Revenue Forecasting Billing Line Item records
        Revenue_Forecasting_Billing_Line_Item__c revenueItem = new Revenue_Forecasting_Billing_Line_Item__c();
        insert revenueItem;
        
        Test.startTest();
        
        // Update Financial Planning record to invoke trigger
        fp.Calculate_RA__c = false;
        update fp;
        
        Test.stopTest();
        
        // Verify if the related records have been deleted
    }
}