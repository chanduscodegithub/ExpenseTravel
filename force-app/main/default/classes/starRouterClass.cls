public without sharing class starRouterClass {
   @AuraEnabled(Cacheable=true)
   public static string getUserRecords(){
       return starAwardController.getUserRecords();
   }
   @AuraEnabled(Cacheable=true)
   public static String getEmailGroupRecords(){
       return starAwardController.getEmailGroupRecords();
   }
    
   @AuraEnabled
   public static string insertAwardRecord(String awardRecordJsonString){
    return starAwardController.insertAwardRecord(awardRecordJsonString);
    }

    @AuraEnabled(Cacheable=true)
   public static String getAwardedStars(){
       return starAwardController.getAwardedStars();
   }
    
}