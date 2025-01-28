public class ProjectOffboardingNotifier implements Schedulable {
    public void execute(SchedulableContext sc) {
        sendOffboardingNotifications();
    }

    public static void sendOffboardingNotifications() {
        Date today = Date.today();

        // Query job applications where either the original end date or the extended end date is today
        List<Position__c> jobDetails = [
            SELECT Id, Project_Start_Date__c, Project_End_Date__c, Project_Extended_Date__c, Is_Project_Extended__c, 
                   Selected_Candidate__r.First_Name__c, Selected_Candidate__r.Last_Name__c, Country1__c,Position_Title__c
            FROM Position__c
            WHERE (Project_End_Date__c = :today AND Is_Project_Extended__c = false)
               OR (Project_Extended_Date__c = :today AND Is_Project_Extended__c = true)
        ];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress orgWideEmails = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address='noreply@crmit.com'];
        for (Position__c job : jobDetails) {
            String candidateName = job.Selected_Candidate__r.First_Name__c + ' ' + job.Selected_Candidate__r.Last_Name__c;
            String candidateCountry = job.Country1__c;
            String candidateRole = job.Position_Title__c;

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { 'vineet.kishore@crmit.com' });
            mail.setSubject('Offboarding Notification for ' + candidateName);
            mail.setOrgWideEmailAddressId(orgWideEmails.Id);
            String emailBody = 'Dear Team,\n\n' +
                               'We want to inform you that Mr./Ms. ' + candidateName + ' is exiting their role as ' + candidateRole +
                               ', from ' + candidateCountry + ' region.\n\n' +
                               'Kindly ensure that all other formalities are taken care of.\n\n' +
                               'Thank you.\n\n';
            mail.setPlainTextBody(emailBody);

            emails.add(mail);


            Messaging.SingleEmailMessage mailIt = new Messaging.SingleEmailMessage();
            mailIt.setToAddresses(new String[] { 'vineet.kishore@crmit.com' });
            mailIt.setSubject('Offboarding Notification for ' + candidateName);
            mailIt.setOrgWideEmailAddressId(orgWideEmails.Id);
            String emailBodyForIT = 'Dear IT Team,\n\n' +
                                    'We would like to inform you that Mr./Ms. ' + candidateName + ' is exiting their role as ' + candidateRole +
                                    ' from the ' + candidateCountry + ' region. As part of the offboarding process, please ensure that all company assets, such as laptops and other assets, assigned to ' + candidateName + ' are collected. Additionally, deactivate all software licenses and access permissions associated with ' + candidateName + '.\n\n' +
                                    'Thank you.\n\n';
            mailIt.setPlainTextBody(emailBodyForIT);
            emails.add(mailIt);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}