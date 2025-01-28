import { LightningElement, track } from 'lwc';
import { createRecord } from 'lightning/uiRecordApi';
import CANDIDATE_OBJECT from '@salesforce/schema/Candidate__c';
import FIRST_NAME_FIELD from '@salesforce/schema/Candidate__c.First_Name__c';
import LAST_NAME_FIELD from '@salesforce/schema/Candidate__c.Last_Name__c';
import EMAIL_FIELD from '@salesforce/schema/Candidate__c.Email__c';

export default class CreateCandidate extends LightningElement {
    @track firstName = '';
    @track lastName = '';
    @track email = '';

    handleFirstNameChange(event) {
        this.firstName = event.target.value;
    }

    handleLastNameChange(event) {
        this.lastName = event.target.value;
    }

    handleEmailChange(event) {
        this.email = event.target.value;
    }

    handleCreateCandidate() {
        const fields = {};
        fields[FIRST_NAME_FIELD.fieldApiName] = this.firstName;
        fields[LAST_NAME_FIELD.fieldApiName] = this.lastName;
        fields[EMAIL_FIELD.fieldApiName] = this.email;
        const recordInput = { apiName: CANDIDATE_OBJECT.objectApiName, fields };

        createRecord(recordInput)
            .then(candidate => {
                // Handle successful candidate creation
                alert(`Candidate created with ID: ${candidate.id}`);
                // Clear input fields
                this.firstName = '';
                this.lastName = '';
                this.email = '';
            })
            .catch(error => {
                // Handle error
                alert(`Error creating candidate: ${error.body.message}`);
            });
    }
}