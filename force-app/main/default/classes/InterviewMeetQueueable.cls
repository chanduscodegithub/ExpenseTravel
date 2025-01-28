public class InterviewMeetQueueable implements Queueable, Database.AllowsCallouts {
    private Id interviewRecordId;

    public InterviewMeetQueueable(Id interviewRecordId) {
        this.interviewRecordId = interviewRecordId;
    }

    public void execute(QueueableContext context) {
        List<String> emails=new List<String>();
        Review__c interview = [
            SELECT Id,Job_Application__r.Candidate__r.Email__c,Job_Application__r.Candidate__r.First_Name__c,Job_Application__r.Candidate__r.Last_Name__c,Date_Time__c
            FROM Review__c
            WHERE Id = :interviewRecordId
            LIMIT 1
        ];
        
        emails.add(interview.Job_Application__r.Candidate__r.Email__c);
        
        try {
            GoogleMeetService.createOrUpdateCalendarEvent(
                interview.Id, 
                emails, 
                interview.Job_Application__r.Candidate__r.First_Name__c+' '+interview.Job_Application__r.Candidate__r.Last_Name__c, 
                interview.Date_Time__c
            );
        } catch (Exception e) {
            System.debug('Failed to create or update Google Calendar event: ' + e.getMessage());
        }
    }
}