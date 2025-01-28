import { getPropertyName } from "../utils/utils";
import { CELEBRATION_PICKVAL, PAIDADJ_PICKVAL, PATERNITY_PICKVAL, MATERNITY_PICKVAL, WFH_PICKVAL, PAID_PICKVAL } from 'c/leaveConfig';
function validate() {
  let balance = this.data[getPropertyName(this.selectedType)];
  let duration = this.duration;

  if (this.duration > balance) {
    throw new Error('You do not have balance for the opted duration.');
  }
  /*Author : Divya  Year end 5 leaves only for permanent employees of India Region should exclude added condition
  (this.empData.Type__c !== 'Probationer' && this.empData.Region__c === 'IND') ||
    (
        this.empData.Type__c === 'Probationer' &&
        (this.empData.Region__c === 'ANZ' || this.empData.Region__c === 'US')
    ) ||
    (
        (this.empData.Region__c === 'IND' || this.empData.Region__c === 'ANZ' || this.empData.Region__c === 'US') &&
        this.empData.Type__c === this.permanentPickValBind
    ) */
  if((this.selectedType == PAID_PICKVAL ) && new Date(this.startDate).getMonth() !== 11 && (balance - duration) < 5 && (
    (this.empData.Type__c !== 'Probationer' && this.empData.Region__c === 'IND') ||
    (
        this.empData.Type__c === 'Probationer' &&
        (this.empData.Region__c === 'ANZ' || this.empData.Region__c === 'US')
    ) ||
    (
        (this.empData.Region__c === 'IND' || this.empData.Region__c === 'ANZ' || this.empData.Region__c === 'US') &&
        this.empData.Type__c === this.permanentPickValBind
    )
)){
    throw new Error('The remaining 5 leaves are locked for the year end vacation!');
  }
  //Year end 5 leaves only for permanent employees added condition 
   if((this.selectedType == PAID_PICKVAL ) && new Date(this.startDate).getMonth() == 11 && (new Date(this.startDate).getDate() < 25 ) && (balance - duration) < 5  && (
    (this.empData.Type__c !== 'Probationer' && this.empData.Region__c === 'IND') ||
    (
        this.empData.Type__c === 'Probationer' &&
        (this.empData.Region__c === 'ANZ' || this.empData.Region__c === 'US')
    ) ||
    (
        (this.empData.Region__c === 'IND' || this.empData.Region__c === 'ANZ' || this.empData.Region__c === 'US') &&
        this.empData.Type__c === this.permanentPickValBind
    )
)){
     throw new Error('The remaining 5 leaves are locked for the year end vacation!'); 
   }
  //Year end 5 leaves only for permanent employees added condition
  if((this.selectedType !== PAID_PICKVAL &&  this.selectedType !== PAIDADJ_PICKVAL) && new Date(this.startDate).getMonth() == 11 && (new Date(this.startDate).getDate() >= 25 || new Date(this.endDate).getDate() == 25)  && (
    (this.empData.Type__c !== 'Probationer' && this.empData.Region__c === 'IND') ||
    (
        this.empData.Type__c === 'Probationer' &&
        (this.empData.Region__c === 'ANZ' || this.empData.Region__c === 'US')
    ) ||
    (
        (this.empData.Region__c === 'IND' || this.empData.Region__c === 'ANZ' || this.empData.Region__c === 'US') &&
        this.empData.Type__c === this.permanentPickValBind
    )
)){
    throw new Error('Please apply only paid Leaves for year end vacation!')
  }
  if(this.selectedType === PAIDADJ_PICKVAL && new Date(this.startDate).getMonth() !== 11){
    throw new Error('Please apply only paid Leave Adjustments strictly for year end vacation!')
  }
  else if(this.selectedType === PAIDADJ_PICKVAL && new Date(this.startDate).getMonth() === 11 && (new Date(this.startDate).getDate() <= 24)){
    throw new Error('Please apply only paid Leave Adjustments strictly for year end vacation!')
  }
  if (this.selectedType.trim() === '' || this.selectedType == null || this.selectedType === undefined) {
    throw new Error('Leave type invalid.');
  }
  // if(this.selectedType === WFH_PICKVAL && (new Date(new Date(this.startDate).getFullYear(), new Date(this.startDate).getMonth(), new Date(this.startDate).getDate()) < new Date(new Date().getFullYear, new Date().getMonth, new Date().getDate()))){
  //   throw new Error('Work from Home should be applied before or on the date of availing, kindly contact HR Team');
  // }
  if(this.selectedType === WFH_PICKVAL && (new Date(this.startDate).getDate() < new Date().getDate()) && (new Date(this.startDate).getMonth() == new Date().getMonth())){
    throw new Error('Work from Home should be applied before or on the date of availing, kindly contact HR Team');
  }
  if (this.selectedType === WFH_PICKVAL && (new Date(this.startDate).getMonth() > new Date().getMonth() || new Date(this.endDate).getMonth() > new Date().getMonth())) {
    throw new Error('Work from Home can only be requested on a monthly basis; it is not possible to apply for leave in advance for the following month.');
  }
  if (this.selectedType === CELEBRATION_PICKVAL && this.empData.Date_of_Birth__c && this.empData.Date_of_Anniversary__c) {
    const currentYear = window.moment().format('YYYY');
    if (this.startDate !== window.moment(this.empData.Date_of_Birth__c).year(currentYear).format('YYYY-MM-DD') && this.startDate !== window.moment(this.empData.Date_of_Anniversary__c).year(currentYear).format('YYYY-MM-DD')) {
      throw new Error('Selected dates are invalid for Celebration Leave.');
    }
  }
}
function dateValidation() {
  if ((new Date(this.startDate).getFullYear() !== new Date().getFullYear() || new Date(this.endDate).getFullYear() !== new Date().getFullYear()) && this.selectedType !== MATERNITY_PICKVAL && this.selectedType !== PATERNITY_PICKVAL) {
    this.startDate = null;
    this.endDate = null;
    throw new Error('Date should belong to current year.');
  }
}
export { validate, dateValidation };