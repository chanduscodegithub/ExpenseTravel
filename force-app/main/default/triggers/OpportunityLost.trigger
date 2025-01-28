trigger OpportunityLost on Opportunity (after insert, after update) {
    if (!OpportunityTriggerHandler.isExecuting) {
        OpportunityTriggerHandler.isExecuting = true; // Prevent recursion within the trigger

        Set<Id> accountIdsToCheck = new Set<Id>();

        // Collect Account IDs from all processed Opportunities
        for (Opportunity opp : Trigger.new) {
            if (opp.AccountId != null) {
                accountIdsToCheck.add(opp.AccountId);
            }
        }

        if (!accountIdsToCheck.isEmpty()) {
            // Map to track account IDs to a Boolean indicating if all related opportunities are lost
            Map<Id, Boolean> allLostMap = new Map<Id, Boolean>();

            // Retrieve all opportunities for the accounts and determine if all are 'Opportunity Lost'
            for (Opportunity opp : [SELECT Id, StageName, AccountId FROM Opportunity WHERE AccountId IN :accountIdsToCheck]) {
                Boolean currentStatus = allLostMap.get(opp.AccountId);
                // Initialize as true when first opportunity is seen or leave as is if already set to false
                if (currentStatus == null) {
                    allLostMap.put(opp.AccountId, true); 
                }
                // If any opportunity is not lost, set to false
                if (opp.StageName != 'Opportunity Lost') {
                    allLostMap.put(opp.AccountId, false);
                }
            }

            // Update accounts based on the findings
            List<Account> accountsToUpdate = new List<Account>();
            for (Id accountId : allLostMap.keySet()) {
                // Only prepare update if the account's current checkbox state differs from the calculated state
                Account acc = new Account(Id = accountId, Lost__c = allLostMap.get(accountId));
                accountsToUpdate.add(acc);
            }

            // Perform the account update if there are accounts to update
            if (!accountsToUpdate.isEmpty()) {
                update accountsToUpdate;
            }
        }

        OpportunityTriggerHandler.isExecuting = false; // Reset the static flag after execution
    }
}