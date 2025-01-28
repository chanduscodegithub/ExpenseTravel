/*
 * This class is created to do dummy update on records so that Apex Triggers fire and update the manual sharing.
*/
public class ManualSharingBatch implements Database.Batchable<sObject>{
    public final String objectName;
    public final String whereCond;
    
    public ManualSharingBatch(String objName, String whereCondition){
        objectName	= objName;
        whereCond	= whereCondition;
    }
    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT ID FROM '+objectName;
        if(whereCond != null){
            query	+= ' WHERE '+whereCond;
        }
        System.debug('the query '+query);
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext BC, List<sObject> scope){
        
        //list for all possible objects
        List<Project__c> projects		= new List<Project__c>();
        List<Case> cases				= new List<Case>();
        List<Support_SLA__c> slas		= new List<Support_SLA__c>();
        List<TeamAllocation__c> teams	= new List<TeamAllocation__c>();
        Schema.SObjectType sObjectType = scope[0].getSObjectType();
        SYstem.debug('sObjectType'+sObjectType);
        
        String objectName =sObjectType.getDescribe().getName();
        SWITCH on objectName{
            WHEN 'Project__c' {
                projects  = (List<Project__c>)scope ;
                for(Project__c p : projects){
                    p.put('Manually_Shared__c',true);
                }
                try{
                    Database.update(projects,false);
                }Catch(Exception e){
                    System.debug('there is an error in projects '+e.getMessage());
                }
            }
            WHEN 'Case' {
                cases = (List<Case>)scope;
                for(Case c : cases){
                    c.put('Manually_Shared__c',true);
                }
                try{
                    Database.update(cases,false);
                }Catch(Exception e){
                    System.debug('there is an error in Cases '+e.getMessage());
                }
            }
            WHEN 'Support_SLA__c' {
                slas = (List<Support_SLA__c>)scope;
                for(Support_SLA__c s : slas){
                    s.put('Manually_Shared__c',true);
                }
                try{
                    Database.update(slas,false);
                }Catch(Exception e){
                    System.debug('there is an error in SLAs '+e.getMessage());
                }
            }
            WHEN 'TeamAllocation__c' {
                teams = (List<TeamAllocation__c>)scope;
                for(TeamAllocation__c t : teams){
                    t.put('Manually_Shared__c',true);
                }
                try{
                    Database.update(teams,false);
                }Catch(Exception e){
                    System.debug('there is an error in Teams '+e.getMessage());
                }
            }
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}