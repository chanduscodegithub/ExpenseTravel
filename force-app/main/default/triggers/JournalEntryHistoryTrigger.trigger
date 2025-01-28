trigger JournalEntryHistoryTrigger on AcctSeed__Journal_Entry__c (after insert, after update, before delete) {
  if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        List<Journal_Entry_History__c> journalEntryHistoryList = new List<Journal_Entry_History__c>();

        for (AcctSeed__Journal_Entry__c journalEntryRecord : Trigger.new) {
            AcctSeed__Journal_Entry__c oldjournalEntryRecord = null;
            if (Trigger.isUpdate) {
                oldjournalEntryRecord = Trigger.oldMap.get(journalEntryRecord.Id);
            }

            if (oldjournalEntryRecord != null) {
                
                if (journalEntryRecord.AcctSeed__Ledger__c != oldjournalEntryRecord.AcctSeed__Ledger__c) {
                    String oldAccountName = JournalEntryHistoryHelper.getFieldModifiedValue(oldjournalEntryRecord, 'Ledger');
                    String newAccountName = JournalEntryHistoryHelper.getFieldModifiedValue(journalEntryRecord, 'Ledger');
                    JournalEntryHistoryHelper.createJournalEntryHistoryRecord(journalEntryHistoryList, journalEntryRecord, 'Ledger', oldAccountName,newAccountName);
                }
                
                if (journalEntryRecord.AcctSeed__Journal_Date__c != oldjournalEntryRecord.AcctSeed__Journal_Date__c) {
                    JournalEntryHistoryHelper.createJournalEntryHistoryRecord(journalEntryHistoryList, journalEntryRecord, 'Journal Date', String.valueOf(oldjournalEntryRecord.AcctSeed__Journal_Date__c), String.valueOf(journalEntryRecord.AcctSeed__Journal_Date__c));
                }
                
                if (journalEntryRecord.AcctSeed__Accounting_Period__c != null && journalEntryRecord.AcctSeed__Accounting_Period__c != oldjournalEntryRecord.AcctSeed__Accounting_Period__c) {
                    String oldAccountName = JournalEntryHistoryHelper.getFieldModifiedValue(oldjournalEntryRecord, 'Accounting Period');
                    String newAccountName = JournalEntryHistoryHelper.getFieldModifiedValue(journalEntryRecord, 'Accounting Period');
                    JournalEntryHistoryHelper.createJournalEntryHistoryRecord(journalEntryHistoryList, journalEntryRecord, 'Accounting Period', oldAccountName,newAccountName);
                }
            } else {
                // For new records (inserts), create separate billing history records for each modified field
                
                if (journalEntryRecord.AcctSeed__Journal_Date__c != null) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    JournalEntryHistoryHelper.createJournalEntryHistoryRecord(journalEntryHistoryList, journalEntryRecord, 'Journal Date', String.valueOf(journalEntryRecord.AcctSeed__Journal_Date__c), String.valueOf(journalEntryRecord.AcctSeed__Journal_Date__c));
                }
                if (journalEntryRecord.AcctSeed__Ledger__c != null) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    String newAccountName1 = JournalEntryHistoryHelper.getFieldModifiedValue(journalEntryRecord, 'Ledger');
                    JournalEntryHistoryHelper.createJournalEntryHistoryRecord(journalEntryHistoryList, journalEntryRecord, 'Ledger',newAccountName1, newAccountName1);
                }
                

                if (!String.isBlank(journalEntryRecord.AcctSeed__Accounting_Period__c)) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    String newAccountName1 = JournalEntryHistoryHelper.getFieldModifiedValue(journalEntryRecord, 'Accounting Period');
                    JournalEntryHistoryHelper.createJournalEntryHistoryRecord(journalEntryHistoryList, journalEntryRecord, 'Accounting Period',newAccountName1, newAccountName1);
                }
            }
        }

        if (!journalEntryHistoryList.isEmpty()) {
            insert journalEntryHistoryList;
        }
    }
    
    if (Trigger.isBefore && Trigger.isDelete) {
        List<Journal_Entry_History__c> payableHistoryToUpdate = new List<Journal_Entry_History__c>();
        
        // Query related Billing History records
        Set<Id> cashreceiptIds = Trigger.oldMap.keySet();
        List<Journal_Entry_History__c> relatedjournalEntryHistoryList = [SELECT Id FROM Journal_Entry_History__c WHERE Journal_Entry__c IN :cashreceiptIds];
        
        // Update Billing History records to mark them as "Deleted"
        for (Journal_Entry_History__c payableHistory : relatedjournalEntryHistoryList) {
            payableHistory.Deleted__c = true;
            payableHistoryToUpdate.add(payableHistory);
        }
        
        // Update the related Billing History records
        if (!payableHistoryToUpdate.isEmpty()) {
            update payableHistoryToUpdate;
        }
    }
}