trigger JobApplicantTrigger on Job_Application__c (after update) {
    /*for (Job_Application__c applicant : Trigger.new) {
        Job_Application__c oldApplicant = Trigger.oldMap.get(applicant.Id);

        // Check if Picklist__c status has changed to 'No show'
        if (applicant.Picklist__c != oldApplicant.Picklist__c && applicant.Picklist__c == 'No-Show For OnboardingO') {
            // Unlock the related Position record
            RRLockingUnlocking.unlockRRRecord(applicant.Position__c);

            // Schedule a job to lock the record again after 10 minutes
            RRLockScheduler.scheduleAction(applicant.Position__c, true);
        } else if (applicant.Picklist__c != oldApplicant.Picklist__c) {
            // If status changes to anything else, lock the related Position record immediately
            RRLockingUnlocking.lockRRRecord(applicant.Position__c);
        }
    }*/
}