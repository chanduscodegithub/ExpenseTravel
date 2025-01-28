/*------------------------------------------------------------
Author       :  Maaz Rahman
Company      :  CRMIT Pvt. Ltd.
Description  :  _
Inputs       :  Mentioned before each methods. No constructor for the CalloutObjects class.
Test Class   :  _

History
<Date>         <Authors Name>        <Brief Description of Change>
------------------------------------------------------------------*/
@RestResource(urlMapping='/api/biometric/*')
global class BiometricHandler {
    public class CustomLogicException extends Exception {}
    final static String CHECKINACTIONTYPE = 'Check In';
    final static String CHECKOUTACTIONTYPE = 'Check Out';
    final static String PUNCHMODE = 'Biometric';
    final static String ADDONMODE = 'Online';
    @HttpPost
    global static void doGet() {
        RestRequest req = RestContext.request;
        if(req.requestBody.size() > 0){
            Blob bodyBlob = req.requestBody;
            getActionAndEmpCodeFromStr(bodyBlob);
        }
    }
    @future
    private static void getActionAndEmpCodeFromStr(Blob reqInBlob) {
        String action = '';
        String empCode = '';
        System.debug(reqInBlob.toString());
        JSONParser parser = JSON.createParser(reqInBlob.toString());
        while(parser.nextToken() != null){
            if(parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                switch on parser.getText().toLowerCase() {
                    when 'action'{
                        parser.nextToken();
                        action = parser.getText();
                    }
                    when 'empcode'{
                        parser.nextToken();
                        empCode = parser.getText();
                    }
                }
            }
        }
       	logBiometric(empCode, action);
	}
    
    public static void logBiometric(String empCode, String action){
        // System.debug('Emp: '+empCode);
        // System.debug('Action: '+action);
        if(action.containsIgnoreCase('in')){
            logIn(empCode);
        }else if(action.containsIgnoreCase('out')){
            logOut(empCode);
        }
        
    }
    public static void logIn(String empCode){
        try{
            Datetime dt = System.now();
            String formattedDt = dt.format('yyyy-MM-dd HH:mm:ss', 'Asia/Kolkata');
            Date currDate = Date.valueOf(formattedDt.substring(0, 10));
            List<Employee__c> empList = [SELECT Id, Name, SF_User__c, SF_User__r.Email,ReportingTo__r.SF_User__c FROM Employee__c WHERE EmployeeID__c = :empCode];
            Employee__c empData;
            if(empList.size() == 1){
                empData = empList[0];
            }else{
                throw new CustomLogicException('No or multiple employees with same Employee Code.');
            }
            Attendance_Activity__c newChildAttendance;
            String currMasterAttendanceId = [SELECT Id, Date__c FROM Attendance__c WHERE Employee__c = :empData.Id AND Date__c =:currDate WITH SYSTEM_MODE]?.Id;
            Time currentTime = Time.newInstance(System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());
            Datetime currentDatetime = DateTime.newInstance(System.today(),currentTime);
            if(currMasterAttendanceId != null){
                newChildAttendance = new Attendance_Activity__c(Attendance__c=currMasterAttendanceId, Action_Time__c=currentTime,Action_Date_and_Time__c = currentDatetime, Mode__c=PUNCHMODE, Action_Type__c=CHECKINACTIONTYPE);
            }else{
                Attendance__c newMasterAttendance = new Attendance__c(Employee__c=empData.Id, Date__c=currDate, Employee_User__c=empData.SF_User__c);
                insert as system newMasterAttendance;
                attendenceTimerCmpCtrl.manualSharing(newMasterAttendance, empData,TRUE);
                newChildAttendance = new Attendance_Activity__c(Attendance__c=newMasterAttendance.Id, Action_Time__c=currentTime,Action_Date_and_Time__c = currentDatetime, Mode__c=PUNCHMODE, Action_Type__c=CHECKINACTIONTYPE);
            }
            insert as system newChildAttendance;
        }catch(Exception e){
            Log__c log = new Log__c(Method_Name__c='logIn', Class_Name__c='BiometricHandler', Line_Number__c=e.getLineNumber(), Reason__c=e.getMessage());
            insert as system log;
        }
    }
    public static void logOut(String empCode){
        try{
            Datetime dt = System.now();
            String formattedDt = dt.format('yyyy-MM-dd HH:mm:ss', 'Asia/Kolkata');
            Date currDate = Date.valueOf(formattedDt.substring(0, 10));
            List<Employee__c> empList = [SELECT Id, Name, SF_User__c, SF_User__r.Email,ReportingTo__r.SF_User__c FROM Employee__c WHERE EmployeeID__c = :empCode];
            Employee__c empData;
            if(empList.size() == 1){
                empData = empList[0];
            }else{
                throw new CustomLogicException('No or multiple employees with same Employee Code.');
            }
            Attendance_Activity__c newChildAttendance;
            String currMasterAttendanceId = [SELECT Id, Date__c FROM Attendance__c WHERE Employee__c = :empData.Id AND Date__c =:currDate WITH SYSTEM_MODE]?.Id;
            Time currentTime = Time.newInstance(System.now().hour(), System.now().minute(), System.now().second(), System.now().millisecond());
            Datetime currentDatetime = DateTime.newInstance(System.today(),currentTime);
            if(currMasterAttendanceId != null){
                newChildAttendance = new Attendance_Activity__c(Attendance__c=currMasterAttendanceId, Action_Time__c=currentTime,Action_Date_and_Time__c = currentDatetime, Mode__c=PUNCHMODE, Action_Type__c=CHECKOUTACTIONTYPE);
            }else{
                Attendance__c newMasterAttendance = new Attendance__c(Employee__c=empData.Id, Date__c=currDate, Employee_User__c=empData.SF_User__c);
                insert as system newMasterAttendance;
                attendenceTimerCmpCtrl.manualSharing(newMasterAttendance, empData, TRUE);
                newChildAttendance = new Attendance_Activity__c(Attendance__c=newMasterAttendance.Id, Action_Time__c=currentTime,Action_Date_and_Time__c = currentDatetime, Mode__c=PUNCHMODE, Action_Type__c=CHECKINACTIONTYPE);
            }
            insert as system newChildAttendance;
        }catch(Exception e){
            Log__c log = new Log__c(Method_Name__c='logIn', Class_Name__c='BiometricHandler', Line_Number__c=e.getLineNumber(), Reason__c=e.getMessage());
            insert as system log;
        }
    }
    @HttpGet
    global static void attendanceInfo(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try{
            Map<String, String> paramMap = req.params;
            JSONParser parser = JSON.createParser(req.requestBody.toString());
            if(!paramMap.containsKey('emp') || !paramMap.containsKey('date')){
                throw new CustomLogicException('Missing emp/date param');
            }
            Employee__c empData = [SELECT Id FROM Employee__c WHERE EmployeeID__c = :paramMap.get('emp') LIMIT 1];
            Date currDate = Date.parse(paramMap.get('date'));
            Attendance__c attendanceInfo = [SELECT Status_Of_Day__c, First_Check_In__c, Last_Check_Out__c, First_Check_In_Date_and_Time__c, Last_Check_Out_Date_and_Time__c, Duration_In_Mins__c, Duration_In_Min_Date_and_Time__c, Duration_In_Hour_and_Minutes__c, Duration_In_Hours__c, Regularization_Status__c, Regularized_Duration_Min__c, Regularized_check_In__c, Regularized_check_out__c, (SELECT Mode__c, Action_Type__c, Action_Time__c, Action_Date_and_Time__c FROM Attendance_Activities__r ORDER BY Action_Time__c DESC) FROM Attendance__c WHERE Employee__c = :empData.Id AND Date__c =:currDate WITH SYSTEM_MODE LIMIT 1];
            res.responseBody = Blob.valueOf(JSON.serializePretty(attendanceInfo));
            res.statusCode = 200;
        }catch(Exception e){
            res.responseBody = Blob.valueOf(e.getMessage()+' @'+e.getLineNumber());
            res.statusCode = 400;
        }finally{
            res.addHeader('Content-Type', 'application/json');
        }
    }
}