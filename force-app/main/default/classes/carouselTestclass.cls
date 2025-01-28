@isTest
public class carouselTestclass {
    @isTest
    public static void getmessageTest()
    {
         Message__c m =new  Message__c();
         m.Message_body__c='Iam new to this';
         insert m;
        Test.startTest();
        carouselclass.getmessages();
        Test.stopTest();
        
    }

}