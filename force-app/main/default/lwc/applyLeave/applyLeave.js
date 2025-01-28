/**
 * @description       : 
 * @author            : Ambika
 * @group             : 
 * @last modified on  : 03-21-2024
 * @last modified by  : Ambika 
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   03-21-2024   Ambika   Initial Version
**/
// Core Imports
import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { loadScript } from "lightning/platformResourceLoader";

// Schema
import LEAVE_TYPE from '@salesforce/schema/Employee_Leave__c.Leave_Type__c';
import EMPLEAVE from "@salesforce/schema/Employee_Leave__c";

// Server Imports
import getEmployeeDetails from '@salesforce/apex/LeaveHandler.getEmployeeDetails';
import allOtherEmployees from '@salesforce/apex/LeaveHandler.allOtherEmployees';
import getExistingLeaves from '@salesforce/apex/LeaveHandler.existingLeaves';
import fetchHolidays from '@salesforce/apex/HolidayHandler.getHolidays';
import saveLeave from '@salesforce/apex/LeaveHandler.saveLeave';
import saveRestricted from '@salesforce/apex/LeaveHandler.saveRestricted';
import sendLeaveBalInMail from '@salesforce/apex/EmailLeaveOrApprovalController.sendLeaveBalInMail';

// Local Imports
import processOnLoad from './config/onLoad.js';
import generateObject from './helpers/generateIndividualLeaveData.js';
import getValidDates from './helpers/eligibleDates.js';
import adjustPicklist from './helpers/stripPicklist.js'
import { validate, dateValidation } from './validators/validations.js';
import { populateData as unbindedPopulateData, partialPopulate as unbindedPartialPopulate } from './helpers/conditionalPopulate';
import { probationerOnLoad as processProbationerOnLoad, contractOnLoad as processContractOnLoad } from './helpers/conditionalProRata.js';
import { getPicklistAPIName, getErrorBody, getEligibleDate, getCurrDateInSFStr, clearData as unbindedClearData } from './utils/utils.js';

//Resources and Lib
import moment from "@salesforce/resourceUrl/MomentJS";
import confetti from "@salesforce/resourceUrl/ConfettiJS";

// Finals
import {
  PERMANENT_PICKVAL,
  PROBATIONER_PICKVAL,
  CONTRACTOR_PICKVAL,
  CELEBRATION_PICKVAL,
  MATERNITY_PICKVAL,
  PATERNITY_PICKVAL,
  CASUAL_PICKVAL,
  SICK_PICKVAL,
  PAID_PICKVAL,
  WFH_PICKVAL,
  PAIDADJ_PICKVAL,
  RESTRICTED_PICKVAL,
  LONG_PICKVAL,
  BEREAVEMENT_PICKVAL,
  PAID_ELIGIBLE_CLSMEM,
  WFH_ELIGIBLE_CLSMEM,
  PAIDADJ_ELIGIBLE_CLSMEM,
  CASUAL_ELIGIBLE_CLSMEM,
  SICK_ELIGIBLE_CLSMEM,
  PATERNITY_ELIGIBLE_CLSMEM,
  MATERNITY_ELIGIBLE_CLSMEM,
  BEREAVEMENT_ELIGIBLE_CLSMEM,
  LOP_ELIGIBLE_CLSMEM,
  CASUAL_LIMIT_CLSMEM,
  PAID_LIMIT_CLSMEM,
  WFH_LIMIT_CLSMEM,
  PAIDADJ_LIMIT_CLSMEM,
  SICK_LIMIT_CLSMEM,
  CELEBRATION_LIMIT_CLSMEM,
  LOP_LIMIT_CLSMEM,
  MATERNITY_BAL_CLSMEM,
  PATERNITY_BAL_CLSMEM,
  CASUAL_BAL_CLSMEM,
  PAID_BAL_CLSMEM,
  WFH_BAL_CLSMEM,
  PAIDADJ_BAL_CLSMEM,
  BEREAVEMENT_BAL_CLSMEM,
  CELEBRATION_BAL_CLSMEM,
  RESTRICTED_BAL_CLSMEM,
  LOP_BAL_CLSMEM,
  CASUAL_CARRY_CLSMEM,
  SICK_CARRY_CLSMEM,
  PRIVILEGE_CARRY_CLSMEM,
  CELEBRATION_CARRY_CLSMEM,
  //PROBATIONER_PAID_BAL_CLSMEM,
  //PROBATIONER_CASUAL_BAL_CLSMEM
} from 'c/leaveConfig';

