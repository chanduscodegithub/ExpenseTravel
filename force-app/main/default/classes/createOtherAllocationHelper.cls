public without sharing class createOtherAllocationHelper {
    public static void createTA(List<TeamAllocation__c> allTeamAllocations){
        Date endDate = Date.newInstance(System.Today().year(), 12, 31);
        Date startDate = Date.newInstance(2022, 03, 27);
        try{
            Project__c otherProject = [SELECT Id, Name FROM Project__c WHERE Name='Others' limit 1];
            System.debug('Other Id: '+otherProject.Id);
            //List<TeamAllocation__c> allTeamAllocations = [SELECT Name, EmployeeName__c, EmployeeName__r.Name FROM TeamAllocation__c WHERE EndDate__c > :startDate ];
            Set<Id> allEmployees = new Set<Id>();
            for(TeamAllocation__c eachAlloc: allTeamAllocations){
                //System.debug('Each Employee: '+eachAlloc.EmployeeName__r.Name);
                allEmployees.add(eachAlloc.EmployeeName__c);
            }
            List<TeamAllocation__c> eligibleTeamAllocations = [SELECT Name, EmployeeName__c, Project__c FROM TeamAllocation__c WHERE EmployeeName__c IN :allEmployees];
            for(TeamAllocation__c eachAlloc: eligibleTeamAllocations){
                if(eachAlloc.Project__c == otherProject.Id){
                    if(allEmployees.contains(eachAlloc.EmployeeName__c)){
                    	allEmployees.remove(eachAlloc.EmployeeName__c);
                	}
                }
            }
            Map<Id, Employee__c> empMap = new Map<Id, Employee__c>([SELECT ReportingTo__r.SF_User__c, Name, ReportingTo__r.Name FROM Employee__c WHERE Id IN :allEmployees]);
            List<TeamAllocation__c> newTA = new List<TeamAllocation__c>();
            for(Id empId: allEmployees){
                System.debug('New TA for: '+empMap.get(empId).Name+' whose Id: '+empId);
                System.debug('and whose manager is: '+empMap.get(empId).ReportingTo__r.Name);
                TeamAllocation__c eachNewTA = new TeamAllocation__c(EmployeeName__c=empId, Project__c=otherProject.Id, StartDate__c=startDate, EndDate__c=endDate, Billing_Status__c='Non Billable', ReportingTo__c = empMap.get(empId).ReportingTo__r.SF_User__c, AllocationPercentage__c=1);
                newTA.add(eachNewTA);
            }
            Database.UpsertResult[] upsertList = Database.upsert(newTA, false);
            for(Database.UpsertResult eachUpsert : upsertList) {
            	if (eachUpsert.isSuccess()) {
                	System.debug('Successfully deleted account with ID: ' + eachUpsert.getId());
            	}
            	else {             
                    for(Database.Error err : eachUpsert.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('TA fields that affected this error: ' + err.getFields());
                    }
            	}
            }
        }catch(Exception e){
            System.debug('Exception: '+e.getMessage());
            System.debug('At: '+e.getLineNumber());
        }
    }
}