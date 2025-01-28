global class InactiveProjectschedulable implements Schedulable {
   global void execute(SchedulableContext sc) {
      InactiveProjectUpdate b = new InactiveProjectUpdate(); 
      Database.executeBatch(b);
   }
}