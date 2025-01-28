/**
* @File Name : HrPolicyDocumentsController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : January 13, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | January 13, 2025 |   | Initial Version
**/

public without sharing class HrPolicyDocumentsController  {
	@AuraEnabled
	public static void saveAcknowledgement(String name, String url,Datetime updatedOn) {

		Id currentUserId = UserInfo.getUserId();

		Employee__c employee = [SELECT Id,Name
                                FROM Employee__c 
                                WHERE SF_User__c = :currentUserId
                                LIMIT 1];

		//system.debug('employee-->'+employee);
		//system.debug('employee name-->'+employee.name);
		Policy_Acknowledgement__c acknowledgment = new Policy_Acknowledgement__c();
		acknowledgment.Name = name; // Custom field for the file name
		acknowledgment.Policy_URL__c = url; // Custom field for the file URL
		acknowledgment.Employee__c=employee.Id;
		acknowledgment.Date_Time_of_Acknowledgement__c=Datetime.now();
		acknowledgment.Policy_Uploaded_Date__c=updatedOn;
		// Insert the acknowledgment record
		insert acknowledgment;
	}

	@AuraEnabled
	public static Map<String, String> getEmployeeRegionAndProfile() {
		// Create a map to hold the response
		Map<String, String> result = new Map<String, String>();

		// Get the current user ID
		Id currentUserId = UserInfo.getUserId();

		try {
			// Query the employee record
			Employee__c employee = [
				SELECT Id, Country__c
				FROM Employee__c
				WHERE SF_User__c = :currentUserId
				LIMIT 1
			];
			result.put('Country', employee.Country__c);
		} catch (Exception e) {
			result.put('Country', 'No employee record found');
		}

		try {
			// Query the profile name of the current user
			User currentUser = [
				SELECT Profile.Name
				FROM User
				WHERE Id = :currentUserId
				LIMIT 1
			];
			result.put('ProfileName', currentUser.Profile.Name);
		} catch (Exception e) {
			result.put('ProfileName', 'Unable to fetch profile name');
		}

		return result;
	}


	@AuraEnabled
	public static List<Policy_Acknowledgement__c> getAcknowledgedPolicyFromEmployees() {
		Id currentUserId = UserInfo.getUserId();

		// Query the employee record
		Employee__c employee;
		try {
			employee = [SELECT Id, Country__c
						FROM Employee__c 
						WHERE SF_User__c = :currentUserId
						LIMIT 1];
		} catch (Exception e) {
			// Handle case when no employee is found
			throw new AuraHandledException('No employee record found for the current user.');
		}

		// Fetch the acknowledged policies for the employee
		List<Policy_Acknowledgement__c> policyList = new List<Policy_Acknowledgement__c>();
		if (employee != null) {
			policyList = [SELECT Id, Date_Time_of_Acknowledgement__c, Name,Policy_Uploaded_Date__c
						FROM Policy_Acknowledgement__c 
						WHERE Employee__c = :employee.Id];
		}
		return policyList;
	}

    @AuraEnabled
    public static void uploadNewFile(String fileName,String fileData,String folderId,String description) {
		try{
			System.debug('fileNameDebug'+fileName+'folderId'+folderId+'fileData'+fileData);
			GoogleDriveIntegrationNew.uploadPdfFile(fileName,fileData,folderId,description, getAccessToken());
		}
		catch (Exception e) {
            if (e.getMessage().contains('401')) { 
                String newToken=GoogleDriveIntegrationNew.refreshAccessToken();
                GoogleDriveIntegrationNew.uploadPdfFile(fileName,fileData,folderId,description,newToken);
            } else {
                throw new AuraHandledException('err: ' + e.getMessage());
            }
		}
	}

	@AuraEnabled
	public static void logPolicyAction(
		String actionType,  // Action type: "File Upload", "File Delete", "Update File Version"
		String fileName     // Name of the file (if applicable)
	) {
		// Validate inputs
		if (String.isBlank(actionType)) {
			throw new AuraHandledException('Action Type is required.');
		}

		// Query the employee record
		Employee__c employee;
		try {
			employee = [
				SELECT Id, Country__c
				FROM Employee__c
				WHERE SF_User__c = :UserInfo.getUserId()
				LIMIT 1
			];
		} catch (Exception e) {
			// Handle case when no employee is found
			throw new AuraHandledException('No employee record found for the current user.');
		}

		// Determine the version for the file
		String version = 'v1'; // Default to v1 for new file uploads
		if (!String.isBlank(fileName)) {
			List<Policy_Document_Tracking__c> existingRecords = [
				SELECT Version__c 
				FROM Policy_Document_Tracking__c 
				WHERE File_Name__c = :fileName
				ORDER BY CreatedDate DESC
				LIMIT 1
			];

			if (!existingRecords.isEmpty()) {
				String lastVersion = existingRecords[0].Version__c;

				if (actionType.equalsIgnoreCase('File Deleted')) {
					// Use the last version without incrementing for delete
					version = lastVersion;
				} else if (actionType.equalsIgnoreCase('Version Updated') && lastVersion != null && lastVersion.startsWith('v')) {
					// Increment the version for updates
					Integer versionNumber = Integer.valueOf(lastVersion.substring(1)) + 1;
					version = 'v' + versionNumber;
				}
			}
		}

		// Create a new Policy Tracking record
		Policy_Document_Tracking__c policyAction = new Policy_Document_Tracking__c();
		policyAction.Action_Type__c = actionType;       // E.g., File Upload, Delete, Update
		policyAction.Performed_By__c = employee.Id;    // Current user performing the action
		policyAction.File_Name__c = fileName;
		policyAction.Action_Date__c = DateTime.now();  // Record action date and time
		policyAction.Version__c = version;             // Version logic based on action type

		// Insert the record
		try {
			insert policyAction;
		} catch (DmlException e) {
			throw new AuraHandledException('Error inserting Policy Tracking record: ' + e.getMessage());
		}
	}

	private static String getAccessToken() {
        GoogleDriveTokens__c googleTokenSettings = GoogleDriveTokens__c.getInstance('GoogleTokenRecord');
        return googleTokenSettings.AccessToken__c;
    }

}