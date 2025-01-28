import { LightningElement,api,track,wire } from 'lwc';
import getInterviewDetails from '@salesforce/apex/CandidateFeedBackController.getInterviewDetails';
import getCandidatefeedBackDetails from '@salesforce/apex/CandidateFeedBackController.getCandidatefeedBackDetails';
import getLoggedInUserCreatedfeedBack from '@salesforce/apex/CandidateFeedBackController.getLoggedInUserCreatedfeedBack';
import createCandidatefeedBack from '@salesforce/apex/CandidateFeedBackController.createCandidatefeedBack';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Candidate_FeedBack__c from '@salesforce/schema/Candidate_FeedBack__c';

export default class CandidateFeedBackComponent extends LightningElement {
    @track interviewData = [];
    @track candidateFeedBackData = [];
    @track loggedInUserCreatedData = [];
    @track error;
    @track candidateStatusOptions;
    @api recordId;
    @track isDataPresent = false;
    @track addRowSection = false;
    @track assessmentValue;
    @track ratingValue;
    @track statusValue;
    @track checkboxVal = false;
    @track isShowModal = false;
    @track disableSave = true;
    @track isDataPresentForLogUser = false;
    @track isCandidateDataPresent = false;

    @wire(getObjectInfo, { objectApiName: Candidate_FeedBack__c })
    candFieldData;


    @wire(getPicklistValuesByRecordType ,

        {
            recordTypeId: '$candFieldData.data.defaultRecordTypeId',

            objectApiName: Candidate_FeedBack__c

            
        }

    )
    wiredpicklistbyRecordIdValues(sss){
        console.log('test 1');
        const {data,error}=sss;
        console.log('sss-'+JSON.stringify(sss));
        if(sss.data){
            this.candidateStatusOptions=data.picklistFieldValues.Status__c.values;
            console.log('candidateStatusOptions='+JSON.stringify(this.candidateStatusOptions))
        }
        else{
            this.error = error;
            console.log('error' + JSON.stringify(error));
        }
    }

    connectedCallback() {
        console.log('recordId>>>'+this.recordId)
        getInterviewDetails({ recordId : this.recordId })
            .then(result => {
                this.interviewData = result.map(interview => {
                    return {
                        ...interview,
                        InterviewUrl: `/lightning/r/${interview.Id}/view`
                    };
                });
                if(this.interviewData.length > 0){
                    this.isDataPresent = true;
                }
                console.log('this.interviewData>>>', JSON.stringify(this.interviewData));
            })
            .catch(error => {
                this.error = error;
                console.log('error>>>', JSON.stringify(this.error));
            });
        getCandidatefeedBackDetails({ recordId : this.recordId })
            .then(result => {
                this.candidateFeedBackData = result.map(candidate => {
                    return {
                        ...candidate,
                        InterviewUrl: `/lightning/r/${candidate.Id}/view`
                    };
                });
                if(this.candidateFeedBackData.length > 0){
                    this.isCandidateDataPresent = true;
                }
                console.log('this.candidateFeedBackData>>>', JSON.stringify(this.candidateFeedBackData));
            })
            .catch(error => {
                this.error = error;
                console.log('error>>>', JSON.stringify(this.error));
            });
        getLoggedInUserCreatedfeedBack({ recordId : this.recordId })
            .then(result => {
                this.loggedInUserCreatedData = result.map(candidate => {
                    return {
                        ...candidate,
                        InterviewUrl: `/lightning/r/${candidate.Id}/view`
                    };
                });
                if(this.loggedInUserCreatedData.length > 0){
                    this.isDataPresentForLogUser = true;
                }
                console.log('this.loggedInUserCreatedData>>>', JSON.stringify(this.loggedInUserCreatedData));
            })
            .catch(error => {
                this.error = error;
                console.log('error>>>', JSON.stringify(this.error));
            });
    }

    handleFeedBackChange(event){
        if(event.target.name == 'Status'){    
            this.statusValue = event.target.value;
            console.log('statusValue=='+JSON.stringify(this.statusValue));
        }
        if(event.target.name == 'Rating'){
            this.ratingValue = event.target.value;
        }
        if(event.target.name == 'Assessment'){
            this.assessmentValue = event.target.value;
        }
    }

    handleSectionToggle(event) {
        const openSections = event.detail.openSections;
    }

    addRow(){
        this.addRowSection = true;
        this.statusValue = '';
        this.ratingValue = '';
        this.assessmentValue = '';
    }

    handleCancel(){
        this.addRowSection = false;
    }

    openModalBox(){
        this.isShowModal = true;
    }
    handleAgreeCheck(event){
        this.checkboxVal = event.target.checked;
        if(this.checkboxVal == true){
            this.disableSave = false;
        }else{
            this.disableSave = true;
        }
    }

    hideModalBox(){
        this.isShowModal = false;
    }

    handleSave(){
        const candidatefeedBack = {
            Candidate : this.recordId,
            Status : this.statusValue,
            Rating : this.ratingValue,
            Assessment : this.assessmentValue
        }
        console.log('candidatefeedBack>>>>'+JSON.stringify(candidatefeedBack));
        createCandidatefeedBack({candWrapper : candidatefeedBack})
        .then(result => {
            alert(`Candidate Feedback created successfully: ${result}`);
            this.isShowModal = false;
            window.location.reload();
            console.log('result>>>', JSON.stringify(this.result));
        })
        .catch(error => {
                this.error = error;
                alert(`Error creating candidate: ${error.body.message}`);
                console.log('error>>>', JSON.stringify(this.error));
            });

    }
}