/*------------------------------------------------------------
Author       :  Maaz Rahman
Company      :  CRMIT Pvt. Ltd.
Description  :  A helper class for handling AMS requests.
Inputs       :  Mentioned before each methods. No constructor for the CalloutObjects class.
Test Class   :  _

History
<Date>         <Authors Name>        <Brief Description of Change>
------------------------------------------------------------------*/
/**
 * A helper class for handling AMS requests.
 * @author Maaz
 * @since 2023-06-13
 */
public without sharing class AMSRequestHelper {
    // Constants for action types and modes
    final static String CHECKINACTIONTYPE = 'Check In';
    final static String CHECKOUTACTIONTYPE = 'Check Out';
    final static String PUNCHMODE = 'Biometric';
    final static String ADDONMODE = 'Online';

    public class CustomLogicException extends Exception {}
    /**
     * Gets the user's attendance data for the current date based on the request parameters.
     * @param {RestRequest} req - The request object containing the query parameters.
     * @param {RestResponse} res - The response object to be sent back to the client.
     * @param {CalloutObjects.BuildBodyPrefix} bodyData - The object containing the payload, message and code for the response.
     * @throws CustomLogicException - If any of the query parameters are missing or invalid, or if there is any issue in querying the attendance data.
     * @warning Apex PMD might throw warning for using WITH USER_MODE instead of WITH SECURITY_ENFORCED. WITH USER_MODE is new addition and PMD do not recognize it yet.
     * @author Maaz
     * @since 2023-06-13
     */
    public static void getUserData(RestRequest req, RestResponse res, CalloutObjects.BuildBodyPrefix bodyData){
        try {
            if(!req.params.containsKey('timeZone') && !req.params.containsKey('emailStripped')){
                throw new CustomLogicException('Error: timeZone/emailStripped query parameters are mandatory.');
            }
            if(req.params.get('emailStripped') != UserInfo.getUserEmail().split('@')[0]){
                throw new CustomLogicException('Error: Account details mismatch, please contact admin.');
            }
            Datetime dt = System.now();
            String formattedDt = dt.format('yyyy-MM-dd HH:mm:ss', req.params.get('timeZone'));
            Date dateOnly = Date.valueOf(formattedDt.substring(0, 10));
            //TODO: Employee User is fixed. Please revert it once done.
            List<Employee__c> empList = [SELECT Id, Name, SF_User__c, SF_User__r.Email FROM Employee__c WHERE SF_User__r.Email = :UserInfo.getUserEmail() and Active__c = true WITH SYSTEM_MODE];
            if(empList.size() > 1){
                throw new CustomLogicException('Error: Found multiple employee record, contact Admin Team.');
            }else if(empList.size() <= 0){
                throw new CustomLogicException('Error: No employee record found, contact Admin Team.');
            }
            Attendance__c todayData = [SELECT First_Check_In__c, Duration_In_Hours__c, Duration_In_Mins__c, Date__c, Name, (SELECT Name, Mode__c, Action_Time__c, Action_Type__c FROM Attendance_Activities__r ORDER BY Action_Time__c DESC) FROM Attendance__c WHERE Employee__c = :empList[0].Id AND Date__c =:dateOnly WITH SYSTEM_MODE LIMIT 1];
            sObject generalizedAttendance = (sObject)todayData;
            if(todayData.Attendance_Activities__r[0].Action_Type__c == CHECKINACTIONTYPE){
                bodyData.setLastAction(CHECKINACTIONTYPE);
                DateTime currentTime = System.now();
                Time timeField = (Time)todayData.get('First_Check_In__c');
                DateTime timeInDateTime = DateTime.newInstance(Date.today(), timeField);
                Decimal hoursBetween = (Decimal)(currentTime.getTime() - timeInDateTime.getTime()) / (1000.0 * 60.0 * 60.0);
                hoursBetween = Math.round(hoursBetween * 100.0) / 100.0;
                bodyData.setCurrentTime(hoursBetween);
            }else if(todayData.Attendance_Activities__r[0].Action_Type__c == CHECKOUTACTIONTYPE){
                bodyData.setLastAction(CHECKOUTACTIONTYPE);
            }else{
                bodyData.setLastAction('unknown');
            }
            bodyData.setPayload(generalizedAttendance);
            bodyData.setMessage('success');
            bodyData.setCode(200);
        } catch(QueryException e){
            if(e.getMessage().containsIgnoreCase('List has no rows')){
                bodyData.setMessage('There is no attendance data for today for the employee!');
                bodyData.setCode(200); // Setting status code to 200 instead of 204 to unmute HttpExceptions
            }else{
                Log__c log = new Log__c(Method_Name__c='getUserData', Class_Name__c='AMSRequestHelper', Line_Number__c=e.getLineNumber(), Reason__c=e.getMessage());
                insert as system log;
                bodyData.setMessage(e.getMessage());
                bodyData.setCode(417);
            }
        } catch (Exception e) {
            Log__c log = new Log__c(Method_Name__c='getUserData', Class_Name__c='AMSRequestHelper', Line_Number__c=e.getLineNumber(), Reason__c=e.getMessage());
            insert as system log;
            bodyData.setMessage(e.getMessage());
            bodyData.setCode(417);
        }
    }
    /**
     * Logs the user's check-in or check-out action based on the request and response parameters.
     * @param {RestRequest} req - The request object containing the query parameters and body.
     * @param {RestResponse} res - The response object to be sent back to the client.
     * @param {CalloutObjects.BuildBodyPrefix} bodyData - The object containing the payload, message and code for the response.
     * @throws CustomLogicException - If any of the query parameters or body fields are missing or invalid.
     * @author Maaz
     * @since 2023-06-13
     */
    public static void logUser(RestRequest req, RestResponse res, CalloutObjects.BuildBodyPrefix bodyData){
        try {
            if(!req.params.containsKey('timeZone') || !req.params.containsKey('emailStripped')){
                throw new CustomLogicException('Error: timeZone/emailStripped query parameters are mandatory.');
            }
            if(req.params.get('emailStripped') != UserInfo.getUserEmail().split('@')[0]){
                throw new CustomLogicException('Error: Account details mismatch, please contact admin.');
            }
            Datetime dt = System.now();
            sObject data;
            String formattedDt = dt.format('yyyy-MM-dd HH:mm:ss', req.params.get('timeZone'));
            Date dateOnly = Date.valueOf(formattedDt.substring(0, 10));
            String actionType = (String)bodyData.bodyObj.resourceObj.reqBody.get('action');
            String logMode = (String)bodyData.bodyObj.resourceObj.reqBody.get('mode');
            if(logMode != ADDONMODE && logMode != PUNCHMODE ){
                throw new CustomLogicException('Error: mode (in body) is missing or invalid.');
            }
            List<Employee__c> empList = [SELECT Id, Name, SF_User__c, SF_User__r.Email FROM Employee__c WHERE SF_User__r.Email = :UserInfo.getUserEmail() and Active__c = true WITH SYSTEM_MODE];
            if(empList.size() > 1){
                throw new CustomLogicException('Error: Found multiple employee record, contact Admin Team.');
            }else if(empList.size() <= 0){
                throw new CustomLogicException('Error: No employee record found, contact Admin Team.');
            }
            if(actionType == null){
                throw new CustomLogicException('Error: action (in body) is missing.');
            }else if(actionType != null && actionType == CHECKINACTIONTYPE){
                data = (sObject)checkInUser(dateOnly, logMode, empList[0]);
                bodyData.setLastAction(CHECKINACTIONTYPE);
            }else if(actionType != null && actionType == CHECKOUTACTIONTYPE){
                data = (sObject)checkOutUser(dateOnly, logMode, empList[0]);
                bodyData.setLastAction(CHECKOUTACTIONTYPE);
            }else{
                bodyData.setLastAction('unknown');
                throw new CustomLogicException('Error: action (in body) is invalid.');
            }
            bodyData.setPayload(data);
            bodyData.setMessage('success');
            bodyData.setCode(200);
        } catch (Exception e) {
            Log__c log = new Log__c(Method_Name__c='logUser', Class_Name__c='AMSRequestHelper', Line_Number__c=e.getLineNumber(), Reason__c=e.getMessage());
            insert as system log;
            bodyData.setMessage(e.getMessage());
            bodyData.setCode(417);
        }
    }
    /**
     * Checks in the user for the current date and mode.
     * @param {Date} currDate - The current date of the user's timezone.
     * @param {String} logMode - The mode of logging (Biometric or Online).
     * @return {Attendance_Activity__c} - The new child attendance record created for the user.
     * @throws CustomLogicException - If there is any issue in creating the child attendance record.
     * @warning Apex PMD might throw warning for using WITH USER_MODE instead of WITH SECURITY_ENFORCED. WITH USER_MODE is new addition and PMD do not recognize it yet.
     * @author Maaz
     * @since 2023-06-13
     */
    private static Attendance_Activity__c checkInUser(Date currDate, String logMode, Employee__c empData){
        try {
            Attendance_Activity__c newChildAttendance;
            String currMasterAttendanceId = [SELECT Id, Date__c FROM Attendance__c WHERE Employee__c = :empData.Id AND Date__c =:currDate WITH SYSTEM_MODE]?.Id;
            Time currentTime = Time.newInstance(System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());
            if(currMasterAttendanceId != null){
                newChildAttendance = new Attendance_Activity__c(Attendance__c=currMasterAttendanceId, Action_Time__c=currentTime, Mode__c=logMode, Action_Type__c=CHECKINACTIONTYPE);
            }else{
                Attendance__c newMasterAttendance = new Attendance__c(Employee__c=empData.Id, Date__c=currDate, Employee_User__c=empData.SF_User__c);
                insert as system newMasterAttendance;
                newChildAttendance = new Attendance_Activity__c(Attendance__c=newMasterAttendance.Id, Action_Time__c=currentTime, Mode__c=logMode, Action_Type__c=CHECKINACTIONTYPE);
            }
            insert as system newChildAttendance;
            return newChildAttendance;
        } catch (Exception e) {
            System.debug('Issue in: AMSRequestHelper @ checkInUser method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            throw new CustomLogicException(e.getMessage()+' @'+e.getLineNumber());
        }
    }
    /**
     * Checks out the user for the current date and mode.
     * @param {Date} currDate - The current date of the user's timezone.
     * @param {String} logMode - The mode of logging (Biometric or Online).
     * @return {Attendance_Activity__c} - The updated child attendance record for the user.
     * @throws CustomLogicException - If there is any issue in updating the child attendance record.
     * @warning This method takes both log mode 'Online' and 'Biometric'. This is done to make it easier to test both type data entries.
     * Also the risk is minimal as no one will have access to Google Addon Script to modify the post body.
     * Please change the logic if there's a risk with Client Key and Secret.
     * @warning Apex PMD might throw warning for using WITH USER_MODE instead of WITH SECURITY_ENFORCED. WITH USER_MODE is new addition and PMD do not recognize it yet.
     * @author Maaz
     * @since 2023-06-13
     */
    private static Attendance_Activity__c checkOutUser(Date currDate, String logMode, Employee__c empData){
        try {
            Attendance_Activity__c newChildAttendance;
            String currMasterAttendanceId = [SELECT Id, Date__c FROM Attendance__c WHERE Employee__c = :empData.Id AND Date__c =:currDate WITH SYSTEM_MODE]?.Id;
            Time currentTime = Time.newInstance(System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());
            if(currMasterAttendanceId != null){
                newChildAttendance = new Attendance_Activity__c(Attendance__c=currMasterAttendanceId, Action_Time__c=currentTime, Mode__c=logMode, Action_Type__c=CHECKOUTACTIONTYPE);
            }else{
                throw new CustomLogicException('Error: Cannot check out if you have not checked in for today!');
            }
            insert as system newChildAttendance;
            return newChildAttendance;
        } catch (Exception e) {
            System.debug('Issue in: AMSRequestHelper @ checkOutUser method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            throw new CustomLogicException(e.getMessage()+' @'+e.getLineNumber());
        }
    }
}