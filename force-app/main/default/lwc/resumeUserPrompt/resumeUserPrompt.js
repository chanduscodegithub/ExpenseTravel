import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import userPrompt from '@salesforce/apex/PdfParser.userPrompt';
export default class ResumeUserPrompt extends LightningElement {
    @api recordId;
    @api insightRecord;
    @track prompt;
    @track promptResponse;
    @track spinnerStatus=false;

    get displayResponse()
    {
        if(!this.spinnerStatus && this.promptResponse!=undefined && this.promptResponse!=null && this.promptResponse!='')
            return true;
        else
            return false;
    }
    handleChange(event)
    {
        this.prompt=event.target.value;
    }

    handleClose()
    {
        const closeAction = new CustomEvent('close', {
            detail:{} 
        });
        this.dispatchEvent(closeAction);
    }
    handleAsk()
    {
        this.spinnerStatus=true;
        userPrompt({promptMessage:this.prompt,recordId:this.recordId,insightRecordId:this.insightRecord.Id})
        .then(res=>{
            console.log('Response-'+res);
            this.promptResponse=res;
            this.spinnerStatus=false;
        })
        .catch(error=>{
            console.log('Error-'+JSON.stringify(error));
            this.dispatchEvent(new ShowToastEvent({
                title: error.body.message,
                message: '',
                variant: 'error',
                mode: 'dismissable'
            }), );
            this.spinnerStatus=false;
        })
    }

}