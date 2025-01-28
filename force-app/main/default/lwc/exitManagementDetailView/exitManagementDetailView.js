import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import pullbackResignation from '@salesforce/apex/ExitManagementController.pullbackResignation';

export default class ExitManagementDetailView extends LightningElement {
    _resignation;
    loaded = false;
    disablePullbackBtn = false;
    isSubmitDisabled = true;
    isPullbackOpen = false;
    spinnerFlag = false;
    fields;
    upsertData;

    @api empData;
    @api set resignation(value) {
        this._resignation = value;
        this.loaded = true;
        if (this.resignation.Resignation_Status__c === 'Approved By HR' || this.resignation.Resignation_Status__c === 'Withdrawn') {
            this.disablePullbackBtn = true;
        }
    }

    get resignation() {
        return this._resignation;
    }

    get conditionalDetails() {
        if (this.upsertData?.Resignation_Status__c === 'Withdrawn') {
            return {
                withdrawn: true,
                Reason_for_Pullback__c: this.upsertData?.Reason_for_Pullback__c
            }
        } else if (this.resignation?.Resignation_Status__c === 'Withdrawn') {
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

    handleCloseCard() {
        const event = new CustomEvent("closedetail", {
            detail: { close: true }
        });
        this.dispatchEvent(event);
    }

    handlePullbackModal() {
        this.isPullbackOpen = !this.isPullbackOpen;
    }

    handleCheckChange(event) {
        this.isSubmitDisabled = !event.target.checked;
    }

    fields = [
        { req: true, name: 'Reason_for_Pullback__c', readonly: false }
        // {req: true, name: 'I_Confirm__c', readonly: false}
    ];

    async handleSubmit(event) {
        //console.log('entered submit');
        event.preventDefault();
        const inputReason = this.template.querySelector('lightning-input-field');
        let reason = inputReason.value;
        if (reason == null || reason?.trim() === '') {
            return this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please fill your reason to pullback.',
                    variant: 'error'
                })
            )
        }

        try {
            this.spinnerFlag = true;
            this.isPullbackOpen = false;
            this.upsertData = await pullbackResignation({ recId: this.resignation.Id, pullbackReason: reason, empId: this.empData.Id });
            this.disablePullbackBtn = true;
            this.dispatchEvent(new CustomEvent('changestatus', {
                detail: this.upsertData
            }));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Your Resignation Pullback Request was submitted successfully',
                    variant: 'success'
                })
            )
            this.spinnerFlag = false;
        } catch (error) {
            this.spinnerFlag = false;
            console.log(error);
            console.log(error?.body?.message);
            console.log(error?.message);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error while initiating Pullback.',
                    variant: 'error'
                })
            )

        }
    }
}