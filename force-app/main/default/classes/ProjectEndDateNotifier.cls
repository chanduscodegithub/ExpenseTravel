public class ProjectEndDateNotifier implements Schedulable {
    public void execute(SchedulableContext sc) {
        checkProjectEndDates();
        checkAgreementEndDates();
    }

    public static void checkProjectEndDates() {
        Date today = Date.today();
        List<Position__c> jobDetails = [
            SELECT Id, Project_Start_Date__c, Project_End_Date__c, Project_Extended_Date__c, Is_Project_Extended__c, 
                   Selected_Candidate__r.First_Name__c, Selected_Candidate__r.Last_Name__c, Country1__c, Position_Title__c,
                   Assets__c // Assume Assets__c is a field holding asset names separated by semicolons
            FROM Position__c
            WHERE Project_End_Date__c != NULL
        ];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress orgWideEmails = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address='noreply@crmit.com'];

        for (Position__c job : jobDetails) {
            Date endDate = job.Project_End_Date__c;
            if (job.Is_Project_Extended__c && job.Project_Extended_Date__c != null) {
                endDate = job.Project_Extended_Date__c;
            }

            Integer daysRemaining = today.daysBetween(endDate);
            System.debug('Days Remaining'+daysRemaining);
            // Check if the project end date is 14 or 7 days away
            if (daysRemaining == 14 || daysRemaining == 7) {
                String candidateName = job.Selected_Candidate__r.First_Name__c + ' ' + job.Selected_Candidate__r.Last_Name__c;
                String candidateCountry = job.Country1__c;
                String candidateRole = job.Position_Title__c;

                // Parse the assets
                List<String> assets = job.Assets__c != null ? job.Assets__c.split(';') : new List<String>();

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { 'vineet.kishore@crmit.com' });
                mail.setSubject('Project Renewal Reminder for ' + candidateName);

                // Construct the email body
                String emailBody = 'Dear Team,\n\n' +
                                   'This is to inform you that the project with job role "' + candidateRole + '" for ' + candidateName +
                                   ', from ' + candidateCountry + ' region, is ending in ' + 
                                   (daysRemaining == 14 ? 'two weeks' : 'one week') + '.\n\n';

                // Add renewal instructions based on remaining days
                if (daysRemaining == 14) {
                    emailBody += 'We kindly request you to initiate discussions regarding the renewal of this project to ensure continuity and avoid any potential disruptions.\n';
                } else if (daysRemaining == 7) {
                    emailBody += 'This is a gentle reminder to start the renewal process for the project to ensure seamless continuation.\n';
                }

                // Include Client Laptop notification only if it exists in assets
                if (assets.contains('Client Laptop')) {
                    if (daysRemaining == 7) {
                        emailBody += '\nPlease ensure that the "Client Laptop" is surrendered today as part of the project closure process.\n';
                    } else if (daysRemaining == 14) {
                        emailBody += '\nPlease ensure that the "Client Laptop" is prepared to be surrendered within a week as part of the project closure process.\n';
                    }
                }

                emailBody += '\nIf there are any questions or if an extension is required, please reach out to the appropriate stakeholders.\n\n';

                mail.setPlainTextBody(emailBody);

                // Add the email to the list
                emails.add(mail);
            }
        }

        // Send the emails if there are any to send
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    //method to check agreement end dates
    public static void checkAgreementEndDates() {
        Date today = Date.today();
        List<Position__c> jobDetails = [
            SELECT Id, Contract_End_Date__c, Selected_Candidate__r.First_Name__c, 
                   Selected_Candidate__r.Last_Name__c, Country1__c, Position_Title__c
            FROM Position__c
            WHERE Contract_End_Date__c != NULL
        ];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress orgWideEmails = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address='noreply@crmit.com'];

        for (Position__c job : jobDetails) {
            Date agreementEndDate = job.Contract_End_Date__c;
            Integer daysRemaining = today.daysBetween(agreementEndDate);

            // Check if the agreement end date is 30 days away
            if (daysRemaining == 30) {
                String candidateName = job.Selected_Candidate__r.First_Name__c + ' ' + job.Selected_Candidate__r.Last_Name__c;
                String candidateCountry = job.Country1__c;
                String candidateRole = job.Position_Title__c;
               
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { 'vineet.kishore@crmit.com' });
                mail.setSubject('Agreement Expiry Notification for ' + candidateName);

                // Construct the email body
                String emailBody = 'Dear Team,\n\n' +
                                'This is to inform you that the agreement for job role "' + candidateRole + '" for ' + candidateName +
                                ', from the ' + candidateCountry + ' region, is set to expire in 30 days.\n\n' +
                                'Please review this agreement and take appropriate actions if any approvals or extensions are required. Ensure all necessary stakeholders are informed about the upcoming expiry.\n\n' +
                                'If you have any questions or need assistance, please contact the relevant teams.\n\n';

                mail.setPlainTextBody(emailBody);
                emails.add(mail);
            }
        }

        // Send the emails if there are any to send
        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}