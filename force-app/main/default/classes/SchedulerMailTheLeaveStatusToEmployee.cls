global class SchedulerMailTheLeaveStatusToEmployee implements Schedulable{
    global void execute(SchedulableContext SC) {
        mailTheLeaveStatusToEmp batch = new mailTheLeaveStatusToEmp();
        Database.executeBatch(batch,50);
    }
}