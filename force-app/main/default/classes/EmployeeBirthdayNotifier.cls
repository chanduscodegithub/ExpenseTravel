public class EmployeeBirthdayNotifier  implements Schedulable {

	public void execute(SchedulableContext sc) {
        findTodaysBirthdays();
    }
	
    public static void findTodaysBirthdays() {
        // Get today's month and day
        Date today = Date.today();
        Integer currentMonth = today.month();
        Integer currentDay = today.day();

        // Query Employee__c records with matching Date_of_Birth__c month and day
        List<Employee__c> birthdayEmployees = [
            SELECT Name, Email_ID__c, Date_of_Birth__c ,Status__c
            FROM Employee__c 
            WHERE 	Status__c = 'Active' 
                AND (Type__c ='Permanent' OR Type__c = 'Probationer') 
                AND Department__c != 'General Admin' 
                AND CALENDAR_MONTH(Date_of_Birth__c) = :currentMonth 
                AND DAY_IN_MONTH(Date_of_Birth__c) = :currentDay
        ];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress orgWideEmails = [SELECT Id, Address FROM OrgWideEmailAddress 
                                            WHERE Address='hrteam@crmit.com'];
        
        // Define email body templates
        String emailTemplate1 = 
            '<div style="font-size: 16px; margin-bottom: 12px;">Dear {0}, <br/></div>' +
            '<span style="font-size: 16px;">' +
                'Wishing you a very Happy Birthday1!<br/><br/>' +
                'We hope your day is filled with joy and love.<br/>' +
                'May this new year bring you all the happiness and success you deserve.' +
            '</span>' +
            '<br/><br/>' +
            '<div style="text-align: center;">' +
                '<img src="https://www.wp.crmit.com/wp-content/uploads/2025/01/Birthday.gif" style="max-width: 300px; height: auto;">' +
            '</div>' 
           ;
        
        String emailTemplate2 = 
            '<div style="font-size: 16px; margin-bottom: 12px;">Dear {0}, <br/></div>' +
            '<span style="font-size: 16px;">' +
                'Happy Birthday2!<br/><br/>' +
                'We want to take this opportunity to celebrate you and all the wonderful things you bring to the team. ' +
                'May this year be your best one yet, filled with exciting opportunities and unforgettable moments.' +
            '</span>' +
            '<br/><br/>' +
            '<div style="text-align: center;">' +
                '<img src="https://www.angroos.com/wp-content/uploads/2024/01/DALL%E2%94%AC%E2%95%96E-2024-05-20-22.30.23-A-unique-and-ultra-realistic-birthday-greeting-card-featuring-a-stunningly-decorated-birthday-cake.-The-card-displays-_Happy-Birthday_-in-elegant-art-1.jpg" style="max-width: 300px; height: auto;">' +
            '</div>' 
           ;

        String emailTemplate3 = 
            '<div style="font-size: 16px; margin-bottom: 12px;">Dear {0}, <br/></div>' +
            '<span style="font-size: 16px;">' +
                'Happy Birthday3 to you!<br/><br/>' +
                'As you celebrate another year of life, we hope this special day brings you joy and fulfillment. ' +
                'We look forward to many more years of collaboration and success together.' +
            '</span>' +
            '<br/><br/>' +
            '<div style="text-align: center;">' +
                '<img src="https://www.angroos.com/wp-content/uploads/2024/01/simple-and-elegant-birthday-greeting-card.jpg" style="max-width: 300px; height: auto;">' +
            '</div>' 
           ;

        for (Employee__c job : birthdayEmployees) {
            String emailBody;
            Integer randomTemplate = (Integer) (Math.random() * 3) + 1;
          List<String> parameters = new List<String>{ job.Name };
            if (randomTemplate == 1) {
                emailBody = String.format(emailTemplate1, parameters);
            } else if (randomTemplate == 2) {
                emailBody = String.format(emailTemplate2, parameters);
            } else {
                emailBody = String.format(emailTemplate3, parameters);
            }

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { job.Email_ID__c });
            mail.setSubject('Happy Birthday!');
            mail.setOrgWideEmailAddressId(orgWideEmails.Id);
			mail.setCcAddresses(new String[] { 'poojitha.narapareddy@crmit.com'}); // CC recipients
  
            mail.setHtmlBody(emailBody);
            emails.add(mail);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
	}
}