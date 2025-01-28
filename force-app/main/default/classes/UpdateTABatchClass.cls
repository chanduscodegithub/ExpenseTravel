public class UpdateTABatchClass Implements Database.batchable<sobject>{
   public string query;
    
   public Database.QueryLocator start(Database.BatchableContext bc){
      query = 'SELECT Id,StartDate__c,EndDate__c from TeamAllocation__c where StartDate__c=TODAY OR EndDate__c=YESTERDAY';
       return Database.getQueryLocator(query);

     }
     public  void execute(Database.BatchableContext bc,List<SObject> scope){
         List<TeamAllocation__c> getTeamAllowcationRecords=new List<TeamAllocation__c>();
         if(scope != null){
            getTeamAllowcationRecords= scope; 
         for(TeamAllocation__c eachTA:getTeamAllowcationRecords){
              if(eachTA.StartDate__c==Date.today()){
                eachTA.Batch_Status__c='Start Date';
              }
              else{
                eachTA.Batch_Status__c='End Date';  
              }
         }
         update getTeamAllowcationRecords;
        }
    
    }
     public void finish(Database.BatchableContext bc){
    }
}