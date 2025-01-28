public class ProjectOnboardingNotifier implements Schedulable {
    public void execute(SchedulableContext sc) {
        sendOnboardingNotifications();
    }

    public static void sendOnboardingNotifications() {
       Date tomorrow = Date.today().addDays(1);
        // Query job applications with start dates of today
        List<Position__c> jobDetails = [
            SELECT Id, Project_Start_Date__c, Project_End_Date__c, Project_Extended_Date__c, Is_Project_Extended__c, 
                   Selected_Candidate__r.First_Name__c, Selected_Candidate__r.Last_Name__c, Country1__c,Position_Title__c
            FROM Position__c
            WHERE Project_Start_Date__c = :tomorrow
        ];
        

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress orgWideEmails = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address='noreply@crmit.com'];

        for (Position__c job : jobDetails) {
            String candidateName = job.Selected_Candidate__r.First_Name__c + ' ' + job.Selected_Candidate__r.Last_Name__c;
            String candidateCountry = job.Country1__c;
            String candidateRole = job.Position_Title__c;

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { 'vineet.kishore@crmit.com' });
            mail.setSubject('Onboarding ' + candidateName);
            mail.setOrgWideEmailAddressId(orgWideEmails.Id);
            // Construct the email body for onboarding
            String emailBody = '<html>' +
                                '<body style="font-family: Arial, sans-serif; font-size: 12px;">' +
                                'Dear Team,<br><br>' +
                                'We are pleased to inform you that Mr./Ms. <b>' + candidateName + '</b> has joined us as <b>' + candidateRole + '</b>,' +
                                ' in the ' + candidateCountry + ' region.<br><br>' +
                                'Kindly ensure that all other formalities are taken care of.<br><br>' +
                                'Thank you.<br><br>' +
                                '</body>' +
                                '</html>';
            mail.setHtmlBody(emailBody);
            emails.add(mail);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }
}