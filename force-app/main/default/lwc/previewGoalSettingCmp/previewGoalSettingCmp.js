import { LightningElement, api, track } from 'lwc';
export default class PreviewGoalSettingCmp extends LightningElement {

    @api allKRA;
    @api validate;
    @api empName;
    @api isCurrentUser;

    @track validateRMandCCM = false;

    connectedCallback() {
        if(this.validate === true && this.isCurrentUser !== ''){
            this.validateRMandCCM = true;
        }
    }

    hideModalBox() {
        this.dispatchEvent(new CustomEvent('hidemodalbox', {
            detail: {
                message: 'CloseTheHideBox'
            }
        }));
    }

    submitHandler() {
        this.dispatchEvent(new CustomEvent('hidemodalbox', {
            detail: {
                message: 'Submitomanager'
            }
        }));
    }
}