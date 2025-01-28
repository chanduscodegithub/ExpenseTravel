public class JournalEntryLineHistoryHelper
{
    public static void createJournalEntryLineHistoryRecord(List<Journal_Entry_History__c> journalEntryLineHistoryList, SObject record, String impactedField, String originalValue, String modifiedValue) {
        Journal_Entry_History__c journalEntryLineHistoryRecord = new Journal_Entry_History__c();
        journalEntryLineHistoryRecord.Journal_Entry_Line__c = (Id)record.get('Id'); // Store the ID of the related Payable Line
        journalEntryLineHistoryRecord.Created_Date__c = record.get('CreatedDate') != null ? ((DateTime)record.get('CreatedDate')).date() : null;
        journalEntryLineHistoryRecord.Modified_Date__c = System.today();
        
        // Fetch the related records and get their names
        if (record.get('CreatedById') != null) {
            Id createdUserId = (Id)record.get('CreatedById');
            User createdUser = [SELECT Name FROM User WHERE Id = :createdUserId];
            journalEntryLineHistoryRecord.Created_User__c = createdUser.Name;
        }
        
        if (record.get('LastModifiedById') != null) {
            Id modifiedUserId = (Id)record.get('LastModifiedById');
            User modifiedUser = [SELECT Name FROM User WHERE Id = :modifiedUserId];
            journalEntryLineHistoryRecord.Modified_User__c = modifiedUser.Name;
        }
        
        if (record.get('AcctSeed__Journal_Entry__c') != null) {
            Id journalEntryId = (Id)record.get('AcctSeed__Journal_Entry__c');
            AcctSeed__Journal_Entry__c journalEntryRecord = [SELECT Id, Name FROM AcctSeed__Journal_Entry__c WHERE Id = :journalEntryId];
            journalEntryLineHistoryRecord.Journal_Entry__c = journalEntryRecord.Id;
        }
        
        if (impactedField != null) {
            journalEntryLineHistoryRecord.Impacted_Field__c = impactedField;
            journalEntryLineHistoryRecord.Original_Value__c = originalValue;
            journalEntryLineHistoryRecord.Modified_Value__c = modifiedValue;
        }
        
        journalEntryLineHistoryList.add(journalEntryLineHistoryRecord);
    }
    
 /*   // This method is for updating the Billing_Line__c records with the Journal_Entry_History__c name
    public static void updateJournalEntryLineRecords(List<AcctSeed__Journal_Entry_Line__c> journalEntryLinesToUpdate, Id journalEntryHistoryId) {
        List<AcctSeed__Journal_Entry_Line__c> linesToUpdate = new List<AcctSeed__Journal_Entry_Line__c>();
        for (AcctSeed__Journal_Entry__c journalEntryLine : journalEntryLinesToUpdate) {
            // Assuming the relationship field to Journal_Entry_History__c is named AcctSeed__Journal_Entry__c
            journalEntryLine.AcctSeed__Journal_Entry__c = journalEntryHistoryId;
            linesToUpdate.add(journalEntryLine);
        }
        update linesToUpdate;
    }*/
    
    public static String getFieldModifiedValue(AcctSeed__Journal_Entry_Line__c records, String field) {
        switch on field {
            when 'GL Account' {
                if (records.AcctSeed__GL_Account__c != null) {
                    AcctSeed__GL_Account__c relatedAccount = [SELECT Name FROM AcctSeed__GL_Account__c WHERE Id = :records.AcctSeed__GL_Account__c];
                    return relatedAccount.Name;
                }
                return null;
            }
            when 'Debit' {
                return String.valueOf(records.AcctSeed__Debit__c);
            }
            when 'Credit' {
                return String.valueOf(records.AcctSeed__Credit__c);
            }
            when 'Amount' {
                return String.valueOf(records.AcctSeed__Amount__c);
            }
			when 'Account' {
                if (records.AcctSeed__Account__c != null) {
                    Account relatedAccount = [SELECT Name FROM Account WHERE Id = :records.AcctSeed__Account__c];
                    return relatedAccount.Name;
                }
                return null;
            }
            when else {
                return null;
            }
        }
    }
}