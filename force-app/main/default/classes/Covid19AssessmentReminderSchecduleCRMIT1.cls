global class Covid19AssessmentReminderSchecduleCRMIT1 implements Schedulable{
	global void execute(SchedulableContext sc) {
      database.executebatch(new Covid19AssessmentReminderCRMITRem(),300); 
    }

}