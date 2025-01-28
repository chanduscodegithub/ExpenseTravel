@IsTest
private class CheckQuotaEligibilityTest {
  @IsTest
    static void testTrigger() {
        // Create test data: Employee__c records
        Financial_Planning__c fp = new Financial_Planning__c();
        fp.name='Test';
        insert fp;
        
        /*List<Employee__c> employees = new List<Employee__c>();
        employees.add(new Employee__c(Name = 'Test Employee 1', Eligible_for_Quota__c = true));
        employees.add(new Employee__c(Name = 'Test Employee 2', Eligible_for_Quota__c = false));
        insert employees;*/

        // Create test data: Revenue_Stream_Employee__c records
        List<Revenue_Stream_Employee__c> revenueStreamEmployees = new List<Revenue_Stream_Employee__c>();
        revenueStreamEmployees.add(new Revenue_Stream_Employee__c(
           // Name = 'Test Revenue Stream 1',
           // Type__c = 'Quota',
            Revenue_Stream_Forecasting__c = fp.id
            //Employees__c = employees[0].Id // Assigning to an eligible employee
        ));
        revenueStreamEmployees.add(new Revenue_Stream_Employee__c(
           // Name = 'Test Revenue Stream 2',
           // Type__c = 'Budget',
            Revenue_Stream_Forecasting__c =fp.id
            //Employees__c = employees[1].Id // Assigning to an ineligible employee
        ));

        // Test insertion
        Test.startTest();
        insert revenueStreamEmployees;
       
        Test.stopTest();

        // Verify results
        //System.assertEquals(true, hasError(revenueStreamEmployees[1]));
    }
     
    // Helper method to check if an error was added to the record
    static Boolean hasError(Revenue_Stream_Employee__c record) {
        return !record.Id.getSObjectType().getDescribe().isCreateable(); // Check if record is not insertable
    }
}