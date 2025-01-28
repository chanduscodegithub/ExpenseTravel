import { LightningElement, api } from 'lwc';
import approveRecord from '@salesforce/apex/Travelrequestclass.approveRecord';
import rejectRecord from '@salesforce/apex/Travelrequestclass.rejectRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class TravelDetails extends LightningElement {
    @api showDetailsSection;
    @api destination; 
    @api purposeofvisit;
    @api dateofdeparture;
    @api dateofreturn; 
    @api traveltype;
    @api modeoftransport;
    @api billedtocustomer;
    @api customer;
    @api department;
    @api description;
    @api currencu;
    @api requestedamount;
    @api existingcard;
    @api cardnumber;
    @api employee;

    @api bills;
    @api itemlist;
    @api workitemid;
    @api showbuttons;


    selectedWorkItemId;
    connectedCallback() {
        this.selectedWorkItemId = this.workitemid;
        console.log(this.workitemid);
        // console.log('bills',bills);

    }
    handleApprove() {
        if (this.selectedWorkItemId) {
            approveRecord({ workItemId: this.selectedWorkItemId })
                .then(() => this.showToast('Success', 'Record approved!', 'success'))
                .catch(error => this.showToast('Error', error.body.message, 'error'));
        }
    }

    handleReject() {
        if (this.selectedWorkItemId) {
            rejectRecord({ workItemId: this.selectedWorkItemId })
                .then(() => this.showToast('Success', 'Record rejected!', 'success'))
                .catch(error => this.showToast('Error', error.body.message, 'error'));
        }
    }
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
    handleCloseCard() {
        const event = new CustomEvent("closedetail", {
            detail: { close: true }
        });
        this.dispatchEvent(event);
    }
}