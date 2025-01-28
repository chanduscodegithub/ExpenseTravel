/*------------------------------------------------------------
Author       :  JEYALALITHA K.H
Company      :  CRMIT Pvt. Ltd.
Test Class   :  _

History
<Date>         <Authors Name>        <Brief Description of Change>
------------------------------------------------------------------*/
/**
* 
* @author Jeyalalitha K.H
* @since 2023-06-13
*/
public without sharing class EmailLeaveOrApprovalController {
    private class DetailsCustomException extends Exception {
    }
    private class EmployeeWrappedLeaveData{
        private String employeeName {get; set;}
        private String casualsBal {get; set;}
        private String sickBal {get; set;}
        private String paidBal {get; set;}
        private String celebrationBal {get; set;}
        private String restrictedBal {get; set;}
        
        private EmployeeWrappedLeaveData(String employeeName, String casualsBal, String sickBal, String paidBal, String celebrationBal, String restrictedBal){
            this.employeeName = employeeName;
            this.casualsBal = casualsBal;
            this.sickBal = sickBal;
            this.paidBal = paidBal;
            this.celebrationBal = celebrationBal;
            this.restrictedBal = restrictedBal;
        }
    }
    @AuraEnabled(cacheable=true)
    public static void sendLeaveBalInMail(Boolean forReportees){
        try{
            Map<Id, EmployeeWrappedLeaveData> empAndReporteesData = new Map<Id, EmployeeWrappedLeaveData>();
            String currYear = String.valueOf(System.now().year());
            OrgWideEmailAddress owaData = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Sales++ Admin' LIMIT 1];
            List<Employee__c> empList = [SELECT Id, Name, Gender__c, Type__c, Region__c, SF_User__r.Email FROM Employee__c WHERE SF_User__c =: UserInfo.getUserId() WITH SYSTEM_MODE limit 1];
            Map<Id, Employee__c> reporteesSelfEmpMap = new Map<Id, Employee__c>([SELECT Id, Name, Gender__c, Type__c, Region__c, SF_User__r.Email FROM Employee__c WHERE ReportingTo__c =: empList[0].Id OR Id =: empList[0].Id WITH SYSTEM_MODE]);
            List<Employee_Leave_Balance__c>  empLeaveBal = [SELECT Id, Employee__c, Employee__r.Date_of_Anniversary__c, Employee_Status__c, Employee__r.Name, Employee__r.Type__c, Year__c, Employee__r.ReportingTo__c, Sick_Leave__c, Bereavement_Leave__c, Casual_Leave__c, Celebration_Leave__c, Maternity_Leave__c, Paternity_Leave__c, Privilege_Paid_Leave_in_days__c, Restricted_Holiday__c FROM Employee_Leave_Balance__c WHERE (Employee__c =: empList[0].Id OR Employee__r.ReportingTo__c =:empList[0].Id) AND Year__c =: currYear AND Active__c=true AND Employee__r.Type__c != 'Probationer' WITH SYSTEM_MODE];
            for(Employee_Leave_Balance__c eachBal : empLeaveBal){
                if(eachBal.Employee_Status__c == reporteesSelfEmpMap.get(eachBal.Employee__c).Type__c){
                    String casualBalStr = eachBal.Casual_Leave__c == null ? '0' : String.valueOf(eachBal.Casual_Leave__c);
                    String sickBalStr = eachBal.Sick_Leave__c == null ? '0' : String.valueOf(eachBal.Sick_Leave__c);
                    String paidBalStr = eachBal.Privilege_Paid_Leave_in_days__c == null ? '0' : String.valueOf(eachBal.Privilege_Paid_Leave_in_days__c);
                    String celebBalStr = eachBal.Celebration_Leave__c == null ? '0' : eachBal.Employee__r.Date_of_Anniversary__c == null ? String.valueOf(eachBal.Celebration_Leave__c - 1) : String.valueOf(eachBal.Celebration_Leave__c);
                    String restrictedBalStr = eachBal.Restricted_Holiday__c == null ? '0' : String.valueOf(eachBal.Restricted_Holiday__c);
                    empAndReporteesData.put(eachBal.Employee__c, new EmployeeWrappedLeaveData(eachBal.Employee__r.Name, casualBalStr, sickBalStr, paidBalStr, celebBalStr, restrictedBalStr));
                }
            }
            String htmlBody = 'Dear&nbsp;'+empList[0].Name+',<br/><br/>';
            String subject = 'Your leave balance report is here!';
            List<String> emailAddress = new List<String>{empList[0].SF_User__r.Email };
                EmployeeWrappedLeaveData currEmpLeaveBalData = empAndReporteesData.get(empList[0].Id);
            Integer i=1;
            String balList = '<table style="font-family: arial, sans-serif; border-collapse: collapse; width: max-content;">';
            balList += '<tr><th style="border: 1px solid #000; text-align: left; padding: 4px 55px 4px 5px;">Casual Leave</th><th style="border: 1px solid #000; text-align: left; padding: 4px 55px 4px 5px;">Sick Leave</th><th style="border: 1px solid #000; text-align: left;padding: 4px 55px 4px 5px;">Privilege/Annual Leave</th><th style="border: 1px solid #000; text-align: left;padding: 4px 55px 4px 5px;">Celebration Leave</th><th style="border: 1px solid #000; text-align: left; padding: 4px 55px 4px 5px;">Restricted Holiday</th></tr>';
            balList += '<tbody><tr style="border: 1px solid #000; background-color: #dddddd;">';
            balList += '<td style="border: 1px solid #000; text-align: left; padding: 4px 55px 4px 5px;">'+currEmpLeaveBalData.casualsBal+'</td>';
            balList += '<td style="border: 1px solid #000; text-align: left; padding: 4px 55px 4px 5px;">'+currEmpLeaveBalData.sickBal+'</td>';
            balList += '<td style="border: 1px solid #000; text-align: left; padding: 4px 55px 4px 5px;">'+currEmpLeaveBalData.paidBal+'</td>';
            balList += '<td style="border: 1px solid #000; text-align: left; padding: 4px 55px 4px 5px;">'+currEmpLeaveBalData.celebrationBal+'</td>';
            balList += '<td style="border: 1px solid #000; text-align: left; padding: 4px 55px 4px 5px;">'+currEmpLeaveBalData.restrictedBal+'</td></tr>';
            balList += '</tbody></table>';
            
            String repoteesBalList = '<table style="font-family: arial, sans-serif; border-collapse: collapse; width: max-content;">';
            repoteesBalList += '<tr><th style="border: 1px solid #000; text-align: left; padding: 4px 55px 4px 5px;">Employee Name</th><th style="border: 1px solid #000; text-align: left; padding: 4px 55px 4px 5px;">Casual Leave</th><th style="border: 1px solid #000; text-align: left; padding: 4px 55px 4px 5px;">Sick Leave</th><th style="border: 1px solid #000; text-align: left;padding: 4px 55px 4px 5px;">Privilege Leave</th><th style="border: 1px solid #000; text-align: left;padding: 4px 55px 4px 5px;">Celebration Leave</th><th style="border: 1px solid #000; text-align: left; padding: 4px 55px 4px 5px;">Restricted Holiday</th></tr>';
            repoteesBalList += '<tbody><tr style="border: 1px solid #000; background-color: #dddddd;">';
            for(Id eachId : empAndReporteesData.keyset()){
                if(eachId != empList[0].Id){
                    EmployeeWrappedLeaveData EmpLeaveBalData = empAndReporteesData.get(eachId);
                    i++;
                    repoteesBalList += (Math.mod(i,2)==0) ? '<tr style="border: 1px solid #000; background-color: #dddddd;">' : '<tr>';
                    repoteesBalList += '<td style="border: 1px solid #000; text-align: left; padding: 4px 55px 4px 5px;">'+EmpLeaveBalData.employeeName+'</td>';
                    repoteesBalList += '<td style="border: 1px solid #000; text-align: left; padding: 4px 55px 4px 5px;">'+EmpLeaveBalData.casualsBal+'</td>';
                    repoteesBalList += '<td style="border: 1px solid #000; text-align: left; padding: 4px 55px 4px 5px;">'+EmpLeaveBalData.sickBal+'</td>';
                    repoteesBalList += '<td style="border: 1px solid #000; text-align: left; padding: 4px 55px 4px 5px;">'+EmpLeaveBalData.paidBal+'</td>';
                    repoteesBalList += '<td style="border: 1px solid #000; text-align: left; padding: 4px 55px 4px 5px;">'+EmpLeaveBalData.celebrationBal+'</td>';
                    repoteesBalList += '<td style="border: 1px solid #000; text-align: left; padding: 4px 55px 4px 5px;">'+EmpLeaveBalData.restrictedBal+'</td></tr>'; 
                }
            }
            repoteesBalList += '</tbody></table>';
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            if((empLeaveBal != null || empLeaveBal.size()>0) && forReportees == false){
                htmlBody += 'I hope this email finds you well. We understand the importance of maintaining an accurate record of your leave entitlements, and we strive to ensure transparency and clarity regarding your available time off.<br/><br/> ';
                htmlBody += 'Here are the details:<br/><br/>'+balList+'<br/>';
                htmlBody += 'Thank you for your dedication and commitment to your role. Should you require any further assistance or information, please feel free to contact HR Team.<br/><br/>';
                htmlBody += 'Thanks,<br/>Avishkaar Team<br/><br/>';
                htmlBody += '<i>This is an auto-generated email. Please do not reply to the email.</i>';
            }
            else if((empLeaveBal != null || empLeaveBal.size()>0) && forReportees == true && empLeaveBal.size() > 1){
                htmlBody += 'I hope this email finds you well. We understand the importance of maintaining an accurate record of your leave entitlements, and we strive to ensure transparency and clarity regarding your available time off.<br/><br/> ';
                htmlBody += ' Here are the details of your leave balance:<br/><br/>'+balList+'<br/>';
                htmlBody += 'Reportees Leave Balance Details are: <br/><br/>'+repoteesBalList+'<br/>';
                htmlBody += 'Thank you for your dedication and commitment to your role. Should you require any further assistance or information, please feel free to contact HR Team.<br/><br/>';
                htmlBody += 'Thanks,<br/>Avishkaar Team<br/><br/>';
                htmlBody += '<i>This is an auto-generated email. Please do not reply to the email.</i>';
            }
            else if((empLeaveBal != null || empLeaveBal.size()>0) && forReportees == true && empLeaveBal.size() == 1){
                htmlBody += 'I hope this email finds you well. We understand the importance of maintaining an accurate record of your leave entitlements, and we strive to ensure transparency and clarity regarding your available time off.<br/><br/> ';
                htmlBody += 'Here are the details of your leave balance:<br/><br/>'+balList+'<br/>';
                htmlBody += '<div style="border: 1px solid black; padding: 10px; display: inline-block;">Note: <span style="color: red;">No active leave balance records are found for your reportees for this year!</span></div><br/><br/>';
                htmlBody += 'Thank you for your dedication and commitment to your role. Should you require any further assistance or information, please feel free to contact HR Team.<br/><br/>';
                htmlBody += 'Thanks,<br/>Avishkaar Team<br/><br/>';
                htmlBody += '<i>This is an auto-generated email. Please do not reply to the email.</i>';
            }
            else{
                htmlBody += 'I hope this email finds you well. Unfortunately, due to a discrepancy or oversight, we do not have the most up-to-date information regarding your leave balance.Our HR team will be working diligently to gather the necessary data and update your leave balance accordingly.<br/>We apologize for any inconvenience or confusion this may cause, and we appreciate your understanding and patience as we work to resolve this matter promptly.<br/><br/>Thank you for your patience and cooperation.';
                //TODO: Add HR's email.
                email.setCcAddresses(new List<String>{'hrteam@crmit.com'});
            }
            email.setHtmlBody(htmlBody);
            email.setSubject(subject);
            email.setOrgWideEmailAddressId(owaData.Id);
            email.setToAddresses(emailAddress);
            if (!Test.isRunningTest()){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{ email});
                if (results[0].success) {
                    System.debug('The email is successfully sent');
                }
                else{
                    System.debug('The email failed to send: '+ results[0].errors[0].message);
                    throw new DetailsCustomException('The email failed to send.');
                }
            }
        }
        catch(Exception e){
            System.debug('Issue in: EmailLeaveOrApprovalController @ sendLeaveBalInMail method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber()); 
        }
    }
   @AuraEnabled(cacheable=true)
    public static LeaveWrapper getUserInfo(Id recId) {
        System.debug('.Id' +recId);
        try{
            LeaveWrapper eachWrap = new LeaveWrapper();
            String recRelation;
            Id actorId;
            String userId = UserInfo.getUserId();
            Employee_Leave__c currEmpLeaveRec = [SELECT Id, Name, Current_Work_Item_ID__c, Send_to_Manager__c, Employee__r.SF_User__c, Reporting_Manager__c, Status__c, Notify_HR__c, Leave_Type__c FROM Employee_Leave__c WHERE Id =: recId];
            User currUser = [SELECT ID, FirstName, LastName, Name, Title, Profile.Name, Email FROM User WHERE ID =: userId LIMIT 1];
            system.debug('currUser'+currUser);
            Group hrQueue = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'HR_queue' LIMIT 1];
            system.debug('hrQueue'+hrQueue);
            Id publicGroupId = [SELECT Id FROM Group WHERE DeveloperName = 'HR_Team' and Type = 'Regular'].Id;
            system.debug('publicGroupId'+publicGroupId);
            List<GroupMember> groupMemberList = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE GroupId =: publicGroupId];
            for(GroupMember eachMem : groupMemberList){
                if(currUser.Id == eachMem.UserOrGroupId && currEmpLeaveRec.Notify_HR__c == true){
                    actorId = hrQueue.Id;
                    system.debug('if loop actorid'+actorId);
                }
                else{
                    actorId = currUser.Id;
                    System.debug('currUser.Id' +currUser.Id);
                    system.debug('else loop actorid'+actorId);
                }
            }
            ProcessDefinition processDef =[SELECT Id FROM ProcessDefinition WHERE DeveloperName='Multilevel_Leave_Approval' limit 1];
            system.debug('processDef'+processDef +'currEmpLeaveRec.Id'+currEmpLeaveRec.Id+'actorId'+actorId);
            List<ProcessInstanceWorkitem>  currWorkItem = [SELECT Id, ProcessInstance.TargetObjectId, ProcessInstance.Status, OriginalActorId, ProcessInstance.ProcessDefinitionId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId =: currEmpLeaveRec.Id AND ProcessInstance.Status = 'Pending' AND OriginalActorId =: actorId AND ProcessInstance.ProcessDefinitionId =: processDef.Id];
            System.debug('currWorkItem' +currWorkItem);
            if(currEmpLeaveRec.Reporting_Manager__c == currUser.Id && currEmpLeaveRec.Status__c == 'Applied'){
                recRelation = 'Manager';
            }
            else{
                recRelation = 'None';
            }
            eachWrap.recRelationWrap = recRelation;
            eachWrap.empLeave = currEmpLeaveRec;
            eachWrap.currUserInfo = currUser;
            if(currWorkItem != null && currWorkItem.size() > 0){
                eachWrap.currWorkItemId = currWorkItem[0].Id; 
            }
            return eachWrap;
        }
        catch(Exception e){
            System.debug('Issue in: EmailLeaveOrApprovalController @ getUserInfo method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            return null;
        }
    }
    public class LeaveWrapper{
        @AuraEnabled public String  recRelationWrap{get;set;}
        @AuraEnabled public String  currWorkItemId{get;set;} 
        @AuraEnabled public User currUserInfo{get;set;}
        @AuraEnabled public Employee_Leave__c empLeave{get;set;}
    }
    
    @AuraEnabled
    public static void approvalStep(String reqAction, String reqComments, String workItemId){
        try {
            system.debug('workItemId>>> in approval step'+workItemId);
            if(workItemId == null) throw new DetailsCustomException('No leave applications are submitted, Kindly contact admin team');
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments(reqComments);
            req.setAction(reqAction);
            req.setWorkitemId(workItemId);
            Approval.ProcessResult result = Approval.process(req);
        } 
        catch (Exception e) {
            System.debug('Issue in: EmailLeaveOrApprovalController @ approvalStep method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    // @InvocableMethod

    //Cancelation method : If an employee has mistakenly applied for leave and wants to cancel it before the manager approves or rejects.  (line no: 217 to 286)

   public static void ApprovalProcessRecordsDelete(Id recId)
   {
   try{
   // if(workItemId == null) throw new DetailsCustomException('No leave applications are submitted, Kindly contact admin team');
    List<Approval.ProcessWorkitemRequest> requests = new List<Approval.ProcessWorkitemRequest> ();
    Employee_Leave__c emps = [Select Id,Status__c,Leave_Type__c, Duration__c, End_Date__c,  Start_Date__c, 
    OwnerId, Employee_Leave_Balance__c	from Employee_Leave__c where ID =:recId and Status__c = 'Applied'];
    system.debug('emps list>>'+emps);
    Map<ID,ProcessInstance> piMap = New Map<ID,ProcessInstance>([Select Id,TargetObjectId from ProcessInstance where TargetObjectId =:emps.id]);
    system.debug('pimap'+piMap);
    
    system.debug('emps>>'+emps);
    //system.debug('targetobjectId'+piMap.TargetObjectId);
        for(ProcessInstanceWorkItem pp : [Select Id from ProcessInstanceWorkItem where ProcessInstanceId IN :piMap.keySet()]){
             Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
             req2.setAction('Removed');
             req2.setWorkitemId(pp.Id);
           //  req2.setWorkitemId(workItemId);
             requests.add(req2);
   }
       Approval.ProcessResult[] processResults = null;
       system.debug('processResults'+processResults);
       processResults = Approval.process(requests, true);
       system.debug('processResults>>>'+processResults);
          for (Approval.ProcessResult result : processResults) {
            if (result.isSuccess()) {
                system.debug('Successfully removed');
              } 
            else {
                    System.debug('Error removing from approval process: ' + result.getErrors()[0].getMessage());
                 }
   } 
    Id EmployeeId = emps.Employee_Leave_Balance__c;
   // Integer Duration = emps.Duration__c;
   // String LeaveType = emps.Leave_Type__c;

   Employee_Leave_Balance__c empleavebalance = [select id,Bereavement_Leave__c, CarryForward__c, Carry_Forward_Celebration_Leave__c	, Casual_Leave__c, Celebration_Leave__c	,Employee__c, Employee_Status__c,
   Long_Leave__c,Loss_of_Pay_LOP__c,Maternity_Leave__c,Paid_Leave_Adjustment__c, Paternity_Leave__c, Privilege_Paid_Leave_in_days__c,
   Restricted_Holiday__c, Sick_Leave__c, Work_from_Home__c from Employee_Leave_Balance__c where  id =: EmployeeId];
   
   Map<String, Object> fieldMap =empleavebalance.getPopulatedFieldsAsMap();
   for (String fieldName : fieldMap.keySet()) {
       // Get the field describe result
       Schema.DescribeFieldResult fieldDescribe = Employee_Leave_Balance__c.getSObjectType().getDescribe().fields.getMap().get(fieldName).getDescribe();
   
       // Output field label
       System.debug('Field Label: ' + fieldDescribe.getLabel());
   
       // Check if the field label contains 'Name'
       if (fieldDescribe.getLabel().contains(emps.Leave_Type__c)) {
        Object fieldValue = fieldMap.get(fieldName);     
        Decimal CurDuration = (Decimal)fieldValue ;  
          // Update the field dynamically
           Decimal d = CurDuration - emps.Duration__c;
           empleavebalance.put(fieldName, CurDuration + emps.Duration__c);
          
       }
      
   }
   
   // Update the record with the modified fields
   update empleavebalance;
   system.debug('empleavebalance'+empleavebalance);
} catch(Exception e){
    System.debug('Issue in: ApprovalProcessRecordsDelete @ getUserInfo method');
    System.debug('Err Msg: ' + e.getMessage());
    System.debug('@ Line: ' + e.getLineNumber());
   // throw new AuraHandledException(e.getMessage());
}
}

}