trigger UpdateQuotaTypeonEmployee on Revenue_Stream_Employee__c (after insert, after update) {
    Set<Id> userIds = new Set<Id>();
    Map<Id, String> userIdToQuotaType = new Map<Id, String>();
    
    // Collecting User Ids and their corresponding Quota Types from Revenue_Stream_Employee__c records
    for (Revenue_Stream_Employee__c revStreamEmp : Trigger.new) {
        if (revStreamEmp.Quota_Type__c != null) {
            userIds.add(revStreamEmp.Employees__c);
            userIdToQuotaType.put(revStreamEmp.Employees__c, revStreamEmp.Quota_Type__c);
        }
    }
    
    // Querying Employee__c records where Employees__c matches Salesforce_SF_User__c in Revenue_Stream_Employee__c
    List<Employee__c> employeesToUpdate = [SELECT Id, Quota_Type__c, Salesforce_SF_User__c
                                            FROM Employee__c
                                            WHERE Salesforce_SF_User__c IN :userIds];
    
    // Updating Quota_Type__c in matching Employee__c records
    for (Employee__c employee : employeesToUpdate) {
        if (userIdToQuotaType.containsKey(employee.Salesforce_SF_User__c)) {
            employee.Quota_Type__c = userIdToQuotaType.get(employee.Salesforce_SF_User__c);
        }
    }
    
    // Performing the update
    if (!employeesToUpdate.isEmpty()) {
        update employeesToUpdate;
    }
}