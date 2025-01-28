public class JournalEntryHistoryHelper 
{
    public static void createJournalEntryHistoryRecord(List<Journal_Entry_History__c> journalEntryHistoryList, AcctSeed__Journal_Entry__c journalEntryRecord, String impactedField, String originalValue, String modifiedValue) {
        Journal_Entry_History__c journalEntryHistoryRecord = new Journal_Entry_History__c();
        journalEntryHistoryRecord.Journal_Entry__c = journalEntryRecord.Id; 
        
        journalEntryHistoryRecord.Created_Date__c = journalEntryRecord.CreatedDate.date();
        journalEntryHistoryRecord.Modified_Date__c = System.today();
        
        if (journalEntryRecord.CreatedById != null) {
            Id createdUserId = journalEntryRecord.CreatedById;
            User createdUser = [SELECT Name FROM User WHERE Id = :createdUserId];
            journalEntryHistoryRecord.Created_User__c = createdUser.Name;
        }
        
        if (journalEntryRecord.LastModifiedById != null) {
            Id modifiedUserId = journalEntryRecord.LastModifiedById;
            User modifiedUser = [SELECT Name FROM User WHERE Id = :modifiedUserId];
            journalEntryHistoryRecord.Modified_User__c = modifiedUser.Name;
        }
        
        if (impactedField != null) {
            journalEntryHistoryRecord.Impacted_Field__c = impactedField;
            journalEntryHistoryRecord.Original_Value__c = originalValue;
            journalEntryHistoryRecord.Modified_Value__c = modifiedValue;
        }
        
        journalentryHistoryList.add(journalEntryHistoryRecord);
    }
    
    public static String getFieldModifiedValue(AcctSeed__Journal_Entry__c journalEntryRecord, String field) {
        switch on field {
            
            when 'Journal Date'{
                return String.valueOf(journalEntryRecord.AcctSeed__Journal_Date__c);
            }
            when 'Ledger' {
                if (journalEntryRecord.AcctSeed__Ledger__c != null) {
                    AcctSeed__Ledger__c relatedAccount = [SELECT Name FROM AcctSeed__Ledger__c WHERE Id = :journalEntryRecord.AcctSeed__Ledger__c];
                    return relatedAccount.Name;
                }
                return null;
            }
            
            when 'Accounting Period' {
                if (journalEntryRecord.AcctSeed__Accounting_Period__c != null) {
                    AcctSeed__Accounting_Period__c relatedAccount = [SELECT Name FROM AcctSeed__Accounting_Period__c WHERE Id = :journalEntryRecord.AcctSeed__Accounting_Period__c];
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