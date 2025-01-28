public  without sharing  class Performanceratingrelatedlistclass {
    @AuraEnabled(cacheable=true) 
    public static  Performance_Rating__c getDetailsOfpr(String recordId){
        return [select id,Status__c,Name, Employee__r.ReportingTo__r.Name from Performance_Rating__c where Employee__c =:recordId];
        
    }
    @AuraEnabled
    public static  String getCommunityURL(){
        try {
            System.debug('~~CommunityURL '+ConnectApi.Communities.getCommunity(Network.getNetworkId()).siteUrl);
            return ConnectApi.Communities.getCommunity(Network.getNetworkId()).siteUrl;
        } catch (Exception er) {
            throw new AuraHandledException(er.getMessage());
        }        
    }
    @AuraEnabled
    public static boolean profileChk(){
       String profileName = [Select id , name from Profile where id=:UserInfo.getProfileId()]?.Name;
       return (profileName=='Partner Community Login User_Full Access'||profileName=='System Administrator')?true:false;
    }
    
}