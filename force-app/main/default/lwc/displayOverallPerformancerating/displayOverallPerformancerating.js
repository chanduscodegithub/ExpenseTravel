import { LightningElement,api,track } from 'lwc';
export default class DisplayOverallPerformancerating extends LightningElement {
    @api pmsData;
    @api totalManagerScore;
    @api reviewerRating;
    @track showreviewer;
    @api selectedQuater;
    connectedCallback() {
        //console.log('~~this.selectedQuater : ',this.selectedQuater);
        this.showreviewer=((this.reviewerRating!=0 && this.selectedQuater=='Annual Cycle')?true:false);
        this.showfinal=((this.totalManagerScore!=0 && this.selectedQuater=='Annual Cycle')?true:false);
        //console.log('~~pmsData : ',this.pmsData);
    }

}