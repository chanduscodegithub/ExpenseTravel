/*------------------------------------------------------------
Author       :  JEYALALITHA K.H
Company      :  CRMIT Pvt. Ltd.
Description  :  Described before every method about their functionalities.
Inputs       :  Mentioned before each methods.
Test Class   :  _

History
<Date>         <Authors Name>        <Brief Description of Change>
------------------------------------------------------------------*/
/**
 * 
 * @author Jeyalalitha K.H
 * @since 2023-06-13
 */

public class AMSAllTriggerHandler {
    
     public class CustomLogicException extends Exception {
         
     }
    
   /**
     * Updates the Employee_User__c field in the attendance record by referencing the SF_User__c field in the Employee record.
     * @param {Map<Id, Attendance__c>} attendanceMap -The Map consists of RecordId keys and corresponding attendance records where the Employee__c field has been updated for the respective RecordId.
     * @param {List<String>} empIdList - The List includes the recordIds of all employees whose attendance records are being passed as parameters via a Map.
     * @throws CustomLogicException - If any of the query parameters are missing or invalid, or if there is any issue in querying the attendance data.
     * @author Jeyalalitha
     * @since 2023-06-13
     */
    // public static void attendanceUpdate(Map<Id, Attendance__c> attendanceMap, List<String> empIdList){
    //     try{
    //         Map<Id, Employee__c> empMap = new Map<Id, Employee__c>([SELECT SF_User__c FROM Employee__c WHERE Id IN :empIdList]);
    //         for(Id attendanceId : attendanceMap.keySet()){
    //             attendanceMap.get(attendanceId).Employee_User__c = empMap.get(attendanceMap.get(attendanceId).Employee__c).SF_User__c;
    //         }
    //     }
    //     catch(Exception e){
    //         System.debug('Issue in: amsAllTriggerHandler @ attendanceUpdate method');
    //         System.debug('Err Msg: ' + e.getMessage());
    //         System.debug('@ Line: ' + e.getLineNumber()); 
    //     }
        
    // }
    
    /**
     * AutoPopulates the Employee_User__c field in the attendance record by referencing the SF_User__c field in the Employee record.
     * @param {List<Attendance__c>} attendanceMap -The Map consists of RecordId keys and corresponding attendance records where the Employee__c field has been updated for the respective RecordId.
     * @param {List<String>} empIdList - The List includes the recordIds of all employees whose attendance records are being passed as parameters via list.
     * @throws CustomLogicException - If any of the query parameters are missing or invalid, or if there is any issue in querying the attendance data.
     * @author Jeyalalitha
     * @since 2023-06-13
     */
    // public static void attendanceInsert (List<Attendance__c> newAttendance, List<String> empIdList){
    //     try{
    //         Map<Id, Employee__c> empMap = new Map<Id, Employee__c>([SELECT SF_User__c FROM Employee__c WHERE Id IN :empIdList]);
    //         for(Attendance__c eachAtt : newAttendance){
    //             eachAtt.Employee_User__c = empMap.get(eachAtt.Employee__c).SF_User__c;
    //         }
    //     }
    //     catch(Exception e){
    //         System.debug('Issue in: amsAllTriggerHandler @ attendanceUpdate method');
    //         System.debug('Err Msg: ' + e.getMessage());
    //         System.debug('@ Line: ' + e.getLineNumber()); 
    //     }
        
    // }
    
