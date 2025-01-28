public class assetEmailTriggerHandler {
    public static Boolean runOnce = false;

    public static void sendEmails(List<Position__c> newList, Map<Id, Position__c> oldMap) {
        
        System.debug('sendEmails method called');
        if (runOnce == false) {
            runOnce = true;
            try {
                List<Id> jobAppIdsToQuery = new List<Id>();
System.debug('New Value: ' + newList[0].Assets_Provided__c);
System.debug('Old Value: ' + oldMap.get(newList[0].Id).Assets_Provided__c);
System.debug('Entire New List: ' + newList);
System.debug('Old Map: ' + oldMap);

                for (Position__c jobApp : newList) {
                    if (jobApp.Assets_Provided__c == true && oldMap.get(jobApp.Id).Assets_Provided__c == false) {
                        jobAppIdsToQuery.add(jobApp.Id);
                    }
                }
                System.debug('jobAppIdsToQuery'+jobAppIdsToQuery);
                if (!jobAppIdsToQuery.isEmpty()) {
                    List<Position__c> jobApplicationsToEmail = [
                        SELECT Id, Assets_Provided__c, Candidate_Address__c, Country1__c, City1__c, Project_Start_Date__c, Project_End_Date__c,
                               Selected_Candidate__r.First_Name__c, Selected_Candidate__r.Last_Name__c
                        FROM Position__c
                        WHERE Id IN :jobAppIdsToQuery
                    ];

                    System.debug('jobApplicationsToEmail'+jobApplicationsToEmail);
                    if (!jobApplicationsToEmail.isEmpty()) {
                        sendAssetEmails(jobApplicationsToEmail);
                    }
                }
                List<Id> positionIdsToUpdate = collectPositionIdsToUpdate(newList, oldMap);
                if (!positionIdsToUpdate.isEmpty()) {
                    updateSelectedCandidates(positionIdsToUpdate);
                }
            } finally {
                runOnce = false; // Ensure the static variable is reset
            }
        }
    }

    private static void sendAssetEmails(List<Position__c> jobApplications) {
        System.debug('sendAssetEmails Method called');
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress orgWideEmails = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address=	'avishkaar@crmit.com'];
        for (Position__c jobApp : jobApplications) {
            String projectDuration = calculateProjectDuration(jobApp.Project_Start_Date__c, jobApp.Project_End_Date__c);

            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            String candidateName = jobApp.Selected_Candidate__r.First_Name__c + ' ' + jobApp.Selected_Candidate__r.Last_Name__c;
            // email.setOrgWideEmailAddressId(orgWideEmails.Id);
            email.setToAddresses(new String[] { 'vineet.kishore@crmit.com' });
            email.setSubject('New Consultant Onboarded - Asset Required');
            String htmlBody = '<html><body style="font-family: Arial, sans-serif; font-size: 13px;">';
            htmlBody += 'Dear IT Team,<br/><br/>';
            htmlBody += 'Please be informed that a new consultant has been onboarded and requires the necessary assets for their assignment. Below are the details:<br/><br/>';
            htmlBody += '<strong>Consultant Name: </strong>' + candidateName + '<br/><br/>';
            htmlBody += '<strong>Address: </strong>' + jobApp.Candidate_Address__c + '<br/><br/>';
            htmlBody += '<strong>Location: </strong>' + jobApp.City1__c + ',' + jobApp.Country1__c + '<br/><br/>';
            htmlBody += '<strong>Project Duration: </strong>' + projectDuration + '<br/><br/>';
            htmlBody += 'Please ensure that the required assets are arranged and delivered promptly.<br/><br/>';
            htmlBody += 'Thank you for your cooperation.<br/><br/>';
            htmlBody += '</body></html>';

            email.setHtmlBody(htmlBody);
            emails.add(email);
        }

        if (!emails.isEmpty()) {
            System.debug('emails are'+emails);
            Messaging.sendEmail(emails);
        }
    }

    private static String calculateProjectDuration(Date startDate, Date endDate) {
        if (startDate == null || endDate == null) {
            return 'N/A';
        }

        Integer years = endDate.year() - startDate.year();
        Integer months = endDate.month() - startDate.month();
        Integer days = endDate.day() - startDate.day();

        if (days < 0) {
            months -= 1;
            days += Date.daysInMonth(startDate.year(), startDate.month());
        }

        if (months < 0) {
            years -= 1;
            months += 12;
        }

        String duration = '';
        if (years > 0) {
            duration += years + ' year' + (years > 1 ? 's' : '') + ' ';
        }
        if (months > 0) {
            duration += months + ' month' + (months > 1 ? 's' : '') + ' ';
        }
        if (days > 0) {
            duration += days + ' day' + (days > 1 ? 's' : '');
        }
        return duration.trim();
    }

    private static List<Id> collectPositionIdsToUpdate(List<Position__c> newList, Map<Id, Position__c> oldMap) {
        List<Id> positionIdsToUpdate = new List<Id>();

        for (Position__c newPos : newList) {
            Position__c oldPos = oldMap.get(newPos.Id);
            if (newPos.Status__c == 'Joining Awaited' && oldPos.Status__c != 'Joining Awaited') {
                positionIdsToUpdate.add(newPos.Id);
            }
        }

        return positionIdsToUpdate;
    }

    public static void updateSelectedCandidates(List<Id> positionIdsToUpdate) {
        List<Position__c> positionsToUpdate = new List<Position__c>();

        List<Position__c> positions = [SELECT Id, (SELECT Id, Candidate__c FROM Job_Applications__r WHERE Candidate__c != null AND Picklist__c = 'Selected')
                                       FROM Position__c WHERE Id IN :positionIdsToUpdate];

        for (Position__c position : positions) {
            if (!position.Job_Applications__r.isEmpty()) {
                position.Selected_Candidate__c = position.Job_Applications__r[0].Candidate__c;
                positionsToUpdate.add(position);
            }
        }

        if (!positionsToUpdate.isEmpty()) {
            update positionsToUpdate;
        }
    }
}