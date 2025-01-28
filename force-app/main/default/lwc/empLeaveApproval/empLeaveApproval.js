import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { getRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';
//apex imports
import getUserInfo from '@salesforce/apex/EmailLeaveOrApprovalController.getUserInfo';
import approvalStep from '@salesforce/apex/EmailLeaveOrApprovalController.approvalStep';
import ApprovalProcessRecordsDelete from '@salesforce/apex/EmailLeaveOrApprovalController.ApprovalProcessRecordsDelete';

export default class EmpLeaveApproval extends LightningElement {
    _recordId;
    isManager = false;
    approvalMessage = '';
    rejectMessage = '';
    empLeaveData;
    leaveData;
    isButtonDisable = false;
    hrApprovalPending;
    RejectionMessage = '';
    currWorkItemId;
    isModalOpen = false;
    isRecordOwner = false;
    currentUserId;
    userId = USER_ID;

    get recordId() {
        return this._recordId;
    }
    @api set recordId(value) {
        this._recordId = value;
        console.log('this._recordId',this._recordId)
        getUserInfo({ recId: this._recordId })
            .then(data => {
                this.leaveData = data.empLeave;
                this.empLeaveData = data.empLeave.Name;
                console.log('this.currWorkItemId in getUserInfo>>>',this.currWorkItemId)
                this.currWorkItemId = data.currWorkItemId;
                console.log('this.currWorkItemId in getUserInfo>>>',this.currWorkItemId)
                if(data.empLeave.Leave_Type__c === 'Work from Home(WFH)'){
                    this.approvalMessage = 'Work From Request has been Approved Successfully!';
                    this.rejectMessage = 'Work From Request has been Rejected Successfully!';
                }
                else{
                    this.approvalMessage = 'Leave Application has been Approved Successfully!';
                    this.rejectMessage = 'Leave Application has been Rejected!'; 
                }
                if (data.currUserInfo.Profile.Name === 'Partner Community Login User_HR' && data.empLeave.Send_to_Manager__c === false && data.empLeave.Notify_HR__c === true) {
                    this.isManager = true;
                }
                else if (data.recRelationWrap === 'Manager' && data.empLeave.Send_to_Manager__c === true && data.empLeave.Notify_HR__c === false) {
                    this.isManager = true;
                }
                else if (data.recRelationWrap === 'Manager' && data.empLeave.Send_to_Manager__c === true && data.empLeave.Notify_HR__c === true) {
                    this.isManager = true;
                }
                else if (data.recRelationWrap === 'Manager' && data.empLeave.Send_to_Manager__c === false && data.empLeave.Notify_HR__c === true) {
                    this.hrApprovalPending = true;
                    this.isButtonDisable = true;
                }
                else {
                    this.isManager = false;
                }
            })
            .catch(err => {
                console.log(err.body.message);
            })
    }

    initRejection() {
        this.isModalOpen = !this.isModalOpen;
    }

    handleInput(e) {
        this.RejectionMessage = e.target.value;
    }
    @wire(CurrentPageReference) pageRef;


    //Cancelation : Record owner can cancel his leaves before reporting manager Approves/Rejects
    @wire(getRecord, { recordId: '$recordId', fields: ['Employee_Leave__c.OwnerId'] })
    wiredRecord({ data, error }) {
        if (data) {
            this.isRecordOwner = data.fields.OwnerId.value === this.userId;
            this.error = undefined; // Reset error
        } else if (error) {
            this.error = error;
            this.isRecordOwner = false; // Set isRecordOwner to false to prevent button rendering
            console.error('Error fetching record:', error);
        }
    }


        handleCancel(){
        console.log('ghukjnh',this._recordId);
        if (this._recordId) {
            console.log('record id>>>',this.recordId)
            console.log('record id>>>',this._recordId)
        ApprovalProcessRecordsDelete({recId: this._recordId})
        .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Cancelled!!',
                    message: 'Leave Application has been Cancelled successfully!',
                    variant: 'success'
                })
            );
            // eslint-disable-next-line @lwc/lwc/no-async-operation
          setTimeout(() => {
                window.location.reload();
            }, 1000);
       })
        .catch(err => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!!',
                    message: err.body.message,
                    variant: 'Error'
                })
            );
        })
    }
    } 

    handleRejection() {
        console.log('RejectionMessage', this.RejectionMessage);
        console.log('this.currWorkItemId>>>',this.currWorkItemId);
        approvalStep({ reqAction: 'Reject', reqComments: this.RejectionMessage, workItemId: this.currWorkItemId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Rejected!!',
                        message: this.rejectMessage,
                        variant: 'success'
                    })
                );
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {
                    window.location.reload();
                }, 1000);
            })
            .catch(err => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: err.body.message,
                        variant: 'Error'
                    })
                );
            })
    }

    handleApproval() {
        console.log('workitem id approval>>>',this.currWorkItemId)
        approvalStep({ reqAction: 'Approve', reqComments: 'Approved', workItemId: this.currWorkItemId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Approved!!',
                        message: this.approvalMessage,
                        variant: 'success'
                    })
                );
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {
                    window.location.reload();
                }, 1000);
            })
            .catch(err => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: err.body.message,
                        variant: 'Error'
                    })
                );
            })
    }
    handleRecall() {
        approvalStep({ reqAction: 'Removed', reqComments: 'Recalled', workItemId: this.currWorkItemId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Recalled!!',
                        message: 'Leave Application has been Recalled successfully!',
                        variant: 'success'
                    })
                );
                // eslint-disable-next-line @lwc/lwc/no-async-operation
                setTimeout(() => {
                    window.location.reload();
                }, 1000);
            })
            .catch(err => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error!!',
                        message: err.body.message,
                        variant: 'Error'
                    })
                );
            })
    }
}