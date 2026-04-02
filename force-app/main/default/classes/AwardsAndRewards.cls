public without sharing class AwardsAndRewards {
    @AuraEnabled(cacheable=true) 
    public static List<Award> getAwardDetailsOfEmp(){ 
        	User userObj = [Select Id,contactid,Name from User where Id = : Userinfo.getUserId() limit 1];
        	//system.debug('userObj'+ userObj);
        	List<Award> awardCycle = [Select Id, Name, AwardDate, AwardedBy, Status, OwnerId, VerifiedDate from Award];
        	system.debug('AwardCycle'+ awardCycle);
        //where Contact__c = : userObj.contactid
        return awardCycle;
    }
    
    @AuraEnabled(cacheable=true) 
    public static List<Holiday__c> getHolidayList(String region){
        //String Region = [SELECT CURRENT_REGION() From ]; 
        //System.debug('Region'+ Region);
        List<Holiday__c> holidayList= new List<Holiday__c>();
        if(region == ''){
            holidayList = HolidayHandler.getHolidays();
        }else{
            holidayList = HolidayHandler.getHolidayListOfDifferentLocation(region);
        }
        
        
        List<Holiday__c> holidays= new List<Holiday__c>();
        for(Holiday__c h:holidayList)
        {
            Holiday__c holiday = new Holiday__c();
            if(h.Date__c >= System.today())
            {
                holidays.add(h);
            }
        }
        //List<CrmitHoliday__c> holidayList = [Select Id, Name, Holiday_Date__c, Is_Restricted_Holiday__c FROM CrmitHoliday__c WHERE Holiday_Date__c>=TODAY ORDER BY Holiday_Date__c ];
        return holidays;
    }
    
    @AuraEnabled(cacheable=true) 
    public static List<Star_Awarded__c> getRewardsList(){
        List<Star_Awarded__c> rewardList = [Select Id,CreatedById,Inform_To__c, Star_Type__c, Comment__c, To__r.Name,CreatedDate,CreatedBy.Name FROM Star_Awarded__c WHERE CreatedDate >= LAST_N_MONTHS:3
        ORDER BY CreatedDate DESC]; 
        //ployee__c emp = [Select Id Name from Employee__c];
        return rewardList;
    }
    
    @AuraEnabled(cacheable=true) 
    public static String getBannerText(){
        Announcement_Banner__c banner = Announcement_Banner__c.getInstance();
        return banner.AnnouncementText__c;
    }
}
