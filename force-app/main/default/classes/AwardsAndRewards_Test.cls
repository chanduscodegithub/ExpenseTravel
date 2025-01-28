@isTest
public class AwardsAndRewards_Test {
    @isTest
    static void testAwardsAndRewardsMethods() {
        // Create test contact
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;

        // Create test user
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User testUser = new User(
            Username = 'testuser_unique@test.com',
            Email = 'testuser@test.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'GMT',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LastName = 'TestUserLastName',
            ProfileId = standardProfile.Id
        );
        insert testUser;

        System.runAs(testUser) {
            // Create and insert test records for custom objects
            CrmitHoliday__c testHoliday = new CrmitHoliday__c(Name = 'Test Holiday', Holiday_Date__c = Date.today());
            insert testHoliday;

            Star_Awarded__c testReward = new Star_Awarded__c(Inform_To__c = 'Test Inform', Star_Type__c = 'Gold', Comment__c = 'Test Comment');
            insert testReward;

            Announcement_Banner__c testBanner = new Announcement_Banner__c(AnnouncementText__c = 'Test Banner Text');
            insert testBanner;

            // Test getAwardDetailsOfEmp method
            List<Award> awards = AwardsAndRewards.getAwardDetailsOfEmp();
            System.assertEquals(0, awards.size());

            // Test getHolidayList method
            List<CrmitHoliday__c> holidays = AwardsAndRewards.getHolidayList();
            System.assertEquals(1, holidays.size());

            // Test getRewardsList method
            List<Star_Awarded__c> rewards = AwardsAndRewards.getRewardsList();
            System.assertEquals(1, rewards.size());

            // Test getBannerText method
            String bannerText = AwardsAndRewards.getBannerText();
            System.assertEquals('Test Banner Text', bannerText);
        }
    }
}