@isTest
public class Batch_CreateNotesForEachAccount_Test {
 @TestSetup
    static void setupData()
    {
        List<Account> AccountList = new List<Account>();
        for(Integer i=0;i<10;i++){
            Account a = new Account();
            a.Name = 'Test '+i;
            a.Type = 'Enterprise Account';
            a.Industry ='Health Care';
            AccountList.add(a);
        }
        insert AccountList;
    }
     static testMethod void TestjobforCurrentMonth() {
        // TO DO: implement unit test
       
        Test.startTest();
        Batch_CreateNotesForEachAccount Batch = new Batch_CreateNotesForEachAccount(); 
        Database.executebatch(Batch,30);
        Test.stopTest();
       
    }
}