trigger FinancialPlanningTrigger on Financial_Planning__c (after insert, after update) {
    Set<Id> recordIds = new Set<Id>();
    List<Financial_Planning__c> recordsToUpdate = new List<Financial_Planning__c>();
    for (Financial_Planning__c fp : Trigger.new) {
        if (fp.Calculate_RA__c && (Trigger.isInsert || fp.Calculate_RA__c != Trigger.oldMap.get(fp.Id).Calculate_RA__c)) {
            recordIds.add(fp.Id);
        }
    }
    
    for (Financial_Planning__c fp : [SELECT Id, Related_Records_Deleted__c FROM Financial_Planning__c WHERE Id IN :recordIds]) {
        if (!fp.Related_Records_Deleted__c) {
            List<Revenue_Forecasting_Billing_Line_Item__c> relatedRevenueItemIds = [SELECT Id FROM Revenue_Forecasting_Billing_Line_Item__c];
            
            if (!relatedRevenueItemIds.isEmpty()) {
                Database.delete(relatedRevenueItemIds);
                
                // Mark the related records as deleted
                fp.Related_Records_Deleted__c = true;
                recordsToUpdate.add(fp);
            }
        }
    }

    if (!recordIds.isEmpty()) {
        UpdateRevenueAttainmentBatch batchJob = new UpdateRevenueAttainmentBatch(recordIds);
        Database.executeBatch(batchJob);
        
        UpdateRevenueAttainmentEmployeeBatch batchJob2 = new UpdateRevenueAttainmentEmployeeBatch(recordIds);
        Database.executeBatch(batchJob2);
        
        List<Financial_Planning__c> recordsToUpdate = new List<Financial_Planning__c>();
        for (Id recordId : recordIds) {
            Financial_Planning__c fp = new Financial_Planning__c(Id = recordId, Calculate_RA__c = false);
            recordsToUpdate.add(fp);
        }
        update recordsToUpdate;
    }
}