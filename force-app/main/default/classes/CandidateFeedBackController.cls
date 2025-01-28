public class CandidateFeedBackController {
    @AuraEnabled(Cacheable=true)
    public static List<InterviewLightningController.InterviewWrapper> getInterviewDetails(string recordId){
        List<InterviewLightningController.InterviewWrapper> interviewsList = new List<InterviewLightningController.InterviewWrapper>();
        try{
            List<Job_Application__c>jobApplications =  [Select Id,Candidate__c from Job_Application__c where Candidate__c =: recordId];
            Set<Id>jobApplicationIds = new Set<Id>();
            if(jobApplications.size() > 0){
                for(Job_Application__c JA : jobApplications){
                    jobApplicationIds.add(JA.Id);
                }
                List<Review__c> reviews = [Select Id,Name,Job_Application__r.Candidate_Name__c, 
                                           Job_Application__r.Position__r.Position_Title__c, 
                                           Position__c, Status__c, Interviewer__r.Name,Fitment_Rating__c,Assessment__c 
                                           from Review__c where Job_Application__c IN :jobApplicationIds];
                if(reviews.size() > 0){
                    for (Review__c review : reviews) {
                        InterviewLightningController.InterviewWrapper wrapper = new InterviewLightningController.InterviewWrapper();
                        wrapper.Id = review.Id;
                        wrapper.Interview = review.Name;
                        wrapper.CandidateName = review.Job_Application__r.Candidate_Name__c;
                        wrapper.PositionName = review.Job_Application__r.Position__r.Position_Title__c;
                        wrapper.PositionNumber = review.Position__c;
                        wrapper.Status = review.Status__c;
                        wrapper.InterviewerName = review.Interviewer__r.Name;
                        wrapper.Rating = review.Fitment_Rating__c;
                        wrapper.Assessment = review.Assessment__c;
                        interviewsList.add(wrapper);
                    }
                }
            }
            return interviewsList;// 
        }catch(Exception ex){
            return interviewsList;
        }
    }
    @AuraEnabled(Cacheable=true)
    public static List<CandidateFeedBackWrapper> getCandidatefeedBackDetails(string recordId){
        List<CandidateFeedBackWrapper> candiFeedBackWrapperList = new List<CandidateFeedBackWrapper>();
        try{
            List<Candidate_FeedBack__c>candiFeedBackList =  [Select Id,Name,Status__c,Candidate__c,Interviewer__r.Name,Assessment__c from Candidate_FeedBack__c where Candidate__c =: recordId];
            
                if(candiFeedBackList.size() > 0){
                    for (Candidate_FeedBack__c canFB : candiFeedBackList) {
                        CandidateFeedBackWrapper wrapper = new CandidateFeedBackWrapper();
                        wrapper.Id = canFB.Id;
                        wrapper.Interview = canFB.Name;
                        wrapper.Status = canFB.Status__c;
                        wrapper.InterviewerName = canFB.Interviewer__r.Name;
                        wrapper.Assessment = canFB.Assessment__c;
                        candiFeedBackWrapperList.add(wrapper);
                    }
                }
            return candiFeedBackWrapperList;
        }catch(Exception ex){
            return candiFeedBackWrapperList;
        }
    }
    @AuraEnabled(Cacheable=true)
    public static List<CandidateFeedBackWrapper> getLoggedInUserCreatedfeedBack(string recordId){
        List<CandidateFeedBackWrapper> candiFeedBackWrapperList = new List<CandidateFeedBackWrapper>();
        try{
            User us = [Select Id from User where Id =: UserInfo.getUserId()];
            List<Candidate_FeedBack__c>candiFeedBackList =  [Select Id,Name,Status__c,Candidate__c,Interviewer__r.Name,Assessment__c,Fitment_Rating__c from Candidate_FeedBack__c where Candidate__c =: recordId and Interviewer__c =: us.Id];
            
                if(candiFeedBackList.size() > 0){
                    for (Candidate_FeedBack__c canFB : candiFeedBackList) {
                        CandidateFeedBackWrapper wrapper = new CandidateFeedBackWrapper();
                        wrapper.Id = canFB.Id;
                        wrapper.Interview = canFB.Name;
                        wrapper.Status = canFB.Status__c;
                        wrapper.InterviewerName = canFB.Interviewer__r.Name;
                        wrapper.Assessment = canFB.Assessment__c;
                        candiFeedBackWrapperList.add(wrapper);
                    }
                }
            return candiFeedBackWrapperList;
        }catch(Exception ex){
            return candiFeedBackWrapperList;
        }
    }
    
    @AuraEnabled
    public static string createCandidatefeedBack(CandidateFeedBackWrapper candWrapper){
        try{
            User us = [Select Id from User where Id =: UserInfo.getUserId()];
            Candidate_FeedBack__c candFb = new Candidate_FeedBack__c();
            candFb.Candidate__c = candWrapper.Candidate;
            candFb.Interviewer__c = us.Id;
            candFb.Fitment_Rating__c = candWrapper.Rating;
            candFb.Status__c = candWrapper.Status;
            candFb.Assessment__c = candWrapper.Assessment;
            insert candFb;
           return 'success';
        }catch(Exception ex){
            return ex.getMessage();
        }
    }
    public class CandidateFeedBackWrapper{
        @AuraEnabled
        public string Id {get;set;}
        @AuraEnabled
        public string Interview {get;set;}
        @AuraEnabled
        public string Candidate {get;set;}
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
    }
    
}