public class jobapplicationhelper {
    public static void sendNotificationToCandidates(List<Job_Application__c> jobApplications) {
    List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

    // Loop through each JobApplication record and send the email notification
    for (Job_Application__c jobApplication : jobApplications) {
        if (jobApplication.Candidate__c != null){
        // Get the Candidate record related to the JobApplication
        Candidate__c candidate = [SELECT First_Name__c, Email__c FROM Candidate__c WHERE Id = :jobApplication.Candidate__c LIMIT 1];

        // Check if candidate email is available
        if (candidate != null && candidate.Email__c != null) {
            // Prepare the email
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new String[] { candidate.Email__c });
            email.setSubject('Job Application Status Update');
            email.setPlainTextBody('Dear'+ candidate.First_Name__c +' your job application status has been updated to ' + jobApplication.Picklist__c	 + '.');

            // Add the email to the list
            emails.add(email);
        }
    }
    }

    // Send the emails in a batch
    if (!emails.isEmpty()) {
        Messaging.sendEmail(emails);
    }
    }

}