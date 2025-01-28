import {
  CELEBRATION_PICKVAL,
  MATERNITY_PICKVAL,
  PATERNITY_PICKVAL,
  CASUAL_PICKVAL,
  SICK_PICKVAL,
  PAID_PICKVAL,
  BEREAVEMENT_PICKVAL,
  RESTRICTED_PICKVAL,
  LONG_PICKVAL,
  LOP_PICKVAL,
  WFH_PICKVAL,
  PAIDADJ_PICKVAL,
  CASUAL_HTML_ATTR,
  SICK_HTML_ATTR,
  PAID_HTML_ATTR,
  CELEBRATION_HTML_ATTR,
  MATERNITY_HTML_ATTR,
  PATERNITY_HTML_ATTR,
  BEREAVEMENT_HTML_ATTR,
  RESTRICTED_HTML_ATTR,
  LONG_HTML_ATTR,
  LOP_HTML_ATTR,
  WFH_HTML_ATTR,
  PAIDADJ_HTML_ATTR,
  CASUAL_BAL_CLSMEM,
  SICK_BAL_CLSMEM,
  PAID_BAL_CLSMEM,
  CELEBRATION_BAL_CLSMEM,
  MATERNITY_BAL_CLSMEM,
  PATERNITY_BAL_CLSMEM,
  BEREAVEMENT_BAL_CLSMEM,
  RESTRICTED_BAL_CLSMEM,
  LOP_BAL_CLSMEM,
  LONG_BAL_CLSMEM,
  WFH_BAL_CLSMEM,
  PAIDADJ_BAL_CLSMEM,
  CASUAL_ELIGIBLE_CLSMEM,
  SICK_ELIGIBLE_CLSMEM,
  PAID_ELIGIBLE_CLSMEM,
  CELEBRATION_ELIGIBLE_CLSMEM,
  MATERNITY_ELIGIBLE_CLSMEM,
  PATERNITY_ELIGIBLE_CLSMEM,
  BEREAVEMENT_ELIGIBLE_CLSMEM,
  RESTRICTED_ELIGIBLE_CLSMEM,
  LONG_ELIGIBLE_CLSMEM,
  LOP_ELIGIBLE_CLSMEM,
  WFH_ELIGIBLE_CLSMEM,
  PAIDADJ_ELIGIBLE_CLSMEM
 } from 'c/leaveConfig';

import transformData from '../helpers/data-transformer.js';

/**
 * A function that returns the picklist API name for a given value from the HTML data-type attribute of the cards.
 * @param value The value from the HTML data-type attribute of the cards.
 * @return {String} The picklist API name for the value.
 * @note If new cards get added or `Leave Type` picklist API name is changed, then this function has to be adjusted accordingly.
 * @author Maaz
 * @since 03/07/2023
 */
function getPicklistAPIName(value) {
  switch (value) {
    case CASUAL_HTML_ATTR:
      return CASUAL_PICKVAL;
    case WFH_HTML_ATTR:
      return WFH_PICKVAL;   
    case SICK_HTML_ATTR:
      return SICK_PICKVAL;
    case PAID_HTML_ATTR:
      return PAID_PICKVAL;
    case CELEBRATION_HTML_ATTR:
      return CELEBRATION_PICKVAL;
    case MATERNITY_HTML_ATTR:
      return MATERNITY_PICKVAL;
    case PATERNITY_HTML_ATTR:
      return PATERNITY_PICKVAL;
    case BEREAVEMENT_HTML_ATTR:
      return BEREAVEMENT_PICKVAL;
    case RESTRICTED_HTML_ATTR:
      return RESTRICTED_PICKVAL;
    case LONG_HTML_ATTR:
      return LONG_PICKVAL;
    case LOP_HTML_ATTR:
      return LOP_PICKVAL;
    case PAIDADJ_HTML_ATTR:
      return PAIDADJ_PICKVAL;
    default:
      return '';
  }
}
/**
 * A function that returns the data (object) property name by taking the leave type picklist API name as a parameter.
 * @param value The leave type picklist API name.
 * @return {String} The data (object) property name for the leave type.
 * @note If any of the properties is added/modified in JS or Apex, the code has to be adjusted accordingly.
 * @author Maaz
 * @since 03/07/2023
 */
function getPropertyName(value) {
  switch (value) {
    case CASUAL_PICKVAL:
      return CASUAL_BAL_CLSMEM;
    case SICK_PICKVAL:
      return SICK_BAL_CLSMEM;
    case WFH_PICKVAL:
      return WFH_BAL_CLSMEM;
    case PAID_PICKVAL:
      return PAID_BAL_CLSMEM;
    case CELEBRATION_PICKVAL:
      return CELEBRATION_BAL_CLSMEM;
    case MATERNITY_PICKVAL:
      return MATERNITY_BAL_CLSMEM;
    case PATERNITY_PICKVAL:
      return PATERNITY_BAL_CLSMEM;
    case BEREAVEMENT_PICKVAL:
      return BEREAVEMENT_BAL_CLSMEM;
    case RESTRICTED_PICKVAL:
      return RESTRICTED_BAL_CLSMEM;
    case LONG_PICKVAL:
      return LONG_BAL_CLSMEM;
    case LOP_PICKVAL:
      return LOP_BAL_CLSMEM;
    case PAIDADJ_PICKVAL:
      return PAIDADJ_BAL_CLSMEM;
    default:
      return '';
  }
}
/**
 * A function that returns the data property name for the eligibility of a given leave type picklist API name.
 * @param value The leave type picklist API name.
 * @return {String} The data property name for the eligibility of the leave type.
 * @note If any modification/additions happens to the API name or data properties in JS or Apex, this function has to be adjusted accordingly. 
 * @author Maaz
 * @since 03/07/2023
 */
