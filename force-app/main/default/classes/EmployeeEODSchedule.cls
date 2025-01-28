public class EmployeeEODSchedule implements Schedulable{
    public void execute(SchedulableContext sc){
        Database.executeBatch(new EmployeeEODStatusBatch1(), 500); 
    }
}