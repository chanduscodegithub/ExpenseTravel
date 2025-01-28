import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getErrorBody } from './utils';
import raiseResignation from '@salesforce/apex/ExitManagementController.raiseResignation';
import getMyResignationRecords from '@salesforce/apex/ExitManagementController.getMyResignationRecords';


export default class ExitManagementMyResignation extends LightningElement {
    _empData;
    resData;
    fields;
    isModalOpen = false;
    disableResignationBtn = false;
    resignations = [];
    error;
    selectedRow = null;
    showRecord = false;
    showList = false;
    loaded = false;

    @api set empData(value) {
        this._empData = value;
        if(value !== null){
            this.getExisitingResignationDetails();
        }
    }
    get empData() {
        return this._empData;
    }
    getExisitingResignationDetails() {
        // Additional value can be queried
        this.fields = [
            { req: false, name: 'Employee_Name__c', readonly: true, value: this.empData.Id },
            { req: true, name: 'Reason__c', readonly: false },
            { req: false, name: 'Remarks__c', readonly: false }
        ];
        this.loaded = true;
    }
    openModal() {
        this.isModalOpen = true;
    }
    closeModal() {
        this.isModalOpen = false;
    }

    async handleSubmit(event) {
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        let reason;
        let remarks;
        if (inputFields) {
            inputFields.forEach(field => {
                if (field.fieldName == 'Reason__c') {
                    reason = field.value;
                }
                if (field.fieldName == 'Remarks__c') {
                    remarks = field.value;
                }
            })
        }
        if (reason === null || reason?.trim() === '') {
            return this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please fill all the required fields.',
                    variant: 'error'
                })
            )
        }
        try {
            this.isModalOpen = false;
            this.loaded = false;
            await raiseResignation({ employeeId: this.empData.Id, addedById: this.empData.Id, reason: reason, remarks: remarks });
            this.loaded = true;
            //this.disableResignationBtn = true;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Your Resignation Request has been raised',
                    variant: 'success'
                })
            )
        } catch (error) {
            this.loaded = true;
            this.dispatchEvent(new ShowToastEvent(getErrorBody(error, 'sticky')));
        }
    }

    @wire(getMyResignationRecords)
    wiredResignations({ error, data }) {
        if (data) {
            this.resignations = data.map((record, index) => {
                if(record.Resignation_Status__c !== 'Withdrawn'){
                    //this.disableResignationBtn = true;
                }
                return {
                    ...record, serialNumber: index + 1
                }
            });
            this.showList = true;
        } else if (error) {
            this.error = error;
        }
    }


    handleRowClick(event) {
        const recordId = event.currentTarget.dataset.id;
        this.selectedRow = this.resignations.find(resignation => resignation.Id === recordId);
        if (this.selectedRow !== null) {
            this.showRecord = true;
            this.showList = false;
        }
    }

    handleReceive(e){
        const currentRecord = e.detail;
        this.resignations.forEach(resignation =>{
            if(currentRecord.Id == resignation.Id){
                resignation.Resignation_Status__c = 'Withdrawn';
            }
        })
    }
    closeDetail(e) {
        this.selectedRow = null;
        this.showRecord = false;
        this.showList = true;
    }
}