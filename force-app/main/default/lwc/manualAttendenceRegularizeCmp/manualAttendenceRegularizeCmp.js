import { LightningElement, track, api } from 'lwc';
import uId from "@salesforce/user/Id";
import recordDetails from "@salesforce/apex/manualAttendenceRegularizeCtrl.getRecordDetails";
import regularize from "@salesforce/apex/manualAttendenceRegularizeCtrl.updateRegularizedDate";
import getNameDetails from "@salesforce/apex/manualAttendenceRegularizeCtrl.getNameDetails";
import approveRejectCtrl from "@salesforce/apex/manualAttendenceRegularizeCtrl.approveRejectCtrl";
//import createRegularize from "@salesforce/apex/manualAttendenceRegularizeCtrl.createRegularizedDate";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import Id from "@salesforce/user/Id";

export default class ManualAttendenceRegularizeCmp extends NavigationMixin(LightningElement) {
    @api recordId;

    @track isShowModal = false;
    @track showWarningMessage = false;
    userId = uId;

    @track atdResult = {};
    @track atdName = {};
    @track empDetails = {};
    @track managerDetails = {};
    @track totalHours;

    @track checkIn;
    @track checkOut;
    @track duration;
    @track empCommnets;

    @track options = [{ label: 'Forget To Check In', value: 'Forget To CheckIn' }, { label: 'Forget To Check Out', value: 'Forget To CheckOut' }];
    @track empReason;

    //new override
    @track overrideNewButton = false;
    @track atdRegularizedDate;

    @track showApproveReject = false;
    @track isManager = false;
    userId = Id;
    @track managerCmt = '';

    isChechInChanges = false;
    firstcheckIn;

    isChechOutChanges = false;
    firstcheckOut;

    /*@wire(attendenceTimerData, { atdId: '$recordId', userId: '$userId' })
    wiredResult({ values }) {
        this.allWiredResult = values;
        const { data, error } = values;
        if (data){
            this.atdResult = data;
            console.log('testdata::'+JSON.stringify(this.atdResult));

        }else if (error) {
            console.log('error:::' + error);
        }
    }*/

    connectedCallback() {

        const url = window.location.href;
        const regex = /\/attendance\/([^\/]+)\//;
        const match = url.match(regex);
        if (match && match.length > 1) {
            this.recordId = match[1];
        } else {
            this.recordId = null;
        }
        this.updateHeader();
    }

    updateHeader() {
        getNameDetails({ atdId: this.recordId })
            .then(result => {
                this.atdName = result;
                if (this.atdName.Employee__r.ReportingTo__r.SF_User__c === this.userId && this.atdName.Regularization_Status__c === 'Waiting For Approval') {
                    this.isManager = true;
                }
            }).catch(error => {
                console.log('error:::' + JSON.stringify(error));
            })
    }

    handleRegularizeClick() {

        this.getRecordDetails();
    }

