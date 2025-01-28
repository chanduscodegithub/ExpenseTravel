trigger PayableLineHistoryTrigger on AcctSeed__Account_Payable_Line__c (after insert, after update,before delete)
{
if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        List<Payable_History__c> payableLineHistoryList = new List<Payable_History__c>();
        
        for (AcctSeed__Account_Payable_Line__c payableLineRecord : Trigger.new) {
            AcctSeed__Account_Payable_Line__c oldpayableLineRecord = null;
            if (Trigger.isUpdate) {
                oldpayableLineRecord = Trigger.oldMap.get(payableLineRecord.Id);
            }
            
            if (oldpayableLineRecord != null) {
                if (!String.isBlank(payableLineRecord.AcctSeed__Expense_GL_Account__c) && payableLineRecord.AcctSeed__Expense_GL_Account__c != oldpayableLineRecord.AcctSeed__Expense_GL_Account__c) {
                    String oldAccountName = PayableLineHistoryHelper.getFieldModifiedValue(oldpayableLineRecord, 'Expense GL Account');
                    String newAccountName = PayableLineHistoryHelper.getFieldModifiedValue(payableLineRecord, 'Expense GL Account');
                    PayableLineHistoryHelper.createPayableLineHistoryRecord(payableLineHistoryList, payableLineRecord, 'Expense GL Account',oldAccountName,newAccountName);
                }
                if (payableLineRecord.AcctSeed__Amount__c != oldpayableLineRecord.AcctSeed__Amount__c) {
                    PayableLineHistoryHelper.createPayableLineHistoryRecord(payableLineHistoryList, payableLineRecord, 'PayableLine Total', String.valueOf(oldpayableLineRecord.AcctSeed__Amount__c), String.valueOf(payableLineRecord.AcctSeed__Amount__c));
                }
                if (payableLineRecord.AcctSeed__Tax_Rate__c != oldpayableLineRecord.AcctSeed__Tax_Rate__c) {
                    PayableLineHistoryHelper.createPayableLineHistoryRecord(payableLineHistoryList, payableLineRecord, 'Tax Rate', String.valueOf(oldpayableLineRecord.AcctSeed__Tax_Rate__c), String.valueOf(payableLineRecord.AcctSeed__Tax_Rate__c));
                }
                if (payableLineRecord.AcctSeed__Tax_Amount__c != oldpayableLineRecord.AcctSeed__Tax_Amount__c) {
                    PayableLineHistoryHelper.createPayableLineHistoryRecord(payableLineHistoryList, payableLineRecord, 'Tax Amount', String.valueOf(oldpayableLineRecord.AcctSeed__Tax_Amount__c), String.valueOf(payableLineRecord.AcctSeed__Tax_Amount__c));
                }
            } else {
                // For new records (inserts), create separate billing history records for each modified field
                if (!String.isBlank(payableLineRecord.AcctSeed__Expense_GL_Account__c)) {
                    String newAccountName1 = PayableLineHistoryHelper.getFieldModifiedValue(payableLineRecord, 'Expense GL Account');
                    PayableLineHistoryHelper.createPayableLineHistoryRecord(payableLineHistoryList, payableLineRecord, 'Expense GL Account', newAccountName1, newAccountName1);
                }
                if (payableLineRecord.AcctSeed__Amount__c != null) {
                    PayableLineHistoryHelper.createPayableLineHistoryRecord(payableLineHistoryList, payableLineRecord, 'PayableLine Total', String.valueOf(payableLineRecord.AcctSeed__Amount__c), String.valueOf(payableLineRecord.AcctSeed__Amount__c));
                }
                if (payableLineRecord.AcctSeed__Tax_Rate__c != null) {
                    PayableLineHistoryHelper.createPayableLineHistoryRecord(payableLineHistoryList, payableLineRecord, 'Tax Rate', String.valueOf(payableLineRecord.AcctSeed__Tax_Rate__c), String.valueOf(payableLineRecord.AcctSeed__Tax_Rate__c));
                }
                if (payableLineRecord.AcctSeed__Tax_Amount__c != null) {
                    PayableLineHistoryHelper.createPayableLineHistoryRecord(payableLineHistoryList, payableLineRecord, 'Tax Amount', String.valueOf(payableLineRecord.AcctSeed__Tax_Amount__c), String.valueOf(payableLineRecord.AcctSeed__Tax_Amount__c));
                }
            }
        }
        
        if (!payableLineHistoryList.isEmpty()) {
            insert payableLineHistoryList;
        }
    }
    if (Trigger.isBefore && Trigger.isDelete) {
        Set<String> payableLineNames = new Set<String>();
        
        for (AcctSeed__Account_Payable_Line__c payableLineRecord : Trigger.old) {
            payableLineNames.add(payableLineRecord.id);
        }
        
        List<Payable_History__c> payableHistoryToUpdate = [
            SELECT Id, Deleted__c
            FROM Payable_History__c
            WHERE Payable_Line__c IN :payableLineNames
        ];
        
        for (Payable_History__c relatedBillingHistory : payableHistoryToUpdate) {
            relatedBillingHistory.Deleted__c = true;
        }
        
        if (!payableHistoryToUpdate.isEmpty()) {
            update payableHistoryToUpdate;
        }
    }
}