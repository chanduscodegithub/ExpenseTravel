global class RunUpdateBatchSchedulableClass implements Schedulable{
    global void execute(SchedulableContext ctx) 
    {
        database.executeBatch(new UpdateTABatchClass());
        database.executeBatch(new UpdateProjectBatchClass());
    }   
}