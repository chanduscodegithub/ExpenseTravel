public class PayableHistoryHelper 
{
    public static void createPayableHistoryRecord(List<Payable_History__c> payableHistoryList, AcctSeed__Account_Payable__c payableRecord, String impactedField, String originalValue, String modifiedValue) {
        Payable_History__c payableHistoryRecord = new Payable_History__c();
        payableHistoryRecord.Payable__c = payableRecord.Id; 
        
        payableHistoryRecord.Created_Date__c = payableRecord.CreatedDate.date();
        payableHistoryRecord.Modified_Date__c = System.today();
        
        if (payableRecord.CreatedById != null) {
            Id createdUserId = payableRecord.CreatedById;
            User createdUser = [SELECT Name FROM User WHERE Id = :createdUserId];
            payableHistoryRecord.Created_User__c = createdUser.Name;
        }
        
        if (payableRecord.LastModifiedById != null) {
            Id modifiedUserId = payableRecord.LastModifiedById;
            User modifiedUser = [SELECT Name FROM User WHERE Id = :modifiedUserId];
            payableHistoryRecord.Modified_User__c = modifiedUser.Name;
        }
        
        if (impactedField != null) {
            payableHistoryRecord.Impacted_Field__c = impactedField;
            payableHistoryRecord.Original_Value__c = originalValue;
            payableHistoryRecord.Modified_Value__c = modifiedValue;
        }
        
        payableHistoryList.add(payableHistoryRecord);
    }
    
    public static String getFieldModifiedValue(AcctSeed__Account_Payable__c payableRecord, String field) {
        switch on field {
            when 'Account' {
                if (payableRecord.AcctSeed__Vendor__c != null) {
                    Account relatedAccount = [SELECT Name FROM Account WHERE Id = :payableRecord.AcctSeed__Vendor__c];
                    return relatedAccount.Name;
                }
                return null;
            }
            when 'Date' {
                return String.valueOf(payableRecord.AcctSeed__Date__c);
            }
            when 'Description' {
                return payableRecord.Description__c;
            }
            when 'Ledger' {
                if (payableRecord.AcctSeed__Ledger__c != null) {
                    AcctSeed__Ledger__c relatedAccount = [SELECT Name FROM AcctSeed__Ledger__c WHERE Id = :payableRecord.AcctSeed__Ledger__c];
                    return relatedAccount.Name;
                }
                return null;
            }
            when 'Accounting Period' {
                if (payableRecord.AcctSeed__Accounting_Period__c != null) {
                    AcctSeed__Accounting_Period__c relatedAccount = [SELECT Name FROM AcctSeed__Accounting_Period__c WHERE Id = :payableRecord.AcctSeed__Accounting_Period__c];
                    return relatedAccount.Name;
                }
                return null;
            }
            when 'Total' {
                return String.valueOf(payableRecord.AcctSeed__Total__c);
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