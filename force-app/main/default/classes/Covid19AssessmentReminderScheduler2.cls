global class Covid19AssessmentReminderScheduler2 implements Schedulable {
   global void execute(SchedulableContext sc) {
      database.executebatch(new Covid19AssessmentReminder2(),60); 
   }
}