    getRecordDetails() {
        recordDetails({ atdId: this.recordId, userId: this.userId })
            .then(result => {

                if (result === null) {
                    this.toastEventFire('You Dont Have Access On Record', 'You Dont Have Access On Record You Can Only View', 'Error');
                    return;
                }if(result.Status_Of_Day__c === 'On Leave' || result.Status_Of_Day__c === 'Public Holiday' ){
                    this.toastEventFire('Cannot Regularize', 'You Cannot Regularize Leave or Public Holiday Attendence', 'Error');
                    return;
                }
                if (result.Regularization_Status__c === 'Approved' || result.Regularization_Status__c === 'Waiting For Approval') {
                    this.toastEventFire('Sorry this attendence is already regularized', 'Please contact the admin', 'Error');
                    return;
                } else {
                    this.isShowModal = true;
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

    handleApproveManager() {
        this.isShowModal = undefined;
        this.showApproveReject = true;
    }

    hideModalApprove() {
        this.isShowModal = false;
        this.showApproveReject = false;
    }

    handleManagerCmt(event) {
        this.managerCmt = event.target.value;
    }

    handleSubmitApproved(event) {
        console.log('event.target.name:::' + event.target.name);
        approveRejectCtrl({ recId: this.recordId, Status: event.target.name, managerComment: this.managerCmt })
            .then(result => {
                if (result === 'successApproved') {
                    this.toastEventFire('Approved Successfully!!!', 'Regularized Successfully', 'Success');
                    this.isManager = false;
                    //window.open(window.location.href, "_self");
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.recordId,
                            objectApiName: 'Attendance__c', // objectApiName is optional
                            actionName: 'view'
                        }
                    });

                    return;
                } else if (result === 'successRejected') {
                    this.toastEventFire('Rejected Successfully!!!', 'Rejected Successfully', 'Success');
                    this.isManager = false;
                    //window.open(window.location.href, "_self");
                    this[NavigationMixin.Navigate]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: this.recordId,
                            objectApiName: 'Attendance__c', // objectApiName is optional
                            actionName: 'view'
                        }
                    });
                    return;
                } else {
                    this.toastEventFire('OOPS Failed to Apporve/Reject', 'OOPS Failed to Apporve/Reject', 'Error');
                    return;
                }
            }).catch(error => {
                console.log('error::' + JSON.stringify(error));
                this.toastEventFire('OOPS Failed to Apporve/Reject', 'OOPS Failed to Apporve/Reject', 'Error');
                return;
            });
    }

    handleReasonChange(event) {
        this.empReason = event.target.value;
    }


    timeDetails(data) {
        const date = new Date(data);
        const timeString = date.toISOString().substr(11, 12);
        const options = {
            hour: 'numeric',
            minute: 'numeric',
            second: 'numeric',
            hour12: false, // Use 24-hour format
        };
        return date.toLocaleString(undefined, options);;
    }

    hideModalBox() {
        this.isShowModal = false;
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
    updateDuration() {
        if (this.checkIn !== undefined && this.checkOut !== undefined && (this.atdResult.Date__c !== undefined || this.atdRegularizedDate !== undefined)) {
            const loginCheckIn = new Date((this.atdResult.Date__c === undefined ? this.atdRegularizedDate : this.atdResult.Date__c) + ' ' + this.checkIn);
            const loginCheckOut = new Date((this.atdResult.Date__c === undefined ? this.atdRegularizedDate : this.atdResult.Date__c) + ' ' + this.checkOut);
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

    timeConvert(min) {
        var num = min;
        var hours = (num / 60);
        var rhours = Math.floor(hours);
        var minutes = (hours - rhours) * 60;
        var rminutes = Math.round(minutes);
        return ((rhours.toString().length === 1 ? '0' + rhours : rhours) + ':' + (rminutes.toString().length === 1 ? '0' + rminutes : rminutes));
    }

    handleEmpComment(event) {
        this.empCommnets = event.target.value;
    }

    beforehandleSubmit() {
        if (parseInt(this.duration.substring(0, 2)) < 9) {
            this.showWarningMessage = true;
            this.isShowModal = undefined;
        } else {
            this.handleSubmit();
        }
    }

    hideModalBoxWarning() {
        this.showWarningMessage = false;
        this.isShowModal = true;
    }

    handleSubmit() {
        if (this.showWarningMessage === true) {
            this.showWarningMessage = false;
            this.isShowModal = true;
        }

        if (this.checkIn === undefined || this.checkOut === undefined) {
            this.toastEventFire('Please Check the dates', 'Please set check in and check out to time to regularize', 'Error');
            return;
        }

        if (this.empReason === undefined) {
            this.toastEventFire('Please select the reason', 'Please select the reason', 'Error');
            return;
        }

        if (this.empCommnets === undefined || this.empCommnets === '') {
            this.toastEventFire('Please enter comments', 'Please enter comments', 'Error');
            return;
        }

        /*if (this.overrideNewButton === true) {
            this.handleSubmitNew();
            return;
        }*/

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
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: this.recordId,
                        objectApiName: 'Attendance__c', // objectApiName is optional
                        actionName: 'view'
                    }
                });
                //this.isShowModal = false;
            }).catch(error => {
                console.log('error:::' + JSON.stringify(error));
                this.toastEventFire('Failed to regularize the record', 'Opps Failed to regularixe the record please contact admin', 'Error');
            });

    }

    handleDateCtrl(event) {
        this.atdRegularizedDate = event.target.value;
        this.updateDuration();
        console.log('atdRegularizedDate:::' + this.atdRegularizedDate);
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
}