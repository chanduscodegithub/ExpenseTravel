public class CashDisbursementHistoryHelper 
{
    public static void createCashDisbursementHistoryRecord(List<Cash_Disbursement_History__c> cashDisbursementHistoryList, AcctSeed__Cash_Disbursement__c CashDisbursementRecord, String impactedField, String originalValue, String modifiedValue) {
        Cash_Disbursement_History__c cashDisbursementHistoryRecord = new Cash_Disbursement_History__c();
        cashDisbursementHistoryRecord.Cash_Disbursement__c = CashDisbursementRecord.Id; 
        
        cashDisbursementHistoryRecord.Created_Date__c = CashDisbursementRecord.CreatedDate.date();
        cashDisbursementHistoryRecord.Modified_Date__c = System.today();
        
        if (CashDisbursementRecord.CreatedById != null) {
            Id createdUserId = CashDisbursementRecord.CreatedById;
            User createdUser = [SELECT Name FROM User WHERE Id = :createdUserId];
            cashDisbursementHistoryRecord.Created_User__c = createdUser.Name;
        }
        
        if (CashDisbursementRecord.LastModifiedById != null) {
            Id modifiedUserId = CashDisbursementRecord.LastModifiedById;
            User modifiedUser = [SELECT Name FROM User WHERE Id = :modifiedUserId];
            cashDisbursementHistoryRecord.Modified_User__c = modifiedUser.Name;
        }
        
        if (impactedField != null) {
            cashDisbursementHistoryRecord.Impacted_Field__c = impactedField;
            cashDisbursementHistoryRecord.Original_Value__c = originalValue;
            cashDisbursementHistoryRecord.Modified_Value__c = modifiedValue;
        }
        
        cashDisbursementHistoryList.add(cashDisbursementHistoryRecord);
    }
    
    public static String getFieldModifiedValue(AcctSeed__Cash_Disbursement__c CashDisbursementRecord, String field) {
        switch on field {
            when 'Account' {
                if (CashDisbursementRecord.AcctSeed__Vendor__c != null) {
                    Account relatedAccount = [SELECT Name FROM Account WHERE Id = :CashDisbursementRecord.AcctSeed__Vendor__c];
                    return relatedAccount.Name;
                }
                return null;
            }
            when 'Total Amount'{
                return String.valueOf(CashDisbursementRecord.AcctSeed__Amount__c);
            }
            when 'Ledger' {
                if (CashDisbursementRecord.AcctSeed__Ledger__c != null) {
                    AcctSeed__Ledger__c relatedAccount = [SELECT Name FROM AcctSeed__Ledger__c WHERE Id = :CashDisbursementRecord.AcctSeed__Ledger__c];
                    return relatedAccount.Name;
                }
                return null;
            }
            when 'Payable' {
                if (CashDisbursementRecord.Payable_Id__c != null) {
                    AcctSeed__Account_Payable__c relatedAccount = [SELECT Name FROM AcctSeed__Account_Payable__c WHERE Id = :CashDisbursementRecord.Payable_Id__c];
                    return relatedAccount.Name;
                }
                return null;
            }
            when 'Accounting Period' {
                if (CashDisbursementRecord.AcctSeed__Accounting_Period__c != null) {
                    AcctSeed__Accounting_Period__c relatedAccount = [SELECT Name FROM AcctSeed__Accounting_Period__c WHERE Id = :CashDisbursementRecord.AcctSeed__Accounting_Period__c];
                    return relatedAccount.Name;
                }
                return null;
            }
            when 'Bank Account' {
                if (CashDisbursementRecord.AcctSeed__Bank_Account__c != null) {
                    AcctSeed__GL_Account__c relatedAccount = [SELECT Name FROM AcctSeed__GL_Account__c WHERE Id = :CashDisbursementRecord.AcctSeed__Bank_Account__c];
                    return relatedAccount.Name;
                }
                return null;
            }
            when 'Debit GL Account' {
                if (CashDisbursementRecord.AcctSeed__Debit_GL_Account__c != null) {
                    AcctSeed__GL_Account__c relatedAccount = [SELECT Name FROM AcctSeed__GL_Account__c WHERE Id = :CashDisbursementRecord.AcctSeed__Debit_GL_Account__c];
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