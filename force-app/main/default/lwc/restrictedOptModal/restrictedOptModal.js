import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getErrorBody } from './utils/utils.js';

export default class RestrictedOptModal extends LightningElement {
  @api leaveBalance;
  _everydayData;
  modifiedRestrictedObj;
  totalRestrictedSize;
  selectedSize = 0;

  @api set everydayData(value) {
    this._everydayData = value;
    let deepCopy = JSON.parse(JSON.stringify(value));
    this.modifiedRestrictedObj = deepCopy.filter(each => each.isRestricted);
    this.totalRestrictedSize = this.modifiedRestrictedObj.length;
  }
  get everydayData() {
    return this._everydayData;
  }

  closeModal() {
    this.dispatchEvent(new CustomEvent('cancelmodal', {}));
  }

  handleCheck(e) {
    try {
      let key = e.target.dataset.key;
      let val = e.target.checked;
      if (val && (this.selectedSize + 1) > this.leaveBalance) {
        e.target.checked = false;
        let DOMToken = e.target;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
          DOMToken.checked = false;
        }, 300);
        throw new Error(`You have only ${this.leaveBalance} restricted leave/s remaining.`);
      }
      if (val) {
        this.selectedSize++;
        this.modifiedRestrictedObj.forEach(each => {
          if (each.key === parseInt(key, 10)) {
            each.restrictedOpted = true;
          }
        });
      } else {
        this.selectedSize--;
        this.modifiedRestrictedObj.forEach(each => {
          if (each.key === parseInt(key, 10)) {
            each.restrictedOpted = false;
          }
        });
      }
    } catch (error) {
      // console.log('@ handleConfirmation');
      this.dispatchEvent(new ShowToastEvent(getErrorBody(error)));
    }
  }

  confirmSelection() {
    let output = {};
    for (let obj of this.modifiedRestrictedObj) {
      let key = obj.key;
      output[key] = obj;
    }
    this.dispatchEvent(new CustomEvent('restrictsubmit', {
      detail: output
    }))
  }
}