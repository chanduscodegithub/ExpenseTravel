public class ScheduleInterview {
 @AuraEnabled
    public static Boolean scheduleMeetInvite(Id interviewId) {
        System.debug('Schedule Interview Called');
        System.enqueueJob(new InterviewMeetQueueable(interviewId));
        return true;
    }
}