public class AMSAllTriggerHandlerANZ {
    final static String CURRYEAR = String.valueOf(System.today().year());
    //final static String CURRYEAR = String.valueOf(2023); 
    private class EmpWrappedDataANZ{
        private Employee__c employeeDetails {get; set;}
        private Regional_Leave_Limit__c currApplicableLimit {get; set;}
        private Employee_Leave_Balance__c oldEmpBalance {get; set;}
        
        private EmpWrappedDataANZ(Employee__c employeeDetails, Regional_Leave_Limit__c currApplicableLimit, Employee_Leave_Balance__c oldEmpBalance){
            this.employeeDetails = employeeDetails;
            this.currApplicableLimit = currApplicableLimit;
            this.oldEmpBalance = oldEmpBalance;
        }
    }
    private static Decimal ProRataCalculation(Decimal leavesAvailable){
        try{
            Decimal proRataMonths = 12 - System.now().month();
            if( System.now().Day() <= 15){
                proRataMonths = proRataMonths+1;
            }
            Decimal proRataCalc = (leavesAvailable/12)*proRataMonths;
            if((proRataCalc - Math.floor(proRataCalc)) > 0.5){
                return Math.ceil(proRataCalc);
            }
            else if((proRataCalc - Math.floor(proRataCalc))< 0.5){
                return Math.floor(proRataCalc);
            }
            else if((proRataCalc - Math.floor(proRataCalc)) == 0.5){
                return proRataCalc;
            }
            return proRataCalc; 
        }
        catch(Exception e){
            System.debug('Issue in: EmployeeProbationToPermanent @ ProRataCalculation method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            return null;
        }
    }
    private static Decimal ProRataCalculationNoDecimals(Decimal leavesAvailable){
        try{
            Decimal proRataMonths = 12 - System.now().month();
            if( System.now().Day() <= 15){
                proRataMonths = proRataMonths+1;
            }
            Decimal proRataCalc = (leavesAvailable/12)*proRataMonths;
            if((proRataCalc - Math.floor(proRataCalc)) >= 0.5){
                return Math.ceil(proRataCalc);
            }
            else if((proRataCalc - Math.floor(proRataCalc))< 0.5){
                return Math.floor(proRataCalc);
            }
            return proRataCalc;
        }
        catch(Exception e){
            System.debug('Issue in: EmployeeProbationToPermanent @ ProRataCalculationNoDecimals method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            return null;  
        }
    }
    public static void balanceDataInsertionNew(Regional_Leave_Limit__c traineeLimitANZ, Map<Id, Employee__c> newJoineeANZMap){
        try{
            List<Employee_Leave_Balance__c > newJoineeEmpBalance = new List<Employee_Leave_Balance__c >();
            for(Id eachId : newJoineeANZMap.keyset()){
                Employee_Leave_Balance__c empBal = new Employee_Leave_Balance__c();
                empBal.Sick_Leave__c = ProRataCalculation(traineeLimitANZ.Sick_Leave__c);
                empBal.Employee_Status__c = traineeLimitANZ.Employee_Status__c;
                empBal.Paternity_Leave__c = traineeLimitANZ.Paternity_Leave__c;
                empBal.Celebration_Leave__c = newJoineeANZMap.get(eachId).Geo_Date_of_Joining__c.month() <= 6? traineeLimitANZ.Celebration_Leave__c : 1;
                empBal.Employee__c = eachId;
                empBal.Privilege_Paid_Leave_in_days__c = ProRataCalculationNoDecimals(traineeLimitANZ.Privilege_Paid_Leave__c);
                //empBal.Privilege_Paid_Leave_in_days__c = (newJoineeANZMap.get(eachId).Geo_Date_of_Joining__c).Day() < = 15 ? 1 : 0;
                empBal.Regional_Leave_Limit__c = traineeLimitANZ.Id;
                newJoineeEmpBalance.add(empBal);
            }
            if(newJoineeEmpBalance.size() > 0){
                insert newJoineeEmpBalance;
            }
        } catch (Exception e) {
            System.debug('Issue in: AMSAllTriggerHandlerANZ @ balanceDataInsertionNew method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            throw new FinalException(e.getMessage());
        }
    }
    public static void newBalanceOnTraineeToFTE(Map<Id, Employee__c> traineeToFTEMap){
        try{
            System.debug('traineeToFTEMap'+traineeToFTEMap);
            Regional_Leave_Limit__c traineeLimitANZ = [SELECT Employee_Status__c, Region__c, Bereavement_Leave__c, Sick_Leave__c, Casual_Leave__c, Privilege_Paid_Leave__c, Paternity_Leave__c, Maternity_Leave__c, Celebration_Leave__c, Restricted_Holiday__c, Loss_of_Pay_LOP__c, Long_Leave__c, CarryForward__c, Carry_Forward_Sick_Leave__c, Carry_Forward_Celebration_Leave__c, Carry_Forward_Privilege_Leave__c FROM Regional_Leave_Limit__c WHERE Region__c = 'ANZ' AND Year__c =:CURRYEAR AND Employee_Status__c = 'FTE(1+ - 10 years)' WITH SYSTEM_MODE limit 1];
            Map<String, Employee_Leave_Balance__c> oldEmpBalMap = new Map<String, Employee_Leave_Balance__c>();
            List<Employee_Leave_Balance__c> convertedEmpBalances = [SELECT Employee__c, Employee_Status__c, Bereavement_Leave__c, Sick_Leave__c, Casual_Leave__c, Privilege_Paid_Leave_in_days__c, Paternity_Leave__c, Maternity_Leave__c, Celebration_Leave__c, Restricted_Holiday__c, Loss_of_Pay_LOP__c, Long_Leave__c, CarryForward__c, CarryForward_Sick_Leave__c, Carry_Forward_Celebration_Leave__c, CarryForward_Privilege_Leave__c,Active__c FROM Employee_Leave_Balance__c WHERE Employee__c IN: traineeToFTEMap.keySet() AND Year__c = :CURRYEAR AND Employee_Status__c = 'Trainee(0-1 years)' WITH SYSTEM_MODE];
            System.debug('convertedEmpBalances'+convertedEmpBalances[0].Active__c );
            List<Employee_Leave_Balance__c> toBeInsertedLeaveBalance = new List<Employee_Leave_Balance__c>();
            Map<Id, EmpWrappedDataANZ> employeeAllData = new Map<Id, empWrappedDataANZ>();
            for(Employee_Leave_Balance__c eachBal : convertedEmpBalances){
                oldEmpBalMap.put(eachBal.Employee__c, eachBal);
            }
            for(Id eachId : traineeToFTEMap.keyset()){
                employeeAllData.put(eachId, new EmpWrappedDataANZ(traineeToFTEMap.get(eachId), traineeLimitANZ, oldEmpBalMap.get(eachId)));
            }
            for(String eachId : employeeAllData.keyset()){
                Employee_Leave_Balance__c eachBal = new Employee_Leave_Balance__c();
                eachBal.Regional_Leave_Limit__c = employeeAllData.get(eachId).currApplicableLimit.Id;
                eachBal.Employee__c =   employeeAllData.get(eachId).employeeDetails.Id;
                eachBal.Employee_Status__c =  employeeAllData.get(eachId).employeeDetails.ANZ_Workforce_Category__c;
                eachBal.Sick_Leave__c = employeeAllData.get(eachId).oldEmpBalance.Sick_Leave__c;
                eachBal.Casual_Leave__c =  employeeAllData.get(eachId).oldEmpBalance.Casual_Leave__c;
                eachBal.Celebration_Leave__c = employeeAllData.get(eachId).oldEmpBalance.Celebration_Leave__c;
                eachBal.Paternity_Leave__c = employeeAllData.get(eachId).oldEmpBalance.Paternity_Leave__c;
                eachBal.Long_Leave__c = employeeAllData.get(eachId).oldEmpBalance.Long_Leave__c;
                eachBal.Loss_of_Pay_LOP__c = employeeAllData.get(eachId).oldEmpBalance.Loss_of_Pay_LOP__c;
                System.debug('prorata calc'+ProRataCalculationNoDecimals(employeeAllData.get(eachId).currApplicableLimit.Privilege_Paid_Leave__c));
                System.debug('employeeAllData.get(eachId).currApplicableLimit'+employeeAllData.get(eachId).currApplicableLimit);
                System.debug('employeeAllData.get(eachId).employeeDetails'+employeeAllData.get(eachId).employeeDetails);
                System.debug('employeeAllData.get(eachId).oldEmpBalance'+employeeAllData.get(eachId).oldEmpBalance);
                eachBal.Privilege_Paid_Leave_in_days__c = ProRataCalculationNoDecimals(employeeAllData.get(eachId).currApplicableLimit.Privilege_Paid_Leave__c) + (employeeAllData.get(eachId).oldEmpBalance.Privilege_Paid_Leave_in_days__c > 10 ? 10 : employeeAllData.get(eachId).oldEmpBalance.Privilege_Paid_Leave_in_days__c);
                toBeInsertedLeaveBalance.add(eachBal);
            }
            System.debug('toBeInsertedLeaveBalance'+toBeInsertedLeaveBalance);
            if(toBeInsertedLeaveBalance.size() > 0){
                insert toBeInsertedLeaveBalance;
            }
            
        } catch (Exception e) {
            System.debug('Issue in: AMSAllTriggerHandlerANZ @ newBalanceOnTraineeToFTE method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            throw new FinalException(e.getMessage());
        }
    }
    public static void insertSeniorEmpBal(Map<Id, Employee__c> FTEToSeniorMap){
        try{
            Regional_Leave_Limit__c FTELimitANZ = [SELECT Employee_Status__c, Region__c, Bereavement_Leave__c, Sick_Leave__c, Casual_Leave__c, Privilege_Paid_Leave__c, Paternity_Leave__c, Maternity_Leave__c, Celebration_Leave__c, Restricted_Holiday__c, Loss_of_Pay_LOP__c, Long_Leave__c, CarryForward__c, Carry_Forward_Sick_Leave__c, Carry_Forward_Celebration_Leave__c, Carry_Forward_Privilege_Leave__c FROM Regional_Leave_Limit__c WHERE Region__c = 'ANZ' AND Year__c =:CURRYEAR AND Employee_Status__c = 'Senior Employee(10+ years)' WITH SYSTEM_MODE limit 1];
            Map<String, Employee_Leave_Balance__c> oldEmpBalMap = new Map<String, Employee_Leave_Balance__c>();
            List<Employee_Leave_Balance__c> convertedEmpBalances = [SELECT Employee__c, Employee_Status__c, Bereavement_Leave__c, Sick_Leave__c, Casual_Leave__c, Privilege_Paid_Leave_in_days__c, Paternity_Leave__c, Maternity_Leave__c, Celebration_Leave__c, Restricted_Holiday__c, Loss_of_Pay_LOP__c, Long_Leave__c, CarryForward__c, CarryForward_Sick_Leave__c, Carry_Forward_Celebration_Leave__c, CarryForward_Privilege_Leave__c FROM Employee_Leave_Balance__c WHERE Employee__c IN: FTEToSeniorMap.keySet() AND Year__c = :CURRYEAR AND Employee_Status__c = 'FTE(1+ - 10 years)' WITH SYSTEM_MODE];
            List<Employee_Leave_Balance__c> toBeInsertedLeaveBalance = new List<Employee_Leave_Balance__c>();
            Map<Id, EmpWrappedDataANZ> employeeAllData = new Map<Id, empWrappedDataANZ>();
            for(Employee_Leave_Balance__c eachBal : convertedEmpBalances){
                oldEmpBalMap.put(eachBal.Employee__c, eachBal);
            }
            for(Id eachId : FTEToSeniorMap.keyset()){
                employeeAllData.put(eachId, new EmpWrappedDataANZ(FTEToSeniorMap.get(eachId), FTELimitANZ, oldEmpBalMap.get(eachId)));
            }
            for(String eachId : employeeAllData.keyset()){
                System.debug('employeeAllData.get(eachId).currApplicableLimit'+employeeAllData.get(eachId).currApplicableLimit);
                System.debug('employeeAllData.get(eachId).currApplicableLimit.Long_Leave__c' +employeeAllData.get(eachId).currApplicableLimit.Long_Leave__c);
                Employee_Leave_Balance__c eachBal = new Employee_Leave_Balance__c();
                eachBal.Regional_Leave_Limit__c = employeeAllData.get(eachId).currApplicableLimit.Id;
                eachBal.Employee__c =   employeeAllData.get(eachId).employeeDetails.Id;
                eachBal.Employee_Status__c =  employeeAllData.get(eachId).employeeDetails.ANZ_Workforce_Category__c;
                eachBal.Casual_Leave__c =  employeeAllData.get(eachId).oldEmpBalance.Casual_Leave__c;
                eachBal.Sick_Leave__c = employeeAllData.get(eachId).oldEmpBalance.Sick_Leave__c;
                eachBal.Celebration_Leave__c = employeeAllData.get(eachId).oldEmpBalance.Celebration_Leave__c;
                eachBal.Paternity_Leave__c = employeeAllData.get(eachId).oldEmpBalance.Paternity_Leave__c;
                eachBal.Long_Leave__c = employeeAllData.get(eachId).currApplicableLimit.Long_Leave__c;
                eachBal.Privilege_Paid_Leave_in_days__c = employeeAllData.get(eachId).oldEmpBalance.Privilege_Paid_Leave_in_days__c;
                eachBal.Loss_of_Pay_LOP__c = employeeAllData.get(eachId).oldEmpBalance.Loss_of_Pay_LOP__c;
                toBeInsertedLeaveBalance.add(eachBal);
            }
            System.debug('toBeInsertedLeaveBalance'+toBeInsertedLeaveBalance);
            if(toBeInsertedLeaveBalance.size() > 0){
                insert toBeInsertedLeaveBalance;
            }
        } catch (Exception e) {
            System.debug('Issue in: AMSAllTriggerHandlerANZ @ insertSeniorEmpBal method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            throw new FinalException(e.getMessage());
        }
    }
    public static void updateSeniorEmpLongLeave(Map<Id, Employee__c> updateFTEToSeniorMap){
        try{
            System.debug('I am called');
            Regional_Leave_Limit__c FTELimitANZ = [SELECT Employee_Status__c, Region__c, Bereavement_Leave__c, Sick_Leave__c, Casual_Leave__c, Privilege_Paid_Leave__c, Paternity_Leave__c, Maternity_Leave__c, Celebration_Leave__c, Restricted_Holiday__c, Loss_of_Pay_LOP__c, Long_Leave__c, CarryForward__c, Carry_Forward_Sick_Leave__c, Carry_Forward_Celebration_Leave__c, Carry_Forward_Privilege_Leave__c FROM Regional_Leave_Limit__c WHERE Region__c = 'ANZ' AND Year__c =:CURRYEAR AND Employee_Status__c = 'Senior Employee(10+ years)' WITH SYSTEM_MODE limit 1];
            List<Employee_Leave_Balance__c> convertedEmpBalances = [SELECT Employee__c, Employee_Status__c, Bereavement_Leave__c, Sick_Leave__c, Casual_Leave__c, Privilege_Paid_Leave_in_days__c, Paternity_Leave__c, Maternity_Leave__c, Celebration_Leave__c, Restricted_Holiday__c, Loss_of_Pay_LOP__c, Long_Leave__c, CarryForward__c, CarryForward_Sick_Leave__c, Carry_Forward_Celebration_Leave__c, CarryForward_Privilege_Leave__c FROM Employee_Leave_Balance__c WHERE Employee__c IN: updateFTEToSeniorMap.keySet() AND Year__c = :CURRYEAR AND Employee_Status__c = 'Senior Employee(10+ years)' AND Active__c = true WITH SYSTEM_MODE];
            System.debug('convertedEmpBalances'+convertedEmpBalances);
            List<Employee_Leave_Balance__c> toBeUpdatedBal = new List<Employee_Leave_Balance__c>();
            for(Employee_Leave_Balance__c eachBal : convertedEmpBalances){
                eachBal.Long_Leave__c = FTELimitANZ.Long_Leave__c;
                toBeUpdatedBal.add(eachBal);
            }
            System.debug('toBeUpdatedBal'+toBeUpdatedBal);
            if(toBeUpdatedBal.size() > 0){
                update toBeUpdatedBal;
            }
        } catch (Exception e) {
            System.debug('Issue in: AMSAllTriggerHandlerANZ @ updateSeniorEmpLongLeave method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            throw new FinalException(e.getMessage());
        }
    }
}