/*------------------------------------------------------------------------------------
Author:        Sayath
Description:   EmployeeBillableStatusService - Calculate Billable Status and Allocations.

History
Date            Author             Comments
--------------------------------------------------------------------------------------

------------------------------------------------------------------------------------*/
public class EmployeeBillableStatusService {
     /*
	* Update Employee Status if required whenever Team Allocation is updated.
	*/
    public static void updateEmployee(List<Id> employees,Map<Id,TeamAllocation__c> teamAllocationMap){
        
        if(!employees.isEmpty()){
            Map<Id,Employee__c> employeesMap = new Map<Id,Employee__c>([SELECT Id, Name, BillingStatus__c 
                                                                        FROM Employee__C 
                                                                        WHERE ID IN :employees AND (Department__c = 'Delivery' OR Department__c = 'Quality Control')AND (BillingStatus__c!='Trainee (Freshers Only)' AND BillingStatus__c!='Management')]);
            //Map to store Team Allocations associated to each Employee
            Map<Id,List<TeamAllocation__c>> employeeTeamAllocationsMap = new Map<Id,List<TeamAllocation__c>>();
            for(TeamAllocation__c ta : [SELECT id, EmployeeName__c,Billing_Status__c, Active__c
                                        FROM TeamAllocation__c WHERE EmployeeName__c IN: employees])
            {
                if(employeeTeamAllocationsMap.containsKey(ta.EmployeeName__c)){
                    employeeTeamAllocationsMap.get(ta.EmployeeName__c).add(ta);
                }else{
                    employeeTeamAllocationsMap.put(ta.EmployeeName__c,new List<TeamAllocation__c>{ta});
                }
            }
            //check if any of the employees has in active
            
            for(TeamAllocation__c team : teamAllocationMap.values()){
                Boolean isActive = false;
                for(TeamAllocation__c ta : employeeTeamAllocationsMap.get(team.EmployeeName__c)){
                    if(ta.Active__c == true){
                        isActive = true;
                        break;
                    }
                }
                if(isActive == false && employeesMap.containsKey(team.EmployeeName__c)){
                   
                    employeesMap.get(team.EmployeeName__c).BillingStatus__c = 'Bench';
                }
            }
            //Aggregate queries on Team Allocation and Employee
            Map<Id,AggregateResult> billablePercentageMap = new Map<Id,AggregateResult>([SELECT EmployeeName__c Id, 
                                                                                        SUM(AllocationPercentage__c) percentage
                                                                                        FROM TeamAllocation__c 
                                                                                        WHERE Billing_Status__c = 'Billable' 
                                                                                         AND Active__c = TRUE
                                                                                        GROUP By EmployeeName__C]);
            Map<Id,AggregateResult> shadowPercentageMap = new Map<Id,AggregateResult>([SELECT EmployeeName__c Id, 
                                                                                      SUM(AllocationPercentage__c) percentage
                                                                                      FROM TeamAllocation__c 
                                                                                      WHERE Billing_Status__c = 'Shadow Dev'
                                                                                       AND Active__c = TRUE
                                                                                      GROUP By EmployeeName__C]);
            Map<Id,AggregateResult> trainingPercentageMap = new Map<Id,AggregateResult>([SELECT EmployeeName__c Id, 
                                                                                      SUM(AllocationPercentage__c) percentage
                                                                                      FROM TeamAllocation__c 
                                                                                      WHERE Billing_Status__c = 'On Training'
                                                                                       AND Active__c = TRUE
                                                                                      GROUP By EmployeeName__C]);
            Map<Id,AggregateResult> longLeavePercentageMap = new Map<Id,AggregateResult>([SELECT EmployeeName__c Id, 
                                                                                      SUM(AllocationPercentage__c) percentage
                                                                                      FROM TeamAllocation__c 
                                                                                      WHERE Billing_Status__c = 'Long Leave'
                                                                                       AND Active__c = TRUE
                                                                                      GROUP By EmployeeName__C]);
              Map<Id,AggregateResult> IsdevelopmentPercentageMap = new Map<Id,AggregateResult>([SELECT EmployeeName__c Id, 
                                                                                      SUM(AllocationPercentage__c) percentage
                                                                                      FROM TeamAllocation__c 
                                                                                      WHERE Billing_Status__c = 'IS Development'
                                                                                       AND Active__c = TRUE
                                                                                      GROUP By EmployeeName__C]);
               Map<Id,AggregateResult> IsManagementPercentageMap = new Map<Id,AggregateResult>([SELECT EmployeeName__c Id, 
                                                                                      SUM(AllocationPercentage__c) percentage
                                                                                      FROM TeamAllocation__c 
                                                                                      WHERE Billing_Status__c = 'Management'
                                                                                       AND Active__c = TRUE
                                                                                      GROUP By EmployeeName__C]);
            
            for(Id empId : employeesMap.keySet()){
                if(billablePercentageMap.containsKey(empId)){
                    if((Decimal)billablePercentageMap.get(empId).get('percentage') >=100){
                        employeesMap.get(empId).CurrentBillable__c = (Decimal)billablePercentageMap.get(empId).get('percentage');
                        employeesMap.get(empId).BillingStatus__c = 'Billable';
                    }
                    else if(((Decimal)billablePercentageMap.get(empId).get('percentage') >0) && ((Decimal)billablePercentageMap.get(empId).get('percentage')<100))
                    {
                        employeesMap.get(empId).CurrentBillable__c = (Decimal)billablePercentageMap.get(empId).get('percentage');
                        employeesMap.get(empId).BillingStatus__c = 'Partial billable';
                    }
                }else if(IsdevelopmentPercentageMap.containsKey(empId)){
                    if((Decimal)IsdevelopmentPercentageMap.get(empId).get('percentage') > 0){
                        //employeesMap.get(empId).CurrentBillable__c = (Decimal)shadowPercentageMap.get(empId).get('percentage');
                        employeesMap.get(empId).CurrentBillable__c = (Decimal)IsdevelopmentPercentageMap.get(empId).get('percentage');
                        employeesMap.get(empId).BillingStatus__c = 'IS Development';
                 }
                    
                }else if(IsManagementPercentageMap.containsKey(empId)){
                    if((Decimal)IsManagementPercentageMap.get(empId).get('percentage') > 0){
        
                        employeesMap.get(empId).CurrentBillable__c = (Decimal)IsManagementPercentageMap.get(empId).get('percentage');
                        employeesMap.get(empId).BillingStatus__c = 'Management';
                 
                }
                }else if(shadowPercentageMap.containsKey(empId)){
                    if((Decimal)shadowPercentageMap.get(empId).get('percentage') > 0){
                        //employeesMap.get(empId).CurrentBillable__c = (Decimal)shadowPercentageMap.get(empId).get('percentage');
                        employeesMap.get(empId).CurrentBillable__c = 0;
                        employeesMap.get(empId).BillingStatus__c = 'Shadow Dev';
                    }
                }else if(trainingPercentageMap.containsKey(empId)){
                    if((Decimal)trainingPercentageMap.get(empId).get('percentage') > 0){
                        //employeesMap.get(empId).CurrentBillable__c = (Decimal)shadowPercentageMap.get(empId).get('percentage');
                        employeesMap.get(empId).CurrentBillable__c = 0;
                        employeesMap.get(empId).BillingStatus__c = 'On Training';
                    }
                }else if(longLeavePercentageMap.containsKey(empId)){
                    if((Decimal)longLeavePercentageMap.get(empId).get('percentage') > 0){
                        //employeesMap.get(empId).CurrentBillable__c = (Decimal)shadowPercentageMap.get(empId).get('percentage');
                        employeesMap.get(empId).CurrentBillable__c = 0;
                        employeesMap.get(empId).BillingStatus__c = 'Long Leave';
                    }
                }else{
                    employeesMap.get(empId).BillingStatus__c = 'Bench';
                    employeesMap.get(empId).CurrentBillable__c = 0;
                }
            }
            Database.update(employeesMap.values());
        }
    }
}