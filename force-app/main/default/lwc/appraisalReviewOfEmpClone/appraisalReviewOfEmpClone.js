import { LightningElement, wire, track,api } from 'lwc';
import getDetailsOfEmp from "@salesforce/apex/appraisalReviewOfEmpCtrlClone.getDetailsOfEmp";
import saveAsDraft from "@salesforce/apex/appraisalReviewOfEmpCtrlClone.saveAsDraft";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getRatingPicklistValues from '@salesforce/apex/PMS_Controller.getPicklistValues';
//import getyearRatingPicklistValues from '@salesforce/apex/PMS_Controller.getyearPicklistValues';
import { NavigationMixin, CurrentPageReference } from "lightning/navigation";


export default class AppraisalReviewOfEmpClone extends NavigationMixin(LightningElement) {
    @track options = [{ label: '1', value: '1' }, { label: '2', value: '2' }, { label: '3', value: '3' }, { label: '4', value: '4' }, { label: '5', value: '5' }];
    entryPopUp = true;
     //@api propertyValue;
    get QPRoptions() {
        return [
            { label: 'QPR-I', value: 'QPR-I' },
            { label: 'QPR-II', value: 'QPR-II' },
            { label: 'QPR-III', value: 'QPR-III' },
            { label: 'QPR-IV/Annual Review', value: 'Annual Cycle' },
        ];
    }
    get yearOptions() {
        return [
            //{ label: '2021', value: '2021' },
            //{ label: '2022', value: '2022' },
            { label: '2023', value: '2023' },
            { label: '2024', value: '2024' },
        ];
    }
    @track wrapperDetailsEmp;
    @track EmpDetails = {};
    @track EmpDetailsTest;
    @track error;
    @track quarter;
    @track message;
    @track isPopupVisible = false;
    @track EmpFeedback;
    @track isLoaded = true;
    @track title;
    @track empreportManager = {};
    @track designation;
    @track isPopupVisible = false;
    @track totalKRAScore;
    @track perId;
    @track ccm;
    @track DelegatedManager1;
    @track DelegatedManager2;
    @track appraisal;
    @track Perstatus;
    @track shwmanagerbtn;
    @track disableEdit;
 @track getyearOptions=[];
    @track displayCareerPlan = false;
    @track displaySelfRating = true;
    @track displayManagerRating = false;

    @track empRecordId = '';


    wrapperDetailsEmpForRefresh;
    disabled = false;
    displayTotalKRA = false;
    activeSectionMessage = '';
    rejected;
    @track disableProceedButton = true;

    selectedQuarter = ''; selectedYear = '';


    @track comment;
    @wire(getRatingPicklistValues, {})
    // Define a wired property for rating picklist values
    wiredRatingPicklistValues({ error, data }) {
        // If data is returned from the wire function
        if (data) {
            // Map the data to an array of options
            this.ratingOptions = data.map(option => {
                return {
                    label: option.label,
                    value: option.value
                };
            });
        }
        // If there is an error
        else if (error) {
            // Log the error to the console
            console.error(error);
        }
    }
     
