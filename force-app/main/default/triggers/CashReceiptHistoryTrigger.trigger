trigger CashReceiptHistoryTrigger on AcctSeed__Cash_Receipt__c (after insert, after update,before delete) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        List<Cash_Receipt_History__c> cashReceiptHistoryList = new List<Cash_Receipt_History__c>();

        for (AcctSeed__Cash_Receipt__c cashReceiptRecord : Trigger.new) {
            AcctSeed__Cash_Receipt__c oldcashReceiptRecord = null;
            if (Trigger.isUpdate) {
                oldcashReceiptRecord = Trigger.oldMap.get(cashReceiptRecord.Id);
            }

            if (oldcashReceiptRecord != null) {
                if (!String.isBlank(cashReceiptRecord.AcctSeed__Account__c) && cashReceiptRecord.AcctSeed__Account__c != oldcashReceiptRecord.AcctSeed__Account__c) {
                    String oldAccountName = CashReceiptHistory.getFieldModifiedValue(oldcashReceiptRecord, 'Account');
                    String newAccountName = CashReceiptHistory.getFieldModifiedValue(cashReceiptRecord, 'Account');
                    CashReceiptHistory.createCashReceiptHistoryRecord(cashReceiptHistoryList, cashReceiptRecord, 'Account', oldAccountName, newAccountName);
                }
                if (cashReceiptRecord.AcctSeed__Amount__c != null && cashReceiptRecord.AcctSeed__Amount__c != oldcashReceiptRecord.AcctSeed__Amount__c) {
                    CashReceiptHistory.createCashReceiptHistoryRecord(cashReceiptHistoryList, cashReceiptRecord, 'Total Amount', String.valueOf(oldcashReceiptRecord.AcctSeed__Amount__c), String.valueOf(cashReceiptRecord.AcctSeed__Amount__c));
                }
                if (cashReceiptRecord.AcctSeed__Ledger__c != oldcashReceiptRecord.AcctSeed__Ledger__c) {
                    String oldAccountName = CashReceiptHistory.getFieldModifiedValue(oldcashReceiptRecord, 'Ledger');
                    String newAccountName = CashReceiptHistory.getFieldModifiedValue(cashReceiptRecord, 'Ledger');
                    CashReceiptHistory.createCashReceiptHistoryRecord(cashReceiptHistoryList, cashReceiptRecord, 'Ledger', oldAccountName,newAccountName);
                }
                if (!String.isBlank(cashReceiptRecord.AcctSeed__Bank_Account__c) && cashReceiptRecord.AcctSeed__Bank_Account__c != oldcashReceiptRecord.AcctSeed__Bank_Account__c) {
                    String oldAccountName = CashReceiptHistory.getFieldModifiedValue(oldcashReceiptRecord, 'Bank Account');
                    String newAccountName = CashReceiptHistory.getFieldModifiedValue(cashReceiptRecord, 'Bank Account');
                    CashReceiptHistory.createCashReceiptHistoryRecord(cashReceiptHistoryList, cashReceiptRecord, 'Bank Account',oldAccountName,newAccountName);
                }
                if (cashReceiptRecord.AcctSeed__Credit_GL_Account__c != null && cashReceiptRecord.AcctSeed__Credit_GL_Account__c != oldcashReceiptRecord.AcctSeed__Credit_GL_Account__c) {
                    String oldAccountName = CashReceiptHistory.getFieldModifiedValue(oldcashReceiptRecord, 'Credit GL Account');
                    String newAccountName = CashReceiptHistory.getFieldModifiedValue(cashReceiptRecord, 'Credit GL Account');
                    CashReceiptHistory.createCashReceiptHistoryRecord(cashReceiptHistoryList, cashReceiptRecord, 'Credit GL Account', oldAccountName,newAccountName);
                }
                if (cashReceiptRecord.AcctSeed__Receipt_Date__c != oldcashReceiptRecord.AcctSeed__Receipt_Date__c) {
                    CashReceiptHistory.createCashReceiptHistoryRecord(cashReceiptHistoryList, cashReceiptRecord, 'Receipt Date', String.valueOf(oldcashReceiptRecord.AcctSeed__Receipt_Date__c), String.valueOf(cashReceiptRecord.AcctSeed__Receipt_Date__c));
                }
                if (cashReceiptRecord.Billing_Id__c != oldcashReceiptRecord.Billing_Id__c) {
                    String oldAccountName = CashReceiptHistory.getFieldModifiedValue(oldcashReceiptRecord, 'Billing');
                    String newAccountName = CashReceiptHistory.getFieldModifiedValue(cashReceiptRecord, 'Billing');
                    CashReceiptHistory.createCashReceiptHistoryRecord(cashReceiptHistoryList, cashReceiptRecord, 'Billing', oldAccountName,newAccountName);
                }
                if (cashReceiptRecord.AcctSeed__Accounting_Period__c != null && cashReceiptRecord.AcctSeed__Accounting_Period__c != oldcashReceiptRecord.AcctSeed__Accounting_Period__c) {
                    String oldAccountName = CashReceiptHistory.getFieldModifiedValue(oldcashReceiptRecord, 'Accounting Period');
                    String newAccountName = CashReceiptHistory.getFieldModifiedValue(cashReceiptRecord, 'Accounting Period');
                    CashReceiptHistory.createCashReceiptHistoryRecord(cashReceiptHistoryList, cashReceiptRecord, 'Accounting Period', oldAccountName,newAccountName);
                }
            } else {
                // For new records (inserts), create separate billing history records for each modified field
                if (!String.isBlank(cashReceiptRecord.AcctSeed__Account__c)) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    String newAccountName1 = CashReceiptHistory.getFieldModifiedValue(cashReceiptRecord, 'Account');
                    CashReceiptHistory.createCashReceiptHistoryRecord(cashReceiptHistoryList, cashReceiptRecord, 'Account', newAccountName1, newAccountName1);
                }
                if (cashReceiptRecord.AcctSeed__Amount__c != null) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    CashReceiptHistory.createCashReceiptHistoryRecord(cashReceiptHistoryList, cashReceiptRecord, 'Total', String.valueOf(cashReceiptRecord.AcctSeed__Amount__c), String.valueOf(cashReceiptRecord.AcctSeed__Amount__c));
                }
                if (cashReceiptRecord.AcctSeed__Receipt_Date__c != null) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    CashReceiptHistory.createCashReceiptHistoryRecord(cashReceiptHistoryList, cashReceiptRecord, 'Receipt Date', String.valueOf(cashReceiptRecord.AcctSeed__Receipt_Date__c), String.valueOf(cashReceiptRecord.AcctSeed__Receipt_Date__c));
                }
                if (cashReceiptRecord.AcctSeed__Ledger__c != null) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    String newAccountName1 = CashReceiptHistory.getFieldModifiedValue(cashReceiptRecord, 'Ledger');
                    CashReceiptHistory.createCashReceiptHistoryRecord(cashReceiptHistoryList, cashReceiptRecord, 'Ledger',newAccountName1, newAccountName1);
                }
                if (!String.isBlank(cashReceiptRecord.AcctSeed__Bank_Account__c)) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    String newAccountName1 = CashReceiptHistory.getFieldModifiedValue(cashReceiptRecord, 'Bank Account');
                    CashReceiptHistory.createCashReceiptHistoryRecord(cashReceiptHistoryList, cashReceiptRecord, 'Bank Account', newAccountName1, newAccountName1);
                }
                if (!String.isBlank(cashReceiptRecord.AcctSeed__Credit_GL_Account__c)) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    String newAccountName1 = CashReceiptHistory.getFieldModifiedValue(cashReceiptRecord, 'Credit GL Account');
                    CashReceiptHistory.createCashReceiptHistoryRecord(cashReceiptHistoryList, cashReceiptRecord, 'Credit GL Account',newAccountName1, newAccountName1);
                }
                if (!String.isBlank(cashReceiptRecord.Billing_Id__c)) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    String newAccountName1 = CashReceiptHistory.getFieldModifiedValue(cashReceiptRecord, 'Billing');
                    CashReceiptHistory.createCashReceiptHistoryRecord(cashReceiptHistoryList, cashReceiptRecord, 'Billing',newAccountName1, newAccountName1);
                }
                if (!String.isBlank(cashReceiptRecord.AcctSeed__Accounting_Period__c)) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    String newAccountName1 = CashReceiptHistory.getFieldModifiedValue(cashReceiptRecord, 'Accounting Period');
                    CashReceiptHistory.createCashReceiptHistoryRecord(cashReceiptHistoryList, cashReceiptRecord, 'Accounting Period',newAccountName1, newAccountName1);
                }
            }
        }

        if (!cashReceiptHistoryList.isEmpty()) {
            insert cashReceiptHistoryList;
        }
    }
    
    if (Trigger.isBefore && Trigger.isDelete) {
        List<Cash_Receipt_History__c> payableHistoryToUpdate = new List<Cash_Receipt_History__c>();
        
        // Query related Billing History records
        Set<Id> cashreceiptIds = Trigger.oldMap.keySet();
        List<Cash_Receipt_History__c> relatedcashReceiptHistoryList = [SELECT Id FROM Cash_Receipt_History__c WHERE Cash_Receipt__c IN :cashreceiptIds];
        
        // Update Billing History records to mark them as "Deleted"
        for (Cash_Receipt_History__c payableHistory : relatedcashReceiptHistoryList) {
            payableHistory.Deleted__c = true;
            payableHistoryToUpdate.add(payableHistory);
        }
        
        // Update the related Billing History records
        if (!payableHistoryToUpdate.isEmpty()) {
            update payableHistoryToUpdate;
        }
    }
}