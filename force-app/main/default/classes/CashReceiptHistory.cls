public class CashReceiptHistory 
{
    public static void createCashReceiptHistoryRecord(List<Cash_Receipt_History__c> cashReceiptHistoryList, AcctSeed__Cash_Receipt__c CashReceiptRecord, String impactedField, String originalValue, String modifiedValue) {
        Cash_Receipt_History__c cashReceiptHistoryRecord = new Cash_Receipt_History__c();
        cashReceiptHistoryRecord.Cash_Receipt__c = CashReceiptRecord.Id; 
        
        cashReceiptHistoryRecord.Created_Date__c = CashReceiptRecord.CreatedDate.date();
        cashReceiptHistoryRecord.Modified_Date__c = System.today();
        
        if (CashReceiptRecord.CreatedById != null) {
            Id createdUserId = CashReceiptRecord.CreatedById;
            User createdUser = [SELECT Name FROM User WHERE Id = :createdUserId];
            cashReceiptHistoryRecord.Created_User__c = createdUser.Name;
        }
        
        if (CashReceiptRecord.LastModifiedById != null) {
            Id modifiedUserId = CashReceiptRecord.LastModifiedById;
            User modifiedUser = [SELECT Name FROM User WHERE Id = :modifiedUserId];
            cashReceiptHistoryRecord.Modified_User__c = modifiedUser.Name;
        }
        
        if (impactedField != null) {
            cashReceiptHistoryRecord.Impacted_Field__c = impactedField;
            cashReceiptHistoryRecord.Original_Value__c = originalValue;
            cashReceiptHistoryRecord.Modified_Value__c = modifiedValue;
        }
        
        cashReceiptHistoryList.add(cashReceiptHistoryRecord);
    }
    
    public static String getFieldModifiedValue(AcctSeed__Cash_Receipt__c CashReceiptRecord, String field) {
        switch on field {
            when 'Account' {
                if (CashReceiptRecord.AcctSeed__Account__c != null) {
                    Account relatedAccount = [SELECT Name FROM Account WHERE Id = :CashReceiptRecord.AcctSeed__Account__c];
                    return relatedAccount.Name;
                }
                return null;
            }
            when 'Receipt Date' {
                return String.valueOf(CashReceiptRecord.AcctSeed__Receipt_Date__c);
            }
            when 'Total Amount'{
                return String.valueOf(CashReceiptRecord.AcctSeed__Amount__c);
            }
            when 'Ledger' {
                if (CashReceiptRecord.AcctSeed__Ledger__c != null) {
                    AcctSeed__Ledger__c relatedAccount = [SELECT Name FROM AcctSeed__Ledger__c WHERE Id = :CashReceiptRecord.AcctSeed__Ledger__c];
                    return relatedAccount.Name;
                }
                return null;
            }
            when 'Billing' {
                if (CashReceiptRecord.Billing_Id__c != null) {
                    AcctSeed__Billing__c relatedAccount = [SELECT Name FROM AcctSeed__Billing__c WHERE Id = :CashReceiptRecord.Billing_Id__c];
                    return relatedAccount.Name;
                }
                return null;
            }
            when 'Accounting Period' {
                if (CashReceiptRecord.AcctSeed__Accounting_Period__c != null) {
                    AcctSeed__Accounting_Period__c relatedAccount = [SELECT Name FROM AcctSeed__Accounting_Period__c WHERE Id = :CashReceiptRecord.AcctSeed__Accounting_Period__c];
                    return relatedAccount.Name;
                }
                return null;
            }
            when 'Bank Account' {
                if (CashReceiptRecord.AcctSeed__Bank_Account__c != null) {
                    AcctSeed__GL_Account__c relatedAccount = [SELECT Name FROM AcctSeed__GL_Account__c WHERE Id = :CashReceiptRecord.AcctSeed__Bank_Account__c];
                    return relatedAccount.Name;
                }
                return null;
            }
            when 'Credit GL Account' {
                if (CashReceiptRecord.AcctSeed__Credit_GL_Account__c != null) {
                    AcctSeed__GL_Account__c relatedAccount = [SELECT Name FROM AcctSeed__GL_Account__c WHERE Id = :CashReceiptRecord.AcctSeed__Credit_GL_Account__c];
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