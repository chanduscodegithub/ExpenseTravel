import { LightningElement, track, api } from 'lwc';
import getrole from '@salesforce/apex/FindJobRole.Findrole';
import sendapproval from '@salesforce/apex/FindJobRole.sendApproval';
import getjdlink from '@salesforce/apex/FindJobRole.getjdlink';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updatejobrole from '@salesforce/apex/FindJobRole.updateContactRecord';
import { NavigationMixin } from 'lightning/navigation';
import LightningConfirm from "lightning/confirm";

export default class Newbutton extends NavigationMixin(LightningElement) {
    fieldsdata = ["Department__c", "Position_Title__c", "Mode_Of_Work__c", "Customer__c", "Project__c", "Country__c", "City__c", "Hiring_Priority__c", "Type_Of_Resource__c", "Job_Description__c"];
    fieldnames = [
        // { label: 'RR-No', name: 'Name' },
        { label: 'Department', name: 'Department__c' },
        { label: 'Position Title', name: 'Position_Title__c' },
        { label: 'Mode Of Work', name: 'Mode_Of_Work__c' },
        { label: 'Customer', name: 'Customer__c' },
        { label: 'Customer Engagement', name: 'Project__c' },
        { label: 'Country', name: 'Country1__c' },
        //{ label: 'City', name: 'City1__c' },
        { label: 'Hiring Priority', name: 'Hiring_Priority__c' },
        //{ label: 'Type Of Resource', name: 'Type_Of_Resource__c' },
        //{ label: 'Requested On', name: 'Open_Date__c' },
        //{ label: 'Requisition Type', name: 'Requisition_Type__c' },
        // { label: 'JD Link', name: 'JD_Link__c' },
        //{ label: 'Hiring Status', name: 'Status__c' },
        { label: 'Hiring Manager', name: 'Hiring_Manager_name__c' },
        //{ label: 'Reporting Manager', name: 'Reporting_Manager__c' },
        { label: 'Cost Center Manager', name: 'Hiring_Manager__c' },
        //{ label: 'Corporate Grade Band', name: 'Corporate_Grade_Band__c' },
        //{ label: 'Corporate Grade Level', name: 'Corporate_Grade_Level__c' },
        //{ label: 'Hiring Justification', name: 'Business_Justification__c' },
        //{ label: 'Expected Joining date', name: 'Hire_By__c' },
        { label: 'Hiring Type', name: 'Type__c' },
    ];
    fieldList = ["Hiring_Manager__c"];
    jobrolefields = [
        { label: 'Job Role', name: 'Job_Role__c' },
        { label: 'Salesforce Clouds', name: 'SF_Clouds__c' },
        { label: 'Essential Tech Skills', name: 'Esse__c' },
        { label: 'Additional Tech Skills', name: 'Additional_Tech_Skills__c' },
        { label: 'Essential Administration Skills', name: 'Essential_Administration_Skills__c' },
        { label: 'Additional Administration Skills', name: 'Additional_Administration_Skills__c' },
        { label: 'Essential Certifications', name: 'Essential_Certifications__c' },
        { label: 'Additional Certifications', name: 'Additional_Certifications__c' },
        { label: 'Essential Tools', name: 'Essential_Tools__c' },
        { label: 'Additional Tools', name: 'Additional_Tools__c' },
        { label: 'Verticals', name: 'Verticals__c' },


    ];
    showEditField;
    @track enable = false;
    @track Title;
    @track link;
    @track Dept;
    @track mod;
    @track jd;
    @track Top;
    @track Hiringpriority;
    @track city;
    @track country;
    @track custom;
    @track project;
    @api recordId;// = 'a2ZDX000000dIqP2AU';
    @track BJ;
    @track check = true;
    @track eligible;// = false;//blank
    @track editform = false;
    @track error;
    @track openform = true;
    @track openerror = true;
    @track fieldsdata = [];
    @track isShowModal = false;//false;
    @track isHighPriority = false;
    @track joindate;
    @track rt;
    @track type;

    //new changes
    @track interviewerLevel1;
    @track interviewerLevel2;
    @track interviewerDay1;
    @track interviewerDay2;
    @track interviewerSlot1;
    @track interviewerSlot2;

