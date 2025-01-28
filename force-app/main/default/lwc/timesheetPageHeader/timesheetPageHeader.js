import { LightningElement, api } from 'lwc';

//Apex
import getTimesheetDetails from '@salesforce/apex/timesheetPageHeaderController.getTimesheetDetails'

export default class TimesheetPageHeader extends LightningElement {
    _recordId;
    headerDetails = { Name: 'Loading' };
    spinnerFlag = true;
    isManager = false;

    get recordId() {
        return this._recordId;
    }
    @api set recordId(value) {
        this._recordId = value;

        getTimesheetDetails({ recID: this.recordId })
            .then(data => {
                //console.log(`RFA: ${JSON.stringify(data)}`);
                this.headerDetails = data.tsData;
                this.isManager = data.isManager;
                this.spinnerFlag = false;
            }).catch(err => {
                this.spinnerFlag = false;
                this.headerDetails.Name = 'Detail View';
                console.log(`Error Occured: ${JSON.stringify(err)}`);
            })
    }
    get btnLabel() {
        if (this.isManager) {
            return `View Timesheet`;
        }
        else if (this.headerDetails.Status__c == 'Approved' || this.headerDetails.Status__c == 'Submitted') {
            return `View Timesheet`;
        } else if ((this.headerDetails.Status__c == 'Draft' || this.headerDetails.Status__c == 'Rejected') && (!this.isManager)) {
            return `Edit Timesheet`;
        } else {
            return `View Timesheet`;
        }
    }
    redirectButton() {
        localStorage.removeItem('curRecId');
        if (this.recordId != null && this.recordId != undefined) {
            localStorage.setItem('curRecId', this.recordId);
        }
        let strURL = window.location.href;
        let locURL = strURL.split('CRMITCommunity/s/');
        let timesheetLink = `${locURL[0]}CRMITCommunity/s/timesheet`;
        window.location.href = timesheetLink;
    }
}