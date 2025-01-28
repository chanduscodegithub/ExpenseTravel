global class Covid19AssessmentReminderSE1Scheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      database.executebatch(new Covid19AssessmentReminderSingleEmail1(),300);  
   }
}