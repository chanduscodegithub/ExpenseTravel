import { RESTRICTED_PICKVAL } from 'c/leaveConfig';
function transformData(rawData, startDateStr, endDateStr) {
  let startDateMoment = window.moment(startDateStr);
  let endDateMoment = window.moment(endDateStr);
  let existingLeaveMap = new Map();
  rawData.forEach(each => {
    if (each?.Individual_Time_off__r?.length) {
      each.Individual_Time_off__r.forEach(eachIndi => {
        let newObj = {};
        newObj.reason = `${each.Leave_Type__c} - ${each.Status__c}`;
        newObj.type = each.Leave_Type__c;
        if (eachIndi.Time_off_Duration__c === 'Full Day') {
          newObj.firstHalf = true;
          newObj.secondHalf = true;
        } else if (eachIndi.Time_off_Duration__c === 'Half Day' && eachIndi.Time_Slot_Selection__c === 'First Half') {
          newObj.firstHalf = true;
          newObj.secondHalf = false;
        } else if (eachIndi.Time_off_Duration__c === 'Half Day' && eachIndi.Time_Slot_Selection__c === 'Second Half') {
          newObj.firstHalf = false;
          newObj.secondHalf = true;
        }
        if (existingLeaveMap.has(eachIndi.Leave_Date__c)) {
          let existingObj = existingLeaveMap.get(eachIndi.Leave_Date__c);
          if (existingObj.firstHalf && existingObj.secondHalf) {
            newObj.firstHalf = true;
            newObj.secondHalf = true;
          } else if (existingObj.firstHalf) {
            newObj.firstHalf = true;
          } else if (existingObj.secondHalf) {
            newObj.secondHalf = true;
          }
          if (existingObj.type === RESTRICTED_PICKVAL) {
            newObj.reason = RESTRICTED_PICKVAL;
          } else {
            newObj.reason += `: Half Day, ${existingObj.reason + ': Half Day'}`;
          }
        }
        existingLeaveMap.set(eachIndi.Leave_Date__c, newObj);
      })
    } else {
      let scopedStartMoment = window.moment(each.Start_Date__c);
      let scopedEndMoment = window.moment(each.End_Date__c);
      let selectedStart = scopedStartMoment.isAfter(startDateMoment) ? scopedStartMoment : startDateMoment;
      let selectedEnd = scopedEndMoment.isAfter(endDateMoment) ? endDateMoment : scopedEndMoment;
      while (selectedEnd.isAfter(selectedStart) || selectedEnd.isSame(selectedStart)) {
        let newObj = {};
        newObj.reason = `${each.Leave_Type__c} - ${each.Status__c}`;
        newObj.firstHalf = true;
        newObj.secondHalf = true;
        newObj.type = each.Leave_Type__c;
        if (existingLeaveMap.has(selectedStart.format('YYYY-MM-DD'))) {
          let existingObj = existingLeaveMap.get(selectedStart.format('YYYY-MM-DD'));
          if (existingObj.type === RESTRICTED_PICKVAL) {
            newObj.type = RESTRICTED_PICKVAL;
            newObj.reason = RESTRICTED_PICKVAL;
          } else {
            newObj.reason += ` + ${existingObj.reason}`;
          }
        }
        existingLeaveMap.set(selectedStart.format('YYYY-MM-DD'), newObj);
        selectedStart.add(1, 'day');
      }
    }
  });
  return existingLeaveMap;
}
export default transformData;