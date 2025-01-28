/* eslint-disable @lwc/lwc/no-async-operation */
const isSame = (word, sentence) => {
  return sentence.toLowerCase().includes(word.toLowerCase());
}
function searchFilter(_data, _key) {
  return new Promise((resolve, reject) => {
    try {
      let filteredData = [];
      if (_key.length) {
        filteredData = _data.filter(eachEmp => {
          return _key.split(' ').every(word => isSame(word, eachEmp.Name))
        });
      }
      resolve(filteredData);
    } catch (err) {
      reject(err);
    }
  })
}

export default searchFilter;