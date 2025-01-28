@RestResource(urlMapping='/CreateApplicant')
global without sharing class ApplicantsController {

    @HttpPost
    global static String createApplicant() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        try {
            // Parse the JSON payload
            String requestBody = req.requestBody.toString();
            Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(requestBody);

            // Extract fields from the payload
            String name = (String) payload.get('name');
            String email = (String) payload.get('email');
            String phone = (String) payload.get('phone');

            // Create a record in Salesforce
            Applicants__c applicant = new Applicants__c();
            applicant.Name = name;
            applicant.Email__c = email;
            applicant.Phone__c = phone;

            insert applicant;

            // Return success response
            res.statusCode = 201;
            return JSON.serialize(new Map<String, String>{
                'status' => 'success',
                'message' => 'Applicant created successfully'
            });
        } catch (Exception e) {
            res.statusCode = 500;
            return JSON.serialize(new Map<String, String>{
                'status' => 'error',
                'message' => e.getMessage()
            });
        }
    }
}