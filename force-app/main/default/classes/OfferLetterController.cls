public without sharing class OfferLetterController {

    // Fetch Offer Letters based on some criteria (e.g., status, date)
    @AuraEnabled(cacheable=true)
    public static List<Offer_Letter__c> getOfferLetters() {
        try {
            // Fetch offer letters with necessary fields
            return [
                SELECT Id, Candidate_Name__c, Status__c, Date__c, Address__c, Designation__c, Salary__c,Candidate_Email__c
                FROM Offer_Letter__c
                ORDER BY Date__c DESC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching offer letters: ' + e.getMessage());
        }
    }

	// Insert a new Offer Letter record
    @AuraEnabled
    public static Offer_Letter__c createOfferLetter(String candidateName, String position, String salary, Date joiningDate) {
        try {
            // Create a new Offer Letter record
            Offer_Letter__c newOfferLetter = new Offer_Letter__c(
                Candidate_Name__c = candidateName,
                Designation__c = position,
                Salary__c = salary,
                Date__c = joiningDate,
                Status__c = 'Pending' // Default status
            );

            // Insert the record into Salesforce
            insert newOfferLetter;

            return newOfferLetter; // Return the newly created record

        } catch (Exception e) {
            throw new AuraHandledException('Error creating offer letter: ' + e.getMessage());
        }
    }

    // Generate PDF for selected Offer Letters
    @AuraEnabled
    public static String generateOfferLetterPDF(List<Id> offerLetterIds) {
        try {
            // Query the Offer Letters based on selected IDs
            List<Offer_Letter__c> selectedOfferLetters = [
                SELECT Id, Candidate_Name__c, Status__c, Date__c, Address__c, Designation__c, Salary__c
                FROM Offer_Letter__c
                WHERE Id IN :offerLetterIds
            ];

            // Generate the PDF (example logic for generating PDF)
            String pdfContent = 'Offer Letter Details:\n\n';

            for (Offer_Letter__c offer : selectedOfferLetters) {
                pdfContent += 'Candidate: ' + offer.Candidate_Name__c + '\n';
                pdfContent += 'Status: ' + offer.Status__c + '\n';
                pdfContent += 'Designation: ' + offer.Designation__c + '\n';
                pdfContent += 'Salary: ' + offer.Salary__c + '\n';
                pdfContent += 'Date: ' + offer.Date__c.format() + '\n\n';
            }

            // You can customize PDF generation logic based on your needs
            // For now, we're just returning the content in plain text
            // In a real use case, you'd use a library to convert this text into a PDF

            return pdfContent; // Placeholder for actual PDF content

        } catch (Exception e) {
            throw new AuraHandledException('Error generating PDF: ' + e.getMessage());
        }
    }

    // Send email to candidates with the offer letter details
    @AuraEnabled
    public static String sendOfferLetterEmail(List<Id> offerLetterIds) {
        try {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

            // Query the Offer Letters based on selected IDs
            List<Offer_Letter__c> selectedOfferLetters = [
                SELECT Id, Candidate_Name__c, Candidate_Email__c, Designation__c, Salary__c
                FROM Offer_Letter__c
                WHERE Id IN :offerLetterIds
            ];

            for (Offer_Letter__c offer : selectedOfferLetters) {
                // Create the email content
                String subject = 'Your Offer Letter';
                String body = 'Dear ' + offer.Candidate_Name__c + ',\n\n';
                body += 'We are pleased to offer you the position of ' + offer.Designation__c + '.\n';
                body += 'The offered salary is ' + offer.Salary__c + '.\n';
                body += 'We look forward to your confirmation.\n\n';
                body += 'Regards,\nCompany Name';

                // Create the email message
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(new String[] { offer.Candidate_Email__c });
                email.setSubject(subject);
                email.setPlainTextBody(body);

                // Add to list of emails to be sent
                emails.add(email);
            }

            // Send the emails
            if (!emails.isEmpty()) {
                Messaging.sendEmail(emails);
            }

            return 'Email(s) sent successfully.';
        } catch (Exception e) {
            throw new AuraHandledException('Error sending email: ' + e.getMessage());
        }
    }
}