    /*@wire(getyearRatingPicklistValues, {})
    // Define a wired property for rating picklist values
    wiredYearRatingPicklistValues({ error, data }) {
    // If data is returned from the wire function
    if(data) {
    console.log('this.yearOptionsdata', data);
    let currentDate = new Date();
    let currentYear = currentDate.getFullYear();
    // Map the data to an array of options
    this.getyearOptions = data.map(option => {
    if (option.label <= currentYear) {
    return {
        label: option.label,
        value: option.value
    };
    }
    return null; // Returning null for options that don't meet the condition
    }).filter(option => option !== null); // Filtering out null values

    }
    // If there is an error
    else if (error) {
    // Log the error to the console
    console.error(error);
    }
    }*/


    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
        //console.log('~~Page Ref ', currentPageReference);
        if (currentPageReference) {
            //console.log(currentPageReference);
            let recordId1 = currentPageReference.attributes.recordId || null;
            let attributes = currentPageReference.attributes;
            let states = currentPageReference.state;
            let type = currentPageReference.type;
            let StateV = currentPageReference.state.c__recId;

            //console.log('~~recordId1 : ',recordId1);
            //console.log('~~attributes : ',attributes);
            //console.log('~~states : ',states);
            //console.log('~~type : ',type);
            //console.log('~~StateV 1 : ',StateV);

            //this.empRecordId = currentPageReference.state.c__recId;
            this.empRecordId = (currentPageReference.state.c__recId == undefined || currentPageReference.state.c__recId == null) ? '' : currentPageReference.state.c__recId;
            //console.log('currentPageReference.state.c__recId', this.empRecordId );

        }



    }

    connectedCallback() {

        var d = new Date();
        console.log('this.selectedQuarter' + this.selectedQuarter);
        //this.quarter = 'Q' + Math.ceil(d.getMonth() / 3);
        this.quarter = 'Q2';
        this.comment = 'with the weightage';

        const date = new Date();
        this.currentYear = date.getFullYear();

        //this.title = 'Self Appraisal For ' + this.selectedQuarter + ' - ' + this.currentYear;

    }
    //disableProceedButton = true;
    @wire(getDetailsOfEmp, { empId: '$empRecordId', selectedQuarter: '$selectedQuarter', currentYr : '$selectedYear'})
    wiredAccountsWithContacts(value) {
        this.wrapperDetailsEmpForRefresh = value;
        const { data, error } = value;
        //console.log('data',data);
        //console.log('~~empRecordId : ', this.empRecordId);
        //console.log('~~selectedQuarter : ', this.selectedQuarter);
        this.disableProceedButton = true;
        if (data) {
            //console.log('Hi');
            this.EmpDetails = JSON.parse(data).EmpDetails;
            this.appraisal = JSON.parse(data).appraisal;
            //console.log('~~data : ',this.EmpDetails.Id);
            this.displayTotalKRA = JSON.parse(data).displayTotalScoreInlwc;
            //console.log('this.displayTotalKRA', this.displayTotalKRA);
            this.empreportManager = this.EmpDetails?.ReportingTo__r?.Name;
            this.designation = this.EmpDetails?.Designation__r.Name;
            this.ccm = this.EmpDetails?.BU_Head__c != undefined ? this.EmpDetails.BU_Head__r?.Name : '';
            //console.log('ccm::'+this.EmpDetails.BU_Head__r.Name);
            this.perId = JSON.parse(data).PerformanceId;
            this.DelegatedManager1 = JSON.parse(data).DelegatedManger1;
            this.DelegatedManager2 = JSON.parse(data).DelegatedManger2;
            this.perId = JSON.parse(data).PerformanceId;
            this.EmpFeedback = JSON.parse(data).EmpComments;
            this.wrapperDetailsEmp = JSON.parse(data).KRAWrapperDetails;
            this.isLoaded = false;
            this.Perstatus = JSON.parse(data).Status;
            //console.log('this.Perstatus', this.Perstatus, JSON.parse(data).Status);
            this.disableEdit = (JSON.parse(data).Status == 'In progress' || JSON.parse(data).Status == 'Draft' || JSON.parse(data).Status == 'Open' || JSON.parse(data).Status == 'Manager Rejected' ? false : true)
            this.rejected = ((JSON.parse(data).Status == 'Manager Rejected' && (this.selectedQuarter == this.appraisal.Current_Cycle__c)) ? true : false);
            //console.log(' this.rejected', this.rejected);
            //console.log('this.disableEdit::', this.disableEdit);
            this.disableProceedButton = false;
            if (this.disableEdit === true) {
                this.disableButton = true;
            }
            let today = new Date().toISOString().slice(0, 10);
            //console.log('today', today);
            //console.log('today', this.appraisal.Q2_EmployeeSubmissionStartDate__c);
            if (this.appraisal.Current_Cycle__c == 'QPR-II') {
                if ((this.appraisal.Q2_EmployeeSubmissionStartDate__c < today && this.appraisal.Q2_EmployeeSubmissionEndDate__c < today) || (this.appraisal.Q2_EmployeeSubmissionStartDate__c > today && this.appraisal.Q2_EmployeeSubmissionEndDate__c > today) || (this.appraisal.Q2_EmployeeSubmissionStartDate__c == undefined && this.appraisal.Q2_EmployeeSubmissionEndDate__c == undefined)) {
                    this.disableButton = true;
                }
                else {
                    this.disableButton = false;
                }
            } else if (this.appraisal.Current_Cycle__c == 'QPR-I') {
                if ((this.appraisal.Q1EmployeeSubmissionStartDate__c < today && this.appraisal.Q1EmployeeSubmissionEndDate__c < today) || (this.appraisal.Q1EmployeeSubmissionStartDate__c > today && this.appraisal.Q1EmployeeSubmissionEndDate__c > today) || (this.appraisal.Q1EmployeeSubmissionStartDate__c == undefined && this.appraisal.Q1EmployeeSubmissionEndDate__c == undefined)) {
                    this.disableButton = true;
                }
                else {
                    this.disableButton = false;
                }
            } else if (this.appraisal.Current_Cycle__c == 'QPR-III') {
                //console.log('this.disableButton123',  this.disableButton );
                if ((this.appraisal.Q3_EmployeeSubmissionStartDate__c < today && this.appraisal.Q3_EmployeeSubmissionEndDate__c < today) || (this.appraisal.Q3_EmployeeSubmissionStartDate__c > today && this.appraisal.Q3_EmployeeSubmissionEndDate__c > today) || (this.appraisal.Q3_EmployeeSubmissionStartDate__c == undefined && this.appraisal.Q3_EmployeeSubmissionEndDate__c == undefined)) {
                    //console.log('this.disableButton1234',  this.disableButton );
                    this.disableButton = true;
                }
                else {
                    this.disableButton = false;
                }

            } else if (this.appraisal.Current_Cycle__c == 'Annual Cycle') {
                if ((this.appraisal.Q4_EmployeeSubmissionStartDate__c < today && this.appraisal.Q4_EmployeeSubmissionEndDate__c < today) || (this.appraisal.Q4_EmployeeSubmissionStartDate__c > today && this.appraisal.Q4_EmployeeSubmissionEndDate__c > today) || (this.appraisal.Q4_EmployeeSubmissionStartDate__c == undefined && this.appraisal.Q4_EmployeeSubmissionEndDate__c == undefined)) {
                    this.disableButton = true;
                }else {
                    this.disableButton = false;
                }
            }


            //console.log('this.disableButton ',this.disableButton );
            if (((this.appraisal.Current_Cycle__c == 'QPR-I' && this.Perstatus == 'QPR-I Manager submitted') || (this.appraisal.Current_Cycle__c != this.selectedQuarter && this.selectedQuarter == 'QPR-I' && this.Perstatus != 'QPR-I Manager submitted')) || ((this.appraisal.Current_Cycle__c == 'QPR-II' && this.Perstatus == 'QPR-II Manager submitted') || (this.appraisal.Current_Cycle__c != this.selectedQuarter && this.selectedQuarter == 'QPR-II' && this.Perstatus != 'QPR-II Manager submitted'))
                || ((this.appraisal.Current_Cycle__c == 'QPR-III' && this.Perstatus == 'QPR-III Manager submitted') || (this.appraisal.Current_Cycle__c != this.selectedQuarter && this.selectedQuarter == 'QPR-III' && this.Perstatus != 'QPR-III Manager submitted')) || (this.appraisal.Current_Cycle__c == 'Annual Cycle' && (this.Perstatus == 'QPR-IV/Annual Review Manager submitted' || this.Perstatus == 'Reviewer Submitted'))) {
                this.shwmanagerbtn = false;
            }
            else {
                this.shwmanagerbtn = true;
            }
            //console.log('this.disableButton12 ',this.disableButton );
            //alert(this.displayTotalKRA)
            if (this.displayTotalKRA === true) {
                this.calculateScore();
                this.disableButton = true;
            }
            if (!JSON.parse(data).isEmpLogIn) {
                this.disableButton = true;
            }
            //console.log('disableProceedButton1::',this.disableProceedButton);
            //console.log('this.disableButton23 ',this.disableButton );
        } else if (error) {
            this.error = error;
            this.isLoaded = false;
            this.disableProceedButton = true;
            this.wrapperDetailsEmp = undefined;
            //console.log('disableProceedButton::',this.disableProceedButton);
            if(error.body.message === 'Please select the year and quater'){
                this.toastMsg('Warning', error.body.message, 'Warning');
            }else{
                this.toastMsg('Error', error.body.message, 'Error');
            }
            console.log('error:::'+JSON.stringify(error));
            
        } else {
            this.entryPopUp = true;
            this.toastMsg('Error', 'You don\'t have any data for the selected quarter', 'Error')
        }
    }

    handleNavigate() {
        this.displayCareerPlan = true;
        this.displaySelfRating = false;
    }

    handleNavigateMR() {
        //console.log('~~PrId : ',this.perId);
        this.displayManagerRating = true;
        this.displaySelfRating = false;
    }

    handlecareerDevelop(event) {
        if (event.detail === 'cancel') {
            this.displayCareerPlan = false;
            this.displayManagerRating = false;
            this.displaySelfRating = true;
        }
    }

    handleEmpRating(event) {
        if (event.target.name === "mycommment") {
            this.wrapperDetailsEmp[event.target.dataset.index].childWrapperDetails[event.target.accessKey].EmpComment = event.target.value;
            //console.log(JSON.stringify(this.wrapperDetailsEmp));
        }
    }
    handlestarrating(event) {
        const data = event.detail;
        this.wrapperDetailsEmp[data.outerindex].childWrapperDetails[data.innerIndex].EmpRating = data.rating;
    }
    handleEmpFeedbackEdit(event) {
        this.EmpFeedback = event.target.value;
        //console.log(' this.EmpFeedback ', this.EmpFeedback);
    }
    entercomments() {
        this.isPopupVisible = !this.isPopupVisible;
    }

    handleCancel() {
        this.entryPopUp = true;
        // this[NavigationMixin.Navigate]({
        //     type: "standard__recordPage",
        //     attributes: {
        //         recordId: this.EmpDetails.Id,
        //         objectApiName: "Employee__c",
        //         actionName: "view"
        //     }
        // });

    }

    handleYearChange(e) {

        this.selectedYear = e.detail.value;
    }
    handleQPRChange(e) {
        this.selectedQuarter = e.detail.value;
        this.title = 'Self Appraisal For ' + this.selectedQuarter + ' - ' + this.selectedYear;
    }
    handleEntryPopUpClose() {
        this.entryPopUp = false;
    }
    handleEntryPopUp() {
        if (this.selectedQuarter == '' && this.selectedYear == '') { this.toastMsg('Error', 'Please Select Year and QPR', 'Error') }
        else if (this.selectedQuarter == '') { this.toastMsg('Error', 'Please Select QPR', 'Error') }
        else if (this.selectedYear == '') { this.toastMsg('Error', 'Please Select Year', 'Error') }
        else {
            this.entryPopUp = false;
            //refreshApex(this.wrapperDetailsEmpForRefresh);
        }

    }
    displayPopup() {
        this.isPopupVisible = !this.isPopupVisible;

        this.calculateScore();
        //alert(this.totalKRAScore);
    }

    calculateScore() {
        this.totalKRAScore = 0;

        for (let i = 0; i < this.wrapperDetailsEmp.length; i++) {
            for (let j = 0; j < this.wrapperDetailsEmp[i].childWrapperDetails.length; j++) {
                this.totalKRAScore += this.wrapperDetailsEmp[i].childWrapperDetails[j].EmpRating != null ? parseFloat(this.wrapperDetailsEmp[i].childWrapperDetails[j].EmpRating / 5) * (parseFloat(this.wrapperDetailsEmp[i].childWrapperDetails[j].KPIWeightage) / 100) : 0 * (parseFloat(this.wrapperDetailsEmp[i].childWrapperDetails[j].KPIWeightage) / 100);
            }
        }
        this.totalKRAScore = (this.totalKRAScore * 5).toFixed(1);
    }

    saveasdraft() {
        this.isLoaded = true;
        /*var result = this.validation(this.wrapperDetailsEmp);
        console.log(result);
        if (result === true) {
            this.isLoaded = false;
            const event = new ShowToastEvent({
                title: 'Please enter required fields',
                message: '',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
    
            return;
        }*/
        console.log(JSON.stringify(this.wrapperDetailsEmp));
        saveAsDraft({ datalist: JSON.stringify(this.wrapperDetailsEmp), futurePotentials: this.EmpFeedback, PerId: this.perId, DraftOrSubmitted: 'Draft' })
            .then(result => {
                this.message = result;
                this.error = undefined;
                if (this.message === 'success') {

                    const event = new ShowToastEvent({
                        title: 'Appraisal review saved as draft!',
                        message: 'Your appraisal review for ' + this.selectedQuarter + ' is saved as draft successfully!',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    this.isLoaded = false;
                    refreshApex(this.wrapperDetailsEmpForRefresh);
                } else {
                    const event = new ShowToastEvent({
                        title: 'appraisal review not saved',
                        message: 'Failed to created the record to please contact admin',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                }
            }).catch(error => {
                console.log('error::'+JSON.stringify(error));
                this.message = undefined;
                this.error = error;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record please contact admin',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
                //console.log("error", JSON.stringify(this.error));
            });
    }

    submittomanager() {

        this.isLoaded = true;


        var result = this.validation(this.wrapperDetailsEmp);
        console.log(result);

        if (result === true) {
            const event = new ShowToastEvent({
                title: 'Please enter required fields',
                message: '',
                variant: 'error',
                mode: 'dismissable'
            });
            this.dispatchEvent(event);
            this.isLoaded = false;
            //this.displayTotalKRA = true;
            this.isPopupVisible = !this.isPopupVisible;
            return;
        }

        this.displayTotalKRA = true;
        //console.log('~~displayTotalKRA on Submit : ', this.displayTotalKRA);
        this.isPopupVisible = !this.isPopupVisible;


        saveAsDraft({ datalist: JSON.stringify(this.wrapperDetailsEmp), futurePotentials: this.EmpFeedback, PerId: this.perId, DraftOrSubmitted: 'Submitted' })
            .then(result => {
                this.message = result;
                this.error = undefined;
                if (this.message === 'success') {
                    const event = new ShowToastEvent({
                        title: 'Appraisal review submitted',
                        message: 'Your appraisal review for ' + this.selectedQuarter + ' is submitted succesfully!',
                        variant: 'success',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    this.isLoaded = false;
                    this.disableButton = true;
                    // Refresh the data after the submission is successful
                    refreshApex(this.wrapperDetailsEmpForRefresh);
                } else {
                    const event = new ShowToastEvent({
                        title: 'appraisal review not saved',
                        message: 'Failed to created the record to please contact admin',
                        variant: 'error',
                        mode: 'dismissable'
                    });
                    this.dispatchEvent(event);
                    // this.refreshData();
                }
            }).catch(error => {
                console.log(error);
                this.message = undefined;
                this.error = error;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record please contact admin',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
                console.log("error", JSON.stringify(this.error));
            });
    }

    validation(data) {

        if (this.EmpFeedback === null || this.EmpFeedback === '') {
            //console.log('this.EmpFeedback', this.EmpFeedback);
            return true;
        }

        for (let i = 0; i < data.length; i++) {
            for (let j = 0; j < data[i].childWrapperDetails.length; j++) {
                if (data[i].childWrapperDetails[j].EmpRating === null) {
                    return true;
                } else if (data[i].childWrapperDetails[j].EmpComment === null || data[i].childWrapperDetails[j].EmpComment == '') {
                    return true;
                }
            }
        }
        return false;
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