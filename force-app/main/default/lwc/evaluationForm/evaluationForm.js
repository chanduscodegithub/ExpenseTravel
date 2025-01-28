import { LightningElement, wire, api, track } from 'lwc';
import getEvaluationData from '@salesforce/apex/EvaluationFormController.getEvaluationData';
import { CurrentPageReference } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getInterviewData from '@salesforce/apex/EvaluationFormController.getInterviewData';
import saveInformation from '@salesforce/apex/EvaluationFormController.saveInformation';
import scheduleInterview from '@salesforce/apex/ScheduleInterview.scheduleMeetInvite';

export default class EvaluationForm extends LightningElement {

    @api recordId;
    instruction;
    fiveStar;
    fourStar;
    threeStar;
    twoStar;
    oneStar;
    isFaceToFace = false;
    isVideoCall = false;
    isTelephonic = false;
    isReject = false;
    isRecommendInterview = false;
    isHire = false;
    isOpenFeedbackForm = false;
    @track isDigitalServices = false;
    @track isDigitalMarketing = false;
    @track showSpinner = false;
    @track showHeaderSpinner = true;
    @track isSubmitted = false;
    @track interviewDetails;
    @track interviewAutoNumber;
    @track listOfRating = [];
    @track modeOfInterview;
    @track EvaluationBtnLabel = 'Evaluation Form';
    @track InterviewBtnLabel= 'Schedule Interview';
    @track showComments = true;
    @track firstCommentText = 'People Capability (Please comment on the candidates People Capability)';
    @track secondCommentText = 'Process Maturity (Please comment on the candidates understanding of processes)';
    @track thirdCommentText = 'Project Knowledge & Domain Expertise (Please comment on the candidate’s project/domain knowledge)';
    @track fourthCommentText = 'Attitude ( Please comment on the candidate’s general attitude to work and to life)';
    @track interviewData = {
        'modeOfInterview': '', 'peopleCapability': '', 'processMaturity': '',
        'projectKnowledge': '', 'Attitude': '', 'Comments': '', 'hireSelected': '',
        'recommendInterview': '', 'isRejected': '', 'recommendPosition': ''
    }
    @track firstModeOfInterview = 'Face to Face';
    @track secondModeOfInterview = 'Video Call / Virtual';
    @track thirdModeOfInterview = 'Telephonic';
    @track showVideoCall = true;
    @track checkRole = true;

