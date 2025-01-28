public class OpportunityEmailSenderFollowup implements Schedulable {
    
    public void execute(SchedulableContext context) {
        sendEmailsToQualifiedOpportunitiesfollowup();
    }
    
    public static void sendEmailsToQualifiedOpportunitiesfollowup() {
        // Calculate the start and end of the current month
        DateTime dt1 = DateTime.Now();
        //DateTime dT = DateTime.newInstance(dt1.year(), dt1.month()+1, dt1.day(), dt1.hour(), dt1.minute(), dt1.second());
        Date currentDate = date.newinstance(dt1.year(), dt1.month(), dt1.day());
        System.debug('currentDatedt2::'+currentDate);
        
        //Date currentDate = Date.today();
        Date monthStartDate = currentDate.toStartOfMonth();
        
        // Calculate the end of the current month
        Integer year = currentDate.year();
        Integer month = currentDate.month();
        Integer lastDayOfMonth = Date.daysInMonth(year, month);
        Date monthEndDate = Date.newInstance(year, month, lastDayOfMonth);
        
        // Retrieve qualified opportunities within the current month
        List<Opportunity> qualifiedOpportunitiesUSA = [
            SELECT Id, Name, Expected_Project_End_Date__c, Expected_Project_Start_Date__c,
            AccountId, Account.Name, Opportunity_Region__c, Owner.Name, Renewed__c, Reason__c
            FROM Opportunity
            WHERE Expected_Project_End_Date__c >= :monthStartDate AND Expected_Project_End_Date__c <= :monthEndDate AND Opportunity_Region__c!=NULL AND Opportunity_Region__c = 'USA' 
            ORDER BY Expected_Project_End_Date__c
        ];
        
        List<Opportunity> qualifiedOpportunitiesANZ = [
            SELECT Id, Name, Expected_Project_End_Date__c, Expected_Project_Start_Date__c,
            AccountId, Account.Name, Opportunity_Region__c, Owner.Name, Renewed__c, Reason__c
            FROM Opportunity
            WHERE Expected_Project_End_Date__c >= :monthStartDate AND Expected_Project_End_Date__c <= :monthEndDate AND Opportunity_Region__c!=NULL AND Opportunity_Region__c = 'ANZ'
            ORDER BY Expected_Project_End_Date__c
        ];
        
        // Retrieve email addresses from the custom metadata type
        List<SendingEmailOpportunity__mdt> emailMetadataListUSA = [SELECT Emails__c FROM SendingEmailOpportunity__mdt WHERE Regions__c = 'USA'];
        List<SendingEmailAUDOpportunity__mdt> emailMetadataListANZ = [SELECT Emails__c FROM SendingEmailAUDOpportunity__mdt WHERE Regions__c = 'ANZ'];
        
        // Retrieve CC email addresses from the custom metadata type
        List<SendCCOpportunityMail__mdt> ccEmailMetadataList = [SELECT Emails__c FROM SendCCOpportunityMail__mdt];
        // Prepare sets to store unique email addresses
        Set<String> toAddressesUSA = new Set<String>();
        Set<String> toAddressesANZ = new Set<String>();
        Set<String> ccAddresses = new Set<String>();
        
        for (SendingEmailOpportunity__mdt metadata : emailMetadataListUSA) {
            // Split the comma-separated email addresses and add them to the set for USA
            String[] emails = metadata.Emails__c.split(',');
            toAddressesUSA.addAll(emails);
        }
        
        for (SendingEmailAUDOpportunity__mdt metadata : emailMetadataListANZ) {
            // Split the comma-separated email addresses and add them to the set for ANZ
            String[] emails = metadata.Emails__c.split(',');
            toAddressesANZ.addAll(emails);
        }
        
        for (SendCCOpportunityMail__mdt ccMetadata : ccEmailMetadataList) {
            // Split the comma-separated CC email addresses and add them to the set
            String[] emails = ccMetadata.Emails__c.split(',');
            ccAddresses.addAll(emails);
        }
        
        // Convert the sets to lists for sending emails
        List<String> toAddressesListUSA = new List<String>(toAddressesUSA);
        List<String> toAddressesListANZ = new List<String>(toAddressesANZ);
        List<String> ccAddressesList = new List<String>(ccAddresses);
        
        // Build the email body with a table of opportunity details for all qualified opportunities
        // Build the email body for USA
        String emailBodyUSA = 'Dear team,<br/><br/>';
        emailBodyUSA += 'Below are the list of Opportunities with Status updated towards renewal,for the month of ' + dt1.format('MMMM')+'\''+year+ '.<br/><br/>';
        emailBodyUSA += '<table style="width: 80%; border-collapse: collapse; border: 1px solid black;">'; // Increased width to 80%
        emailBodyUSA += '<tr>';
        emailBodyUSA += '<th style="text-align: center; border: 1px solid black; padding: 5px;">Sl.No</th>';
        emailBodyUSA += '<th style="text-align: center; border: 1px solid black; padding: 5px;">Opportunity</th>';
        emailBodyUSA += '<th style="text-align: center; border: 1px solid black; padding: 5px;">Account</th>';
        emailBodyUSA += '<th style="text-align: center; border: 1px solid black; padding: 5px;">Opportunity Region</th>';
        emailBodyUSA += '<th style="text-align: center; border: 1px solid black; padding: 5px;">Opportunity Owner</th>';
        emailBodyUSA += '<th style="text-align: center; border: 1px solid black; padding: 5px;">Start Date</th>';
        emailBodyUSA += '<th style="text-align: center; border: 1px solid black; padding: 5px;">End Date</th>';
        emailBodyUSA += '<th style="text-align: center; border: 1px solid black; padding: 5px;">Renewed</th>';
        emailBodyUSA += '<th style="text-align: center; border: 1px solid black; padding: 5px;">Reason</th>';
        emailBodyUSA += '</tr>';
        
        Integer serialNumberUSA = 1; // Initialize the serial number for USA
        for (Opportunity opp : qualifiedOpportunitiesUSA) {
            emailBodyUSA += '<tr>';
            emailBodyUSA += '<td style="text-align: center; border: 1px solid black; padding: 5px;">' + serialNumberUSA + '</td>';
            emailBodyUSA += '<td style="text-align: left; border: 1px solid black; padding: 5px;"><a href="' + getOpportunityURL(opp.Id) + '">' + (opp.Name != null ? opp.Name : '') + '</a></td>';            
            emailBodyUSA += '<td style="text-align: left; border: 1px solid black; padding: 5px;">' + (opp.Account.Name != null ? opp.Account.Name : '') + '</td>';
            emailBodyUSA += '<td style="text-align: center; border: 1px solid black; padding: 5px;">' + (opp.Opportunity_Region__c != null ? opp.Opportunity_Region__c : '') + '</td>';
            emailBodyUSA += '<td style="text-align: center; border: 1px solid black; padding: 5px;">' + (opp.Owner.Name != null ? opp.Owner.Name : '') + '</td>';
            emailBodyUSA += '<td style="text-align: center; border: 1px solid black; padding: 5px;">' + (opp.Expected_Project_Start_Date__c != null ? opp.Expected_Project_Start_Date__c.format() : '') + '</td>';
            emailBodyUSA += '<td style="text-align: center; border: 1px solid black; padding: 5px;">' + (opp.Expected_Project_End_Date__c != null ? opp.Expected_Project_End_Date__c.format() : '') + '</td>';
            emailBodyUSA += '<td style="text-align: center; border: 1px solid black; padding: 5px;">' + (opp.Renewed__c != null ? opp.Renewed__c : '') + '</td>';
            emailBodyUSA += '<td style="text-align: center; border: 1px solid black; padding: 5px;">' + (opp.Reason__c != null ? opp.Reason__c : '') + '</td>';
            emailBodyUSA += '</tr>';
            serialNumberUSA++;
        }
        
        emailBodyUSA += '</table><br/><br/>Regards,<br/> CRMIT';
        
        // Build the email body for ANZ
        String emailBodyANZ = 'Dear team,<br/><br/>';
        emailBodyANZ += 'Below are the list of Opportunities with Status updated towards renewal,for the month of ' + dt1.format('MMMM')+'\''+year+ '.<br/><br/>';
        emailBodyANZ += '<table style="width: 80%; border-collapse: collapse; border: 1px solid black;">'; // Increased width to 80%
        emailBodyANZ += '<tr><th style="text-align: center; border: 1px solid black; padding: 5px;">Sl.No</th><th style="text-align: center; border: 1px solid black; padding: 5px;">Opportunity</th><th style="text-align: center; border: 1px solid black; padding: 5px;">Account</th><th style="text-align: center; border: 1px solid black; padding: 5px;">Opportunity Region</th><th style="text-align: center; border: 1px solid black; padding: 5px;">Opportunity Owner</th><th style="text-align: center; border: 1px solid black; padding: 5px;">Start Date</th><th style="text-align: center; border: 1px solid black; padding: 5px;">End Date</th>';
        emailBodyANZ += '<th style="text-align: center; border: 1px solid black; padding: 5px;">Renewed</th>';
        emailBodyANZ += '<th style="text-align: center; border: 1px solid black; padding: 5px;">Reason</th>';
        emailBodyANZ += '</tr>';
        
        Integer serialNumberANZ = 1; // Initialize the serial number for ANZ
        for (Opportunity opp : qualifiedOpportunitiesANZ) {
            emailBodyANZ += '<tr><td style="text-align: center; border: 1px solid black; padding: 5px;">' + serialNumberANZ + '</td>';
            emailBodyANZ += '<td style="text-align: left; border: 1px solid black; padding: 5px;"><a href="' + getOpportunityURL(opp.Id) + '">' + (opp.Name != null ? opp.Name : '') + '</a></td>';
            emailBodyANZ += '<td style="text-align: left; border: 1px solid black; padding: 5px;">' + (opp.Account.Name != null ? opp.Account.Name : '') + '</td>';
            emailBodyANZ += '<td style="text-align: center; border: 1px solid black; padding: 5px;">' + (opp.Opportunity_Region__c != null ? opp.Opportunity_Region__c : '') + '</td>';
            emailBodyANZ += '<td style="text-align: center; border: 1px solid black; padding: 5px;">' + (opp.Owner.Name != null ? opp.Owner.Name : '') + '</td>';
            emailBodyANZ += '<td style="text-align: center; border: 1px solid black; padding: 5px;">' + (opp.Expected_Project_Start_Date__c != null ? opp.Expected_Project_Start_Date__c.format() : '') + '</td>';
            emailBodyANZ += '<td style="text-align: center; border: 1px solid black; padding: 5px;">' + (opp.Expected_Project_End_Date__c != null ? opp.Expected_Project_End_Date__c.format() : '') + '</td>';
            emailBodyANZ += '<td style="text-align: center; border: 1px solid black; padding: 5px;">' + (opp.Renewed__c != null ? opp.Renewed__c : '') + '</td>';
            emailBodyANZ += '<td style="text-align: center; border: 1px solid black; padding: 5px;">' + (opp.Reason__c != null ? opp.Reason__c : '') + '</td>';
            serialNumberANZ++;
        }
        
        emailBodyANZ += '</table><br/><br/>Regards,<br/> CRMIT';
        
        // Create and send emails to unique email addresses for USA and ANZ with CC recipients
        if (!toAddressesListUSA.isEmpty()) {
            sendEmail(emailBodyUSA, toAddressesListUSA, ccAddressesList, 'Opportunities due for renewal for the month of -' + dt1.format('MMMM')+'\''+year+'(USA)');
        }
        
        if (!toAddressesListANZ.isEmpty()) {
            sendEmail(emailBodyANZ, toAddressesListANZ, ccAddressesList, 'Opportunities due for renewal for the month of -' + dt1.format('MMMM')+'\''+year+'(ANZ)');
        }
    }
    
    private static void sendEmail(String emailBody, List<String> toAddressesList, List<String> ccAddressesList, String emailSubject) {
        // Create a single email message
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        // Send emails to unique email addresses
        email.setToAddresses(toAddressesList);
        
        // Add CC recipients
        email.setCcAddresses(ccAddressesList);
        
        email.setSubject(emailSubject);
        
        email.setHtmlBody(emailBody);
        
        // Add the email to a list and send it
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>{email};
            
            // Send the email
            Messaging.sendEmail(emailList);
    }
    
    private static String getOpportunityURL(Id opportunityId) {
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        return baseUrl + '/' + opportunityId;
    }
   
}