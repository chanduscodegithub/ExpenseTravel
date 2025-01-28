import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getTemplateFiles from '@salesforce/apex/GoogleDriveIntegrationNew.getTemplateFiles';
// import mergeAndDownloadTemplate from '@salesforce/apex/TemplateProcessor.mergeAndDownloadTemplate';
import replaceVariablesAndDownload from '@salesforce/apex/GoogleDocController.replaceVariablesAndDownload';
import sendEmailWithAttachment from '@salesforce/apex/GoogleDocController.sendEmailWithAttachment';



export default class OfferLetterRollout extends LightningElement {
    @track templateOptions = [];
    @track selectedTemplate;
    @track selectedFormat = 'DOCX';
    @track recordId;
    
    formatOptions = [
        { label: 'DOCX', value: 'DOCX' },
        { label: 'PDF', value: 'PDF' }
    ];

    // Fetch templates from Google Drive folder (replace with actual folder ID)
    connectedCallback() {
        const folderId = '1aOXMUYXPvMeDHADrJqztI7nOVzlADhTK'; // Replace with your folder ID
        
        getTemplateFiles({ folderId: folderId})
            .then((result) => {
                this.templateOptions = result.map((file) => {
                    return { label: file.fileName, value: file.fileId };
                });
                console.log('Template Options Are',this.templateOptions);
            })
            .catch((error) => {
                this.showToast('Error', 'Error fetching templates: ' + error.body.message, 'error');
            });
    }

    handleTemplateChange(event) {
        this.selectedTemplate = event.detail.value;
        console.log(' this.selectedTemplate', this.selectedTemplate);
    }

    handleFormatChange(event) {
        this.selectedFormat = event.detail.value;
    }


   async handleDownload() {
        try {
             if (!this.selectedTemplate) {
            this.showToast('Error', 'Please select a template!', 'error');
            return;
        }
            console.log('RecordId',this.recordId);
            const base64Data = await replaceVariablesAndDownload({ 
                recordId: 'a6WDX0000004xSH2AY', 
                documentId: this.selectedTemplate 
            });
            

            // Determine file type based on selected format
            const mimeType = this.selectedFormat === 'PDF' ? 'application/pdf' : 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
            const fileExtension = this.selectedFormat.toLowerCase();

            // Convert Base64 to Blob
            const blob = new Blob([Uint8Array.from(atob(base64Data), c => c.charCodeAt(0))], {
                type: 'application/pdf' // Assuming PDF type
            });
            // Trigger download
            const link = document.createElement('a');
            link.href = window.URL.createObjectURL(blob);
            link.download = 'UpdatedDocument.pdf';
            link.click();
        } catch (error) {
            console.error('Error downloading document:', error);
        }
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(event);
    }

    handleRollOut() {
        sendEmailWithAttachment({ recordId: 'a6WDX0000004xSH2AY',documentId: this.selectedTemplate})
            .then(result => {
                console.log('Email sent successfully:', result);
            })
            .catch(error => {
                console.error('Error sending email:', error);
            });
    }
}