import { LightningElement,api } from 'lwc';
import approveRecord from '@salesforce/apex/Expenseclaimclass.approveRecord';
import rejectRecord from '@salesforce/apex/Expenseclaimclass.rejectRecord';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class ExpenseDetails extends LightningElement {
 @api showDetailsSection;
    @api category;
    @api department;
    @api employeeName;
    @api totalBillAmount;
    @api expenseDate;
    @api currency;
    @api employeeComments;
    @api bills;
    @api itemlist;
    @api workitemid;
    @api showbuttons;
    selectedWorkItemId;
    showcomments;
    headername;
    confirmsubmit=false;
    comments;
    
    connectedCallback() {
        this.selectedWorkItemId=this.workitemid;
        console.log(this.workitemid);
   
       console.log('expenseDate',this.expenseDate);
       console.log('itemlist',JSON.stringify(this.itemlist));
       console.log('showbuttons',this.showbuttons);
    }

    handleClose() {
        // Dispatch the 'closedetail' event to notify the parent
        const closeEvent = new CustomEvent('closedetail');
        this.dispatchEvent(closeEvent);
    }

       handleApprove() {
        this.showcomments=true;
        this.headername='Approver';
        if (this.selectedWorkItemId) {
            if(this.confirmsubmit)
            {
            approveRecord({ workItemId: this.selectedWorkItemId,comments:this.comments })
                .then(() => this.showToast('Success', 'Record approved!', 'success'))
                .catch(error => this.showToast('Error', error.body.message, 'error'));
        }
        }
    }

    handleReject() {
          this.showcomments=true;
           this.headername='Rejected';
             if(this.confirmsubmit){
        if (this.selectedWorkItemId) {
            rejectRecord({ workItemId: this.selectedWorkItemId,comments: this.comments })
                .then(() => this.showToast('Success', 'Record rejected!', 'success'))
                .catch(error => this.showToast('Error', error.body.message, 'error'));
        }
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
    hideModalBox()
    {
        this.showcomments=false;
    }
    onsubmit()
    {
        this.confirmsubmit=true;
    }
    handlechange(event)
    {
        this.comments=event.target.value;
    }
}