public class UpdateEngagementPicklist implements Schedulable {
    public void execute(SchedulableContext context) {
        
        UpdateEngagementPicklistBatch batch = new UpdateEngagementPicklistBatch();
        database.executeBatch(batch,200);
        
    }
}