    /**
     * Throws an error when attempting to apply individual time-off for a date that has already been applied before.
     * @param {List<Individual_Time_off__c>} newtimeOff - The list of Individual time off records that is being inserted newly .
     * @throws CustomLogicException - If any of the query parameters are missing or invalid, or if there is any issue in querying the attendance data.
     * @author Jeyalalitha
     * @since 2023-06-13
     */
    public static void timeOffError(List<Individual_Time_off__c> newtimeOff){
        try{
            
            List<Id> employeeLeaveId = new List<Id>();
            for(Individual_Time_off__c eachOff : newtimeOff){
                employeeLeaveId.add(eachOff.Employee_Leave__c);
            }
            List<Individual_Time_off__c> timeOffList = [SELECT Id, Leave_Date__c, Employee_Leave__c,  Employee_Leave__r.Employee__c FROM Individual_Time_off__c WHERE Employee_Leave__c IN: employeeLeaveId];
            for(Individual_Time_off__c eachOff : newtimeOff){
                for(Individual_Time_off__c each : timeOffList){
                    if(eachOff.Employee_Leave__c == each.Employee_Leave__c && eachOff.Leave_Date__c == each.Leave_Date__c){
                        eachOff.Leave_Date__c.addError('You are not allowed to request leave for dates that have already been applied for.');
                    }
                }  
            }  
        }
        catch(Exception e){
            System.debug('Issue in: amsAllTriggerHandler @ timeOffError method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber()); 
        }
    }
    
    /**
     * Implements a validation mechanism to prevent the creation of duplicate attendance records for the same employee on the same date, and throws an error if such an attempt is made.
     * @param {List<Attendance__c>} incomingAttendanceList - The list of newly created attendance records to be inserted into the attendance object.
     * @throws CustomLogicException - If any of the query parameters are missing or invalid, or if there is any issue in querying the attendance data.
     * @author Jeyalalitha
     * @since 2023-06-13
     */
    // public static void preventAttendanceDuplication(List<Attendance__c> incomingAttendanceList){
    //     try{
    //        List<Id> incomingEmployeeId = new List<Id>();
    //         for(Attendance__c eachAtt : incomingAttendanceList){
    //             incomingEmployeeId.add(eachAtt.Employee__c);
    //         }
    //         List<Attendance__c> existingAttendanceList = [SELECT Id, Date__c, Employee__c  FROM Attendance__c WHERE Employee__c IN: incomingEmployeeId];
    //         for(Attendance__c eachInAtt : incomingAttendanceList){
    //             for(Attendance__c eachAtt : existingAttendanceList){
    //                 if(eachInAtt.Employee__c == eachAtt.Employee__c && eachInAtt.Date__c == eachAtt.Date__c){
    //                     eachInAtt.Date__c.addError('Your Attendance has been already Recorded for this Date.');
    //                 }
    //             }
    //         }
            
    //     }
    //     catch(Exception e){
    //         System.debug('Issue in: amsAllTriggerHandler @ preventAttendanceDuplication method');
    //         System.debug('Err Msg: ' + e.getMessage());
    //         System.debug('@ Line: ' + e.getLineNumber()); 
    //     }
    // }
    
     /**
     * Implements a validation mechanism to prevent the creation of duplicate leave balance records for the same employee on the same date, and throws an error if such an attempt is made.
     * @param {List<Attendance__c>} incomingAttendanceList - The list of newly created attendance records to be inserted into the attendance object.
     * @throws CustomLogicException - If any of the query parameters are missing or invalid, or if there is any issue in querying the attendance data.
     * @author Jeyalalitha
     * 
     * @since 2023-06-13
     */
    public static void preventDuplicateLeaveBalance(List<Employee_Leave_Balance__c> newEmpLeaveBalance){
        try{
           List<Id> incomingEmpId = new List<Id>();
            for(Employee_Leave_Balance__c eachBal : newEmpLeaveBalance){
                incomingEmpId.add(eachBal.Employee__c);
            }
            List<Employee_Leave_Balance__c> existingLeaveBal = [SELECT Id, Year__c, Employee__c, Employee_Status__c FROM Employee_Leave_Balance__c WHERE Employee__c IN: incomingEmpId];
            for(Employee_Leave_Balance__c eachInBal : newEmpLeaveBalance){
                for(Employee_Leave_Balance__c eachBal : existingLeaveBal){
                    if(eachInBal.Employee__c == eachBal.Employee__c && eachInBal.Year__c == eachBal.Year__c && eachInBal.Employee_Status__c == eachBal.Employee_Status__c && eachInBal.Region__c == eachBal.Region__c){
                        eachInBal.Year__c.addError('Your leave balance record for the current year already exists.');
                    }
                }
            }
        }
        catch(Exception e){
            System.debug('Issue in: amsAllTriggerHandler @ preventAttendanceDuplication method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber()); 
        }
    }
    
    /**
     * In the context of inserting an Employee leave record, the system will automatically populate the "Employee_Leave_Balance__c" field. This will be accomplished by retrieving the record IDs of the employee's leave balance records for the current year and using that information to populate the field.
     * @param {List<Employee_Leave__c>} newLeaves - The list of newly created Employee leave records to be inserted into the Employee Leave object.
     * @param {List<String>} newLeaves - The list of recordIds of Employees for whom the leave record is being created.
     * @throws CustomLogicException - If any of the query parameters are missing or invalid, or if there is any issue in querying the attendance data.
     * @author Jeyalalitha
     * @since 2023-06-13
     */
    public static void empBalFieldUpdate(List<Employee_Leave__c> newLeaves, List<String> employee){
        try{
            List<Employee_Leave_Balance__c> empLeaveBalList = [SELECT Id, Employee__c, Year__c, Employee_Status__c FROM Employee_Leave_Balance__c WHERE Employee__c IN: employee];
            for(Employee_Leave__c eachLeave : newLeaves){
                for(Employee_Leave_Balance__c eachBal : empLeaveBalList){
                    if(eachBal.Year__c == String.valueOf(System.now().year()) && eachBal.Employee__c == eachLeave.Employee__c && eachBal.Employee_Status__c == eachLeave.Employee_Status__c){
                        eachLeave.Employee_Leave_Balance__c = eachBal.Id;
                    }
                }
            }
        }
        catch(Exception e){
            System.debug('Issue in: amsAllTriggerHandler @ empBalFieldUpdate method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber()); 
        }
    }
    
    public static void empBalEmpNameUpdate(List<Employee_Leave_Balance__c> newEmpBal, List<String> employeeIds){
        try{
            List<Employee__c > employeeList = [SELECT Id, Name FROM Employee__c WHERE Id IN: employeeIds];
            for(Employee_Leave_Balance__c eachBal : newEmpBal){
                for(Employee__c eachEmp : employeeList){
                    if(eachBal.Employee__c == eachEmp.Id){
                        eachBal.Employee_Name__c = eachEmp.Name;
                    }
                }
            }
        }
        catch(Exception e){
            System.debug('Issue in: amsAllTriggerHandler @ empBalEmpNameUpdate method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber()); 
        }
    }
    
    /**
     * Updates the leave balances based on the leaves applied by the Employees based on the leave types and number of days.
     * @param {Map<Id, Employee_Leave__c>} newEmpLeaveList - The map where the recordId is the key and the value is the updated employee leave record for those whose leave duration field value has been changed.  
     * @param {Map<Id, Employee_Leave__c>} oldMapLeave - The map where the recordId is the key and value is the employee leave record before being updated.
     * @param {List<String>} employeeList - The list of Employee recordId for whom the employee leave balance is being calculated.
     * @param {List<String>} YearList - The list of years for which employee leave balance is being calculated.
     * @param {List<String>} RegionList - The list of Regions of the employees for which employee leave balance is being calculated.
     * @throws CustomLogicException - If any of the query parameters are missing or invalid, or if there is any issue in querying the attendance data.
     * @author Jeyalalitha
     * @since 2023-06-13
     */
    public static void leaveBalanceUpdate(Map<Id, Employee_Leave__c> newEmpLeaveList, Map<Id, Employee_Leave__c> oldMapLeave, List<String> employeeList, List<String> YearList, List<String> RegionList){
        try{
            List<Employee_Leave_Balance__c> empLeaveBalList = [SELECT Id, Employee__c, Year__c, Casual_Leave__c, Sick_Leave__c, Region__c, Privilege_Paid_Leave_in_days__c,Restricted_Holiday__c, Celebration_Leave__c, Bereavement_Leave__c, Loss_of_Pay_LOP__c,Work_from_Home__c FROM Employee_Leave_Balance__c WHERE Employee__c IN: employeeList AND Year__c IN: YearList AND Region__c IN: RegionList AND Active__c = true];
            List<Employee_Leave_Balance__c> toBeUpdatedBal = new List<Employee_Leave_Balance__c>();
            for(Id eachEmpId : newEmpLeaveList.keySet()){
                for(Employee_Leave_Balance__c eachBal : empLeaveBalList){
                    if(eachBal.Year__c == newEmpLeaveList.get(eachEmpId).Year__c && eachBal.Employee__c == newEmpLeaveList.get(eachEmpId).Employee__c && eachBal.Region__c == newEmpLeaveList.get(eachEmpId).Region__c){
                        toBeUpdatedBal.add(leaveBalCalculation(eachBal, newEmpLeaveList.get(eachEmpId)));
                    }
                }
            }
            if(toBeUpdatedBal.size()> 0){
                Update toBeUpdatedBal;  
            }
        }
        catch(Exception e){
            System.debug('Issue in: amsAllTriggerHandler @ leaveBalanceUpdate method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber()); 
        }
    }
    
    public static void leaveBalanceUpdateOnInsert( List<Employee_Leave__c> empLeaveList, List<String> employeeList, List<String> YearList, List<String> RegionList){
        try{
            List<Employee_Leave_Balance__c> empLeaveBalList = [SELECT Id, Employee__r.Type__c, Employee__c, Year__c, Region__c, Paternity_Leave__c, Casual_Leave__c, Sick_Leave__c, Privilege_Paid_Leave_in_days__c,Restricted_Holiday__c, Celebration_Leave__c, Bereavement_Leave__c, Loss_of_Pay_LOP__c, Maternity_Leave__c, Work_from_Home__c FROM Employee_Leave_Balance__c WHERE Employee__c IN: employeeList AND Year__c IN: YearList AND Region__c IN: RegionList AND Active__c = True];
            Map<Id, String> empType = new Map<Id, String>();
            List<Employee_Leave_Balance__c> toBeUpdatedBal = new List<Employee_Leave_Balance__c>();
            for(Employee_Leave__c eachLeave : empLeaveList){
                for(Employee_Leave_Balance__c eachBal : empLeaveBalList){
                      System.debug('eachLeave out if'+eachBal); 
                     System.debug('eachBal out if'+eachBal);
                    if(eachBal.Id == eachLeave.Employee_Leave_Balance__c){
                        System.debug('eachBal in if'+eachBal);
                        toBeUpdatedBal.add(leaveBalCalculation(eachBal, eachLeave));
                    }
                }
            }
            System.debug('toBeUpdatedBal'+toBeUpdatedBal);
            if(toBeUpdatedBal.size()> 0){
                Update toBeUpdatedBal;  
            }
        }
        catch(Exception e){
            System.debug('Issue in: amsAllTriggerHandler @ leaveBalanceUpdate method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber()); 
        }
    }
    public static void leaveBalanceUpdateOnRejection(Map<Id,Employee_Leave__c> rejectedEmpLeaves, List<String> employeeList, List<String> YearList, List<String> RegionList){
        try{
            List<Employee_Leave_Balance__c> empLeaveBalList = [SELECT Id, Employee__c, Employee_Status__c, Year__c, Paternity_Leave__c, Casual_Leave__c, Sick_Leave__c, Region__c, Privilege_Paid_Leave_in_days__c,Restricted_Holiday__c, Celebration_Leave__c, Bereavement_Leave__c, Loss_of_Pay_LOP__c, Maternity_Leave__c, Work_from_Home__c FROM Employee_Leave_Balance__c WHERE Employee__c IN: employeeList AND Year__c IN: YearList AND Region__c IN: RegionList AND Active__c  = true];
            List<Employee_Leave_Balance__c> toBeUpdatedBal = new List<Employee_Leave_Balance__c>();
            List<Employee__c> toBeUpdatedEmployee = new List<Employee__c>();
            Map<Id, Employee__c> employeeMap = new Map<Id, Employee__c>([SELECT Id, Paternity_Maternity_Leave_Count__c From Employee__c WHERE Id IN: employeeList]);
            for(Id eachEmpId : rejectedEmpLeaves.keySet()){
                for(Employee_Leave_Balance__c eachBal : empLeaveBalList){
                    if(eachBal.Year__c == rejectedEmpLeaves.get(eachEmpId).Year__c && eachBal.Employee__c == rejectedEmpLeaves.get(eachEmpId).Employee__c && eachBal.Region__c == rejectedEmpLeaves.get(eachEmpId).Region__c && eachBal.Employee_Status__c == rejectedEmpLeaves.get(eachEmpId).Employee_Status__c){
                        toBeUpdatedBal.add(leaveBalCalculationOnRejection(eachBal, rejectedEmpLeaves.get(eachEmpId)));
                        if(rejectedEmpLeaves.get(eachEmpId).Leave_Type__c == 'Maternity Leave' || rejectedEmpLeaves.get(eachEmpId).Leave_Type__c == 'Paternity Leave'){
                            employeeMap.get(rejectedEmpLeaves.get(eachEmpId).Employee__c).Paternity_Maternity_Leave_Count__c -= 1;
                            toBeUpdatedEmployee.add(employeeMap.get(rejectedEmpLeaves.get(eachEmpId).Employee__c));
                        }
                    }
                }
            }
            if(toBeUpdatedBal.size()> 0){
                update toBeUpdatedBal;  
            }
            if(toBeUpdatedEmployee.size()> 0){
                update toBeUpdatedEmployee;
            }
        }
        catch(Exception e){
            System.debug('Issue in: amsAllTriggerHandler @ leaveBalanceUpdate method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber()); 
        }
    }
    public static void emailInformedUsers(Map<Id, Employee_Leave__c> approvedEmpLeaves, Map<Id,Employee_Leave__c> oldMapLeave){
        try{
            System.debug('Iam here to send email in emailInformedUsers');
            List<Messaging.SingleEmailMessage> allEmailMsg = new List<Messaging.SingleEmailMessage>();
            List<String> toaddress = new List<String>();
            for(Id eachId : approvedEmpLeaves.keyset()){
                String[] informTo = approvedEmpLeaves.get(eachId).Informed_Users__c.split(';');
                String htmlBody = 'Hi Team,<br/><br/>';
                htmlBody += 'This is to inform you that ' +approvedEmpLeaves.get(eachId).Employee_Name__c+' has applied leave/Work From Home for the following dates. For any clarification contact his/her Reporting Manager - '+oldMapLeave.get(eachId).Reporting_Manager__r.Name+'.<br/><br/>';
                htmlBody += 'Leave Details:<br/> Start Date: '+approvedEmpLeaves.get(eachId).Start_Date__c+'<br/> End Date: '+approvedEmpLeaves.get(eachId).End_Date__c+'<br/> Number of Days: '+approvedEmpLeaves.get(eachId).Duration__c+'<br/> Leave type: '+approvedEmpLeaves.get(eachId).Leave_Type__c+'<br/><br/>Regards,<br/>HR Team.<br/>Note: This Email is auto-generated do not reply.';
                for(String eachEmailId : informTo){
                    eachEmailId = eachEmailId.trim();
                    System.debug('eachEmailId'+eachEmailId);
                       toaddress.add(eachEmailId);
                }
                System.debug('toaddress'+toaddress);
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setHtmlBody(htmlBody);
                mail.setSubject(' Leave Information - '+approvedEmpLeaves.get(eachId).Employee_Name__c+'.');
                mail.setToAddresses(toaddress);
                allEmailMsg.add(mail);
                
            }
            if (!Test.isRunningTest()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(allEmailMsg);
                if (results[0].success) {
                    System.debug('The email is successfully sent');
                }
                else{
                    System.debug('The email failed to send: '+ results[0].errors[0].message);
                    throw new CustomLogicException('The email failed to send.');
                }
            }
        }
        catch(Exception e){
            System.debug('Issue in: amsAllTriggerHandler @ emailInformedUsers method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber()); 
        }
    }
    
    /**
     * Helper method that returns employee leave balance in which fields are assigned with appropriate values based on the conditions to be met.
     * @param {Employee_Leave_Balance__c} eachBal - Employee leave balance record in which the field update has to be carried out.  
     * @param {Employee_Leave__c} eachEmpLeave - The Employee leave record based on which the the employee leave balance is being calculated.
     * @throws CustomLogicException - If any of the query parameters are missing or invalid, or if there is any issue in querying the attendance data.
     * @author Jeyalalitha
     * @since 2023-06-13
     */
    private static Employee_Leave_Balance__c leaveBalCalculation (Employee_Leave_Balance__c eachBal, Employee_Leave__c eachEmpLeave){
        try{
            switch on eachEmpLeave.Leave_Type__c{
                when 'Sick Leave'{
                    eachBal.Sick_Leave__c -= eachEmpLeave.Duration__c;  
                } 
                When 'Casual Leave'{
                    eachBal.Casual_Leave__c -= eachEmpLeave.Duration__c;  
                }
                When 'Work from Home(WFH)'{
                    eachBal.Work_from_Home__c -= eachEmpLeave.Duration__c;
                }
                When 'paid Leave Adjustment'{
                    eachBal.Paid_Leave_Adjustment__c -= eachEmpLeave.Duration__c;
                }
                When 'Privilege/Paid Leave'{
                    eachBal.Privilege_Paid_Leave_in_days__c -= eachEmpLeave.Duration__c; 
                }
                When 'Maternity Leave'{
                    eachBal.Maternity_Leave__c -= eachEmpLeave.Duration__c; 
                }
                When 'Paternity Leave'{
                    eachBal.Paternity_Leave__c -= eachEmpLeave.Duration__c;
                }
                When 'Celebration Leave'{
                    eachBal.Celebration_Leave__c -= eachEmpLeave.Duration__c;
                }
                When 'Restricted Holiday'{
                    eachBal.Restricted_Holiday__c -= eachEmpLeave.Duration__c; 
                }
                When 'Loss of Pay(LOP)'{
                    eachBal.Loss_of_Pay_LOP__c -= eachEmpLeave.Duration__c;
                }
                When 'Bereavement Leave'{
                    eachBal.Bereavement_Leave__c -= eachEmpLeave.Duration__c; 
                }
            }
            System.debug('eachBal'+eachBal);
            return eachBal;
            
        }
        catch(Exception e){
            System.debug('Issue in: amsAllTriggerHandler @ leaveBalCalculation method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber()); 
            return null;
        }
    }
    private static Employee_Leave_Balance__c leaveBalCalculationOnRejection (Employee_Leave_Balance__c eachBal, Employee_Leave__c eachEmpLeave){
        try{
            switch on eachEmpLeave.Leave_Type__c{
                when 'Sick Leave'{
                    eachBal.Sick_Leave__c += eachEmpLeave.Duration__c;  
                } 
                When 'Casual Leave'{
                    eachBal.Casual_Leave__c += eachEmpLeave.Duration__c;  
                }
                When 'Work from Home(WFH)'{
                    eachBal.Work_from_Home__c += eachEmpLeave.Duration__c;
                }
                When 'paid Leave Adjustment'{
                    eachBal.Paid_Leave_Adjustment__c += eachEmpLeave.Duration__c;
                }
                When 'Privilege/Paid Leave'{
                    eachBal.Privilege_Paid_Leave_in_days__c += eachEmpLeave.Duration__c; 
                }
                When 'Maternity Leave'{
                    eachBal.Maternity_Leave__c += eachEmpLeave.Duration__c;
                }
                When 'Paternity Leave'{
                    eachBal.Paternity_Leave__c += eachEmpLeave.Duration__c;
                }
                When 'Celebration Leave'{
                    eachBal.Celebration_Leave__c += eachEmpLeave.Duration__c;
                }
                When 'Restricted Holiday'{
                    eachBal.Restricted_Holiday__c += eachEmpLeave.Duration__c; 
                }
                When 'Loss of Pay(LOP)'{
                    eachBal.Loss_of_Pay_LOP__c += eachEmpLeave.Duration__c;
                }
                When 'Bereavement Leave'{
                    eachBal.Bereavement_Leave__c += eachEmpLeave.Duration__c; 
                }
            }
            System.debug('eachBal'+eachBal);
            return eachBal;
            
        }
        catch(Exception e){
            System.debug('Issue in: amsAllTriggerHandler @ leaveBalCalculation method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber()); 
            return null;
        }
    }
}