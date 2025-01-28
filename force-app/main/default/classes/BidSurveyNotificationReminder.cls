/*************************************************************************************************************
 * @name			BidSurveyNotificationReminder
 * @author			Rohit Pal <rohit.pal@crmit.com>
 * @created			04 / 07 / 2020
 * @description		Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 * 				No.		Date			Author					Description
 * 				----	------------	--------------------	----------------------------------------------
 * @version		1.0		2020-07-04		Rohit Pal			This class is used to send an email to all those people 
 *                                                          who are part of the Bid Survey Approval Process If 
 *                                                          they do not upate the survey status an email will trigger to remind them. 
 *
**************************************************************************************************************/         
public class BidSurveyNotificationReminder {

    public static set<string> setUserFullName = new set<string>();
    /**
    * @description 
    * @author Rohit Pal | 4/7/2020 
    * @return void 
    **/
    public static void sendApprovalReminderEmail(){
        //
        List<RFPProcess__c> listRFPProcess = [SELECT Id,
                                                     Name,
                                                     RFPStatus__c
                                              FROM RFPProcess__c
                                              WHERE RFPStatus__c ='Pending Approval'];
        if(!listRFPProcess.isEmpty()){
            //
            for(ProcessInstance IteratorProcessInstance : [SELECT Id, 
                                                                  Status,
                                                                  TargetObjectId, 
                                                                  (SELECT Id, 
                                                                          StepStatus, 
                                                                          Actor.Name
                                                                    FROM StepsAndWorkitems 
                                                                    WHERE StepStatus = 'Pending') 
                                                            FROM ProcessInstance 
                                                            WHERE TargetObjectId IN : listRFPProcess 
                                                                  AND 
                                                                  Status = 'Pending']){
                //
                for(ProcessInstanceHistory iteratorProcessInstanceHistory : IteratorProcessInstance.StepsAndWorkitems){
                    setUserFullName.add(iteratorProcessInstanceHistory.Actor.Name);
                }
            }
        }
        if(!setUserFullName.isEmpty()){
            //
            List<messaging.SingleEmailMessage> lstmessaging = new List<messaging.SingleEmailMessage>();
            //
            for(user iteratorUser : [SELECT Id,
                                            FirstName,
                                            Email 
                                    FROM 
                                    user WHERE Name IN : setUserFullName]){
                //
                messaging.SingleEmailMessage emails=new messaging.SingleEmailMessage();
                emails.setToAddresses(new string[]{iteratorUser.Email});
                emails.setSubject('Bid Approval Reminder');
                String body = 'Hi ' + iteratorUser.FirstName + ', <br/><br/>';
                body += 'Hope you’re great. Just sending you a gentle reminder on RFP Bid Approval.<br/><br/>';
                body += 'I would appreciate it if you could take a moment and look over the Approval when you get a chance.<br/><br/>';
                body += 'Thanks in advance for your cooperation.<br/><br/><br/>';
                body += 'Kind regards,<br/>';
                body += 'RFP Team';
                emails.setHtmlBody(body);                
                emails.setSenderDisplayName('CRMIT RFP Team');
                //
                lstmessaging.add(emails);
            }
            try {
                Messaging.sendEmail(lstmessaging);
            } catch (Exception e) {
                System.debug('Exception Message Is ' + e.getMessage() + 'Cause - ' +e.getCause()+'Line'+ e.getLineNumber());
            }
        }
        //
        List<RFPProcess__c> listUpdateRFPProcess = new List<RFPProcess__c>();
        //
        for(RFPProcess__c iteratorRFPProcess : [SELECT Id,
                                                       Name,
                                                       RFPStatus__c
                                                FROM RFPProcess__c
                                                WHERE RFPStatus__c = 'Bid' 
                                                      and
                                                      RFPSubmissionDate__c =: system.today()]){
            //
            iteratorRFPProcess.RFPStatus__c = 'Bid Submitted';
            listUpdateRFPProcess.add(iteratorRFPProcess);
        }
        if(!listUpdateRFPProcess.isEmpty()){
            try {
                update listUpdateRFPProcess;
            } catch (Exception e) {
                System.debug('Exception Message Is ' + e.getMessage() + 'Cause - ' +e.getCause()+'Line'+ e.getLineNumber());
            }
        }
    }
}