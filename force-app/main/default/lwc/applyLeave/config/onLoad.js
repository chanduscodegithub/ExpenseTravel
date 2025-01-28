function processOnLoad() {
  if (this.empData.Paternity_Maternity_Leave_Count__c == null || this.empData.Paternity_Maternity_Leave_Count__c === undefined) {
    this.empData.Paternity_Maternity_Leave_Count__c = 0;
  }
  if (!this.empData.Enable_Bereavement__c) {
    this.data[this.bereavementEligibleBind] = false;
  }

  /* Author Divya : Modified this.empData.Paternity_Maternity_Leave_Count__c < 2 condition to his.empData.Paternity_Maternity_Leave_Count__c <= 2, Since paternity is not enabled for the employee */
  if (this.empData.Gender__c === 'Female') {
    this.data[this.maternityEligibleBind] = (this.empData.Enable_Paternity_Maternity__c && this.empData.Paternity_Maternity_Leave_Count__c <= 2 || this.data[this.maternityBalanceBind] === 0) ? true : false;
    this.data[this.paternityBalanceBind] = 0;
    this.data[this.paternityEligibleBind] = false;
  } else if (this.empData.Gender__c === 'Male') {
    this.data[this.paternityEligibleBind] = (this.empData.Enable_Paternity_Maternity__c && this.empData.Paternity_Maternity_Leave_Count__c <= 2 || this.data[this.paternityBalanceBind] === 0) ? true : false;
    this.data[this.maternityBalanceBind] = 0;
    this.data[this.maternityEligibleBind] = false;
  }
  // Carry Forward
  if (this.empData.Type__c === this.permanentPickValBind) {
    this.data[this.casualLimitBind] = this.data[this.casualLimitBind] + this.data[this.casualCarryBind];
    this.data[this.sickLimitBind] = this.data[this.sickLimitBind] + this.data[this.sickCarryBind];
    this.data[this.privilegeLimitBind] = this.data[this.privilegeLimitBind] + this.data[this.privilegeCarryBind];
    this.data[this.celebrationLimitBind] = this.data[this.celebrationLimitBind] + this.data[this.celebrationCarryBind];
  }

  // Special Leave
  if ((this.empData.Date_of_Anniversary__c === '' || this.empData.Date_of_Anniversary__c == null || this.empData.Date_of_Anniversary__c === undefined) && this.empData.Region__c == 'IND') {
    this.data[this.celebrationLimitBind] = this.data[this.celebrationLimitBind] - 1;
    this.data[this.celebrationBalanceBind] = this.data[this.celebrationBalanceBind] - 1;
    console.log('CELEBRATION', this.data[this.celebrationBalanceBind]);
  }
  let balance = 0;
  for (let key of Object.keys(this.data)) {
    if (key.includes('Balance') && this.data[`${key.split('Balance')[0]}Eligible`] && key !== this.celebrationBalanceBind && key !== this.restrictedBalanceBind && key !== this.wfhBalanceBind) {
      balance += this.data[key];
    }
  }
  // if (balance <= 0) {
  //   this.data.lossOfPayTook = - this.data[this.lopBalanceBind];
  //   this.data[this.lopEligibleBind] = true;
  //   this.data[this.lopLimitBind] = 100;
  //   this.data[this.lopBalanceBind] = 100;
  // } else {
  //   this.data[this.lopEligibleBind] = false;
  //   this.data[this.lopLimitBind] = 0;
  //   this.data[this.lopBalanceBind] = 0;
  //   this.data.lossOfPayTook = 0;
  // }
    //When all the leaves are exhausted except 5 privilege leaves, the LOP is enabled.
    if ((balance-5) <= 0) {
      this.data.lossOfPayBalance =  this.data[this.lopBalanceBind];
      console.log('lopBalanceBind',this.data[this.lopBalanceBind]);
      this.data.lossOfPayTook = this.data[this.lopLimitBind] - this.data[this.lopBalanceBind];
      this.data[this.lopEligibleBind] = true;
      this.data[this.lopLimitBind] = 100;
      //this.data[this.lopBalanceBind] = 100;
    } else {
      this.data[this.lopEligibleBind] = false;
      this.data[this.lopLimitBind] = 0;
      this.data[this.lopBalanceBind] = 0;
      this.data.lossOfPayTook = 0;
    }
  
}

export default processOnLoad;