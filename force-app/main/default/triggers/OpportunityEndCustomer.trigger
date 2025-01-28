trigger OpportunityEndCustomer  on Opportunity (after insert, after update) {
    if (!OpportunityTriggerHandler.isExecuting) {
        OpportunityTriggerHandler.isExecuting = true; // Set the static variable to true to indicate that trigger is executing
        
        Set<Id> accountIdsToUpdate = new Set<Id>();

        // Identify Opportunities with Closed Won stage and collect their related Account IDs
        for (Opportunity opp : Trigger.new) {
            if (opp.StageName == 'Opportunity Won') {
                accountIdsToUpdate.add(opp.End_Customer__c);
            }
        }

        // Query the related Accounts and update the checkbox field
        List<Account> accountsToUpdate = [SELECT Id, Checkbox_for_Dashboard__c FROM Account WHERE Id IN :accountIdsToUpdate AND Checkbox_for_Dashboard__c = false];
        for (Account acc : accountsToUpdate) {
            acc.Checkbox_for_Dashboard__c = true;
        }

        // Perform the update
        if (!accountsToUpdate.isEmpty()) {
            update accountsToUpdate;
        }

        OpportunityTriggerHandler.isExecuting = false; // Set the static variable back to false after trigger logic execution
    }
}