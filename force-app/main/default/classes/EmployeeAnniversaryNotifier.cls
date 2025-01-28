public class EmployeeAnniversaryNotifier  implements Schedulable {

	public void execute(SchedulableContext sc) {
        findTodaysAnniversarys();
    }

  	public static void findTodaysAnniversarys() {
        // Get today's month and day
        Date today = Date.today();
        Integer currentMonth = today.month();
        Integer currentDay = today.day();
        Integer currentYear = today.year();

        // Query Employee__c records with matching anniversary month and day
		List<Employee__c> anniversaryEmployees = [
			SELECT Name, Email_ID__c, Geo_Date_of_Joining__c, DateofJoin__c
			FROM Employee__c
			WHERE Status__c = 'Active'  
                AND (Type__c ='Permanent' OR Type__c = 'Probationer')
                AND Department__c != 'General Admin' 
                AND (
				(Geo_Date_of_Joining__c != null 
                AND CALENDAR_MONTH(Geo_Date_of_Joining__c) = :currentMonth 
                AND DAY_IN_MONTH(Geo_Date_of_Joining__c) = :currentDay
                AND CALENDAR_YEAR(Geo_Date_of_Joining__c) <= :currentYear - 1)
				OR
				(Geo_Date_of_Joining__c = null 
                AND CALENDAR_MONTH(DateofJoin__c) = :currentMonth 
                AND DAY_IN_MONTH(DateofJoin__c) = :currentDay
                AND CALENDAR_YEAR(DateofJoin__c) <= :currentYear - 1)
			)
		];


        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress orgWideEmails = [SELECT Id, Address FROM OrgWideEmailAddress 
                    WHERE Address='hrteam@crmit.com'];

        for (Employee__c job : anniversaryEmployees) {    
                Date joiningDate = job.Geo_Date_of_Joining__c != null ? job.Geo_Date_of_Joining__c : job.DateofJoin__c;

            // Skip if no joining date is available
            if (joiningDate == null) {
                continue;
            }
            // Calculate years of service
            Integer yearsOfService = Date.today().year() - joiningDate.year();

            // Adjust for month and day to ensure the calculation is accurate
            if (Date.today().month() < joiningDate.month() || 
                (Date.today().month() == joiningDate.month() && Date.today().day() < joiningDate.day())) {
                yearsOfService--;
            }
            String yearLabel = (yearsOfService == 1) ? 'year' : 'years';

            String emailTemplate1 = 
            '<span style="font-size: 14px;">Dear ' + job.Name + ', <br/></span>' +
                '<span style="font-size: 14px;">' +
                'Today, we celebrate a remarkable milestone in your career journey - your work anniversary with CRMIT. <br/>' +
                'On this special day, we want to take a moment to express our heartfelt gratitude for your dedication, hard work, and commitment over the last ' +  yearsOfService + ' ' + yearLabel + '. ' + 'Your contributions have been invaluable, and your positive impact on the team is 			 immeasurable. <br/><br/>' +
                'Happy Work Anniversary1! Here\'s to your continued growth, prosperity, and many more years of achievements.' +
                '</span>' +
                '<br/><br/>' +
                '<div style="text-align: center;">' +
                '<img src="https://www.wp.crmit.com/wp-content/uploads/2025/01/Work-Anniversary.jpg" ' +
                'alt="Happy Work Anniversary" style="max-width: 400px; height: auto;">' +
                '</div>' +
                '<br/>' +
                '<span style="font-size: 14px;">Best Regards,</span> <br/>' +
                '<span style="font-size: 14px;">CRMIT Team</span>';
                
                String emailTemplate2 =
                '<span style="font-size: 14px;">Dear ' + job.Name + ', <br/></span>' +
                    '<span style="font-size: 14px;">' +
                    'Today, we celebrate a remarkable milestone in your career journey - your work anniversary with CRMIT. <br/>' +
                    'On this special day, we want to take a moment to express our heartfelt gratitude for your dedication, hard work, and commitment over the last ' +  yearsOfService + ' ' + yearLabel + '. ' + 'Your contributions have been invaluable, and your positive impact on the team is 			 immeasurable. <br/><br/>' +
                    'Happy Work Anniversary1! Here\'s to your continued growth, prosperity, and many more years of achievements.' +
                    '</span>' +
                    '<br/><br/>' +
                    '<div style="text-align: center;">' +
                    '<img src="https://d2w2i7rp1a0wob.cloudfront.net/media/2024/06/professional-work-anniversary-wishes-1024x673.png" ' +
                    'alt="Happy Work Anniversary2" style="max-width: 400px; height: auto;">' +
                    '</div>' +
                    '<br/>' +
                    '<span style="font-size: 14px;">Best Regards,</span> <br/>' +
                    '<span style="font-size: 14px;">CRMIT Team</span>';

                String emailTemplate3 =
                '<span style="font-size: 14px;">Dear ' + job.Name + ', <br/></span>' +
                '<span style="font-size: 14px;">' +
                'Today, we celebrate a remarkable milestone in your career journey - your work anniversary with CRMIT. <br/>' +
                'On this special day, we want to take a moment to express our heartfelt gratitude for your dedication, hard work, and commitment over the last ' +  yearsOfService + ' ' + yearLabel + '. ' + 'Your contributions have been invaluable, and your positive impact on the team is 			 immeasurable. <br/><br/>' +
                'Happy Work Anniversary3! Here\'s to your continued growth, prosperity, and many more years of achievements.' +
                '</span>' +
                '<br/><br/>' +
                '<div style="text-align: center;">' +
                '<img src="https://as1.ftcdn.net/jpg/09/28/05/54/1000_F_928055494_b308GM0spW9ofg2N2Me0pdDOjdCuTRyw.webp" ' +
                'alt="Happy Work Anniversary3" style="max-width: 400px; height: auto;">' +
                '</div>' +
                '<br/>' +
                '<span style="font-size: 14px;">Best Regards,</span> <br/>' +
                '<span style="font-size: 14px;">CRMIT Team</span>';

                 String template;
                if (yearsOfService >= 1 && yearsOfService <= 5) {
                    template = emailTemplate1;
                } else if (yearsOfService >= 6 && yearsOfService <= 10) {
                    template = emailTemplate2;
                } else {
                    template = emailTemplate3;
                } 
                
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            mail.setToAddresses(new String[] { job.Email_ID__c });
            mail.setSubject('Happy Work Anniversary!');
            mail.setOrgWideEmailAddressId(orgWideEmails.Id);
			mail.setCcAddresses(new String[] { 'poojitha.narapareddy@crmit.com'}); // CC recipients
            
            mail.setHtmlBody(template);
            emails.add(mail);
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
	}
}