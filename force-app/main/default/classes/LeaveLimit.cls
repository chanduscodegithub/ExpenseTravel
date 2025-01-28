public abstract inherited sharing class LeaveLimit extends LeaveBalance{
    protected Regional_Leave_Limit__c regionData { get; set; }
    protected Employee__c employData { get; set; }
    @AuraEnabled
    public Decimal bereavementLimit{
        get {
            return (this.regionData.Bereavement_Leave__c == null) ? 0 : this.regionData.Bereavement_Leave__c;
        }
    }
    @AuraEnabled
    public Boolean bereavementEligible{
        get {
            return (this.regionData.Bereavement_Leave__c >= 0.00 || this.regionData.Bereavement_Leave__c == null) ? true : false;
        }
    }
    @AuraEnabled
    public Decimal sickLimit{
        get {
            return (this.regionData.Sick_Leave__c == null) ? 0 : this.regionData.Sick_Leave__c;
        }
    }
    @AuraEnabled
    public Boolean sickEligible{
        get {
            return (this.regionData.Sick_Leave__c >= 0.00 || this.regionData.Sick_Leave__c == null) ? true : false;
        }
    }
    @AuraEnabled
    public Decimal casualLimit{
        get {
            return (this.regionData.Casual_Leave__c == null) ? 0 : this.regionData.Casual_Leave__c;
        }
    }
    @AuraEnabled
    public Boolean casualEligible{
        get {
            return (this.regionData.Casual_Leave__c >= 0.00 || this.regionData.Casual_Leave__c == null) ? true : false;
        }
    }
    @AuraEnabled
    public Decimal paidAdjLimit{
        get {
            return (this.regionData.paid_Leave_Adjustment_Limit__c == null) ? 0 : this.regionData.paid_Leave_Adjustment_Limit__c;
        }
    }
    @AuraEnabled
    public Boolean paidAdjEligible{
        get {
            return (this.regionData.paid_Leave_Adjustment_Limit__c >= 0.00 || this.regionData.paid_Leave_Adjustment_Limit__c == null) ? true : false;
        }
    }
    @AuraEnabled
    public Decimal workFromHomeLimit{
        get {
            if(this.employData.Grade__c == 'L1'){
                return (this.regionData.WFH_B1_L1__c == null) ? 0 : this.regionData.WFH_B1_L1__c;
            }
            else if(this.employData.Grade__c == 'L2'){
                return (this.regionData.WFH_B1_L2__c == null) ? 0 : this.regionData.WFH_B1_L2__c;
            }
            else if(this.employData.Grade__c == 'L3' || this.employData.Grade__c == 'L4' || this.employData.Grade__c == 'L5'){
                return (this.regionData.WFH_B1_L3_to_L5__c == null) ? 0 : this.regionData.WFH_B1_L3_to_L5__c;
            }
            else if(this.employData.Grade__c == 'M1' || this.employData.Grade__c == 'M2' || this.employData.Grade__c == 'M3'){
                return (this.regionData.WFH_B2_M1_to_M3__c == null) ? 0 : this.regionData.WFH_B2_M1_to_M3__c;
            }
            else {
                return (this.regionData.WFH_D1_above__c == null) ? 0 : this.regionData.WFH_D1_above__c;
            }
        }
    }
    @AuraEnabled
    public Boolean workFromHomeEligible{
        get {
            if(this.employData.Grade__c == 'L1'){
                return (this.regionData.WFH_B1_L1__c == null || this.regionData.WFH_B1_L1__c >= 0.00) ? true : false;
            }
            else if(this.employData.Grade__c == 'L2'){
                return (this.regionData.WFH_B1_L2__c == null || this.regionData.WFH_B1_L2__c >= 0.00) ? true : false;
            }
            else if(this.employData.Grade__c == 'L3' || this.employData.Grade__c == 'L4' || this.employData.Grade__c == 'L5'){
                return (this.regionData.WFH_B1_L3_to_L5__c == null || this.regionData.WFH_B1_L3_to_L5__c >= 0.00 ) ? true : false;
            }
            else if(this.employData.Grade__c == 'M1' || this.employData.Grade__c == 'M2' || this.employData.Grade__c == 'M3'){
                return (this.regionData.WFH_B2_M1_to_M3__c == null || this.regionData.WFH_B2_M1_to_M3__c >= 0.00) ? true : false;
            }
            else {
                return (this.regionData.WFH_D1_above__c == null || this.regionData.WFH_D1_above__c >= 0.00) ? true : false;
            }
        }
    }
    @AuraEnabled
    public Decimal privilegeLimit{
        get {
            return (this.regionData.Privilege_Paid_Leave__c == null) ? 0 : this.regionData.Privilege_Paid_Leave__c;
        }
    }
    @AuraEnabled
    public Boolean privilegeEligible{
        get {
            return (this.regionData.Privilege_Paid_Leave__c >= 0.00 || this.regionData.Privilege_Paid_Leave__c == null) ? true : false;
        }
    }
    @AuraEnabled
    public Decimal paternityLimit{
        get {
            system.debug('this.regionData.Paternity_Leave__c'+this.regionData.Paternity_Leave__c);
            return (this.regionData.Paternity_Leave__c == null) ? 0 : this.regionData.Paternity_Leave__c;
        }
    }
    @AuraEnabled
    public Boolean paternityEligible{
        get {
            System.debug('this.regionData.Paternity_Leave__c'+this.regionData.Paternity_Leave__c);
            return (this.regionData.Paternity_Leave__c >= 0.00 || this.regionData.Paternity_Leave__c == null) ? true : false;
        }
    }
    @AuraEnabled
    public Decimal maternityLimit{
        get {
            return (this.regionData.Maternity_Leave__c == null) ? 0 : this.regionData.Maternity_Leave__c;
        }
    }
    @AuraEnabled
    public Boolean maternityEligible{
        get {
            return (this.regionData.Maternity_Leave__c >= 0.00 || this.regionData.Maternity_Leave__c == null) ? true : false;
        }
    }
    @AuraEnabled
    public Decimal celebrationLimit{
        get {
            return (this.regionData.Celebration_Leave__c == null) ? 0 : this.regionData.Celebration_Leave__c;
        }
    }
    @AuraEnabled
    public Boolean celebrationEligible{
        get {
            return (this.regionData.Celebration_Leave__c >= 0.00 || this.regionData.Celebration_Leave__c == null) ? true : false;
        }
    }
    @AuraEnabled
    public Decimal restrictedLimit{
        get {
            return (this.regionData.Restricted_Holiday__c ==  null) ? 0 : this.regionData.Restricted_Holiday__c;
        }
    }
    @AuraEnabled
    public Boolean restrictedEligible{
        get {
            return (this.regionData.Restricted_Holiday__c >= 0.00 || this.regionData.Restricted_Holiday__c == null) ? true : false;
        }
    }
    @AuraEnabled
    public Decimal lossOfPayLimit{
        get {
            return this.regionData.Loss_of_Pay_LOP__c;
        }
    }
    @AuraEnabled
    public Boolean lossOfPayEligible{
        get {
            return false;
        }
    }
    @AuraEnabled
    public Boolean longEligible{
        get {
            return (this.regionData.Long_Leave__c >= 0.00 || this.regionData.Long_Leave__c == null) ? true : false;
        }
    }
    @AuraEnabled
    public Decimal longLimit{
        get {
            return (this.regionData.Long_Leave__c == null) ? 0 : this.regionData.Long_Leave__c;
        }
    }
}