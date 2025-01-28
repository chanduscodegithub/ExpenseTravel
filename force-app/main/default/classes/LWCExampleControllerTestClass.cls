@isTest
public class LWCExampleControllerTestClass {
		@isTest static void testGetAccperiodList() {
        // Create test data
                   AcctSeed__Accounting_Period__c testPeriods = new AcctSeed__Accounting_Period__c();
                    testPeriods.Name = '2023-10';
                    testPeriods.AcctSeed__Start_Date__c = Date.today();// Set your desired start date here
                    testPeriods.AcctSeed__End_Date__c	 = Date.today().addDays(30); // Set your desired end date here
                    testPeriods.AcctSeed__Status__c = 'Open' ;// Set the desired status value here
        insert testPeriods;
            LWCExampleController.getAccperiodList();
}	
    @isTest static void testGetGSTReturnList() {
                        Id recordTypeId = Schema.SObjectType.GST_Returns__c.getRecordTypeInfosByDeveloperName().get('Sales').getRecordTypeId();
        List<GST_Returns__c> testGSTReturns = new List<GST_Returns__c>();
        for (Integer i = 1; i <= 5; i++) {
            GST_Returns__c gstReturn = new GST_Returns__c(
                returnFilingMonth__c = '2023-10',
                RecordTypeId = recordTypeId
                
               
            );
            testGSTReturns.add(gstReturn);
        }
        insert testGSTReturns;

                    LWCExampleController.getgstreturnList('2023-10','Sales');

    }
     @isTest static void testGetCSV() {
                GST_Return_Files__c files = new GST_Return_Files__c();
					files.Name = 'Sales 2023-10';
      files.Transaction_Type__c ='Sales ';
      files.Accounting_Period__c = '2023-10';
    
      insert files;
         Attachment attachment = new Attachment();
attachment.ParentId = files.Id;
attachment.Name = files.Name+'.csv';
attachment.Body =Blob.valueOf('hu'); 
insert attachment;
                               LWCExampleController.getcsv('hi','Sales ','2023-10');

    }

}