public abstract inherited sharing class LeaveBalance {
    protected Employee_Leave_Balance__c balanceData { get; set; }
    @AuraEnabled
    public Decimal bereavementBalance{
        get {
            return this.balanceData.Bereavement_Leave__c == null ? 0 : this.balanceData.Bereavement_Leave__c;
        }
    }
    @AuraEnabled
    public Decimal sickBalance{
        get {
            return this.balanceData.Sick_Leave__c == null ? 0 : this.balanceData.Sick_Leave__c;
        }
    }
    @AuraEnabled
    public Decimal casualBalance{
        get {
            return this.balanceData.Casual_Leave__c == null ? 0 : this.balanceData.Casual_Leave__c;
        }
    }
    @AuraEnabled
    public Decimal workFromHomeBalance{
        get {
            return this.balanceData.Work_from_Home__c == null ? 0 : this.balanceData.Work_from_Home__c;
        }
    }
    @AuraEnabled
    public Decimal paidAdjustmentBalance{
        get {
            return this.balanceData.Paid_Leave_Adjustment__c == null ? 0 : this.balanceData.Paid_Leave_Adjustment__c;
        }
    }
    @AuraEnabled
    public Decimal privilegeBalance{
        get {
            return this.balanceData.Privilege_Paid_Leave_in_days__c == null ? 0 : this.balanceData.Privilege_Paid_Leave_in_days__c;
        }
    }
    @AuraEnabled
    public Decimal paternityBalance{
        get {
            return this.balanceData.Paternity_Leave__c == null ? 0 : this.balanceData.Paternity_Leave__c;
        }
    }
    @AuraEnabled
    public Decimal maternityBalance{
        get {
            return this.balanceData.Maternity_Leave__c == null ? 0 : this.balanceData.Maternity_Leave__c;
        }
    }
    @AuraEnabled
    public Decimal celebrationBalance{
        get {
            return this.balanceData.Celebration_Leave__c == null ? 0 : this.balanceData.Celebration_Leave__c;
        }
    }
    @AuraEnabled
    public Decimal restrictedBalance{
        get {
            return this.balanceData.Restricted_Holiday__c == null ? 0 : this.balanceData.Restricted_Holiday__c;
        }
    }
    @AuraEnabled
    public Decimal lossOfPayBalance{
        get {
            return this.balanceData.Loss_of_Pay_LOP__c == null ? 0 : this.balanceData.Loss_of_Pay_LOP__c;
        }
    }
    @AuraEnabled
    public Decimal longBalance{
        get {
            return this.balanceData.Long_Leave__c == null ? 0 : this.balanceData.Long_Leave__c;
        }
    }
}