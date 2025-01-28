public class EmployeeProbationToPermanent {
    private class EmployeeWrappedData{
        private Employee__c employeeRecord {get; set;}
        private String employeeRegion {get; set;}
        private Decimal employeeAvailedCasualsSofar {get; set;}
        private Decimal employeeAvailedPaidLeaves {get; set;}
        
        private EmployeeWrappedData(Employee__c employeeRecord, String employeeRegion, Decimal employeeAvailedCasualsSofar, Decimal employeeAvailedPaidLeaves){
            this.employeeRecord = employeeRecord;
            this.employeeRegion = employeeRegion;
            this.employeeAvailedCasualsSofar = employeeAvailedCasualsSofar;
            this.employeeAvailedPaidLeaves = employeeAvailedPaidLeaves;
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
    Private Static Decimal servedProbationMonthsCalc(Employee__c employeeRecord){
        try{
            Decimal servedMonths = 0;
            date dateOfJoining = employeeRecord.DateofJoin__c;
            date dateMadePermanent = System.today();
            if(dateOfJoining.day() < = 15){
                servedMonths = dateOfJoining.monthsBetween(dateMadePermanent) + 1;
            }
            else{
                servedMonths = dateOfJoining.monthsBetween(dateMadePermanent); 
            }
            return servedMonths;
        }
        catch(Exception e){
            System.debug('Issue in: EmployeeProbationToPermanent @ servedProbationMonthsCalc method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            return null;
        }
    }
    private static Integer celebLeaveCalc(){
        try{
            if(System.now().month() < = 7){
                return 2;
            }
            else{
                return 1;
            }
        }
        catch(Exception e){
            System.debug('Issue in: EmployeeProbationToPermanent @ celebLeaveCalc method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            return null;
        }
    }
    public static void probationToPermanent (Set<Id> employeeMadePermanentId, Set<String> employeeRegions){
        try{
            String CurrYear = String.valueOf(System.now().year());
            List<Employee_Leave_Balance__c> toBeInsertedBalList = new List<Employee_Leave_Balance__c>(); 
            Map<Id, EmployeeWrappedData> allPermanentEmpData = new Map<Id, EmployeeWrappedData>();
            Map<Id, Employee__c> madePermanentEmployee = new Map<Id, Employee__c>([SELECT Id, Gender__c, Region__c, DateofJoin__c , (SELECT Id, Duration__c, Leave_Type__c, Status__c FROM Employee_Leaves__r WHERE Status__c != 'Rejected') FROM Employee__c WHERE Region__c IN: employeeRegions AND Id IN: employeeMadePermanentId]);
            List<Regional_Leave_Limit__c> CurrYearRegionalLimits = [SELECT Id, Region__c, Sick_Leave__c, Privilege_Paid_Leave__c, Bereavement_Leave__c, Casual_Leave__c, Restricted_Holiday__c, Paternity_Leave__c, Maternity_Leave__c FROM Regional_Leave_Limit__c WHERE Year__c =: CurrYear AND Employee_Status__c = 'Permanent'];
            for(Id eachEmpId : madePermanentEmployee.keySet()){
                Decimal casualsSoFar = 0;
                Decimal paidLeavesSoFar = 0;
                for(Employee_Leave__c eachLeave : madePermanentEmployee.get(eachEmpId).Employee_Leaves__r){
                    if(eachLeave.Leave_Type__c == 'Casual Leave'){
                        casualsSoFar+= eachLeave.Duration__c;
                    }
                    else if(eachLeave.Leave_Type__c == 'Privilege/Paid Leave'){
                        paidLeavesSoFar += eachLeave.Duration__c;
                    }
                }
                allPermanentEmpData.put(eachEmpId, new EmployeeWrappedData(madePermanentEmployee.get(eachEmpId), madePermanentEmployee.get(eachEmpId).Region__c, casualsSoFar, paidLeavesSoFar));
            }
            for(Id eachId : allPermanentEmpData.keyset()){
                EmployeeWrappedData currEmpWrappedData = allPermanentEmpData.get(eachId);
                Decimal proRataMonths = 12 - System.now().month();
                Decimal casualsAddOn = 0;
                Decimal PaidAddOns = 0;
                Decimal probationServedMonths = 0;
                probationServedMonths = servedProbationMonthsCalc(currEmpWrappedData.employeeRecord);
                casualsAddOn = probationServedMonths - currEmpWrappedData.employeeAvailedCasualsSofar;
                if(probationServedMonths - currEmpWrappedData.employeeAvailedPaidLeaves >10){
                    PaidAddOns = 10;
                }
                else{
                    PaidAddOns = probationServedMonths - currEmpWrappedData.employeeAvailedPaidLeaves;
                }
                
                Employee_Leave_Balance__c newEmpBal = new Employee_Leave_Balance__c ();
                for(Regional_Leave_Limit__c eachLimit : CurrYearRegionalLimits){
                    if(eachLimit.Region__c == currEmpWrappedData.employeeRegion){
                        newEmpBal.Employee_Status__c = 'Permanent';
                        newEmpBal.Employee__c = eachId;
                        newEmpBal.Sick_Leave__c = ProRataCalculation(eachLimit.Sick_Leave__c);
                        newEmpBal.Privilege_Paid_Leave_in_days__c = ProRataCalculationNoDecimals(eachLimit.Privilege_Paid_Leave__c) + PaidAddOns;
                        newEmpBal.Bereavement_Leave__c = ProRataCalculationNoDecimals(eachLimit.Bereavement_Leave__c);
                        newEmpBal.Celebration_Leave__c = celebLeaveCalc();
                        newEmpBal.Restricted_Holiday__c =  ProRataCalculationNoDecimals(eachLimit.Restricted_Holiday__c);
                        newEmpBal.Regional_Leave_Limit__c = eachLimit.Id;
                        if((((eachLimit.Casual_Leave__c/12)*proRataMonths) + casualsAddOn)>5){
                            newEmpBal.Casual_Leave__c = 5;
                        }
                        else{
                            newEmpBal.Casual_Leave__c = ProRataCalculation(eachLimit.Casual_Leave__c) + casualsAddOn; 
                        }
                        if(currEmpWrappedData.employeeRecord.Gender__c == 'Male'){
                            newEmpBal.Paternity_Leave__c = eachLimit.Paternity_Leave__c;
                        }
                        else if(currEmpWrappedData.employeeRecord.Gender__c == 'Female'){
                            newEmpBal.Maternity_Leave__c = eachLimit.Maternity_Leave__c;
                        }
                        
                    }
                    
                }
                toBeInsertedBalList.add(newEmpBal);
            }
            if(toBeInsertedBalList.size()> 0){
                insert toBeInsertedBalList;
            }  
        }
        catch(Exception e){
            System.debug('Issue in: EmployeeProbationToPermanent @ probationToPermanent method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
        }
    }
}