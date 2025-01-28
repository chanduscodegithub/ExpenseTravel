trigger PayableHistoryTrigger on AcctSeed__Account_Payable__c (after insert, after update,before delete) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        List<Payable_History__c> payableHistoryList = new List<Payable_History__c>();

        for (AcctSeed__Account_Payable__c payableRecord : Trigger.new) {
            AcctSeed__Account_Payable__c oldpayableRecord = null;
            if (Trigger.isUpdate) {
                oldpayableRecord = Trigger.oldMap.get(payableRecord.Id);
            }

            if (oldpayableRecord != null) {
                if (!String.isBlank(payableRecord.AcctSeed__Vendor__c) && payableRecord.AcctSeed__Vendor__c != oldpayableRecord.AcctSeed__Vendor__c) {
                    String oldAccountName = PayableHistoryHelper.getFieldModifiedValue(oldpayableRecord, 'Account');
                    String newAccountName = PayableHistoryHelper.getFieldModifiedValue(payableRecord, 'Account');
                    PayableHistoryHelper.createPayableHistoryRecord(payableHistoryList, payableRecord, 'Account', oldAccountName, newAccountName);
                }
                if (payableRecord.AcctSeed__Date__c != oldpayableRecord.AcctSeed__Date__c) {
                    PayableHistoryHelper.createPayableHistoryRecord(payableHistoryList, payableRecord, 'Date', String.valueOf(oldpayableRecord.AcctSeed__Date__c), String.valueOf(payableRecord.AcctSeed__Date__c));
                }
                if (!String.isBlank(payableRecord.Description__c) && payableRecord.Description__c != oldpayableRecord.Description__c) {
                    PayableHistoryHelper.createPayableHistoryRecord(payableHistoryList, payableRecord, 'Description', String.valueOf(oldpayableRecord.Description__c), String.valueOf(payableRecord.Description__c));
                }
                if (payableRecord.AcctSeed__Total__c != null && payableRecord.AcctSeed__Total__c != oldpayableRecord.AcctSeed__Total__c) {
                    PayableHistoryHelper.createPayableHistoryRecord(payableHistoryList, payableRecord, 'Total', String.valueOf(oldpayableRecord.AcctSeed__Total__c), String.valueOf(payableRecord.AcctSeed__Total__c));
                }
                if (payableRecord.AcctSeed__Ledger__c != oldpayableRecord.AcctSeed__Ledger__c) {
                    String oldAccountName = PayableHistoryHelper.getFieldModifiedValue(oldpayableRecord, 'Ledger');
                    String newAccountName = PayableHistoryHelper.getFieldModifiedValue(payableRecord, 'Ledger');
                    PayableHistoryHelper.createPayableHistoryRecord(payableHistoryList, payableRecord, 'Ledger', oldAccountName,newAccountName);
                }
                if (payableRecord.AcctSeed__Accounting_Period__c != null && oldpayableRecord.AcctSeed__Accounting_Period__c != oldpayableRecord.AcctSeed__Accounting_Period__c) {
                    String oldAccountName = PayableHistoryHelper.getFieldModifiedValue(oldpayableRecord, 'Accounting Period');
                    String newAccountName = PayableHistoryHelper.getFieldModifiedValue(payableRecord, 'Accounting Period');
                    PayableHistoryHelper.createPayableHistoryRecord(payableHistoryList, payableRecord, 'Accounting Period', oldAccountName,newAccountName);
                }
            } else {
                // For new records (inserts), create separate billing history records for each modified field
                if (!String.isBlank(payableRecord.AcctSeed__Vendor__c)) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    String newAccountName1 = PayableHistoryHelper.getFieldModifiedValue(payableRecord, 'Account');
                    PayableHistoryHelper.createPayableHistoryRecord(payableHistoryList, payableRecord, 'Account', newAccountName1, newAccountName1);
                }
                if (payableRecord.AcctSeed__Date__c != null) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    PayableHistoryHelper.createPayableHistoryRecord(payableHistoryList, payableRecord, 'Date', String.valueOf(payableRecord.AcctSeed__Date__c), String.valueOf(payableRecord.AcctSeed__Date__c));
                }
                if (!String.isBlank(payableRecord.Description__c)) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    PayableHistoryHelper.createPayableHistoryRecord(payableHistoryList, payableRecord, 'Description', payableRecord.Description__c, payableRecord.Description__c);
                }
                    if (payableRecord.AcctSeed__Total__c != null) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    PayableHistoryHelper.createPayableHistoryRecord(payableHistoryList, payableRecord, 'Total', String.valueOf(payableRecord.AcctSeed__Total__c), String.valueOf(payableRecord.AcctSeed__Total__c));
                }
                if (payableRecord.AcctSeed__Ledger__c != null) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    String newAccountName1 = PayableHistoryHelper.getFieldModifiedValue(payableRecord, 'Ledger');
                    PayableHistoryHelper.createPayableHistoryRecord(payableHistoryList, payableRecord, 'Ledger',newAccountName1, newAccountName1);
                }
                if (!String.isBlank(payableRecord.AcctSeed__Accounting_Period__c)) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    String newAccountName1 = PayableHistoryHelper.getFieldModifiedValue(payableRecord, 'Accounting Period');
                    PayableHistoryHelper.createPayableHistoryRecord(payableHistoryList, payableRecord, 'Accounting Period',newAccountName1, newAccountName1);
                }
            }
        }

        if (!payableHistoryList.isEmpty()) {
            insert payableHistoryList;
        }
    }
    
    if (Trigger.isBefore && Trigger.isDelete) {
        List<Payable_History__c> payableHistoryToUpdate = new List<Payable_History__c>();
        
        // Query related Billing History records
        Set<Id> payableIds = Trigger.oldMap.keySet();
        List<Payable_History__c> relatedPayableHistoryList = [SELECT Id FROM Payable_History__c WHERE Payable__c IN :payableIds];
        
        // Update Billing History records to mark them as "Deleted"
        for (Payable_History__c payableHistory : relatedPayableHistoryList) {
            payableHistory.Deleted__c = true;
            payableHistoryToUpdate.add(payableHistory);
        }
        
        // Update the related Billing History records
        if (!payableHistoryToUpdate.isEmpty()) {
            update payableHistoryToUpdate;
        }
    }
}