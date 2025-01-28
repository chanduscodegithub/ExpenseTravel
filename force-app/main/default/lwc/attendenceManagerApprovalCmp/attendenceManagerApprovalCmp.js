import { LightningElement, track, wire } from 'lwc';
import getWfaDetails from "@salesforce/apex/AttendenceManagerApprovalCmpCtrl.getWfaDetails";
import getApprovalDetails from "@salesforce/apex/AttendenceManagerApprovalCmpCtrl.getApprovalDetails";
import getRejectedDetails from "@salesforce/apex/AttendenceManagerApprovalCmpCtrl.getRejectedDetails";
import insertActivityDetails from "@salesforce/apex/AttendenceManagerApprovalCmpCtrl.createTimeSheetActivity";
import rejectTimeSheetActivity from "@salesforce/apex/AttendenceManagerApprovalCmpCtrl.rejectTimeSheetActivity";
import { getWfaColoum, getAppdColoum, getRejectedColoum } from "./myColoumResult";
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class AttendenceManagerApprovalCmp extends NavigationMixin(LightningElement) {

    @track wfaColumn = getWfaColoum();
    @track appdColumn = getAppdColoum();
    @track rejectesColumn = getRejectedColoum();
    //@track appdColoum = getAprColoum;


    allWiredResultWfa;
    allWiredResultRejected;
    allWiredResultAppd;
    @track wfaEmpResults = [];
    @track apprEmpResults = [];
    @track rejectedDetails = [];
    @track managerComments;

    @track buttonLable = '';
    @track sortBy;
    @track sortDirection;

    @track isShowModal = false;
    @track isShowModalParent = false;


    timeSheetActivity = [];

    connectedCallback() {
        //console.log('Enter::');
    }


    @wire(getWfaDetails)
    wiredResultWrapperWfa(values) {

        this.allWiredResultWfa = values;
        //console.log('testData::' + JSON.stringify(values));
        const { data, error } = values;
        if (data) {
            //console.log('test::' + JSON.stringify(data));
            this.wfaEmpResults = data;
        } else if (error) {
            //console.log('error::' + JSON.stringify(error));
        }
    }

    @wire(getRejectedDetails)
    wiredResultWrapperRejected(values) {

        this.allWiredResultRejected = values;
        //console.log('values::' + JSON.stringify(values));
        const { data, error } = values;
        if (data) {
            //console.log('data::' + JSON.stringify(data));
            this.rejectedDetails = data;
        } else if (error) {
            console.log('error::' + error);
        }
    }

    @wire(getApprovalDetails)
    wiredResultWrapperAppd(values) {
        this.allWiredResultAppd = values;
        //console.log('values::' + JSON.stringify(values));
        const { data, error } = values;
        if (data) {
            //console.log('data::' + JSON.stringify(data));
            this.apprEmpResults = data;
        } else if (error) {
            //console.log('error::' + JSON.stringify(error));
        }
    }
    hideModalBoxParent(){
        this.isShowModalParent = false;
    }

    handleRegularizationCall(){
        this.isShowModalParent = true;
    }

    handleManagerCmt(event) {
        this.managerComments = event.target.value;
    }

    showPopUp(event) {
        //console.log(event.target.name);
        if (event.target.name === 'approve') {
            this.buttonLable = 'Approve';
            this.isShowModal = true;
        } else if (event.target.name === 'reject') {
            this.buttonLable = 'Reject';
            this.isShowModal = true;
        }
    }

    approveOrReject() {
        //console.log('selectedRecords::' + this.buttonLable);
        if (this.buttonLable === 'Approve') {
            this.saveHander();
            this.isShowModal = false;
        } else if (this.buttonLable === 'Reject') {
            this.reject();
            this.isShowModal = false;
        }
    }

    saveHander() {
        this.timeSheetActivity = [];
        var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        //console.log('selectedRecords::' + JSON.stringify(selectedRecords));
        if (selectedRecords.length === 0) {
            this.toastEventFire('Please select record to approve', '', 'error');
            return;
        } else { 
            selectedRecords.forEach(currentItem => {
                if (currentItem.checkInOld !== currentItem.checkInNew) {
                    const timeSheetActivity = {
                        Action_Type__c: 'Check In',
                        Mode__c: 'Regularized',
                        Action_Time__c: this.timeZoneDetails(currentItem.checkInNew),
                        Attendance__c: currentItem.atdId
                    }
                    this.timeSheetActivity.push(timeSheetActivity);

                } if (currentItem.checkOutOld !== currentItem.checkOutNew) {
                    console.log('checkOutNew::' + currentItem.checkOutNew);
                    const timeSheetActivity = {
                        Action_Type__c: 'Check Out',
                        Mode__c: 'Regularized',
                        Action_Time__c: this.timeZoneDetails(currentItem.checkOutNew),
                        Attendance__c: currentItem.atdId
                    }
                    this.timeSheetActivity.push(timeSheetActivity);
                }
            });
        }
        //console.log('timeSheetActivity::' + JSON.stringify(this.timeSheetActivity));

        insertActivityDetails({ data: JSON.stringify(this.timeSheetActivity), managerComment: this.managerComments !== undefined ? this.managerComments : null })
            .then(result => {
                //console.log('result::' + JSON.stringify(result));
                this.timeSheetActivity = [];
                refreshApex(this.allWiredResultWfa);
                refreshApex(this.allWiredResultAppd);
                refreshApex(this.allWiredResultRejected);

                this.toastEventFire('Success!!!', 'Successfully Approved the regularization', 'success');

            }).catch(error => {
                this.toastEventFire('Opps Failed!!!', 'Failed Approved the regularization Please contact admin', 'error');
                console.log('error::' + JSON.stringify(error));
            });
    }

    reject() {
        this.timeSheetActivity = [];
        var selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        //console.log('selectedRecords::' + JSON.stringify(selectedRecords));
        if (selectedRecords.length === 0) {
            this.toastEventFire('Please select record to reject', '', 'error');
        } else {
            selectedRecords.forEach(currentItem => {
                const selectedRecords = {
                    id: currentItem.atdId,
                    Regularization_Status__c: 'Rejected'
                }
                if (this.managerComments !== undefined) {
                    selectedRecords.Manager_Comment__c = this.managerComments;
                }
                this.timeSheetActivity.push(selectedRecords);
            });
            //console.log('result::' + JSON.stringify(this.timeSheetActivity));

            rejectTimeSheetActivity({ data: JSON.stringify(this.timeSheetActivity) })
                .then(result => {

                    //console.log('result::' + JSON.stringify(result));
                    this.timeSheetActivity = [];
                    refreshApex(this.allWiredResultWfa);
                    refreshApex(this.allWiredResultAppd);
                    refreshApex(this.allWiredResultRejected);

                    this.toastEventFire('Success!!!', 'Successfully Rejected the regularization', 'success');

                }).catch(error => {
                    this.toastEventFire('Opps Failed!!!', 'Failed to Reject the regularization Please contact admin', 'error');
                    console.log('error::' + JSON.stringify(error));
                });
        }

    }

    navigateToListView() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Attendance__c',
                actionName: 'list'
            },
            state: {
                filterName: 'default'
            }
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

    timeZoneDetails(data) {
        const timestamp = new Date(data);

        let hours = timestamp.getHours();
        const minutes = timestamp.getMinutes();
        const seconds = timestamp.getSeconds();

        hours = (hours < 10 ? '0' : '') + (hours % 24);

        const formattedDate = `${hours}:${minutes < 10 ? '0' : ''}${minutes}:${seconds < 10 ? '0' : ''}${seconds}.000Z`;
        return formattedDate;
        
    }

    /*Back UP 
    console.log('data:::'+data);
        const timestamp = data;

        const date = new Date(timestamp);

        const formatter = new Intl.DateTimeFormat('en-US', {
            hour: '2-digit',
            minute: '2-digit',
            second: '2-digit',
            hour12: false
        });

        const localTime = formatter.format(date) + ".000Z";

        return localTime;*/

    hideModalBox() {
        this.isShowModal = false
    }


    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.wfaEmpResults));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.wfaEmpResults = parseData;
    }
}