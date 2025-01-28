global class UpdateEngagementPicklistBatchLead implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator([SELECT Id, Last_Engagement_in_Days__c, Last_Engagement__c FROM Lead]);
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> leadList) {
        
        try{
            By_Pass_Validation_Rule__c cs = [select id,Name,byPassCheckbox__c from By_Pass_Validation_Rule__c Limit 1];
            cs.byPassCheckbox__c = true;
            update cs;
            System.debug('modifiedbypass'+cs.byPassCheckbox__c);
            
            
            List<Lead> updatedRecords = new List<Lead>();
            
            for (Lead record : leadList) {
                System.debug('record-'+record);
                //record.Id = record.Id;
                Lead led = new Lead();
                
                decimal lastEngagementInDays = record.Last_Engagement_in_Days__c;
                System.debug('lastEngagementInDays--'+lastEngagementInDays);
                // if (lastEngagementInDays == null || lastEngagementInDays == 0) {
                if (lastEngagementInDays == null ) {
                    
                    System.debug('Test-Null '+lastEngagementInDays);
                    led.Last_Engagement__c = 'No Activities';
                } else if (lastEngagementInDays >= 0 && lastEngagementInDays <= 15) {
                    System.debug('Test-<=15'+lastEngagementInDays);
                    led.Last_Engagement__c = '<15 days';
                } else if (lastEngagementInDays >= 16 && lastEngagementInDays <= 30) {
                    System.debug('Test-between 16 and 30'+lastEngagementInDays);
                    led.Last_Engagement__c = '16-30 days';
                } else if (lastEngagementInDays > 30) {
                    System.debug('Test-between above 30'+lastEngagementInDays);
                    led.Last_Engagement__c = '>30 days';
                }
                else{
                    System.debug('record-'+record);
                }
                if(led != null){
                    led.Id = record.Id;
                    updatedRecords.add(led);   
                } 
            }
            System.debug('Exception--'+updatedRecords.size());
            if (!updatedRecords.isEmpty()) {
                update updatedRecords;
                System.debug('updatedRecords-'+updatedRecords);
            }
        }catch(Exception e){
            System.debug('Exception--'+e.getMessage());
            Log__c log = new Log__c(Method_Name__c='UpdateEngagementPicklistBatchLead', Class_Name__c='UpdateEngagementPicklistBatchLead', Line_Number__c=e.getLineNumber(), Reason__c=e.getMessage());
            insert log;
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        By_Pass_Validation_Rule__c cs = [select id,Name,byPassCheckbox__c from By_Pass_Validation_Rule__c Limit 1];
        cs.byPassCheckbox__c = false;
        update cs;
        System.debug('updatecustom'+cs.byPassCheckbox__c);
        
    }
    
}