public class TeamMembersApex {
    @AuraEnabled
    public static TeamMembersWrapper getTeamMembers(String ProjectId){
        
        System.debug(ProjectId);
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,[SELECT Id,EmployeeName__c,Billable_Hours_Allocated__c,EmployeeName__r.Name,AllocationHours__c,StartDate__c,
                                              EndDate__c,Billing_Status__c,AllocationPercentage__c,ReportingTo__r.Name,Active__c From TeamAllocation__c 
                                              where  Project__c=:ProjectId]);
       List<TeamAllocation__c> teamalllist = securityDecision.getRecords();
        /* List<TeamAllocation__c> teamalllist =[SELECT Id,EmployeeName__c,Billable_Hours_Allocated__c,EmployeeName__r.Name,AllocationHours__c,StartDate__c,
                                              EndDate__c,Billing_Status__c,AllocationPercentage__c,ReportingTo__r.Name,Active__c From TeamAllocation__c 
                                              where  Project__c=:ProjectId];*/
        TeamMembersWrapper tmw = new TeamMembersWrapper();
        for(TeamAllocation__c teamAllo:teamalllist){
            if(teamAllo.Billing_Status__c=='Billable'){
                if(tmw.billableTAList == null){
                    tmw.billableTAList = new  List<TeamAllocation__c>();
                }
                
                tmw.billableTAList.add(teamAllo);
            }
            else if(teamAllo.Billing_Status__c=='IS Development'){
                if(tmw.avishkaarTAList == null){
                    tmw.avishkaarTAList = new  List<TeamAllocation__c>();
                }
                tmw.avishkaarTAList.add(teamAllo);
            }
            else{
                if(tmw.nonBillableTAList == null){
                    tmw.nonBillableTAList = new  List<TeamAllocation__c>();
                }
                tmw.nonBillableTAList.add(teamAllo);
            }
        }
        System.debug('tmw='+tmw);
        return tmw;
    }
    @AuraEnabled
    public static Opportunity getOpprotunityInfo(String ProjId){
        System.debug('ProjId='+ProjId);
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,[SELECT id,Opportunity__c,Region__c FROM Project__c where id=:ProjId LImit 1]);
        List<Project__c> proList = securityDecision.getRecords();
        //List<Project__c> proList = [SELECT id,Opportunity__c,Region__c FROM Project__c where id=:ProjId LImit 1];
        Opportunity opp;
        if(proList!=null&&!proList.isEmpty()){
            
            Project__c pro= proList[0];
            String oppid  = pro.Opportunity__c ;
            try{
                opp =[SELECT id,Opportunity_Region__c,Opportunity_Source__c,Opportunity_Stream__c,FNA_Status__c,Territory2Id,Expected_Effort__c,AccountId From Opportunity where id=:oppid];
            }catch(Exception ex){
                System.debug('No opportunity found');
            }
            System.debug(opp);
        }
        return opp;
    }
    
    public class TeamMembersWrapper{
        @AuraEnabled public List<TeamAllocation__c> billableTAList{get;set;}
        @AuraEnabled public List<TeamAllocation__c> nonBillableTAList{get;set;}
        @AuraEnabled public List<TeamAllocation__c> avishkaarTAList{get;set;}
    }

    @AuraEnabled(cacheable=true)
    public static String retrieveCommunityURL(){
        try {
            return ConnectApi.Communities.getCommunity(Network.getNetworkId()).siteUrl;
        } catch (Exception er) {
            throw new AuraHandledException(er.getMessage());
        }
    }
}