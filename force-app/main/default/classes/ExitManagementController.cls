public with sharing class ExitManagementController {
    public class CustomException extends Exception {}
    
    @AuraEnabled(cacheable=true)
    public static Employee__c getEmployeeDetails(){
        try {
            List<Employee__c> empl = [SELECT Id, Name, ReportingTo__c, Department__c, BU_Head__c, SF_User__c FROM Employee__c WHERE Active__c = true AND SF_User__c = :UserInfo.getUserId() WITH SYSTEM_MODE];
            if(empl.size() > 1){
                throw new CustomException('Multiple active employee records found, please contact IT Admin.');
            }else if(empl.size() == 0){
                throw new CustomException('No active employee record available, please contact IT Admin.');
            }else if(String.isBlank(empl[0].BU_Head__c)){
                throw new CustomException('BU Head/CCM detail is missing, please contact IT Admin.');
            }else{
                return empl[0];
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void raiseResignation(String employeeId, String addedById, String reason, String remarks) {
        Employee__c emp = [SELECT Id, Name, ReportingTo__r.SF_User__c, BU_Head__r.SF_User__c, SF_User__r.Email  FROM Employee__c WHERE Id = :employeeId];
        Resignation__c resignation = new Resignation__c();
        resignation.Employee_Name__c = employeeId;
        resignation.Added_By__c = addedById;
        resignation.Reason__c = reason;
        resignation.Remarks__c = remarks;
        resignation.Reporting_Manager__c = emp.ReportingTo__r.SF_User__c;
        resignation.CCM__c = emp.BU_Head__r.SF_User__c;
        resignation.Separation_Type__c = 'Resignation';
        resignation.Resignation_Status__c = 'Applied';
        resignation.Date_of_Resignation__c = System.now().date();
        try {
            insert as system resignation;
            submitForApproval(resignation.Id,UserInfo.getUserId());
            emp.Status__c = 'Resignation in process';
            update as system emp;
            System.debug('Resignation Record Created');
            // Email
        } catch (Exception e) {
            throw new AuraHandledException('An error occurred while creating the resignation record: ' + e.getMessage());
        }
    }
    
    public static void sendEmailAfterRaising(Employee__c raisingEmp, Resignation__c resig){
        
    }
    
    public static void submitForApproval(String resId, String submitterId){
        Approval.ProcessSubmitRequest apprReq = new Approval.ProcessSubmitRequest();
        apprReq.setComments('Resignation Submitted');
        apprReq.setObjectId(resId);
        apprReq.setSubmitterId(submitterId);
        apprReq.setProcessDefinitionNameOrId('Resignation_Approval_V2');
        apprReq.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(apprReq);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Resignation__c> getMyResignationRecords(){
        return [SELECT Id, Name, Employee_ID__c, Employee_Name__c, Employee_Name__r.Name, Title__c, Department__c, Reason__c, Resignation_Status__c , Remarks__c, Added_Time__c,Location__c, Reporting_To__c,
                Cost_Center_Manager__c, Date_of_Joining__c, Added_By__r.Name, Separation_Type__c, Date_of_Resignation__c, Last_Working_Date__c,Final_Relieving_Date__c, Reason_for_Pullback__c
                FROM Resignation__c WHERE Employee_Name__r.SF_User__c = :UserInfo.getUserId() ORDER BY CreatedDate DESC];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Resignation__c> getTeamResignationRecords(){
        return [SELECT Id, Name, Employee_ID__c, Employee_Name__c, Employee_Name__r.Name, Title__c, Department__c, Reason__c, Resignation_Status__c , Remarks__c, Added_Time__c,Location__c, Reporting_To__c, Reporting_Manager__c,
                Cost_Center_Manager__c, CCM__c, Date_of_Joining__c, Added_By__r.Name, Separation_Type__c, Date_of_Resignation__c, Last_Working_Date__c,Final_Relieving_Date__c, Reason_for_Pullback__c
                FROM Resignation__c WHERE Reporting_Manager__c = :UserInfo.getUserId() OR CCM__c = :UserInfo.getUserId() ORDER BY CreatedDate DESC];       
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Resignation__c> getAllResignationRecords(){
        return [SELECT Id, Name, Employee_ID__c, Employee_Name__c, Employee_Name__r.Name, Title__c, Department__c, Reason__c, Resignation_Status__c , Remarks__c, Added_Time__c,Location__c, Reporting_To__c, Reporting_Manager__c,
                Cost_Center_Manager__c, CCM__c, Date_of_Joining__c, Added_By__r.Name, Separation_Type__c, Date_of_Resignation__c, Last_Working_Date__c,Final_Relieving_Date__c, Reason_for_Pullback__c
                FROM Resignation__c ORDER BY CreatedDate DESC];       
    }
    
    @AuraEnabled(cacheable=true)
    public static String checkHR(){
        try{
            Group grpHR = [SELECT Id, DeveloperName FROM Group WHERE DeveloperName = 'HR_Team' WITH SYSTEM_MODE LIMIT 1];
            List<GroupMember> grpMember = [SELECT Id FROM GroupMember WHERE GroupId = :grpHR.Id AND UserOrGroupId = :UserInfo.getUserId() WITH SYSTEM_MODE];
            if(grpMember.size() > 0){
                return 'Yes';
            }
            return 'No';
        }catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    @AuraEnabled
    public static void approverActions(String actionBtnLabel, String recId, String comment, String relation, String relievingString, String resignEmp){
        System.debug(actionBtnLabel);
        System.debug(comment);
        System.debug(recId);
        System.debug(relation);
        Date relievingDate;
        if(String.isNotBlank(relievingString)){
            relievingDate = Date.valueOf(relievingString);
        }
        
        System.debug(relievingDate);
        System.debug(resignEmp);
        ProcessDefinition processDef = [SELECT Id FROM ProcessDefinition WHERE DeveloperName = 'Resignation_Approval_V2' LIMIT 1];
        List<Approval.ProcessWorkitemRequest> allProcessReq = new List<Approval.ProcessWorkitemRequest>();
        List<ProcessInstanceWorkitem> currWorkItem = [SELECT Id, ProcessInstance.TargetObjectId, ProcessInstance.Status, OriginalActorId, 
                                                       ProcessInstance.ProcessDefinitionId FROM ProcessInstanceWorkitem WHERE ProcessInstance.ProcessDefinitionId = :processDef.Id AND OriginalActorId = :UserInfo.getUserId() AND ProcessInstance.TargetObjectId = :recId];
        for(ProcessInstanceWorkitem eachWorkItem : currWorkItem){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction(actionBtnLabel);
            req.setWorkitemId(eachWorkItem.Id);
            req.setComments(comment);
            allProcessReq.add(req);
        }
        Schema.Resignation__c resg = new Schema.Resignation__c(Id=recId);
        Schema.Employee__c emp = new Schema.Employee__c(Id=resignEmp);
        if(relation == 'Manager'){
            resg.Comments_by_Reporting_Manager__c = comment;
        }else if(relation == 'CCM'){
            resg.Comments_by_CCM__c = comment;
        }else if(relation == 'HR'){
            resg.Final_Relieving_Date__c = relievingDate;
        }
        if(relation == 'Manager' && actionBtnLabel == 'Approve'){
            resg.Resignation_Status__c = 'Approved by Reporting Manager';
        }else if(relation == 'Manager' && actionBtnLabel == 'Reject'){
            emp.Status__c = 'Active';
            resg.Resignation_Status__c = 'Rejected by Reporting Manager';
        }else if(relation == 'CCM' && actionBtnLabel == 'Approve'){
            resg.Resignation_Status__c = 'Approved by CCM';
        }else if(relation == 'CCM' && actionBtnLabel == 'Reject'){
            emp.Status__c = 'Active';
            resg.Resignation_Status__c = 'Rejected by CCM';
        }else if(relation == 'HR' && actionBtnLabel == 'Approve'){
            emp.Status__c = 'Relieved';
            resg.Resignation_Status__c = 'Resignation Processed';
        }else if(relation == 'HR' && actionBtnLabel == 'Reject'){
            emp.Status__c = 'Active';
            resg.Resignation_Status__c = 'Rejected by HR';
        }
        System.debug(resg);
        update as system resg;
        System.debug(emp);
        update as system emp;
        List<Approval.ProcessResult> result = Approval.process(allProcessReq);
    }
    
    @AuraEnabled
    public static Resignation__c pullbackResignation(String recId, String pullbackReason, String empId){
        System.debug(empId);
        ProcessDefinition processDef = [SELECT Id FROM ProcessDefinition WHERE DeveloperName = 'Resignation_Approval_V2' LIMIT 1];
        List<Approval.ProcessWorkitemRequest> allProcessReq = new List<Approval.ProcessWorkitemRequest>();
        List<ProcessInstanceWorkitem>  currWorkItem = [SELECT Id, ProcessInstance.TargetObjectId, ProcessInstance.Status, OriginalActorId, 
                                                       ProcessInstance.ProcessDefinitionId FROM ProcessInstanceWorkitem WHERE ProcessInstance.ProcessDefinitionId = :processDef.Id];
        for(ProcessInstanceWorkitem eachWorkItem : currWorkItem){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction('Removed');
            req.setWorkitemId(eachWorkItem.Id);
            req.setComments(pullbackReason);
            allProcessReq.add(req);
        }
        List<Approval.ProcessResult> result = Approval.process(allProcessReq);
        Schema.Resignation__c resg = new Schema.Resignation__c(Id=recId);
        resg.Reason_for_Pullback__c = pullbackReason;
        resg.Resignation_Status__c = 'Withdrawn';
        Schema.Employee__c emp = new Schema.Employee__c(Id=empId);
        emp.Status__c = 'Active';
        try{
            update as system resg;
            update as system emp;
            return resg;   
        }catch (Exception e) {
            System.debug(e);
            throw new AuraHandledException('An error occurred while pulling back the resignation record: ' + e.getMessage());
        }
    }
}