export default class ApplyLeave extends LightningElement {
  // Flags
  spinnerFlag = true;
  isModalOpen;
  showTable;
  restrictedModalFlag;
  restrictedListFlag;
  additionalModalContent = false;
  furloughWarning = false;
  reportModalFlag = false;
  holidayModalFlag = false;
  includeReportees = false;
  // Picklist
  leaveOptions;
  vanillaLeaveOpts;
  // Data
  data;
  reportingEmployee;
  empData;
  rawHolidays;
  holidayData; //! Map
  restEmployees;
  informToEmp = [];
  existingLeaves;
  lastLeaveInformedTo;
  // Inputs
  startDate;
  endDate;
  onLoadStartDate;
  endDateDOMToken;
  startDateDOMToken;
  selectedType;
  reason;
  // Auto Populated
  duration = 0;
  dayCollection = [];

  get isValidSelectedType() {
    return this.selectedType != null && this.selectedType !== undefined && this.selectedType !== '';
  }
  get isStartDateValid() {
    return this.startDate != null && this.startDate !== undefined && this.startDate !== '';
  }
  get isEndDateValid() {
    return this.endDate != null && this.endDate !== undefined && this.endDate !== '';
  }
  get isDateValid() {
    return this.isStartDateValid && this.isEndDateValid;
  }
  get isDataValid() {
    return this.isDateValid && this.isValidSelectedType;
  }
  get isDataInvalid() {
    return !this.isDataValid;
  }
  get allowSaveDisable() {
    return this.isDataInvalid || this.duration <= 0;
  }
  get havePopulateCriteria() {
    return this.isStartDateValid && this.isValidSelectedType && !this.isEndDateValid;
  }
  get havePartialPopulateCriteria() {
    return this.startDate === this.onLoadStartDate && this.isValidSelectedType && !this.isEndDateValid;
  }
  get tableView() {
    return this.showTable && this.isDataValid;
  }
  get reportButtonAllowed() {
    return this.empData.Type__c === PERMANENT_PICKVAL;
  }
  get getHolidayHeading() {
    return `Region: ${this.empData.Region__c} Holidays`
  }

  @wire(getObjectInfo, { objectApiName: EMPLEAVE })
  leaveObjInfo;

  @wire(getPicklistValues, { recordTypeId: "$leaveObjInfo.data.defaultRecordTypeId", fieldApiName: LEAVE_TYPE })
  wiredFuncforPick1({ data, error }) {
    if (data) {
      this.vanillaLeaveOpts = data.values.filter(ele => ele.value !== 'Carry Forward');
      if (this.data) {
        this.stripPicklist(this.vanillaLeaveOpts);
      }
    }
    if (error) {
      console.log('@ Wire');
      this.dispatchEvent(new ShowToastEvent(getErrorBody(error)));
    }
  }

