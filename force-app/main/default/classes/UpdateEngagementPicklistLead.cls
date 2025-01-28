public class UpdateEngagementPicklistLead implements Schedulable{
    public void execute(SchedulableContext context) {
        
        UpdateEngagementPicklistBatchLead batch = new UpdateEngagementPicklistBatchLead();
        database.executeBatch(batch,200);
        
    }
}