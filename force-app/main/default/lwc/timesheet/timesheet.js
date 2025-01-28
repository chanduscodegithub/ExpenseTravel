import { LightningElement, wire, track } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';
 import userData from '@salesforce/apex/TimesheetController.userData';
 import Id from '@salesforce/user/Id';
import Timesheet_Restriction_Bypass__c from '@salesforce/schema/User.Timesheet_Restriction_Bypass__c';
const fields=[Timesheet_Restriction_Bypass__c];

//Apex
import getEmployee from "@salesforce/apex/TimesheetController.getEmployee";
import getTeam_Sheet from "@salesforce/apex/TimesheetController.getTeam_Sheet";
import saveTS from "@salesforce/apex/TimesheetController.saveTS";
import deleteExisting from '@salesforce/apex/TimesheetController.deleteExisting';
import prevRec from '@salesforce/apex/TimesheetController.prevRec';
import approvalStep from '@salesforce/apex/TimesheetController.approvalStep';
import getCurrentUserProfileName from '@salesforce/apex/UserController.getCurrentUserProfileName';

//For Custom Setting
import getMaxFileSize from '@salesforce/apex/TimesheetController.getCustomSettingData';
import getAccFileSettingData from '@salesforce/apex/TimesheetController.getAccFileSettingData';

//Field Values
import CATEGORY from '@salesforce/schema/Delivery__c.Category__c';
import SUB_CATEGORY from '@salesforce/schema/Delivery__c.Sub_Category__c';

import { getPicklistValues } from 'lightning/uiObjectInfoApi';

//New Way
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import DTSObject from "@salesforce/schema/Delivery__c";

//Resources and Lib
import { loadScript } from "lightning/platformResourceLoader";
import { loadStyle } from 'lightning/platformResourceLoader';
import externalCSS from '@salesforce/resourceUrl/externalCSS';
import moment from "@salesforce/resourceUrl/MomentJS";

// Extra JS
import postProcessing from "./postProcessing";
import allocationPostProcess from "./allocationPostProcess";

export default class Timesheet extends LightningElement {
    empObj;
    @track generatedAlloc;
    @track cloneInfo = { cloneDate: null, cloneDatePretty: null, initDatePretty: null, initNextDay: null, lastDay: false, lastDate: null, details: {} };
    parentTS;
    existingFileName;
    deleteRecordObj;
    totalHours = 0.00;
    activeSections = [];
    leaveHoursOpt = [{ label: 'Half Day', value: "4.00" }, { label: 'Full Day', value: "8.00" }];
    groupedAllocation_wProject;
    @track error;
    profileName
    
    //Message from Custom Metadata
    msgBelow40;
    msgAbove48;
    msgOnTime;

    //LoadFlag from Custom Metadata
    loadReportButton = false;
    loadCarouselBanner = false;

    //Dates
    todayPlaceholder = new Date().toISOString();
    momentizedStartDate;
    startDateStr;
    momentizedEndDate;
    endDateStr;
    startDayStr;
    endDayStr;

    //Approval
    approvalBoxLabel;
    approvalDescription = '';
    approvalBoxHeading = 'Comments';
    approvalBoxPlaceholder = 'Comments..'

    //Flags - Removed as per suggestions
    workaholic = false;
    tempWorkaholic;

    //Manager Flag
    managerView = false;

    //ExistingTSData
    existingTTcontinuation;

    //Schemas and Field Values
    subcategoryData;
    categoryOptions;
    subcategoryOptions;

    //Additional Flags
    spinnerFlag = true;
    isModalOpen = false;
    isCloneOpen = false;
    submittedFlag = false;
    dayPassedFlag = false;
    cloneDateCheck = true;
    confirmBox = false;
    ifBlank = false;
    isEdited = false;
    deleteConfirm = false;
    reportFlag = false;
    mandatoryMessageOnConfirm = false;
    allowApproval = false;
    showApprovalBox = false;

    //indexation
    indexation = 100;

    userId = Id;
    userBypass;
    disableline = false;
   
    @wire(getCurrentUserProfileName)
    getWiredUserData({data,error}){
        if(data){
        this.profileName=data
        console.log('The profile Name is',this.profileName);
        }else if(error){
        console.error('There is an error in fetching the profile',error);
        }
    }
  
    @wire(userData, { Ids: '$userId' })
    userDetails({ error, data }) {
        if (data) {
            if (data.Timesheet_Restriction_Bypass__c ) {
             //   console.log('wwww'+data.Timesheet_Restriction_Bypass__c);
                this.userBypass = data.Timesheet_Restriction_Bypass__c;
            }
        }else if (error) {
         //   console.log('e2'+this.error);
            this.error = error;
        //    console.log('e3'+this.error);
        } 
    } 
    


    get lockedToEdit() {
        return this.submittedFlag || this.managerView || this.dayPassedFlag;
    }
    get confirmBoxMsg() {
        // if (this.totalHours < 40) {
        //     return this.msgBelow40;
        // } else 
        if (this.totalHours >= 48) {
            return `Hey, ${this.empObj.Name}. ${this.msgAbove48}`;
        } else {
            return 'Are you sure you want to proceed?';
        }
    }
    get carouselStatus() {
        return this.loadCarouselBanner && this.empObj.Employee_Type__c == 'Internal';
    }

    @wire(getObjectInfo, { objectApiName: DTSObject })
    deliveryObjInfo;

    // To get Picklist values using 'lightning/uiObjectInfoApi' and '@salesforce/schema/___obj&FieldName__'
    @wire(getPicklistValues, { recordTypeId: "$deliveryObjInfo.data.defaultRecordTypeId", fieldApiName: CATEGORY })
    wiredFuncforPick1({ data, error }) {
        if (data) {
            this.categoryOptions = data.values;
        }
        if (error) {
            //console.log(error);
        }
    }
    @wire(getPicklistValues, { recordTypeId: "$deliveryObjInfo.data.defaultRecordTypeId", fieldApiName: SUB_CATEGORY })
    wiredFuncforPick2({ data, error }) {
        if (data) {
            this.subcategoryData = data;
            this.subcategoryOptions = data.values;
        }
        if (error) {
            //console.log(error);
        }
    }

    // @wire(getEmployee)
    // wiredFunc({ err, data }) {
    //     if (data) {
    //         if (Object.keys(data).length === 0) {
    //             this.dispatchEvent(
    //                 new ShowToastEvent({
    //                     title: 'Error!!',
    //                     message: `Please check with Manager to link your profile with employee record!`,
    //                     variant: 'error'
    //                 })
    //             );
    //             let strURL = window.location.href;
    //             let locURL = strURL.split('CRMITCommunity/s/');
    //             let backtoListTimesheet = `${locURL[0]}CRMITCommunity/s/recordlist/Team_Timesheet__c/Default`;
    //             setTimeout(() => {
    //                 window.location.href = backtoListTimesheet;
    //             }, 3000)
    //         }
    //         this.empObj = data.empUser;
    //         this.msgOnTime = data.msgOnTime;
    //         this.msgAbove48 = data.msgAbove48;
    //         this.msgBelow40 = data.msgBelow40;
    //         this.loadReportButton = data.loadReportButton == 'True' ? true : false;
    //         this.loadCarouselBanner = data.loadCarouselBanner == 'True' ? true : false;
    //         console.log(`Msg and Emp Wrapper: ${JSON.stringify(data)}`);
    //         this.spinnerFlag = false;
    //     } else if (err) {
    //         console.log(`WiredFuncError: ${err}`);
    //         this.spinnerFlag = false;
    //     }
    // }

