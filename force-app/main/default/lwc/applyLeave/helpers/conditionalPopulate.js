import { CELEBRATION_PICKVAL, MATERNITY_PICKVAL, PAID_PICKVAL } from 'c/leaveConfig';
import { addDays } from '../utils/utils.js';

function populateData() {
  return new Promise((res, rej) => {
    try {
      this.spinnerFlag = true;
      if (this.selectedType === CELEBRATION_PICKVAL && this.isStartDateValid) {
        const currentYear = window.moment().format('YYYY');
        this.endDate = this.startDate;
        if (this.empData.Date_of_Birth__c && this.startDate === window.moment(this.empData.Date_of_Birth__c).year(currentYear).format('YYYY-MM-DD')) {
          this.reason = 'Birthday';
        } else if (this.empData.Date_of_Anniversary__c && this.startDate === window.moment(this.empData.Date_of_Anniversary__c).year(currentYear).format('YYYY-MM-DD')) {
          this.reason = 'Anniversary';
        } else {
          this.reason = 'Anniversary/Birthday';
        }
      } else if (this.selectedType === MATERNITY_PICKVAL && this.isStartDateValid) {
        /* if (window.moment(this.startDate).add(6, 'M').year() !== new Date().getFullYear()) {
          this.endDate = window.moment().endOf('year').format('YYYY-MM-DD');
        } else {
          this.endDate = window.moment(this.startDate).add(6, 'M').format('YYYY-MM-DD');
        } */
        // this.endDate = window.moment(this.startDate).add(6, 'M').format('YYYY-MM-DD');
        this.endDate = window.moment(this.startDate).add(26, 'weeks').subtract(1, 'days').format('YYYY-MM-DD');
      } else if (this.selectedType === PAID_PICKVAL && this.isStartDateValid) {
        let momentEndDate = addDays(window.moment(this.startDate), 1, this.holidayData, this.existingLeaves);
        this.endDate = momentEndDate.format('YYYY-MM-DD');
      }
      this.spinnerFlag = false;
      res();
    } catch (error) {
      rej(error);
    }
  })
}
function nearestSpecialDate() {
  const currentYear = window.moment().format('YYYY');
  const today = window.moment(this.startDate);
  if (!this.empData.Date_of_Anniversary__c && !this.empData.Date_of_Birth__c) {
    return today;
  } else if (!this.empData.Date_of_Anniversary__c) {
    return window.moment(this.empData.Date_of_Birth__c).year(currentYear);
  } else if (!this.empData.Date_of_Birth__c) {
    return window.moment(this.empData.Date_of_Anniversary__c).year(currentYear);
  }
  const bdayDate = window.moment(this.empData.Date_of_Birth__c).year(currentYear);
  const anniversaryDate = window.moment(this.empData.Date_of_Anniversary__c).year(currentYear);
  if (bdayDate.isBefore(today) && anniversaryDate.isBefore(today)) {
    return today;
  } else if (bdayDate.isBefore(today)) {
    return anniversaryDate;
  } else if (anniversaryDate.isBefore(today)) {
    return bdayDate;
  }
  if (bdayDate.isBefore(anniversaryDate)) {
    return bdayDate;
  }
  return anniversaryDate;
}
function partialPopulate() {
  if (this.selectedType === CELEBRATION_PICKVAL) {
    const nearestDate = nearestSpecialDate.call(this);
    if (nearestDate.isoWeekday() !== 6 && nearestDate.isoWeekday() !== 7) {
      this.endDate = nearestDate.format('YYYY-MM-DD');
      this.startDate = nearestDate.format('YYYY-MM-DD');
    }
  }
}
export { populateData, partialPopulate };