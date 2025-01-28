trigger BillingLineTriggerToDuplicate on AcctSeed__Billing_Line__c (after insert, after update,before delete) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        List<Billing_History__c> billingHistoryList = new List<Billing_History__c>();
        
        for (AcctSeed__Billing_Line__c billingLineRecord : Trigger.new) {
            AcctSeed__Billing_Line__c oldBillingLineRecord = null;
            if (Trigger.isUpdate) {
                oldBillingLineRecord = Trigger.oldMap.get(billingLineRecord.Id);
            }
            
            if (oldBillingLineRecord != null) {
                if (!String.isBlank(billingLineRecord.AcctSeed__Revenue_GL_Account__c) && billingLineRecord.AcctSeed__Revenue_GL_Account__c != oldBillingLineRecord.AcctSeed__Revenue_GL_Account__c) {
                    String oldAccountName = BillingLineTriggerHelper.getFieldModifiedValue(oldBillingLineRecord, 'Revenue GL Account');
                    String newAccountName = BillingLineTriggerHelper.getFieldModifiedValue(billingLineRecord, 'Revenue GL Account');
                    BillingLineTriggerHelper.createBillingHistoryRecord(billingHistoryList, billingLineRecord, 'Revenue GL Account',oldAccountName,newAccountName);
                }
                if (billingLineRecord.AcctSeed__Total__c != oldBillingLineRecord.AcctSeed__Total__c) {
                    BillingLineTriggerHelper.createBillingHistoryRecord(billingHistoryList, billingLineRecord, 'BillingLine Total', String.valueOf(oldBillingLineRecord.AcctSeed__Total__c), String.valueOf(billingLineRecord.AcctSeed__Total__c));
                }
            } else {
                // For new records (inserts), create separate billing history records for each modified field
                if (!String.isBlank(billingLineRecord.AcctSeed__Revenue_GL_Account__c)) {
                    String newAccountName1 = BillingLineTriggerHelper.getFieldModifiedValue(billingLineRecord, 'Revenue GL Account');
                    BillingLineTriggerHelper.createBillingHistoryRecord(billingHistoryList, billingLineRecord, 'Revenue GL Account', newAccountName1, newAccountName1);
                }
                if (billingLineRecord.AcctSeed__Total__c != null) {
                    BillingLineTriggerHelper.createBillingHistoryRecord(billingHistoryList, billingLineRecord, 'BillingLine Total', String.valueOf(billingLineRecord.AcctSeed__Total__c), String.valueOf(billingLineRecord.AcctSeed__Total__c));
                }
            }
        }
        
        if (!billingHistoryList.isEmpty()) {
            insert billingHistoryList;
        }
    }
    if (Trigger.isBefore && Trigger.isDelete) {
        Set<String> billingLineNames = new Set<String>();
        
        for (AcctSeed__Billing_Line__c billingLineRecord : Trigger.old) {
            billingLineNames.add(billingLineRecord.Name);
        }
        
        List<Billing_History__c> billingHistoryToUpdate = [
            SELECT Id, Deleted__c
            FROM Billing_History__c
            WHERE BillingLineHistory__c IN :billingLineNames
        ];
        
        for (Billing_History__c relatedBillingHistory : billingHistoryToUpdate) {
            relatedBillingHistory.Deleted__c = true;
        }
        
        if (!billingHistoryToUpdate.isEmpty()) {
            update billingHistoryToUpdate;
        }
    }
    
}