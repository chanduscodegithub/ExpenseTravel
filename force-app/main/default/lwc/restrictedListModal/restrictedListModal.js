import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getErrorBody } from './utils/utils';
import { RESTRICTED_PICKVAL } from 'c/leaveConfig';

export default class RestrictedListModal extends LightningElement {
  _holidayData;
  _existingLeaves;
  restrictedLeaves = [];
  selectedLeaves = [];
  existingLeavesSet;
  @api restrictedBalance;
  @api set holidayData(value) {
    this._holidayData = value;
    let i = 0;
    for (let each of value) {
      if (each[1].HolidayType === RESTRICTED_PICKVAL) {
        this.restrictedLeaves.push({ dateStr: window.moment(each[0]).format('dddd, Do MMMM'), name: each[1].Name, date: each[0], key: i++, used: false });
      }
    }
  }
  get holidayData() {
    return this._holidayData;
  }
  @api set existingLeaves(value) {
    this._existingLeaves = value;
    const existingRestrictedLeave = new Set();
    value.forEach(each => {
      existingRestrictedLeave.add(each.Start_Date__c);
    });
    this.existingLeavesSet = existingRestrictedLeave;
  }
  get existingLeaves() {
    return this._existingLeaves;
  }
  handleCheck(e) {
    try {
      let key = e.target.dataset.key;
      if (e.target.checked) {
        if (this.selectedLeaves.length === this.restrictedBalance) {
          e.target.checked = false;
          throw new Error(`You have only ${this.restrictedBalance} restricted leaves remaining.`);
        }
        let item = this.restrictedLeaves.find(each => each.key === parseInt(key, 10));
        this.selectedLeaves.push(item);
      } else {
        this.selectedLeaves = this.selectedLeaves.filter(each => each.key !== parseInt(key, 10));
      }
    } catch (error) {
      this.dispatchEvent(new ShowToastEvent(getErrorBody(error)));
    }
  }
  closeModal() {
    this.dispatchEvent(new CustomEvent('closeleavelist', {
      detail: true
    }));
  }
  confirmSelection() {
    try {
      if (this.selectedLeaves.length) {
        this.dispatchEvent(new CustomEvent('saveleavelist', {
          detail: this.selectedLeaves
        }));
      } else {
        throw new Error('No restricted leaves selected.')
      }
    } catch (error) {
      this.dispatchEvent(new ShowToastEvent(getErrorBody(error)));
    }
  }
  connectedCallback() {
    this.restrictedLeaves.forEach(each => {
      if (this.existingLeavesSet.has(each.date)) {
        each.used = true;
        each.leaveOpted = true;
      }
      return each;
    })
  }
}