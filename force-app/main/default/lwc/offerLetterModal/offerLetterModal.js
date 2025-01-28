import { LightningElement, api } from 'lwc';
import createOfferLetter from '@salesforce/apex/OfferLetterController.createOfferLetter';

export default class OfferLetterModal extends LightningElement {
    @api candidateName = '';
    @api position = '';
    @api offerLetters = [];
    @api salary = '';
    @api joiningDate = '';

    handleInputChange(event) {
        const field = event.target.label;
        if (field === 'Candidate Name') {
            this.candidateName = event.target.value;
        } else if (field === 'Position') {
            this.position = event.target.value;
        } else if (field === 'Salary') {
            this.salary = event.target.value;
        } else if (field === 'Joining Date') {
            this.joiningDate = event.target.value;
        }
    }

    handleSubmit() {
        // Logic for submitting the new offer letter record
      createOfferLetter({
            candidateName: this.candidateName,
            position: this.position,
            salary: this.salary,
            joiningDate: this.joiningDate
        })
        .then((newOfferLetter) => {
            console.log('New Offer Letter Created:', newOfferLetter);
            this.offerLetters = [...this.offerLetters, newOfferLetter]; // Add the new offer letter to the data table
            this.closeModal(); // Close the modal after submitting
        })
        .catch((error) => {
            console.error('Error creating offer letter:', error);
        });
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('closemodal'));
    }
}