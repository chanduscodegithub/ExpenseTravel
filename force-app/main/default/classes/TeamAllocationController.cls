/*------------------------------------------------------------------------------------
Author:        Paras Prajapati
Description:   This class will be used in Project Detail Componnent and My Last Year Allocation.
Date : 21 April 2020

History
Date            Author             Comments
--------------------------------------------------------------------------------------

------------------------------------------------------------------------------------*/
public without sharing class TeamAllocationController {
    public class ProjectData{
        @AuraEnabled
        public String id;
    }

    public class TeamAllocationData{
        @AuraEnabled
        public String projectName;
        @AuraEnabled
        public Date startDate;
        @AuraEnabled
        public Date endDate;
        @AuraEnabled
        public String  billableStatus;
        @AuraEnabled
        public Decimal allocation;
        @AuraEnabled
        public String id;
    }

    @AuraEnabled(cacheable=true)
    public static ProjectData findProject(String teamAllocationRecordId) {
        System.debug('teamAllocationRecordId' + teamAllocationRecordId);
        ProjectData projectData = new ProjectData();
        if(teamAllocationRecordId!=null){
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,[Select id,Project__c,Project__r.Name,Project__r.Region__c,Project__r.Opportunity__r.Name,
            Project__r.StartDate__c,Project__r.EndDate__c,Project__r.Status__c from TeamAllocation__c where id =:teamAllocationRecordId ]);
            List<TeamAllocation__c> listOfTeamAllocation = securityDecision.getRecords();
            /*List<TeamAllocation__c> listOfTeamAllocation= [Select id,Project__c,Project__r.Name,Project__r.Region__c,Project__r.Opportunity__r.Name,
            Project__r.StartDate__c,Project__r.EndDate__c,Project__r.Status__c from TeamAllocation__c where id =:teamAllocationRecordId ];*/
            if(!listOfTeamAllocation.isEmpty()){
                TeamAllocation__c teamAllocationRecord = listOfTeamAllocation.get(0);
                projectData.id = teamAllocationRecord.Project__c;
            }
        }
        return projectData;
    }

    @AuraEnabled(cacheable=true)
    public static List<TeamAllocation__c> findAllLastYearAllocated(String teamAllocationRecordId) {
        List<TeamAllocationData> listOfTeamAllocationData=new List<TeamAllocationData>();
        List<TeamAllocation__c> relatedTeamAllocationRecods = new List<TeamAllocation__c>();
        List<TeamAllocation__c> listOfTeamAllocation= [Select id,EmployeeName__c from TeamAllocation__c where id =:teamAllocationRecordId ];
        if(!listOfTeamAllocation.isEmpty()){
            String employeeid = listOfTeamAllocation.get(0).EmployeeName__c;
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,[Select id,Project__c,Project__r.Name,AllocationPercentage__c,StartDate__c, EndDate__c,
            Billing_Status__c ,EmployeeName__c from TeamAllocation__c where EmployeeName__c =:employeeid AND   StartDate__c = LAST_N_DAYS: 730 AND
            StartDate__c < LAST_N_DAYS: 1]);
            relatedTeamAllocationRecods = securityDecision.getRecords();
            /*relatedTeamAllocationRecods= [Select id,Project__c,Project__r.Name,AllocationPercentage__c,StartDate__c, EndDate__c,
            Billing_Status__c ,EmployeeName__c from TeamAllocation__c where EmployeeName__c =:employeeid AND   StartDate__c = LAST_N_DAYS: 730 AND
            StartDate__c < LAST_N_DAYS: 1];*/
       }
      return relatedTeamAllocationRecods;
    }

    @AuraEnabled(cacheable=true)
    public static List<TeamAllocation__c> myActiveTeamAllocationRecords(String teamAllocationRecordId) {
        List<TeamAllocationData> listOfTeamAllocationData=new List<TeamAllocationData>();
        List<TeamAllocation__c> relatedTeamAllocationRecods = new List<TeamAllocation__c>();
        List<TeamAllocation__c> listOfTeamAllocation= [Select id,EmployeeName__c from TeamAllocation__c where id =:teamAllocationRecordId ];
        if(!listOfTeamAllocation.isEmpty()){
            String employeeid = listOfTeamAllocation.get(0).EmployeeName__c;
            String currentTeamAllocationId= listOfTeamAllocation.get(0).Id;
            SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,[Select id,Project__c,Project__r.Name,AllocationPercentage__c,StartDate__c, EndDate__c,
            Billing_Status__c ,EmployeeName__c from TeamAllocation__c where Active__c=true AND  EmployeeName__c =:employeeid AND ID!=:currentTeamAllocationId]);
            relatedTeamAllocationRecods = securityDecision.getRecords();
            /*relatedTeamAllocationRecods= [Select id,Project__c,Project__r.Name,AllocationPercentage__c,StartDate__c, EndDate__c,
            Billing_Status__c ,EmployeeName__c from TeamAllocation__c where Active__c=true AND  EmployeeName__c =:employeeid AND ID!=:currentTeamAllocationId];*/
       }
      return relatedTeamAllocationRecods;
    }

    @AuraEnabled
    public static List<TeamAllocation__c> myActiveProject(String employeeId,string whatProjects) {
        System.debug('whatprojects' + whatprojects);
        List<TeamAllocation__c> relatedTeamAllocationRecods = new List<TeamAllocation__c>();
        if(whatProjects=='myActiveProject'){
        relatedTeamAllocationRecods= [Select id,Project__c,Project__r.Name,AllocationPercentage__c,StartDate__c, EndDate__c,
            Billing_Status__c ,EmployeeName__c from TeamAllocation__c where Active__c=true AND  EmployeeName__c =:employeeid ];
        }else if(whatProjects=='myBillableProject'){
            relatedTeamAllocationRecods= [Select id,Project__c,Project__r.Name,AllocationPercentage__c,StartDate__c, EndDate__c, Billing_Status__c ,EmployeeName__c 
            from TeamAllocation__c where Billing_Status__c='Billable' AND  EmployeeName__c =:employeeid AND StartDate__c = LAST_N_DAYS: 730];
        }else if(whatProjects=='myNonBillableProject'){
            relatedTeamAllocationRecods= [Select id,Project__c,Project__r.Name,AllocationPercentage__c,StartDate__c, EndDate__c, Billing_Status__c ,EmployeeName__c 
            from TeamAllocation__c where Billing_Status__c!='Billable' AND  EmployeeName__c =:employeeid AND StartDate__c = LAST_N_DAYS: 730];
        }
        
      return relatedTeamAllocationRecods;
    }

    @AuraEnabled
    public static List<TeamAllocation__c> myBillableProject(String employeeId) {
        List<TeamAllocation__c> relatedTeamAllocationRecods = new List<TeamAllocation__c>();
         
      return relatedTeamAllocationRecods;
    }
    
    @AuraEnabled
    public static String retrieveCommunityURL(){
        try {
            return ConnectApi.Communities.getCommunity(Network.getNetworkId()).siteUrl;
        } catch (Exception er) {
            throw new AuraHandledException(er.getMessage());
        }
    }
        
}