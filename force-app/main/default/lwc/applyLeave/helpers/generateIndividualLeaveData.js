import transformData from './data-transformer.js';
import { CASUAL_PICKVAL, SICK_PICKVAL } from 'c/leaveConfig';

const generateObject = (momentizedStartDate, momentizedEndDate, holidayMap, rawLeaveData, selectedType) => {
  let duration = window.moment.duration(momentizedEndDate.diff(momentizedStartDate));
  let originalDays = duration.asDays() + 1;
  let originalBusinessDays = duration.asDays() + 1;
  let days = duration.asDays() + 1;
  let restrictedHoliday = false;
  let holidayExistsBW = false;
  let leaveExistsBW = false;
  let holidayCount = 0;
  let leaveCount = 0;
  let leaveData = transformData(rawLeaveData, momentizedStartDate.format('YYYY-MM-DD'), momentizedEndDate.format('YYYY-MM-DD'));
  let individualDayData = Array(days).fill(0).map((each, idx) => {
    let data = {
      key: idx,
      firstHalf: true,
      secondHalf: true,
      firstHalfLocked: false,
      secondHalfLocked: false,
      /* dateStr: momentizedStartDate.format('dddd, Do MMMM, YYYY'), */
      dateStr: momentizedStartDate.format('dddd, Do MMMM'),
      date: momentizedStartDate.format('YYYY-MM-DD'),
      locked: false,
      lockReason: '',
      isWeekDay: true,
      dayType: 'BusinessDay',
      isRestricted: false,
      restrictedOpted: false
    };
    if (momentizedStartDate.isoWeekday() === 6 || momentizedStartDate.isoWeekday() === 7) {
      data.isWeekDay = false;
      data.dayType = 'Weekend';
      days = days - 1;
      originalBusinessDays -= 1;
    } else if (holidayMap.has(data.date) && !leaveData.has(data.date)) {
      holidayExistsBW = true;
      holidayCount += 1;
      data.lockReason = holidayMap.get(data.date).Name;
      data.dayType = holidayMap.get(data.date).HolidayType;
      if (data.dayType === 'Restricted Holiday') {
        data.isRestricted = true;
        restrictedHoliday = true;
      } else {
        data.locked = true;
        days = days - 1;
      }
      data.firstHalf = false;
      data.secondHalf = false;
    } else if (leaveData.has(data.date)) {
      leaveExistsBW = true;
      let existingData = leaveData.get(data.date);
      data.firstHalfLocked = existingData.firstHalf;
      data.secondHalfLocked = existingData.secondHalf;
      if (existingData.firstHalf && existingData.secondHalf) {
        data.dayType = 'On Leave';
        data.locked = true;
        data.lockReason = existingData.reason;
        days = days - 1;
        leaveCount += 1;
      } else if (selectedType === CASUAL_PICKVAL || selectedType === SICK_PICKVAL) {
        days = days - 0.5;
        leaveCount += 0.5;
      } else {
        data.firstHalfLocked = true;
        data.secondHalfLocked = true;
        data.firstHalf = true;
        data.secondHalf = true;
        data.dayType = 'On Half Day Leave';
        data.locked = true;
        data.lockReason = existingData.reason;
        days = days - 1;
        leaveCount += 1;
      }
    }
    momentizedStartDate.add(1, 'day');
    return data;
  });
  return { days, individualDayData, restrictedHoliday, holidayExistsBW, holidayCount, leaveExistsBW, leaveCount, originalDays, originalBusinessDays }
}

export default generateObject;