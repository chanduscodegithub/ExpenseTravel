import { LightningElement, api, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import ClearTaxGSTAPI from '@salesforce/apex/ClearTaxGSTAPI.getPreSignedURL';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class UploadCallAPI extends NavigationMixin(LightningElement) {
    @api recordId;
    @track isLoading = false;
    @track validationMessage = ''; // Store the validation message

    handleCancel() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }

    handleConfirm() {
        this.isLoading = true;

        // Call the Apex method
        ClearTaxGSTAPI({ recordId: this.recordId })
            .then((result) => {
                if (result === 'Success') {
                    // API call is successful, show success toast and navigate to the record page
                    const toastEvent = new ShowToastEvent({
                        title: 'Note',
                        message: 'Check the response if the file was successfully uploaded',
                        variant: 'info',
                    });
                    this.dispatchEvent(toastEvent);
                    this.isLoading = false;
                    this.dispatchEvent(new CloseActionScreenEvent());

                    // Navigate to the record page after the API call is successful
                    setTimeout(() => {
                        window.location.reload();
                    }, 6000);
                } else {
                    // Set the validation message and display it as a toast
                    this.validationMessage = result;
                    const toastEvent = new ShowToastEvent({
                        title: 'Validation Error',
                        message: this.validationMessage,
                        variant: 'error',
                    });
                    this.dispatchEvent(toastEvent);
                    this.isLoading = false;
                }
            })
            .catch((error) => {
                console.error('Error calling Apex method: ', error);
                const toastEvent = new ShowToastEvent({
                    title: 'Error',
                    message: 'Error in calling the API',
                    variant: 'error',
                });
                this.dispatchEvent(toastEvent);
                this.dispatchEvent(new CloseActionScreenEvent());
                this.isLoading = false; // Hide the spinner on error
            });
    }
}