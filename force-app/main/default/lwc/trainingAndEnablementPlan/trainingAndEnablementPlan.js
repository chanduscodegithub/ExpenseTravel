import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import saveTrainingEnablementData from '@salesforce/apex/careerDevelopmentAndEnablementController.saveTrainingEnablementData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import disabledTEP from './trainingAndEnablementPlanDisabled.html'
import enabledTEP from './trainingAndEnablementPlan.html';
import searchEmployeeCertificate from '@salesforce/apex/careerDevelopmentAndEnablementController.searchEmployeeCertificate';


export default class TrainingAndEnablementPlan extends NavigationMixin(LightningElement) {

    @api cdepCompleteDetails;
    @api isEditable;
    @api empId;
    @api fromgoalsetting;

    @track certificationsList = [];
    @track employeeCertificationsPlan = [{ index: 0, Id: "", certificateName: "", targetDate: "", status: "" }];
    @track employeeEnablementPlans = [{ index: 0, Id: "", processTraining: "", softSkills: "", mentorship: "" }];
    @track managerComments = '';
    @track reviewerComments = '';
    @track isLoading = false

    toDeleteCertificationsPlanIds = [];
    toDeleteEnablementPlansIds = [];

    @wire(CurrentPageReference) pageRef;

    // Search Implementation
    recentlySearchedListOfCertificates = [];
    searchValue;
    @track searchedCertificateResultList = [];

    @wire(searchEmployeeCertificate, { certificate: '$searchValue' })
    wiredCoachSearchResult({ data, error }) {
        if (data) {
            //console.log('The fetched data is @@',data);
            this.recentlySearchedListOfCertificates = [];
            data.forEach(certificate => { this.recentlySearchedListOfCertificates.push({ label: certificate.Name, value: certificate.Id }) });
            this.searchedCertificateResultList = this.recentlySearchedListOfCertificates;
        } else if (error) {
            this.dispatchEvent(new ShowToastEvent({
                variant: 'error',
                title: 'Failed to fetch search result'
            }));
        }
    }
    searchForCertificate(event) {
        const index = event.currentTarget.dataset.index;
        this.searchValue = event.target.value;
        //console.log('The input value is @@',this.searchValue);
        //this.employeeCertificationsPlan[index].Id = "";
        this.employeeCertificationsPlan[index].certificateName = "";
        this.employeeCertificationsPlan[index]["displayDropDown"] = true;
    }

    selectCertificateFromSearchResult(event) {
        const certificateId = event.currentTarget.dataset.value;
        const certificateName = event.currentTarget.dataset.label;
        const index = event.currentTarget.dataset.index;

        // this.employeeCertificationsPlan[index].Id = certificateId;
        this.employeeCertificationsPlan[index].certificateName = certificateName;
        this.employeeCertificationsPlan[index]["displayDropDown"] = false;
    }

    hideSearchOptions(event) {
        const index = event.currentTarget.dataset.index;
        this.employeeCertificationsPlan[index]["displayDropDown"] = false;
    }


    // Life cycle hooks
    connectedCallback() {
        //console.log('This is the child connected call back')
        if (this.cdepCompleteDetails.comments.length > 0) {
            this.managerComments = this.cdepCompleteDetails.comments[0].trainingManagerComments;
            this.reviewerComments = this.cdepCompleteDetails.comments[0].trainingReviewerComments;
        }

        this.certificationsList = this.cdepCompleteDetails.cdepData.certificationDetails;

        if (this.cdepCompleteDetails.cdepData.recommendedCertificates?.length > 0) {
            this.employeeCertificationsPlan = JSON.parse(JSON.stringify(this.cdepCompleteDetails.cdepData.recommendedCertificates));
            // this.employeeCertificationsPlan = Object.assign( [], this.cdepCompleteDetails.cdepData.recommendedCertificates );
        }

        if (this.cdepCompleteDetails.cdepData.enablementDetails?.length > 0) {
            this.employeeEnablementPlans = JSON.parse(JSON.stringify(this.cdepCompleteDetails.cdepData.enablementDetails));
            // this.employeeEnablementPlans = Object.assign( [], this.cdepCompleteDetails.cdepData.enablementDetails );
        }
    }


    render() {
        return (this.isEditable) ? enabledTEP : disabledTEP;
    }
    //search for certificate


    // For employee certification plan
    handelNewCertRec(event) {
        const planIndex = event.target.dataset.index;
        const planFor = event.target.dataset.for;
        const value = event.target.value;
        this.employeeCertificationsPlan[planIndex][planFor] = value;
    }

    createNewCertificateRow() {
        this.employeeCertificationsPlan.push({
            index: this.employeeCertificationsPlan.length,
            Id: "",
            certificateName: "",
            targetDate: "",
            status: ""
        });
    }

