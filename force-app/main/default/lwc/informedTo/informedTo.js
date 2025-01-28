// Core Imports
import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Server Imports
import searchHelper from './searchHelper.js';

function getInitSelectEmp() {
  let allEmails = this.lastLeaveData.Informed_Users__c.split(';');
  for (let object of this.restOfEmployee) {
    if (allEmails.includes(object?.SF_User__r?.Email)) {
      this.selectedEmployeeList.push(object);
    }
  }
  this.modifiedProp_restOfEmp = this.modifiedProp_restOfEmp.filter(_ => !allEmails.includes(_?.SF_User__r?.Email));
}

export default class InformedTo extends LightningElement {
  _restOfEmployee;
  _lastLeaveData
  modifiedProp_restOfEmp = [];
  selectedEmployeeName;
  selectedEmployeeList = [];
  searchedEmp = [];

  @api set lastLeaveData(value) {
    if (value !== undefined) {
      this._lastLeaveData = value;
    }
  }
  get lastLeaveData() {
    return this._lastLeaveData;
  }
  @api set restOfEmployee(value) {
    if (value !== undefined) {
      this._restOfEmployee = value;
      this.modifiedProp_restOfEmp = JSON.parse(JSON.stringify(value));
    }
  }
  get restOfEmployee() {
    return this._restOfEmployee;
  }
  get listClass() {
    return this.searchedEmp.length ? 'search_res' : 'search_res off'
  }
  async handleInput(e) {
    let keyWord = e.target.value.trim();
    if (keyWord.length) {
      this.searchedEmp = await searchHelper(this.modifiedProp_restOfEmp, keyWord.trim());
    } else {
      this.searchedEmp = [];
    }
  }
  empSelect(e) {
    try {
      let _selectedEmp = e.target.dataset.id;
      let filteredArr = this.modifiedProp_restOfEmp.filter(_ => _.Id === _selectedEmp);
      this.modifiedProp_restOfEmp = this.modifiedProp_restOfEmp.filter(_ => _.Id !== _selectedEmp);
      this.selectedEmployeeList.push(filteredArr[0]);
      if (filteredArr[0].SF_User__r.Email === undefined) {
        throw new Error('Error: Selected employee data is improper, please contact Admin Team');
      }
      this.searchedEmp = [];
      this.selectedEmployeeName = '';
      this.dispatchEvent(new CustomEvent('empevt', {
        detail: {
          actionType: 'push',
          email: filteredArr[0].SF_User__r.Email
        }
      }));
      //? Some issue with abstract tree not noticing the DOM update.
      let empSearchDOMToken = this.template.querySelector('lightning-input.employee__input');
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      setTimeout(() => {
        empSearchDOMToken.value = '';
      }, 300);
    } catch (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error!',
          message: `${error}`,
          variant: 'error'
        })
      );
    }
  }
  handleRemoveEmp(e) {
    try {
      let empId = e.target.dataset.emp;
      let originalValue = this.restOfEmployee.filter(_ => _.Id === empId);
      this.modifiedProp_restOfEmp.push(originalValue[0]);
      if (originalValue[0].SF_User__r.Email === undefined) {
        throw new Error('Error: Selected employee data is improper, please contact Admin Team');
      }
      this.dispatchEvent(new CustomEvent('empevt', {
        detail: {
          actionType: 'pop',
          email: originalValue[0].SF_User__r.Email
        }
      }));
      this.selectedEmployeeList = this.selectedEmployeeList.filter(each => each.Id !== empId);
    } catch (error) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error!',
          message: `${error}`,
          variant: 'error'
        })
      );
    }
  }
  connectedCallback() {
    if (this.lastLeaveData !== undefined && this.lastLeaveData != null && this.restOfEmployee !== undefined && this.restOfEmployee != null && this.lastLeaveData.Informed_Users__c) {
      getInitSelectEmp.call(this);
    }
  }
}