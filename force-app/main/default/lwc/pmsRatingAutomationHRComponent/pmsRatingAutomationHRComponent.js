import { LightningElement } from 'lwc';
import KPIAutomationMethod from '@salesforce/apex/PMSKPIRatingAutomationController.KPIAutomationMethod';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PmsRatingAutomationHRComponent extends LightningElement {

    handleAutomate(){
        KPIAutomationMethod()
        .then(result=>{
            this.toastMsg('Success', 'Ratings are defaulting to 2.5', 'Success') 
        }).catch(error=>{
            this.toastMsg('Error', 'Error Automating to default', 'Error') 
        })
    }

    toastMsg(title, msg, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: msg,
                variant: variant,
            }),
        );
    }

}