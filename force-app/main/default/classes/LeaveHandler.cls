/*------------------------------------------------------------
Author       :  Maaz Rahman
Company      :  CRMIT Pvt. Ltd.
Description  :  _
Inputs       :  Mentioned before each methods. No constructor for the LeaveHandler class.
Test Class   :  _

History
<Date>         <Authors Name>        <Brief Description of Change>
------------------------------------------------------------------*/
public without sharing class LeaveHandler {
    /**
      * @description Custom Exception.
      * 
      */
    private class CustomLogicException extends Exception {
    }
    private class FinalException extends Exception {
    }
    /**
      * @description Final values
      *
      */
    final static String CURRYEAR = String.valueOf(System.today().year());
    //final static String CURRYEAR = String.valueOf(2024);
    final static String LASTYEAR = String.valueOf(Integer.valueOf(CURRYEAR) - 1);
    
    /*probationer flag check 
     //Static variable to track if code has been executed before
     */
     private static Boolean hasLoaded = false;    
     
    /**
      * @description Region Mapping
      */
    final static Map<String, String> regionMapping = new Map<String, String>{
        'India' => 'IND',
        'Austrailia' => 'ANZ',
        'USA' => 'US'
    };
    /**
      * EmployeeBundle inner class that initializes the Object that includes the following data:
      * Carry Forward which adds up to the regional limit of current year.
      * EmpData all the neccessary employee data.
      * It also extends LeaveLimit abstract class containing all the regional leave limit data.
      * LeaveLimit also extends another abstract class that contains all the balance data of the employee.
      * @author Maaz
      * @since 03/07/2023
      */
    private inherited sharing class EmployeeBundle extends LeaveLimit{
        @AuraEnabled
        public Employee__c empData { get; set; }
        @AuraEnabled 
        public Decimal carryForwardCasual = 0;
        @AuraEnabled 
        public Decimal carryForwardSick = 0;
        @AuraEnabled 
        public Decimal carryForwardPrivilege = 0;
        @AuraEnabled 
        public Decimal carryForwardCelebration = 0;
        private Employee_Leave_Balance__c lastYearBalance = new Employee_Leave_Balance__c();
        private EmployeeBundle(Employee__c empData){
            this.empData = empData;
            if(this.empData.Region__c == null || this.empData.Region__c == ''){
                throw new CustomLogicException('Error: Region data is missing for your record, contact Admin Team');
            }
            else if(this.empData.Region__c == 'IND'){
               this.populateData(); 
            }
            else if(this.empData.Region__c == 'ANZ' || this.empData.Region__c == 'US'){
                this.populateAustraliaOrUsData();
            }
        }
        /**
          * This class method assigns all the values to inner class memeber variables.
          * This method also check and verify last year balance, limit, current year balance.
          * @author Maaz
          * @since 03/07/2023
          */
        public Employee__c  employeeDataToDetectLimitWFH(){
            try{
                List<Employee__c> empListForWFH = [SELECT Id, Name, Type__c, Grade__c, DateofJoin__c, Gender__c, Region__c, Country__c, SF_User__c, ReportingTo__r.SF_User__c, SF_User__r.Email, Enable_Paternity_Maternity__c, Enable_Bereavement__c, Paternity_Maternity_Leave_Count__c, Date_of_Birth__c, Date_of_Anniversary__c, Onsite_Experience__c, Geo_Date_of_Joining__c, ANZ_Workforce_Category__c FROM Employee__c WHERE SF_User__c = :UserInfo.getUserId() AND Region__c = 'IND' AND Type__c = 'Permanent' and Active__c = true   WITH SYSTEM_MODE];
                if(empListForWFH.size() == 1){
                    this.employData = empListForWFH[0];
                    return this.employData;
                }else if(empListForWFH.size() > 1){
                    throw new CustomLogicException('Error: Found multiple employee record, contact Admin Team.');
                }else{
                    throw new CustomLogicException('Error: No employee record found, contact Admin Team.');
                }
                
            }
            catch(Exception e){
                System.debug('Issue in: LeaveHandler @ employeeDataToDetectLimitWFH method');
                System.debug('Err Msg: ' + e.getMessage());
                System.debug('@ Line: ' + e.getLineNumber());
                throw new FinalException(e.getMessage());
            }
        }
        private void populateData(){
            try{
                List<Regional_Leave_Limit__c> regionList = [SELECT Employee_Status__c, Region__c, Bereavement_Leave__c, Sick_Leave__c, Casual_Leave__c, Privilege_Paid_Leave__c, Paternity_Leave__c, Maternity_Leave__c, Celebration_Leave__c, Restricted_Holiday__c, Loss_of_Pay_LOP__c, Long_Leave__c, CarryForward__c, Carry_Forward_Sick_Leave__c, Carry_Forward_Celebration_Leave__c, Carry_Forward_Privilege_Leave__c, WFH_B1_L1__c, WFH_B1_L2__c, WFH_B1_L3_to_L5__c, WFH_B2_M1_to_M3__c, WFH_D1_above__c, paid_Leave_Adjustment_Limit__c FROM Regional_Leave_Limit__c WHERE Region__c = :this.empData.Region__c AND Year__c =:CURRYEAR AND Employee_Status__c =:this.empData.Type__c WITH SYSTEM_MODE];
                List<Employee_Leave_Balance__c> balanceList = [SELECT Employee__c, Employee_Status__c, Work_from_Home__c, Bereavement_Leave__c, Sick_Leave__c, Casual_Leave__c, Privilege_Paid_Leave_in_days__c, Paternity_Leave__c, Maternity_Leave__c, Celebration_Leave__c, Restricted_Holiday__c, Loss_of_Pay_LOP__c, Long_Leave__c, CarryForward__c, CarryForward_Sick_Leave__c, Carry_Forward_Celebration_Leave__c, CarryForward_Privilege_Leave__c, Paid_Leave_Adjustment__c,Probationer_Casual_Leave_in_days__c,Probationer_Paid_Leave_in_days__c,hasLoaded__c FROM Employee_Leave_Balance__c WHERE Employee__c = :this.empData.Id AND Year__c = :CURRYEAR AND Active__c = true WITH SYSTEM_MODE];
                List<Employee_Leave_Balance__c> lastYearBalance = [SELECT Employee__c, Employee_Status__c, Work_from_Home__c, Bereavement_Leave__c, Sick_Leave__c, Casual_Leave__c, Privilege_Paid_Leave_in_days__c, Paternity_Leave__c, Maternity_Leave__c, Celebration_Leave__c, Restricted_Holiday__c, Loss_of_Pay_LOP__c, Long_Leave__c, CarryForward__c, CarryForward_Sick_Leave__c, Carry_Forward_Celebration_Leave__c, CarryForward_Privilege_Leave__c, Paid_Leave_Adjustment__c,Probationer_Casual_Leave_in_days__c,Probationer_Paid_Leave_in_days__c,hasLoaded__c FROM Employee_Leave_Balance__c WHERE Employee__c = :this.empData.Id AND Year__c = :LASTYEAR AND Employee_Status__c= :this.empData.Type__c WITH SYSTEM_MODE ORDER BY CreatedDate DESC Limit 1];
                List<Regional_Leave_Limit__c> lastYearRegionList = [SELECT Employee_Status__c, Region__c, Bereavement_Leave__c, Sick_Leave__c, Casual_Leave__c, Privilege_Paid_Leave__c, Paternity_Leave__c, Maternity_Leave__c, Celebration_Leave__c, Restricted_Holiday__c, Loss_of_Pay_LOP__c, Long_Leave__c, CarryForward__c, Carry_Forward_Sick_Leave__c, Carry_Forward_Celebration_Leave__c, Carry_Forward_Privilege_Leave__c, WFH_B1_L1__c, WFH_B1_L2__c, WFH_B1_L3_to_L5__c, WFH_B2_M1_to_M3__c, WFH_D1_above__c, paid_Leave_Adjustment_Limit__c FROM Regional_Leave_Limit__c WHERE Region__c = :this.empData.Region__c AND Year__c =:LASTYEAR AND Employee_Status__c =:this.empData.Type__c WITH SYSTEM_MODE];
                if(regionList.size() == 1){
                    this.regionData = regionList[0];
                }else if(regionList.size() > 1){
                    throw new CustomLogicException('Error: Found duplicate region data for employee type/current year, contact Admin Team');
                }else{
                    throw new CustomLogicException('Error: No active region data for employee type/current year, contact Admin Team');
                }
                if(lastYearBalance.size() > 0){
                    this.lastYearBalance = this.updateOldBalanceSheet(lastYearBalance[0]);
                    this.carryForwardCasual = this.lastYearBalance.CarryForward__c;
                    this.carryForwardSick = this.lastYearBalance.CarryForward_Sick_Leave__c;
                    this.carryForwardPrivilege = this.lastYearBalance.CarryForward_Privilege_Leave__c;
                    this.carryForwardCelebration = this.lastYearBalance.Carry_Forward_Celebration_Leave__c;
                }else{
                    this.lastYearBalance.CarryForward__c = 0;
                    this.lastYearBalance.CarryForward_Sick_Leave__c = 0;
                    this.lastYearBalance.CarryForward_Privilege_Leave__c = 0;
                    this.lastYearBalance.Carry_Forward_Celebration_Leave__c = 0;
                }
                if(balanceList.size() == 1){
                    System.debug('balanceList'+balanceList[0]);
                    this.balanceData = balanceList[0];
                    if(this.balanceData.Privilege_Paid_Leave_in_days__c < 5){ 
                        System.debug('this.regionData.paid_Leave_Adjustment_Limit__c'+ this.regionData.paid_Leave_Adjustment_Limit__c); 
                        System.debug('this.balanceData.Privilege_Paid_Leave_in_days__c'+ this.balanceData.Privilege_Paid_Leave_in_days__c); 
                        System.debug('checkIfTakenOnDec'+ checkIfTakenOnDec(this.empData.Id));
                        System.debug('checkIfPLAdjustmentTakenCurrYar'+ checkIfPLAdjustmentTakenCurrYear(this.empData.Id)); 
                        this.balanceData.Paid_Leave_Adjustment__c =  this.regionData.paid_Leave_Adjustment_Limit__c - this.balanceData.Privilege_Paid_Leave_in_days__c - checkIfTakenOnDec(this.empData.Id) - checkIfPLAdjustmentTakenCurrYear(this.empData.Id);
                        System.debug('this.balanceData.Paid_Leave_Adjustment__c'+ this.balanceData.Paid_Leave_Adjustment__c);   
                        if(this.balanceData.Paid_Leave_Adjustment__c < 0){
                            this.balanceData.Paid_Leave_Adjustment__c = 0;
                        }
                        else{
                            this.balanceData.Paid_Leave_Adjustment__c = this.balanceData.Paid_Leave_Adjustment__c;
                        }
                        if(this.empData.Type__c  == 'Probationer'){
                            this.balanceData.Paid_Leave_Adjustment__c += 1;
                           /* if(this.empData.DateofJoin__c.month() == System.today().month()){
                                if(this.empData.DateofJoin__c.day() < 15){
                                    this.balanceData.Probationer_Paid_Leave_in_days__c = 1;
                                    this.balanceData.Probationer_Casual_Leave_in_days__c = 1;
                                    this.balanceData.Privilege_Paid_Leave_in_days__c = 1;
                                    this.balanceData.Casual_Leave__c =1;
                                }
                                  
                                else if(this.empData.DateofJoin__c.day() >= 15){
                                    this.balanceData.Probationer_Paid_Leave_in_days__c = 0;
                                    this.balanceData.Probationer_Casual_Leave_in_days__c = 0;
                                    this.balanceData.Privilege_Paid_Leave_in_days__c = 0;
                                    this.balanceData.Casual_Leave__c =0;                                   
                                    
                                }
                                this.regionData.Privilege_Paid_Leave__c = this.balanceData.Probationer_Paid_Leave_in_days__c;
                                    this.regionData.Casual_Leave__c = this.balanceData.Probationer_Casual_Leave_in_days__c;
                                    system.debug('probationers: this.regionData.Casual_Leave__c'+this.regionData.Casual_Leave__c);
                                    system.debug('this.balanceData.Probationer_Paid_Leave_in_days__c probationers>>>'+this.balanceData.Probationer_Paid_Leave_in_days__c);
                                                                    
                            }*/
                        }
                    
                    else{
                        this.balanceData.Paid_Leave_Adjustment__c = 0;
                    }
                    }
                    //To load this method for the first time when probationer created, 2nd time batch/Schedule will be crediting the leaves
                    
                    if(this.empData.Type__c  == 'Probationer'){  
                        system.debug(this.empData.DateofJoin__c.month() == System.today().month());
                        if (balanceList[0].hasLoaded__c) {
                             system.debug('inside if');
                            system.debug('this.empData.DateofJoin__c.month()>>>>>>>>>>>>>'+this.empData.DateofJoin__c.month());
                            system.debug('System.today().month()'+System.today().month());
                            system.debug('this.empData.DateofJoin__c.day()'+this.empData.DateofJoin__c.day());
                                 if(this.empData.DateofJoin__c.month() == System.today().month()){
                                      system.debug('inside else');
                                if(this.empData.DateofJoin__c.day() < 15){
                                    this.balanceData.Probationer_Paid_Leave_in_days__c = 1;
                                    this.balanceData.Probationer_Casual_Leave_in_days__c = 1;
                                    this.balanceData.Privilege_Paid_Leave_in_days__c = 1;
                                    this.balanceData.Casual_Leave__c =1;
                                    system.debug('this.balanceData.Probationer_Paid_Leave_in_days__c>>>>>>>>>>>'+this.balanceData.Probationer_Paid_Leave_in_days__c);
                                    system.debug('this.balanceData.Probationer_Casual_Leave_in_days__c>>>>>>>>>>'+this.balanceData.Probationer_Casual_Leave_in_days__c);
                                }
                                  
                                else if(this.empData.DateofJoin__c.day() >= 15){
                                    system.debug('inside else if');
                                    this.balanceData.Probationer_Paid_Leave_in_days__c = 0;
                                    this.balanceData.Probationer_Casual_Leave_in_days__c = 0;
                                    this.balanceData.Privilege_Paid_Leave_in_days__c = 0;
                                    this.balanceData.Casual_Leave__c =0;                                   
                                    
                                }
                                this.regionData.Privilege_Paid_Leave__c = this.balanceData.Probationer_Paid_Leave_in_days__c;
                                    this.regionData.Casual_Leave__c = this.balanceData.Probationer_Casual_Leave_in_days__c;
                                    system.debug('probationers: this.regionData.Casual_Leave__c'+this.regionData.Casual_Leave__c);
                                    system.debug('this.balanceData.Probationer_Paid_Leave_in_days__c probationers>>>'+this.balanceData.Probationer_Paid_Leave_in_days__c);
                                   // balanceList[0].hasLoaded__c = false;   
                                     this.balanceData.hasLoaded__c = false;
                                     system.debug('this.balanceData.hasLoaded__c'+this.balanceData.hasLoaded__c);
                                         
                                    update regionData;
                            }                                 
                             }
                        
                        else if(this.empData.DateofJoin__c.month() != System.today().month()){
                            system.debug('inside else');
                            system.debug('this.balanceData.hasLoaded__c'+this.balanceData.hasLoaded__c);
                        system.debug(this.empData.DateofJoin__c.month() != System.today().month());
                         List<Employee_Leave_Balance__c> balanceList1 = [SELECT Employee__c, Employee_Status__c, Work_from_Home__c, Bereavement_Leave__c, Sick_Leave__c, Casual_Leave__c, Privilege_Paid_Leave_in_days__c, Paternity_Leave__c, Maternity_Leave__c, Celebration_Leave__c, Restricted_Holiday__c, Loss_of_Pay_LOP__c, Long_Leave__c, CarryForward__c, CarryForward_Sick_Leave__c, Carry_Forward_Celebration_Leave__c, CarryForward_Privilege_Leave__c, Paid_Leave_Adjustment__c,Probationer_Casual_Leave_in_days__c,Probationer_Paid_Leave_in_days__c,hasLoaded__c FROM Employee_Leave_Balance__c WHERE Employee__c = :this.empData.Id AND Year__c = :CURRYEAR AND Active__c = true WITH SYSTEM_MODE];
                             system.debug('balanceList1'+balanceList1);
                             this.regionData.Privilege_Paid_Leave__c = this.balanceData.Probationer_Paid_Leave_in_days__c;
                                    this.regionData.Casual_Leave__c = this.balanceData.Probationer_Casual_Leave_in_days__c;
                            this.balanceData.Privilege_Paid_Leave_in_days__c = balanceData.Privilege_Paid_Leave_in_days__c;
                            this.balanceData.Casual_Leave__c = balanceData.Casual_Leave__c;
                            update regionData;
                        }
                    
                    update this.balanceData;   
                    
                    
                }
                }else if(balanceList.size() > 1){
                    throw new CustomLogicException('Error: Found duplicate leave balance for current year, contact Admin Team');
                }else{
                    this.balanceData = this.generateBalanceSheet();
                }
                if(lastYearRegionList.size() == 0){
                    lastYearRegionList.add(this.generateLastYearLimit());
                }
                if(this.empData.Type__c != 'Permanent'){
                    return;
                }
                LeaveAdjustment leaveAdjustObj = new LeaveAdjustment(this.regionData, this.balanceData, lastYearRegionList[0],employeeDataToDetectLimitWFH());
                if(leaveAdjustObj.isFixingRequired && lastYearBalance.size() == 0){
                    Map<String, Decimal> adjustLeaveCount = leaveAdjustObj.fixLeaveData();
                    this.carryForwardCasual = adjustLeaveCount.get('Casual');
                    this.carryForwardSick = adjustLeaveCount.get('Sick');
                    this.carryForwardPrivilege = adjustLeaveCount.get('Privilege');
                    this.carryForwardCelebration = adjustLeaveCount.get('Celebration');
                }
            }catch(Exception e){
                System.debug('Issue in: LeaveHandler @ populateData method');
                System.debug('Err Msg: ' + e.getMessage());
                System.debug('@ Line: ' + e.getLineNumber());
                throw new FinalException(e.getMessage());
            }
        }
        public void populateAustraliaOrUsData(){
            try{
                List<Regional_Leave_Limit__c> regionList = [SELECT Employee_Status__c, Region__c, Bereavement_Leave__c, Sick_Leave__c, Casual_Leave__c, Privilege_Paid_Leave__c, Paternity_Leave__c, Maternity_Leave__c, Celebration_Leave__c, Restricted_Holiday__c, Loss_of_Pay_LOP__c, Long_Leave__c, CarryForward__c, Carry_Forward_Sick_Leave__c, Carry_Forward_Celebration_Leave__c, Carry_Forward_Privilege_Leave__c, WFH_B1_L1__c, WFH_B1_L2__c, WFH_B1_L3_to_L5__c, WFH_B2_M1_to_M3__c, WFH_D1_above__c, paid_Leave_Adjustment_Limit__c FROM Regional_Leave_Limit__c WHERE Region__c = :this.empData.Region__c AND Year__c =:CURRYEAR AND Employee_Status__c =:this.empData.ANZ_Workforce_Category__c WITH SYSTEM_MODE];
                List<Employee_Leave_Balance__c> balanceList = [SELECT Employee__c, Employee_Status__c, Work_from_Home__c, Bereavement_Leave__c, Sick_Leave__c, Casual_Leave__c, Privilege_Paid_Leave_in_days__c, Paternity_Leave__c, Maternity_Leave__c, Celebration_Leave__c, Restricted_Holiday__c, Loss_of_Pay_LOP__c, Long_Leave__c, CarryForward__c, CarryForward_Sick_Leave__c, Carry_Forward_Celebration_Leave__c, CarryForward_Privilege_Leave__c, Paid_Leave_Adjustment__c FROM Employee_Leave_Balance__c WHERE Employee__c = :this.empData.Id AND Year__c = :CURRYEAR AND Active__c = true WITH SYSTEM_MODE];
                List<Employee_Leave_Balance__c> lastYearBalance = [SELECT Employee__c, Employee_Status__c, Work_from_Home__c, Bereavement_Leave__c, Sick_Leave__c, Casual_Leave__c, Privilege_Paid_Leave_in_days__c, Paternity_Leave__c, Maternity_Leave__c, Celebration_Leave__c, Restricted_Holiday__c, Loss_of_Pay_LOP__c, Long_Leave__c, CarryForward__c, CarryForward_Sick_Leave__c, Carry_Forward_Celebration_Leave__c, CarryForward_Privilege_Leave__c, Paid_Leave_Adjustment__c FROM Employee_Leave_Balance__c WHERE Employee__c = :this.empData.Id AND Region__c=:this.empData.Region__c AND Year__c = :LASTYEAR WITH SYSTEM_MODE ORDER BY CreatedDate DESC Limit 1];
                List<Regional_Leave_Limit__c> lastYearRegionList = [SELECT Employee_Status__c, Region__c, Bereavement_Leave__c, Sick_Leave__c, Casual_Leave__c, Privilege_Paid_Leave__c, Paternity_Leave__c, Maternity_Leave__c, Celebration_Leave__c, Restricted_Holiday__c, Loss_of_Pay_LOP__c, Long_Leave__c, CarryForward__c, Carry_Forward_Sick_Leave__c, Carry_Forward_Celebration_Leave__c, Carry_Forward_Privilege_Leave__c, WFH_B1_L1__c, WFH_B1_L2__c, WFH_B1_L3_to_L5__c, WFH_B2_M1_to_M3__c, WFH_D1_above__c, paid_Leave_Adjustment_Limit__c FROM Regional_Leave_Limit__c WHERE Region__c = :this.empData.Region__c AND Year__c =:LASTYEAR AND Employee_Status__c =:this.empData.ANZ_Workforce_Category__c WITH SYSTEM_MODE];
                if(regionList.size() == 1){
                    this.regionData = regionList[0];
                }else if(regionList.size() > 1){
                    throw new CustomLogicException('Error: Found duplicate region data for employee type/current year, contact Admin Team');
                }else{
                    throw new CustomLogicException('Error: No active region data for employee type/current year, contact Admin Team');
                }
                if(lastYearBalance.size() > 0){
                    this.lastYearBalance = this.updateOldBalanceSheet(lastYearBalance[0]);
                    this.carryForwardCasual = this.lastYearBalance.CarryForward__c;
                    this.carryForwardSick = this.lastYearBalance.CarryForward_Sick_Leave__c;
                    this.carryForwardPrivilege = this.lastYearBalance.CarryForward_Privilege_Leave__c;
                    this.carryForwardCelebration = this.lastYearBalance.Carry_Forward_Celebration_Leave__c;
                }else{
                    this.lastYearBalance.CarryForward__c = 0;
                    this.lastYearBalance.CarryForward_Sick_Leave__c = 0;
                    this.lastYearBalance.CarryForward_Privilege_Leave__c = 0;
                    this.lastYearBalance.Carry_Forward_Celebration_Leave__c = 0;
                }
                System.debug('_______________________');
                System.debug(this.lastYearBalance.CarryForward_Privilege_Leave__c);
                System.debug(this.lastYearBalance);
                System.debug('_______________________');
                if(balanceList.size() == 1){
                    this.balanceData = balanceList[0];
                    if(this.balanceData.Privilege_Paid_Leave_in_days__c < 5){ 
                        this.balanceData.Paid_Leave_Adjustment__c =  this.regionData.paid_Leave_Adjustment_Limit__c - this.balanceData.Privilege_Paid_Leave_in_days__c - checkIfTakenOnDec(this.empData.Id) - checkIfPLAdjustmentTakenCurrYear(this.empData.Id);
                        System.debug('this.balanceData.Paid_Leave_Adjustment__c'+ this.balanceData.Paid_Leave_Adjustment__c);   
                        if(this.balanceData.Paid_Leave_Adjustment__c < 0){
                            this.balanceData.Paid_Leave_Adjustment__c = 0;
                        }
                        else{
                            this.balanceData.Paid_Leave_Adjustment__c = this.balanceData.Paid_Leave_Adjustment__c;
                        }
                    }
                    else{
                        this.balanceData.Paid_Leave_Adjustment__c = 0;
                    }
                    update this.balanceData;             
                }else if(balanceList.size() > 1){
                    throw new CustomLogicException('Error: Found duplicate leave balance for current year, contact Admin Team');
                }else{
                    this.balanceData = this.empData.Region__c == 'ANZ'? this.generateBalanceSheetANZ() : this.generateBalanceSheet();
                }
                if(lastYearRegionList.size() == 0){
                    lastYearRegionList.add(this.generateLastYearLimit());
                }
            }
            catch(Exception e){
                System.debug('Issue in: LeaveHandler @ populateAustraliaData method');
                System.debug('Err Msg: ' + e.getMessage());
                System.debug('@ Line: ' + e.getLineNumber());
                throw new FinalException(e.getMessage());
            }
        }
        /**
          * This function updates the last year's balance sheet of an employee's leave based on the region data and the carry forward rules.
          * @warning The calculation should happen once. Do NOT edit lastYearSheet once it is generated.
          * @param {Employee_Leave_Balance__c} lastYearSheet - The last year's balance sheet of an employee's leave.
          * @return {Employee_Leave_Balance__c} The updated balance sheet of an employee's leave.
          * @author Maaz
          * @since 03/07/2023
          */
        private Employee_Leave_Balance__c updateOldBalanceSheet(Employee_Leave_Balance__c lastYearSheet){
            // Check if any of the leave types can be carried forward from the last year.
            if(
                (this.regionData.CarryForward__c > 0 && lastYearSheet.Casual_Leave__c != 0 && (lastYearSheet.CarryForward__c == 0 || lastYearSheet.CarryForward__c == null)) ||
                (this.regionData.Carry_Forward_Sick_Leave__c > 0 && lastYearSheet.Sick_Leave__c != 0 && (lastYearSheet.CarryForward_Sick_Leave__c == 0 || lastYearSheet.CarryForward_Sick_Leave__c == null)) ||
                (this.regionData.Carry_Forward_Privilege_Leave__c > 0 && lastYearSheet.Privilege_Paid_Leave_in_days__c != 0 && (lastYearSheet.CarryForward_Privilege_Leave__c == 0 || lastYearSheet.CarryForward_Privilege_Leave__c == null)) ||
                (this.regionData.Carry_Forward_Celebration_Leave__c > 0 && lastYearSheet.Celebration_Leave__c != 0 && (lastYearSheet.Carry_Forward_Celebration_Leave__c == 0 || lastYearSheet.Carry_Forward_Celebration_Leave__c == null))
            ){
                // Calculate the carry forward amount for each leave type based on the region data and the available balance.
                lastYearSheet.CarryForward__c = this.regionData.CarryForward__c > 0 ? (this.regionData.CarryForward__c > lastYearSheet.Casual_Leave__c ? lastYearSheet.Casual_Leave__c : this.regionData.CarryForward__c ) : 0;
                lastYearSheet.Casual_Leave__c = this.regionData.CarryForward__c > 0 ?  (lastYearSheet.Casual_Leave__c > this.regionData.CarryForward__c ? lastYearSheet.Casual_Leave__c - this.regionData.CarryForward__c : 0) : lastYearSheet.Casual_Leave__c;
                lastYearSheet.CarryForward_Sick_Leave__c = this.regionData.Carry_Forward_Sick_Leave__c > 0 ? (this.regionData.Carry_Forward_Sick_Leave__c > lastYearSheet.Sick_Leave__c ? lastYearSheet.Sick_Leave__c : this.regionData.Carry_Forward_Sick_Leave__c ) : 0;
                lastYearSheet.Sick_Leave__c = this.regionData.Carry_Forward_Sick_Leave__c > 0 ?  (lastYearSheet.Sick_Leave__c > this.regionData.Carry_Forward_Sick_Leave__c ? lastYearSheet.Sick_Leave__c - this.regionData.Carry_Forward_Sick_Leave__c : 0) : lastYearSheet.Sick_Leave__c;
                lastYearSheet.CarryForward_Privilege_Leave__c = this.regionData.Carry_Forward_Privilege_Leave__c > 0 ? (this.regionData.Carry_Forward_Privilege_Leave__c > lastYearSheet.Privilege_Paid_Leave_in_days__c ? lastYearSheet.Privilege_Paid_Leave_in_days__c : this.regionData.Carry_Forward_Privilege_Leave__c ) : 0;
                lastYearSheet.Privilege_Paid_Leave_in_days__c = this.regionData.Carry_Forward_Privilege_Leave__c > 0 ?  (lastYearSheet.Privilege_Paid_Leave_in_days__c > this.regionData.Carry_Forward_Privilege_Leave__c ? lastYearSheet.Privilege_Paid_Leave_in_days__c - this.regionData.Carry_Forward_Privilege_Leave__c : 0) : lastYearSheet.Privilege_Paid_Leave_in_days__c;
                lastYearSheet.Carry_Forward_Celebration_Leave__c = this.regionData.Carry_Forward_Celebration_Leave__c > 0 ? (this.regionData.Carry_Forward_Celebration_Leave__c > lastYearSheet.Celebration_Leave__c ? lastYearSheet.Celebration_Leave__c : this.regionData.Carry_Forward_Celebration_Leave__c ) : 0;
                lastYearSheet.Celebration_Leave__c = this.regionData.Carry_Forward_Celebration_Leave__c > 0 ?  (lastYearSheet.Celebration_Leave__c > this.regionData.Carry_Forward_Celebration_Leave__c ? lastYearSheet.Celebration_Leave__c - this.regionData.Carry_Forward_Celebration_Leave__c : 0) : lastYearSheet.Celebration_Leave__c;
                update as system lastYearSheet;
            }
            return lastYearSheet;
        }
        /**
          * This function generates a new balance sheet of an employee's leave based on the region data, the last year's balance sheet and the leave rules.
          * @return {Employee_Leave_Balance__c} The new balance sheet of an employee's leave.
          * @throws {FinalException} If there is any error in the process.
          * @author Maaz
          * @since 03/07/2023
          */
        private Employee_Leave_Balance__c generateBalanceSheet(){
            try {
                Employee_Leave_Balance__c newELB = new Employee_Leave_Balance__c();
                newELB.Regional_Leave_Limit__c = this.regionData.Id;
                newELB.Bereavement_Leave__c = this.regionData.Bereavement_Leave__c;
                newELB.Sick_Leave__c = this.regionData.Carry_Forward_Sick_Leave__c > 0 ? (this.regionData.Carry_Forward_Sick_Leave__c > this.lastYearBalance.CarryForward_Sick_Leave__c ? this.lastYearBalance.CarryForward_Sick_Leave__c + this.regionData.Sick_Leave__c : this.regionData.Carry_Forward_Sick_Leave__c + this.regionData.Sick_Leave__c) : this.regionData.Sick_Leave__c ;
                newELB.Casual_Leave__c = this.regionData.CarryForward__c > 0 ? (this.regionData.CarryForward__c > this.lastYearBalance.CarryForward__c ? this.lastYearBalance.CarryForward__c + this.regionData.Casual_Leave__c : this.regionData.CarryForward__c + this.regionData.Casual_Leave__c) : this.regionData.Casual_Leave__c ;
                newELB.Privilege_Paid_Leave_in_days__c = this.regionData.Carry_Forward_Privilege_Leave__c > 0 ? (this.regionData.Carry_Forward_Privilege_Leave__c > this.lastYearBalance.CarryForward_Privilege_Leave__c ? this.lastYearBalance.CarryForward_Privilege_Leave__c + this.regionData.Privilege_Paid_Leave__c - checkIfPLAdjustmentTaken(this.empData.Id) : this.regionData.Carry_Forward_Privilege_Leave__c + this.regionData.Privilege_Paid_Leave__c - checkIfPLAdjustmentTaken(this.empData.Id)) : this.regionData.Privilege_Paid_Leave__c - checkIfPLAdjustmentTaken(this.empData.Id);
                newELB.Paternity_Leave__c = this.regionData.Paternity_Leave__c;
                newELB.Maternity_Leave__c = this.regionData.Maternity_Leave__c;
                newELB.Work_from_Home__c = decideEmpGradeBasedWfhAllowance(this.empData, this.regionData);
                newELB.Celebration_Leave__c = this.regionData.Carry_Forward_Celebration_Leave__c > 0 ? (this.regionData.Carry_Forward_Celebration_Leave__c > this.lastYearBalance.Carry_Forward_Celebration_Leave__c ? this.lastYearBalance.Carry_Forward_Celebration_Leave__c + this.regionData.Celebration_Leave__c : this.regionData.Carry_Forward_Celebration_Leave__c + this.regionData.Celebration_Leave__c) : this.regionData.Celebration_Leave__c;
                newELB.Restricted_Holiday__c = this.regionData.Restricted_Holiday__c;
                newELB.Loss_of_Pay_LOP__c = this.regionData.Loss_of_Pay_LOP__c;
                newELB.Long_Leave__c = this.regionData.Long_Leave__c;
                newELB.Employee__c = this.empData.Id;
                newELB.Employee_Status__c = this.empData.Region__c == 'IND'? this.empData.Type__c : this.regionData.Employee_Status__c;
                insert as system newELB;
                return newELB;
            } catch (Exception e) {
                System.debug('Issue in: LeaveHandler @ generateBalanceSheet method');
                System.debug('Err Msg: ' + e.getMessage());
                System.debug('@ Line: ' + e.getLineNumber());
                throw new FinalException(e.getMessage());
            }
        }
        private Employee_Leave_Balance__c generateBalanceSheetANZ(){
            try {
                Employee_Leave_Balance__c newELB = new Employee_Leave_Balance__c();
                newELB.Regional_Leave_Limit__c = this.regionData.Id;
                newELB.Bereavement_Leave__c = this.regionData.Bereavement_Leave__c;
                newELB.Sick_Leave__c = this.regionData.Carry_Forward_Sick_Leave__c > 0 ? (this.regionData.Carry_Forward_Sick_Leave__c > this.lastYearBalance.CarryForward_Sick_Leave__c ? this.lastYearBalance.CarryForward_Sick_Leave__c + this.regionData.Sick_Leave__c : this.regionData.Carry_Forward_Sick_Leave__c + this.regionData.Sick_Leave__c) : this.regionData.Sick_Leave__c ;
                newELB.Casual_Leave__c = this.regionData.CarryForward__c > 0 ? (this.regionData.CarryForward__c > this.lastYearBalance.CarryForward__c ? this.lastYearBalance.CarryForward__c + this.regionData.Casual_Leave__c : this.regionData.CarryForward__c + this.regionData.Casual_Leave__c) : this.regionData.Casual_Leave__c ;
                newELB.Privilege_Paid_Leave_in_days__c = this.regionData.Carry_Forward_Privilege_Leave__c > 0 ? (this.regionData.Carry_Forward_Privilege_Leave__c > this.lastYearBalance.CarryForward_Privilege_Leave__c ? this.lastYearBalance.CarryForward_Privilege_Leave__c + 1 - checkIfPLAdjustmentTaken(this.empData.Id) : this.regionData.Carry_Forward_Privilege_Leave__c + 1 - checkIfPLAdjustmentTaken(this.empData.Id)) : 1 - checkIfPLAdjustmentTaken(this.empData.Id);
                newELB.Paternity_Leave__c = this.regionData.Paternity_Leave__c;
                newELB.Maternity_Leave__c = this.regionData.Maternity_Leave__c;                
                newELB.Celebration_Leave__c = this.regionData.Carry_Forward_Celebration_Leave__c > 0 ? (this.regionData.Carry_Forward_Celebration_Leave__c > this.lastYearBalance.Carry_Forward_Celebration_Leave__c ? this.lastYearBalance.Carry_Forward_Celebration_Leave__c + this.regionData.Celebration_Leave__c : this.regionData.Carry_Forward_Celebration_Leave__c + this.regionData.Celebration_Leave__c) : this.regionData.Celebration_Leave__c;
                newELB.Restricted_Holiday__c = this.regionData.Restricted_Holiday__c;
                newELB.Loss_of_Pay_LOP__c = this.regionData.Loss_of_Pay_LOP__c;
                newELB.Long_Leave__c = isSeniorNearingDeacades() ? (this.lastYearBalance.Long_Leave__c == 0 ? (empLongLeavesIsNotAvailed() ? this.regionData.Long_Leave__c : 0) : this.lastYearBalance.Long_Leave__c) : this.lastYearBalance.Long_Leave__c; 
                newELB.Employee__c = this.empData.Id;
                newELB.Employee_Status__c = this.regionData.Employee_Status__c;
                insert as system newELB;
                return newELB;
            } catch (Exception e) {
                System.debug('Issue in: LeaveHandler @ generateBalanceSheet method');
                System.debug('Err Msg: ' + e.getMessage());
                System.debug('@ Line: ' + e.getLineNumber());
                throw new FinalException(e.getMessage());
            }
        }
        private Boolean empLongLeavesIsNotAvailed(){
            try{
                List<Employee_Leave__c> empLongLeaveList = [SELECT Id FROM Employee_Leave__c WHERE Leave_Type__c = 'Long Leave' AND Year__c =: LASTYEAR AND Employee__c =: this.empData.Id ];
                if(empLongLeaveList.size() == 0){
                    return true;
                }
                else{
                    return false;
                }
            } catch (Exception e) {
                System.debug('Issue in: LeaveHandler @ empLongLeavesIsAvailed method');
                System.debug('Err Msg: ' + e.getMessage());
                System.debug('@ Line: ' + e.getLineNumber());
                throw new FinalException(e.getMessage());
            }
        }
        private Boolean isSeniorNearingDeacades(){
            try{
                Decimal remainder = 0;
                if(this.empData.Onsite_Experience__c != 0){
                    Decimal firstResult = this.empData.Onsite_Experience__c / 10; 
                    Decimal flooredResult = math.floor(firstResult);
                    Decimal flooredProduct = flooredResult * 10;
                    remainder = this.empData.Onsite_Experience__c - flooredProduct; 
                }
                if(remainder == 1){
                    return true;
                }
                else{
                    return false;
                }
            }catch (Exception e) {
                System.debug('Issue in: LeaveHandler @ isSeniorNearingDeacades method');
                System.debug('Err Msg: ' + e.getMessage());
                System.debug('@ Line: ' + e.getLineNumber());
                throw new FinalException(e.getMessage());
            }
        }
        /**
          * This function generates a new regional leave limit for the last year based on the region data and the employee status.
          * @return {Regional_Leave_Limit__c} The new regional leave limit for the last year.
          * @author Maaz
          * @since 03/07/2023
          */
        private Regional_Leave_Limit__c generateLastYearLimit(){
            Regional_Leave_Limit__c oldRegionalLimit = new Regional_Leave_Limit__c();
            oldRegionalLimit.Region__c = this.regionData.Region__c;
            oldRegionalLimit.Year__c = LASTYEAR;
            oldRegionalLimit.Employee_Status__c = this.regionData.Employee_Status__c;
            insert as system oldRegionalLimit;
            return oldRegionalLimit;
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
            System.debug('Issue in: LeaveHandler @ decideEmpGradeBasedWfhAllowance method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber()); 
            return null;
        }
    }
    private static Decimal checkIfPLAdjustmentTaken(Id empId){
        try{
            List<Employee_Leave__c> empPLAdjustmentLeave = [SELECT Id, Leave_Type__c, Duration__c, Start_Date__c, End_Date__c FROM Employee_Leave__c WHERE Leave_Type__c = 'paid Leave Adjustment' AND Year__c =: LASTYEAR AND Employee__c =: empId];
            if(empPLAdjustmentLeave.size() > 0){
                Decimal duration = 0.0;
                for(Employee_Leave__c empLeave : empPLAdjustmentLeave){
                    duration += empLeave.Duration__c;
                }
                return duration;
            }
            else{
                return 0;
            }
        }
        catch(Exception e){
            System.debug('Issue in: LeaveHandler @ checkIfPLAdjustmentTaken method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber()); 
            return null;
        }
    }
    private static Decimal checkIfPLAdjustmentTakenCurrYear(Id empId){
        try{
            List<Employee_Leave__c> empPLAdjustmentLeave = [SELECT Id, Leave_Type__c, Duration__c, Start_Date__c, End_Date__c FROM Employee_Leave__c WHERE Leave_Type__c = 'paid Leave Adjustment' AND Year__c =: CURRYEAR AND Employee__c =: empId];
            if(empPLAdjustmentLeave.size() > 0){
                Decimal duration = 0.0;
                for(Employee_Leave__c empLeave : empPLAdjustmentLeave){
                    duration += empLeave.Duration__c;
                }
                return duration;
            }
            else{
                return 0;
            }
        }
        catch(Exception e){
            System.debug('Issue in: LeaveHandler @ checkIfPLAdjustmentTaken method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber()); 
            return null;
        }
    }
    private static Decimal checkIfTakenOnDec(Id empId){
        try{
            List<Employee_Leave__c> empPLLeave = [SELECT Id, Leave_Type__c, Duration__c, Start_Date__c, End_Date__c FROM Employee_Leave__c WHERE Employee__c =: empId AND Leave_Type__c = 'Privilege/Paid Leave' AND Year__c =: CURRYEAR  AND ((DAY_IN_MONTH(Start_Date__c) > 25 OR DAY_IN_MONTH(End_Date__c) >= 25) AND CALENDAR_MONTH(Start_Date__c) = 12)];
            System.debug('empPLLeave'+ empPLLeave);
            System.debug('empPLLeave size'+empPLLeave.size());
            if(empPLLeave.size() > 0){
                Decimal duration = 0.0;
                for(Employee_Leave__c empLeave : empPLLeave){
                    if(empLeave.Start_Date__c.Day() >= 25){
                        duration += empLeave.Duration__c;
                    }
                    else if(empLeave.End_Date__c.Day() == 25){
                        duration += 1;
                    }
                    else if(empLeave.End_Date__c.Day() > 25 && empLeave.Start_Date__c.Day() < 25){
                        duration += ((empLeave.End_Date__c.Day() - 25) + 1);
                    }
                }
                System.debug('duration'+duration);
                return duration;
            }
            else{
                return 0; 
            }
        }
        catch(Exception e){
            System.debug('Issue in: LeaveHandler @ checkIfTakenOnDec method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber()); 
            return null;
        }
    }
    /**
      * This function returns the employee details of the current user based on a query from the Employee__c object.
      * @return {EmployeeBundle} The employee details of the current user wrapped in an EmployeeBundle object.
      * @throws {CustomLogicException} If there is any error in the query or the employee data.
      * @throws {FinalException} If there is any other exception in the process.
      * @AuraEnabled This function can be called from an Aura/LWC component.
      * @author Maaz
      * @since 03/07/2023
      */
    @AuraEnabled
    public static EmployeeBundle getEmployeeDetails() {
        try{
            List<Employee__c> empList = [SELECT Id, Name, Type__c, DateofJoin__c, Gender__c, Region__c, Country__c, SF_User__c, ReportingTo__r.SF_User__c, SF_User__r.Email, Enable_Paternity_Maternity__c, Enable_Bereavement__c, Paternity_Maternity_Leave_Count__c, Date_of_Birth__c, Date_of_Anniversary__c, Onsite_Experience__c, Geo_Date_of_Joining__c, ANZ_Workforce_Category__c FROM Employee__c WHERE SF_User__c = :UserInfo.getUserId() and Active__c = true WITH SYSTEM_MODE];
            System.debug('emp>>'+empList);
            System.debug('emp size'+empList.size());
            System.debug('user>>'+UserInfo.getUserId());
            if(empList.size() == 1){
                if(empList[0].Region__c == null || empList[0].Region__c == ''){
                    if(regionMapping.containsKey(empList[0].Country__c)){
                        empList[0].Region__c = regionMapping.get(empList[0].Country__c);
                        update as system empList[0];
                    }else{
                        throw new CustomLogicException('Error: Both Region and Country data is missing, contact Admin Team');
                    }
                }
                // TODO: IND Region Restriction
                if(empList[0].Region__c != 'IND' && empList[0].Region__c != 'ANZ' && empList[0].Region__c != 'US'){
                    throw new CustomLogicException('Error: App is currently available for Indian Employees. Sorry for the inconvenience.');
                }
                if(empList[0].Type__c == 'Probationer' && empList[0].DateofJoin__c == null){
                    throw new CustomLogicException('Error: Date of joining is missing for the employee, contact Admin Team.');
                }
                return new EmployeeBundle(empList[0]);
            }else if(empList.size() > 1){
                throw new CustomLogicException('Error: Found multiple employee record, contact Admin Team.');
            }else{
                throw new CustomLogicException('Error: No employee record found, contact Admin Team.');
            }
        }catch (Exception e) {
            System.debug('Issue in: LeaveHandler @ getEmployeeDetails method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            throw new FinalException(e.getMessage());
        }
    }
    /**
      * This function returns a list of all other active employees except the current user based on a query from the Employee__c object.
      * @return {List<Employee__c>} The list of all other active employees except the current user.
      * @throws {FinalException} If there is any error in the process.
      * @AuraEnabled(cacheable=true) This function can be called from an Aura/LWC component and can be cached on the client side.
      * @author Maaz
      * @since 03/07/2023
      */
    @AuraEnabled(cacheable=true)
    public static List<Employee__c> allOtherEmployees(){
        try {
            List<Employee__c> empList = [SELECT Id, Name, Email_ID__c,EmployeeID__c,SF_User__r.FullPhotoUrl  FROM Employee__c WHERE Active__c = true WITH SYSTEM_MODE];
            return empList;
        } catch (Exception e) {
            System.debug('Issue in: LeaveHandler @ allOtherEmployees method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            throw new FinalException(e.getMessage());
        }
    }
    /**
      * This function returns a list of existing leaves of the current user for the current year based on a query from the Employee_Leave__c object.
      * @return {List<Employee_Leave__c>} The list of existing leaves of the current user for the current year.
      * @throws {CustomLogicException} If there is any error in the query or the employee data.
      * @throws {FinalException} If there is any other exception in the process.
      * @AuraEnabled(cacheable=true) This function can be called from an Aura/LWC component and can be cached on the client side.
      * @author Maaz
      * @since 03/07/2023
      */
    @AuraEnabled(cacheable=true)
    public static List<Employee_Leave__c> existingLeaves(){
        try {
            System.debug('user is>>'+UserInfo.getUserId());
            List<Employee__c> empList = [SELECT Id FROM Employee__c WHERE SF_User__c = :UserInfo.getUserId() and Active__c = true WITH SYSTEM_MODE];
            System.debug('emp >>>'+empList);
            System.debug('emp size>>>>'+empList.size());
            System.debug('user after query is>>'+UserInfo.getUserId());
            if(empList.size() > 1){
                throw new CustomLogicException('Error: Found multiple employee record, contact Admin Team.');
            }else if(empList.size() == 0){
                throw new CustomLogicException('Error: No employee record found, contact Admin Team.');
            }
            List<Employee_Leave__c> allLeaves = [SELECT Id, Duration__c, Start_Date__c, End_Date__c, Leave_Type__c, Status__c, Informed_Users__c, (SELECT Id, Leave_Date__c, Time_off_Duration__c, Time_Slot_Selection__c, Duration_in_days__c FROM Individual_Time_off__r) FROM Employee_Leave__c WHERE Employee__c = :empList[0].Id AND Year__c = :CURRYEAR AND (Status__c = 'Applied' OR Status__c = 'Approved') WITH SYSTEM_MODE ORDER BY LastModifiedDate DESC];
            return allLeaves;
        } catch (Exception e) {
            System.debug('Issue in: LeaveHandler @ allOtherEmployees method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            throw new FinalException(e.getMessage());
        }
    }
    /**
      * This method saves the leaves of all types except the direct restricted leave type.
      * @param {Decimal} duration - Duration of the leave.
      * @param {String} selectedType - Leave Type
      * @param {String} empStr - Stringified value of the Employee Object.
      * @param {String} reportingEmployee - Stringified value of the Employee Object of Reporting Manager.
      * @param {String} individualDetails - Stringified value of the individual days of leave application, contains details about first, second half leave data etc..
      * @param {String} reason - Reason of the leave.
      * @param {List<String>} informedTo - List of email address.
      * @param {String} startDate - Start Date.
      * @param {String} endDate - End Start.
      * @return {null}
      * @throws {CustomLogicException} If there is any error in the query or the employee data.
      * @throws {FinalException} If there is any other exception in the process.
      * @AuraEnabled This function can be called from an Aura/LWC component.
      * @author Maaz
      * @since 03/07/2023
      */
    @AuraEnabled
    public static void saveLeave(Decimal duration, String selectedType, String empStr, String reportingEmployee, String individualDetails, String reason, List<String> informedTo, String startDate, String endDate){
        try {
            EmployeesCls bothEmpsData = getEmployeesObj(empStr, reportingEmployee);
            Employee__c empData = bothEmpsData.empData;
            Employee__c reportingEmployeeObj = bothEmpsData.reportingEmployeeObj;
            String informedUsers = '';
            for(String eachInformEmail: informedTo){
                informedUsers += eachInformEmail + ';';
            }
            informedUsers = informedUsers.removeEnd(';');
            Date startFormatted = Date.valueOf(startDate);
            Date endFormatted = Date.valueOf(endDate);
            Boolean shareWithHR = false;
            Employee_Leave__c parentLeave = new Employee_Leave__c(Employee__c=empData.Id, Reporting_Manager__c=reportingEmployeeObj.SF_User__c, Leave_Type__c=selectedType, Status__c='Applied', Applied_By__c='Self', Reason__c=reason, Informed_Users__c=informedUsers, Duration__c=duration, Start_Date__c=startFormatted, End_Date__c=endFormatted);
            if(parentLeave.Leave_Type__c == 'Maternity Leave' || parentLeave.Leave_Type__c == 'Paternity Leave'){
                parentLeave.Notify_HR__c = true;
                parentLeave.Send_to_Manager__c = false;
                shareWithHR = true;
                empData.Paternity_Maternity_Leave_Count__c = empData.Paternity_Maternity_Leave_Count__c != null ? (empData.Paternity_Maternity_Leave_Count__c + 1) : 1;
                update as system empData;
            }else if(parentLeave.Leave_Type__c == 'Bereavement Leave' || (selectedType == 'Sick Leave' && duration >= 3)){
                parentLeave.Notify_HR__c = true;
                parentLeave.Send_to_Manager__c = false;
                shareWithHR = true;
            }else{
                parentLeave.Send_to_Manager__c = true;
                parentLeave.Notify_HR__c = false;
            }
            List<Individual_Time_off__c> allChildLeave = new List<Individual_Time_off__c>();
            List<Employee_Leave__c> additionalParent = new List<Employee_Leave__c>();
            insert as system parentLeave;
            if(selectedType == 'Casual Leave' || selectedType == 'Sick Leave'){
                List<Object> eachDayList = (List<Object>)JSON.deserializeUntyped(individualDetails);
                for(Object eachDayObj : eachDayList){
                    Map<String, Object> eachDayMap = (Map<String, Object>)eachDayObj;
                    if(!(Boolean)eachDayMap.get('locked') && !(Boolean)eachDayMap.get('restrictedOpted')){
                        Boolean firstHalf = (Boolean)eachDayMap.get('firstHalf');
                        Boolean secondHalf = (Boolean)eachDayMap.get('secondHalf');
                        Individual_Time_off__c childLeave = new Individual_Time_off__c();
                        childLeave.Employee_Leave__c = parentLeave.Id;
                        childLeave.Leave_Date__c = Date.valueOf((String)eachDayMap.get('date'));
                        if(firstHalf && secondHalf){
                            childLeave.Time_off_Duration__c = 'Full Day';
                        }else if(firstHalf && !secondHalf){
                            childLeave.Time_off_Duration__c = 'Half Day';
                            childLeave.Time_Slot_Selection__c = 'First Half';
                        }else if(!firstHalf && secondHalf){
                            childLeave.Time_off_Duration__c = 'Half Day';
                            childLeave.Time_Slot_Selection__c = 'Second Half';
                        }else{
                            continue;
                        }
                        allChildLeave.add(childLeave);
                    }else if(!(Boolean)eachDayMap.get('locked') && (Boolean)eachDayMap.get('restrictedOpted')){
                        Date selectedDate = Date.valueOf((String)eachDayMap.get('date'));
                        Employee_Leave__c eachAdditionalLeave = new Employee_Leave__c(Employee__c=empData.Id, Reporting_Manager__c=reportingEmployeeObj.SF_User__c, Leave_Type__c='Restricted Holiday', Status__c='Applied', Applied_By__c='Self', Reason__c='Opted Restricted Holiday', Informed_Users__c=informedUsers, Duration__c=1, Start_Date__c=selectedDate, End_Date__c=selectedDate, Send_to_Manager__c=true, Notify_HR__c=false);
                        additionalParent.add(eachAdditionalLeave);
                    }
                }
            }else if(selectedType == 'Privilege/Paid Leave' || selectedType == 'Bereavement Leave'){
                List<Object> eachDayList = (List<Object>)JSON.deserializeUntyped(individualDetails);
                for(Object eachDayObj : eachDayList){
                    Map<String, Object> eachDayMap = (Map<String, Object>)eachDayObj;
                    if(!(Boolean)eachDayMap.get('locked') && (Boolean)eachDayMap.get('restrictedOpted')){
                        Date selectedDate = Date.valueOf((String)eachDayMap.get('date'));
                        Employee_Leave__c eachAdditionalLeave = new Employee_Leave__c(Employee__c=empData.Id, Reporting_Manager__c=reportingEmployeeObj.SF_User__c, Leave_Type__c='Restricted Holiday', Status__c='Applied', Applied_By__c='Self', Reason__c='Opted Restricted Holiday', Informed_Users__c=informedUsers, Duration__c=1, Start_Date__c=selectedDate, End_Date__c=selectedDate, Send_to_Manager__c=true, Notify_HR__c=false);
                        additionalParent.add(eachAdditionalLeave);
                    }
                }
            }else{
                System.debug('Else; Duration: ');
                System.debug(duration);
            }
            if(allChildLeave.size() > 0){
                insert as system allChildLeave;
            }
            if(additionalParent.size() > 0){
                insert as system additionalParent; 
            }
            shareSubmitRecords(parentLeave, additionalParent, empData, reportingEmployeeObj, shareWithHR);
        } catch (Exception e) {
            System.debug('Issue in: LeaveHandler @ saveLeave method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            throw new FinalException(e.getMessage());
        }
    }
    /**
      * This function saves the restricted holiday leaves of an employee based on JSON strings of the employee data, the reporting employee data and the leave data.
      * @param {String} empStr - The JSON string that represents the employee data.
      * @param {String} reportingEmployee - The JSON string that represents the reporting employee data.
      * @param {String} leaveData - The JSON string that represents the leave data.
      * @AuraEnabled This function can be called from an Aura component.
      * @throws {FinalException} If there is any error in the process.
      * @author Maaz
      * @since 03/07/2023
      */
    @AuraEnabled
    public static void saveRestricted(String empStr, String reportingEmployee, String leaveData){
        try {
            EmployeesCls bothEmpsData = getEmployeesObj(empStr, reportingEmployee);
            Employee__c empData = bothEmpsData.empData;
            Employee__c reportingEmployeeObj = bothEmpsData.reportingEmployeeObj;
            List<Employee_Leave__c> allOtherRestrictedLeaves = new List<Employee_Leave__c>();
            List<Object> eachDayList = (List<Object>)JSON.deserializeUntyped(leaveData);
            Employee_Leave__c firstRestrictedLeave = new Employee_Leave__c();
            Boolean splittedLeaves = false;
            for(Object eachDayObj : eachDayList){
                Map<String, Object> eachDayMap = (Map<String, Object>)eachDayObj;
                if(!splittedLeaves){
                    splittedLeaves = true;
                    firstRestrictedLeave.Employee__c = empData.Id;
                    firstRestrictedLeave.Reporting_Manager__c = reportingEmployeeObj.SF_User__c;
                    firstRestrictedLeave.Leave_Type__c = 'Restricted Holiday';
                    firstRestrictedLeave.Status__c = 'Applied';
                    firstRestrictedLeave.Applied_By__c = 'Self';
                    firstRestrictedLeave.Duration__c = 1;
                    firstRestrictedLeave.Reason__c = (String)eachDayMap.get('name');
                    firstRestrictedLeave.Start_Date__c = Date.valueOf((String)eachDayMap.get('date'));
                    firstRestrictedLeave.End_Date__c = Date.valueOf((String)eachDayMap.get('date'));
                    firstRestrictedLeave.Send_to_Manager__c = true;
                    firstRestrictedLeave.Notify_HR__c = false;
                }else{
                    Employee_Leave__c otherRestrictedLeave = new Employee_Leave__c();
                    otherRestrictedLeave.Employee__c = empData.Id;
                    otherRestrictedLeave.Reporting_Manager__c = reportingEmployeeObj.SF_User__c;
                    otherRestrictedLeave.Leave_Type__c = 'Restricted Holiday';
                    otherRestrictedLeave.Status__c = 'Applied';
                    otherRestrictedLeave.Applied_By__c = 'Self';
                    otherRestrictedLeave.Duration__c = 1;
                    otherRestrictedLeave.Reason__c = (String)eachDayMap.get('name');
                    otherRestrictedLeave.Start_Date__c = Date.valueOf((String)eachDayMap.get('date'));
                    otherRestrictedLeave.End_Date__c = Date.valueOf((String)eachDayMap.get('date'));
                    otherRestrictedLeave.Send_to_Manager__c = true;
                    otherRestrictedLeave.Notify_HR__c = false;
                    allOtherRestrictedLeaves.add(otherRestrictedLeave);
                }
            }
            insert as system firstRestrictedLeave;
            if(allOtherRestrictedLeaves.size() > 0){
                insert as system allOtherRestrictedLeaves;
            }
            shareSubmitRecords(firstRestrictedLeave, allOtherRestrictedLeaves, empData, reportingEmployeeObj, false);
        } catch (Exception e) {
            System.debug('Issue in: LeaveHandler @ saveRestricted method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            throw new FinalException(e.getMessage());
        }
    }
    /**
      * This function submits the leave records of an employee for approval and shares them with the reporting manager and optionally with the HR group based on the parameters.
      * @param {Employee_Leave__c} parentLeave - The parent leave record of the employee.
      * @param {List<Employee_Leave__c>} additionalParent - The list of additional parent leave records of the employee.
      * @param {Employee__c} empData - The employee data of the employee.
      * @param {Employee__c} reportingEmployeeObj - The reporting employee data of the employee.
      * @param {Boolean} shareWithHR - A boolean flag to indicate if the leave records should be shared with the HR group or not.
      * @throws {FinalException} If there is any error in the process.
      * @author Maaz
      * @since 03/07/2023
      */
    private static void shareSubmitRecords(Employee_Leave__c parentLeave, List<Employee_Leave__c> additionalParent, Employee__c empData, Employee__c reportingEmployeeObj, Boolean shareWithHR){        try {
            // Submit for approval
            List<Approval.ProcessSubmitRequest> apprReqList = new List<Approval.ProcessSubmitRequest>();
            Approval.ProcessSubmitRequest apprReq = new Approval.ProcessSubmitRequest();
            apprReq.setComments('Leave Applied!');
            apprReq.setObjectId(parentLeave.Id);
            apprReq.setSubmitterId(empData.SF_User__c);
            apprReq.setProcessDefinitionNameOrId('Multilevel_Leave_Approval');
            apprReq.setSkipEntryCriteria(true);
            apprReqList.add(apprReq);
            for(Employee_Leave__c eachAdditional : additionalParent){
                Approval.ProcessSubmitRequest apprReqMain = new Approval.ProcessSubmitRequest();
                apprReqMain.setComments('Leave Applied!');
                apprReqMain.setObjectId(eachAdditional.Id);
                apprReqMain.setSubmitterId(empData.SF_User__c);
                apprReqMain.setProcessDefinitionNameOrId('Multilevel_Leave_Approval');
                apprReqMain.setSkipEntryCriteria(true);
                apprReqList.add(apprReqMain);
            }
            List<Approval.ProcessResult> result = Approval.process(apprReqList);
            // Share the record
            List<Employee_Leave__Share> empLeaveShareList = new List<Employee_Leave__Share>();
            Employee_Leave__Share empLeaveShare = new Employee_Leave__Share();
            empLeaveShare.ParentId = parentLeave.id;
            empLeaveShare.UserOrGroupId = reportingEmployeeObj.SF_User__c;
            empLeaveShare.AccessLevel = 'Edit';
            empLeaveShare.RowCause = 'Manual';
            empLeaveShareList.add(empLeaveShare);
            if(shareWithHR){
                String hrGroupId = [SELECT Id FROM Group WHERE Name = 'HR Team'][0]?.Id;
                Employee_Leave__Share empLeaveShareHR = new Employee_Leave__Share();
                empLeaveShareHR.ParentId = parentLeave.id;
                empLeaveShareHR.UserOrGroupId = hrGroupId;
                empLeaveShareHR.AccessLevel = 'Edit';
                empLeaveShareHR.RowCause = 'Manual';
                empLeaveShareList.add(empLeaveShareHR);
            }
            for(Employee_Leave__c eachAdditional : additionalParent){
                Employee_Leave__Share addEmpLeaveShare = new Employee_Leave__Share();
                addEmpLeaveShare.ParentId = eachAdditional.id;
                addEmpLeaveShare.UserOrGroupId = reportingEmployeeObj.SF_User__c;
                addEmpLeaveShare.AccessLevel = 'Edit';
                addEmpLeaveShare.RowCause = 'Manual';
                empLeaveShareList.add(addEmpLeaveShare);
            }
            upsert as system empLeaveShareList;
        } catch (Exception e) {
            System.debug('Issue in: LeaveHandler @ shareSubmitRecords method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            throw new FinalException(e.getMessage());
        }
    }
    /**
      * This class defines a custom data type that holds the employee data and the reporting employee data of an employee.
      */
    private class EmployeesCls{
        private Employee__c empData { get; set; }
        private Employee__c reportingEmployeeObj { get; set; }
    }
    /**
      * This function returns an EmployeesCls object that contains the employee data and the reporting employee data of an employee based on JSON strings.
      * @param {String} empStr - The JSON string that represents the employee data.
      * @param {String} reportingEmployee - The JSON string that represents the reporting employee data.
      * @return {EmployeesCls} The EmployeesCls object that contains the employee data and the reporting employee data of an employee.
      * @author Maaz
      * @since 03/07/2023
      */
    private static EmployeesCls getEmployeesObj(String empStr, String reportingEmployee ){
        EmployeesCls empDataObj = new EmployeesCls();
        empDataObj.empData =  (Employee__c)JSON.deserialize(empStr, Employee__c.class);
        empDataObj.reportingEmployeeObj = (Employee__c)JSON.deserialize(reportingEmployee, Employee__c.class);
        return empDataObj;
    }
}