    activeSessions = ['Rating Details', 'Overall Comments', 'Recommendation'];

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        if (currentPageReference) {
            // console.log('currentPageReference::'+JSON.stringify(currentPageReference));
            this.recordId = currentPageReference.attributes.recordId;
            // console.log('recordId::'+this.recordId);
            if (this.recordId) {
                this.fetchInterviewDetails();
            }
        }
    }

    @wire(getEvaluationData)
    wiredData({ data, error }) {
        if (data) {
            this.instruction = data.Instruction__c;
            this.fiveStar = data.X5_Star__c;
            this.fourStar = data.X4_Star__c;
            this.threeStar = data.X3_Star__c;
            this.twoStar = data.X2_Star__c;
            this.oneStar = data.X1_Star__c;

            if (this.showComments == false) {
                this.fiveStar = 'Outstanding – Exceptional standards';
                this.fourStar = 'Excellent-exceeds ( SME) or Advanced Level, meets all against the position';
                this.twoStar = 'Below Average—Does not meet the Hiring requirements';
            }
        } else if (error) {
            console.log('error in evaluation form::' + error);
        }
    }

    fetchInterviewDetails() {
        getInterviewData({
            interviewRecordId: this.recordId
        })
            .then(result => {
                // console.log('result::'+JSON.stringify(result));
                this.showHeaderSpinner = false;
                this.interviewDetails = result;
                this.interviewAutoNumber = this.interviewDetails.name;
                this.isSubmitted = this.interviewDetails.isFeedbackSubmitted;

                if(this.interviewDetails.role === 'Others'){
                    this.checkRole = true;
                }else if (this.interviewDetails.role !== undefined) {
                    this.checkRole = false;
                }

                if (this.interviewDetails.role == 'Quality Consultant') {
                    this.secondModeOfInterview = 'Video Call';
                } else if (this.interviewDetails.role == 'HR Director') {
                    this.showComments = false;
                    this.showVideoCall = false;
                    this.firstCommentText = 'People Capability (Please comment on the candidate’s ability liaise with stakeholders)';
                    this.thirdCommentText = 'Overall Domain Expertise (Please comment on the candidates understanding of processes involved)';

                } else if (this.interviewDetails.role == 'Business Development Manager – Digital Services') {
                    this.isDigitalServices = true;
                    this.secondModeOfInterview = 'Video Call';
                    this.firstCommentText = 'People/Team Management Skills (Understanding of candidate’s ability manage with internal and external stakeholders)';
                    this.secondCommentText = 'Ability to build pipeline and manage key accounts effectively';
                    this.thirdCommentText = 'Ability to understand B2B and B2C markets in Salesforce ecosystem';
                    this.fourthCommentText = 'Professional Attitude (Please comment on the candidate’s general attitude to this role, work and life)';

                } else if (this.interviewDetails.role == 'Digital Marketing Manager') {
                    this.showVideoCall = false;
                    this.isDigitalMarketing = true;
                    this.firstCommentText = 'People Capability (Please comment on the candidate’s ability liaise with stakeholders)';
                    this.secondCommentText = 'Ability towards original/required content creations and all relevant communications';
                    this.thirdCommentText = 'Overall Domain Expertise (Please comment on the candidates understanding of processes involved)';

                } else if (this.interviewDetails.role == 'SF Business Analyst/Business Consultant') {
                    this.secondModeOfInterview = 'Video Call';
                }

                if (this.isSubmitted) {
                    this.EvaluationBtnLabel = 'Evaluation Submitted';

                    if (this.interviewDetails.modeOfInterview != undefined) {
                        if (this.interviewDetails.modeOfInterview == 'Face to Face') {
                            this.isFaceToFace = true;
                        } else if (this.interviewDetails.modeOfInterview == 'Video Call / Virtual') {
                            this.isVideoCall = true;
                        } else if (this.interviewDetails.modeOfInterview == 'Telephonic') {
                            this.isTelephonic = true;
                        }
                    }

                    this.isHire = this.interviewDetails.hireSelected;
                    this.isRecommendInterview = this.interviewDetails.recommendInterview;
                    this.isReject = this.interviewDetails.isRejected;
                    this.interviewData.recommendPosition = this.interviewDetails.recommendPosition;
                    this.interviewData.peopleCapability = this.interviewDetails.peopleCapability;
                    this.interviewData.processMaturity = this.interviewDetails.processMaturity;
                    this.interviewData.projectKnowledge = this.interviewDetails.projectKnowledge;
                    this.interviewData.Attitude = this.interviewDetails.Attitude;
                    this.interviewData.Comments = this.interviewDetails.Comments;
                }
            })
            .catch(error => {
                this.showHeaderSpinner = false;
                console.log('error::' + JSON.stringify(error));
            });
    }

    handleCheckbox(event) {
        let checkboxName = event.target.name;
        this.interviewData.modeOfInterview = checkboxName;

        if (checkboxName == 'Face to Face') {
            this.isFaceToFace = event.target.checked;
            this.isVideoCall = false;
            this.isTelephonic = false;
        } else if (checkboxName == 'Video Call / Virtual') {
            this.isVideoCall = event.target.checked;
            this.isFaceToFace = false;
            this.isTelephonic = false;
        } else if (checkboxName == 'Telephonic') {
            this.isTelephonic = event.target.checked;
            this.isFaceToFace = false;
            this.isVideoCall = false;
        }
    }
    handleInterviewInvite(){
        scheduleInterview({interviewId:this.recordId})
        .then(result=>{
            console.log('Interview Scheduled');
            this.dispatchEvent(new ShowToastEvent({
                title: 'Interview Scheduled Successfully',
                message: 'Success',
                variant: 'success',
                mode: 'dismissable'
            }));
        })
        .catch(err=>{
            console.log('Failed to Schedule Interview',err);
        })
    }
    handleTextArea(event) {
        if (event.target.name == 'People Capability') {
            this.interviewData.peopleCapability = event.target.value;
        } else if (event.target.name == 'Process Maturity') {
            this.interviewData.processMaturity = event.target.value;
        } else if (event.target.name == 'Project Knowledge') {
            this.interviewData.projectKnowledge = event.target.value;
        } else if (event.target.name == 'Attitude') {
            this.interviewData.Attitude = event.target.value;
        } else if (event.target.name == 'Comments') {
            this.interviewData.Comments = event.target.value;
        }
    }

    handleRecommendation(event) {
        let checkboxName = event.target.name;

        if (checkboxName == 'Hire') {
            this.isHire = event.target.checked;
            this.isRecommendInterview = false;
            this.isReject = false;
            this.interviewData.hireSelected = event.target.checked
        } else if (checkboxName == 'Recommend Interview') {
            this.isRecommendInterview = event.target.checked;
            this.isHire = false;
            this.isReject = false;
            this.interviewData.recommendInterview = event.target.checked
        } else if (checkboxName == 'Reject') {
            this.isReject = event.target.checked;
            this.isHire = false;
            this.isRecommendInterview = false;
            this.interviewData.isRejected = event.target.checked
        }
    }

    // handlePosition(event){
    //     this.interviewData.recommendPosition = event.target.value;
    // }

    handleRating(event) {
        // console.log('starRating::'+JSON.stringify(event.detail));
        if (this.listOfRating.length > 0) {
            let isNewSkillSet = true;
            for (let i = 0; i < this.listOfRating.length; i++) {
                if (this.listOfRating[i].skillSetId == event.detail.outerindex && this.listOfRating[i].innerIndex == event.detail.innerIndex) {
                    this.listOfRating[i].rating = event.detail.rating;
                    isNewSkillSet = false;
                }
            }
            if (isNewSkillSet) {
                let ratingDetails = {};
                ratingDetails.innerIndex = event.detail.innerIndex;
                ratingDetails.skillSetId = event.detail.outerindex;
                ratingDetails.rating = event.detail.rating;
                ratingDetails.questionName = event.detail.questionName;
                this.listOfRating.push(ratingDetails);
            }
        } else {
            let ratingDetails = {};
            ratingDetails.innerIndex = event.detail.innerIndex;
            ratingDetails.skillSetId = event.detail.outerindex;
            ratingDetails.rating = event.detail.rating;
            ratingDetails.questionName = event.detail.questionName;
            this.listOfRating.push(ratingDetails);
        }
        // console.log('ratinglist::'+JSON.stringify(this.listOfRating));
    }

    handleJustify(event) {
        let outerIndex = event.target.name;
        let innerIndex = event.target.dataset.innerindex;
        let questionName = event.target.dataset.questionname;
        if (this.listOfRating.length > 0) {
            let isNewSkillSet = true;
            for (let i = 0; i < this.listOfRating.length; i++) {
                if (this.listOfRating[i].skillSetId == outerIndex && this.listOfRating[i].innerIndex == innerIndex) {
                    this.listOfRating[i].justification = event.target.value;
                    isNewSkillSet = false;
                }
            }
            if (isNewSkillSet) {
                let ratingDetails = {};
                ratingDetails.innerIndex = innerIndex;
                ratingDetails.skillSetId = outerIndex;
                ratingDetails.justification = event.target.value;
                ratingDetails.questionName = questionName;
                this.listOfRating.push(ratingDetails);
            }
        } else {
            let ratingDetails = {};
            ratingDetails.innerIndex = innerIndex;
            ratingDetails.skillSetId = outerIndex;
            ratingDetails.justification = event.target.value;
            ratingDetails.questionName = questionName;
            this.listOfRating.push(ratingDetails);
        }
        // console.log('justification::'+JSON.stringify(this.listOfRating));
    }

    submitForm() {
        if (this.interviewData.modeOfInterview == '' || this.interviewData.modeOfInterview == undefined) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Please select Mode Of Interview.',
                message: '',
                variant: 'warning',
                mode: 'dismissable'
            }));
            return;
        }
        if (this.listOfRating.length == 0) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Please fill Skill Set Ratings.',
                message: '',
                variant: 'warning',
                mode: 'dismissable'
            }));
            return;
        }
        if (this.interviewData.peopleCapability == '' || this.interviewData.peopleCapability == undefined) {
            let message = '';
            if (this.isDigitalServices == true) {
                message = 'Please enter People/Team Management Skills.';
            } else {
                message = 'Please enter People Capability.';
            }
            this.dispatchEvent(new ShowToastEvent({
                title: message,
                message: '',
                variant: 'warning',
                mode: 'dismissable'
            }));
            return;
        }
        if (this.showComments && (this.interviewData.processMaturity == '' || this.interviewData.processMaturity == undefined)) {
            let message = '';
            if (this.isDigitalServices == true) {
                message = 'Please enter Ability to build pipeline and manage key accounts effectively.';
            } else if (this.isDigitalMarketing == true) {
                message = 'Please enter Ability towards original/required content creations.';
            } else {
                message = 'Please enter Process Maturity.';
            }
            this.dispatchEvent(new ShowToastEvent({
                title: message,
                message: '',
                variant: 'warning',
                mode: 'dismissable'
            }));
            return;
        }
        if (this.interviewData.projectKnowledge == '' || this.interviewData.projectKnowledge == undefined) {
            let message = '';
            if (this.showComments == false) {
                message = 'Please enter Overall Domain Expertise.';
            } else if (this.isDigitalServices == true) {
                message = 'Please enter Ability to understand B2B and B2C markets.';
            } else {
                message = 'Please enter Project Knowledge/Domain Expertise.';
            }
            this.dispatchEvent(new ShowToastEvent({
                title: message,
                message: '',
                variant: 'warning',
                mode: 'dismissable'
            }));
            return;
        }
        if (this.interviewData.Attitude == '' || this.interviewData.Attitude == undefined) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Please enter Attitude.',
                message: '',
                variant: 'warning',
                mode: 'dismissable'
            }));
            return;
        }
        if (this.interviewData.Comments == '' || this.interviewData.Comments == undefined) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Please enter Overall Comments.',
                message: '',
                variant: 'warning',
                mode: 'dismissable'
            }));
            return;
        }
        if (this.interviewData.hireSelected == false && this.interviewData.isRejected == false && this.interviewData.recommendInterview == false) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Please select anyone Recommendation.',
                message: '',
                variant: 'warning',
                mode: 'dismissable'
            }));
            return;
        }
        this.showSpinner = true;
        saveInformation({
            interviewWrap: this.interviewData,
            ratingSkills: this.listOfRating,
            interviewId: this.recordId
        })
            .then(result => {
                if (result == 'Success') {
                    this.showSpinner = false;
                    this.isSubmitted = true;
                    this.isOpenFeedbackForm = false;
                    window.location.reload();
                    console.log('result::' + JSON.stringify(result));
                    this.EvaluationBtnLabel = 'Evaluation Submitted';
                    this.dispatchEvent(new ShowToastEvent({
                        title: 'Record saved successfully',
                        message: '',
                        variant: 'success'
                    }));
                    return;
                } else {
                    this.showSpinner = false;
                    this.isSubmitted = false;
                    console.log('error::' + JSON.stringify(result));
                    this.dispatchEvent(new ShowToastEvent({
                        title: result,
                        message: '',
                        variant: 'error'
                    }));
                    return;
                }
            })
            .catch(error => {
                this.showSpinner = false;
                this.isSubmitted = false;
                console.log('error::' + JSON.stringify(error));
                this.dispatchEvent(new ShowToastEvent({
                    title: error,
                    message: '',
                    variant: 'error'
                }));
                return;
            })
    }

    handleInterviewForm() {
        this.isOpenFeedbackForm = true;
    }

    handleClosePopup() {
        this.isOpenFeedbackForm = false;
        if (this.isSubmitted == false) {
            this.listOfRating = [];
            this.interviewData.modeOfInterview = '';
            this.interviewData.peopleCapability = '';
            this.interviewData.processMaturity = '';
            this.interviewData.projectKnowledge = '';
            this.interviewData.Attitude = '';
            this.interviewData.Comments = '';
            this.interviewData.hireSelected = false;
            this.interviewData.isRejected = false;
            this.interviewData.recommendInterview = false;
            this.interviewData.recommendPosition = '';
            this.isFaceToFace = false;
            this.isVideoCall = false;
            this.isTelephonic = false;
            this.isHire = false;
            this.isRecommendInterview = false;
            this.isReject = false;
        }
    }
}