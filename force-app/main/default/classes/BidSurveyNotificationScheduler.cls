/*************************************************************************************************************
 * @name			BidSurveyNotificationScheduler
 * @author			Rohit Pal <rohit.pal@crmit.com>
 * @created			04 / 07 / 2020
 * @description		Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2020-07-04		Rohit Pal			Changes desription
 *
**************************************************************************************************************/
global  class BidSurveyNotificationScheduler implements Schedulable {

    global void execute(SchedulableContext ctx) {
        // awesome code here
        BidSurveyNotificationReminder.sendApprovalReminderEmail();
    }
    
}