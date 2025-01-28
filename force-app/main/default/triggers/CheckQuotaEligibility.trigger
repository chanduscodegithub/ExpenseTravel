trigger CheckQuotaEligibility on Revenue_Stream_Employee__c (before insert, before update) {
   if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            Set<Id> userIds = new Set<Id>();
            Map<Id, Revenue_Stream_Employee__c> userRecordMap = new Map<Id, Revenue_Stream_Employee__c>();

            for (Revenue_Stream_Employee__c record : Trigger.new) {
                if (record.Type__c == 'Quota') {
                    userIds.add(record.Employees__c);
                    userRecordMap.put(record.Employees__c, record);
                }
            }

            List<Employee__c> eligibleEmployees = [SELECT Id, Eligible_for_Quota__c, SF_User__c
                                                    FROM Employee__c
                                                    WHERE SF_User__c IN :userIds];

            for (Employee__c emp : eligibleEmployees) {
                if (emp.Eligible_for_Quota__c == false) {
                    Revenue_Stream_Employee__c recordWithError = userRecordMap.get(emp.SF_User__c);
                    recordWithError.addError('Selected user is not eligible for quota');
                }
            }
        }
    }
     
}