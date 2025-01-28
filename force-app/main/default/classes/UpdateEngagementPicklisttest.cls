@isTest
public class UpdateEngagementPicklisttest {
    @isTest
    static void testupdate(){
        Contact newcon = new Contact();
        newcon.LastName = 'Test1';
        newcon.Phone='2121212121';
        insert newcon;
        
        insert new Task(
    ActivityDate = Date.today(),
    Subject = 'foo',
    Status = 'Completed',
    WhoId = newcon.Id
);
      
        
        
          Contact newcon3 = new Contact();
				newcon3.LastName='TEast1';
        		newcon3.Phone='4545455454';
        insert newcon3;
                            insert new Task(
    ActivityDate = Date.today()-65,
    Subject = 'foo',
    Status = 'Completed',
    WhoId = newcon3.Id
);
                 Contact n2 = new Contact();
				n2.LastName='TEast1';
        		n2.Phone='4545455454';
        insert n2;
                            insert new Task(
    ActivityDate = Date.today()-10,
    Subject = 'foo',
    Status = 'Completed',
    WhoId = n2.Id
);
                         Contact bn3 = new Contact();
				bn3.LastName='TEast1';
        		bn3.Phone='4545455454';
        insert bn3;
                            insert new Task(
    ActivityDate = null,
    Subject = 'foo',
    Status = 'Completed',
    WhoId = bn3.Id
);
        
        
        
  Test.startTest();
        UpdateEngagementPicklist schedulableInstance = new UpdateEngagementPicklist();
        String cronExpression = '0 0 0 * * ?'; // Run once daily
        System.schedule('Test Schedule', cronExpression, schedulableInstance);
        Test.stopTest();        
        
    }

}