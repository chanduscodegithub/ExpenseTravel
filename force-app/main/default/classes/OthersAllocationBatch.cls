global class OthersAllocationBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        Date startDate = Date.newInstance(2022, 03, 27);
        System.debug('Date: '+startDate);
        String query = 'SELECT Name, EmployeeName__c, EmployeeName__r.Name FROM TeamAllocation__c WHERE EndDate__c > :startDate';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<TeamAllocation__c> scope){
          createOtherAllocationHelper.createTA(scope);
    }
    global void finish(Database.BatchableContext BC){
        
    }
}