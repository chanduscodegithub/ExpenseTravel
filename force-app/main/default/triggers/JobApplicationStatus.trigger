trigger JobApplicationStatus on Job_Application__c (after insert,after update) {
    // List to hold JobApplication records where candidate status is On Hold or Rejected
    List<Job_Application__c> jobApplicationsToNotify = new List<Job_Application__c>();

    // Loop through the updated JobApplication records
    for (Job_Application__c newJobApplication : Trigger.new) {
        // Compare with the previous value of the Candidate_Status field
        Job_Application__c oldJobApplication = Trigger.oldMap != null ? Trigger.oldMap.get(newJobApplication.Id) : null;

        // Check if the Candidate_Status has changed to "On Hold" or "Rejected"
        if ((newJobApplication.Picklist__c == 'On Hold' || newJobApplication.Picklist__c == 'Rejected') && (oldJobApplication == null ||
            oldJobApplication.Picklist__c != newJobApplication.Picklist__c)) {
            jobApplicationsToNotify.add(newJobApplication);
        }
    }

    // If there are any JobApplication records to notify, call the notification logic
    if (!jobApplicationsToNotify.isEmpty()) {
        jobapplicationhelper1.sendNotificationToCandidates(jobApplicationsToNotify);
    }
}


// Method to send notification to the candidates