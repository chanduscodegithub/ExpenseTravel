import { LightningElement, api } from 'lwc';
export default class DisplayPdfManagerappraisal extends LightningElement {
    @api pmsData;
    @api totalManagerScore;
    connectedCallback() {
        //console.log('~~totalManagerScore : ', this.totalManagerScore);
    }

}