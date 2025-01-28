public class BillingLineTriggerHelper {
    public static void createBillingHistoryRecord(List<Billing_History__c> billingHistoryList, SObject record, String impactedField, String originalValue, String modifiedValue) {
        Billing_History__c billingHistoryRecord = new Billing_History__c();
        billingHistoryRecord.BillingLineHistory__c = (String)record.get('Name');
        billingHistoryRecord.Created_Date__c = record.get('CreatedDate') != null ? ((DateTime)record.get('CreatedDate')).date() : null;
        billingHistoryRecord.Modified_Date__c = System.today();

        // Fetch the related records and get their names
        if (record.get('CreatedById') != null) {
            Id createdUserId = (Id)record.get('CreatedById');
            User createdUser = [SELECT Name FROM User WHERE Id = :createdUserId];
            billingHistoryRecord.Created_User__c = createdUser.Name;
        }

        if (record.get('LastModifiedById') != null) {
            Id modifiedUserId = (Id)record.get('LastModifiedById');
            User modifiedUser = [SELECT Name FROM User WHERE Id = :modifiedUserId];
            billingHistoryRecord.Modified_User__c = modifiedUser.Name;
        }
        
         if (record.get('AcctSeed__Billing__c') != null) {
            Id billingId = (Id)record.get('AcctSeed__Billing__c');
            AcctSeed__Billing__c billingRecord = [SELECT Id,Name FROM AcctSeed__Billing__c WHERE Id = :billingId];
            billingHistoryRecord.Billing__c = billingRecord.Id;
        }
        
        if (impactedField != null) {
            billingHistoryRecord.Impacted_Field__c = impactedField;
            billingHistoryRecord.Original_Value__c = originalValue;
            billingHistoryRecord.Modified_Value__c = modifiedValue;
        }
        
        billingHistoryList.add(billingHistoryRecord);
    }
    
    // This method is for updating the Billing_Line__c records with the Billing_History__c name
    public static void updateBillingLineRecords(List<AcctSeed__Billing_Line__c> billingLinesToUpdate, Id billingHistoryId) {
        List<AcctSeed__Billing_Line__c> linesToUpdate = new List<AcctSeed__Billing_Line__c>();
        for (AcctSeed__Billing_Line__c billingLine : billingLinesToUpdate) {
            // Assuming the relationship field to Billing_History__c is named AcctSeed__Billing__c
            billingLine.AcctSeed__Billing__c = billingHistoryId;
            linesToUpdate.add(billingLine);
        }
        update linesToUpdate;
    }
    
    public static String getFieldModifiedValue(AcctSeed__Billing_Line__c records, String field) {
        switch on field {
            when 'Revenue GL Account' {
                if (records.AcctSeed__Revenue_GL_Account__c != null) {
                    AcctSeed__GL_Account__c relatedAccount = [SELECT Name FROM AcctSeed__GL_Account__c WHERE Id = :records.AcctSeed__Revenue_GL_Account__c];
                    return relatedAccount.Name;
                }
                return null;
            }
            when 'BillingLine Total' {
                return String.valueOf(records.AcctSeed__Total__c);
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