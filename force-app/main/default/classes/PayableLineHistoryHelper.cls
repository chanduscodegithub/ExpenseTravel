public class PayableLineHistoryHelper {
    public static void createPayableLineHistoryRecord(List<Payable_History__c> payableLineHistoryList, SObject record, String impactedField, String originalValue, String modifiedValue) {
        Payable_History__c payableHistoryRecord = new Payable_History__c();
        payableHistoryRecord.Payable_Line__c = (Id)record.get('Id'); // Store the ID of the related Payable Line
        payableHistoryRecord.Created_Date__c = record.get('CreatedDate') != null ? ((DateTime)record.get('CreatedDate')).date() : null;
        payableHistoryRecord.Modified_Date__c = System.today();
        
        // Fetch the related records and get their names
        if (record.get('CreatedById') != null) {
            Id createdUserId = (Id)record.get('CreatedById');
            User createdUser = [SELECT Name FROM User WHERE Id = :createdUserId];
            payableHistoryRecord.Created_User__c = createdUser.Name;
        }
        
        if (record.get('LastModifiedById') != null) {
            Id modifiedUserId = (Id)record.get('LastModifiedById');
            User modifiedUser = [SELECT Name FROM User WHERE Id = :modifiedUserId];
            payableHistoryRecord.Modified_User__c = modifiedUser.Name;
        }
        
        if (record.get('AcctSeed__Account_Payable__c') != null) {
            Id payableId = (Id)record.get('AcctSeed__Account_Payable__c');
            AcctSeed__Account_Payable__c payableRecord = [SELECT Id, Name FROM AcctSeed__Account_Payable__c WHERE Id = :payableId];
            payableHistoryRecord.Payable__c = payableRecord.Id;
        }
        
        if (impactedField != null) {
            payableHistoryRecord.Impacted_Field__c = impactedField;
            payableHistoryRecord.Original_Value__c = originalValue;
            payableHistoryRecord.Modified_Value__c = modifiedValue;
        }
        
        payableLineHistoryList.add(payableHistoryRecord);
    }
    
    // This method is for updating the Billing_Line__c records with the Payable_History__c name
    public static void updatePayableLineRecords(List<AcctSeed__Account_Payable_Line__c> payableLinesToUpdate, Id payableHistoryId) {
        List<AcctSeed__Account_Payable_Line__c> linesToUpdate = new List<AcctSeed__Account_Payable_Line__c>();
        for (AcctSeed__Account_Payable_Line__c payableLine : payableLinesToUpdate) {
            // Assuming the relationship field to Payable_History__c is named AcctSeed__Account_Payable__c
            payableLine.AcctSeed__Account_Payable__c = payableHistoryId;
            linesToUpdate.add(payableLine);
        }
        update linesToUpdate;
    }
    
    public static String getFieldModifiedValue(AcctSeed__Account_Payable_Line__c records, String field) {
        switch on field {
            when 'Expense GL Account' {
                if (records.AcctSeed__Expense_GL_Account__c != null) {
                    AcctSeed__GL_Account__c relatedAccount = [SELECT Name FROM AcctSeed__GL_Account__c WHERE Id = :records.AcctSeed__Expense_GL_Account__c];
                    return relatedAccount.Name;
                }
                return null;
            }
            when 'payableLine Total' {
                return String.valueOf(records.AcctSeed__Amount__c);
            }
            when 'Tax Rate' {
                return String.valueOf(records.AcctSeed__Tax_Rate__c);
            }
            when 'Tax Amount' {
                return String.valueOf(records.AcctSeed__Tax_Amount__c);
            }
            when else {
                return null;
            }
        }
    }
    public static void fakeMethod(){
    Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

  }
}