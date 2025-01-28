trigger UpdateRevenueAttainmentRegion on Billing__c (after insert, after update) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        List<Billing__c> uncheckedBillings = new List<Billing__c>();
        
        for (Billing__c billing : Trigger.new) {
            // Check if the "Automate Revenue Attainment" checkbox is unchecked
            if (!billing.Automate_Revenue_Attainment__c) {
                uncheckedBillings.add(billing);
            }
        }
        
        if (!uncheckedBillings.isEmpty()) {
            UpdateRevenueAttainmentEmployeeHelper.updateRevenueAttainmentEmp(uncheckedBillings);
            UpdateRevenueAttainmentRegionHelper.updateRevenueAttainment(uncheckedBillings);
        }
    }
}