    @track interviewer2Level1;
    @track interviewer2Level2;
    @track interviewer2Day1;
    @track interviewer2Day2;
    @track interviewer2Slot1;
    @track interviewer2Slot2;

    @track activeSections= ['Round 1'];
    @track activeSectionsPreview = ['Round 1','Round 2'];


    isInputValid() {
        let isValid = true;
        let inputFields = this.template.querySelectorAll('lightning-input-field');

        inputFields.forEach(inputField => {
            if (!inputField.reportValidity()) {
                isValid = false;
            }
        });
        return isValid;
    }



    handleNext(event) {
        event.preventDefault();

        let isValid = this.isInputValid();
        console.log('isValid ', isValid);
        if (isValid == true) {
            console.log('this.eligible 123', this.eligible);
            console.log('this.Title', this.Title);
            getrole({ rolename: this.Title })
                .then(result => {
                    console.log('this.eligible ', this.eligible);
                    if (result) {
                        const fields = event.detail.fields;
                        console.log('onsubmit event recordEditForm' + JSON.stringify(event.detail.fields));
                        this.template.querySelector('lightning-record-edit-form').submit(fields);
                        //this.template.querySelectorAll('[data-id="1"]').submit(fields);
                        this.openform = false;

                    } else {
                        this.openerror = false;
                        this.openform = false;
                    }
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    this.eligible = undefined;
                });
        }
    }
    handleChange(event) {
        if (event.target.name == 'Position_Title__c') {
            this.Title = event.target.value;
            console.log('this.Title' + this.Title);
            getjdlink({ title: this.Title })
                .then(result => {

                    console.log('result', result);
                    if (result != null && result != '') {
                        this.link = result;
                        console.log('this.link', this.link);
                    }
                })
                .catch(error => {
                    this.link = null;
                    this.error = error;
                    console.log('this.error', JSON.stringify(this.error));

                });
        }
        if (event.target.name == 'Department__c') {
            this.Dept = event.target.value;
        }
        if (event.target.name == 'Mode_Of_Work__c') {
            this.mod = event.target.value;
        }
        if (event.target.name == 'Business_Justification__c') {
            this.BJ = event.target.value;
        }
        if (event.target.name == 'Project__c') {
            this.project = event.target.value;
        }
        if (event.target.name == 'Customer__c') {
            this.custom = event.target.value;
        }
        if (event.target.name == 'Country1__c') {
            this.country = event.target.value;
        }
        if (event.target.name == 'City1__c') {
            this.city = event.target.value;
            if (this.city != 'Remote') {
                this.mod = 'Work From Office';
                this.template.querySelector('[data-mode-of-work]').value = 'Work From Office';
            }
        }
        if (event.target.name == 'Hiring_Priority__c') {
            this.Hiringpriority = event.target.value;
            if (event.target.value === 'High') {
                this.isHighPriority = true;
                this.showToast({
                    title: 'High Priority Selected',
                    message: 'You have selected priority as High. Kindly provide business justification.',
                    variant: 'warning',
                    mode: 'dismissable'
                });
            } else {
                this.isHighPriority = false;
            }
        }
        if (event.target.name == 'Type_Of_Resource__c') {
            this.Top = event.target.value;
        }
        if (event.target.name == 'Job_Description__c') {
            this.jd = event.target.value;
        }
        if (event.target.name == 'Requisition_Type__c') {
            this.rt = event.target.value;
        }
        if (event.target.name == 'Type__c') {
            this.type = event.target.value;
        }

        if (event.target.name == 'Interviewer_Level_1__c') {
            this.interviewerLevel1 = event.target.value;
        } if (event.target.name == 'Interviewer_Level_2__c') {
            this.interviewerLevel2 = event.target.value;
        } if (event.target.name == 'Interviewer_Available_Day_Level_1__c') {
            this.interviewerDay1 = event.target.value;
        } if (event.target.name == 'Interviewer_Available_Day_Level_2__c') {
            this.interviewerDay2 = event.target.value;
        } if (event.target.name == 'Interviewer_Slot_Level_1__c') {
            this.interviewerSlot1 = event.target.value;
        } if (event.target.name == 'Interviewer_Slot_Level_2__c') {
            this.interviewerSlot2 = event.target.value;
        }
        if (event.target.name == 'Interviewer_2_Level_1__c') {
            this.interviewer2Level1 = event.target.value;
        } if (event.target.name == 'Interviewer_2_Level_2__c') {
            this.interviewer2Level2 = event.target.value;
        } if (event.target.name == 'Interviewer_2_Available_Day_Level_1__c') {
            this.interviewer2Day1 = event.target.value;
        } if (event.target.name == 'Interviewer_2_Available_Day_Level_2__c') {
            this.interviewer2Day2 = event.target.value;
        } if (event.target.name == 'Interviewer_2_Slot_Level_1__c') {
            this.interviewer2Slot1 = event.target.value;
        } if (event.target.name == 'Interviewer_2_Slot_Level_2__c') {
            this.interviewer2Slot2 = event.target.value;
        }
    }

