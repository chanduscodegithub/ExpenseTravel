import { LightningElement, track, api, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import searchCoachByName from '@salesforce/apex/careerDevelopmentAndEnablementController.searchCoachByName';
import saveCareerDevelopmentData from '@salesforce/apex/careerDevelopmentAndEnablementController.saveCareerDevelopmentData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import disabledCDP from './careerDevelopmentPlanCompDisabled.html'
import enabledCDP from './careerDevelopmentPlanComp.html';
import searchDesignation from '@salesforce/apex/careerDevelopmentAndEnablementController.searchDesignation'

import { loadStyle } from 'lightning/platformResourceLoader';
import staticCss from '@salesforce/resourceUrl/staticCss';


export default class CareerDevelopmentPlanComp extends NavigationMixin(LightningElement) {

    @api isEditable;
    @api cdpCompleteDetails;
    @api empId;
    @track managerComments = '';
    @track reviewerComments = '';
    @api fromgoalsetting;

    @track disSubmit = false;
    @track isLoading = false;
    @track disp
    @track isClickInsideDropdown;
    @track isClickInsideComponent
    @track showDropdown = false;
    @track type;
    @track isDropdownOpen


    @track employeeDevelopmentPlans = [{
        index: 0,
        Id: "",
        proposedGrowth: "",
        proposedProficiency: "",
        recommenedMentorId: "",
        recommenedMentorName: "",
        status: "",
        assignedDate: "",
        actualStartDate: "",
        expectedCompletionDate: "",
        actualCompletionDate: "",
        acp: true,
        type: "search"
    }];

    toDeleteCDPIds = [];
    //search Implementation for Designation 
    recentlySearchedListOfDesignations = [];
    searchDesignationValue;
    @track searchedDesignationResultList = [];
    boxClass = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click slds-has-focus';
    inputClass = '';
    @wire(searchDesignation, { designation: '$searchDesignationValue' })
    wiredDesignationSearchResult({ data, error }) {
        if (data) {
            this.recentlySearchedListOfDesignations = [];
            data.forEach(coach => { this.recentlySearchedListOfDesignations.push({ label: coach.Name, value: coach.Id }) });
            this.searchedDesignationResultList = this.recentlySearchedListOfDesignations;
        } else if (error) {
            this.dispatchEvent(new ShowToastEvent({
                variant: 'error',
                title: 'Failed to fetch search result'
            }));
        }
    }
    searchForDesignation(event) {

        const index = event.currentTarget.dataset.index;
        this.searchDesignationValue = event.target.value;
        //this.employeeDevelopmentPlans[index].recommenedMentorId = "";
        this.employeeDevelopmentPlans[index].designationName = "";
        this.employeeDevelopmentPlans[index]["displayDropDown"] = true;

        //this.showDropdown=true;

    }

    //     handleClickOutside(event) {
    //     const dropdown = this.template.querySelector('.isdropdown'); // Replace with your dropdown element selector

    //     // Check if the clicked element is inside the dropdown or not
    //     if (dropdown && !dropdown.contains(event.target)) {
    //       this.isDropdownOpen = true;
    //     }
    //   }


    selectDesignationFromSearchResult(event) {
        this.close = true;
        //console.log('test', event.currentTarget.dataset.label);
        const designationId = event.currentTarget.dataset.value;
        const designationName = event.currentTarget.dataset.label;
        const index = event.currentTarget.dataset.index;

        // this.employeeDevelopmentPlans[index].recommenedMentorId = coachId;
        this.employeeDevelopmentPlans[index].proposedGrowth = designationName;
        this.employeeDevelopmentPlans[index]["displayDropDown"] = false;
        //this.showDropdown=false;

    }

    // Search Implementation for Coach
    recentlySearchedListOfCoaches = [];
    searchValue;
    @track searchedCoachResultList = [];

    @wire(searchCoachByName, { coachName: '$searchValue' })
    wiredCoachSearchResult({ data, error }) {
        if (data) {
            this.recentlySearchedListOfCoaches = [];
            data.forEach(coach => { this.recentlySearchedListOfCoaches.push({ label: coach.Name, value: coach.Id }) });
            this.searchedCoachResultList = this.recentlySearchedListOfCoaches;
        } else if (error) {
            this.dispatchEvent(new ShowToastEvent({
                variant: 'error',
                title: 'Failed to fetch search result'
            }));
        }
    }
    onblurchange(event) {
        console.log('event');

    }

    searchForCoach(event) {

        const index = event.currentTarget.dataset.index;
        this.searchValue = event.target.value;
        //console.log('The entered value is', this.searchValue)
        this.employeeDevelopmentPlans[index].recommenedMentorId = "";
        this.employeeDevelopmentPlans[index].recommenedMentorName = "";
        this.employeeDevelopmentPlans[index]["displayDropDown1"] = true;


    }

    selectCoachFromSearchResult(event) {

        const coachId = event.currentTarget.dataset.value;
        const coachName = event.currentTarget.dataset.label;
        const index = event.currentTarget.dataset.index;

        this.employeeDevelopmentPlans[index].recommenedMentorId = coachId;
        this.employeeDevelopmentPlans[index].recommenedMentorName = coachName;
        this.employeeDevelopmentPlans[index]["displayDropDown1"] = false;

    }

    hideSearchOptions(event) {
        const index = event.currentTarget.dataset.index;
        this.employeeDevelopmentPlans[index]["displayDropDown"] = false;
    }
    // End of search
    toggle() {
        this.isLoading = !this.isLoading;
    }
    // Life Cycel Hooks
    connectedCallback() {
        Promise.all([loadStyle(this, staticCss)])
        if (this.cdpCompleteDetails.comments.length > 0) {
            this.managerComments = this.cdpCompleteDetails.comments[0].careerManagerComments;
            this.reviewerComments = this.cdpCompleteDetails.comments[0].careerReviewerComments;
        }

        if (this.cdpCompleteDetails.cdpData.length > 0) {
            // this.employeeDevelopmentPlans = [...this.cdpCompleteDetails.cdpData];
            this.employeeDevelopmentPlans = JSON.parse(JSON.stringify(this.cdpCompleteDetails.cdpData));
            //console.log('The employee development plan', JSON.stringify(this.cdpCompleteDetails.cdpData));
        }
        if (this.employeeDevelopmentPlans.length > 0) {
            this.employeeDevelopmentPlans.forEach((Obj) => {
                Obj.disp = Obj.status == 'Completed' ? true : false
                //console.log('The value of disp', Obj.disp)
                Obj.type = (Obj.disp == true ? '' : 'search');
                //console.log('The value of type', Obj.type);
                //console.log('The value of disp', Obj.disp)
            })
        }
        document.addEventListener('click', this.handleClickOutside);
    }

    render() {
        return (this.isEditable) ? enabledCDP : disabledCDP;
    }

    disconnectedCallback() {
        document.removeEventListener('click', this.handleClickOutside);
    }

    // handleClickOutside(event){
    //     const dropdown=this.template.querySelector('.dropdown');
    //     this.isClickInsideDropdown= dropdown &&dropdown.contains(event.target);
    //     this.isClickInsideComponent=this.template.contains(event.target);

    //     if ((this.isClickInsideDropdown) && (this.isClickInsideComponent)) {
    //         // Perform any necessary actions to close the dropdown
    //         // For example, you can set a flag or update a variable to hide the dropdown
    //         this.showDropdown = true;
    //     }
    // }


    // Capture new user entered details
    handelComments(event) {
        const from = event.target.dataset.from;
        const value = event.target.value;
        this[from] = value;
    }

    captureDevelopmentPlan(event) {
        let planIndex = event.target.dataset.index;
        //console.log(planIndex);
        const planFor = event.target.dataset.planfor;
        const value = event.target.value;
        console.log(planIndex);




        if (planFor == 'status' && value == 'Completed') {
            this.employeeDevelopmentPlans[planIndex]["acp"] = false;



            // this.acp=false;

        }



        else if (planFor == 'status' && value != 'Completed') {
            this.employeeDevelopmentPlans[planIndex]["acp"] = true;
            this.employeeDevelopmentPlans[planIndex]["type"] = '';
            this.employeeDevelopmentPlans[planIndex]['actualCompletionDate'] = '';
            //this.acp=true;
        }

        this.employeeDevelopmentPlans[planIndex][planFor] = value;
    }

    createNewPlan() {
        this.employeeDevelopmentPlans.push({
            index: this.employeeDevelopmentPlans.length,
            Id: "",
            proposedGrowth: "",
            proposedProficiency: "",
            recommenedMentorId: "",
            recommenedMentorName: "",
            status: "",
            assignedDate: "",
            actualStartDate: "",
            expectedCompletionDate: "",
            actualCompletionDate: "",
            acp: true,
            type: "search"

        });
    }

    handelSubmit(event) {
        console.log()
        this.toggle();
        event.preventDefault();

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
            this.toggle()
            return;
        }

        debugger;

        const payLoad = {
            "empId": this.empId,
            "cdepData": {
                "Id": (this.cdpCompleteDetails.comments.length > 0 && this.cdpCompleteDetails.comments[0]?.Id) ? this.cdpCompleteDetails.comments[0].Id : '',
                "managerComments": this.managerComments,
                "reviewerComments": this.reviewerComments,
            },
            "cdp": this.employeeDevelopmentPlans,
            "toDeleteCDPIds": this.toDeleteCDPIds
        };

        //console.clear();
        console.log('payload', JSON.parse(JSON.stringify(payLoad)))

        saveCareerDevelopmentData({ jsonststring: JSON.stringify(payLoad) })
            .then(result => {

                this.dispatchEvent(new ShowToastEvent({
                    variant: 'success',
                    title: 'Successfully Submited The Response'
                }));

                this.dispatchEvent(new CustomEvent('selfrating', { detail: "cancel", bubbles: true, composed: true }));
                //this.updateRecordView();
                this.dispatchEvent(new CustomEvent('callparentconnect'));
                this.toggle();
            })
            .catch(error => {
                //console.log('error', error);
                //console.log('error', error.body.pageErrors[0].message);
                //console.log('this.employeeDevelopmentPlans', this.employeeDevelopmentPlans);
                this.dispatchEvent(new ShowToastEvent({
                    variant: 'error',
                    title: error.body.pageErrors[0].message,
                    message: error.body.pageErrors[0].message
                }));
                this.toggle();

            })
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

        if (this[globalVariableName][arrIndex].Id) {
            this.toDeleteCDPIds.push(this[globalVariableName][arrIndex].Id);
        }

        if (arrIndex > -1) {
            this[globalVariableName].splice(arrIndex, 1);
        }

        this[globalVariableName].forEach((element, index) => { element.index = index });
    }

    get proficiencyLevels() {
        return [
            { label: 'Competent', value: 'Competent' },
            { label: 'Proficient', value: 'Proficient' },
            { label: 'Expert', value: 'Expert' },
            { label: 'Industry Expert', value: 'Specialist' }
        ];
    }

    // get growthOption(){
    //     return [
    //         { label: 'Solution Architect', value: 'Solution Architect'},
    //         { label: 'CX Cloud Developer - Trainee', value: 'CX Cloud Developer - Trainee'},
    //         { label: 'Associate CX Cloud Developer', value: 'Associate CX Cloud Developer'},
    //         { label: 'CX Cloud Developer', value: 'CX Cloud Developer'},
    //         { label: 'CX Cloud Senior developer', value: 'CX Cloud Senior developer'},
    //         { label: 'Team Lead / Module Lead', value: 'Team Lead / Module Lead'},
    //         { label: 'Technical Architect', value: 'Technical Architect'}
    //     ];
    // }

    get cdpStatus() {
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