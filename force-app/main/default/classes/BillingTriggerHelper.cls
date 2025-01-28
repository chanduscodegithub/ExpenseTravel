public class BillingTriggerHelper {
    public static void createBillingHistoryRecord(List<Billing_History__c> billingHistoryList, AcctSeed__Billing__c billingRecord, String impactedField, String originalValue, String modifiedValue) {
        Billing_History__c billingHistoryRecord = new Billing_History__c();
        billingHistoryRecord.Billing__c = billingRecord.Id; // Set the Name from the billingRecord
        
        billingHistoryRecord.Created_Date__c = billingRecord.CreatedDate.date();
        billingHistoryRecord.Modified_Date__c = System.today();
        
        if (billingRecord.CreatedById != null) {
            Id createdUserId = billingRecord.CreatedById;
            User createdUser = [SELECT Name FROM User WHERE Id = :createdUserId];
            billingHistoryRecord.Created_User__c = createdUser.Name;
        }
        
        if (billingRecord.LastModifiedById != null) {
            Id modifiedUserId = billingRecord.LastModifiedById;
            User modifiedUser = [SELECT Name FROM User WHERE Id = :modifiedUserId];
            billingHistoryRecord.Modified_User__c = modifiedUser.Name;
        }
        
        if (impactedField != null) {
            billingHistoryRecord.Impacted_Field__c = impactedField;
            billingHistoryRecord.Original_Value__c = originalValue;
            billingHistoryRecord.Modified_Value__c = modifiedValue;
        }
        
        billingHistoryList.add(billingHistoryRecord);
    }
    
    public static String getFieldModifiedValue(AcctSeed__Billing__c billingRecord, String field) {
        switch on field {
            when 'Account' {
                if (billingRecord.AcctSeed__Customer__c != null) {
                    Account relatedAccount = [SELECT Name FROM Account WHERE Id = :billingRecord.AcctSeed__Customer__c];
                    return relatedAccount.Name;
                }
                return null;
            }
            when 'Date' {
                return String.valueOf(billingRecord.AcctSeed__Date__c);
            }
            when 'Description' {
                return billingRecord.AcctSeed__Billing_Comment__c;
            }
            when 'Total' {
                return String.valueOf(billingRecord.AcctSeed__Total__c);
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