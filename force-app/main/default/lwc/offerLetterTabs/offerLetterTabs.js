import { LightningElement, track, wire } from 'lwc';
import getOfferLetters from '@salesforce/apex/OfferLetterController.getOfferLetters';
import generateOfferLetterPDF from '@salesforce/apex/OfferLetterController.generateOfferLetterPDF';
import sendOfferLetterEmailApex from '@salesforce/apex/OfferLetterController.sendOfferLetterEmail';
import createOfferLetter from '@salesforce/apex/OfferLetterController.createOfferLetter';
import IMAGES from '@salesforce/resourceUrl/offerImages';


export default class OfferLetterTabs extends LightningElement {
    @track offerLetters = [];
    @track selectedOfferLetters = [];
    @track isModalOpen = false;
    @track candidateName = '';
    @track position = '';
    @track salary = '';
    @track joiningDate = '';
    @track activeTab = 'offerLetterTab'; // Default active tab
    selectedRecord = {}; // To store the selected offer letter record details
    showDetailsSection = false; // Controls the display of the details section
    showTabs = true;
    approvalTab=false;
    // Columns for Offer Letter Data Table
    columns = [
        { label: 'Status', fieldName: 'Status__c' },
        { label: 'Date', fieldName: 'Date__c', type: 'date' },
        { label: 'Candidate Name', fieldName: 'Candidate_Name__c' },
        { label: 'Address', fieldName: 'Address__c' },
        { label: 'Designation', fieldName: 'Designation__c' },
        { type: 'checkbox', label: 'Select', fieldName: 'selected' }
    ];

    @track timelineData = [
        {
            id: '1',
            isFirst:true,
            name: 'C0655 - Suresh Padmanabhan request has been sent for approval',
            timestamp: '21-Oct-2024 05:59 PM',
            avatar: 'https://via.placeholder.com/40',
            message: "",
            status: '',
            email:''
        },
        {
            id: '2',
            isFirst:false,
            name: 'C0712 - Ravi Shankar K',
            timestamp: '21-Oct-2024 06:03 PM',
            avatar: 'https://via.placeholder.com/40',
            message: '',
            status: 'Approved',
            email:'ravi.kasinadhuni@crmit.com'
        },
        {
            id: '3',
            isFirst:false,
            name: 'C0024 - Saritha P',
            timestamp: '21-Oct-2024 08:24 PM',
            avatar: 'https://via.placeholder.com/40',
            message: '',
            status: 'Approved',
            email:'psaritha@crmit.com'
        },
        {
            id: '4',
            isFirst:false,
            name: 'C0003 - Vinod Reddy',
            timestamp: '21-Oct-2024 08:57 PM',
            avatar: 'https://via.placeholder.com/40',
            message: '',
            status: 'Approved',
            email:'vinod@crmit.com'
        }
    ];
    @track isGenerateDisabled = true;
    @track isEmailDisabled = true;

    // Fetch Offer Letters from Apex
    @wire(getOfferLetters)
    wiredOfferLetters({ error, data }) {
        if (data) {
            this.offerLetters = data;
            console.log('offerletters', this.offerLetters);
        } else if (error) {
            console.error('Error fetching offer letters:', error);
        }
    }


    verticalLine = IMAGES + '/offerImages/verticalLine.png';
    // Handler when a row is clicked, showing the details of the clicked offer letter
    showDetails(event) {
        const recordId = event.currentTarget.dataset.recordId;
        console.log('RecordId', recordId);
        this.selectedRecord = this.offerLetters.find(record => record.Id === recordId);
        this.showDetailsSection = true; // Show details section
        this.showTabs = false;
    }

    handleApprovalModal(){
        this.showDetailsSection=false;
        this.approvalTab=true;
    }

    // Back button handler to go back to the records list view
    backToRecords() {
        this.showDetailsSection = false; // Hide details section and show records list
    }

    // Approve offer letter handler (example functionality)
    approveOffer() {
        console.log('Offer approved for:', this.selectedRecord.Candidate_Name__c);
        // Implement your approval logic here
    }

    closeModal() {
        this.isModalOpen = false;
    }
    // Submit a new offer letter and update the data table
    submitOfferLetter() {
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
    }

    // Handle row selection in the data table
    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedOfferLetters = selectedRows;
        this.isGenerateDisabled = selectedRows.length === 0;
        this.isEmailDisabled = selectedRows.length === 0;
    }

    switchTab(event) {
        const selectedTab = event.target.dataset.tab;
        console.log('Selected Tab:', selectedTab);

        const allTabs = this.template.querySelectorAll('.tab-panel');
        const allTabButtons = this.template.querySelectorAll('.tab-button');

        // Hide all tabs and remove the active class from buttons
        allTabs.forEach((tab) => {
            tab.classList.add('slds-hide'); // Hide the tab
            tab.classList.remove('active'); // Optional, in case "active" is on panels too
        });
        allTabButtons.forEach((button) => button.classList.remove('active'));

        // Show the selected tab and set the active class on the button
        const selectedTabPanel = this.template.querySelector(`.tab-panel[data-tab="${selectedTab}"]`);
        if (selectedTabPanel) {
            selectedTabPanel.classList.remove('slds-hide'); // Show the selected tab
            selectedTabPanel.classList.add('active'); // Show the selected tab
        }

        event.target.classList.add('active'); // Highlight the clicked button
        this.activeTab = selectedTab; // Update the active tab (optional)
    }


    // Handle input changes for the Offer Upload Form
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

    // Open the modal to add a new record
    openNewOfferLetterModal() {
        this.isModalOpen = true;
    }

    // Close the modal
    closeModal() {
        this.isModalOpen = false;
    }

    // Generate PDF for selected records
    generatePDF() {
        if (this.selectedOfferLetters.length > 0) {
            generateOfferLetterPDF({ offerLetterIds: this.selectedOfferLetters.map(record => record.Id) })
                .then(result => {
                    console.log('PDF generated:', result);
                })
                .catch(error => {
                    console.error('Error generating PDF:', error);
                });
        }
    }

    // Send email for selected offer letters
    sendOfferLetterEmail() {
        if (this.selectedOfferLetters.length > 0) {
            sendOfferLetterEmailApex({ offerLetterIds: this.selectedOfferLetters.map(record => record.Id) })
                .then(result => {
                    console.log('Email sent:', result);
                })
                .catch(error => {
                    console.error('Error sending email:', error);
                });
        }
    }
}