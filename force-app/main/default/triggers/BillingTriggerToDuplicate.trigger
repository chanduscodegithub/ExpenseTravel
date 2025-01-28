trigger BillingTriggerToDuplicate on AcctSeed__Billing__c (after insert, after update,before delete) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        List<Billing_History__c> billingHistoryList = new List<Billing_History__c>();

        for (AcctSeed__Billing__c billingRecord : Trigger.new) {
            AcctSeed__Billing__c oldBillingRecord = null;
            if (Trigger.isUpdate) {
                oldBillingRecord = Trigger.oldMap.get(billingRecord.Id);
            }

            if (oldBillingRecord != null) {
                if (!String.isBlank(billingRecord.AcctSeed__Customer__c) && billingRecord.AcctSeed__Customer__c != oldBillingRecord.AcctSeed__Customer__c) {
                    String oldAccountName = BillingTriggerHelper.getFieldModifiedValue(oldBillingRecord, 'Account');
                    String newAccountName = BillingTriggerHelper.getFieldModifiedValue(billingRecord, 'Account');
                    BillingTriggerHelper.createBillingHistoryRecord(billingHistoryList, billingRecord, 'Account', oldAccountName, newAccountName);
                }
                if (billingRecord.AcctSeed__Date__c != oldBillingRecord.AcctSeed__Date__c) {
                    BillingTriggerHelper.createBillingHistoryRecord(billingHistoryList, billingRecord, 'Date', String.valueOf(oldBillingRecord.AcctSeed__Date__c), String.valueOf(billingRecord.AcctSeed__Date__c));
                }
                if (!String.isBlank(billingRecord.AcctSeed__Billing_Comment__c) && billingRecord.AcctSeed__Billing_Comment__c != oldBillingRecord.AcctSeed__Billing_Comment__c) {
                    BillingTriggerHelper.createBillingHistoryRecord(billingHistoryList, billingRecord, 'Description', String.valueOf(oldBillingRecord.AcctSeed__Billing_Comment__c), String.valueOf(billingRecord.AcctSeed__Billing_Comment__c));
                }
                if (billingRecord.AcctSeed__Total__c != null && billingRecord.AcctSeed__Total__c != oldBillingRecord.AcctSeed__Total__c) {
                    BillingTriggerHelper.createBillingHistoryRecord(billingHistoryList, billingRecord, 'Total', String.valueOf(oldBillingRecord.AcctSeed__Total__c), String.valueOf(billingRecord.AcctSeed__Total__c));
                }
            } else {
                // For new records (inserts), create separate billing history records for each modified field
                if (!String.isBlank(billingRecord.AcctSeed__Customer__c)) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    String newAccountName1 = BillingTriggerHelper.getFieldModifiedValue(billingRecord, 'Account');
                    BillingTriggerHelper.createBillingHistoryRecord(billingHistoryList, billingRecord, 'Account', newAccountName1, newAccountName1);
                }
                if (billingRecord.AcctSeed__Date__c != null) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    BillingTriggerHelper.createBillingHistoryRecord(billingHistoryList, billingRecord, 'Date', String.valueOf(billingRecord.AcctSeed__Date__c), String.valueOf(billingRecord.AcctSeed__Date__c));
                }
                if (!String.isBlank(billingRecord.AcctSeed__Billing_Comment__c)) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    BillingTriggerHelper.createBillingHistoryRecord(billingHistoryList, billingRecord, 'Description', billingRecord.AcctSeed__Billing_Comment__c, billingRecord.AcctSeed__Billing_Comment__c);
                }
            }
        }

        if (!billingHistoryList.isEmpty()) {
            insert billingHistoryList;
        }
    }
    
    if (Trigger.isBefore && Trigger.isDelete) {
        List<Billing_History__c> billingHistoryToUpdate = new List<Billing_History__c>();
        
        // Query related Billing History records
        Set<Id> billingIds = Trigger.oldMap.keySet();
        List<Billing_History__c> relatedBillingHistoryList = [SELECT Id FROM Billing_History__c WHERE Billing__c IN :billingIds];
        
        // Update Billing History records to mark them as "Deleted"
        for (Billing_History__c billingHistory : relatedBillingHistoryList) {
            billingHistory.Deleted__c = true;
            billingHistoryToUpdate.add(billingHistory);
        }
        
        // Update the related Billing History records
        if (!billingHistoryToUpdate.isEmpty()) {
            update billingHistoryToUpdate;
        }
    }
}