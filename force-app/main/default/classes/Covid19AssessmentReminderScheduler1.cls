global class Covid19AssessmentReminderScheduler1 implements Schedulable {
   global void execute(SchedulableContext sc) {
      database.executebatch(new Covid19AssessmentReminder1(),60); 
   }
}