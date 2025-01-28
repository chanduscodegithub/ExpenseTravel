trigger UpdateAccounts on IT_Landscape__c (after insert, after update) {

    // Lists to store Salesforce and Others records
    List<IT_Landscape__c> salesforceRecords = new List<IT_Landscape__c>();
    List<IT_Landscape__c> othersRecords = new List<IT_Landscape__c>();

    // Set to store unique Account IDs
    Set<Id> uniqueAccountIds = new Set<Id>();

    // Iterate through the inserted records and collect unique Account IDs
    for (IT_Landscape__c landscape : Trigger.new) {
        uniqueAccountIds.add(landscape.Account__c);
        if (landscape.Technology_Type__c == 'Salesforce') {
            salesforceRecords.add(landscape);
        } else if (landscape.Technology_Type__c == 'Others') {
            othersRecords.add(landscape);
        }
    }

    // List to store Account records for update
    List<Account> accountsToUpdate = new List<Account>();

    // Map to store the total number of users for each Account
    Map<Id, Decimal> accountUsersMap = new Map<Id, Decimal>();

    // Query and update Total Salesforce for Salesforce records
    if (!salesforceRecords.isEmpty()) {
        for (AggregateResult aggregateResult : [SELECT Account__c, SUM(Estimated_ACV__c) sumEstimatedACV, SUM(No_of_Licenses__c) sumNoOfUsers FROM IT_Landscape__c WHERE Account__c IN :uniqueAccountIds AND Technology_Type__c = 'Salesforce' GROUP BY Account__c]) {
            Id accountId = (Id)aggregateResult.get('Account__c');
            Decimal sumEstimatedACV = (Decimal)aggregateResult.get('sumEstimatedACV');
            Decimal sumNoOfUsers = (Decimal)aggregateResult.get('sumNoOfUsers');

            Account acc = new Account(Id = accountId);
            acc.Total_Salesforce__c = sumEstimatedACV;
            acc.Estimated_Salesforce_Users__c = sumNoOfUsers; // Update Total Salesforce Users field
            accountsToUpdate.add(acc);
            accountUsersMap.put(accountId, sumNoOfUsers);
        }
    }

    // Query and update Total Others for Others records
    if (!othersRecords.isEmpty()) {
        for (AggregateResult aggregateResult : [SELECT Account__c, SUM(Estimated_ACV__c) sumEstimatedACV, SUM(No_of_Licenses__c) sumNoOfUsers FROM IT_Landscape__c WHERE Account__c IN :uniqueAccountIds AND Technology_Type__c = 'Others' GROUP BY Account__c]) {
            Id accountId = (Id)aggregateResult.get('Account__c');
            Decimal sumEstimatedACV = (Decimal)aggregateResult.get('sumEstimatedACV');
            Decimal sumNoOfUsers = (Decimal)aggregateResult.get('sumNoOfUsers');

            Account acc = new Account(Id = accountId);
            acc.Total_Others__c = sumEstimatedACV;
            accountsToUpdate.add(acc);
            // Assuming Total_Others_Users__c is the field on the Account object for Others users
            acc.Estimated_other_Users__c = sumNoOfUsers; // Update Total Others Users field
            accountUsersMap.put(accountId, sumNoOfUsers);
        }
    }

   
    
    // Perform the update
    if (!accountsToUpdate.isEmpty()) {
        update accountsToUpdate;
    }
}