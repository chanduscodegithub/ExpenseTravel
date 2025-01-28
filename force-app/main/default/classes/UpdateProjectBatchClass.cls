public class UpdateProjectBatchClass Implements Database.batchable<sobject>{
    public string query;
    
   public Database.QueryLocator start(Database.BatchableContext BC){
       string recordid ='';
       Date todaysDate = Date.today();
      query = 'SELECT Id from Project__c ';
      return Database.getQueryLocator(query);
     }
     public  void execute(Database.BatchableContext BC,List<SObject> scope){
         //update scope;
         Database.update(scope,false); 
    
    }
     public void finish(Database.BatchableContext BC){
    }
}