    onDateChange(event) {
        this.todayPlaceholder = event.target.value;
    }
    changeDate() {
        this.tempWorkaholic = this.workaholic;
        if (this.isEdited) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Warning!!',
                    message: `Save the recent changes before changing the date!`,
                    variant: 'warning'
                })
            );
            this.isEdited = false;
            return;
        }
        this.isModalOpen = true;
    }
    handleWeekendWorkaholic(event) {
        this.workaholic = event.target.checked;
    }
    closeClone() {
        this.isCloneOpen = false;
    }
    handleClone(event) {
        this.cloneInfo = { cloneDate: null, cloneDatePretty: null, initDatePretty: null, initNextDay: null, lastDay: false, lastDate: null, details: {}, projectAllocKey: null }
        this.cloneInfo.cloneDate = event.currentTarget.dataset.date;
        //event.currentTarget.dataset.project
        //event.currentTarget.dataset.id
        let initDate = window.moment(this.cloneInfo.cloneDate);
        let continueFlag = false;
        if (this.momentizedEndDate.isSame(initDate, 'day')) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: `Click the “Add” button to append a new task`,
                    variant: 'error'
                })
            );
            continueFlag = true;
        }
        this.generatedAlloc.forEach(data => {
            if (data.key == event.currentTarget.dataset.project) {
                data.eachProject.forEach(eTS => {
                    if ((eTS.key == event.currentTarget.dataset.id && eTS.eachDate.cloned) || initDate.isoWeekday() == 7) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!!',
                                message: `Cloned Tasks for all days of the week already exist. Click the “Add” button to append a new task`,
                                variant: 'error'
                            })
                        );
                        continueFlag = true;
                    }
                    if (eTS.key == event.currentTarget.dataset.id && (eTS.eachDate.category == '' || eTS.eachDate.description == '' || eTS.eachDate.sub_category == '' || eTS.eachDate.work_hour == '')) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!!',
                                message: `All fields must have data before cloning!`,
                                variant: 'error'
                            })
                        );
                        continueFlag = true;
                    }
                })
            }
        })
        if (continueFlag) {
            return;
        }
        switch (initDate.isoWeekday()) {
            case 1:
                this.cloneInfo.initNextDay = initDate.add(4, 'days').format('YYYY-MM-DD');
                break;
            case 2:
                this.cloneInfo.initNextDay = initDate.add(3, 'days').format('YYYY-MM-DD');
                break;
            case 3:
                this.cloneInfo.initNextDay = initDate.add(2, 'days').format('YYYY-MM-DD');
                break;
            case 4:
                this.cloneInfo.initNextDay = initDate.add(1, 'days').format('YYYY-MM-DD');
                break;
            case 5:
                this.cloneInfo.initNextDay = initDate.add(2, 'days').format('YYYY-MM-DD');
                break;
            case 6:
                this.cloneInfo.initNextDay = initDate.add(1, 'days').format('YYYY-MM-DD');
                this.cloneInfo.lastDay = true;
                break;
            case 7:
                this.cloneInfo.initNextDay = initDate.format('YYYY-MM-DD');
                this.cloneInfo.lastDay = true;
                break;
        }
        while (initDate.isAfter(this.momentizedEndDate)) {
            this.cloneInfo.initNextDay = initDate.subtract(1, 'days').format('YYYY-MM-DD');
            this.cloneInfo.lastDay = true;
        }
        this.generatedAlloc.forEach(data => {
            if (data.key == event.currentTarget.dataset.project) {
                this.cloneInfo.projectAllocKey = event.currentTarget.dataset.project;
                data.eachProject.forEach(eachTS => {
                    if (eachTS.key == event.currentTarget.dataset.id) {
                        this.cloneInfo.details = eachTS.eachDate;
                    }
                });
            }
        });
        let StartPrettyMoment = window.moment(this.cloneInfo.cloneDate);
        let textStr = StartPrettyMoment.toString().split(' ');
        this.cloneInfo.cloneDatePretty = textStr[0] + ', ' + ' ' + textStr[2] + ' ' + textStr[1] + ' ' + textStr[3];
        textStr = initDate.toString().split(' ');
        this.cloneInfo.initDatePretty = textStr[0] + ', ' + ' ' + textStr[2] + ' ' + textStr[1] + ' ' + textStr[3];
        this.isCloneOpen = true;
    }
    getDayinText(weekdayNum, full) {
        switch (weekdayNum) {
            case 1:
                return full ? 'Monday' : 'Mon';
            case 2:
                return full ? 'Tuesday' : 'Tue';
            case 3:
                return full ? 'Wednesday' : 'Wed';
            case 4:
                return full ? 'Thursday' : 'Thurs';
            case 5:
                return full ? 'Friday' : 'Fri';
            case 6:
                return full ? 'Saturday' : 'Sat';
            case 7:
                return full ? 'Sunday' : 'Sun';
        }
    }
    onCloneDateChange(event) {
        let selectedDateStr = event.target.value;
        let selectedDate = window.moment(selectedDateStr);
        let cloningFromDate = window.moment(this.cloneInfo.cloneDate);
        if (selectedDate.isAfter(cloningFromDate) && this.momentizedEndDate.isAfter(selectedDate)) {
            this.cloneDateCheck = true;
            this.cloneInfo.lastDate = selectedDateStr;
        } else {
            this.cloneDateCheck = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: `Date should be after ${this.cloneInfo.cloneDate} and before ${this.momentizedEndDate.format('DD-MM-YYYY')}.`,
                    variant: 'error'
                })
            );
        }
    }
    processClone() {
        if (this.cloneDateCheck) {
            this.spinnerFlag = true;
            let currDate = window.moment(this.cloneInfo.cloneDate);
            let lastDate = this.cloneInfo.lastDate ? window.moment(this.cloneInfo.lastDate) : window.moment(this.cloneInfo.initNextDay);
            if (currDate.isoWeekday() != 7) {
                do {
                    //console.log(`Pushing Values in Date> ${currDate.toString()}`);
                    let existFlag = true;
                    this.generatedAlloc.forEach(data => {
                        if (data.key == this.cloneInfo.projectAllocKey) {
                            data.eachProject.forEach(eachTS => {
                                if (eachTS.eachDate.date == currDate.format('YYYY-MM-DD') && (eachTS.eachDate.category == this.cloneInfo.details.category && eachTS.eachDate.sub_category == this.cloneInfo.details.sub_category)) {
                                    existFlag = false;
                                    if (eachTS.eachDate.category == '' && eachTS.eachDate.description == '' && eachTS.eachDate.sub_category == '' && eachTS.eachDate.work_hour == '') {
                                        eachTS.eachDate.category = this.cloneInfo.details.category;
                                        eachTS.eachDate.description = this.cloneInfo.details.description;
                                        eachTS.eachDate.sub_category = this.cloneInfo.details.sub_category;
                                        eachTS.eachDate.work_hour = this.cloneInfo.details.work_hour;
                                        eachTS.eachDate.catOptions = this.cloneInfo.details.catOptions;
                                        eachTS.eachDate.subcatOptions = this.cloneInfo.details.subcatOptions;
                                        eachTS.eachDate.leaveField = this.cloneInfo.details.leaveField;
                                        eachTS.eachDate.dayStr = currDate.format('ddd');
                                    }
                                    eachTS.eachDate.cloned = lastDate.isSame(currDate, 'day') ? false : true;
                                }
                                return eachTS;
                            });
                            return data;
                        }
                    });
                    if (existFlag) {
                        let newObj = {
                            key: this.indexation,
                            eachDate: {
                                project: this.cloneInfo.details.project,
                                projectId: this.cloneInfo.details.projectId,
                                projectAllocId: this.cloneInfo.details.projectAllocId,
                                region: this.cloneInfo.details.region,
                                reportingManager: this.cloneInfo.details.reportingManager,
                                billingStatus: this.cloneInfo.details.billingStatus,
                                date: currDate.format('YYYY-MM-DD'),
                                category: this.cloneInfo.details.category,
                                sub_category: this.cloneInfo.details.sub_category,
                                work_hour: this.cloneInfo.details.work_hour,
                                description: this.cloneInfo.details.description,
                                taStart: this.cloneInfo.details.taStart,
                                taEnd: this.cloneInfo.details.taEnd,
                                existing: false,
                                catOptions: this.cloneInfo.details.catOptions,
                                subcatOptions: this.cloneInfo.details.subcatOptions,
                                leaveField: this.cloneInfo.details.leaveField,
                                cloned: lastDate.isSame(currDate, 'day') ? false : true,
                                projectLabel: this.cloneInfo.details.projectLabel,
                                dayStr: currDate.format('ddd')
                            }
                        }
                        if (this.cloneInfo.details.groupedAllocation) {
                            newObj.eachDate.groupedAllocation = true;
                            newObj.eachDate.groupedAllocationDates = this.cloneInfo.details.groupedAllocationDates;
                        }
                        this.generatedAlloc.forEach(data => {
                            if (data.key == this.cloneInfo.projectAllocKey) {
                                data.eachProject.push(newObj);
                            }
                            return data;
                        });
                        this.indexation += 10;
                    }
                    currDate.add(1, 'days');
                } while (lastDate.isAfter(currDate) || lastDate.isSame(currDate, 'day'));
            } else {
                let newObj = {
                    key: this.indexation,
                    eachDate: {
                        project: this.cloneInfo.details.project,
                        projectId: this.cloneInfo.details.projectId,
                        projectAllocId: this.cloneInfo.details.projectAllocId,
                        region: this.cloneInfo.details.region,
                        reportingManager: this.cloneInfo.details.reportingManager,
                        billingStatus: this.cloneInfo.details.billingStatus,
                        date: currDate.format('YYYY-MM-DD'),
                        category: this.cloneInfo.details.category,
                        sub_category: this.cloneInfo.details.sub_category,
                        work_hour: this.cloneInfo.details.work_hour,
                        description: this.cloneInfo.details.description,
                        taEnd: this.cloneInfo.details.taEnd,
                        taStart: this.cloneInfo.details.taStart,
                        existing: false,
                        catOptions: this.cloneInfo.details.catOptions,
                        subcatOptions: this.cloneInfo.details.subcatOptions,
                        leaveField: this.cloneInfo.details.leaveField,
                        cloned: true,
                        projectLabel: this.cloneInfo.details.projectLabel,
                        dayStr: currDate.format('ddd'),
                    }
                }
                if (this.cloneInfo.details.groupedAllocation) {
                    newObj.eachDate.groupedAllocation = true;
                    newObj.eachDate.groupedAllocationDates = this.cloneInfo.details.groupedAllocationDates;
                }
                this.generatedAlloc.forEach(data => {
                    if (data.key == this.cloneInfo.projectAllocKey) {
                        data.eachProject.push(newObj);
                    }
                    return data;
                });
                this.indexation += 10;
            }
            //console.log(`Updated Object: ${JSON.stringify(this.generatedAlloc)}`);
            this.spinnerFlag = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!!',
                    message: 'Cloned',
                    variant: 'success'
                })
            );
            this.isCloneOpen = false;
            this.isEdited = true;
            this.cloneInfo = { cloneDate: null, cloneDatePretty: null, initDatePretty: null, initNextDay: null, lastDay: false, lastDate: null, details: {}, projectAllocKey: null }
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Date not in range!',
                    variant: 'error'
                })
            );
        }
        this.calculateTotalHours();
        this.calculateTotalHoursforProject();
        this.sortGeneratedObj();
    }
    submitStartDate(event, startDateStr) {
        this.generatedAlloc = [];
        this.parentTS = null;
        this.spinnerFlag = true;
        let today = window.moment(new Date());
        // Check for last 2 weeks
        let last2Week = window.moment(today.format('YYYY-MM-DD'));
        //console.log(`Start Date Str Passed: ${startDateStr}`);
        let startDate;
        if (startDateStr == undefined) {
            //console.log('DID NOT RECEIVE ANY START DATE');
            startDate = window.moment(this.todayPlaceholder);
        } else {
            startDate = window.moment(startDateStr);
            //console.log(`RECEIVED START DATE: ${startDate.toString()}`);
        }
        if (startDate.isAfter(today)) {
            this.spinnerFlag = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'You cannot select future dates for week start!',
                    variant: 'error'
                })
            );
            return this.changeDate();
        }
        if (startDate.isoWeekday() != 1) {
            // Removed as per suggestion
            /*this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Warning!!',
                    message: 'Start date changed to last date which was Monday!',
                    variant: 'warning'
                })
            )*/
            startDate.startOf('isoWeek');
        }
        //console.log(`Current Day: ${last2Week.toString()}`);
       if(this.userBypass == true)
         {
            last2Week = window.moment('2022-03-28');
         } else{
        if (last2Week.isoWeekday() == 7) {
            last2Week.subtract(1, 'weeks').startOf('isoWeek');
        } else {
            last2Week.subtract(1, 'weeks').startOf('isoWeek');
        }
        }
   

        console.log(this.existingTTcontinuation);
        console.log(typeof this.existingTTcontinuation);

        //console.log(`Last 2 Week: ${last2Week.toString()}`);
        //console.log(`Selected Start Day: ${startDate.toString()}`);

       //  last2Week = window.moment('2022-03-28');
        //last2Week.subtract(2, 'months').startOf('isoWeek');
        if (!this.managerView && typeof this.existingTTcontinuation === 'undefined') {
            if (last2Week.isAfter(startDate)) {
                this.spinnerFlag = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: 'You can only fill the timesheet for previous and current week!',
                        variant: 'error'
                    })
                );
                return this.changeDate();
            }
        } else if (!this.managerView && typeof this.existingTTcontinuation === 'object') {
            if (last2Week.isAfter(startDate)) {
                this.dayPassedFlag = true;
            } else {
                this.dayPassedFlag = false;
            }
        } else {
            this.dayPassedFlag = false;
        }

        this.momentizedStartDate = startDate;
        this.startDateStr = startDate.format("DD-MMM-YYYY");
        let endDate = window.moment(startDate.toString()).add(6, 'days');
        this.recurseDate(endDate, today);
        this.momentizedEndDate = endDate.endOf('day');
        this.endDateStr = endDate.format("DD-MMM-YYYY");
        this.startDayStr = this.getDayinText(this.momentizedStartDate.isoWeekday());
        this.endDayStr = this.getDayinText(this.momentizedEndDate.isoWeekday());
        this.isModalOpen = false;
        this.getTeamAndTimeSheet(startDate.format("YYYY-MM-DD"), endDate.format("YYYY-MM-DD"));
    }
    recurseDate(endDate, today) {
        if (endDate.isAfter(today)) {
            endDate.subtract(1, 'days');
            this.recurseDate(endDate, today);
        }
    }
    getTeamAndTimeSheet(startString, endString) {
        this.spinnerFlag = true;
        getTeam_Sheet({ empId: this.empObj.Id, startString, endString }).then(data => {
            this.submittedFlag = data.submitted;
            this.parentTS = data.parentTS ? data.parentTS : null;
            this.existingFileName = data.existingFileName;//Existing File Name
            //console.log(`Parent TS: ${this.parentTS}`);
            this.generateObject(data.TeamAllocList, data.allTS);
        }).catch(err => {
            console.log(`generateTimeSheetError:`);
            console.log(err)
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: `Ooops! Looks like we have a problem saving your entries now. Please feel free to report the issue using the 'Error Logging Timesheet?' link on the bottom left on the timesheet entry page.`,
                    variant: 'error'
                })
            );
            this.spinnerFlag = false;
        });
    }
    generateObject(allTeamAllocations, existingTimeSheets) {
        //console.log('All TAs Pre-Processing', JSON.stringify(allTeamAllocations));
        //console.log('All Existing TS Pre-Processing', JSON.stringify(existingTimeSheets));
        const generatedTimeSheet = new Map(); // Map of Project Id (key) and list of generated TS
        const allocationForSameProject = new Map();
        let i = 10000000000;
        allTeamAllocations.forEach(eachAllocation => {
            //console.log('New Alloc: ', eachAllocation.Project__r.Name);
            let currDay = window.moment(this.momentizedStartDate.toISOString());
            let projectTimeSheet = [];
            let rec1Only = true; // Added after new changes asked
            while (this.momentizedEndDate.isAfter(currDay)) {
                //console.log(`Current Date: ${currDay.toString()}`);
                let DateMap = new Map();
                existingTimeSheets.forEach(existingTS => {
                    //console.log(`Existing: ${existingTS.Date__c}, ${existingTS.Customer_Engagement__c}`);
                    //console.log(`Date Str: ${currDay.format('YYYY-MM-DD')} and currAlloc: ${eachAllocation.Project__c}`);
                    console.log('existingTS.Timesheet_Approval__r.Approval_Status__c>>'+existingTS.Timesheet_Approval__r.Approval_Status__c);
                    if(existingTS.Timesheet_Approval__r.Approval_Status__c !=null && (existingTS.Timesheet_Approval__r.Approval_Status__c == 'Rejected' || existingTS.Timesheet_Approval__r.Approval_Status__c == 'Draft')){
                        this.disableline=false;
                    }
                    else if(existingTS.Timesheet_Approval__r.Approval_Status__c !=null && (existingTS.Timesheet_Approval__r.Approval_Status__c == 'Approved' || existingTS.Timesheet_Approval__r.Approval_Status__c == 'Submitted')){
                        this.disableline=true;
                    }
                console.log('this.disableline>>>'+this.disableline);
                    let key = this.subcategoryData.controllerValues[existingTS.Category__c];
                    let localSubcat = this.subcategoryData.values.filter(option => option.validFor.includes(key));
                    let localCat = this.categoryOptions;
                    if (eachAllocation.Project__r.Name == 'Others') {
                        localCat = this.categoryOptions.filter(eachOp => {
                            return (eachOp.value == 'Leave' || eachOp.value == 'Enablement' || eachOp.value == 'PreSales Support' || eachOp.value == 'Meetings' || eachOp.value == 'COE' || eachOp.value == 'Takshashila' || eachOp.value == 'Interviews' || eachOp.value == 'POCs' || eachOp.value == 'CRMIT Holiday')
                        });
                    } else {
                        localCat = this.categoryOptions.filter(eachOp => {
                            return (eachOp.value != 'Leave' && eachOp.value != 'Enablement' && eachOp.value != 'PreSales Support' && eachOp.value != 'COE' && eachOp.value != 'Takshashila' && eachOp.value != 'POCs' && eachOp.value != 'CRMIT Holiday')
                        });
                    }
                    if (currDay.format('YYYY-MM-DD') == existingTS.Date__c && existingTS.Team_Allocation__c == eachAllocation.Id) {
                        if (DateMap.has(existingTS.Date__c)) {
                            let existingArr = DateMap.get(existingTS.Date__c);
                            let TSObject = {
                                tsId: existingTS.Id,
                                tsName: existingTS.Name,
                                project: eachAllocation.Project__r.Name,
                                projectId: eachAllocation.Project__c,
                                projectAllocId: eachAllocation.Id,
                                region: eachAllocation.Region__c,
                                reportingManager: eachAllocation.ReportingTo__r.Name,
                                billingStatus: eachAllocation.Billing_Status__c,
                                date: existingTS.Date__c,
                                allocPercentage: eachAllocation.AllocationPercentage__c,
                                category: existingTS.Category__c,
                                sub_category: existingTS.Sub_Category__c,
                                work_hour: existingTS.Category__c == 'Leave' ? parseFloat(existingTS.Time_in_Hours__c).toPrecision(3).toString() : existingTS.Time_in_Hours__c,
                                description: existingTS.Description__c,
                                taEnd: eachAllocation.EndDate__c,
                                taStart: eachAllocation.StartDate__c,
                                existing: true,
                                catOptions: localCat,
                                subcatOptions: localSubcat,
                                cloned: false,
                                leaveField: existingTS.Category__c == 'Leave' ? true : false,
                                projectLabel: eachAllocation.Project__r.Name,
                                disableline:this.disableline,
                                dayStr: currDay.format('ddd')
                            };
                            existingArr.push(TSObject);
                            DateMap.set(existingTS.Date__c, existingArr);
                        } else {
                            let TSObject = {
                                tsId: existingTS.Id,
                                tsName: existingTS.Name,
                                project: eachAllocation.Project__r.Name,
                                projectId: eachAllocation.Project__c,
                                projectAllocId: eachAllocation.Id,
                                region: eachAllocation.Region__c,
                                reportingManager: eachAllocation.ReportingTo__r.Name,
                                billingStatus: eachAllocation.Billing_Status__c,
                                date: existingTS.Date__c,
                                allocPercentage: eachAllocation.AllocationPercentage__c,
                                category: existingTS.Category__c,
                                sub_category: existingTS.Sub_Category__c,
                                work_hour: existingTS.Category__c == 'Leave' ? parseFloat(existingTS.Time_in_Hours__c).toPrecision(3).toString() : existingTS.Time_in_Hours__c,
                                description: existingTS.Description__c,
                                taEnd: eachAllocation.EndDate__c,
                                taStart: eachAllocation.StartDate__c,
                                existing: true,
                                catOptions: localCat,
                                subcatOptions: localSubcat,
                                cloned: false,
                                leaveField: existingTS.Category__c == 'Leave' ? true : false,
                                projectLabel: eachAllocation.Project__r.Name,
                                disableline:this.disableline,
                                dayStr: currDay.format('ddd')
                            };
                            let arr = [];
                            arr.push(TSObject);
                            DateMap.set(currDay.format('YYYY-MM-DD'), arr);
                        }
                        rec1Only = false;
                    }
                });
                //console.log(`Weekday: ${currDay.toString()} and WeekNumber: ${currDay.isoWeekday()}`)
                if (!DateMap.has(currDay.format('YYYY-MM-DD')) && (!this.submittedFlag)) {
                    if (currDay.isoWeekday() != 6 && currDay.isoWeekday() != 7 && rec1Only) {
                        let localCat = this.categoryOptions;
                        let localSubcat = this.subcategoryOptions;
                        if (eachAllocation.Project__r.Name == 'Others') {
                            localCat = this.categoryOptions.filter(eachOp => {
                                return (eachOp.value == 'Leave' || eachOp.value == 'Enablement' || eachOp.value == 'PreSales Support' || eachOp.value == 'Meetings' || eachOp.value == 'COE' || eachOp.value == 'Takshashila' || eachOp.value == 'Interviews' || eachOp.value == 'POCs' || eachOp.value == 'CRMIT Holiday')
                            });
                        } else {
                            localCat = this.categoryOptions.filter(eachOp => {
                                return (eachOp.value != 'Leave' && eachOp.value != 'Enablement' && eachOp.value != 'PreSales Support' && eachOp.value != 'COE' && eachOp.value != 'Takshashila' && eachOp.value != 'POCs' && eachOp.value != 'CRMIT Holiday')
                            });
                        }
                        let TSObject = {
                            project: eachAllocation.Project__r.Name,
                            projectId: eachAllocation.Project__c,
                            projectAllocId: eachAllocation.Id,
                            region: eachAllocation.Region__c,
                            reportingManager: eachAllocation.ReportingTo__r.Name,
                            billingStatus: eachAllocation.Billing_Status__c,
                            date: currDay.format('YYYY-MM-DD'),
                            allocPercentage: eachAllocation.AllocationPercentage__c,
                            category: '',
                            sub_category: '',
                            work_hour: '',
                            description: '',
                            taEnd: eachAllocation.EndDate__c,
                            taStart: eachAllocation.StartDate__c,
                            existing: false,
                            catOptions: localCat,
                            subcatOptions: localSubcat,
                            cloned: false,
                            leaveField: false,
                            projectLabel: eachAllocation.Project__r.Name,
                            disableline:false,
                            dayStr: currDay.format('ddd')
                        };
                        let arr = [];
                        arr.push(TSObject);
                        DateMap.set(currDay.format('YYYY-MM-DD'), arr);
                        rec1Only = false;
                    }
                    // Removed as per suggestion
                    else if (this.workaholic) {
                        let localCat = this.categoryOptions;
                        let localSubcat = this.subcategoryOptions;
                        if (eachAllocation.Project__r.Name == 'Leave') {
                            localCat = this.categoryOptions.filter(eachOp => {
                                return (eachOp.value == 'Leave' || eachOp.value == 'Enablement' || eachOp.value == 'PreSales Support' || eachOp.value == 'Meetings' || eachOp.value == 'COE' || eachOp.value == 'Takshashila' || eachOp.value == 'Interviews' || eachOp.value == 'POCs' || eachOp.value == 'CRMIT Holiday')
                            });
                        } else {
                            localCat = this.categoryOptions.filter(eachOp => {
                                return (eachOp.value != 'Leave' && eachOp.value != 'Enablement' && eachOp.value != 'PreSales Support' && eachOp.value != 'COE' && eachOp.value != 'Takshashila' && eachOp.value != 'POCs' && eachOp.value != 'CRMIT Holiday')
                            });
                        }
                        let TSObject = {
                            project: eachAllocation.Project__r.Name,
                            projectId: eachAllocation.Project__c,
                            projectAllocId: eachAllocation.Id,
                            region: eachAllocation.Region__c,
                            reportingManager: eachAllocation.ReportingTo__r.Name,
                            billingStatus: eachAllocation.Billing_Status__c,
                            date: currDay.format('YYYY-MM-DD'),
                            allocPercentage: eachAllocation.AllocationPercentage__c,
                            category: '',
                            sub_category: '',
                            work_hour: '',
                            description: '',
                            taEnd: eachAllocation.EndDate__c,
                            taStart: eachAllocation.StartDate__c,
                            existing: false,
                            catOptions: localCat,
                            subcatOptions: localSubcat,
                            cloned: false,
                            leaveField: false,
                            projectLabel: eachAllocation.Project__r.Name,
                            dayStr: currDay.format('ddd')
                        };
                        let arr = [];
                        arr.push(TSObject);
                        DateMap.set(currDay.format('YYYY-MM-DD'), arr);
                    }
                }
                currDay.add(1, 'days');
                //console.log('Each Day Allocation', Object.fromEntries(DateMap));
                //console.log(Array.from(DateMap.values()));
                for (let [key, value] of DateMap.entries()) {
                    value.forEach(eachTS => {
                        projectTimeSheet.push({ key: i++, eachDate: eachTS });
                    });
                }
            }
            console.log('Extract PID and AID from ProjectTimeSheet-787', JSON.stringify(projectTimeSheet));
            if (projectTimeSheet.length) {
                generatedTimeSheet.set(eachAllocation.Id, projectTimeSheet);
                if (allocationForSameProject.has(projectTimeSheet[0].eachDate.projectId)) {
                    let allocList = allocationForSameProject.get(projectTimeSheet[0].eachDate.projectId);
                    allocList.push(projectTimeSheet[0].eachDate.projectAllocId);
                } else {
                    let allocList = [projectTimeSheet[0].eachDate.projectAllocId];
                    allocationForSameProject.set(projectTimeSheet[0].eachDate.projectId, allocList);
                }
            }
        });
        this.groupedAllocation_wProject = allocationForSameProject;
        console.log('800'+Object.fromEntries(generatedTimeSheet));
        //console.log(Array.from(generatedTimeSheet.values()));
        let otherObj = {};
        for (let [key, value] of generatedTimeSheet.entries()) {
            let generateObj = {
                key, projectName: value[0].eachDate.project, manager: value[0].eachDate.reportingManager, region: value[0].eachDate.region, status: value[0].eachDate.billingStatus, allocCent: value[0].eachDate.allocPercentage, eachProject: value, projectLabel: value[0].eachDate.projectLabel,disablebtn: !value[0].eachDate.disableline && value[1] != undefined ? value[1].eachDate.disableline :value[0].eachDate.disableline
            }
            if (value[0].eachDate.project == 'Others') {
                generateObj.otherAlloc = true
                otherObj = generateObj;
            } else {
                generateObj.otherAlloc = false;
                generateObj.fileName = '';
                generateObj.filedata = '';
                this.generatedAlloc.push(generateObj);
                console.log('813>'+JSON.stringify(this.generatedAlloc));
            }
        }
        if (Object.keys(otherObj).length) {
            this.generatedAlloc.push(otherObj);
            console.log('818>'+JSON.stringify(this.generatedAlloc));
        }
        //this.generatedAlloc = Array.from(generatedTimeSheet.values());
        //console.log(`Generated Timesheet Object`);
        //console.log(JSON.stringify(this.generatedAlloc));
        if (this.generatedAlloc.length === 0) {
            this.ifBlank = true;
        } else {
            this.ifBlank = false;
        }

        postProcessing(this.generatedAlloc, this.groupedAllocation_wProject)
            .then((data) => {
                console.log(`Generated Timesheet Object`);
                console.log(JSON.stringify(data));
                this.generatedAlloc = data;
                this.adjustCloneFlagforGeneratedObj();
                this.calculateTotalHours();
                this.calculateTotalHoursforProject();
                this.generatedAlloc.sort((curr, prev) => {
                    if (curr.projectName < prev.projectName) {
                        return -1;
                    }
                    if (curr.projectName > prev.projectName) {
                        return 1;
                    }
                    return 0;
                })
                this.generatedAlloc.sort((curr, prev) => {
                    return curr.otherAlloc ? 1 : 0;
                })
                this.spinnerFlag = false
            })
            .catch(err => {
                console.log('Post Processing Error', err)
                this.spinnerFlag = false
            })
    }
    handleAdd(event) {
        this.spinnerFlag = true;
        let uid = event.currentTarget.dataset.id;
        let projectId = event.currentTarget.dataset.project;
        this.generatedAlloc.forEach(data => {
            if (data.key == projectId) {
                data.eachProject.forEach((eachTS, indx, arr) => {
                    if (eachTS.key == uid) {
                        let localCat = this.categoryOptions;
                        if (eachTS.eachDate.project == 'Others') {
                            localCat = this.categoryOptions.filter(eachOp => {
                                return (eachOp.value == 'Leave' || eachOp.value == 'Enablement' || eachOp.value == 'PreSales Support' || eachOp.value == 'Meetings' || eachOp.value == 'COE' || eachOp.value == 'Takshashila' || eachOp.value == 'Interviews' || eachOp.value == 'POCs' || eachOp.value == 'CRMIT Holiday')
                            });
                        } else {
                            localCat = this.categoryOptions.filter(eachOp => {
                                return (eachOp.value != 'Leave' && eachOp.value != 'Enablement' && eachOp.value != 'PreSales Support' && eachOp.value != 'COE' && eachOp.value != 'Takshashila' && eachOp.value != 'POCs' && eachOp.value != 'CRMIT Holiday')
                            });
                        }
                        let newObj = {
                            key: uid + this.indexation,
                            eachDate: {
                                project: eachTS.eachDate.project,
                                projectId: eachTS.eachDate.projectId,
                                region: eachTS.eachDate.region,
                                projectAllocId: eachTS.eachDate.projectAllocId,
                                reportingManager: eachTS.eachDate.reportingManager,
                                billingStatus: eachTS.eachDate.billingStatus,
                                date: eachTS.eachDate.date,
                                category: '',
                                sub_category: '',
                                work_hour: '',
                                description: '',
                                taEnd: eachTS.eachDate.taEnd,
                                taStart: eachTS.eachDate.taStart,
                                existing: false,
                                catOptions: localCat,
                                subcatOptions: this.subcategoryOptions,
                                //cloned: eachTS.eachDate.cloned
                                cloned: false,
                                leaveField: false,
                                projectLabel: eachTS.eachDate.projectLabel,
                                //disableline:this.disableline,
                                dayStr: window.moment(eachTS.eachDate.date).format('ddd')
                            }
                        }
                        if (eachTS.eachDate.groupedAllocation) {
                            newObj.eachDate.groupedAllocation = true;
                            newObj.eachDate.groupedAllocationDates = eachTS.eachDate.groupedAllocationDates;
                        }
                        arr.splice(indx + 1, 0, newObj)
                    }
                    return eachTS;
                });
            }
            return data;
        });
        this.indexation += 10;
        this.spinnerFlag = false;
    }
    async handleSubtract(event) {
        this.spinnerFlag = true;
        let directDeleteFlag = true;
        let uid = event.currentTarget.dataset.id;
        let projectId = event.currentTarget.dataset.project;
        let cDate = event.currentTarget.dataset.date;
        let cloneDate = window.moment(cDate);
        let singleItemLeft = false;
        this.generatedAlloc.forEach(data => {
            if (data.key == projectId) {
                if (data.eachProject.length == 1) {
                    singleItemLeft = true;
                }
                data.eachProject.forEach(eTS => {
                    if (eTS.key == uid) {
                        if (eTS.eachDate.existing) {
                            this.deleteRecordObj = { cloneDate, projectId, uid, tsId: eTS.eachDate.tsId, singleItemLeft, entireObj: eTS.eachDate };
                            directDeleteFlag = false;
                            this.deleteConfirm = true;
                        } else if (singleItemLeft) {
                            eTS.eachDate.category = '';
                            eTS.eachDate.sub_category = '';
                            eTS.eachDate.work_hour = '';
                            eTS.eachDate.description = '';
                            eTS.eachDate.date = this.momentizedStartDate.format('YYYY-MM-DD');
                            eTS.eachDate.cloned = false;
                            eTS.eachDate.leaveField = false;
                            eTS.eachDate.dayStr = this.momentizedStartDate.format('ddd');
                        }
                    }
                })
            }
        });
        try {
            if (directDeleteFlag && (!singleItemLeft)) {
                await this.removeDeleted(cloneDate, projectId, uid);
            }
            await this.adjustCloneFlag();
        } catch (error) {
            //console.log(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: `Ooops! Looks like we have a problem saving your entries now. Please feel free to report the issue using the 'Error Logging Timesheet?' link on the bottom left on the timesheet entry page.`,
                    variant: 'error'
                })
            );
            this.spinnerFlag = false;
        }
        this.calculateTotalHoursforProject();
        this.calculateTotalHours();
        this.sortGeneratedObj();
        this.spinnerFlag = false;
    }
    // Make last item always ready for clone
    async adjustCloneFlag() {
        return new Promise(resolve => {
            this.generatedAlloc.forEach(data => {
                let len = data.eachProject.length;
                data.eachProject.forEach((eTS, idx) => {
                    if ((len - 1) == idx) {
                        eTS.eachDate.cloned = false;
                    }
                    return eTS;
                })
                return data;
            });
            resolve();
        })
    }
    // Make last item always ready for clone
    async adjustCloneFlagforGeneratedObj() {
        return new Promise(resolve => {
            this.generatedAlloc.forEach(data => {
                let len = data.eachProject.length;
                data.eachProject.forEach((eTS, idx) => {
                    if ((len - 1) == idx) {
                        eTS.eachDate.cloned = false;
                    } else {
                        eTS.eachDate.cloned = true;
                    }
                    return eTS;
                })
                return data;
            });
            resolve();
        })
    }
    async removeDeleted(cloneDate, projectId, uid) {
        return new Promise(resolve => {
            //console.log(`Clone Date: ${cloneDate.isoWeekday()}`);
            this.generatedAlloc.forEach(data => {
                if (data.key == projectId) {
                    data.eachProject = data.eachProject.filter(eachTS => eachTS.key != uid);
                }
                return data;
            });
            this.calculateTotalHoursforProject();
            this.calculateTotalHours();
            this.sortGeneratedObj();
            resolve();
        })
    }
    async confirmDelete() {
        this.spinnerFlag = true;
        deleteExisting({ TSId: this.deleteRecordObj.tsId })
            .then(data => {
                //console.log(`Last Deleted?`);
                //console.log(data)
                if (data) {
                    this.parentTS = null;
                }
                return this.removeDeleted(this.deleteRecordObj.cloneDate, this.deleteRecordObj.projectId, this.deleteRecordObj.uid)
            })
            .then(data => {
                if (this.deleteRecordObj.singleItemLeft) {
                    //console.log(this.deleteRecordObj.entireObj);
                    let localCat = this.categoryOptions;
                    if (this.deleteRecordObj.entireObj.project == 'Others') {
                        localCat = this.categoryOptions.filter(eachOp => {
                            return (eachOp.value == 'Leave' || eachOp.value == 'Enablement' || eachOp.value == 'PreSales Support' || eachOp.value == 'Meetings' || eachOp.value == 'COE' || eachOp.value == 'Takshashila' || eachOp.value == 'Interviews' || eachOp.value == 'POCs' || eachOp.value == 'CRMIT Holiday')
                        });
                    } else {
                        localCat = this.categoryOptions.filter(eachOp => {
                            return (eachOp.value != 'Leave' && eachOp.value != 'Enablement' && eachOp.value != 'PreSales Support' && eachOp.value != 'COE' && eachOp.value != 'Takshashila' && eachOp.value != 'POCs' && eachOp.value != 'CRMIT Holiday')
                        });
                    }
                    let newObj = {
                        key: this.indexation,
                        eachDate: {
                            project: this.deleteRecordObj.entireObj.project,
                            projectId: this.deleteRecordObj.entireObj.projectId,
                            region: this.deleteRecordObj.entireObj.region,
                            projectAllocId: this.deleteRecordObj.entireObj.projectAllocId,
                            reportingManager: this.deleteRecordObj.entireObj.reportingManager,
                            billingStatus: this.deleteRecordObj.entireObj.billingStatus,
                            date: this.momentizedStartDate.format('YYYY-MM-DD'),
                            category: '',
                            sub_category: '',
                            work_hour: '',
                            description: '',
                            taEnd: this.deleteRecordObj.entireObj.taEnd,
                            taStart: this.deleteRecordObj.entireObj.taStart,
                            existing: false,
                            catOptions: localCat,
                            subcatOptions: this.subcategoryOptions,
                            cloned: false,
                            leaveField: false,
                            projectLabel: this.deleteRecordObj.entireObj.projectLabel,
                            disableline:this.disableline,
                            dayStr: this.momentizedStartDate.format('ddd')
                        }
                    }
                    if (this.deleteRecordObj.entireObj.groupedAllocation) {
                        newObj.eachDate.groupedAllocation = true;
                        newObj.eachDate.groupedAllocationDates = this.deleteRecordObj.entireObj.groupedAllocationDates;
                    }
                    this.generatedAlloc.forEach(data => {
                        if (data.key == this.deleteRecordObj.projectId) {
                            data.eachProject.push(newObj);
                        }
                        return data;
                    })
                    this.indexation += 10;
                    this.sortGeneratedObj();
                }
                this.adjustCloneFlag();
                this.deleteRecordObj = null;
                this.spinnerFlag = false;
            })
            .catch(err => {
                //console.log(err);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: `Ooops! Looks like we have a problem saving your entries now. Please feel free to report the issue using the 'Error Logging Timesheet?' link on the bottom left on the timesheet entry page.`,
                        variant: 'error'
                    })
                );
                this.spinnerFlag = false;
            });
        this.deleteConfirm = false;
    }
    handleInput(event) {
        this.spinnerFlag = true;
        if (!this.submittedFlag) {
            let projectId = event.currentTarget.dataset.project;
            let uid = event.currentTarget.dataset.id;
            let propName = event.currentTarget.dataset.infofor;
            let value = event.target.value;
            this.generatedAlloc.forEach(data => {
                if (data.key == projectId) {
                    data.eachProject.forEach(eachTS => {
                        if (eachTS.key == uid) {
                            this.isEdited = true;
                            if (propName == 'date') {
                                let originalDate = JSON.parse(JSON.stringify(eachTS.eachDate.date));
                                let selectedDate = window.moment(value);
                                if (selectedDate.isAfter(this.momentizedEndDate) || this.momentizedStartDate.isAfter(selectedDate)) {
                                    let currPos = window.scrollY;
                                    setTimeout(() => {
                                        this.adjustingDate(projectId, uid, originalDate, currPos);
                                    }, 100);
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Error!!',
                                            message: `Selected Date ${selectedDate.format('DD-MMM-YYYY')} not in current week range.`,
                                            variant: 'error'
                                        })
                                    );
                                } else {
                                    eachTS.eachDate.date = value;
                                    eachTS.eachDate.dayStr = window.moment(value).format('ddd');
                                }
                            } else if (propName == 'category') {
                                /*if (eachTS.eachDate.category == 'Leave' && value != 'Leave') {
                                    eachTS.eachDate.description = '';
                                    eachTS.eachDate.work_hour = null;
                                    this.generatedAlloc.forEach(data => {
                                        if (data.key != projectId) {
                                            data.eachProject.forEach(eTS => {
                                                if (eTS.eachDate.date == eachTS.eachDate.date) {
                                                    eachTS.eachDate.description = '';
                                                    eachTS.eachDate.work_hour = null;
                                                }
                                            })
                                        }
                                    })
                                }*/
                                if (eachTS.eachDate.category != value) {
                                    eachTS.eachDate.work_hour = '';
                                    if (eachTS.eachDate.category == 'CRMIT Holiday') {
                                        eachTS.eachDate.description = '';
                                    }
                                }
                                if (value == 'Leave') {
                                    eachTS.eachDate.leaveField = true;
                                } else {
                                    eachTS.eachDate.leaveField = false;
                                }
                                eachTS.eachDate.category = value;
                                let key = this.subcategoryData.controllerValues[value];
                                eachTS.eachDate.subcatOptions = this.subcategoryData.values.filter(option => option.validFor.includes(key));
                                if (eachTS.eachDate.subcatOptions.length == 1) {
                                    eachTS.eachDate.sub_category = eachTS.eachDate.subcatOptions[0].value;
                                } else {
                                    eachTS.eachDate.sub_category = '';
                                }
                                //Leave is removed
                                /*if (eachTS.eachDate.category == 'Leave') {
                                    eachTS.eachDate.description = 'Leave';
                                    if (eachTS.eachDate.work_hour != 4.00) {
                                        eachTS.eachDate.work_hour = 8.00;
                                    }
                                    this.handleLeaveChanges(eachTS.eachDate.date, projectId, eachTS.eachDate.work_hour);
                                }*/
                                if (eachTS.eachDate.category == 'CRMIT Holiday') {
                                    eachTS.eachDate.work_hour = 8.00;
                                    eachTS.eachDate.description = 'CRMIT Holiday';
                                }
                                eachTS.eachDate.cloned = false;
                            } else if (propName == 'sub_category') {
                                eachTS.eachDate.sub_category = value;
                                eachTS.eachDate.cloned = false;
                            } else if (propName == 'work_hour') {
                                eachTS.eachDate.work_hour = value;
                                if (eachTS.eachDate.category == 'Leave') {
                                    eachTS.eachDate.work_hour = parseFloat(value).toPrecision(3);
                                }
                                /*if (eachTS.eachDate.category == 'Leave') {
                                    this.handleLeaveChanges(eachTS.eachDate.date, projectId, eachTS.eachDate.work_hour);
                                }*/
                            } else if (propName == 'description') {
                                eachTS.eachDate.description = value;
                            }
                        }
                        return eachTS;
                    });
                }
                return data;
            });
        }
        this.sortGeneratedObj();
        this.calculateTotalHours();
        this.calculateTotalHoursforProject();
        this.spinnerFlag = false;
        //console.log(`Updated JSON: ${JSON.stringify(this.generatedAlloc)}`);
    }

    /*Upload Proof Start*/

    //An Object to store file data for each Project Allocation except "Others"
    fileData = {};
    
    maxFileSize;
    listOfFileFormats;
    fileTypes = [];

    @wire(getMaxFileSize)
    wiredCustomSettingData({ error, data }) {
        if (data) {
            this.customSettingData = data;
            this.maxFileSize = this.customSettingData.size__c;
        } else if (error) {
            console.error('Error loading custom setting data', error);
        }
    }

    
     @wire(getAccFileSettingData)
    wiredAcctFileSettingData({ error, data }) {
        if (data) {
            this.customSettingData = data;
            this.listOfFileFormats = this.customSettingData.fileformats__c;
            this.fileTypes = this.listOfFileFormats.split(',');

            //console.log("fileTypes>>"+typeof this.fileTypes);

        } else if (error) {
            console.error('Error loading custom setting data', error);
        }
    }


  
    handleUploadProof(event) {
        const allocId = event.target.dataset.id; // Team Allocation Id
    
        if (!this.fileData[allocId]) {
            this.fileData[allocId] = {}; // Initialize the object if it doesn't exist
        }
    
        const file = event.target.files[0];
        event.target.value = '';
    
        console.log('MaxFileSize' + this.maxFileSize);
         const fileExtension = file.name.split('.').pop().toLowerCase();
    
        if (!this.fileTypes.includes("." + fileExtension)) {
        // Handle file type validation failure
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Invalid File Type',
                    message: 'The uploaded file type isn\'t supported. Please select a file with an accepted format',
                    variant: 'error',
            })
        );
        }
    
      
    
        else  if (file.size > this.maxFileSize) {
            // Handle file size validation failure
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'File Size Exceeded',
                    message: 'The selected file exceeds the maximum allowed file size.',
                    variant: 'error',
                })
            );
        } else {
            let projectNameString = this.generatedAlloc[allocId].projectName.split(' ');
            let projectFirstWord = projectNameString[0];

            let fileNameString = this.startDateStr+'_'+projectFirstWord+'_'+this.empObj.Name+'_'+file.name;
            this.generatedAlloc[allocId].fileName = fileNameString;
    
            const reader = new FileReader();
            reader.onload = () => {
                var base64 = reader.result.split(',')[1];
                this.generatedAlloc[allocId].filedata = base64;
            };
            reader.readAsDataURL(file);
        }
    }
    
    removeFile(event) {
        const tempAllocId = event.target.dataset.id;
        console.log(tempAllocId);
        
        if (this.generatedAlloc[tempAllocId]) {
            this.generatedAlloc[tempAllocId].fileName = ''; // Clear the file name
        }
    }
    
    //Upload Proof End

    handleDraft() {
        this.sortGeneratedObj();
        if (this.submittedFlag) {
            return;
        }
        let flag = true;
        let pivotDate = window.moment(this.momentizedStartDate.format('YYYY-MM-DD'));
        while (this.momentizedEndDate.isAfter(pivotDate)) {
            let currDayHours = 0.00;
            this.generatedAlloc.forEach(data => {
                data.eachProject.forEach(tsData => {
                    if (tsData.eachDate.date == pivotDate.format('YYYY-MM-DD')) {
                        if (!isNaN(parseFloat(tsData.eachDate.work_hour))) {
                            currDayHours += parseFloat(tsData.eachDate.work_hour);
                        }
                        if (currDayHours > 12.00) {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error!!',
                                    message: `You cannot log more than 12 hrs of effort in a day (${pivotDate.format('DD-MMM-YYYY')}) .Please Cap it to 12 for now and discuss the same with your reporting manager .`,
                                    variant: 'error',
                                    mode: 'sticky'
                                })
                            );
                            flag = false;
                        }
                    }
                })
            });
            pivotDate.add(1, 'days');
        }
        this.generatedAlloc.forEach(data => {
            let tempFlag = false;
            data.eachProject.forEach((eachTS, idx, orgArray) => {
                let prevIdx = idx - 1;
                if (tempFlag && orgArray[prevIdx].eachDate.category == eachTS.eachDate.category && orgArray[prevIdx].eachDate.sub_category == eachTS.eachDate.sub_category && orgArray[prevIdx].eachDate.date == eachTS.eachDate.date) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!!',
                            message: `Duplicate records found on ${eachTS.eachDate.date} for Project: ${eachTS.eachDate.project}.`,
                            variant: 'error'
                        })
                    );
                    flag = false;
                }
                tempFlag = true;
                let selectedDate = window.moment(eachTS.eachDate.date);
                let taEndDate = window.moment(eachTS.eachDate.taEnd);
                let taStartDate = window.moment(eachTS.eachDate.taStart);
                if (selectedDate.isAfter(taEndDate) && (eachTS.eachDate.category != '' || eachTS.eachDate.sub_category != '' || eachTS.eachDate.description != '' || eachTS.eachDate.work_hour != '')) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!!',
                            message: `Please select date on or before ${taEndDate.format('DD-MMM-YYYY')} as the Project: ${eachTS.eachDate.project} allocation is ending on ${taEndDate.format('DD-MMM-YYYY')}.`,
                            variant: 'error',
                            mode: 'sticky'
                        })
                    );
                    flag = false;
                }
                if (taStartDate.isAfter(selectedDate) && (eachTS.eachDate.category != '' || eachTS.eachDate.sub_category != '' || eachTS.eachDate.description != '' || eachTS.eachDate.work_hour != '')) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!!',
                            message: `Please select date on or after ${taStartDate.format('DD-MMM-YYYY')} as the Project: ${eachTS.eachDate.project} allocation is starting on ${taStartDate.format('DD-MMM-YYYY')}.`,
                            variant: 'error',
                            mode: 'sticky'
                        })
                    );
                    flag = false;
                }
                if ((eachTS.eachDate.category != '' || eachTS.eachDate.sub_category != '' || eachTS.eachDate.description != '' || eachTS.eachDate.work_hour != '') && (eachTS.eachDate.category == '' || eachTS.eachDate.description == '' || eachTS.eachDate.sub_category == '' || eachTS.eachDate.work_hour == '')) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!',
                            message: `All fields are mandatory! (${eachTS.eachDate.project})`,
                            variant: 'error'
                        })
                    );
                    flag = false;
                }
                if ((selectedDate.isAfter(this.momentizedEndDate) || this.momentizedStartDate.isAfter(selectedDate)) && (eachTS.eachDate.category != '' || eachTS.eachDate.sub_category != '' || eachTS.eachDate.description != '' || eachTS.eachDate.work_hour != '')) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!!',
                            message: `Selected Date ${selectedDate.format('DD-MMM-YYYY')} for the Project: ${eachTS.eachDate.project} not in current week range.`,
                            variant: 'error',
                            mode: 'sticky'
                        })
                    );
                    flag = false;
                }
                // if (eachTS.eachDate.category != 'Leave') {
                // } else if (eachTS.eachDate.category == 'Leave') {
                //     if ((eachTS.eachDate.sub_category != '' || eachTS.eachDate.description != '' || eachTS.eachDate.work_hour != '') && (eachTS.eachDate.description == '' || eachTS.eachDate.sub_category == '' || eachTS.eachDate.work_hour == '')) {
                //         console.log('THAT ONE')
                //         this.dispatchEvent(
                //             new ShowToastEvent({
                //                 title: 'Error!',
                //                 message: `All fields are mandatory!`,
                //                 variant: 'error'
                //             })
                //         );
                //         flag = false;
                //     }
                // }
                // Not required as Leave is dropped
                /*if (eachTS.eachDate.category == 'Leave') {
                    if (!(eachTS.eachDate.work_hour == 8.00 || eachTS.eachDate.work_hour == 4.00)) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!!',
                                message: `Hours allowed for the Leave is either 4 or 8.`,
                                variant: 'error'
                            })
                        );
                        flag = false;
                    }
                }*/
                //console.log(`WH: ${eachTS.eachDate.work_hour}`);
                if (eachTS.eachDate.work_hour != '') {
                    if (eachTS.eachDate.work_hour <= 0) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!!',
                                message: `Work hour is not valid!`,
                                variant: 'error'
                            })
                        );
                        flag = false;
                    }
                }
            });
        });
        if (flag && this.generatedAlloc.length) {
            allocationPostProcess(this.generatedAlloc).then(data => {
                this.generatedAlloc = data;
                //console.log('After Process: ', JSON.stringify(data));
                this.spinnerFlag = true;
                if (flag && this.generatedAlloc.length) {
                    this.spinnerFlag = true;
                    //console.log(`Before Save: ${JSON.stringify(this.generatedAlloc)}`);
                    saveTS({ stringifiedObj: JSON.stringify(this.generatedAlloc), save: false, empID: this.empObj.Id, startStr: this.momentizedStartDate.format('YYYY-MM-DD'), reportingManagerId: this.empObj.ReportingTo__r.SF_User__c, parentTS: this.parentTS,fileData: JSON.stringify(this.fileData) })
                        .then(data => {
                            //console.log(data)
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success!!',
                                    message: 'Saved!',
                                    variant: 'success'
                                })
                            )
                            /*setTimeout(function () {
                                //window.location.reload();
                                window.history.back();
                            }, 1000);*/
                            //window.history.back();
                            this.spinnerFlag = false;
                            
                            let strURL = window.location.href;
                            if(this.profileName=='Partner Community Login Contractors'){
                                let locURL = strURL.split('CRMITPRCommunity/s/');
                                let backtoListTimesheet = `${locURL[0]}CRMITPRCommunity/s/recordlist/Team_Timesheet__c/Default`;
                                window.location.href = backtoListTimesheet;
                            }else {

                                let locURL = strURL.split('CRMITCommunity/s/');
                                let backtoListTimesheet = `${locURL[0]}CRMITCommunity/s/recordlist/Team_Timesheet__c/Default`;
                                window.location.href = backtoListTimesheet;
                            }
                            
                        })
                        .catch(err => {
                            //console.log(err);
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error!!',
                                    message: `Ooops! Looks like we have a problem saving your entries now. Please feel free to report the issue using the 'Error Logging Timesheet?' link on the bottom left on the timesheet entry page.`,
                                    variant: 'error'
                                })
                            );
                            this.spinnerFlag = false;
                        })
                }
            }).catch(err => {
                console.log('Allocation Post Process', err);
                this.spinnerFlag = false;
            });
        }
    }
    handleConfirmation() {
        let continueFlag = true;
        this.generatedAlloc.forEach(data => {
            data.eachProject.forEach(eachTS => {
                if ((eachTS.eachDate.category != '' || eachTS.eachDate.sub_category != '' || eachTS.eachDate.description != '' || eachTS.eachDate.work_hour != '') && (eachTS.eachDate.category == '' || eachTS.eachDate.description == '' || eachTS.eachDate.sub_category == '' || eachTS.eachDate.work_hour == '')) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!',
                            message: `All fields are mandatory! (${eachTS.eachDate.project})`,
                            variant: 'error'
                        })
                    );
                    continueFlag = false;
                }
                // if (eachTS.eachDate.category != 'Leave') {
                // } else if (eachTS.eachDate.category == 'Leave') {
                //     if ((eachTS.eachDate.sub_category != '' || eachTS.eachDate.description != '' || eachTS.eachDate.work_hour != '') && (eachTS.eachDate.description == '' || eachTS.eachDate.sub_category == '' || eachTS.eachDate.work_hour == '')) {
                //         this.dispatchEvent(
                //             new ShowToastEvent({
                //                 title: 'Error!',
                //                 message: `All fields are mandatory!`,
                //                 variant: 'error'
                //             })
                //         );
                //         continueFlag = false;
                //     }
                // }
            });

        });
        if (this.totalHours < 40)
        {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: `Effort logged for the week is less than 40 hrs.`,
                    variant: 'error'
                    
                })
            );
        return;
        }
        if (continueFlag) {
            this.confirmBox = true;
        }
    }
    handleSubmit() {
        this.sortGeneratedObj();
        if (this.submittedFlag) {
            return;
        }
        let flag = true;
        let pivotDate = window.moment(this.momentizedStartDate.format('YYYY-MM-DD'));
        while (this.momentizedEndDate.isAfter(pivotDate)) {
            let currDayHours = 0;
            this.generatedAlloc.forEach(data => {
                data.eachProject.forEach(tsData => {
                    if (tsData.eachDate.date == pivotDate.format('YYYY-MM-DD')) {
                        if (!isNaN(parseFloat(tsData.eachDate.work_hour))) {
                            currDayHours += parseFloat(tsData.eachDate.work_hour);
                        }
                        if (currDayHours > 12.00) {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error!!',
                                    message: `You cannot log more than 12 hrs of effort in a day (${pivotDate.format('DD-MMM-YYYY')}) .Please Cap it to 12 for now and discuss the same with your reporting manager .`,
                                    variant: 'error',
                                    mode: 'sticky'
                                })
                            );
                            flag = false;
                        }
                    }
                })
            });
            pivotDate.add(1, 'days');
        }
        this.generatedAlloc.forEach(data => {
            let tempFlag = false;
            data.eachProject.forEach((eachTS, idx, orgArray) => {
                let prevIdx = idx - 1;
                if (tempFlag && orgArray[prevIdx].eachDate.category == eachTS.eachDate.category && orgArray[prevIdx].eachDate.sub_category == eachTS.eachDate.sub_category && orgArray[prevIdx].eachDate.date == eachTS.eachDate.date) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!!',
                            message: `Duplicate tasks found for the day: ${eachTS.eachDate.date} at Project: ${eachTS.eachDate.project}.`,
                            variant: 'error'
                        })
                    );
                    flag = false;
                }
                tempFlag = true;
                let selectedDate = window.moment(eachTS.eachDate.date);
                let taEndDate = window.moment(eachTS.eachDate.taEnd);
                let taStartDate = window.moment(eachTS.eachDate.taStart);
                if (selectedDate.isAfter(taEndDate) && (eachTS.eachDate.category != '' || eachTS.eachDate.sub_category != '' || eachTS.eachDate.description != '' || eachTS.eachDate.work_hour != '')) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!!',
                            message: `Please select date on or before ${taEndDate.format('DD-MMM-YYYY')} as the Project: ${eachTS.eachDate.project} allocation is ending on ${taEndDate.format('DD-MMM-YYYY')}.`,
                            variant: 'error',
                            mode: 'sticky'
                        })
                    );
                    flag = false;
                }
                if (taStartDate.isAfter(selectedDate) && (eachTS.eachDate.category != '' || eachTS.eachDate.sub_category != '' || eachTS.eachDate.description != '' || eachTS.eachDate.work_hour != '')) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!!',
                            message: `Please select date on or after ${taStartDate.format('DD-MMM-YYYY')} as the Project: ${eachTS.eachDate.project} allocation is starting on ${taStartDate.format('DD-MMM-YYYY')}.`,
                            variant: 'error',
                            mode: 'sticky'
                        })
                    );
                    flag = false;
                }
                if ((selectedDate.isAfter(this.momentizedEndDate) || this.momentizedStartDate.isAfter(selectedDate)) && (eachTS.eachDate.category != '' || eachTS.eachDate.sub_category != '' || eachTS.eachDate.description != '' || eachTS.eachDate.work_hour != '')) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error!!',
                            message: `Selected Date ${selectedDate.format('DD-MMM-YYYY')} for the Project: ${eachTS.eachDate.project} not in current week range.`,
                            variant: 'error'
                        })
                    );
                    flag = false;
                }
                //Removed as leave is not required (New Logic For Leave)
                /*if (eachTS.eachDate.category == 'Leave') {
                    if (!(eachTS.eachDate.work_hour == 8.00 || eachTS.eachDate.work_hour == 4.00)) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!!',
                                message: `Hours allowed for the Leave is either 4 or 8.`,
                                variant: 'error'
                            })
                        );
                        flag = false;
                    }
                }*/
                //console.log(`WH: ${eachTS.eachDate.work_hour}`);
                if (eachTS.eachDate.work_hour != '') {
                    if (eachTS.eachDate.work_hour <= 0) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!!',
                                message: `Work hour is not valid!`,
                                variant: 'error'
                            })
                        );
                        flag = false;
                    }
                }
            });
        });
        if (flag && this.generatedAlloc.length) {
            allocationPostProcess(this.generatedAlloc).then(data => {
                this.spinnerFlag = true;
                this.generatedAlloc = data;
                //console.log('After Process: ', JSON.stringify(data));
                if (flag && this.generatedAlloc.length) {
                    this.spinnerFlag = true;
                    //console.log(`Before Save: ${JSON.stringify(this.generatedAlloc)}`);
                    saveTS({ stringifiedObj: JSON.stringify(this.generatedAlloc), save: true, empID: this.empObj.Id, startStr: this.momentizedStartDate.format('YYYY-MM-DD'), reportingManagerId: this.empObj.ReportingTo__r.SF_User__c, parentTS: this.parentTS, fileData: JSON.stringify(this.fileData) })
                        .then(data => {
                            //console.log(data)
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Success!!',
                                    message: 'Saved!',
                                    variant: 'success'
                                })
                            )
                            this.confirmBox = false;
                            /*setTimeout(function () {
                                //window.location.reload();
                                window.history.back();
                            }, 1000);*/
                            //window.location.reload();
                            //window.history.back();
                            this.spinnerFlag = false;
                            let strURL = window.location.href;
                            if(this.profileName=='Partner Community Login Contractors'){
                                let locURL = strURL.split('CRMITPRCommunity/s/');
                                let backtoListTimesheet = `${locURL[0]}CRMITPRCommunity/s/recordlist/Team_Timesheet__c/Default`;
                                window.location.href = backtoListTimesheet;
                            }else {

                                let locURL = strURL.split('CRMITCommunity/s/');
                                let backtoListTimesheet = `${locURL[0]}CRMITCommunity/s/recordlist/Team_Timesheet__c/Default`;
                                window.location.href = backtoListTimesheet;
                            }
                        })
                        .catch(err => {
                            console.log(err);
                            console.log(err.body.message);
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error!!',
                                    message: `Ooops! Looks like we have a problem saving your entries now. Please feel free to report the issue using the 'Error Logging Timesheet?' link on the bottom left on the timesheet entry page.`,
                                    variant: 'error'
                                })
                            );
                            this.spinnerFlag = false;
                        });
                }
            }).catch(err => {
                console.log('Allocation Post Process', err);
                this.spinnerFlag = false;
            });
        }
    }
    closeConfirm() {
        this.confirmBox = false;
    }
    previousPage() {
        let strURL = window.location.href;
        let backtoListTimesheet='';
        if(this.profileName=='Partner Community Login Contractors'){
            let locURL = strURL.split('CRMITPRCommunity/s/');
             backtoListTimesheet += `${locURL[0]}CRMITPRCommunity/s/recordlist/Team_Timesheet__c/Default`;
            //window.location.href = backtoListTimesheet;
            console.log('Inside if block',backtoListTimesheet);
        }else {

            let locURL = strURL.split('CRMITCommunity/s/');
             backtoListTimesheet += `${locURL[0]}CRMITCommunity/s/recordlist/Team_Timesheet__c/Default`;
            //window.location.href = backtoListTimesheet;
            console.log('Inside else block',backtoListTimesheet);
        }
        if (this.generatedAlloc) {
            this.isModalOpen = false;
            this.workaholic = this.tempWorkaholic;
        } else {
            /*setTimeout(function () {
                window.history.back();
            }, 1000);*/
            
            window.location.href = backtoListTimesheet;
        }
    }
    sortGeneratedObj() {
        this.spinnerFlag = true;
        this.generatedAlloc.forEach(data => {
            data.eachProject.sort((curr, prev) => {
                return new Date(curr.eachDate.date) - new Date(prev.eachDate.date);
            });
            return data;
        });
        this.spinnerFlag = false;
    }
    closeDelete() {
        this.deleteConfirm = false;
    }
    handleSectionToggle(event) {
        this.activeSections = [];
        const openSections = event.detail.openSections;
        openSections.forEach(data => this.activeSections.push(data));
        //console.log(this.activeSections);
    }
    closeApprovalBox() {
        this.showApprovalBox = false;
        this.approvalBoxLabel = '';
        this.approvalDescription = '';
        this.approvalBoxHeading = 'Comments';
        this.approvalBoxPlaceholder = 'Comments..'
    }
    handleRejection() {
        this.approvalBoxHeading = 'Reason for Rejection';
        this.approvalBoxPlaceholder = 'Reason for Rejection here....';
        this.approvalBoxLabel = 'Reject';
        this.showApprovalBox = true;
    }
    handleApproval() {
        this.approvalBoxLabel = 'Approve';
        this.approvalBoxHeading = 'Approval Comment';
        this.approvalBoxPlaceholder = 'Comments..';
        this.showApprovalBox = true;
        this.approvalDescription = 'Approved';
    }
    handleDescriptionInput(event) {
        this.approvalDescription = event.target.value;
    }
    submitApproval() {
        if (this.approvalDescription == '') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: 'Comments are required!',
                    variant: 'error'
                })
            );
            return false;
        }
        this.spinnerFlag = true;
        approvalStep({ reqAction: this.approvalBoxLabel, reqComments: this.approvalDescription, workItemId: this.existingTTcontinuation.Current_Work_Item_ID__c })
            .then(data => {
                if (this.approvalBoxLabel == 'Approve') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Approved!!',
                            message: 'Timesheet approved successfully!',
                            variant: 'success'
                        })
                    );
                } else if (this.approvalBoxLabel == 'Reject') {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Rejected!!',
                            message: 'Timesheet rejected successfully!',
                            variant: 'success'
                        })
                    );
                }
                this.spinnerFlag = true;
                let strURL = window.location.href;
                if(this.profileName=='Partner Community Login Contractors'){
                    let locURL = strURL.split('CRMITPRCommunity/s/');
                    let backtoListTimesheet = `${locURL[0]}CRMITPRCommunity/s/recordlist/Team_Timesheet__c/Default`;
                   // window.location.href = backtoListTimesheet;
                }else {

                    let locURL = strURL.split('CRMITCommunity/s/');
                    let backtoListTimesheet = `${locURL[0]}CRMITCommunity/s/recordlist/Team_Timesheet__c/Default`;
                   // window.location.href = backtoListTimesheet;
                }
                setTimeout(() => {
                    window.location.href = backtoListTimesheet;
                }, 1000)
            })
            .catch(err => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: `Ooops! Looks like we have a problem saving your entries now. Please feel free to report the issue using the 'Error Logging Timesheet?' link on the bottom left on the timesheet entry page.`,
                        variant: 'error'
                    })
                );
                this.spinnerFlag = false;
            })
    }
    handleReport() {
        this.reportFlag = true;
    }
    handleBack(event) {
        window.history.back();
    }
    handleClose(event) {
        this.reportFlag = event.detail;
    }
    calculateTotalHours() {
        this.totalHours = 0.00;
        this.generatedAlloc.forEach(data => {
            data.eachProject.forEach(eTS => {
                if (eTS.eachDate.work_hour != '') {
                    this.totalHours += parseFloat(eTS.eachDate.work_hour);
                }
            })
        });
        if (this.totalHours <= 10.00) {
            this.totalHours = this.totalHours.toPrecision(3);
        } else {
            this.totalHours = this.totalHours.toPrecision(4);
        }
    }
    calculateTotalHoursforProject() {
        this.generatedAlloc.forEach(data => {
            data.currProjectHours = 0.00;
            data.eachProject.forEach(eTS => {
                if (eTS.eachDate.work_hour != '') {
                    data.currProjectHours += parseFloat(eTS.eachDate.work_hour);
                }
            });
            if (data.currProjectHours <= 10.00) {
                data.currProjectHours = data.currProjectHours.toPrecision(3);
            } else {
                data.currProjectHours = data.currProjectHours.toPrecision(4);
            }
            data.projectName_hours_combined = `${data.projectName}  : Hours ${data.currProjectHours}`;
            return data;
        })
    }
    adjustingDate(projectId, uid, originalDate, currPos) {
        this.spinnerFlag = true;
        // this.generatedAlloc.forEach(data => {
        //     if (data.key == projectId) {
        //         data.eachProject.forEach(eachTS => {
        //             if (eachTS.key == uid) {
        //                 eachTS.eachDate.date = originalDate;
        //             }
        //         });
        //     }
        // });
        // this.spinnerFlag = false;
        //console.log('Set Timeout Placed');
        window.setTimeout(() => {
            //console.log('Set Timeout Fired');
            this.generatedAlloc.forEach(data => {
                if (data.key == projectId) {
                    data.eachProject.forEach(eachTS => {
                        if (eachTS.key == uid) {
                            eachTS.eachDate.date = originalDate;
                        }
                    });
                }
            });
            this.spinnerFlag = false;
        }, 100);
        window.setTimeout(() => {
            window.scrollTo(0, currPos);
        }, 500)
    }
    /*handleLeaveChanges(onDateStr, projectFrom, hrsChose) {
        let newRec = true;
        let key = this.subcategoryData.controllerValues['Leave'];
        let localsubcatOptions = this.subcategoryData.values.filter(option => option.validFor.includes(key));
        this.generatedAlloc.forEach(data => {
            if (data.key != projectFrom) {
                let isBlankEntryNotThere = true;
                let singleEntry = true;
                data.eachProject.forEach(eTS => {
                    if (eTS.eachDate.date == onDateStr && (eTS.eachDate.category == '' || eTS.eachDate.category == 'Leave') && (eTS.eachDate.sub_category == '' || eTS.eachDate.sub_category == 'Leave') && singleEntry) {
                        newRec = false;
                        singleEntry = false;
                        isBlankEntryNotThere = false;
                        eTS.eachDate.category = 'Leave';
                        eTS.eachDate.sub_category = 'Leave';
                        eTS.eachDate.work_hour = hrsChose;
                        eTS.eachDate.description = 'Leave';
                        eTS.eachDate.subcatOptions = localsubcatOptions;
                    }
                    return eTS;
                });
                if (isBlankEntryNotThere) {
                    data.eachProject.forEach(eTS => {
                        if (eTS.eachDate.date == onDateStr) {
                            newRec = false;
                            eTS.eachDate.category = 'Leave';
                            eTS.eachDate.sub_category = 'Leave';
                            eTS.eachDate.work_hour = hrsChose;
                            eTS.eachDate.description = 'Leave';
                            eTS.eachDate.subcatOptions = localsubcatOptions;
                        }
                        return eTS;
                    });
                }
            }
            return data;
        });
        if (newRec) {
            this.generatedAlloc.forEach(data => {
                if (data.key != projectFrom) {
                    let obj = {
                        key: this.indexation,
                        eachDate: {
                            project: data.eachProject[0].eachDate.project,
                            projectId: data.eachProject[0].eachDate.projectId,
                            projectAllocId: data.eachProject[0].eachDate.projectAllocId,
                            region: data.eachProject[0].eachDate.region,
                            reportingManager: data.eachProject[0].eachDate.reportingManager,
                            billingStatus: data.eachProject[0].eachDate.billingStatus,
                            date: onDateStr,
                            allocPercentage: data.eachProject[0].eachDate.allocPercentage,
                            category: 'Leave',
                            sub_category: 'Leave',
                            work_hour: hrsChose,
                            description: 'Leave',
                            taEnd: data.eachProject[0].eachDate.taEnd,
                            taStart: data.eachProject[0].eachDate.taStart,
                            existing: false,
                            catOptions: data.eachProject[0].eachDate.catOptions,
                            subcatOptions: localsubcatOptions,
                            cloned: false
                        }
                    }
                    data.eachProject.push(obj);
                    this.indexation += 10;
                }
                return data;
            });
        }
    }*/
    connectedCallback() {
        //console.log(navigator.userAgent);
        Promise.all([loadScript(this, moment)])
            .then(() => {
                //console.log("Moment Loaded");
                window.addEventListener('scroll', event => {
                    let topBar = this.template.querySelector('.weekBlock');
                    //scrollY __ for Org (Changed because addition of msg)
                    //216 for Community
                    let scrollVal = 216;
                    if (this.loadCarouselBanner) {
                        scrollVal = 280;
                    }
                    //console.log(`${window.scrollY}, Current Val: ${scrollVal}`);
                    if (topBar) {
                        if (window.scrollY > scrollVal) {
                            topBar.classList.add('fixedTopBar');
                        } else {
                            topBar.classList.remove('fixedTopBar');
                        }
                    }
                })
                let currRecId = localStorage.getItem("curRecId");
                localStorage.removeItem("curRecId");
                if (currRecId) {
                    return prevRec({ currRecId });
                } else {
                    return null;
                }
            })
            .then(data => {
                //console.log(`PChain1: ${JSON.stringify(data)}`);
                if (data && data.currTS) {
                    this.managerView = data.managerView;
                    this.existingTTcontinuation = data.currTS;
                    return getEmployee({ empID: data.currTS.Employee_Name__c });
                } else {
                    return getEmployee();
                }
            })
            .then(data => {
                if (data) {
                    if (Object.keys(data).length === 0) {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error!!',
                                message: `Please check with Timesheet Helpdesk to link your profile correctly!`,
                                variant: 'error'
                            })
                        );
                        // this.dispatchEvent(
                        //     new ShowToastEvent({
                        //         title: 'Wait for the launch!!',
                        //         message: `Coming Soon!`,
                        //         variant: 'warning'
                        //     })
                        // );
                        let strURL = window.location.href;
                        if(this.profileName=='Partner Community Login Contractors'){
                            let locURL = strURL.split('CRMITPRCommunity/s/');
                            let backtoListTimesheet = `${locURL[0]}CRMITPRCommunity/s/recordlist/Team_Timesheet__c/Default`;
                           // window.location.href = backtoListTimesheet;
                        }else {

                            let locURL = strURL.split('CRMITCommunity/s/');
                            let backtoListTimesheet = `${locURL[0]}CRMITCommunity/s/recordlist/Team_Timesheet__c/Default`;
                           // window.location.href = backtoListTimesheet;
                        }
                        setTimeout(() => {
                            //window.location.href = backtoListTimesheet;
                        }, 3000)
                    }
                    this.empObj = data.empUser;
                    this.msgOnTime = data.msgOnTime;
                    this.msgAbove48 = data.msgAbove48;
                    this.msgBelow40 = data.msgBelow40;
                    this.loadReportButton = data.loadReportButton == 'True' ? true : false;
                    this.loadCarouselBanner = data.loadCarouselBanner == 'True' ? true : false;
                    //console.log(`PChain2: ${JSON.stringify(data)}`);
                    //console.log(`ExististingTT: ${JSON.stringify(this.existingTTcontinuation)}`);
                    if (this.existingTTcontinuation?.Week_Start_Date__c) {
                        this.submitStartDate(event, this.existingTTcontinuation.Week_Start_Date__c);
                        return null;
                    } else {
                        return 1;
                    }
                } else {
                    console.log(`PChainErr: ${err}`);
                }
            })
            .then(data => {
                if (data) {
                    this.spinnerFlag = false;
                    this.isModalOpen = true;
                } else if (this.managerView) {
                    if (this.existingTTcontinuation.Status__c == 'Submitted') {
                        this.allowApproval = false;
                    } else {
                        this.allowApproval = true;
                    }
                }
            })
            .catch((err) => {
                console.log(`MainPChainErr: ${JSON.stringify(err)}`);
                console.log(`MainPChainErrBody: ${err.body}`);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: `Please check with Timesheet Helpdesk to link your profile correctly!`,
                        variant: 'error'
                    })
                );
                // this.dispatchEvent(
                //     new ShowToastEvent({
                //         title: 'Wait for the launch!!',
                //         message: `Coming Soon!`,
                //         variant: 'warning'
                //     })
                // );
                let strURL = window.location.href;
                if(this.profileName=='Partner Community Login Contractors'){
                    let locURL = strURL.split('CRMITPRCommunity/s/');
                    let backtoListTimesheet = `${locURL[0]}CRMITPRCommunity/s/recordlist/Team_Timesheet__c/Default`;
                    //window.location.href = backtoListTimesheet;
                }else {

                    let locURL = strURL.split('CRMITCommunity/s/');
                    let backtoListTimesheet = `${locURL[0]}CRMITCommunity/s/recordlist/Team_Timesheet__c/Default`;
                   // window.location.href = backtoListTimesheet;
                }
                setTimeout(() => {
                    //window.location.href = backtoListTimesheet;
                }, 3000);
            });
        Promise.all([
            loadStyle(this, externalCSS)
        ])
            .then(() => {
                //console.log('CSS Loaded');
            })
            .catch(err => {
                //console.log(err);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: `Ooops! Looks like we have a problem saving your entries now. Please feel free to report the issue using the 'Error Logging Timesheet?' link on the bottom left on the timesheet entry page.`,
                        variant: 'error'
                    })
                );
                this.spinnerFlag = false;
            })
    }
}