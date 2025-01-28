@IsTest
public with sharing class starRouterClassTest {
    @TestSetup
    static void makeData(){
        
            Profile p = [SELECT Id, name FROM Profile LIMIT 1];
            User u = new User(
                Alias = 'standt',
                Email = 'ravindra@testorg.com',
                LastName = 'ravindra',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = p.Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                Username='standarduser@testorg.com.reavi.user',
                EmailEncodingKey='UTF-8',
                ManagerId=userinfo.getUserId()
            );
            insert u;
        Star_Awarded__c starRecord =new Star_Awarded__c();
            starRecord.To__r=u;
            starRecord.Comment__c='test';
            starRecord.Star_Type__c='Gold';
        insert starRecord;
    }

    @IsTest
    static void getUserRecordsTest(){
        string userJson = starRouterClass.getUserRecords();
        List<User> lstOfUser = (List<User>)JSON.deserialize(userJson, List<User>.class);
        for(User u : lstOfUser){
            if(u.LastName=='ravindra'){
                System.assert(true);
            }
        }
    }

    @IsTest
    static void insertAwardRecordTest(){
        starAwardController.StarRecordWrapper wr = new starAwardController.StarRecordWrapper();
        wr.Comment='comment';
        wr.InformTo='test@mail.com';
        wr.StarType='Gold';
        wr.To=UserInfo.getUserId();

        String st = starRouterClass.insertAwardRecord(JSON.serialize(new List<starAwardController.StarRecordWrapper>{wr}));
        System.assert(st!=null);

        String st2 = starRouterClass.getAwardedStars();
        System.assert(st2!=null);
        
        String st3 = starRouterClass.getEmailGroupRecords();
        System.assert(st3!=null);
        

    }
}