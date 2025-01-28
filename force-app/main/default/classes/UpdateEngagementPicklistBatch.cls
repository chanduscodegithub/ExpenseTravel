global class UpdateEngagementPicklistBatch implements Database.Batchable<sObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        // collect the batches of records or objects to be passed to execute
        
        String query = 'SELECT Id, Last_Engagement_in_Days__c, Last_Engagement_PickList__c FROM Contact';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> conList) {
        try{
            
            List<Contact> updatedRecords = new List<Contact>();
            
            for (Contact record : conList) {
                System.debug('record-'+record);
                //record.Id = record.Id;
                Contact con = new Contact();
                
                decimal lastEngagementInDays = record.Last_Engagement_in_Days__c;
                // System.debug('lastEngagementInDays--'+lastEngagementInDays);
                // if (lastEngagementInDays == null || lastEngagementInDays == 0) {
                if (lastEngagementInDays == null ) {
                    
                    System.debug('Test-Null '+lastEngagementInDays);
                    con.Last_Engagement_PickList__c = 'No Activities';
                } else if (lastEngagementInDays >= 0 && lastEngagementInDays <= 15) {
                    System.debug('Test-<=15'+lastEngagementInDays);
                    con.Last_Engagement_PickList__c = '<15';
                } else if (lastEngagementInDays >= 16 && lastEngagementInDays <= 30) {
                    System.debug('Test-between 16 and 30'+lastEngagementInDays);
                    con.Last_Engagement_PickList__c = '16 - 30';
                } else if (lastEngagementInDays > 30) {
                    System.debug('Test-between above 30'+lastEngagementInDays);
                    con.Last_Engagement_PickList__c = '>31';
                }
                else{
                    System.debug('record-'+record);
                }
                if(con != null){
                    con.Id = record.Id;
                    updatedRecords.add(con);   
                } 
            }
            System.debug('Exceptiomn--'+updatedRecords.size());
            if (!updatedRecords.isEmpty()) {
                update updatedRecords;
                System.debug('updatedRecords-'+updatedRecords);
            }
        }
        
        catch(Exception e)
        {
            System.debug('Exceptiomn--'+e.getMessage());
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
}