import { LightningElement, track, wire } from 'lwc';
import getAttendence from '@salesforce/apex/EventController.getAttendence';
import recordDetails from "@salesforce/apex/manualAttendenceRegularizeCtrl.getRecordDetails";
import regularize from "@salesforce/apex/manualAttendenceRegularizeCtrl.updateRegularizedDate";
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import Id from "@salesforce/user/Id";
import LightningConfirm from 'lightning/confirm';

export default class EmployeeCalenderCmp extends LightningElement {
    @track startDate = new Date();
    @track endDate;
    error;
    openModal = false;
    showCalender = false;
    @track events = [];
    wiredResult;
    baseUrl = window.location.origin + '/CRMITCommunity/s/attendance';

    @track todayDate;
    userId = Id;
    @track attendenceRecord;
    @track managerDetails = {};
    @track atdResult = {};
    @track atdName = {};
    @track empDetails = {};
    @track totalHours;

    @track checkIn;
    @track checkOut;
    @track duration;
    @track empCommnets;
    @track recordId;
    @track loader = false;


    @track options = [{ label: 'Forget To Check In', value: 'Forget To CheckIn' }, { label: 'Forget To Check Out', value: 'Forget To CheckOut' }, { label: 'Others', value: 'Others' }];
    @track empReason;

    @wire(getAttendence)
    eventObj(value) {
        this.loader = true;
        this.todayDate = new Date();
        this.wiredResult = value;
        const { data, error } = value;
        this.attendenceRecord = data;
        this.empCommnets = undefined;
        this.empReason = undefined;
        if (data) {
            let records = data.map(event => {
                return {
                    id: event.Id,
                    title: event.Regularization__c === 'Approved' ? 'Regularized' : (event.Regularization__c === 'Approval Awaited' ? 'Approval Awaited' : (event.Status_Of_Day__c.toUpperCase() === 'ABSENT' || event.Status_Of_Day__c.toUpperCase() === 'HALF DAY' ? 'Need To Regularize' : (event.Status_Of_Day__c.toUpperCase() === 'FULL DAY' ? 'Present' : event.Status_Of_Day__c))),
                    start: event.Date__c,
                    end: event.Date__c,
                    //url: window.location.origin + '/CRMITCommunity/s/attendance/' + event.Id + '/' + event.Name.replace('-', '').toLowerCase(),
                    textColor: event.Regularization__c === 'Approval Awaited' ? '#020294' : 'white',
                    borderColor: 'rgba(111,111,111,0.2) transparent transparent',
                    backgroundColor: event.Regularization__c === 'Approved' ? '#91c066' : (event.Regularization__c === 'Approval Awaited' ? '#e4d064' : (event.Status_Of_Day__c === 'ABSENT' || event.Status_Of_Day__c === 'HALF DAY' ? '#d94949' : (event.Status_Of_Day__c === 'On Leave' || event.Status_Of_Day__c === 'Public Holiday') ? '#0e5d9c' : '#759849')),
                    allDay: 'true'
                };
            });
            this.events = JSON.parse(JSON.stringify(records));
            this.error = undefined;
            this.loader = false;
            this.showCalender = true;

        } else if (error) {
            this.events = [];
            this.error = 'No events are found';
            this.loader = false;
            this.showCalender = true;
        }
    }

    refreshTable() {
        return refreshApex(this.wiredResult)
            .then((result) => {
                this.template.querySelector('c-calender-view-parent').refreshCalender();
            })
            .catch(error => {
                console.error('Error refreshing table', error);
            })
    }

    handleEvent(event) {
        var id = event.detail;
        if (id === undefined) {
            return;
        }
        let task = this.wiredResult.data.find(x => x.Id === id);
        this.recordId = id;
        this.recordName = task.Name;
        if (task.Regularization__c === 'Approved' || task.Regularization__c === 'Approval Awaited' || task.Status_Of_Day__c === 'FULL DAY' || task.Status_Of_Day__c === 'Public Holiday' || task.Status_Of_Day__c === 'On Leave') {
            this.viewRecordDetails();
        } else {
            this.getRecordDetails();
        }
    }

    viewRecordDetails() {
        let naviUrl = window.location.origin + '/CRMITCommunity/s/attendance/' + this.recordId + '/' + this.recordName.replace('-', '').toLowerCase() + '?tabset-0eb33a68=2';
        window.open(naviUrl);
    }

    hideModalBox(event) {
        this.empCommnets = undefined;
        this.empReason = undefined;
        this.openModal = false;
    }

    getRecordDetails() {
        recordDetails({ atdId: this.recordId, userId: this.userId })
            .then(result => {

                if (result === null) {
                    this.toastEventFire('You Dont Have Access On Record', 'You Dont Have Access On Record You Can Only View', 'Error');
                    return;
                } if (result.Status_Of_Day__c === 'On Leave' || result.Status_Of_Day__c === 'Public Holiday') {
                    this.toastEventFire('Cannot Regularize', 'You Cannot Regularize Leave or Public Holiday Attendence', 'Error');
                    return;
                }
                if (result.Regularization_Status__c === 'Approved' || result.Regularization_Status__c === 'Waiting For Approval') {
                    this.toastEventFire('Sorry this attendence is already regularized', 'Please contact the admin', 'Error');
                    return;
                } else {
                    this.openModal = true;
                    this.atdResult = result;
                    this.empDetails = result.Employee__r;
                    this.managerDetails = result.Employee__r.ReportingTo__r;
                    if (this.atdResult.Duration_In_Min_Date_and_Time__c !== null) {
                        this.duration = this.atdResult.Duration_In_Min_Date_and_Time__c;
                    } if (this.atdResult.First_Check_In__c !== undefined) {
                        this.checkIn = this.firstcheckIn = this.timeDetails(this.atdResult.First_Check_In_Date_and_Time__c);
                    } if (this.atdResult.Last_Check_Out__c !== undefined) {
                        this.checkOut = this.firstcheckOut = this.timeDetails(this.atdResult.Last_Check_Out_Date_and_Time__c);
                    }
                }
            }).catch(error => {
                console.log('error:::' + JSON.stringify(error));
                this.toastEventFire('OPPS!!! Failed to Open Page', 'Please contact the admin', 'Error');
                return;

            });
    }

