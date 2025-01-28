/*------------------------------------------------------------------------------------
Author:        Paras Prajapati
Description:   TeamAllocation__c Handler Class.

History
Date            Author             Comments
--------------------------------------------------------------------------------------

------------------------------------------------------------------------------------*/
public class TeamAllocationTriggerHandler { 
    public static void BeforeTeamAllocationInsert(List<TeamAllocation__c> teamAllocationRecords){
        CalculateHoursAllocationService.calculateHoursAllocated(teamAllocationRecords);
        TeamEmployeeRateService.insertEmployeeRate(teamAllocationRecords);
    }
    public static void BeforeTeamAllocationUpdate(Map<Id, TeamAllocation__c> newItems, Map<Id, TeamAllocation__c> oldItems) {
        CalculateHoursAllocationService.calculateAllocatedHoursOnUpdate(newItems,oldItems);
    }
    public static void afterTeamAllocationInsert(Map<Id,TeamAllocation__c> teamAllocationMap){
        //Get all employees from the Team Allocation
        List<Id> employees = new List<Id>();
        for(Id teamId : teamAllocationMap.keySet()){
            employees.add(teamAllocationMap.get(teamId).EmployeeName__c);
        }
        EmployeeBillableStatusService.updateEmployee(employees,teamAllocationMap);
    }
    /*
	* Update Employee Status if required whenever Team Allocation is updated.
	*/
    public static void afterTeamAllocationUpdate(Map<Id,TeamAllocation__c> teamAllocationMap,Map<Id,TeamAllocation__c> oldMap){
        //Get all employees from the Team Allocation
        List<Id> employees = new List<Id>();
        for(Id teamId : teamAllocationMap.keySet()){
            if(		(teamAllocationMap.get(teamId).Active__c != oldMap.get(teamId).Active__c)
               ||	(teamAllocationMap.get(teamId).Billing_Status__c != oldMap.get(teamId).Billing_Status__c)
               ||	(teamAllocationMap.get(teamId).AllocationPercentage__c != oldMap.get(teamId).AllocationPercentage__c)
               ||	(teamAllocationMap.get(teamId).Batch_Status__c != oldMap.get(teamId).Batch_Status__c)
              )
            {
                employees.add(teamAllocationMap.get(teamId).EmployeeName__c);
            }
        }
        EmployeeBillableStatusService.updateEmployee(employees,teamAllocationMap);
    }
  public static void preventUpdateifTSAttached(Map<Id,TeamAllocation__c> teamAllocationMap,Map<Id,TeamAllocation__c> oldMap){
        Set<String> toPreventTAIds = new Set<String>();
        for(String eachTAId : teamAllocationMap.keySet()){
            if(    (teamAllocationMap.get(eachTAId).EndDate__c != oldMap.get(eachTAId).EndDate__c)
                || (teamAllocationMap.get(eachTAId).StartDate__c != oldMap.get(eachTAId).StartDate__c)
                || (teamAllocationMap.get(eachTAId).AllocationPercentage__c != oldMap.get(eachTAId).AllocationPercentage__c)
             ){
                toPreventTAIds.add(eachTAId);
            }
        }
        List<Timesheet_Utils__c> allUtils = [SELECT Team_Allocation__c FROM Timesheet_Utils__c WHERE Team_Allocation__c IN :toPreventTAIds];
        for(Timesheet_Utils__c eachExistingUtils: allUtils){
            teamAllocationMap.get(eachExistingUtils.Team_Allocation__c).addError('Cannot update Allocation attached to Timesheet, please clone the Team Allocation to extend');
        }
    }  

    public static void updateProjectCounts(List<TeamAllocation__c> teamAllocations) {
        Map<Id, Project__c> projectMap = new Map<Id, Project__c>();

        // Collect Project IDs from the new Team Allocation records
        for (TeamAllocation__c teamAlloc : teamAllocations) {
            if (teamAlloc.Project__c != null) {
                projectMap.put(teamAlloc.Project__c, null);
            }
        }

        // Query Project__c records with related Team Allocation records
        projectMap.putAll([
            SELECT Id, Billable_Count__c, Shadow_Count__c,
                (SELECT Billing_Status__c, AllocationPercentage__c FROM Team_Allocations__r)
            FROM Project__c
            WHERE Id IN :projectMap.keySet()
        ]);

        // Calculate weighted counts using AllocationPercentage__c
        for (Project__c project : projectMap.values()) {
            Decimal billableSum = 0;
            Decimal shadowSum = 0;

            for (TeamAllocation__c teamAlloc : project.Team_Allocations__r) {
                Decimal allocationPercentage = teamAlloc.AllocationPercentage__c != null ? teamAlloc.AllocationPercentage__c / 100 : 0;

                if (teamAlloc.Billing_Status__c == 'Billable' || teamAlloc.Billing_Status__c == 'Is Development') {
                    billableSum += allocationPercentage;
                } else if (teamAlloc.Billing_Status__c == 'Shadow Dev') {
                    shadowSum += allocationPercentage;
                }
            }

            // Update the weighted counts on the Project record
            project.Billable_Count__c = billableSum;
            project.Shadow_Count__c = shadowSum;
        }

        // Update the Project records
        update projectMap.values();
    }

}