trigger JournalEntryLineHistoryTrigger on AcctSeed__Journal_Entry_Line__c (after insert, after update,before delete) {
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        List<Journal_Entry_History__c> journalEntryLineHistoryList = new List<Journal_Entry_History__c>();
        
        for (AcctSeed__Journal_Entry_Line__c journalEntryLineRecord : Trigger.new) {
            AcctSeed__Journal_Entry_Line__c oldjournalEntryLineRecord = null;
            if (Trigger.isUpdate) {
                oldjournalEntryLineRecord = Trigger.oldMap.get(journalEntryLineRecord.Id);
            }
            
            if (oldjournalEntryLineRecord != null) {
                if (!String.isBlank(journalEntryLineRecord.AcctSeed__GL_Account__c) && journalEntryLineRecord.AcctSeed__GL_Account__c != oldjournalEntryLineRecord.AcctSeed__GL_Account__c) {
                    String oldAccountName = JournalEntryLineHistoryHelper.getFieldModifiedValue(oldjournalEntryLineRecord, 'GL Account');
                    String newAccountName = JournalEntryLineHistoryHelper.getFieldModifiedValue(journalEntryLineRecord, 'GL Account');
                    JournalEntryLineHistoryHelper.createJournalEntryLineHistoryRecord(journalEntryLineHistoryList, journalEntryLineRecord, 'GL Account',oldAccountName,newAccountName);
                }
                if (journalEntryLineRecord.AcctSeed__Amount__c != oldjournalEntryLineRecord.AcctSeed__Amount__c) {
                    JournalEntryLineHistoryHelper.createJournalEntryLineHistoryRecord(journalEntryLineHistoryList, journalEntryLineRecord, 'Amount', String.valueOf(oldjournalEntryLineRecord.AcctSeed__Amount__c), String.valueOf(journalEntryLineRecord.AcctSeed__Amount__c));
                }
                if (journalEntryLineRecord.AcctSeed__Debit__c != oldjournalEntryLineRecord.AcctSeed__Debit__c) {
                    JournalEntryLineHistoryHelper.createJournalEntryLineHistoryRecord(journalEntryLineHistoryList, journalEntryLineRecord, 'Debit', String.valueOf(oldjournalEntryLineRecord.AcctSeed__Debit__c), String.valueOf(journalEntryLineRecord.AcctSeed__Debit__c));
                }
                if (journalEntryLineRecord.AcctSeed__Credit__c != oldjournalEntryLineRecord.AcctSeed__Credit__c) {
                    JournalEntryLineHistoryHelper.createJournalEntryLineHistoryRecord(journalEntryLineHistoryList, journalEntryLineRecord, 'Credit', String.valueOf(oldjournalEntryLineRecord.AcctSeed__Credit__c), String.valueOf(journalEntryLineRecord.AcctSeed__Credit__c));
                }
                if (!String.isBlank(journalEntryLineRecord.AcctSeed__Account__c) && journalEntryLineRecord.AcctSeed__Account__c != oldjournalEntryLineRecord.AcctSeed__Account__c) {
                    String oldAccountName = JournalEntryLineHistoryHelper.getFieldModifiedValue(oldjournalEntryLineRecord, 'Account');
                    String newAccountName = JournalEntryLineHistoryHelper.getFieldModifiedValue(journalEntryLineRecord, 'Account');
                    JournalEntryLineHistoryHelper.createJournalEntryLineHistoryRecord(journalEntryLineHistoryList, journalEntryLineRecord, 'Account',oldAccountName,newAccountName);
                }
            } else {
                // For new records (inserts), create separate billing history records for each modified field
                if (!String.isBlank(journalEntryLineRecord.AcctSeed__GL_Account__c)) {
                    String newAccountName1 = JournalEntryLineHistoryHelper.getFieldModifiedValue(journalEntryLineRecord, 'GL Account');
                    JournalEntryLineHistoryHelper.createJournalEntryLineHistoryRecord(journalEntryLineHistoryList, journalEntryLineRecord, 'GL Account', newAccountName1, newAccountName1);
                }
                if (journalEntryLineRecord.AcctSeed__Amount__c != null) {
                    JournalEntryLineHistoryHelper.createJournalEntryLineHistoryRecord(journalEntryLineHistoryList, journalEntryLineRecord, 'Amount', String.valueOf(journalEntryLineRecord.AcctSeed__Amount__c), String.valueOf(journalEntryLineRecord.AcctSeed__Amount__c));
                }
                if (journalEntryLineRecord.AcctSeed__Debit__c != null) {
                    JournalEntryLineHistoryHelper.createJournalEntryLineHistoryRecord(journalEntryLineHistoryList, journalEntryLineRecord, 'Debit', String.valueOf(journalEntryLineRecord.AcctSeed__Debit__c), String.valueOf(journalEntryLineRecord.AcctSeed__Debit__c));
                }
                if (journalEntryLineRecord.AcctSeed__Credit__c != null) {
                    JournalEntryLineHistoryHelper.createJournalEntryLineHistoryRecord(journalEntryLineHistoryList, journalEntryLineRecord, 'Credit', String.valueOf(journalEntryLineRecord.AcctSeed__Credit__c), String.valueOf(journalEntryLineRecord.AcctSeed__Credit__c));
                }
                if (!String.isBlank(journalEntryLineRecord.AcctSeed__Account__c)) {
                    // For new records, Original_Value__c should be same as Modified_Value__c
                    String newAccountName1 = JournalEntryLineHistoryHelper.getFieldModifiedValue(journalEntryLineRecord, 'Account');
                    JournalEntryLineHistoryHelper.createJournalEntryLineHistoryRecord(journalEntryLineHistoryList, journalEntryLineRecord, 'Account', newAccountName1, newAccountName1);
                }
            }
        }
        
        if (!journalEntryLineHistoryList.isEmpty()) {
            insert journalEntryLineHistoryList;
        }
    }
    if (Trigger.isBefore && Trigger.isDelete) {
        Set<String> journalEntryLineNames = new Set<String>();
        
        for (AcctSeed__Journal_Entry_Line__c journalEntryLineRecord : Trigger.old) {
            journalEntryLineNames.add(journalEntryLineRecord.id);
        }
        
        List<Journal_Entry_History__c> journalEntryHistoryToUpdate = [
            SELECT Id, Deleted__c
            FROM Journal_Entry_History__c
            WHERE Journal_Entry_Line__c IN :journalEntryLineNames
        ];
        
        for (Journal_Entry_History__c relatedJournalEntryHistory : journalEntryHistoryToUpdate) {
            relatedJournalEntryHistory.Deleted__c = true;
        }
        
        if (!journalEntryHistoryToUpdate.isEmpty()) {
            update journalEntryHistoryToUpdate;
        }
    }
}