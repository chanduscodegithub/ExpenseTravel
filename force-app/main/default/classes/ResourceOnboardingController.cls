public without sharing class ResourceOnboardingController {

    @AuraEnabled(cacheable=true)
    public static String getAgreementUrl(String region,String agreementType) {
        System.debug('DEtails are'+region+agreementType);
        List<Agreement_File__mdt> agreements = [
            SELECT File_URL__c 
            FROM Agreement_File__mdt 
            WHERE Region__c = :region AND Agreement_Type__c = :agreementType
            LIMIT 1
        ];

        if (!agreements.isEmpty()) {
            return agreements[0].File_URL__c;
        } else {
            return null;
        }
    }

    @AuraEnabled
    public static List<Position__c> fetchEmployeeContracts(Id employeeId, Id currentRecordId) {
        if (employeeId == null) {
            throw new AuraHandledException('Employee ID is required.');
        }
        return [
            SELECT Id, Contract_Start_Date__c, Contract_End_Date__c 
            FROM Position__c 
            WHERE Employee_Record__c = :employeeId
            AND Id != :currentRecordId
        ];
    }

    @AuraEnabled(cacheable=true)
    public static Boolean getJobApplication(Id positionId) {
        List<Job_Application__c> job = [SELECT Id FROM Job_Application__c WHERE Position__c = :positionId];
        if (job.isEmpty()) {
            return false;
        }
        return true;
    }
    @AuraEnabled(cacheable=true)
    public static Boolean getSelectedApplication(Id positionId) {
        List<Job_Application__c> job = [SELECT Id,Picklist__c FROM Job_Application__c WHERE Position__c = :positionId AND (Picklist__c='Candidate Selected' OR Picklist__c='Selected') LIMIT 1];
        if (job.isEmpty()) {
            return false;
        }
        return true;
    }

    @AuraEnabled(cacheable=true)
    public static Boolean getHiringStatus(Id positionId) {
        Position__c position = [SELECT Status__c FROM Position__c WHERE Id = :positionId LIMIT 1];
        Boolean statusFlag;
        if(position.Status__c=='Joining Awaited' || position.Status__c=='Joined/Onboarded'){
            statusFlag=true;
        }
        else{
            statusFlag=false;
        }
        return statusFlag;
    }

    @AuraEnabled
    public static Position__c getCandidateDetails(Id positionId) {
        Position__c posDetail = [
            SELECT Id,Selected_Candidate__r.First_Name__c,Selected_Candidate__r.Last_Name__c,Selected_Candidate__r.Id,Technical_Capabilities__c,Is_Project_Extended__c, Hiring_Manager_name__c,Status__c,
                   Reason_for_Not_Eligible_to_Re_hire__c, CIN_Number__c, Has_CIN_Number__c, Selected_Candidate__r.Email__c, 
                   Eligible_to_Re_Hire__c,SOW_Sent__c, IT_Audit_Completed__c, Project_Extended_Date__c, Selected_Candidate__r.Candidate_Current_Location__c, Agreement_Type__c, Contract_End_Date__c, Contract_Start_Date__c,Nature_Of_Engagement__c,
                   ABN_Number__c, Has_ABN_Number__c,Employee_RecordId__c,Project_Start_Date__c, Project_End_Date__c,Candidate_Address__c, Country1__c,City1__c,BGV_Check__c,Assets_Provided__c,Assets__c, 
                   Visa_Type__c, Vendor__c,Vendor_Name__c,Agreement_Sent__c,Employee_Record__r.Email_ID__c,Employee_Record__r.EmployeeID__c,Document_1__c, Document_2__c, Document_3__c, Document_4__c, Document_5__c, Agreement_Url__c,Employee_Record__c
            FROM Position__c 
            WHERE Id = :positionId 
            LIMIT 1
        ];
        return posDetail;
    }

    @AuraEnabled
    public static List<TeamAllocation__c> getProjects(String employeeId) {
        System.debug('Employee Id is For Projects'+employeeId);
        List<TeamAllocation__c> results = [SELECT Id, Name, StartDate__c, EndDate__c, Project__r.Name
                                            FROM TeamAllocation__c
                                            WHERE EmployeeName__r.Id = :employeeId];
        System.debug('Records Retrieved: ' + results);
        return results;
    }
    
    @AuraEnabled
    public static String getOnboardingStatus(Id positionId) {
        Position__c position = [SELECT Onboarding_Status__c FROM Position__c WHERE Id = :positionId LIMIT 1];
        String pos=position.Onboarding_Status__c;
        return pos;
    }
	
    @AuraEnabled
    public static void saveOnboarding(Id jobId, String onboardingDetail) {
        System.debug('Job Id is'+jobId);
        Position__c pos = [
            SELECT  Id,Name FROM Position__c 
            WHERE Id = :jobId 
            LIMIT 1
        ];
        if (onboardingDetail != null) {
            pos.Onboarding_Status__c = onboardingDetail;
        }
        if(onboardingDetail=='Onboarded'){
            pos.Status__c='Joined/Onboarded';
        }
        update pos;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Position__c> getActiveApplications(String candidateId, Id currentJobAppId) {
        System.debug('Active App'+candidateId+currentJobAppId);
        return [SELECT Id, Contract_Start_Date__c, Technical_Capabilities__c,Employee_Record__c,Contract_End_Date__c, Agreement_URL__c,Agreement_Type__c, Country1__c, Visa_Type__c, Document_1__c, Document_2__c, Document_3__c, Document_4__c, Document_5__c,Reason_for_Not_Eligible_to_Re_hire__c,CIN_Number__c, Has_CIN_Number__c,Eligible_to_Re_Hire__c,
                ABN_Number__c, Has_ABN_Number__c
                FROM Position__c WHERE Selected_Candidate__c=:candidateId AND Contract_Start_Date__c <=TODAY AND Contract_End_Date__c >= TODAY  AND Id != :currentJobAppId
                ORDER BY CreatedDate DESC LIMIT 1];
    }

    /**
     * Send email to Finance team with the attached Draft Agreement
     * and instructions to send DocuSign to candidate and share signed DocuSign with recruiter.
    */

    @AuraEnabled
    public static void sendEmailToFinance(Map<String, Object> params) {

        // Extract parameters
        String fileName = (String) params.get('fileName');
        String base64Data = (String) params.get('fileData'); // This is Base64 encoded data
        String consultantName = (String) params.get('consultantName');

        // Validate parameters
        if (String.isBlank(fileName) || String.isBlank(base64Data) || String.isBlank(consultantName)) {
            throw new AuraHandledException('Missing required parameters: fileName, fileData, or consultantName.');
        }

        // Decode Base64 data to Blob
        Blob fileData;
        try {
            fileData = EncodingUtil.base64Decode(base64Data);
        } catch (Exception e) {
            throw new AuraHandledException('Failed to decode file data: ' + e.getMessage());
        }

        // Validate file size (25 MB limit for email attachments in Salesforce)
        if (fileData.size() > 26214400) { // 25 MB in bytes
            throw new AuraHandledException('File size exceeds the 25 MB limit.');
        }

        // Prepare email body
        String body = 'Dear Finance Team,<br><br>' +
                      'The Draft Agreement for consultant <strong>' + consultantName + '</strong> has been uploaded and attached.<br>' +
                      'Please find the document attached to this email.<br><br>' +
                      'Once signed, kindly share the signed DocuSign with the recruiter for processing.<br><br>' +
                      'Regards,<br>'+'TA Team<br>'+'This is an auto generated email. Please do not reply.';

        // Fetch Org-Wide Email Address dynamically (use the Display Name 'NoReply')
        OrgWideEmailAddress[] orgWideEmails = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'NoReply' LIMIT 1];
        if (orgWideEmails.isEmpty()) {
            throw new AuraHandledException('Org-Wide Email Address "NoReply" not found.');
        }

        // Create and configure the email message
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] { 'vineet.kishore@crmit.com' }); // Replace with the actual Finance team's email
        email.setSubject('Draft Agreement for DocuSign');
        email.setHtmlBody(body);
        email.setOrgWideEmailAddressId(orgWideEmails[0].Id);

        // Attach the document
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName(fileName);
        attachment.setBody(fileData);
        email.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });

        // Send the email
        try {
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        } catch (Exception e) {
            System.debug('Error sending email: ' + e.getMessage());
            throw new AuraHandledException('Failed to send email: ' + e.getMessage());
        }
    }


    @AuraEnabled
    public static void saveCandidateDetails(Id jobId, Map<String, Object> candidateDetails) {
        Position__c candidate = [
            SELECT  Id,Candidate_Name__c,SOW_Sent__c,Technical_Capabilities__c,Is_Project_Extended__c, Hiring_Manager_name__c, 
                   Reason_for_Not_Eligible_to_Re_hire__c,Vendor__c, CIN_Number__c, Has_CIN_Number__c, Selected_Candidate__r.Email__c, 
                   Eligible_to_Re_Hire__c, IT_Audit_Completed__c, Project_Extended_Date__c, Candidate_Address__c, Agreement_Type__c, Contract_End_Date__c, Contract_Start_Date__c,Nature_Of_Engagement__c,
                   ABN_Number__c, Has_ABN_Number__c,Employee_RecordId__c,Project_Start_Date__c, Project_End_Date__c, Country1__c,City1__c,BGV_Check__c,Assets_Provided__c,Assets__c, 
                   Visa_Type__c,Vendor_Name__c,Employee_Record__c,Agreement_Sent__c,Document_1__c, Document_2__c, Document_3__c, Document_4__c, Document_5__c, Agreement_Url__c
            FROM Position__c 
            WHERE Id = :jobId 
            LIMIT 1
        ];
        System.debug('Candidate Details'+candidateDetails+candidateDetails.containsKey('Enter_ABN_Number__c')+candidateDetails.containsKey('Skills__c'));
        if (candidateDetails.containsKey('Country1__c')) {
            candidate.Country1__c = (String) candidateDetails.get('Country1__c');
        }
        if (candidateDetails.containsKey('Agreement_Sent__c')) {
            candidate.Agreement_Sent__c = (Boolean) candidateDetails.get('Agreement_Sent__c');
        }
        if (candidateDetails.containsKey('Employee_Record__c')) {
            candidate.Employee_Record__c = (Id) candidateDetails.get('Employee_Record__c');
        }
        if (candidateDetails.containsKey('City1__c')) {
            candidate.City1__c = (String) candidateDetails.get('City1__c');
        }
        if (candidateDetails.containsKey('Vendor_Name__c')) {
            candidate.Vendor_Name__c = (String) candidateDetails.get('Vendor_Name__c');
        }
        if (candidateDetails.containsKey('Agreement_Type__c')) {
            candidate.Agreement_Type__c = (String) candidateDetails.get('Agreement_Type__c');
        }
        if (candidateDetails.containsKey('Vendor__c')) {
            candidate.Vendor__c = (String) candidateDetails.get('Vendor__c');
        }
        if (candidateDetails.containsKey('Assets_Provided__c')) {
            candidate.Assets_Provided__c = (Boolean) candidateDetails.get('Assets_Provided__c');
        }
        if (candidateDetails.containsKey('SOW_Sent__c')) {
            candidate.SOW_Sent__c = (Boolean) candidateDetails.get('SOW_Sent__c');
        }
        if (candidateDetails.containsKey('Assets__c')) {
            Object assetsProvidedObj = candidateDetails.get('Assets__c');
            if (assetsProvidedObj instanceof List<Object>) {
                List<Object> assetsList = (List<Object>) assetsProvidedObj;
                List<String> assetsStringList = new List<String>();
                for (Object asset : assetsList) {
                    if (asset instanceof String) {
                        assetsStringList.add((String) asset);
                    }
                }
                candidate.Assets__c = String.join(assetsStringList, ';');
            } else if (assetsProvidedObj instanceof String) {
                String assetsProvidedStr = (String) assetsProvidedObj;
                List<String> assetsStringList = assetsProvidedStr.substring(1, assetsProvidedStr.length() - 1).split(',\\s*');
                candidate.Assets__c = String.join(assetsStringList, ';');
            } else {
                candidate.Assets__c = ''; 
            }
        }
        if (candidateDetails.containsKey('Visa_Type__c')) {
            candidate.Visa_Type__c = (String) candidateDetails.get('Visa_Type__c');
        }
        if (candidateDetails.containsKey('Candidate_Name__c')) {
            candidate.Candidate_Name__c = (String) candidateDetails.get('Candidate_Name__c');
        }
        if (candidateDetails.containsKey('Contract_End_Date__c')) {
            candidate.Contract_End_Date__c = Date.valueOf((String) candidateDetails.get('Contract_End_Date__c'));
        }
        if (candidateDetails.containsKey('Contract_Start_Date__c')) {
            candidate.Contract_Start_Date__c = Date.valueOf((String) candidateDetails.get('Contract_Start_Date__c'));
        }
        if (candidateDetails.containsKey('ABN_Number__c')) {
            candidate.ABN_Number__c = (String) candidateDetails.get('ABN_Number__c');
        }
        if (candidateDetails.containsKey('Has_ABN_Number__c')) {
            candidate.Has_ABN_Number__c = (Boolean) candidateDetails.get('Has_ABN_Number__c');
        }
        if (candidateDetails.containsKey('Project_Start_Date__c')) {
            candidate.Project_Start_Date__c = Date.valueOf((String) candidateDetails.get('Project_Start_Date__c'));
        }
        if (candidateDetails.containsKey('Project_End_Date__c')) {
            candidate.Project_End_Date__c = Date.valueOf((String) candidateDetails.get('Project_End_Date__c'));
        }
        if (candidateDetails.containsKey('IT_Audit_Completed__c')) {
            candidate.IT_Audit_Completed__c = (Boolean)candidateDetails.get('IT_Audit_Completed__c');
        }
        if (candidateDetails.containsKey('Document_1__c')) {
            candidate.Document_1__c = (String) candidateDetails.get('Document_1__c');
        }
        if (candidateDetails.containsKey('Document_2__c')) {
            candidate.Document_2__c = (String) candidateDetails.get('Document_2__c');
        }
        if (candidateDetails.containsKey('Document_3__c')) {
            candidate.Document_3__c = (String) candidateDetails.get('Document_3__c');
        }
        if (candidateDetails.containsKey('Document_4__c')) {
            candidate.Document_4__c = (String) candidateDetails.get('Document_4__c');
        }
        if (candidateDetails.containsKey('Document_5__c')) {
            candidate.Document_5__c = (String) candidateDetails.get('Document_5__c');
        }
        if (candidateDetails.containsKey('Agreement_Url__c')) {
            candidate.Agreement_Url__c = (String) candidateDetails.get('Agreement_Url__c');
        }
        if (candidateDetails.containsKey('Project_Extended_Date__c') && candidateDetails.get('Project_Extended_Date__c') != null) {
            candidate.Project_Extended_Date__c = Date.valueOf((String) candidateDetails.get('Project_Extended_Date__c'));
        }

        if (candidateDetails.containsKey('Technical_Capabilities__c')) {
            candidate.Technical_Capabilities__c = (String) candidateDetails.get('Technical_Capabilities__c');
        }
        if (candidateDetails.containsKey('Is_Project_Extended__c')) {
            candidate.Is_Project_Extended__c = (Boolean) candidateDetails.get('Is_Project_Extended__c');
        }
        if (candidateDetails.containsKey('Consultant_Email__c')) {
            candidate.Consultant_Email__c = (String) candidateDetails.get('Consultant_Email__c');
        }
        if (candidateDetails.containsKey('Consultant_ID__c')) {
            candidate.Consultant_ID__c = (String) candidateDetails.get('Consultant_ID__c');
        }
        if (candidateDetails.containsKey('Eligible_to_Re_Hire__c')) {
            candidate.Eligible_to_Re_Hire__c = (Boolean) candidateDetails.get('Eligible_to_Re_Hire__c');
        }
        if (candidateDetails.containsKey('Reason_for_Not_Eligible_to_Re_hire__c') && candidateDetails.get('Reason_for_Not_Eligible_to_Re_hire__c')!=null) {
            candidate.Reason_for_Not_Eligible_to_Re_hire__c = (String) candidateDetails.get('Reason_for_Not_Eligible_to_Re_hire__c');
        }
        // if (candidateDetails.containsKey('Consultant_ID__c')) {
        //     candidate.Consultant_ID__c = (String) candidateDetails.get('Consultant_ID__c');
        // }
        if (candidateDetails.containsKey('Candidate_Address__c')) {
            candidate.Candidate_Address__c = (String) candidateDetails.get('Candidate_Address__c');
        }
        if (candidateDetails.containsKey('BGV_Check__c')) {
            candidate.BGV_Check__c = (Boolean) candidateDetails.get('BGV_Check__c');
        }
        if (candidateDetails.containsKey('Nature_Of_Engagement__c')) {
            candidate.Nature_Of_Engagement__c = (String) candidateDetails.get('Nature_Of_Engagement__c');
        }
        update candidate;
        System.debug('Candidate Details'+candidate);
    }

    @AuraEnabled
    public static String createEmployee(Id jobId) {
        try {
            Position__c selectedCandidate = [
                SELECT Candidate_Name__c, Selected_Candidate__r.First_Name__c,Selected_Candidate__r.Last_Name__c,Selected_Candidate__r.Mobile__c,City1__c,Country1__c, Project_Start_Date__c
                FROM Position__c
                WHERE Id = :jobId
                LIMIT 1
            ];

            if (selectedCandidate != null) {
                List<Employee__c> employees = [SELECT EmployeeID__c FROM Employee__c WHERE EmployeeID__c LIKE 'CT%' ORDER BY EmployeeID__c DESC LIMIT 1];
                String region;
                String consultantEmailId;
                String newEmployeeID;
                if (!employees.isEmpty()) {
                    String lastEmployeeID = employees[0].EmployeeID__c;
                    System.debug('Last Employee ID: ' + lastEmployeeID);
                    Integer nextNumber = Integer.valueOf(lastEmployeeID.substring(2)) + 1;
                    System.debug('Next Number is ' + nextNumber);
                    newEmployeeID = 'CT' + String.valueOf(nextNumber).leftPad(3, '0');
                } else {
                    newEmployeeID = 'CT001'; // If no employees are there, it will start with 001
                }

                System.debug('New Employee ID: ' + newEmployeeID); // Debug the new employee ID

                region=selectedCandidate.Country1__c;
                consultantEmailId=selectedCandidate.Selected_Candidate__r.First_Name__c + '.' + selectedCandidate.Selected_Candidate__r.Last_Name__c + '@crmit.com';
                consultantEmailId.toLowerCase();
                Employee__c newEmployee = new Employee__c(
                    Name = selectedCandidate.Selected_Candidate__r.First_Name__c+' '+selectedCandidate.Selected_Candidate__r.Last_Name__c,
                    EmployeeID__c = newEmployeeID,
                    DateofJoin__c = selectedCandidate.Project_Start_Date__c,
                    // Department__c = 'Delivery',
                    MobileNo__c = selectedCandidate.Selected_Candidate__r.Mobile__c,
                    Email_ID__c = consultantEmailId,
                    City__c=selectedCandidate.City1__c,
                    Country__c=region
                );

                insert newEmployee;
                System.debug('Employee Created: ' + newEmployee.Id + newEmployeeID);
                return newEmployee.Id+','+newEmployeeID+','+consultantEmailId;
            } else {
                System.debug('No Job Application found with Id: ' + jobId);
                return null; // Handle scenario where no job application is found
            }
        } catch (Exception e) {
            System.debug('Error creating employee record: ' + e.getMessage());
            throw e; 
        }
    }
}