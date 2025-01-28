public class InterviewLightningController {
    @AuraEnabled(Cacheable = true)
    public static List<InterviewWrapper> getInterviews(String jobApplicationId){
        List<InterviewWrapper> interviewsList = new List<InterviewWrapper>();
        try{
            List<Review__c> reviews = [Select Id,Name,Job_Application__r.Candidate_Name__c, 
                                              Job_Application__r.Position__r.Position_Title__c, Overall_Rating__c,Comment__c,
                                              Position__c, Status__c, Interviewer__r.Name,Fitment_Rating__c,Assessment__c 
                                              from Review__c where Job_Application__c = :jobApplicationId];
            if(!reviews.isEmpty()){
                for (Review__c review : reviews) {
                    InterviewWrapper wrapper = new InterviewWrapper();
                    wrapper.Id = review.Id;
                    wrapper.Interview = review.Name;
                    wrapper.CandidateName = review.Job_Application__r.Candidate_Name__c;
                    wrapper.PositionName = review.Job_Application__r.Position__r.Position_Title__c;
                    wrapper.PositionNumber = review.Position__c;
                    wrapper.Status = review.Status__c;
                    wrapper.InterviewerName = review.Interviewer__r.Name;
                    wrapper.Rating = (review.Fitment_Rating__c != null) ? review.Fitment_Rating__c : review.Overall_Rating__c ;
                    wrapper.Assessment = (review.Assessment__c != null) ? review.Assessment__c : review.Comment__c;
                    interviewsList.add(wrapper);
                }
            }
            return interviewsList;
        } catch(Exception e){
            // Optionally, handle the exception or log it
            InterviewWrapper wrapper = new InterviewWrapper();
            wrapper.ErrorLineNumber = e.getLineNumber();
            wrapper.ErrorMessage = e.getMessage();
            interviewsList.add(wrapper);
            return interviewsList;
        }
    }
    public class InterviewWrapper{
        @AuraEnabled
        public string Id {get;set;}
        @AuraEnabled
        public string Interview {get;set;}
        @AuraEnabled
        public string CandidateName {get;set;}
        @AuraEnabled
        public string PositionName {get;set;}
        @AuraEnabled
        public string PositionNumber {get;set;}
        @AuraEnabled
        public string Status {get;set;}
        @AuraEnabled
        public string InterviewerName {get;set;}
        @AuraEnabled
        public decimal Rating {get;set;}
        @AuraEnabled
        public string Assessment {get;set;}
        @AuraEnabled
        public integer ErrorLineNumber {get;set;}
        @AuraEnabled
        public string ErrorMessage {get;set;}
    }
}