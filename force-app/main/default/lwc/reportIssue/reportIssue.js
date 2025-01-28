import { LightningElement } from 'lwc';
import createIssue from '@salesforce/apex/ReportIssueClass.createIssue';
//import uploadFile from '@salesforce/apex/ReportIssueClass.uploadFile'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class ReportIssue extends LightningElement {
    description = '';
    fileData;
    recId;
    base64 = '';
    fileName = '';
    spinnerFlag = false;


    openfileUpload(event) {
        this.spinnerFlag = true;
        const file = event.target.files[0];
        var reader = new FileReader();
        this.fileName = file.name;

        reader.onload = () => {
            this.base64 = reader.result.split(',')[1];
            //console.log('base64', this.base64);
            this.fileData = {
                'filename': this.fileName,
                'base64': this.base64
            }
        }
        reader.readAsDataURL(file);
        this.spinnerFlag = false;
    }
    onDescriptionChange(event) {
        this.description = event.target.value;
    }
    handleSubmit(event) {
        let checkFlag = false;
        this.spinnerFlag = true;
        if (this.description == '' || this.description == null) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: "Description is required to report an issue!",
                    variant: 'error'
                })
            );
            this.spinnerFlag = false;
            checkFlag = true;
        }
        if (checkFlag) {
            return;
        }
        createIssue({ s: this.description, base64: this.base64, filename: this.fileName }).then(res => {
            //console.log('res --> ', res);
            this.recId = res;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Thank you for reporting the issue, please make a note of reference id : ' + res,
                    variant: 'success'
                })
            );
            setTimeout(() => {
                this.spinnerFlag = false;
                this.dispatchEvent(new CustomEvent("getflagvalue", {
                    detail: false
                }));
            }, 5000);
        }).catch((error) => {
            //console.log("some error in code:", error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Failed',
                    message: "Error happened while uploading!",
                    variant: 'error'
                })
            );
            setTimeout(() => {
                this.spinnerFlag = false;
                this.dispatchEvent(new CustomEvent("getflagvalue", {
                    detail: false
                }));
            }, 5000);
        });
    }
    handleCancel() {
        this.dispatchEvent(new CustomEvent("getflagvalue", {
            detail: false
        }));
    }
}