    toastEventFire(title, msg, variant) {
        const toastEvent = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant,
            mode: 'dismissable',
        });
        this.dispatchEvent(toastEvent);
    }

    handleDateCtrl(event) {
        this.atdRegularizedDate = event.target.value;
        this.updateDuration();
    }

    handleTimeInCtrl(event) {
        if (event.target.name === 'checkInTime') {
            this.checkIn = event.target.value;
            this.updateDuration();
        } else {
            this.checkOut = event.target.value;
            this.updateDuration();
        }
    }

    handleReasonChange(event) {
        this.empReason = event.target.value;
    }

    handleEmpComment(event) {
        this.empCommnets = event.target.value;
    }

    updateDuration() {
        if (this.checkIn !== undefined && this.checkOut !== undefined && (this.atdResult.Date__c !== undefined || this.atdRegularizedDate !== undefined)) {

            const loginCheckIn = new Date((this.atdResult.Date__c === undefined ? this.atdRegularizedDate : this.atdResult.Date__c) + ' ' + this.checkIn);
            const loginCheckOut = new Date((this.atdResult.Date__c === undefined ? this.atdRegularizedDate : this.atdResult.Date__c) + ' ' + this.checkOut);
            if ((parseInt(this.checkIn.substring(0, 2)) >= 12 && parseInt(this.checkIn.substring(0, 2)) < 24) && parseInt(this.checkOut.substring(0, 2)) <= 12) {
                loginCheckOut.setDate(loginCheckOut.getDate() + 1);
            }
            const minutes = this.minutesDiff(loginCheckIn, loginCheckOut);
            //console.log('minutes:::' + minutes);
            this.duration = this.timeConvert(minutes);
            //console.log('this.duration:::' + this.duration);
        }
    }

    minutesDiff(dateTimeValue1, dateTimeValue2) {
        var differenceValue = (dateTimeValue2.getTime() - dateTimeValue1.getTime()) / 1000;
        differenceValue /= 60;
        return Math.abs(Math.round(differenceValue));
    }

    timeDetails(data) {
        const date = new Date(data);
        //const timeString = date.toISOString().substr(11, 12);
        const options = {
            hour: 'numeric',
            minute: 'numeric',
            second: 'numeric',
            hour12: false, // Use 24-hour format
        };
        return date.toLocaleString(undefined, options);
    }

    timeConvert(min) {
        //toString().padStart(2, '0');
        var num = min;
        var hours = (num / 60);
        var rhours = Math.floor(hours);
        var minutes = (hours - rhours) * 60;
        var rminutes = Math.round(minutes);
        return ((rhours.toString().padStart(2, '0')) + ':' + (rminutes.toString().padStart(2, '0')));
    }

    async handleConfirmClick() {

        if (this.checkIn === undefined || this.checkOut === undefined) {
            this.toastEventFire('Please Check the dates', 'Please set check in and check out to time to regularize', 'Error');
            return;
        }

        if (this.empReason === undefined) {
            this.toastEventFire('Please select the reason', 'Please select the reason', 'Error');
            return;
        }

        if (this.empCommnets === undefined || this.empCommnets === null || this.empCommnets === "") {
            this.toastEventFire('Please enter comments', 'Please enter comments', 'Error');
            return;
        }

        if (parseInt(this.duration.substring(0, 2)) < 9) {
            const result = await LightningConfirm.open({
                message: "The duration you specified is less than 9 hours. If you wish to adjust the duration, please consider modifying the check-in or check-out time by clicking cancel.",
                label: "Your Duration is " + this.duration + ",Can you confirm ?",
                theme: "warning"
            });
            if (result) {
                this.handleSubmit();
            } else {
                //this.openModal = false;
            }
        } else {
            this.handleSubmit();
        }
    }

    handleSubmit() {
        const atdRecord = {
            Id: this.atdResult.Id,
            Regularization_Status__c: 'Waiting For Approval',
            Regularized_check_In__c: this.checkIn + 'Z',
            Regularized_check_out__c: this.checkOut + 'Z',
            is_Regularized__c: true,
            Reason_for_Regularization__c: this.empReason
        }
        if (this.empCommnets !== undefined) {
            atdRecord.Employee_Comment__c = this.empCommnets;
        }

        regularize({ data: JSON.stringify(atdRecord) })
            .then(result => {
                //console.log('result:::' + result);
                this.toastEventFire('Regularization Request Submitted Successfully', 'Regularization Request Submitted Successfully (Please Refresh the Page)', 'success');
                this.openModal = false;
                this.empCommnets = undefined;
                this.empReason = undefined;
                this.refreshTable();
            }).catch(error => {
                console.log('error:::' + JSON.stringify(error));
                this.toastEventFire('Failed to regularize the record', 'Opps Failed to regularixe the record please contact admin', 'Error');
            });
    }

}