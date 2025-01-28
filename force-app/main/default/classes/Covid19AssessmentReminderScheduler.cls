global class Covid19AssessmentReminderScheduler implements Schedulable {
   global void execute(SchedulableContext sc) {
      database.executebatch(new Covid19AssessmentReminder(),300); 
   }
}