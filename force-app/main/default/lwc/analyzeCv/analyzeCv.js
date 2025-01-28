import { LightningElement,api,track } from 'lwc';
import parse from '@salesforce/apex/PdfParser.parse';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';

export default class AnalyzeCv extends NavigationMixin(LightningElement) {
    //@api recordId;
    @track resumeJson;
    @track relatedFiles;
    @track _recordId;
    @track spinnerFlag = true;
    @track showModal=false;
    @track selectedResume;

    get recordId() {
        return this._recordId;
    }
    @api set recordId(value) {
        (this._recordId = value),this.handleAnalyze();
    }

    handleAnalyze()
    {
        this.spinnerFlag=true;
        parse({recordId:this.recordId})
        .then((resumeException)=>{
            if(resumeException!=null && resumeException!=undefined)
            {
                const event = new CustomEvent('close', {
                    detail: {}
                });
                this.dispatchEvent(event);
                this.spinnerFlag=false;
                this.dispatchEvent(new ShowToastEvent({
                    title: resumeException.message,
                    message: '',
                    variant: 'error',
                    mode: 'dismissable'
                }), );
                setTimeout(() => {
                    window.location.reload();
                }, 1000); 
                return;
            }
            const event = new CustomEvent('close', {
                detail: {}
            });
            this.dispatchEvent(event);
            this.spinnerFlag=false;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Resume Analyzing process started. We will notify you once the process is complete.',
                message: '',
                variant: 'success',
                mode: 'dismissable'
            }), );

        })
        .catch(error=>{
            console.log('Error--'+JSON.stringify(error));
            const event = new CustomEvent('close', {
                detail: {}
            });
            this.dispatchEvent(event);
            this.spinnerFlag=false;
            this.dispatchEvent(new ShowToastEvent({
                title: error.body.message,
                message: '',
                variant: 'error',
                mode: 'dismissable'
            }), );
        })
    }
}