    handleBack() {
        this.eligible = false;
        this.isShowModal = true;
    }

    hideModalBox() {
        this.isShowModal = false;
    }

    closeQuickAction() {
        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Position__c',
                actionName: 'list'
            },
            state: {
                filterName: 'Recent'
            }
        });
    }

    showToast(params) {
        const event = new ShowToastEvent(params);
        this.dispatchEvent(event);
    }
    handleEdit() {
        this.showEditField = !this.showEditField;

    }

    handlesuccess(event) {
        console.log('eventid', event.detail.id);
        this.recordId = event.detail.id;
        console.log(' this.recordId', this.recordId);
        this.isShowModal = true;
    }
    handlesuccess2(event) {
        this.isShowModal = false;
        console.log(' this.isShowModal ', this.isShowModal);
    }
    handlecheck(event) {
        this.check = event.target.value;
        if (event.target.value == true) {
            this.check = false;
        }
    }
    handleSuccess1(event) {
        event.preventDefault();
        console.log(' this.isShowModal', this.isShowModal);
        this.isShowModal = false;
        let fields = event.detail.fields;
        this.manager = fields.Hiring_Manager__c;
        console.log(' this.manager: ', this.manager);
        console.log('fields', JSON.stringify(fields));
        console.log('Record ID: ', this.recordId);
        //this.template.querySelector('lightning-record-edit-form').submit(fields);
        let isValid = this.isInputValid();
        console.log('isValid ', isValid);
        if (isValid == true) {
            if (this.manager != null) {
                sendapproval({ recordId: this.recordId, manager: this.manager })
                    .then(result => {
                        this.closeQuickAction();
                        console.log('result', result);
                    })
                    .catch(error => {

                        this.error = error;
                        console.log('this.error', JSON.stringify(this.error));
                        this.closeQuickAction();
                    });
            }
            else {
                console.log('else');
                const result = LightningConfirm.open({
                    message: "Please Fill Cost Center Manager.",
                    label: "Warning",
                    theme: "error",
                });
            }

        }
    }
    handleviewnext(event) {
        this.isShowModal = false;

        this.editform = true;
    }
    handleclose() {
        this.showEditField = !this.showEditField;
    }
    handlesaveNext(event) {
        console.log('handlesaveNext');
        event.preventDefault();
        let fields = event.detail.fields;
        console.log('fields', fields);
        //fields.Id= this.recordId;
        console.log('this.recordId', this.recordId);
        console.log('fields', event.detail.fields);
        //this.fieldata=fields;
        //this.template.querySelector('lightning-record-edit-form').submit(fields);
        updatejobrole({ jobfields: fields })
            .then(result => {
                console.log('result', result);
                this.eligible = true;
                this.editform = false;
            })
            .catch(error => {
                this.eligible = true;
                this.editform = false;
                console.log('error');
                this.error = error;
                console.log(' this.error ', JSON.stringify(this.error));
            });
        this.eligible = true;
        this.editform = false;
    }
    handleNextview(event) {
        event.preventDefault();
        this.eligible = true
        this.editform = false;


    }
}