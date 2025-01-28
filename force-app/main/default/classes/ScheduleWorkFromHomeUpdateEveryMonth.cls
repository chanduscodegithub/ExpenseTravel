global class ScheduleWorkFromHomeUpdateEveryMonth implements Schedulable {
    
    final static String CURRYEAR = String.valueOf(System.today().year());
    
    private class EmployeeWrappedData{
        private Employee_Leave_Balance__c empBal {get; set;}
        private Decimal wfhInDays {get; set;}
        
        private EmployeeWrappedData(Employee_Leave_Balance__c empBal, Decimal wfhInDays){
            this.empBal = empBal;
            this.wfhInDays = wfhInDays;
        }
    }
    global void execute(SchedulableContext SC){
            try{
            Map<Id, EmployeeWrappedData> wrappedEmpDataMap = new Map<Id, EmployeeWrappedData>();
            List<Employee_Leave_Balance__c> toBeUpdatedBal = new List<Employee_Leave_Balance__c>();
            Map<Id, Employee_Leave_Balance__c> empBalMap = new Map<Id, Employee_Leave_Balance__c>();
            Map<Id, Employee__c> empListForWFH = new Map<Id, Employee__c>([SELECT Id, Name, Type__c, Grade__c, DateofJoin__c, Gender__c, Region__c, Country__c, SF_User__c, ReportingTo__r.SF_User__c, SF_User__r.Email, Enable_Paternity_Maternity__c, Enable_Bereavement__c, Paternity_Maternity_Leave_Count__c, Date_of_Birth__c, Date_of_Anniversary__c, Onsite_Experience__c, Geo_Date_of_Joining__c, ANZ_Workforce_Category__c FROM Employee__c WHERE IsWFHApplicable__c = true AND Region__c = 'IND' AND Type__c = 'Permanent' WITH SYSTEM_MODE]);
            List<Regional_Leave_Limit__c> regionList = [SELECT Employee_Status__c, Region__c, WFH_B1_L1__c, WFH_B1_L2__c, WFH_B1_L3_to_L5__c, WFH_B2_M1_to_M3__c, WFH_D1_above__c 
                                                        FROM Regional_Leave_Limit__c WHERE Region__c = 'IND' AND Year__c =:CURRYEAR AND Employee_Status__c = 'Permanent' WITH SYSTEM_MODE limit 1];
            List<Employee_Leave_Balance__c> balanceList = [SELECT Employee__c, Employee_Status__c, Work_from_Home__c FROM Employee_Leave_Balance__c WHERE Employee__c IN : empListForWFH.keyset() AND Year__c = :CURRYEAR AND Active__c = true WITH SYSTEM_MODE];
                           
                for(Employee_Leave_Balance__c eachBal : balanceList){
                empBalMap.put(eachBal.Employee__c, eachBal);
            }
            for(Id eachId : empListForWFH.Keyset()){
                wrappedEmpDataMap.put(eachId, new EmployeeWrappedData(empBalMap.get(eachId), decideEmpGradeBasedWfhAllowance(empListForWFH.get(eachId), regionList[0])));
            }
            for(Id eachId : wrappedEmpDataMap.keyset()){
                
                EmployeeWrappedData wrappedData = wrappedEmpDataMap.get(eachId);
                if(wrappedData != null && wrappedData.empBal != null){
                Employee_Leave_Balance__c eachBal = wrappedEmpDataMap.get(eachId).empBal;
                /*if(eachBal.Work_from_Home__c == 0 || eachBal.Work_from_Home__c == null || eachBal.Work_from_Home__c < 0){
                    eachBal.Work_from_Home__c = isWfhAlreadyUpdatedViaStart() ? 0: wrappedEmpDataMap.get(eachId).wfhInDays ;
                }*/
                eachBal.Work_from_Home__c = wrappedEmpDataMap.get(eachId).wfhInDays;
                toBeUpdatedBal.add(eachBal);
            }
            }
                system.debug('toBeUpdatedBal>>>>>>>>>>>>>'+toBeUpdatedBal);
            if(toBeUpdatedBal.size() > 0){
                update toBeUpdatedBal;
               }
                system.debug('toBeUpdatedBal'+toBeUpdatedBal);
        }
        catch(Exception e){
            System.debug('Issue in: ScheduleWorkFromHomeUpdateEveryMonth @ execute method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber()); 
        }
    }
    private static Decimal decideEmpGradeBasedWfhAllowance(Employee__c eachEmployee, Regional_Leave_Limit__c applicableRegionLimit){
        try{
            Decimal wfhLimit = 0.0;
            
            switch on eachEmployee.Grade__c{
                when 'L1'{
                    wfhLimit = applicableRegionLimit.WFH_B1_L1__c;  
                } 
                When 'L2'{
                    wfhLimit = applicableRegionLimit.WFH_B1_L2__c; 
                }
                When 'L3'{
                    wfhLimit = applicableRegionLimit.WFH_B1_L3_to_L5__c;
                }
                When 'L4'{
                    wfhLimit = applicableRegionLimit.WFH_B1_L3_to_L5__c;
                }
                When 'L5'{
                    wfhLimit = applicableRegionLimit.WFH_B1_L3_to_L5__c;
                }
                When 'M1'{
                    wfhLimit = applicableRegionLimit.WFH_B2_M1_to_M3__c;
                }
                When 'M2'{
                    wfhLimit = applicableRegionLimit.WFH_B2_M1_to_M3__c;
                }
                When 'M3'{
                    wfhLimit = applicableRegionLimit.WFH_B2_M1_to_M3__c;
                }
            }
            return wfhLimit;
        }
        catch(Exception e){
            System.debug('Issue in: ScheduleWorkFromHomeUpdateEveryMonth @ decideEmpGradeBasedWfhAllowance method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber()); 
            return null;
        }
    }

    
   /* Author : Divya 
    Date: 24th April 2024
    WFH Issue fix : WFH - Monthly leave credit Issue (Whenever class is scheduled the wfh should credit back irrespective of any check)
    
    private static Boolean isWfhAlreadyUpdatedViaStart(){
        try{
           List<Employee_Leave__c> empAcquiredWfhList = [SELECT Id, Employee_Status__c, Start_Date__c, End_Date__c, Employee__r.Name, Employee_Leave_Balance__c FROM Employee_Leave__c WHERE CALENDAR_MONTH(Start_Date__c) = :System.today().month() AND CALENDAR_MONTH(End_Date__c) = :System.today().month() AND Leave_Type__c  = 'Work from Home(WFH)'];
           system.debug('empAcquiredWfhList'+empAcquiredWfhList);
           return empAcquiredWfhList.size() > 0 && empAcquiredWfhList.size() != null ? true : false; 
        }
        catch(Exception e){
            System.debug('Issue in: ScheduleWorkFromHomeUpdateEveryMonth @ isWfhAlreadyUpdatedViaStart method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber()); 
            return false;
        }
    }
*/
}