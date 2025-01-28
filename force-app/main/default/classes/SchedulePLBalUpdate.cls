global class SchedulePLBalUpdate implements Schedulable {
    global void execute(SchedulableContext SC) {
        try{
            String currentYear = String.valueOf(System.today().year());
            Map<Id, Employee_Leave_Balance__c> traineeEmpMapANZ = new Map<Id, Employee_Leave_Balance__c>([SELECT Id, Privilege_Paid_Leave_in_days__c, Employee__r.Geo_Date_of_Joining__c, Employee__r.DateofJoin__c, Employee__r.Id FROM Employee_Leave_Balance__c WHERE Employee_Status__c = 'Trainee(0-1 years)' AND Region__c = 'ANZ' AND Active__c = true]);
            List<Employee_Leave_Balance__c> toBeUpdatedEmpBalList = new List<Employee_Leave_Balance__c>();
            System.debug('traineeEmpMapANZ' + traineeEmpMapANZ);
            for(Id eachId : traineeEmpMapANZ.keyset()){
                if(traineeEmpMapANZ.get(eachId).Employee__r.Geo_Date_of_Joining__c != System.today()){
                    traineeEmpMapANZ.get(eachId).Privilege_Paid_Leave_in_days__c += 1.6;
                }
                else{
                    traineeEmpMapANZ.get(eachId).Privilege_Paid_Leave_in_days__c = traineeEmpMapANZ.get(eachId).Privilege_Paid_Leave_in_days__c == 1.6 ? traineeEmpMapANZ.get(eachId).Privilege_Paid_Leave_in_days__c : (isPLConsumed(traineeEmpMapANZ.get(eachId).Employee__r.Id, currentYear) ? traineeEmpMapANZ.get(eachId).Privilege_Paid_Leave_in_days__c : 1.6);
                        }
                        toBeUpdatedEmpBalList.add(traineeEmpMapANZ.get(eachId));
            } 
            System.debug('toBeUpdatedEmpBalList'+toBeUpdatedEmpBalList);
            if(toBeUpdatedEmpBalList.size() > 0){
                update toBeUpdatedEmpBalList;
            }
        } catch (Exception e) {
            System.debug('Issue in: SchedulePLBalUpdate @ execute method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            throw new FinalException(e.getMessage());
        }
        
        
    }
    private Boolean isPLConsumed(Id employeeId, String currentYear){
        Boolean isConsumed = false;
        try{
            List<Employee_Leave__c > availedLeave = [SELECT Id FROM Employee_Leave__c WHERE Employee__r.Id =: employeeId AND Year__c =: currentYear];
            if(availedLeave.size() > 0){
                isConsumed = true;
            }
            else{
                isConsumed = false;
            }
        } catch (Exception e) {
            System.debug('Issue in: SchedulePLBalUpdate @ isPLConsumed method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            throw new FinalException(e.getMessage());
        }
        return isConsumed;
        
    }
}