    // For Additional Training / Enablement Plans
    createNewEnablementRow() {
        this.employeeEnablementPlans.push({
            index: this.employeeEnablementPlans.length,
            Id: "",
            processTraining: "",
            softSkills: "",
            mentorship: ""
        });
    }

    handelNewEnablementRec(event) {
        const value = event.target.value;
        const key = event.target.dataset.for;
        const index = event.target.dataset.index;
        this.employeeEnablementPlans[index][key] = value;
    }

    handelComments(event) {
        const from = event.target.dataset.from;
        const value = event.target.value;
        this[from] = value;
    }
    toggle() {
        this.isLoading = !this.isLoading;
    }

    // Handel submit
    handelSubmit(event) {
        this.toggle()
        event.preventDefault();
        //console.log('deleteids',this.toDeleteEnablementPlansIds);
        let allTheVlauesAreSubmited = true;
        event.currentTarget.querySelectorAll('lightning-combobox').forEach(el => {
            el.reportValidity();
            allTheVlauesAreSubmited = (el.value && allTheVlauesAreSubmited) ? true : false;
        });

        if (!allTheVlauesAreSubmited) {
            this.dispatchEvent(new ShowToastEvent({
                variant: 'error',
                title: 'Please enter all the required fields!'
            }));

            this.toggle();
            //console.log('this.toggle()',this.isLoading);
            return;

        }

        const payLoad = {
            "empId": this.empId,
            "cdepData": {
                "Id": (this.cdepCompleteDetails.comments.length > 0 && this.cdepCompleteDetails.comments[0]?.Id) ? this.cdepCompleteDetails.comments[0].Id : '',
                "managerComments": this.managerComments,
                "reviewerComments": this.reviewerComments,
            },
            "recommendedCertifications": this.employeeCertificationsPlan,
            "employeeEnablementPlans": this.employeeEnablementPlans,
            "toDeleteCertificationsPlanIds": this.toDeleteCertificationsPlanIds,
            "toDeleteEnablementPlansIds": this.toDeleteEnablementPlansIds
        };

        //console.clear();
        //console.log('The JSON payload is'+ JSON.parse( JSON.stringify( payLoad ) ) )
        //console.log('JSON.stringify( payLoad )',JSON.stringify( payLoad ));
        saveTrainingEnablementData({ jsonstr: JSON.stringify(payLoad) })
            .then(result => {
                this.dispatchEvent(new ShowToastEvent({
                    variant: 'success',
                    title: 'Successfully Submited The Response'
                }));

                //this.updateRecordView();
                this.dispatchEvent(new CustomEvent('selfrating', { detail: "cancel", bubbles: true, composed: true }));
                this.dispatchEvent(new CustomEvent('callparentconnect'))

                this.toggle()

            })
            .catch(error => {
                this.dispatchEvent(new ShowToastEvent({
                    variant: 'error',
                    title: error.body.pageErrors[0].message,
                    message: error.body.pageErrors[0].message
                }));
                this.toggle()
            })
        //location.reload()
        //window.location.href=window.location.href
    }

    // Footer button click handlers
    handelCancel() {
        if (this.fromgoalsetting === 'true') {
            this.dispatchEvent(new CustomEvent('callcancel', {
                detail: {
                    message: 'cancel',
                }
            }));
        } else {
            this.dispatchEvent(new CustomEvent('selfrating', { detail: "cancel", bubbles: true, composed: true }));
        }
    }

    // Utility Delete Row
    handelDeleteRow(event) {
        const globalVariableName = event.target.dataset.variable;
        const arrIndex = event.target.dataset.index;

        //console.log( JSON.parse( JSON.stringify( this[globalVariableName] ) ) );

        if (this[globalVariableName][arrIndex].Id) {
            const toDeleteId = this[globalVariableName][arrIndex].Id;

            if (globalVariableName === "employeeCertificationsPlan") {
                this.toDeleteCertificationsPlanIds.push(toDeleteId);
            }

            if (globalVariableName === "employeeEnablementPlans") {
                this.toDeleteEnablementPlansIds.push(toDeleteId);
            }
        }

        if (arrIndex > -1) {
            this[globalVariableName].splice(arrIndex, 1);
        }

        this[globalVariableName].forEach((element, index) => { element.index = index });
    }

    get certificatesList() {
        return [];
    }

    get certificateStatus() {
        return [
            { label: 'In Progress', value: 'In Progress' },
            { label: 'Deferred', value: 'Deferred' },
            { label: 'Yet To Start', value: 'Yet To Start' },
            { label: 'Completed', value: 'Completed' },
        ]
    }
    updateRecordView() {
        setTimeout(() => {
            eval("$A.get('e.force:refreshView').fire();");
        }, 1000);
    }

}