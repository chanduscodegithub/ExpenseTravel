public with sharing class CandidateLoginController {
    @AuraEnabled
    public static void requestOtp(String email) {
        // Implement OTP generation logic here
    }

    @AuraEnabled
    public static Boolean verifyOtp(String email, String otp) {
        // Implement OTP verification logic here
        return true;
    }

    @AuraEnabled
    public static void uploadOfferLetter(String email, String fullName, String fileName, String base64Data) {
        // Decode and save the file, then associate it with the record
    }
}