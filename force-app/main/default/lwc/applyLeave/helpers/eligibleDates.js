function findLastIndex(array) {
  let l = array.length;
  while (l--) {
    if (isDayUnchecked(array[l], l, array)){
      return l;
    }
  }
  return -1;
}
function findFirstIndex(array) {
  let l = array.length;
   for (let i = 0; i < l; i++) {
    if (isDayUnchecked(array[i], i, array)){
        return i;
    } 
  }
  return -1;
}
function isDayUnchecked(element) {
   if (element.firstHalfLocked && element.secondHalfLocked) {
    return false;
  } else if (element.firstHalfLocked) {
    return element.secondHalf;
  } else if (element.secondHalfLocked) {
    return element.firstHalf;
  }
  return element.firstHalf || element.secondHalf;
}
function getValidDates(arr) {
  let lastIndex = findLastIndex(arr);
  
  let firstIndex = findFirstIndex(arr);
  let lastDateObject = arr[lastIndex];
  let firstDateObject = arr[firstIndex];

  return { firstDateObject, lastDateObject }

}
export default getValidDates;