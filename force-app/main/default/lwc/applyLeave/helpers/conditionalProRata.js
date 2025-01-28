/* function roundOff(num) {
  let decimal = num - Math.floor(num);
  if (decimal === 0.5) {
    return Math.floor(num);
  }
  return Math.round(num);
} */

/**
 *
 *
 * @param {Number} num1
 * @param {Number} num2
 * @return {*} 
 * @author Maaz
 * @since 03/07/2023
 */
/* function isEqual(num1, num2) {
  let epsilon = 0.0000001;
  return Math.abs(num1 - num2) < epsilon;
} */
/**
 *
 *
 * @param {Number} num
 * @return {*} 
 * @author Maaz
 * @since 03/07/2023
 */
function roundOff(num) {
  let str = num.toString();
  let dotIndex = str.indexOf('.');
  if (dotIndex === -1) {
    return num;
  }
  let intPart = str.slice(0, dotIndex);
  let decPart = str.slice(dotIndex + 1);
  if (decPart[0] === '5' && decPart.length === 1) {
    return parseInt(intPart, 10);
  }
  return Math.round(num);
}
/**
 *
 *
 * @author Maaz
 * @since 03/07/2023
 */

function probationerOnLoad() {
  /*console.log('probationerOnLoad>>>');
  let monthStart = window.moment().startOf('month');
  let joinDate = window.moment(this.empData.DateofJoin__c);
  let monthCount = roundOff(monthStart.diff(joinDate, 'months', true)) + 1;
  console.log('monthStart',monthStart + 'joinDate',joinDate + 'monthCount',monthCount);
  if (monthCount > 0) {
    this.data[this.privilegeEligibleBind] = true;
    this.data[this.casualEligibleBind] = true;
  }
  this.data[this.casualLimitBind] = monthCount;
  console.log('this.data[this.casualLimitBind]'+this.data[this.casualLimitBind]);
  this.data[this.privilegeLimitBind] = monthCount;
  
  let privilegeDuration = 0;
  let casualDuration = 0;
  for (let each of this.existingLeaves) {
    if (each.Leave_Type__c === this.casualPickValBind) {
      casualDuration += each.Duration__c;
    } else if (each.Leave_Type__c === this.privilegePickValBind) {
      privilegeDuration += each.Duration__c;
    }
  }
  this.data[this.casualBalanceBind] = monthCount - casualDuration;
  this.data[this.privilegeBalanceBind] = monthCount - privilegeDuration;  
  */
}

function probationerOnInput() {
  // Check for every month
  // const existingLeaves = new Map();
  // for (let each of this.existingLeaves) {
  //   existingLeaves.set(each.Start_Date__c.split('-')[1], each.Leave_Type__c);
  // }
  // if (existingLeaves.has(this.startDate.split('-')[1])) {
  //   this.data[this.casualBalanceBind] = 0;
  // } else {
  //   this.data[this.casualBalanceBind] = 1;
  // }
}
/**
 *
 *
 * @author Maaz
 * @since 03/07/2023
 */
function contractOnLoad() {
  let count = 2;
  let duration = 0;
  let currMonth = window.moment().startOf('month');
  let prevMonth = window.moment().subtract(1, 'months').startOf('month');
  let joinDate = window.moment(this.empData.DateofJoin__c);
  if (roundOff(prevMonth.diff(joinDate, 'months', true)) < 0) {
    count = count + roundOff(prevMonth.diff(joinDate, 'months', true));
  }
  for (let each of this.existingLeaves) {
    if (count === 2 && (prevMonth.isSame(window.moment(each.Start_Date__c), "month") || currMonth.isSame(window.moment(each.Start_Date__c), "month"))) {
      duration += each.Duration__c;
    } else if (count === 1 && currMonth.isSame(window.moment(each.Start_Date__c), "month")) {
      duration += each.Duration__c;
    }
  }
  this.data[this.casualEligibleBind] = true;
  this.data[this.casualLimitBind] = count;
  this.data[this.casualBalanceBind] = count - duration;
}

export { probationerOnLoad, probationerOnInput, contractOnLoad }