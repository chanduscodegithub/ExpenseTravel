import { LightningElement,api,wire } from 'lwc';
import findProject from '@salesforce/apex/TeamAllocationController.findProject';

export default class TeamAllocationProjectDetailComponent extends LightningElement {
    @api recordId;
    @api projectrecordid;
    @api projectobjectApiName;
    error;

    connectedCallback(){
        this.fetchConfigData();
    }

    fetchConfigData(){
        findProject({teamAllocationRecordId:this.recordId }).then(result => {
            this.projectrecordid = result.id;
            this.projectobjectApiName = 'Project__c';
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
        })
    }
    

}