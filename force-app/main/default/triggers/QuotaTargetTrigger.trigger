trigger QuotaTargetTrigger on Revenue_Stream_Employee__c (before insert, before update) {
    // Get all User IDs from the Revenue_Stream_Employee__c records
    Set<Id> userIds = new Set<Id>();
    for (Revenue_Stream_Employee__c rse : Trigger.new) {
        if (rse.Employees__c != null) {
            userIds.add(rse.Employees__c);
        }
    }

    // Query Employee records based on Salesforce_SF_User__c field
    Map<Id, Employee__c> employeeMap = new Map<Id, Employee__c>();
    for(Employee__c emp : [SELECT Id, Designation__c, Region__c, CurrencyIsoCode, Salesforce_SF_User__c 
                            FROM Employee__c 
                            WHERE Salesforce_SF_User__c IN :userIds]) {
        employeeMap.put(emp.Salesforce_SF_User__c, emp);
    }

    // Update Revenue_Stream_Employee__c records with Designation, Region, and Currency from Employee records
    for (Revenue_Stream_Employee__c rse : Trigger.new) {
        if (rse.Employees__c != null && employeeMap.containsKey(rse.Employees__c)) {
            Employee__c emp = employeeMap.get(rse.Employees__c);
            rse.Role__c = emp.Designation__c;
           
        }
    }
}