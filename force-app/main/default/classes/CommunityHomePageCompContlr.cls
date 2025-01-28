public with sharing class CommunityHomePageCompContlr {
    
    @AuraEnabled
    public static List<Project__c> getProjectList(){
        date fifteenthdate = Date.today()+15;
        date today = Date.today();
        system.debug('fifteenthdate>>>>>'+fifteenthdate);
      //  List<Project__c> projectDetailList =[select id,Name,StartDate__c,EndDate__c,Status__c,ProjectManager__c,ProjectManager__r.Name from Project__c where EndDate__c >=:today AND EndDate__c <=:fifteenthdate];
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,
                                                                            [select id,Name,StartDate__c,EndDate__c,Status__c,
                                                                             ProjectManager__c,ProjectManager__r.Name from Project__c 
                                                                             where EndDate__c >=:today AND EndDate__c <=:fifteenthdate]
                                                                           );
        List<Project__c> projectDetailList =securityDecision.getRecords();
        system.debug('projectDetailList???'+projectDetailList);
        return projectDetailList;
    }
    
    @AuraEnabled
    public static List<TeamAllocation__c> getTeamAllocationList(){
        date fifteenthdate = Date.today()+15;
        date today = Date.today();
        system.debug('fifteenthdate>>>>>'+fifteenthdate);
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,[select id,Name,StartDate__c,EndDate__c,Billing_Status__c,EmployeeName__c,EmployeeName__r.Name,ReportingTo__c,ReportingTo__r.Name,Project__c,Project__r.Name from
                                                                                                 TeamAllocation__c where EndDate__c >=:today AND EndDate__c <=:fifteenthdate]);
        List<TeamAllocation__c> TADetailList =securityDecision.getRecords();
        system.debug('TADetailList???'+TADetailList);
        return TADetailList;
    }
    @AuraEnabled
    public static List<SupportRequest__c> getSupportRequestList(){
        date Seventhdate = Date.today()+7;
        date today = Date.today();
        system.debug('Seventhdate>>>>>'+Seventhdate);
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, [select id,Name,
RequestOwnedBy__c,Requested_By__c,Project__c,Project__r.Name,SolutionType__c,Status__c,Priority__c,DueDate__c 
from SupportRequest__c where DueDate__c >=:today AND DueDate__c >=:Seventhdate]);
        List<SupportRequest__c> SRDetailList=securityDecision.getRecords();
        
        system.debug('SRDetailList???'+SRDetailList);
        return SRDetailList;
    }
    
    @AuraEnabled
    public static List<TeamAllocation__c> getTAwithoutKPIList(){
        Date currentDate = System.today();
         SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,
        [select id,Name,StartDate__c,EndDate__c,Billing_Status__c,EmployeeName__c,EmployeeName__r.Name,
         ReportingTo__c,ReportingTo__r.Name,Project__c,Project__r.Name,
         (select id,name from Project_KPIs__r) from TeamAllocation__c where EndDate__c > 2020-12-31 and EndDate__c < :currentDate]);
        List<TeamAllocation__c> proj =securityDecision.getRecords();
        system.debug('proj????'+proj.size());
        List<TeamAllocation__c> projectwithoutKPIsList = new List<TeamAllocation__c>();
        for(TeamAllocation__c	 projdetails : proj){
            if(projdetails.Project_KPIs__r.size() ==0){
                projectwithoutKPIsList.add(projdetails);
            }
            
            //system.debug(projdetails.Support_Requests__r.size());
        }
        system.debug('projectwithoutKPIsList????'+projectwithoutKPIsList.size());
        return projectwithoutKPIsList;
    }
    @AuraEnabled
    public static List<SupportRequest__c> getEmployeeSRInprogress(String employeeId){
        system.debug('employeeId?????'+employeeId);
        Employee__c employeeRec = [select id,SF_User__c from Employee__c where id=:employeeId];
        system.debug('employeeRec???'+employeeRec);
         SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, [select id,Name,RequestOwnedBy__c,Requested_By__c,Project__c,Project__r.Name,SolutionType__c,Status__c,Priority__c,DueDate__c from SupportRequest__c 
                                                                                                   where Requested_By__c =:employeeRec.SF_User__c and Status__c ='In-Progress']);
        List<SupportRequest__c> employeeSRInProgressList =securityDecision.getRecords();
        system.debug('employeeSRInProgressList???'+employeeSRInProgressList);
        return employeeSRInProgressList;
    }
     @AuraEnabled
    public static List<SupportRequest__c> getEmployeeSRComplete(String employeeId){
        Employee__c employeeRec = [select id,SF_User__c from Employee__c where id=:employeeId];
        system.debug('employeeRec???'+employeeRec);
      SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,  [select id,Name,
RequestOwnedBy__c,Requested_By__c,Project__c,Project__r.Name,SolutionType__c,Status__c,Priority__c,DueDate__c
from SupportRequest__c where Requested_By__c =:employeeRec.SF_User__c and Status__c ='Completed']);
        
        List<SupportRequest__c> employeeSRCompleteList =securityDecision.getRecords(); 
        system.debug('employeeSRCompleteList???'+employeeSRCompleteList);
        return employeeSRCompleteList;
    }
    
    @AuraEnabled
    public static List<TeamAllocation__c> getTeamAllocationwithoutKPIs(string employeeId){
        Date currentDate = System.today();
       SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,  [SELECT 
Id,Name,StartDate__c,EndDate__c,Project__c,Project__r.Name,(select id,name from Project_KPIs__r) FROM TeamAllocation__c WHERE EmployeeName__c =:employeeId and EndDate__c > 2020-12-31 and EndDate__c < :currentDate]); 
        List<TeamAllocation__c> TAwithoutKPIs =securityDecision.getRecords();
            system.debug('TAwithoutKPIs????'+TAwithoutKPIs.size());
        List<TeamAllocation__c> projectwithoutKPIsList = new List<TeamAllocation__c>();
        for(TeamAllocation__c	 TAdetails : TAwithoutKPIs){
            if(TAdetails.Project_KPIs__r.size() ==0){
                projectwithoutKPIsList.add(TAdetails);
            }
            
            //system.debug(projdetails.Support_Requests__r.size());
        }
        system.debug('projectwithoutKPIsList????'+projectwithoutKPIsList.size());
        return projectwithoutKPIsList;
    }
    
    @AuraEnabled
    public static List<TeamAllocation__c> getTeamAllocationwithKPIs(string employeeId){
       SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE, 
[SELECT Id,Name,StartDate__c,EndDate__c,Project__c,Project__r.Name,(select id,name from Project_KPIs__r) 
 FROM TeamAllocation__c WHERE EmployeeName__c =:employeeId]); 
        List<TeamAllocation__c> TAwithKPIs =securityDecision.getRecords();
        system.debug('TAwithKPIs????'+TAwithKPIs.size());
        List<TeamAllocation__c> projectwithtKPIsList = new List<TeamAllocation__c>();
        for(TeamAllocation__c	 TAdetails : TAwithKPIs){
            if(TAdetails.Project_KPIs__r.size() >0){
                projectwithtKPIsList.add(TAdetails);
            }
            
            //system.debug(projdetails.Support_Requests__r.size());
        }
        system.debug('projectwithoutKPIsList????'+projectwithtKPIsList.size());
        return projectwithtKPIsList;
    }
    
    
}