trigger InterviewTrigger on Review__c (after insert, before update, before insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        System.debug('********** After Insert - START **********');
        List<Review__c> interviewList = [Select Id,Job_Application__c from Review__c Where ID IN :Trigger.New];
        
        Set<Id> interviewIds = new Set<Id>();
        
        for(Review__c eachInterview : interviewList){
            if(interviewIds.contains(eachInterview.Id)==false){
                interviewIds.add(eachInterview.Id);
            }
            //eachInterview.Candidate_Lookup__c = eachInterview.Job_Application__r.Candidate__c;
        }
        
        List<Review__c> updateInterviewList = [Select Id, Job_Application__c, Job_Application__r.Candidate__c from Review__c Where Id IN :interviewIds];
        System.debug('updateInterviewList - '+updateInterviewList);
        System.debug('Candidate: '+ updateInterviewList[0].Job_Application__r.Candidate__c);
        
        for(Review__c eachInterview : updateInterviewList){
            eachInterview.Candidate_Lookup__c = eachInterview.Job_Application__r.Candidate__c;
        }
        
        if(updateInterviewList.size()>0){
            try{
                update updateInterviewList;
            }
            catch(Exception e) {
                System.debug('Exception is : ' + e.getMessage());
            }
            System.debug('********** After Insert - END **********');
        }
    }
    /*if(Trigger.isBefore && Trigger.isUpdate){
List<Review__c> listReview= [Select Id,Interviewer__c,Interviewer__r.Name from Review__c where Id IN :Trigger.New];

for(Review__c eachReview : listReview){
if(Trigger.OldMap.get(eachReview.Id).Interviewer__c != eachReview.Interviewer__c){
eachReview.Old_Interviewer__c = Trigger.OldMap.get(eachReview.Id).Interviewer__c;
}
}
}*/
    
    If(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        System.debug('********** Before Insert - START **********');
        List<Review__c> existingListInterview = [Select Id, Date_Time__c,Interviewer__c, Candidate__c from Review__c where Date_Time__c>=TODAY AND Id NOT IN :Trigger.New];
        System.debug('existingListInterview - '+existingListInterview);
        if(Trigger.isInsert){
            for(Review__c eachReview : Trigger.New){
                eachReview.Old_Interviewer__c = eachReview.Interviewer__c;
                eachReview.Old_Date_Time__c = eachReview.Date_Time__c;
                //eachReview.Recruiter_User__c = eachReview.CreatedById;
            }
        }
        
        for(Review__c eachReview : Trigger.New){
            System.debug('eachReview - '+eachReview);
            for(Review__c eachExisitngReview : existingListInterview){
                System.debug('existingListInterview - '+existingListInterview);
                if(eachReview.Date_Time__c == eachExisitngReview.Date_Time__c && eachReview.Interviewer__c == eachExisitngReview.Interviewer__c){
                    System.debug('********** Before Insert - END **********');
                    eachReview.addError('The Interviewer has been already allocated with another Interview on '+eachReview.Date_Time__c.format('MMM dd YYYY, hh:mm a'));
                }
                else if(eachReview.Date_Time__c == eachExisitngReview.Date_Time__c && eachReview.Candidate__c == eachExisitngReview.Candidate__c){
                    System.debug('********** Before Insert - END **********');
                    eachReview.addError('The Candidate has been already allocated with another Interview on '+eachReview.Date_Time__c.format('MMM dd YYYY, hh:mm a'));
                }
            }
        }
        System.debug('********** Before Insert - END **********');
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        System.debug('********** Before Update - START **********');
        List<Review__c> interviewList = Trigger.New;
        
        Id currentUser = UserInfo.getUserId(); 
        
        System.debug('currentUser - '+currentUser);
        
        List<GroupMember> groupMemeberList = [SELECT UserOrGroupId, GroupId, Id FROM GroupMember where Group.DeveloperName='Recruiting_Team'];
        System.debug('groupMemeberList - '+groupMemeberList);
        
        Set<Id> groupMembersIds = new Set<Id>();
        for(GroupMember eachGM : groupMemeberList){
            if(groupMembersIds.contains(eachGM.UserOrGroupId)==false){
                groupMembersIds.add(eachGM.UserOrGroupId);
            }
        }
        System.debug('groupMembersIds - '+groupMembersIds);
        
        for(Review__c eachInterview : interviewList){
            if(eachInterview.Interviewer__c != currentUser && !groupMembersIds.contains(currentUser)){
                System.debug('********** Before Update - END **********');
                eachInterview.addError('You don\'t have enough access to edit the record.');
            }
        }
        System.debug('********** Before Update - END **********');
    }}