public class AMSRegionLeaveLimitTriggerHandler {
    Public static void regionalLeaveLimitMethod(Map<id,Regional_Leave_Limit__c> newData ,Map<id,Regional_Leave_Limit__c> oldData){
        try{
            List<Regional_Leave_Limit__c> regionalLeaveLimitList = [SELECT Name,Region__c,Employee_Status__c,Year__c FROM  Regional_Leave_Limit__c where Region__c!=Null AND Employee_Status__c!=NULL AND Year__c!=NULL];
            for(Regional_Leave_Limit__c eachRegionLeaveLimit : regionalLeaveLimitList ){
                for(Regional_Leave_Limit__c eachRegionLeave : newData.values()){
                    
                    if(eachRegionLeaveLimit.Region__c == eachRegionLeave.Region__c && eachRegionLeaveLimit.Year__c == eachRegionLeave.Year__c && eachRegionLeaveLimit.Employee_Status__c == eachRegionLeave.Employee_Status__c && eachRegionLeave.Id != eachRegionLeaveLimit.id ){
                        newData.get(eachRegionLeave.Id).addError('Record cannot be created because a duplicate record already exist');
                    }
                    else{
                        system.debug('Inside else Condition');
                    }
                }
            }
            /***********Update Record********/
            List<Regional_Leave_Limit__c> regionLeaveLimitList = [SELECT id,name,Year__c,Sick_Leave__c,Bereavement_Leave__c,Casual_Leave__c,Privilege_Paid_Leave__c,Celebration_Leave__c,(SELECT id FROM Employee_Leave_Balance__r ) FROM Regional_Leave_Limit__c  WHERE id in: newData.keySet()];
            for(Regional_Leave_Limit__c eachRegion:regionLeaveLimitList){
                
                
                if(eachRegion.Employee_Leave_Balance__r.size()>0 && (eachRegion.Sick_Leave__c != newData.get(eachRegion.Id).Sick_Leave__c || eachRegion.Bereavement_Leave__c != newData.get(eachRegion.Id).Bereavement_Leave__c || eachRegion.Celebration_Leave__c != newData.get(eachRegion.Id).Celebration_Leave__c || eachRegion.Casual_Leave__c != newData.get(eachRegion.Id).Casual_Leave__c)){
                    newData.get(eachRegion.Id).addError('This Regional Request have some employees');
                }
            }
        }
        catch(Exception e){
            system.debug('Error'+e.getMessage());
            
        }
        
        
    }
    /********* After Insert**********/
    Public static void regionalLeaveLimitAfterInsert(List<Regional_Leave_Limit__c> regionalLevaelimitlist){
        List<Employee__c> employeeList = [SELECT id,name FROM Employee__c LIMIT 1];
        List<Employee_Leave_Balance__c> empLeaveBalanceList = new List<Employee_Leave_Balance__c>();
        for(Regional_Leave_Limit__c eachRegionNew : regionalLevaelimitlist){
            for(Employee__c eachRegion : employeeList){
                Employee_Leave_Balance__c empLeaveBalance = new Employee_Leave_Balance__c();
                empLeaveBalance.Sick_Leave__c = eachRegionNew.Sick_Leave__c;
                empLeaveBalance.Bereavement_Leave__c = eachRegionNew.Bereavement_Leave__c;
                empLeaveBalance.Casual_Leave__c = eachRegionNew.Casual_Leave__c;
                empLeaveBalance.Privilege_Paid_Leave_in_days__c = eachRegionNew.Privilege_Paid_Leave__c;
                empLeaveBalance.Celebration_Leave__c = eachRegionNew.Celebration_Leave__c;
                empLeaveBalance.Employee__c = eachRegion.id;
                empLeaveBalance.Regional_Leave_Limit__c = eachRegionNew.Id;
                empLeaveBalanceList.add(empLeaveBalance);
                
            }
        }
        insert empLeaveBalanceList;
        
    }
    
}