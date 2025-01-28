/*------------------------------------------------------------------------------------
Author:        Paras Prajapati
Description:   EmployeeRateService - Insert Employee per hour rate in employee team record.

History
Date            Author             Comments
--------------------------------------------------------------------------------------

------------------------------------------------------------------------------------*/
public class TeamEmployeeRateService {
   /**
     *  @description Handle inserts for TeamAllocation__c and stamp Rate Per Hour from Employee Role
     *  @param records - List of TeamAllocation__c Records
     */
    public static void insertEmployeeRate(List<TeamAllocation__c> teamAllocationRecords){
        Set<Id> empIdSet=new Set<Id>();
        for(TeamAllocation__c teamAllocation : teamAllocationRecords){
            if(teamAllocation.EmployeeName__c != null){
                empIdSet.add(teamAllocation.EmployeeName__c);
            }       
        }
        Map<ID, Employee__c> mapEmp = new Map<ID, Employee__c>([select id,BillingStatus__c,Designation__c,Designation__r.Grade__c,Designation__r.RatePerHour__c from Employee__c where id =:empIdSet]);
        if(!mapEmp.isEmpty()){
            for(TeamAllocation__c teamAllocation : teamAllocationRecords){
                if(teamAllocation.EmployeeName__c != null && mapEmp.containsKey(teamAllocation.EmployeeName__c)){
                    Employee__c employeeRecord = mapEmp.get(teamAllocation.EmployeeName__c);
                    if(employeeRecord.Designation__r.RatePerHour__c!=null){
                       teamAllocation.RatePerHour__c = mapEmp.get(teamAllocation.EmployeeName__c).Designation__r.RatePerHour__c; 
                    }
                }       
            } 
        }
    }
}