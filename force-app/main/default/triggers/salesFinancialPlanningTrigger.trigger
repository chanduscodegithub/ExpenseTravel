trigger salesFinancialPlanningTrigger on Financial_Planning__c (after insert, after update) {
    Set<Id> recordIds = new Set<Id>();
    List<Financial_Planning__c> recordsToUpdate = new List<Financial_Planning__c>();
    Map<Id, Integer> recordFinancialYears = new Map<Id, Integer>(); // Map to store Financial Year for each record as an Integer
    
    for (Financial_Planning__c fp : Trigger.new) {
        if (fp.Calculate_RA__c && (Trigger.isInsert || fp.Calculate_RA__c != Trigger.oldMap.get(fp.Id).Calculate_RA__c)) {
            recordIds.add(fp.Id);
            // Convert the Financial Year string to an Integer
            Integer fpYear = fp.FP_Year__c != null ? Integer.valueOf(fp.FP_Year__c) : null;
            recordFinancialYears.put(fp.Id, fpYear); // Store Financial Year for each record
        }
    }
    
    if (!recordIds.isEmpty()) {
        // Instantiate the batch class
        SalesRevenueAttainmentEmployeeBatch batchJob1 = new SalesRevenueAttainmentEmployeeBatch(recordIds, Trigger.new[0].FP_Year__c);
        Database.executeBatch(batchJob1);
        
        // Update Financial Planning records
        for (Id recordId : recordIds) {
            Financial_Planning__c fp = new Financial_Planning__c(Id = recordId, Calculate_RA__c = false);
            recordsToUpdate.add(fp);
        }
        update recordsToUpdate;
    }
}