  /**
    * A function that handles the input event of the start date and end date fields and updates the state of the component accordingly.
    * It also validates the input values and throws an error if they are not in the current year or if the end date is before the start date.
    * It also calls the renderTable and populateData methods if the data is valid and the populate criteria is met.
    * @param {Event} e The input event object that contains the input value and the data type attribute of the field.
    * @throws Error If the input value is not in the current year or if the end date is before the start date.
    * @throws ShowToastEvent If there is any other error during the execution of the function.
    * @author Maaz
    * @since 03/07/2023
    */
  // eslint-disable-next-line consistent-return
  async handleInput(e) {
    try {
      this.spinnerFlag = true;
      const { target, currentTarget } = e;
      const { value } = target;
      if (value == null || value === undefined) {
        this.spinnerFlag = false;
        return;
      }
      const momentDate = window.moment(value);
      if (this.isValidSelectedType && momentDate.isoWeekday() === 6 && this.selectedType !== MATERNITY_PICKVAL && this.selectedType !== PATERNITY_PICKVAL) {
        momentDate.add(2, 'day');
        target.value = momentDate.format('YYYY-MM-DD');
      } else if (this.isValidSelectedType && momentDate.isoWeekday() === 7 && this.selectedType !== MATERNITY_PICKVAL && this.selectedType !== PATERNITY_PICKVAL) {
        momentDate.add(1, 'day');
        target.value = momentDate.format('YYYY-MM-DD');
      }
      if (currentTarget.dataset.type === 'start-date' && this.startDate !== value) {
        this.startDate = value;
      } else if (currentTarget.dataset.type === 'end-date' && this.endDate !== value) {
        this.endDate = value;
      } else {
        this.spinnerFlag = false;
        return;
      }
      if (this.isValidSelectedType && this.selectedType === CELEBRATION_PICKVAL) {
        this.startDate = value;
        this.endDate = value;
      }
      if (this.havePopulateCriteria || (this.isDateValid && this.selectedType === CELEBRATION_PICKVAL)) {
        await this.populateData();
      }
      if (this.isDataValid) {
        dateValidation.call(this);
        this.renderTable();
      } else if (this.isDateValid) {
        const momentizedStartDate = window.moment(this.startDate);
        const momentizedEndDate = window.moment(this.endDate);
        const duration = window.moment.duration(momentizedEndDate.diff(momentizedStartDate));
        const days = duration.asDays() + 1;
        
        if (days <= 0) {
          throw new Error('End date cannot be before start date.');
        }
      }
      this.spinnerFlag = false;
    } catch (error) {
      this.endDate = null;
      this.spinnerFlag = false;
      console.log('@ handleInput');
      this.dispatchEvent(new ShowToastEvent(getErrorBody(error)));
    }
  }
  /**
    *
    *
    * @param {*} e
    * @memberof ApplyLeave
    */
  handleReasonInput(e) {
    this.reason = e.target.value;
  }
  /**
    * A function that handles the click event of the leave type cards and updates the state of the component accordingly.
    * It also calls the getPicklistAPIName function to get the picklist API name for the selected card and assigns it to the selectedType property.
    * It also calls the populateData and renderTable methods if the populate criteria and data are valid respectively.
    * It also scrolls the view to the appropriate element based on the selected leave type.
    * @param {CustomEvent} e The click event object that contains the action type of the clicked card.
    * @throws ShowToastEvent If there is any error during the execution of the function.
    * @author Maaz
    * @since 03/07/2023
    */
  async handleCardClick(e) {
    try {
      let selectedCard = getPicklistAPIName(e.detail.actionType);
      if (this.selectedType !== selectedCard && this.isValidSelectedType) {
        this.clearData();
      }
      this.selectedType = selectedCard;
      if (this.havePartialPopulateCriteria) {
        this.partialPopulate();
      }
      if (this.havePopulateCriteria || (this.isDateValid && this.selectedType === CELEBRATION_PICKVAL)) {
        await this.populateData();
      }
      let DropdownDOMToken = this.template.querySelector('lightning-combobox.selectedType');
      switch (this.selectedType) {
        case CELEBRATION_PICKVAL:
        case MATERNITY_PICKVAL:
        case PATERNITY_PICKVAL:
          // eslint-disable-next-line @lwc/lwc/no-async-operation
          setTimeout(() => {
            DropdownDOMToken.scrollIntoView();
          }, 1000);
          break;
        case CASUAL_PICKVAL:
        case SICK_PICKVAL:
        case PAID_PICKVAL:
        case BEREAVEMENT_PICKVAL:
        case PAIDADJ_PICKVAL:
        case WFH_PICKVAL:
          // eslint-disable-next-line @lwc/lwc/no-async-operation
          setTimeout(() => {
            DropdownDOMToken.scrollIntoView();
          }, 300);
          break;
        default:
          break;
      }
      if (this.isDataValid) {
        dateValidation.call(this);
        this.renderTable();
      }
      if (this.selectedType === RESTRICTED_PICKVAL) {
        this.restrictedListFlag = true;
      }
    } catch (error) {
      this.spinnerFlag = false;
      console.log('@ handleCardClick');
      this.dispatchEvent(new ShowToastEvent(getErrorBody(error)));
    }
  }
  /**
    * A function that handles the change event of the leave type picklist and updates the state of the component accordingly.
    * It also calls the renderTable and populateData methods if the data is valid and the populate criteria is met.
    * @param {Event} e The change event object that contains the selected leave type value.
    * @throws ShowToastEvent If there is any error during the execution of the function.
    * @author Maaz
    * @since 03/07/2023
    */
  async handleTypeChange(e) {
    try {
      this.spinnerFlag = true;
      if (this.selectedType !== e.target.value && this.isValidSelectedType) {
        this.clearData();
      }
      this.selectedType = e.target.value;
      if (this.havePartialPopulateCriteria) {
        this.partialPopulate();
      }
      if (this.havePopulateCriteria || (this.isDateValid && this.selectedType === CELEBRATION_PICKVAL)) {
        await this.populateData();
      }
      if (this.isDataValid) {
        dateValidation.call(this);
        this.renderTable();
      }
      if (this.selectedType === RESTRICTED_PICKVAL) {
        this.restrictedListFlag = true;
      }
      this.spinnerFlag = false;
    } catch (error) {
      this.spinnerFlag = false;
      console.log('@ handleTypeChange');
      this.dispatchEvent(new ShowToastEvent(getErrorBody(error)));
    }
  }
  /**
    * A function that renders the table of leave days based on the selected leave type and the start date and end date properties.
    * It also calls the generateObject function to get the number of days, individual day data and restricted holiday flag for the given date range and holiday data.
    * It also updates the duration and dayCollection properties accordingly and handles the case when there is a restricted holiday and the employee is eligible for it.
    * It also validates the date range and throws an error if the end date is before the start date.
    * @throws Error If the end date is before the start date.
    * @throws ShowToastEvent If there is any other error during the execution of the function or the generateObject function. 
    * @author Maaz
    * @since 03/07/2023
    */
  renderTable() {
    try {
      this.spinnerFlag = true;
      const momentizedStartDate = window.moment(this.startDate);
      const momentizedEndDate = window.moment(this.endDate);
      const { days, individualDayData, restrictedHoliday, holidayCount, holidayExistsBW, leaveCount, leaveExistsBW, originalDays, originalBusinessDays } = generateObject(momentizedStartDate, momentizedEndDate, this.holidayData, this.existingLeaves, this.selectedType);
      this.additionalModalContent = leaveExistsBW ? true : holidayExistsBW;
      if (holidayCount + leaveCount >= originalBusinessDays && holidayExistsBW && leaveExistsBW) {
        this.startDate = null;
        this.endDate = null;
        throw new Error('Leave/Holiday exists entirely between selected dates');
      }
      if (days <= 0 && holidayExistsBW && !leaveExistsBW) {
        this.startDate = null;
        this.endDate = null;
        throw new Error('Holiday exists entirely between selected dates');
      }
      if (days <= 0 && leaveExistsBW && !holidayExistsBW) {
        this.startDate = null;
        this.endDate = null;
        throw new Error('Leave exists entirely between selected dates');
      }
      if (days <= 0) {
        this.startDate = null;
        throw new Error('Please check the start date and end date.');
      }
      if (restrictedHoliday && this.data.restrictedEligible && this.data.restrictedBalance > 0 && (this.selectedType === CASUAL_PICKVAL || this.selectedType === SICK_PICKVAL || this.selectedType === PAID_PICKVAL || this.selectedType === BEREAVEMENT_PICKVAL)) {
        this.restrictedModalFlag = restrictedHoliday;
      }
      if (this.selectedType === MATERNITY_PICKVAL || this.selectedType === LONG_PICKVAL) {
        this.duration = originalDays;
      } else {
        this.duration = days;
      }
      this.dayCollection = individualDayData.filter(each => each.isWeekDay);
       if (this.selectedType === PAID_PICKVAL && this.data[this.privilegeBalanceBind] - this.duration <= 5&& this.empData.Type__c === this.permanentPickValBind) {
         this.furloughWarning = true;
       } else {
         this.furloughWarning = false;
       }
      if (this.selectedType === CASUAL_PICKVAL || this.selectedType === SICK_PICKVAL) {
        this.showTable = true;
      } else {
        this.showTable = false;
      }
      this.spinnerFlag = false;
    } catch (error) {
      console.log('@ renderTable');
      if (error.message.includes('Invalid array length')) {
        this.dispatchEvent(new ShowToastEvent(getErrorBody('End date cannot be before start date.')));
      } else {
        this.dispatchEvent(new ShowToastEvent(getErrorBody(error)));
      }
      this.spinnerFlag = false;
      this.restrictedModalFlag = false;
      this.showTable = false;
    }
  }
  /**
    * A function that handles the change event of the checkbox elements in the table and updates the dayCollection and duration properties accordingly.
    * It also uses the data key and name attributes of the checkbox element to identify the corresponding object and property in the dayCollection array.
    * @param {Event} e The change event object that contains the checked value, data key and name of the checkbox element.
    * @author Maaz
    * @since 03/07/2023
    */
  handleCheck(e) {
    let key = e.target.dataset.key;
    let prop = e.target.name === 'First Half' ? 'firstHalf' : 'secondHalf';
    let val = e.target.checked;
    this.dayCollection.forEach(each => {
      if (each.key === parseInt(key, 10)) {
        each[prop] = val;
      }
    });
    if (val) {
      this.duration += 0.5;
    } else {
      this.duration -= 0.5;
    }
  }
  /**
    * 
    * 
    * @author Maaz
    * @since 03/07/2023
    */
  handleConfirmation() {
    try {
      validate.call(this);
      this.isModalOpen = true;
    } catch (error) {
      console.log('@ handleConfirmation');
      this.isModalOpen = false;
      this.dispatchEvent(new ShowToastEvent(getErrorBody(error)));
    }
  }
  /**
    * 
    * 
    * @author Maaz
    * @since 04/07/2023
    */
  handleCancelRestricted() {
    this.clearData()
    this.showTable = false;
    this.restrictedModalFlag = false;
  }
  /**
    * 
    * @param {CustomEvent} e 
    * @author Maaz
    * @since 13/07/2023
    */
  async handleSaveRestricted(e) {
    try {
      this.spinnerFlag = true;
      let data = e.detail;
      console.log('data'+data);
      await saveRestricted({ empStr: JSON.stringify(this.empData), reportingEmployee: JSON.stringify(this.reportingEmployee), leaveData: JSON.stringify(data) })
      this.spinnerFlag = false;
      this.restrictedListFlag = false;
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Applied!',
          message: `Successfully applied the leave.`,
          variant: 'success'
        })
      );
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      setTimeout(() => {
        window.location.reload();
      }, 1000);
    } catch (error) {
      this.spinnerFlag = false;
      this.restrictedListFlag = false;
      this.clearData();
      console.log('@ handleSaveRestricted');
      this.dispatchEvent(new ShowToastEvent(getErrorBody(error)));
    }
  }
  /**
    * A method that handles if the employee is opting Restricted that is falling in between their leaves.
    *
    * @param {CustomEvent} e The CustomEvent event that contains the modified restricted object.
    * @author Maaz
    * @since 04/07/2023
    */
  handleRestrictSubmit(e) {
    try {
      this.spinnerFlag = true;
      let modifiedRestrictedObj = e.detail;
      this.dayCollection = this.dayCollection.map(each => {
        if (modifiedRestrictedObj[each.key]) {
          let obj = modifiedRestrictedObj[each.key];
          if (obj.isRestricted && !obj.restrictedOpted) {
            obj.firstHalf = true;
            obj.secondHalf = true;
          } else {
            this.duration = this.duration - 1;
          }
          return obj;
        }
        return each;
      });
      
      if (this.selectedType === PAID_PICKVAL && this.data[this.privilegeBalanceBind] - this.duration <= 5 && this.empData.Type__c === this.permanentPickValBind) {
        this.furloughWarning = true;
      } else {
        this.furloughWarning = false;
      } 
      this.restrictedModalFlag = false;
      this.spinnerFlag = false;    
    } catch (error) {
      this.spinnerFlag = false;
      this.restrictedModalFlag = false;
      console.log('@ handleRestrictSubmit');
      this.dispatchEvent(new ShowToastEvent(getErrorBody(error)));
    }
  }
  /**
    * 
    * @param {CustomEvent} e 
    * @author Maaz
    * @since 03/07/2023
    */
  async handleModalEvent(e) {
    if (e.detail.state === 'applying' && e.detail.value) {
      this.handleApply();
    } else if (e.detail.state === 'applying' && !e.detail.value) {
      this.isModalOpen = false;
    } else if (e.detail.state === 'reports' && e.detail.value) {
      this.reportModalFlag = false;
      this.spinnerFlag = true;
      await sendLeaveBalInMail({ forReportees: this.includeReportees });
      this.spinnerFlag = false;
    } else if (e.detail.state === 'reports' && !e.detail.value) {
      this.reportModalFlag = false;
    } else if (e.detail.state === 'calendar') {
      this.holidayModalFlag = false;
    }
  }
  /**
    * 
    * @author Maaz
    * @since 03/07/2023
    */
  handleCloseLeaveList() {
    this.spinnerFlag = true;
    this.clearData();
    this.restrictedListFlag = false;
    this.spinnerFlag = false;
  }
  /**
    * 
    * @param {CustomEvent} e 
    * @author Maaz
    * @since 03/07/2023
    */
  handleInformedEmp(e) {
    let evtData = e.detail;
    if (evtData.actionType === 'push') {
      this.informToEmp.push(evtData.email);
    } else if (evtData.actionType === 'pop') {
      this.informToEmp = this.informToEmp.filter(_email => _email !== evtData.email);
    }
  }
  /**
    *
    *
    * @memberof ApplyLeave
    */
  handleHolidayPopUp() {
    this.holidayModalFlag = true;
  }
  /**
    *
    *
    * @memberof ApplyLeave
    */
  handleLeaveBalanceReport() {
    this.reportModalFlag = true;
  }
  /**
    *
    *
    * @param {CustomEvent} e
    * @memberof ApplyLeave
    */
  handleCheckReportees(e) {
    this.includeReportees = e.target.checked;
  }
  /**
    * An async function that handles the click event of the apply button and saves the leave request to the database using the saveLeave apex method.
    * It also calculates the start date and end date based on the selected leave type and the dayCollection array.
    * It also displays a toast message to indicate the success or failure of the operation and reloads the window after a delay.
    * @throws ShowToastEvent If there is any error during the execution of the function or the apex method.
    * @author Maaz
    * @since 03/07/2023
    */
  async handleApply() {
    try {
      this.spinnerFlag = true;
      let startDate;
      let endDate;
      let successMessage;
      if(this.selectedType === WFH_PICKVAL){
        successMessage = 'Successfully applied for Work From Home.';
      }
      else{
        successMessage = 'Successfully applied the leave.';
      }
      if (this.selectedType === CELEBRATION_PICKVAL || this.selectedType === PATERNITY_PICKVAL  /*|| this.selectedType === PAID_PICKVAL */ || this.selectedType === BEREAVEMENT_PICKVAL) {
        startDate = this.startDate;
        endDate = this.endDate;
      }
      else {        
        const { firstDateObject, lastDateObject } = getValidDates(this.dayCollection);
        //startDate = firstDateObject.date;
        startDate = (this.selectedType === PAID_PICKVAL) ? this.startDate : firstDateObject.date;
        //endDate = lastDateObject.date;
        endDate = (this.selectedType === PAID_PICKVAL) ? this.endDate : lastDateObject.date;
        }
      await saveLeave({ duration: this.duration, selectedType: this.selectedType, empStr: JSON.stringify(this.empData), reportingEmployee: JSON.stringify(this.reportingEmployee), individualDetails: JSON.stringify(this.dayCollection), reason: this.reason, informedTo: this.informToEmp, startDate, endDate });
      this.spinnerFlag = false;
      this.isModalOpen = false;
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Applied!',
          message: successMessage,
          variant: 'success'
        })
      );
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      setTimeout(() => {
        window.location.reload();
      }, 1000);
    } catch (error) {
      this.spinnerFlag = false;
      console.log('@ handleApply');
      this.dispatchEvent(new ShowToastEvent(getErrorBody(error)));
    }
  }
  /**
    * A lifecycle hook that is invoked when the component is inserted into the document.
    * It loads the moment and Confetti scripts and sets the startDate property to the current date.
    * It also calls the getEmployeeDetails and allOtherEmployees apex methods to fetch the employee data and assign them to the data, reportingEmployee, empData and restEmployees properties.
    * It also binds the unbindedPopulateData function to the component context and assigns it to the populateData property.
    * It also calls the stripPicklist function if the leaveOptions property is not null.
    * It also fetch all the existing holidays for the current employee.
    * It also handles any errors that occur during the script loading or apex methods and displays a toast message accordingly.
    * It also calls the getExistingLeaves and set the existing leave data.
    * @author Maaz
    * @since 03/07/2023
    */
  connectedCallback() {
    this.spinnerFlag = true;
    Promise.all([loadScript(this, moment), loadScript(this, confetti), getEmployeeDetails({}), allOtherEmployees({}), getExistingLeaves({}), fetchHolidays({})])
      .then(results => {
        /** This code uses Promise.all to execute multiple asynchronous tasks in parallel
          * The tasks are: loading two scripts (moment and Confetti), getting employee details, getting all other employees, getting existing leaves, and fetching holidays
          * The results of the tasks are passed as an array to the then method, which can handle them as needed
          * The catch method handles any errors that may occur in any of the tasks
          * results[0] is the moment script
          * results[1] is the Confetti script
          * results[2] is the employee details object
          * results[3] is the array of other employees
          * results[4] is the array of existing leaves
          * results[5] is the array of holidays 
          */
        this.data = results[2];
        this.reportingEmployee = results[2].empData.ReportingTo__r;
        this.empData = results[2].empData;
        this.restEmployees = results[3];
        this.existingLeaves = results[4];
        this.lastLeaveInformedTo = results[4].find(each => each?.Informed_Users__c !== '' && each?.Informed_Users__c !== null );
        if (this.lastLeaveInformedTo?.Informed_Users__c) {
          this.informToEmp.push(...this.lastLeaveInformedTo.Informed_Users__c.split(';'));
        }
        this.rawHolidays = results[5];
        let holidayMap = new Map();
        for (let holiday of results[5]) {
          holidayMap.set(holiday.Date__c, { Name: holiday.Name, HolidayType: holiday.Holiday_Type__c });
        }
        this.holidayData = holidayMap;
        let currDateFormatted = getCurrDateInSFStr();
        this.startDate = getEligibleDate(currDateFormatted, holidayMap, results[4]);
        this.onLoadStartDate = this.startDate;
        if (results[2].empData.Type__c === this.probationerPickValBind) {
         // processProbationerOnLoad.call(this);
        }
        if (results[2].empData.Type__c === this.contractorPickValBind) {
          processContractOnLoad.call(this);
        }
        processOnLoad.call(this);
        if (this.vanillaLeaveOpts) {
          this.stripPicklist(this.vanillaLeaveOpts);
        }
        this.spinnerFlag = false;
      })
      .catch(error => {
        this.spinnerFlag = false;
        console.log('@ connectedCallback');
        this.dispatchEvent(new ShowToastEvent(getErrorBody(error)));
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        setTimeout(() => {
          window.location.href = `${window.location.origin}${window.location.pathname.split('s/')[0]}s/employee-leave/Employee_Leave__c/Default`;
        }, 3000);
      })
  }
  /**
    *
    *
    * @memberof ApplyLeave
    */
  renderedCallback() {
    this.endDateDOMToken = this.template.querySelector('lightning-input[data-type="end-date"]');
    this.startDateDOMToken = this.template.querySelector('lightning-input[data-type="start-date"]');
  }
  constructor() {
    super();
    // EMPLOYEE TYPE PICKLIST BIND
    this.permanentPickValBind = PERMANENT_PICKVAL;
    this.probationerPickValBind = PROBATIONER_PICKVAL;
    this.contractorPickValBind = CONTRACTOR_PICKVAL;
    // LEAVE TYPE PICKLIST BIND
    this.paternityPickValBind = PATERNITY_PICKVAL;
    this.maternityPickValBind = MATERNITY_PICKVAL;
    this.casualPickValBind = CASUAL_PICKVAL;
    this.restrictedPickValBind = RESTRICTED_PICKVAL;
    // this.sickPickValBind = SICK_PICKVAL;
    this.privilegePickValBind = PAID_PICKVAL;
    // ELIGIBILITY BIND
    this.privilegeEligibleBind = PAID_ELIGIBLE_CLSMEM;
    this.sickEligibleBind = SICK_ELIGIBLE_CLSMEM;
    this.casualEligibleBind = CASUAL_ELIGIBLE_CLSMEM;
    this.paternityEligibleBind = PATERNITY_ELIGIBLE_CLSMEM;
    this.maternityEligibleBind = MATERNITY_ELIGIBLE_CLSMEM;
    this.bereavementEligibleBind = BEREAVEMENT_ELIGIBLE_CLSMEM;
    this.lopEligibleBind = LOP_ELIGIBLE_CLSMEM;
    // LIMIT BIND
    this.casualLimitBind = CASUAL_LIMIT_CLSMEM;
    this.privilegeLimitBind = PAID_LIMIT_CLSMEM;
    this.sickLimitBind = SICK_LIMIT_CLSMEM;
    this.celebrationLimitBind = CELEBRATION_LIMIT_CLSMEM;
    this.lopLimitBind = LOP_LIMIT_CLSMEM;
    // CARRY BIND
    this.casualCarryBind = CASUAL_CARRY_CLSMEM;
    this.sickCarryBind = SICK_CARRY_CLSMEM;
    this.privilegeCarryBind = PRIVILEGE_CARRY_CLSMEM;
    this.celebrationCarryBind = CELEBRATION_CARRY_CLSMEM;
    // BALANCE BIND
    this.casualBalanceBind = CASUAL_BAL_CLSMEM;
    this.privilegeBalanceBind = PAID_BAL_CLSMEM;
    this.maternityBalanceBind = MATERNITY_BAL_CLSMEM;
    this.paternityBalanceBind = PATERNITY_BAL_CLSMEM;
    this.bereavementBalanceBind = BEREAVEMENT_BAL_CLSMEM;
    this.celebrationBalanceBind = CELEBRATION_BAL_CLSMEM;
    this.restrictedBalanceBind = RESTRICTED_BAL_CLSMEM;
    this.lopBalanceBind = LOP_BAL_CLSMEM;
    this.wfhBalanceBind = WFH_BAL_CLSMEM;
    // FUNCTION BIND
    this.populateData = unbindedPopulateData.bind(this);
    this.partialPopulate = unbindedPartialPopulate.bind(this);
    this.stripPicklist = adjustPicklist.bind(this);
    this.clearData = unbindedClearData.bind(this);
  }
}