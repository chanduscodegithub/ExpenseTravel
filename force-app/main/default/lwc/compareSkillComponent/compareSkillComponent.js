import { LightningElement, api, wire, track } from 'lwc';
import getUnMatchedEmployeeSkillSet from '@salesforce/apex/CompareSkillController.getUnMatchedEmployeeSkillSet';
export default class CompareSkillComponent extends LightningElement {
    //@track certificationData;

    @api recordId;
    @api cardIcon="custom:custom15";
    @api cardTitle="Required Skills";
    error;
    requiredCertificationList=[];
    infoMessage;
    @track certificationData ={
        requiredCertificationList : [],
        infoCertificationMessage : '',
        requiredSkillsList : [],
        infoSkillMessage : '',
        infoTrailblazerRankMessage:''
    }
        


    @track activeSectionMessage = '';

    handleToggleSection(event) {
        this.activeSectionMessage =
            'Open section name:  ' + event.detail.openSections;
    }

    connectedCallback(){
        this.fetchConfigData(); 
    }

    fetchConfigData(){
        getUnMatchedEmployeeSkillSet({employeeId:this.recordId }).then(result => {
            console.log(result)
            this.certificationData = result;
            console.log(JSON.stringify(this.certificationData));
            this.error = undefined;
        })
        .catch(error => {
            console.log('Now Started...calling...ERROR' + error);
            this.error = error;
        })
    }

}