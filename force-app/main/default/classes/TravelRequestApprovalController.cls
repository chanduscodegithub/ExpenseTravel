/**
* @File Name : TravelRequestApprovalController.cls
* @Description :
* @Author :
* @Last Modified By :
* @Last Modified On : January 25, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | January 25, 2025 |   | Initial Version
**/

public with sharing class TravelRequestApprovalController {
    
    @AuraEnabled
    public static void submitForApproval(String recordId) {
        try {
            // Get the Travel Request record by ID
            Travel_Request__c travelRequest = [SELECT Id, Name,Country__c FROM Travel_Request__c WHERE Id = :recordId LIMIT 1];
            
            if (travelRequest != null && travelRequest.Country__c == 'India') {
                // Create the ProcessSubmitRequest
                Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
                submitRequest.setObjectId(travelRequest.Id);
                submitRequest.setProcessDefinitionNameOrId('Travel_Request_approval_process_India'); // Use the name or ID of your approval process
                
                // Submit for approval using the Approval.process() method
                Approval.ProcessResult result = Approval.process(submitRequest);
                
                // Check if the submission was successful
                if (result.isSuccess()) {
                    System.debug('Travel request submitted for approval successfully.');
                } else {
                    System.debug('Error in submission: ' + result.getErrors());
                }
            }
        } catch (Exception e) {
            System.debug('Error submitting for approval: ' + e.getMessage());
            throw new AuraHandledException('Error submitting travel request for approval.');
        }
    }
}