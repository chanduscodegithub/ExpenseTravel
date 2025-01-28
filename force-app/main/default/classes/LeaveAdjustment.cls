/*------------------------------------------------------------
Author       :  Maaz Rahman
Company      :  CRMIT Pvt. Ltd.
Description  :  _
Inputs       :  Mentioned before each methods. No constructor for the LeaveHandler class.
Test Class   :  _

History
<Date>         <Authors Name>        <Brief Description of Change>
------------------------------------------------------------------*/
public without sharing class LeaveAdjustment {
    private class CustomLogicException extends Exception {
    }
    private class FinalException extends Exception {
    }
    final static String CURRYEAR = String.valueOf(System.today().year());
    final static String LASTYEAR = String.valueOf(Integer.valueOf(CURRYEAR) - 1);
    
    private Regional_Leave_Limit__c regionData { get; set; }
    private Employee_Leave_Balance__c balanceData { get; set; }
    private Regional_Leave_Limit__c lastYearRegionalLimit { get; set; }
    private Employee__c employData { get; set; }
    private Boolean isCasualCarryAllowed{
        get {
            return this.regionData.CarryForward__c > 0;
        }
    }
    private Boolean isPrivilegeCarryAllowed{
        get {
            return this.regionData.Carry_Forward_Privilege_Leave__c > 0;
        }
    }
    private Boolean isSickCarryAllowed{
        get {
            return this.regionData.Carry_Forward_Sick_Leave__c > 0;
        }
    }
    private Boolean isCelebrationCarryAllowed{
        get {
            return this.regionData.Carry_Forward_Celebration_Leave__c > 0;
        }
    }

    private Decimal additionalCasualCount{
        get {
            return this.balanceData.Casual_Leave__c - this.regionData.Casual_Leave__c;
        }
    }
    private Decimal additionalSickCount{
        get {
            return this.balanceData.Sick_Leave__c - this.regionData.Sick_Leave__c;
        }
    }
    private Decimal additionalPrivilegeCount{
        get {
            return this.balanceData.Privilege_Paid_Leave_in_days__c - this.regionData.Privilege_Paid_Leave__c;
        }
    }
    private Decimal additionalCelebrationCount{
        get {
            return this.balanceData.Celebration_Leave__c - this.regionData.Celebration_Leave__c;
        }
    }

    private Boolean isCasualExtra{
        get {
            return this.additionalCasualCount > 0;
        }
    }
    private Boolean isPrivilegeExtra{
        get {
            return this.additionalPrivilegeCount > 0;
        }
    }
    private Boolean isSickExtra{
        get {
            return this.additionalSickCount > 0;
        }
    }
    private Boolean isCelebrationExtra{
        get {
            return this.additionalCelebrationCount > 0;
        }
    }
    public Boolean isFixingRequired{
        get {
            return this.isCasualExtra || this.isPrivilegeExtra || this.isSickExtra || this.isCelebrationExtra;
        }
    }

    public LeaveAdjustment(Regional_Leave_Limit__c regionData, Employee_Leave_Balance__c balanceData, Regional_Leave_Limit__c lastYearRegionalLimit, Employee__c employData) {
        this.regionData = regionData;
        this.balanceData = balanceData;
        this.lastYearRegionalLimit = lastYearRegionalLimit;
        this.employData = employData;
    }
    public Map<String, Decimal> fixLeaveData(){
        try {
            Boolean lastYearBalanceCreation = false;
            Boolean currBalanceUpdation = false;
            Map<String, Decimal> carryData = new Map<String, Decimal>{
                'Casual' => 0.0,
                'Sick' => 0.0,
                'Privilege' => 0.0,
                'Celebration' => 0.0
            };
            Employee_Leave_Balance__c prevBalanceData = this.balanceData.clone();
            prevBalanceData.Regional_Leave_Limit__c = this.lastYearRegionalLimit.Id;
            prevBalanceData.Employee__c = this.balanceData.Employee__c;
            prevBalanceData.Employee_Status__c = this.balanceData.Employee_Status__c;
            prevBalanceData.Casual_Leave__c = 0;
            prevBalanceData.Sick_Leave__c = 0;
            prevBalanceData.Bereavement_Leave__c = 0;
            prevBalanceData.Privilege_Paid_Leave_in_days__c = 0;
            prevBalanceData.Paternity_Leave__c = 0;
            prevBalanceData.Maternity_Leave__c = 0;
            prevBalanceData.Celebration_Leave__c = 0;
            prevBalanceData.Restricted_Holiday__c = 0;
            prevBalanceData.Long_Leave__c = 0;

            if(this.isCasualCarryAllowed && this.isCasualExtra){
                if(this.additionalCasualCount > this.regionData.CarryForward__c){
                    prevBalanceData.CarryForward__c = this.regionData.CarryForward__c;
                    // currBalanceUpdation = true;
                    // this.balanceData.Casual_Leave__c = this.regionData.Casual_Leave__c;
                }else{
                    prevBalanceData.CarryForward__c = this.additionalCasualCount;
                }
                carryData.put('Causal', (Decimal)prevBalanceData.CarryForward__c);
                lastYearBalanceCreation = true;
            }
            if(this.isSickCarryAllowed && this.isSickExtra){
                if(this.additionalSickCount > this.regionData.Carry_Forward_Sick_Leave__c){
                    prevBalanceData.CarryForward_Sick_Leave__c = this.regionData.Carry_Forward_Sick_Leave__c;
                    // currBalanceUpdation = true;
                    // this.balanceData.Sick_Leave__c = this.regionData.Sick_Leave__c;
                }else{
                    prevBalanceData.CarryForward_Sick_Leave__c = this.additionalSickCount;
                }
                carryData.put('Sick', (Decimal)prevBalanceData.CarryForward_Sick_Leave__c);
                lastYearBalanceCreation = true;
            }
            if(this.isPrivilegeCarryAllowed && this.isPrivilegeExtra){
                if(this.additionalPrivilegeCount > this.regionData.Carry_Forward_Privilege_Leave__c){
                    prevBalanceData.CarryForward_Privilege_Leave__c = this.regionData.Carry_Forward_Privilege_Leave__c;
                    // currBalanceUpdation = true;
                    // this.balanceData.Privilege_Paid_Leave_in_days__c = this.regionData.Privilege_Paid_Leave__c;
                }else{
                    prevBalanceData.CarryForward_Privilege_Leave__c = this.additionalPrivilegeCount;
                }
                carryData.put('Privilege', (Decimal)prevBalanceData.CarryForward_Privilege_Leave__c);
                lastYearBalanceCreation = true;
            }
            if(this.isCelebrationCarryAllowed && this.isCelebrationExtra){
                if(this.additionalCelebrationCount > this.regionData.Carry_Forward_Celebration_Leave__c){
                    prevBalanceData.Carry_Forward_Celebration_Leave__c = this.regionData.Carry_Forward_Celebration_Leave__c;
                    // currBalanceUpdation = true;
                    // this.balanceData.Carry_Forward_Celebration_Leave__c = this.regionData.Carry_Forward_Celebration_Leave__c;
                }else{
                    prevBalanceData.Carry_Forward_Celebration_Leave__c = this.additionalCelebrationCount;
                }
                carryData.put('Celebration', (Decimal)prevBalanceData.Carry_Forward_Celebration_Leave__c);
                lastYearBalanceCreation = true;
            }
            if(lastYearBalanceCreation){
                insert as system prevBalanceData;
            }
            if(currBalanceUpdation){
                update as system this.balanceData;
            }
            return carryData;
        } catch (Exception e) {
            System.debug('Issue in: LeaveHandler @ populateData method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            throw new FinalException(e.getMessage());
        }
    }
}