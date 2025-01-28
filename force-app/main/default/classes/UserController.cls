public with sharing class UserController {
    
    @AuraEnabled(cacheable=true)
    public static String getCurrentUserProfileName(){
        String userId = UserInfo.getUserId();
        User currentUser=[Select Profile.Name from User WHERE Id=:userId Limit 1];
            return currentUser.Profile.Name;
    }
    
}