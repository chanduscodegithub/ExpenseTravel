public with sharing class ResignationTestDataFactory {
    public static Resignation__c createResignation(String reason, String remarks){
        // List<User> sfUser = [SELECT Id FROM User WHERE Id != :UserInfo.getUserId() AND IsActive = true AND Id IN ('005DX000009o3yjYAA','0051K00000Ai8lsQAB') WITH SYSTEM_MODE];
        User uReporting = [SELECT Id FROM User WHERE Email = 'aneesh.vemireddy@crmit.com' LIMIT 1];
        User uCCM = [SELECT Id FROM User WHERE Email = 'tamanna.singh+pms@crmit.com' LIMIT 1];
        Employee__c currEmployee = [SELECT Id, SF_User__c FROM Employee__c WHERE SF_User__c = :UserInfo.getUserId() AND Active__c = true WITH SYSTEM_MODE LIMIT 1];
        Employee__c otherEmployee = [SELECT Id, SF_User__c FROM Employee__c WHERE SF_User__c != :UserInfo.getUserId() AND Active__c = true WITH SYSTEM_MODE LIMIT 1];
        Resignation__c res = new Resignation__c();
        res.Employee_Name__c = currEmployee.Id;
        res.Added_By__c = otherEmployee.Id;
        res.Reporting_Manager__c = uReporting.Id; // sfUser[0].Id;
        res.CCM__c = uCCM.Id; // sfUser[1].Id;
        res.Remarks__c = remarks;
        res.Reason__c = reason;
        res.Separation_Type__c = 'Resignation';
        res.Resignation_Status__c = 'Applied';
        res.Date_of_Resignation__c = System.now().date();
        try{
            insert res;
            return res;
        }
        catch (Exception e){
            throw new AuraHandledException('An error occurred while creating the resignation record: ' + e.getMessage());
        }
    }
    
    
    public static void submitForApproval(Resignation__c res, Id submitterId){
        Approval.ProcessSubmitRequest apprReq = new Approval.ProcessSubmitRequest();
        apprReq.setComments('Resignation Submitted');
        apprReq.setObjectId(res.id);
        apprReq.setSubmitterId(submitterId);
        apprReq.setProcessDefinitionNameOrId('Resignation_Approval_V2');
        apprReq.setSkipEntryCriteria(true);
        Approval.ProcessResult result = Approval.process(apprReq);
    }
    
    public static Resignation__c recallRecord(String recId, String reason){
         System.debug(recId);
         System.debug(reason);
        ProcessDefinition processDef = [SELECT Id FROM ProcessDefinition WHERE DeveloperName = 'Resignation_Approval_V2' LIMIT 1];
        List<Approval.ProcessWorkitemRequest> allProcessReq = new List<Approval.ProcessWorkitemRequest>();
        // List<ProcessInstanceWorkitem>  currWorkItem = [SELECT Id, ProcessInstance.TargetObjectId, ProcessInstance.Status, OriginalActorId, 
        // ProcessInstance.ProcessDefinitionId FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId = :recId 
        // AND ProcessInstance.Status = 'Pending' AND OriginalActorId = :UserInfo.getUserId() AND ProcessInstance.ProcessDefinitionId = :processDef.Id];
        List<ProcessInstanceWorkitem>  currWorkItem = [SELECT Id, ProcessInstance.TargetObjectId, ProcessInstance.Status, OriginalActorId, 
                 ProcessInstance.ProcessDefinitionId FROM ProcessInstanceWorkitem WHERE ProcessInstance.ProcessDefinitionId = :processDef.Id];
        for(ProcessInstanceWorkitem eachWorkItem : currWorkItem){
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setAction('Removed');
            req.setWorkitemId(eachWorkItem.Id);
            req.setComments(reason);
            allProcessReq.add(req);
        }
        
        List<Approval.ProcessResult> result = Approval.process(allProcessReq);
        Schema.Resignation__c resg = new Schema.Resignation__c(Id=recId);
		resg.Reason_for_Pullback__c = reason;
        resg.Resignation_Status__c = 'Withdrawn';
        System.debug(resg);
        try{
            update resg;
            System.debug(resg.Resignation_Status__c);
            return resg;
            
        }catch (Exception e){
            throw new AuraHandledException('An error occurred while pulling back the resignation record: ' + e.getMessage());
        }
        
    }
    
}