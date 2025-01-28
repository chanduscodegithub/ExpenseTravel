import { LightningElement,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import saveLead from '@salesforce/apex/importLeadController.saveLead';
import sendEmail from '@salesforce/apex/importLeadController.sendEmail';
import RecurrenceTimeZoneSidKey from '@salesforce/schema/Task.RecurrenceTimeZoneSidKey';

export default class ImportLeads extends LightningElement {
    @track fileName;
    @track csvRecords = [];
    @track isFileUploaded = false;
    @track isShowModal = false;
    @track showSpinner = false;
    @track isShowLeadCSV = true;
    @track successCount;
    @track errorCount;
    @track successResult;
    @track errorResult;
    @track isShowSuccessResult = false;
    @track isShowErrorResult = false;
    @track isShowDuplicateEmails = false;
    @track duplicateEmailCount;
    @track duplicateEmailResult;
    @track successInsertResult;
    @track successUpdateResult;
    @track successInsertCount;
    @track successUpdateCount;
    @track isShowInsertResult = false;
    @track isShowUpdateResult = false;

    handleFileChange(event){
        var allowedExtensions = /(\.csv)$/i;
        var filePath = event.target.files[0].name;
        if(!allowedExtensions.exec(filePath)){
            this.dispatchEvent(new ShowToastEvent({
                title: 'Allowed only .csv file',
                message: '',
                variant: 'warning',
                mode: 'dismissable'
            }), );
            return;
        }
        const file = event.target.files[0];
        if (file) {
            this.fileName = file.name;
            this.isFileUploaded = true;
            this.readFile(file);
        }
    }

    readFile(file) {
        const reader = new FileReader();
        reader.onload = () => {
            this.parseCSV(reader.result);
        };
        reader.readAsText(file);
    }

    parseCSV(csvData) {
        // Parse CSV data and convert it into JavaScript objects
        // Example parsing logic:
        const lines = csvData.split('\n');

        // Extract headers from the first line
        const headers = lines[0].split(',');

        // Extract headers from the first line
        const csvHeaders = lines[0].split(',').map(header => header.trim()); // Trim whitespace and special characters
        console.log('csvHeaders::'+JSON.stringify(csvHeaders));

        // Define expected headers
        const expectedHeaders = ['FirstName', 'LastName', 'EmailAddress', 'Phone', 'Country', 'LeadStatus', 'LeadSource', 'Company', 'Title'];

        // Check if all expected headers are present in the CSV file
        const missingHeaders = this.getMissingHeaders(csvHeaders, expectedHeaders);
        if (missingHeaders.length > 0) {
            // Throw an error if any expected headers are missing
            this.isFileUploaded = false;
            this.fileName = '';
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'CSV file is missing headers: ['+missingHeaders.join(', ') +']',
                variant: 'error',
                mode: 'dismissable'
            }), );
            return;
        }

        // Check if CSV headers match the expected headers
        if (!this.areHeadersValid(csvHeaders, expectedHeaders)) {
            // Throw an error if headers don't match
            this.isFileUploaded = false;
            this.fileName = '';
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'CSV file header is not matching. Please use these Header: ['+expectedHeaders +']',
                variant: 'error',
                mode: 'dismissable'
            }), );
            return;
        }

        this.csvRecords = [];
        for(let i = 1; i < lines.length; i++) {
            const data = lines[i].split(',');
            const record = {};
            for(let j = 0; j < headers.length; j++) {
                record[headers[j].replace('\r','')] = data[j].replace('\r','');
            }
            this.csvRecords.push(record);
        }

        if(this.csvRecords.length > 0){
            this.isShowModal = true;
        }
    }

    areHeadersValid(csvHeaders, expectedHeaders) {
        // Check if all expected headers are present in the CSV file headers
        return expectedHeaders.every(header => csvHeaders.includes(header));
    }

    getMissingHeaders(csvHeaders, expectedHeaders) {
        // Find and return the headers that are missing in the CSV file
        return expectedHeaders.filter(header => !csvHeaders.includes(header));
    }

    handleClosePopup(){
        this.isShowModal = false;
        this.isFileUploaded = false;
        this.fileName = '';
        this.csvRecords = [];
        this.isShowLeadCSV = true;
        this.successCount = '';
        this.errorCount = '';
        this.successResult = '';
        this.errorResult = '';
        this.duplicateEmailCount ='';
        this.duplicateEmailResult ='';
        this.isShowDuplicateEmails = false;
        this.isShowInsertResult = false;
        this.isShowUpdateResult = false;
        this.isShowErrorResult = false;
    }

    handleSubmit(){
        console.log('processData::'+JSON.stringify(this.csvRecords));

        this.showSpinner = true;
        saveLead({
            leadWrap : this.csvRecords
        })
        .then(result => {
            console.log('result::'+JSON.stringify(result));
            if(result.status == 'Success'){
                this.isShowLeadCSV = false;
                this.successCount = result.successCount;
                this.errorCount = result.errorCount;
                this.successResult = result.successResult;
                this.errorResult = result.errorResult;
                if(this.successResult.length > 0){
                    this.isShowSuccessResult = true;
                }
                if(this.errorResult.length > 0){
                    this.isShowErrorResult = true;
                }else{
                    this.isShowErrorResult = false;
                }

                this.successInsertResult = result.successInsertResult;
                this.successUpdateResult = result.successUpdateResult;
                this.successInsertCount = result.successInsertCount;
                this.successUpdateCount = result.successUpdateCount;
                if(this.successInsertResult.length > 0){
                    this.isShowInsertResult = true;
                }else{
                    this.isShowInsertResult = false;
                } 
                if(this.successUpdateResult.length > 0){
                    this.isShowUpdateResult = true;
                }else{
                    this.isShowUpdateResult = false;
                }

                this.duplicateEmailCount = result.duplicateEmailsCount;
                this.duplicateEmailResult = result.duplicateEmails;
                if(this.duplicateEmailResult.length > 0){
                    this.isShowDuplicateEmails = true;
                }else{
                    this.isShowDuplicateEmails = false;
                }
                
                this.showSpinner = false;
            }else if(result.status == 'Error'){
                this.showSpinner = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: result.errorMessage,
                    message: '',
                    variant: 'error',
                    mode: 'dismissable'
                }), );
                return;
            }
        })
        .catch(error =>{
            this.showSpinner = false;
            console.log('error::'+JSON.stringify(error));
        })
    }

    handleSendEmail(){
        this.isShowModal = false;
        this.isFileUploaded = false;
        this.isShowLeadCSV = true;
        this.fileName = '';
        this.csvRecords = [];
        console.log('successCount::'+this.successCount);
        console.log('errorCount::'+this.errorCount);
        console.log('successResult::'+JSON.stringify(this.successResult));
        console.log('errorResult::'+JSON.stringify(this.errorResult));

        this.showSpinner = true;
        sendEmail({
            successsInsertCount : this.successInsertCount,
            successUpdateCount : this.successUpdateCount,
            successsInsertResult : this.successInsertResult,
            successUpdateResult : this.successUpdateResult,
            errorCount : this.errorCount,
            errorResult : this.errorResult,
            duplicateEmailCount : this.duplicateEmailCount,
            duplicateEmailResult : this.duplicateEmailResult
        })
        .then(result =>{
            console.log('result::'+JSON.stringify(result));
            this.handleClosePopup();
            if(result.status == 'Success'){
                this.showSpinner = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Email Sent Successfully!',
                    variant: 'success',
                    mode: 'dismissable'
                }), );
                return;
            }else if(result.status == 'Error'){
                this.showSpinner = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: result.errorMessage,
                    message: '',
                    variant: 'error',
                    mode: 'dismissable'
                }), );
                return;
            }
        })
        .catch(error =>{
            this.showSpinner = false;
            console.log('error::'+JSON.stringify(error));
        })
    }
}