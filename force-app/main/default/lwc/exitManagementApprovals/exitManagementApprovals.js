import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getErrorBody } from './utils';
import approverActions from '@salesforce/apex/ExitManagementController.approverActions';

export default class ExitManagementApprovals extends LightningElement {
    spinnerFlag = true;
    loaded = false;
    _resignation;
    isCommentsModalOpen = false;
    modalBtnName = '';

    @api empData;
    @api isHR;

    get isHRFlag() {
        if (this.isHR === 'Yes') {
            return true;
        }
        return false;
    }

    @api set resignation(value) {
        this._resignation = value;
        console.log(JSON.stringify(this.empData));
        console.log(JSON.stringify(this.isHR));
        this.spinnerFlag = false;
        this.loaded = true;
    }

    get resignation() {
        return this._resignation;
    }

    get disableApproveBtn() {
        console.log('**INSIDE DISABLE APPR/REJECT BUTTON**');
        console.log('If HR?: ',this.isHR);
        console.log('Status: ',this.resignation?.Resignation_Status__c);
        console.log('Reporting Manager Id: ',this.resignation?.Reporting_Manager__c);
        console.log('Curr User Id: ',this.empData.SF_User__c);
        console.log('Is Manager?: ',this.resignation?.Reporting_Manager__c === this.empData.SF_User__c);
        console.log('Is CCM?: ',this.resignation?.CCM__c === this.empData.SF_User__c);
        if (this.resignation?.Resignation_Status__c === 'Approved By CCM' && this.isHR === 'Yes') {
            return false;
        }
        if (this.isHR === 'No' && this.resignation?.Resignation_Status__c === 'Applied' && this.resignation?.Reporting_Manager__c === this.empData.SF_User__c) {
            return false;
        }
        if (this.isHR === 'No' && (this.resignation?.Resignation_Status__c === 'Approved by Reporting Manager' || this.resignation?.Resignation_Status__c === 'Applied') && this.resignation?.CCM__c === this.empData.SF_User__c) {
            return false
        }
        return true;
    }

    get disableRejectBtn() {
        if (this.resignation?.Resignation_Status__c === 'Approved By CCM' && this.isHR === 'Yes') {
            return false;
        }
        if (this.isHR === 'No' && this.resignation?.Resignation_Status__c === 'Applied' && this.resignation?.Reporting_Manager__c === this.empData.SF_User__c) {
            return false;
        }
        if (this.isHR === 'No' && (this.resignation?.Resignation_Status__c === 'Approved by Reporting Manager' || this.resignation?.Resignation_Status__c === 'Applied') && this.resignation?.CCM__c === this.empData.SF_User__c) {
            return false
        }
        return true;
    }

    get withdrawalDetails() {
        if (this.resignation?.Resignation_Status__c === 'Withdrawn') {
            return {
                withdrawn: true,
                Reason_for_Pullback__c: this.resignation?.Reason_for_Pullback__c
            }
        }
        return {
            withdrawn: false,
            Reason_for_Pullback__c: ''
        }
    }

    handleApprove() {
        this.modalBtnName = 'Approve';
        this.isCommentsModalOpen = true;
    }

    handleReject() {
        this.modalBtnName = 'Reject';
        this.isCommentsModalOpen = true;
    }


    async handleApproverAction(e) {
        let comment = this.template.querySelector('lightning-input[data-type="comment"]');
        let relievingdate = this.template.querySelector('lightning-input[data-type="relieving"]');
        let relation = '';
        if (this.isHR === 'Yes') {
            relation = 'HR';
        } else if (this.isHR === 'No' && this.resignation?.Reporting_Manager__c === this.empData.SF_User__c) {
            relation = 'Manager';
        } else if (this.isHR === 'No' && this.resignation?.CCM__c === this.empData.SF_User__c) {
            relation = 'CCM';
        }
        if (this.isHR === 'No' && (comment?.value == null || comment?.value?.trim() === '' )) {
            return this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please fill in your Comments.',
                    variant: 'error'
                })
            )
        }
        if(this.isHR === 'Yes' && (relievingdate?.value == null || relievingdate?.value?.trim() === '')){
            return this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please fill in the Final Relieving Date.',
                    variant: 'error'
                })
            )
        }
        try {
            if(this.isHR === 'Yes'){
                await approverActions({ actionBtnLabel: this.modalBtnName, recId: this.resignation.Id, comment: '', relation, resignEmp: this.resignation.Employee_Name__c, relievingString: relievingdate.value });
            }else{
                await approverActions({ actionBtnLabel: this.modalBtnName, recId: this.resignation.Id, comment: comment.value, relation, resignEmp: this.resignation.Employee_Name__c, relievingString: '' });
            }
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Record updated successfully',
                    variant: 'success'
                })
            )
        } catch (error) {
            this.loaded = true;
            this.dispatchEvent(new ShowToastEvent(getErrorBody(error, 'sticky')));
        }
        
    }
    handleCloseModal() {
        this.isCommentsModalOpen = !this.isCommentsModalOpen;
    }
    handleCloseCard() {
        const event = new CustomEvent("closedetail", {
            detail: { close: true }
        });
        this.dispatchEvent(event);
    }
}