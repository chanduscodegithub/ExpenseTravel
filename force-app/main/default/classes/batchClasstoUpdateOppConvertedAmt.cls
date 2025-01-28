global class batchClasstoUpdateOppConvertedAmt implements Database.Batchable<sObject>{
    
     global Database.QueryLocator start( Database.BatchableContext BC ) {
        
        String query = 'select id, Name, Amount, CloseDate, Amount_Converted_In_USD__c from Opportunity where CloseDate > 2022-04-01 and CloseDate < 2023-03-31';
        return Database.getQueryLocator( query );
    }
    
    global void execute( Database.BatchableContext BC, List< Opportunity > scope ) {
        
        update scope;
    }   
    
    global void finish( Database.BatchableContext BC ) {
        
    }

}