function getPropertyNameEligible(value) {
  switch (value) {
    case CASUAL_PICKVAL:
      return CASUAL_ELIGIBLE_CLSMEM;
    case WFH_PICKVAL:
      return WFH_ELIGIBLE_CLSMEM;
    case SICK_PICKVAL:
      return SICK_ELIGIBLE_CLSMEM;
    case PAID_PICKVAL:
      return PAID_ELIGIBLE_CLSMEM;
    case CELEBRATION_PICKVAL:
      return CELEBRATION_ELIGIBLE_CLSMEM;
    case MATERNITY_PICKVAL:
      return MATERNITY_ELIGIBLE_CLSMEM;
    case PATERNITY_PICKVAL:
      return PATERNITY_ELIGIBLE_CLSMEM;
    case BEREAVEMENT_PICKVAL:
      return BEREAVEMENT_ELIGIBLE_CLSMEM;
    case RESTRICTED_PICKVAL:
      return RESTRICTED_ELIGIBLE_CLSMEM;
    case LONG_PICKVAL:
      return LONG_ELIGIBLE_CLSMEM;
    case LOP_PICKVAL:
      return LOP_ELIGIBLE_CLSMEM;
    case PAIDADJ_PICKVAL:
      return PAIDADJ_ELIGIBLE_CLSMEM;
    default:
      return '';
  }
}

/**
 *
 *
 * @param {*} momentDate
 * @param {*} daysToAdd
 * @param {*} holidayMap
 * @param {*} rawLeaveData
 * @return {*} 
 * @author Maaz
 * @since 03/07/2023
 */
function addDays(momentDate, daysToAdd, holidayMap, rawLeaveData) {
  let leaveData = transformData(rawLeaveData, momentDate.format('YYYY-MM-DD'), window.moment(momentDate.format('YYYY-MM-DD')).add(20, 'days').format('YYYY-MM-DD'));
  while (daysToAdd > 0) {
    momentDate = momentDate.add(1, "days");
    if (momentDate.isoWeekday() !== 6 && momentDate.isoWeekday() !== 7 && !holidayMap.has(momentDate.format('YYYY-MM-DD')) && !leaveData.has(momentDate.format('YYYY-MM-DD'))) {
      daysToAdd -= 1;
    }
  }
  return momentDate;
}
/**
 *
 *
 * @param {*} formattedDateStr
 * @param {*} holidayMap
 * @param {*} rawLeaveData
 * @return {*} 
 * @author Maaz
 * @since 03/07/2023
 */
function getEligibleDate(formattedDateStr, holidayMap, rawLeaveData) {
  let momentDate = window.moment(formattedDateStr);
  let leaveData = transformData(rawLeaveData, momentDate.format('YYYY-MM-DD'), window.moment(momentDate.format('YYYY-MM-DD')).add(30, 'days').format('YYYY-MM-DD'));
  while (momentDate.isoWeekday() === 6 || momentDate.isoWeekday() === 7 || holidayMap.has(momentDate.format('YYYY-MM-DD')) || leaveData.has(momentDate.format('YYYY-MM-DD'))) {
    momentDate = momentDate.add(1, "days");
  }
  return momentDate.format('YYYY-MM-DD');
}
/**
 *
 *
 * @return {*}
 * @author Maaz
 * @since 03/07/2023 
 */
function getCurrDateInSFStr() {
  let date = new Date();
  let year = date.getFullYear();
  let month = date.getMonth() + 1;
  let day = date.getDate();
  month = month < 10 ? '0' + month : month;
  day = day < 10 ? '0' + day : day;
  let formattedDate = year + '-' + month + '-' + day;
  return formattedDate;
}
/**
 *
 *
 * @param {*} err
 * @return {*} 
 * @author Maaz
 * @since 03/07/2023
 */
function getErrorBody(err) {
  if (err?.body?.message) {
    return {
      title: 'Error!',
      message: `${err.body.message}`,
      variant: 'error'
    }
  } else if (err?.body) {
    return {
      title: 'Error!',
      message: `${err.body}`,
      variant: 'error'
    }
  } else if (err?.message) {
    return {
      title: 'Error!',
      message: `${err.message}`,
      variant: 'error'
    }
  }
  return {
    title: 'Error!',
    message: `${err}`,
    variant: 'error'
  }
}
/**
 *
 *
 * @author Maaz
 * @since 03/07/2023
 */
function clearData() {
  this.endDate = '';
  this.reason = '';
  this.dayCollection = [];
  this.duration = 0;
  if (this.selectedType === this.restrictedPickValBind) {
    this.selectedType = '';
  }
  this.additionalModalContent = false;
}

export { getPicklistAPIName, getPropertyName, addDays, getErrorBody, getPropertyNameEligible, getEligibleDate, getCurrDateInSFStr, clearData }