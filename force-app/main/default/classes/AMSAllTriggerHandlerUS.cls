public class AMSAllTriggerHandlerUS {
    
    final static String CURRYEAR = String.valueOf(System.today().year()); 
    private class EmpWrappedDataUS{
        private Employee__c employeeDetails {get; set;}
        private Regional_Leave_Limit__c currApplicableLimit {get; set;}
        private Employee_Leave_Balance__c oldEmpBalance {get; set;}
        
        private EmpWrappedDataUS(Employee__c employeeDetails, Regional_Leave_Limit__c currApplicableLimit, Employee_Leave_Balance__c oldEmpBalance){
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
    
    public static void balanceDataInsertionNew(Regional_Leave_Limit__c traineeLimitUS, Map<Id, Employee__c> newJoineeUSMap){
        try{
            List<Employee_Leave_Balance__c > newJoineeEmpBalance = new List<Employee_Leave_Balance__c >();
            for(Id eachId : newJoineeUSMap.keyset()){
                Employee_Leave_Balance__c empBal = new Employee_Leave_Balance__c();
                empBal.Sick_Leave__c = ProRataCalculation(traineeLimitUS.Sick_Leave__c);
                empBal.Employee_Status__c = traineeLimitUS.Employee_Status__c;
                empBal.Paternity_Leave__c = traineeLimitUS.Paternity_Leave__c;
                empBal.Celebration_Leave__c = traineeLimitUS.Celebration_Leave__c;
                empBal.Employee__c = eachId;
                empBal.Long_Leave__c = traineeLimitUS.Long_Leave__c;
                empBal.Loss_of_Pay_LOP__c = traineeLimitUS.Loss_of_Pay_LOP__c;
                empBal.Privilege_Paid_Leave_in_days__c = ProRataCalculationNoDecimals(traineeLimitUS.Privilege_Paid_Leave__c);
                empBal.Regional_Leave_Limit__c = traineeLimitUS.Id;
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
    public static void newBalanceOnTraineeUSToFTEUS(Map<Id, Employee__c> traineeUSToFTEUSMap){
        try{
            Regional_Leave_Limit__c traineeLimitUS = [SELECT Employee_Status__c, Region__c, Bereavement_Leave__c, Sick_Leave__c, Casual_Leave__c, Privilege_Paid_Leave__c, Paternity_Leave__c, Maternity_Leave__c, Celebration_Leave__c, Restricted_Holiday__c, Loss_of_Pay_LOP__c, Long_Leave__c, CarryForward__c, Carry_Forward_Sick_Leave__c, Carry_Forward_Celebration_Leave__c, Carry_Forward_Privilege_Leave__c FROM Regional_Leave_Limit__c WHERE Region__c = 'US' AND Year__c =:CURRYEAR AND Employee_Status__c = 'FTEUS(3 or 3 - 4 years)' WITH SYSTEM_MODE limit 1];
            Map<String, Employee_Leave_Balance__c> oldEmpBalMap = new Map<String, Employee_Leave_Balance__c>();
            List<Employee_Leave_Balance__c> convertedEmpBalances = [SELECT Employee__c, Employee_Status__c, Bereavement_Leave__c, Sick_Leave__c, Casual_Leave__c, Privilege_Paid_Leave_in_days__c, Paternity_Leave__c, Maternity_Leave__c, Celebration_Leave__c, Restricted_Holiday__c, Loss_of_Pay_LOP__c, Long_Leave__c, CarryForward__c, CarryForward_Sick_Leave__c, Carry_Forward_Celebration_Leave__c, CarryForward_Privilege_Leave__c,Active__c FROM Employee_Leave_Balance__c WHERE Employee__c IN: traineeUSToFTEUSMap.keySet() AND Year__c = :CURRYEAR AND Employee_Status__c = 'TraineeUS(0-3 years)' WITH SYSTEM_MODE];
            List<Employee_Leave_Balance__c> toBeInsertedLeaveBalance = new List<Employee_Leave_Balance__c>();
            Map<Id, EmpWrappedDataUS> employeeAllData = new Map<Id, EmpWrappedDataUS>();
            for(Employee_Leave_Balance__c eachBal : convertedEmpBalances){
                oldEmpBalMap.put(eachBal.Employee__c, eachBal);
            }
            for(Id eachId : traineeUSToFTEUSMap.keyset()){
                employeeAllData.put(eachId, new EmpWrappedDataUS(traineeUSToFTEUSMap.get(eachId), traineeLimitUS, oldEmpBalMap.get(eachId)));
            }
            for(String eachId : employeeAllData.keyset()){
                Employee_Leave_Balance__c eachBal = new Employee_Leave_Balance__c();
                eachBal.Regional_Leave_Limit__c = employeeAllData.get(eachId).currApplicableLimit.Id;
                eachBal.Employee__c =   employeeAllData.get(eachId).employeeDetails.Id;
                eachBal.Employee_Status__c =  employeeAllData.get(eachId).employeeDetails.ANZ_Workforce_Category__c;
                eachBal.Sick_Leave__c = ProRataCalculation(employeeAllData.get(eachId).currApplicableLimit.Sick_Leave__c);
                eachBal.Long_Leave__c = employeeAllData.get(eachId).oldEmpBalance.Long_Leave__c;
                eachBal.Loss_of_Pay_LOP__c = employeeAllData.get(eachId).oldEmpBalance.Loss_of_Pay_LOP__c;
                eachBal.Privilege_Paid_Leave_in_days__c = employeeAllData.get(eachId).oldEmpBalance.Privilege_Paid_Leave_in_days__c ;
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
    public static void insertSeniorEmpBalUS(Map<Id, Employee__c> FTEToSeniorMapUS){
        try{
            Regional_Leave_Limit__c FTELimitUS = [SELECT Employee_Status__c, Region__c, Bereavement_Leave__c, Sick_Leave__c, Casual_Leave__c, Privilege_Paid_Leave__c, Paternity_Leave__c, Maternity_Leave__c, Celebration_Leave__c, Restricted_Holiday__c, Loss_of_Pay_LOP__c, Long_Leave__c, CarryForward__c, Carry_Forward_Sick_Leave__c, Carry_Forward_Celebration_Leave__c, Carry_Forward_Privilege_Leave__c FROM Regional_Leave_Limit__c WHERE Region__c = 'US' AND Year__c =:CURRYEAR AND Employee_Status__c = 'SeniorUS(4-4+ years)' WITH SYSTEM_MODE limit 1];
            Map<String, Employee_Leave_Balance__c> oldEmpBalMap = new Map<String, Employee_Leave_Balance__c>();
            List<Employee_Leave_Balance__c> convertedEmpBalances = [SELECT Employee__c, Employee_Status__c, Bereavement_Leave__c, Sick_Leave__c, Casual_Leave__c, Privilege_Paid_Leave_in_days__c, Paternity_Leave__c, Maternity_Leave__c, Celebration_Leave__c, Restricted_Holiday__c, Loss_of_Pay_LOP__c, Long_Leave__c, CarryForward__c, CarryForward_Sick_Leave__c, Carry_Forward_Celebration_Leave__c, CarryForward_Privilege_Leave__c FROM Employee_Leave_Balance__c WHERE Employee__c IN: FTEToSeniorMapUS.keySet() AND Year__c = :CURRYEAR AND Employee_Status__c = 'FTEUS(3 or 3 - 4 years)' WITH SYSTEM_MODE];
            List<Employee_Leave_Balance__c> toBeInsertedLeaveBalance = new List<Employee_Leave_Balance__c>();
            Map<Id, EmpWrappedDataUS> employeeAllData = new Map<Id, EmpWrappedDataUS>();
            for(Employee_Leave_Balance__c eachBal : convertedEmpBalances){
                oldEmpBalMap.put(eachBal.Employee__c, eachBal);
            }
            for(Id eachId : FTEToSeniorMapUS.keyset()){
                employeeAllData.put(eachId, new EmpWrappedDataUS(FTEToSeniorMapUS.get(eachId), FTELimitUS, oldEmpBalMap.get(eachId)));
            }
            for(String eachId : employeeAllData.keyset()){
                Employee_Leave_Balance__c eachBal = new Employee_Leave_Balance__c();
                eachBal.Regional_Leave_Limit__c = employeeAllData.get(eachId).currApplicableLimit.Id;
                eachBal.Employee__c =   employeeAllData.get(eachId).employeeDetails.Id;
                eachBal.Employee_Status__c =  employeeAllData.get(eachId).employeeDetails.ANZ_Workforce_Category__c;
                eachBal.Sick_Leave__c = employeeAllData.get(eachId).oldEmpBalance.Sick_Leave__c;
                eachBal.Long_Leave__c = employeeAllData.get(eachId).currApplicableLimit.Long_Leave__c;
                eachBal.Privilege_Paid_Leave_in_days__c = ProRataCalculationNoDecimals(employeeAllData.get(eachId).currApplicableLimit.Privilege_Paid_Leave__c) + (employeeAllData.get(eachId).oldEmpBalance.Privilege_Paid_Leave_in_days__c > 5 ? 5 : employeeAllData.get(eachId).oldEmpBalance.Privilege_Paid_Leave_in_days__c);
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
}