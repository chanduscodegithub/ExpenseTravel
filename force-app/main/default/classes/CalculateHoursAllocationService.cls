/*------------------------------------------------------------------------------------
Author:        Paras Prajapati
Description:   CalculateHoursAllocationService class to Calculate Team Billable Hours and Total Hours

History
Date            Author             Comments
--------------------------------------------------------------------------------------

------------------------------------------------------------------------------------*/
public class CalculateHoursAllocationService {
    
     /*----------------------------------------------------------
@description Method calculate > Hours_Allocated__c and Billable_Hours_Allocated__c 
@param teamAllocationRecords - Set Of TeamAllocation__c Records which need to be processed.
------------------------------------------------------------*/  
    public static void calculateHoursAllocated(List<TeamAllocation__c> teamAllocationRecords){
        Set<Date> holidaysSet = getHolidays();  
        if(!teamAllocationRecords.isempty()){
            for(TeamAllocation__c teamAllocation : teamAllocationRecords){
                if(teamAllocation.Active__c || Date.today()<teamAllocation.StartDate__c){
                   updateHours(teamAllocation,holidaysSet);
                }
            }
        }
    }
    
    /*----------------------------------------------------------
@description Method to Hours_Allocated__c and Billable_Hours_Allocated__c
@param newItems - Set Of TeamAllocation__c Records which are updated.
@param oldItems - Set Of TeamAllocation__c Records which are updated and have old values.
------------------------------------------------------------*/
    public static void calculateAllocatedHoursOnUpdate(Map<Id, TeamAllocation__c> newItems, Map<Id, TeamAllocation__c> oldItems) {
        Set<Date> holidaysSet = getHolidays();
        for(Id teamAllocationtId : newItems.keySet()){
            TeamAllocation__c newTeamAllocation = newItems.get(teamAllocationtId);
            TeamAllocation__c oldTeamAllocation = oldItems.get(teamAllocationtId);
            if((newTeamAllocation.AllocationPercentage__c != oldTeamAllocation.AllocationPercentage__c) || 
               (newTeamAllocation.StartDate__c != oldTeamAllocation.StartDate__c) || (newTeamAllocation.EndDate__c != oldTeamAllocation.EndDate__c) || (newTeamAllocation.Billing_Status__c != oldTeamAllocation.Billing_Status__c) ){
                if(newTeamAllocation.Active__c || Date.today()<newTeamAllocation.StartDate__c){
                   updateHours(newTeamAllocation,holidaysSet);
                }
            }
        }
    }
    /*----------------------------------------------------------
@description Method  utility method which will be called to set working Hours allocated an Billing hours allocated.
@param teamAllocation - Set Of TeamAllocation__c Records which will be updated.
------------------------------------------------------------*/
    public Static void updateHours(TeamAllocation__c teamAllocation,Set<Date> holidaysSet){  
        Integer numberOfWorkingDays = calculateWorkingDays(teamAllocation.StartDate__c,teamAllocation.EndDate__c,holidaysSet);
        Decimal allocationPercentage = teamAllocation.AllocationPercentage__c!=null?teamAllocation.AllocationPercentage__c:0;
        Decimal workingHours = (numberOfWorkingDays*8*allocationPercentage)/100;
        teamAllocation.Hours_Allocated__c = workingHours;
        if(teamAllocation.Billing_Status__c=='Billable'){
            teamAllocation.Billable_Hours_Allocated__c=workingHours;
        }else{
            teamAllocation.Billable_Hours_Allocated__c=0.0;
        }
    }
   /*----------------------------------------------------------
@description Method  utility method to find holiday and find working days from start to end date
@param startDate - Start Date if Team allocation record
@param endDate - End Date if Team allocation record
------------------------------------------------------------*/
    public static Integer calculateWorkingDays(Date startDate, Date endDate,Set<Date> holidaysSet){          
        Integer workingDays = 0; 
        Integer workingHours = 0;
        for(integer i=0; i <= startDate.daysBetween(endDate); i++) {  
            Date dt = startDate + i;  
            DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());  
            String todayDay = currDate.format('EEEE');  
            if(todayDay != 'Saturday' && todayDay !='Sunday' && (!holidaysSet.contains(dt))){  
              workingDays = workingDays + 1;  
            }
        }  
        return workingDays;  
    }  
    
    /*----------------------------------------------------------
@description Method to get all Company Holiday
@return Set<Date> - unique list of holiday dates
------------------------------------------------------------*/
    public Static Set<Date> getHolidays(){
        Set<Date> holidaysSet = new Set<Date>();  
        for(Holiday currHoliday : [select id, name, ActivityDate FROM Holiday]){  
            holidaysSet.add(currHoliday.ActivityDate);  
        } 
        return holidaysSet;
    }
}