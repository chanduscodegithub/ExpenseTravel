trigger CashDisbursementHistoryTrigger on AcctSeed__Cash_Disbursement__c (after insert, after update,before delete) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        List<Cash_Disbursement_History__c> CashDisbursementHistoryList = new List<Cash_Disbursement_History__c>();

        for (AcctSeed__Cash_Disbursement__c CashDisbursementRecord : Trigger.new) {
            AcctSeed__Cash_Disbursement__c oldCashDisbursementRecord = null;
            if (Trigger.isUpdate) {
                oldCashDisbursementRecord = Trigger.oldMap.get(CashDisbursementRecord.Id);
            }

            if (oldCashDisbursementRecord != null) {
                if (!String.isBlank(CashDisbursementRecord.AcctSeed__Vendor__c) && CashDisbursementRecord.AcctSeed__Vendor__c != oldCashDisbursementRecord.AcctSeed__Vendor__c) {
                    String oldAccountName = CashDisbursementHistoryHelper.getFieldModifiedValue(oldCashDisbursementRecord, 'Account');
                    String newAccountName = CashDisbursementHistoryHelper.getFieldModifiedValue(CashDisbursementRecord, 'Account');
                    CashDisbursementHistoryHelper.createCashDisbursementHistoryRecord(CashDisbursementHistoryList, CashDisbursementRecord, 'Account', oldAccountName, newAccountName);
                }
                if (CashDisbursementRecord.AcctSeed__Amount__c != null && CashDisbursementRecord.AcctSeed__Amount__c != oldCashDisbursementRecord.AcctSeed__Amount__c) {
                    CashDisbursementHistoryHelper.createCashDisbursementHistoryRecord(CashDisbursementHistoryList, CashDisbursementRecord, 'Total Amount', String.valueOf(oldCashDisbursementRecord.AcctSeed__Amount__c), String.valueOf(CashDisbursementRecord.AcctSeed__Amount__c));
                }
                if (CashDisbursementRecord.AcctSeed__Ledger__c != oldCashDisbursementRecord.AcctSeed__Ledger__c) {
                    String oldAccountName = CashDisbursementHistoryHelper.getFieldModifiedValue(oldCashDisbursementRecord, 'Ledger');
                    String newAccountName = CashDisbursementHistoryHelper.getFieldModifiedValue(CashDisbursementRecord, 'Ledger');
                    CashDisbursementHistoryHelper.createCashDisbursementHistoryRecord(CashDisbursementHistoryList, CashDisbursementRecord, 'Ledger', oldAccountName,newAccountName);
                }
                if (!String.isBlank(CashDisbursementRecord.AcctSeed__Bank_Account__c) && CashDisbursementRecord.AcctSeed__Bank_Account__c != oldCashDisbursementRecord.AcctSeed__Bank_Account__c) {
                    String oldAccountName = CashDisbursementHistoryHelper.getFieldModifiedValue(oldCashDisbursementRecord, 'Bank Account');
                    String newAccountName = CashDisbursementHistoryHelper.getFieldModifiedValue(CashDisbursementRecord, 'Bank Account');
                    CashDisbursementHistoryHelper.createCashDisbursementHistoryRecord(CashDisbursementHistoryList, CashDisbursementRecord, 'Bank Account',oldAccountName,newAccountName);
                }
                if (CashDisbursementRecord.AcctSeed__Debit_GL_Account__c != null && CashDisbursementRecord.AcctSeed__Debit_GL_Account__c != oldCashDisbursementRecord.AcctSeed__Debit_GL_Account__c) {
                    String oldAccountName = CashDisbursementHistoryHelper.getFieldModifiedValue(oldCashDisbursementRecord, 'Debit GL Account');
                    String newAccountName = CashDisbursementHistoryHelper.getFieldModifiedValue(CashDisbursementRecord, 'Debit GL Account');
                    CashDisbursementHistoryHelper.createCashDisbursementHistoryRecord(CashDisbursementHistoryList, CashDisbursementRecord, 'Debit GL Account', oldAccountName,newAccountName);
                }
                if (CashDisbursementRecord.Payable_Id__c != oldCashDisbursementRecord.Payable_Id__c) {
                    String oldAccountName = CashDisbursementHistoryHelper.getFieldModifiedValue(oldCashDisbursementRecord, 'Payable');
                    String newAccountName = CashDisbursementHistoryHelper.getFieldModifiedValue(CashDisbursementRecord, 'Payable');
                    CashDisbursementHistoryHelper.createCashDisbursementHistoryRecord(CashDisbursementHistoryList, CashDisbursementRecord, 'Payable', oldAccountName,newAccountName);
                }
                if (CashDisbursementRecord.AcctSeed__Accounting_Period__c != null && CashDisbursementRecord.AcctSeed__Accounting_Period__c != oldCashDisbursementRecord.AcctSeed__Accounting_Period__c) {
                    String oldAccountName = CashDisbursementHistoryHelper.getFieldModifiedValue(oldCashDisbursementRecord, 'Accounting Period');
                    String newAccountName = CashDisbursementHistoryHelper.getFieldModifiedValue(CashDisbursementRecord, 'Accounting Period');
                    CashDisbursementHistoryHelper.createCashDisbursementHistoryRecord(CashDisbursementHistoryList, CashDisbursementRecord, 'Accounting Period', oldAccountName,newAccountName);
                }
            } else {
                // For new records (inserts), create separate billing history records for each modified field
                if (!String.isBlank(CashDisbursementRecord.AcctSeed__Vendor__c)) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    String newAccountName1 = CashDisbursementHistoryHelper.getFieldModifiedValue(CashDisbursementRecord, 'Account');
                    CashDisbursementHistoryHelper.createCashDisbursementHistoryRecord(CashDisbursementHistoryList, CashDisbursementRecord, 'Account', newAccountName1, newAccountName1);
                }
                if (CashDisbursementRecord.AcctSeed__Amount__c != null) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    CashDisbursementHistoryHelper.createCashDisbursementHistoryRecord(CashDisbursementHistoryList, CashDisbursementRecord, 'Total', String.valueOf(CashDisbursementRecord.AcctSeed__Amount__c), String.valueOf(CashDisbursementRecord.AcctSeed__Amount__c));
                }
                if (CashDisbursementRecord.AcctSeed__Ledger__c != null) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    String newAccountName1 = CashDisbursementHistoryHelper.getFieldModifiedValue(CashDisbursementRecord, 'Ledger');
                    CashDisbursementHistoryHelper.createCashDisbursementHistoryRecord(CashDisbursementHistoryList, CashDisbursementRecord, 'Ledger',newAccountName1, newAccountName1);
                }
                if (!String.isBlank(CashDisbursementRecord.AcctSeed__Bank_Account__c)) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    String newAccountName1 = CashDisbursementHistoryHelper.getFieldModifiedValue(CashDisbursementRecord, 'Bank Account');
                    CashDisbursementHistoryHelper.createCashDisbursementHistoryRecord(CashDisbursementHistoryList, CashDisbursementRecord, 'Bank Account', newAccountName1, newAccountName1);
                }
                if (!String.isBlank(CashDisbursementRecord.AcctSeed__Debit_GL_Account__c)) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    String newAccountName1 = CashDisbursementHistoryHelper.getFieldModifiedValue(CashDisbursementRecord, 'Debit GL Account');
                    CashDisbursementHistoryHelper.createCashDisbursementHistoryRecord(CashDisbursementHistoryList, CashDisbursementRecord, 'Debit GL Account',newAccountName1, newAccountName1);
                }
                if (!String.isBlank(CashDisbursementRecord.Payable_Id__c)) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    String newAccountName1 = CashDisbursementHistoryHelper.getFieldModifiedValue(CashDisbursementRecord, 'Payable');
                    CashDisbursementHistoryHelper.createCashDisbursementHistoryRecord(CashDisbursementHistoryList, CashDisbursementRecord, 'Payable',newAccountName1, newAccountName1);
                }
                if (!String.isBlank(CashDisbursementRecord.AcctSeed__Accounting_Period__c)) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    String newAccountName1 = CashDisbursementHistoryHelper.getFieldModifiedValue(CashDisbursementRecord, 'Accounting Period');
                    CashDisbursementHistoryHelper.createCashDisbursementHistoryRecord(CashDisbursementHistoryList, CashDisbursementRecord, 'Accounting Period',newAccountName1, newAccountName1);
                }
            }
        }

        if (!CashDisbursementHistoryList.isEmpty()) {
            insert CashDisbursementHistoryList;
        }
    }
    
    if (Trigger.isBefore && Trigger.isDelete) {
        List<Cash_Disbursement_History__c> payableHistoryToUpdate = new List<Cash_Disbursement_History__c>();
        
        // Query related Billing History records
        Set<Id> cashdisbursementIds = Trigger.oldMap.keySet();
        List<Cash_Disbursement_History__c> relatedCashDisbursementHistoryList = [SELECT Id FROM Cash_Disbursement_History__c WHERE Cash_Disbursement__c IN :cashdisbursementIds];
        
        // Update Billing History records to mark them as "Deleted"
        for (Cash_Disbursement_History__c payableHistory : relatedCashDisbursementHistoryList) {
            payableHistory.Deleted__c = true;
            payableHistoryToUpdate.add(payableHistory);
        }
        
        // Update the related Billing History records
        if (!payableHistoryToUpdate.isEmpty()) {
            update payableHistoryToUpdate;
        }
    }
}