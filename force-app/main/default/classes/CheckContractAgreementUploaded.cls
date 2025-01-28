public class CheckContractAgreementUploaded implements Schedulable {

    // Entry point for the schedulable job
    public void execute(SchedulableContext sc) {
        sendDocuSignAgreementReminders();
    }

    // Main logic for sending reminders
    public static void sendDocuSignAgreementReminders() {
        // Query Positions with pending DocuSign Agreement URL and valid contract start date
        List<Position__c> pendingAgreements = [
            SELECT Id, Selected_Candidate__r.First_Name__c, Selected_Candidate__r.Last_Name__c, 
                   Contract_Start_Date__c, Country1__c, City1__c, 
                   Project_Start_Date__c, Project_End_Date__c, Agreement_URL__c, 
                   Recruiter__c, Recruiter_2__c
            FROM Position__c
            WHERE Agreement_URL__c = NULL AND Contract_Start_Date__c != NULL
        ];

        // Prepare email messages
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        Date today = Date.today();

        for (Position__c job : pendingAgreements) {
            Integer daysElapsed = job.Contract_Start_Date__c.daysBetween(today);

            if (daysElapsed == 3) {
                // 3rd Day Reminder: Send to recruiter only
                emails.add(prepareReminderEmail(job, new String[] { job.Recruiter__r.Email }, null, false));  
            } else if (daysElapsed == 5) {
                // 5th Day Reminder: Send to recruiter, CC TA Manager
                emails.add(prepareReminderEmail(
                    job, 
                    new String[] { job.Recruiter__r.Email },      //Recruiter Email Id
                    new String[] { job.Recruiter_2__r.Email },   //Add TA Manager Email iD
                    true
                ));
            }
        }

        // Send emails if any
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    // Prepare reminder email
    private static Messaging.SingleEmailMessage prepareReminderEmail(Position__c job, String[] recipients, String[] ccRecipients, Boolean isFinalReminder) {
        Date projectStartDate = job.Project_Start_Date__c;
        Date projectEndDate = job.Project_End_Date__c;
        OrgWideEmailAddress orgWideEmails = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address='noreply@crmit.com'];
        // Calculate project duration
        String duration = calculateProjectDuration(projectStartDate, projectEndDate);

        // Construct candidate details
        String candidateName = job.Selected_Candidate__r.First_Name__c + ' ' + job.Selected_Candidate__r.Last_Name__c;
        String candidateLocation = job.City1__c + ', ' + job.Country1__c;

        // Build the email
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(recipients);
        if (ccRecipients != null) {
            mail.setCcAddresses(ccRecipients);
        }
        mail.setSubject('Upload DocuSign Agreement Reminder for ' + candidateName);
        mail.setOrgWideEmailAddressId(orgWideEmails.Id);
        // Email Body
        String emailBody = buildEmailBody(candidateName, projectStartDate, candidateLocation, duration, isFinalReminder);
        mail.setHtmlBody(emailBody);

        return mail;
    }

    // Calculate project duration in years, months, and days
    private static String calculateProjectDuration(Date startDate, Date endDate) {
        Integer totalDays = startDate.daysBetween(endDate);
        Integer years = totalDays / 365;
        totalDays -= years * 365;
        Integer months = totalDays / 30;
        totalDays -= months * 30;

        // Build duration string
        String duration = '';
        if (years > 0) duration += years + ' years, ';
        if (months > 0 || years > 0) duration += months + ' months, ';
        duration += totalDays + ' days';

        return duration;
    }

    // Build the HTML email body
    private static String buildEmailBody(String candidateName, Date projectStartDate, String location, String duration, Boolean isFinalReminder) {
        String reminderType = isFinalReminder ? 'Final Reminder' : 'Reminder';

        return '<html>' +
               '<body style="font-family: Arial, sans-serif; font-size: 12px;">' +
               'Dear [Recruiter/TA Head/Manager],<br><br>' +
               'This is a ' + reminderType + ' that the DocuSign agreement for the following consultant is still pending upload:<br><br>' +
               '<strong>Consultant Name:</strong> ' + candidateName + '<br>' +
               '<strong>Onboarding Date:</strong> ' + projectStartDate + '<br>' +
               '<strong>Location:</strong> ' + location + '<br>' +
               '<strong>Project Duration:</strong> ' + duration + '<br><br>'+
               'Thank you.<br><br>' +
               '</body>' +
               '</html>';
    }
}