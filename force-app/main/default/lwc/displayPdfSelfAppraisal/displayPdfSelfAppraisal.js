import { LightningElement, api, track } from 'lwc';

export default class DisplayPdfSelfAppraisal extends LightningElement {

    @api allEmpDetails;
    @api totalscore;


    connectedCallback() {

        //alert(this.totalscore);
    }




}