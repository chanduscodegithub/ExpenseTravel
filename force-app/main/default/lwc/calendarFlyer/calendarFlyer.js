import { LightningElement, api } from 'lwc';

function animateByBoundingBox(target, container, size) {
  let containerBoundingBox = container.getBoundingClientRect();
  let elementPlusWidth = (2 * containerBoundingBox.width) + size;
  let keyFrames = [{ transform: `translateX(${containerBoundingBox.width}px)` }, { transform: `translateX(${-elementPlusWidth}px)` }];
  let options = {
    duration: (3000 * elementPlusWidth / containerBoundingBox.width) + (20 * containerBoundingBox.width),
    easing: 'linear',
    iterations: Infinity
  };
  target.animate(keyFrames, options);
}

export default class CalendarFlyer extends LightningElement {
  _holidayData;
  formattedLeaves = [];

  @api set holidayData(value) {
    this._holidayData = value;
    let i = 0;
    let today = window.moment();
    for (let each of value) {
      if (window.moment(each[0]).isAfter(today) && each[1].HolidayType === "Restricted Holiday") {
        this.formattedLeaves.push({ dateStr: window.moment(each[0]).format('ddd, Do MMM'), name: `${each[1].Name} (Restricted).`, date: each[0], key: i++ });
      } else if (window.moment(each[0]).isAfter(today)) {
        this.formattedLeaves.push({ dateStr: window.moment(each[0]).format('ddd, Do MMM'), name: `${each[1].Name}.`, date: each[0], key: i++ });
      }
    }
  }
  get holidayData() {
    return this._holidayData;
  }
  renderedCallback() {
    let listDOMToken = this.template.querySelector('ul.holiday__list');
    let containerDOMToken = this.template.querySelector('div.holiday__container');
    let listItem = this.template.querySelectorAll('li.holiday__list-item');
    let size = 0;
    listItem.forEach(each => {
      let computedStyles = getComputedStyle(each);
      size += parseFloat(computedStyles.width.split('px')[0], 10) + parseFloat(computedStyles.marginRight.split('px')[0], 10) + parseFloat(computedStyles.marginLeft.split('px')[0], 10);
    })
    window.addEventListener('resize', () => {
      animateByBoundingBox(listDOMToken, containerDOMToken, size);
    })
    if (listItem) {
      animateByBoundingBox(listDOMToken, containerDOMToken, size);
    }
  }
}