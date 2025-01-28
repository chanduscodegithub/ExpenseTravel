global class Covid19AssessmentReminderSchecduleCRMIT implements Schedulable{ 
	global void execute(SchedulableContext sc) {
      database.executebatch(new Covid19AssessmentReminderCRMIT(),300); 
   }
}