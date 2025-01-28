/*
Type             : Apex class
Name             : EvaluationFormController
Test Class       : 
Created On       : 14-02-2024
Usage            : This Class is used to retrieve and insert Interview record.
*/
public without sharing class EvaluationFormController 
{
    @AuraEnabled(cacheable=true)
    public static Evaluation_Form__mdt getEvaluationData()
    {
        return [Select id,DeveloperName,Instruction__c,X5_Star__c,X4_Star__c,X3_Star__c,X2_Star__c,X1_Star__c from Evaluation_Form__mdt];
    }

    @AuraEnabled
    public static relatedInterviewDetails getInterviewData(Id interviewRecordId){
        relatedInterviewDetails interviewWrapper = new relatedInterviewDetails();

        /*Review__c interview = [Select id,Name,Interviewer__r.Name,Job_Application__c,Job_Application__r.Candidate__r.First_Name__c,Job_Application__r.Candidate__r.Last_Name__c,Role__c,Job_Application__r.Position__r.Position_Title__c,Date_Time__c,Mode_Of_Interview__c,People_Capability__c,Process_Maturity__c,Project_Knowledge__c,Attitude__c,Comment__c,Hire__c,Reject__c,Is_Evaluation_Form_Submitted__c from Review__c Where Id =: interviewRecordId];
        
        interviewWrapper.name = interview.Name;
        interviewWrapper.candidateName = interview.Job_Application__r.Candidate__r.First_Name__c + ' '+ interview.Job_Application__r.Candidate__r.Last_Name__c;
        interviewWrapper.interviewerName = interview.Interviewer__r.Name;
        interviewWrapper.role = interview.Role__c;
        interviewWrapper.requistionName = interview.Job_Application__r.Position__r.Position_Title__c;
        interviewWrapper.dateOfInterview = interview.Date_Time__c;
        interviewWrapper.modeOfInterview = interview.Mode_Of_Interview__c;
        interviewWrapper.peopleCapability = interview.People_Capability__c;
        interviewWrapper.processMaturity = interview.Process_Maturity__c;
        interviewWrapper.projectKnowledge = interview.Project_Knowledge__c; 
        interviewWrapper.Attitude = interview.Attitude__c;
        interviewWrapper.Comments = interview.Comment__c;
        interviewWrapper.hireSelected = interview.Hire__c;
        interviewWrapper.isRejected = interview.Reject__c;
        // interviewWrapper.recommendInterview = interview.Recommending_for_other_positions__c;
        // interviewWrapper.recommendPosition = interview.Other_Position_In_CRMIT__c;

        List<interviewQuestions> questionWrapperList = new List<interviewQuestions>();
        if(interview.Is_Evaluation_Form_Submitted__c == false){
            for(Interview_Skill_Set__c skillSet : [Select id,Name,Question__c, Roles__c, Active__c,Sequence__c from Interview_Skill_Set__c Where Roles__c =: interview.Role__c and Active__c =True Order by Sequence__c asc])
            {
                interviewQuestions questionWrapper = new interviewQuestions();
                questionWrapper.Id = skillSet.id;
                questionWrapper.question = skillSet.Question__c; 
                questionWrapper.rating = '0';
                questionWrapperList.add(questionWrapper);
            }
        }

        List<Interview_Skill_Rating__c> skillRating = [Select id,Interview__c,Interview_Skill_Set__c,Interview_Skill_Set__r.Question__c,Rating__c,Justification__c,Sequence__c from Interview_Skill_Rating__c Where Interview__c =: interviewRecordId Order by Sequence__c asc];
        if(skillRating.size()>0 && interview.Is_Evaluation_Form_Submitted__c)
        {
            interviewWrapper.isFeedbackSubmitted = true;

            for(Interview_Skill_Rating__c eachSkillRating : skillRating)
            {
                interviewQuestions questionWrapper = new interviewQuestions();
                questionWrapper.Id = eachSkillRating.Interview_Skill_Set__c;
                questionWrapper.question = eachSkillRating.Interview_Skill_Set__r.Question__c; 
                questionWrapper.rating = string.valueOf(eachSkillRating.Rating__c);
                questionWrapper.justification = eachSkillRating.Justification__c;
                questionWrapperList.add(questionWrapper);
            }
        }else{
            interviewWrapper.isFeedbackSubmitted = false;
        }

        interviewWrapper.interviewWrap = questionWrapperList;*/

        return interviewWrapper;
    }

    @AuraEnabled 
    public static string saveInformation(interviewWrapper interviewWrap,List<ratingWrapper> ratingSkills,Id interviewId){
        
        String Status;
        try{
            system.debug('interviewWrap:::'+interviewWrap);

            Review__c interviewRole = [Select id,Name,Role__c from Review__c Where Id =: interviewId];
            AggregateResult skillSet = [Select COUNT(Id)total from Interview_Skill_Set__c Where Roles__c =: interviewRole.Role__c and Active__c =True];

            Review__c interview = new Review__c();
            interview.Id = interviewId;
            interview.Mode_Of_Interview__c = interviewWrap.modeOfInterview;
            interview.People_Capability__c = interviewWrap.peopleCapability;
            interview.Process_Maturity__c = interviewWrap.processMaturity;
            interview.Project_Knowledge__c = interviewWrap.projectKnowledge;
            interview.Attitude__c = interviewWrap.Attitude;
            interview.Comment__c = interviewWrap.Comments;
            interview.Hire__c = Boolean.valueOf(interviewWrap.hireSelected);
            interview.Reject__c = Boolean.valueOf(interviewWrap.isRejected);
            // interview.Recommending_for_other_positions__c = Boolean.valueOf(interviewWrap.recommendInterview);
            // interview.Other_Position_In_CRMIT__c = interviewWrap.recommendPosition;
            interview.Is_Evaluation_Form_Submitted__c = true;
            interview.Total_Questions__c = (Decimal)skillSet.get('total');
            update interview;
             Integer counter=0;
            List<Interview_Skill_Rating__c> skilSetList = new List<Interview_Skill_Rating__c>();
            for(ratingWrapper eachRating : ratingSkills){
                Interview_Skill_Rating__c skillRating = new Interview_Skill_Rating__c();
                skillRating.Interview__c = interviewId;
                skillRating.Interview_Skill_Set__c = eachRating.skillSetId;
                skillRating.Rating__c = Decimal.valueOf(eachRating.rating);
                if(skillRating.Rating__c >0)
                {
                    counter=counter+1;
                    skillRating.Interview__r.Total_answer_questions__c=counter;
                }
                skillRating.Question__c = eachRating.questionName;
                skillRating.Justification__c = eachRating.justification;
                skilSetList.add(skillRating);
            }

            if(skilSetList.size()>0)
            {
                insert skilSetList;
            }

            Status='Success';
            return Status; 

        }catch(Exception ex){
            System.debug('ex:::'+ex.getMessage() +'Linenumber: '+ex.getLineNumber());
            Status = String.valueOf(ex);
            return Status;
        }
    }

    public class relatedInterviewDetails
    {
        @AuraEnabled 
        public String name { get; set; }
        @AuraEnabled 
        public String candidateName { get; set; }
        @AuraEnabled 
        public String role { get; set; }
        @AuraEnabled 
        public String requistionName { get; set; }
        @AuraEnabled 
        public String interviewerName { get; set; }
        @AuraEnabled 
        public DateTime dateOfInterview { get; set; }
        @AuraEnabled 
        public Boolean isFeedbackSubmitted { get; set;}
        @AuraEnabled 
        public String modeOfInterview { get; set; }
        @AuraEnabled 
        public String peopleCapability { get; set; }
        @AuraEnabled 
        public String processMaturity { get; set; }
        @AuraEnabled 
        public String projectKnowledge { get; set; }
        @AuraEnabled 
        public String Attitude { get; set; }
        @AuraEnabled 
        public String Comments { get; set; }
        @AuraEnabled 
        public Boolean hireSelected { get; set; }
        @AuraEnabled 
        public Boolean recommendInterview { get; set; }
        @AuraEnabled 
        public Boolean isRejected { get; set; }
        @AuraEnabled 
        public String recommendPosition { get; set; }
        @AuraEnabled
        public List<interviewQuestions> interviewWrap { get; set; }
    }

    public class interviewQuestions{
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String question { get; set; }
        @AuraEnabled 
        public String rating { get; set; }
        @AuraEnabled
        public String justification { get; set; }
    }

    public class interviewWrapper{
        @AuraEnabled 
        public String modeOfInterview { get; set; }
        @AuraEnabled 
        public String peopleCapability { get; set; }
        @AuraEnabled 
        public String processMaturity { get; set; }
        @AuraEnabled 
        public String projectKnowledge { get; set; }
        @AuraEnabled 
        public String Attitude { get; set; }
        @AuraEnabled 
        public String Comments { get; set; }
        @AuraEnabled 
        public String hireSelected { get; set; }
        @AuraEnabled 
        public String recommendInterview { get; set; }
        @AuraEnabled 
        public String isRejected { get; set; }
        @AuraEnabled 
        public String recommendPosition { get; set; }
    }

    public class ratingWrapper{
        @AuraEnabled 
        public String innerIndex { get; set; }
        @AuraEnabled 
        public String skillSetId { get; set; }
        @AuraEnabled 
        public String rating { get; set; }
        @AuraEnabled 
        public String questionName { get; set; }
        @AuraEnabled 
        public String justification { get; set; }
    }
}