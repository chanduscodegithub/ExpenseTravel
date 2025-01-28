import { LightningElement, track, api,wire} from 'lwc';
import getCandidateDetails from '@salesforce/apex/ResourceOnboardingController.getCandidateDetails';
import getApplication from '@salesforce/apex/ResourceOnboardingController.getJobApplication';
import getSelectedApplication from '@salesforce/apex/ResourceOnboardingController.getSelectedApplication';
import getAgreementUrl from '@salesforce/apex/ResourceOnboardingController.getAgreementUrl';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import uploadFileToGoogleDrive from '@salesforce/apex/GoogleDriveIntegrationNew.uploadFileToGoogleDrive';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import POSITION_OBJECT from '@salesforce/schema/Position__c'; 
import saveCandidateDetails from '@salesforce/apex/ResourceOnboardingController.saveCandidateDetails';
import fetchEmployeeContracts from '@salesforce/apex/ResourceOnboardingController.fetchEmployeeContracts';
import getProjects from '@salesforce/apex/ResourceOnboardingController.getProjects';
import getActiveApplications from '@salesforce/apex/ResourceOnboardingController.getActiveApplications';
import sendEmailToFinance from '@salesforce/apex/ResourceOnboardingController.sendEmailToFinance';
import createEmployeeRecord from '@salesforce/apex/ResourceOnboardingController.createEmployee';
import saveOnboarding from '@salesforce/apex/ResourceOnboardingController.saveOnboarding';
import getOnboardingStatus from '@salesforce/apex/ResourceOnboardingController.getOnboardingStatus';
import { updateRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import getHiringStatus from '@salesforce/apex/ResourceOnboardingController.getHiringStatus'
import { getRecord, getRecordNotifyChange } from 'lightning/uiRecordApi';
import HIRING_STATUS_FIELD from '@salesforce/schema/Position__c.Status__c';
import ONBOARDING_STATUS from '@salesforce/schema/Position__c.Onboarding_Status__c';
import EMPLOYEE_EMAIL_FIELD from '@salesforce/schema/Employee__c.Email_ID__c';
import { refreshApex } from '@salesforce/apex';
import EMPLOYEE_ID_FIELD from '@salesforce/schema/Employee__c.EmployeeID__c';
const FIELDS = [EMPLOYEE_EMAIL_FIELD, EMPLOYEE_ID_FIELD];
import ACCOUNT_NAME_FIELD from '@salesforce/schema/Account.Name';
import EMPLOYEE_RECORD_FIELD from '@salesforce/schema/Position__c.Employee_Record__c';

export default class ResourceOnboarding extends NavigationMixin(LightningElement) {
    @track record;
    @track vendorName;
    @track onboardingButtonLabel;
    @track assetsClass;
    @track sowClass;
    @track firstModalNext='Save & Next'
    @track exisitingRecord=false;
    @track sowSent;
    @track isThirdModalOpen=false;
    @track noJobApplicationFlag=false;
    @track noJobApplication=false;
    @track noApplicationSelected=false;
    @track noSelectedFlag=false;
    @track hiringStatus;
    @track error;
    @track isModalOpen=false;
    @track isModalDisabled = false;
    @track isSubmitDisabled=false;
    @track isSecondModalOpen = false;
    @track selectedConsultant;
    @track contractorName = '';
    @track bgvCheck;
    accountId;
    @track isProjectsLoaded=false;
    @track consultantEmail='';
    @track isCorptoCorp=false;
    @track selectedNatureOfEngagements;
    @track natureOfEngagementsValues;
    @track eligibleToHireYesorNo='Yes';
    @track isProjectExtendedFlag;
    @track reportingManager='';
    @track consultantId;
    @track contracts = [];
    @track showModal = false;
    @track itAuditCompleted;
    @track showVisaType = false;
    @track documentStatus = {};
    @track documentUploadStatus = [];
    @track showHeading = false;
    @track assetsProvided;
    @track isCityDisabled = true;
    @track abnTrue = false;
    @track esnTrue=false;
    isVendorNotFound = false;
    @track esnNumber;
    @track abnNumber;
    @track australia=false;
    @track Usa=false;
    @track isInvalidAbn = false;
    @track isInvalidEsn=false;
    @track skills;
    @track extendedDate;
    @track isError = false;
    @api recordId;
    @api fileName;
    @api fileData;
    @track regionValues;
    @track cityValues;
    @track selectedRegion = '';
    @track selectedCity = '';
    @track address;
    @track agreementValues;
    @track selectedAgreementType = '';
    @track visaValues;
    @track employeeRecordId;
    @track isRecordCreated = false; 
    @track selectedVisaType='';
    @track documents;
    @track agreementStartDate;
    @track agreementEndDate;
    @track projectStartDate;
    @track projectEndDate;
    contractMessage;
    @track abnYesChecked = false;
    @track abnNoChecked = true;
    @track esnYesChecked=false;
    @track esnNoChecked=false;
    isPicklistDataLoaded = false;
    isCandidateDataLoaded = false;
    @track selectedProjectStatus;
    @track projectStatusValues;
    @track picklistValuesObj;
    @track eligibleToHire=true;
    @track reasonForNotEligibleToRehire;
    @track contractorEmail;
    @track isProjectExtended=false;
    @track projects;
    @track showAssetSelection = false;
    @track selectedAssets = [];
    @track assetOptions = [];
    documentUrl;
    @track position={};
    @api candidateRecordId;
    @track onboardingStatus;
    employeeRecordField = EMPLOYEE_RECORD_FIELD;

    @wire(getObjectInfo, { objectApiName:  POSITION_OBJECT})
    objectInfo;

    handleClose() {
        this.noJobApplication = false;
        this.isModalOpen=false;
        this.noApplicationSelected=false;
        this.isSecondModalOpen = false;
        this.isThirdModalOpen=false;
    }

    closeModal(){
        this.showModal=false;
        this.isSecondModalOpen = true;
    }

    @wire(getRecord, { recordId: '$recordId', fields: [HIRING_STATUS_FIELD] })
    wiredPosition({ error, data }) {
        if (data) {
            this.position = data;
            this.refreshRecord();
        } else if (error) {
            console.error('Error fetching position data:', error);
        }
    }

    @wire(getRecord, { recordId: '$recordId', fields: [ONBOARDING_STATUS] })
    wiredOnboarding({ error, data }) {
        if (data) {
            this.onboardingStatus = data;
            this.refreshRecord();
        } else if (error) {
            console.error('Error fetching position data:', error);
        }
    }

    get isAgreementDisabled() {
        return this.isModalDisabled || this.documentUploadStatus.some(item => item.uploaded);
    }

    @wire(getPicklistValuesByRecordType, { objectApiName: POSITION_OBJECT, recordTypeId: '$objectInfo.data.defaultRecordTypeId' })
    newPicklistValues({ error, data }) {
        if (data) {
            this.error = null;
            this.picklistValuesObj = data.picklistFieldValues;

            let regionValuesList = data.picklistFieldValues.Country1__c.values;
            this.regionValues = regionValuesList.map(item => ({ label: item.label, value: item.value }));

            let agreementValuesList = data.picklistFieldValues.Agreement_Type__c.values;
            this.agreementValues = agreementValuesList.map(item => ({ label: item.label, value: item.value }));

            let natureOfEngagementsValuesList=data.picklistFieldValues.Nature_Of_Engagement__c.values;
            this.natureOfEngagementsValues = natureOfEngagementsValuesList.map(item => ({ label: item.label, value: item.value }));

            let assetsValuesList = data.picklistFieldValues.Assets__c.values;
            this.assetOptions = assetsValuesList.map(item => ({ label: item.label, value: item.value }));

            this.isPicklistDataLoaded = true;
            this.initializeDataIfReady();

        } else if (error) {
            this.error = JSON.stringify(error);
        }
    }

    handleRegionChange(event) {
        this.selectedRegion = event.detail.value;
        this.australia = this.selectedRegion === 'Australia';
        this.Usa=this.selectedRegion==='USA';
        this.showHeading = true;
        this.showVisaType = this.selectedRegion === 'Australia' || this.selectedRegion === 'USA';
        this.initializeDocumentUploadStatus(); 
        if (this.selectedRegion && this.picklistValuesObj && this.picklistValuesObj.City1__c) {
            let data = this.picklistValuesObj;
            let totalCityValues = data.City1__c;
            this.isCityDisabled = this.onboardingStatus==='Onboarded'? true:false;

            let controllerValueIndex = totalCityValues.controllerValues[this.selectedRegion];
            let cityPicklistValues = data.City1__c.values;
            let cityPicklists = [];

            cityPicklistValues.forEach(key => {
                for (let i = 0; i < key.validFor.length; i++) {
                    if (controllerValueIndex == key.validFor[i]) {
                        cityPicklists.push({
                            label: key.label,
                            value: key.value
                        });
                    }
                }
            })
            if (cityPicklists && cityPicklists.length > 0) {
                this.cityValues = cityPicklists;
            } else {
                this.cityValues = [];
            }

            let totalVisaValues=data.Visa_Type__c;
            let controllerVisaValueIndex = totalVisaValues.controllerValues[this.selectedRegion];
            let visaPicklistValues = data.Visa_Type__c.values;
            let visaPicklists = [];
            // Iterate the picklist values for the city field
            visaPicklistValues.forEach(key => {
                for (let i = 0; i < key.validFor.length; i++) {
                    if (controllerVisaValueIndex == key.validFor[i]) {
                        visaPicklists.push({
                            label: key.label,
                            value: key.value
                        });
                    }
                }
            })
            if (visaPicklists && visaPicklists.length > 0) {
                this.visaValues = visaPicklists;
            } else {
                this.visaValues = [];
            }
        }
    }

    handleVisaChange(event){
        this.selectedVisaType = event.detail.value;
    }

    handleCityChange(event){
        this.selectedCity = event.detail.value;
    }

    handleEndDateChange(even){
        this.agreementEndDate=even.detail.value;
    }

    handleAssetSelectionChange(event) {
        this.selectedAssets = event.detail.value;
    }

    handleAgreementChange(event){
        this.selectedAgreementType=event.detail.value;
        this.isCorptoCorp=this.selectedAgreementType=='Corp-to-Corp'?true:false;
    }

    handleProjectStatusChange(event){
        this.selectedProjectStatus=event.detail.value;
    }

    handleStartDateChange(event){
        this.agreementStartDate=event.detail.value;
        this.setContractEndDate();
        this.validateDates();
    }

    handleEndDateChange(event){
        this.agreementEndDate=event.detail.value;
        this.validateDates();
    }

    handleProjectStartDateChange(event){
        this.projectStartDate=event.detail.value;
        this.validateDates();
    }

    handleProjectEndDateChange(event){
        this.projectEndDate=event.detail.value;
        this.validateDates();
    }

    handleAddressChange(event){
        this.address=event.detail.value;
    }

    handlebgvCheckChange(even){
        this.bgvCheck=even.detail.value;
        this.isSubmitDisabled=false;
    }

    handlenatureOfEngagementsChange(event){
        this.selectedNatureOfEngagements=event.detail.value;
    }

    handleConsultantIdChange(event){
        this.consultantId=event.target.value;
    }

    handleConsultantEmailChange(event){
        this.consultantEmail=event.target.value;
    }

    setContractEndDate() {
        if (this.agreementStartDate) {
            let startDate = new Date(this.agreementStartDate);
            startDate.setFullYear(startDate.getFullYear() + 1);
            this.agreementEndDate = startDate.toISOString().split('T')[0];
        }
    }

    validateDates() {
        let valid = true;
        let errorMsg = '';

        if (this.agreementEndDate < this.agreementStartDate) {
            valid = false;
            errorMsg = 'Contract end date cannot be earlier than the start date.';
        } else if (this.projectStartDate && (this.projectStartDate < this.agreementStartDate || this.projectStartDate > this.agreementEndDate)) {
            valid = false;
            errorMsg = 'Project start date must be within the contract date range.';
        } else if (this.projectEndDate && (this.projectEndDate < this.projectStartDate || this.projectEndDate > this.agreementEndDate)) {
            valid = false;
            errorMsg = 'Project end date must be within the contract date range and after the project start date.';
        }  else if(this.extendedDate && (this.extendedDate < this.agreementStartDate || this.extendedDate > this.agreementEndDate)){
            valid = false;
            errorMsg = 'Extended date must be within the contract date range.';
        } else if(this.extendedDate && (this.extendedDate < this.projectStartDate || this.projectEndDate > this.extendedDate)){
            valid = false;
            errorMsg = 'Extended date must be after the Project date range.';
        }

        if (!valid) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: errorMsg,
                    variant: 'error'
                })
            );
        }
        return valid;
    }

    handleProjectExtendedChange(event){
        this.isProjectExtendedFlag=event.detail.value;
        this.isSubmitDisabled=false;
        this.isProjectExtended = this.isProjectExtendedFlag === 'Yes' ? true : false;
        this.extendedDate=this.isProjectExtended?this.extendedDate:null;
    }

    handleSaveCandidate() {
        const documentFields = {
            Agreement_Url__c: this.documentUploadStatus[0]?.fileUrl || '',
            Document_1__c: this.documentUploadStatus[1]?.fileUrl || '',
            Document_2__c: this.documentUploadStatus[2]?.fileUrl || '',
            Document_3__c: this.documentUploadStatus[3]?.fileUrl || '',
            Document_4__c: this.documentUploadStatus[4]?.fileUrl || '',
            Document_5__c: this.documentUploadStatus[5]?.fileUrl || '',
        };

        const candidateDetails = {
            SOW_Sent__c:this.sowSent=='Yes'?true:false,
            Vendor__c:this.accountId,
            Vendor_Name__c:this.vendorName,
            Employee_Record__c:this.employeeRecordId,
            Assets_Provided__c:this.assetsProvided=='Yes'?true:false,
            Assets__c:this.selectedAssets,
            Country1__c: this.selectedRegion,
            City1__c: this.selectedCity,
            Agreement_Type__c: this.selectedAgreementType,
            Visa_Type__c: this.selectedVisaType,
             ...documentFields,
            IT_Audit_Completed__c:this.itAuditCompleted=='Yes' ? true : false,
            Project_Start_Date__c:this.projectStartDate,
            Project_End_Date__c:this.projectEndDate,
            Contract_Start_Date__c:this.agreementStartDate,
            Contract_End_Date__c:this.agreementEndDate,
            Has_ABN_Number__c:this.abnYesChecked,
            ABN_Number__c:this.abnNumber,
            Has_CIN_Number__c:this.esnTrue,
            CIN_Number__c:this.esnNumber,
            Agreement_Sent__c:this.agreementSent,
            Project_Extended_Date__c:this.extendedDate,
            Technical_Capabilities__c:this.skills,
            Is_Project_Extended__c:this.isProjectExtendedFlag== 'Yes' ? true : false,
            Eligible_to_Re_Hire__c:this.eligibleToHireYesorNo=='Yes'?true:false,
            Reason_for_Not_Eligible_to_Re_hire__c:this.reasonForNotEligibleToRehire,
            Candidate_Address__c:this.address,
            BGV_Check__c:this.bgvCheck=='Yes'?true:false,
            Nature_Of_Engagement__c:this.selectedNatureOfEngagements,
            Consultant_Email__c:this.consultantEmail,
            Consultant_ID__c:this.consultantId
        };
        saveCandidateDetails({ jobId: this.recordId, candidateDetails: candidateDetails })
            .then(() => {
            })
            .catch(error => {
                console.error('Error saving candidate details:', error);
                this.showToast('Error', 'Error saving candidate details', 'error');
            });
        return saveCandidateDetails({ jobId: this.recordId, candidateDetails: candidateDetails });
    }
    handleSaveOnboarding(){
        saveOnboarding({jobId: this.recordId, onboardingDetail: this.onboardingStatus})
            .then((result) => {
                return refreshApex(this.wiredResult);
            })
            .then(() => {
                setTimeout(() => {
                    this.refreshRecordView();
                }, 1000);
            })
            .catch((error) => {
                console.error('Error saving candidate details:', error);
                this.showToast('Error', 'Error saving candidate details', 'error');
            });
    }
    refreshRecordView() {
        getRecordNotifyChange([{ recordId: this.recordId }]);
    }

    handleFileChange(event) {
        const docName = event.target.dataset.docName;
        const files = event.target.files;
        if (files.length > 0) {
            const file = files[0];
            const reader = new FileReader();
            reader.onload = () => {
                const fileData = reader.result.split(',')[1]; // Only the base64 part
                const fileName = docName === 'Upload DocuSign Agreement' ? `${this.contractorName}_Agreement` : `${this.contractorName}_${docName}`;
                this.updateDocumentStatus(docName, { fileName, fileData });
            };
            reader.readAsDataURL(file);
        }
    }

    handleFileSelect(event) {
        const docName = event.target.dataset.docName;
        const fileInput = this.template.querySelector(`input[data-doc-name="${docName}"]`);
        if (fileInput) {
            fileInput.click();
        }
    }

    handleRemoveFile(event) {
        const docName = event.target.dataset.docName;
        const index = this.documentUploadStatus.findIndex(item => item.document === docName);
        if (index !== -1) {
            this.documentUploadStatus[index].fileName = null;
            this.documentUploadStatus[index].fileData = null;
            this.documentUploadStatus = [...this.documentUploadStatus]; // refresh UI
        }
    }

    handleUpload(event) {
        const docName = event.target.dataset.docName;
        const index = this.documentUploadStatus.findIndex(item => item.document === docName);
        // Validation: Check if it's Corp to Corp and Vendor is blank
        if (this.isCorptoCorp && (!this.vendorName || this.vendorName.trim() === '')) {
            this.showToast('Error', 'Please select a Vendor before uploading.', 'error');
            return; // Stop further execution
        }

        if (index !== -1 && this.documentUploadStatus[index].fileData) {
            this.updateDocumentStatus(docName, { uploading: true, notStarted: false });

            // For Draft Agreement, send email to Finance team
            if (docName === 'Upload Draft Agreement') {
                sendEmailToFinance({
                    params: {
                        fileName: this.documentUploadStatus[index].fileName,
                        fileData: btoa(this.documentUploadStatus[index].fileData),
                        consultantName: this.contractorName
                    }
                })
                .then(() => {
                    this.updateDocumentStatus(docName, {
                        uploading: false,
                        uploaded: true,
                        sent:true,
                        uploadProgress: 100
                    });
                    this.agreementSent=true;
                    this.showToast('Success', 'Email sent to Finance Team successfully.', 'success');
                    this.handleSaveCandidate()
                    .then(() => {
                        this.onboardingStatus = 'In Progress';
                        this.cmpLabel = 'Continue the Onboarding Process';
                        this.onboardingButtonLabel = 'Continue Onboarding';
                        this.handleSaveOnboarding();
                    })
                    .catch(error => {
                        console.error('Error saving candidate details:', error);
                        this.showToast('Error', 'Error Uploading Candidate Document', 'error');
                    });
                })
                .catch(error => {
                    console.error('Error sending email to Finance Team: ', error);
                    this.updateDocumentStatus(docName, {
                        uploading: false,
                        notStarted: true
                    });
                    this.showToast('Error', 'Failed to send email to Finance Team.', 'error');
                });
            } else {
                // For other documents, keep the original upload logic
                uploadFileToGoogleDrive({
                    fileName: this.documentUploadStatus[index].fileName,
                    fileData: this.documentUploadStatus[index].fileData,
                    agreementType: this.selectedAgreementType,
                    vendorName: this.vendorName,
                    consultantName: this.contractorName,
                    region:this.selectedRegion
                })
                .then(result => {
                    this.updateDocumentStatus(docName, {
                        uploading: false,
                        uploaded: true,
                        uploadProgress: 100,
                        fileUrl: result.fileUrl
                    });
                    this.handleSaveCandidate()
                    .then(() => {
                        this.onboardingStatus = 'In Progress';
                        this.cmpLabel = 'Continue the Onboarding Process';
                        this.onboardingButtonLabel = 'Continue Onboarding';
                        this.handleSaveOnboarding();
                    })
                    .catch(error => {
                        console.error('Error saving candidate details:', error);
                        this.showToast('Error', 'Error Uploading Candidate Document', 'error');
                    });
                })
                .catch(error => {
                    console.error('Error uploading file: ', error);
                    this.updateDocumentStatus(docName, {
                        uploading: false,
                        notStarted: true
                    });
                });
            }
        }
    }

    handleView(event) {
        const docName = event.target.dataset.docName;
        const doc = this.documentUploadStatus.find(item => item.document === docName);
        if (doc && doc.fileUrl) {
            window.open(doc.fileUrl, '_blank'); // Open the file URL in a new tab
        } else {
            console.error('File URL is not available');
        }
    }
        
    handleDownload() {
      if (!this.selectedAgreementType) {
            this.isError = true;
            return;
        }
        this.isError = false;
        getAgreementUrl({
            region: this.selectedRegion,
            agreementType: this.selectedAgreementType
        })
        .then(result => {
            if (result) {
                window.open(result, '_blank');
            } else {
                console.error('No file URL returned');
            }
        })
        .catch(error => {
            console.error('Error fetching agreement URL:', error);
        });
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    handleAbnChange(event) {
        this.abnTrue = event.target.value == 'yes';
        this.isSubmitDisabled=false;
        if(this.abnTrue){
            this.abnYesChecked=true;
        }
        else{
            this.abnNoChecked=true;
            this.abnYesChecked=false;
            this.abnNumber = null;
            this.isInvalidAbn = false;
        }
    }

    handleToggle(event) {
        let target = event.target;
        // Ensure target is the button if SVG or path is clicked
        if (target.tagName === 'path') {
            target = target.closest('button');
        } else if (target.tagName === 'svg') {
            target = target.parentElement;
        }

        const sectionId = target.dataset.id;
        const content = this.template.querySelector(`.accordion-content[data-id="${sectionId}"]`);
        const chevron = target.querySelector('.chevron-icon');

        if (content && chevron) {
            if (content.classList.contains('show')) {
                content.classList.remove('show');
                chevron.classList.remove('rotate');
            } else {
                content.classList.add('show');
                chevron.classList.add('rotate');
            }
        }
    }

    handleEsnChange(event) {
        this.esnTrue = event.target.value == 'yes';
        this.isSubmitDisabled=false;
        if(this.esnTrue){
            this.esnYesChecked=true;
        }
        if (!this.esnTrue) {
            this.esnNoChecked=true;
            this.esnYesChecked=false;
            this.esnNumber = null;
            this.isInvalidEsn = false;
        }
    }

    handleAbnNumberChange(event) {
        this.abnNumber = event.target.value;
        this.isInvalidAbn = !this.isValidAbn(this.abnNumber)||null;
        this.isSubmitDisabled=false;
    }

    handleEsnNumberChange(event) {
        this.esnNumber = event.target.value;
        this.isSubmitDisabled=false;
        this.isInvalidEsn = !this.isValidEsn(this.esnNumber)||null;
    }

    handleExtendedDateChange(event) {
        this.isSubmitDisabled=false;
        this.extendedDate = event.detail.value;
        this.validateDates();
    }

    isValidEsn(ssn) {
        const ssnPattern = /^(?!666|000|9\d{2})\d{3}-(?!00)\d{2}-(?!0000)\d{4}$/;
        if (!ssnPattern.test(ssn)) {
            return false;
        }
        const parts = ssn.split('-');
        const area = parseInt(parts[0], 10);
        const group = parseInt(parts[1], 10);
        const serial = parseInt(parts[2], 10);
        if (area === 666 || area === 0 || group === 0 || serial === 0) {
            return false;
        }
        return true;
    }

    isValidAbn(abn) {
        if (abn.length !== 11 || !/^\d{11}$/.test(abn)) {
            return false;
        }

        // Subtract 1 from the first digit
        abn = abn.split('').map(Number);
        abn[0] -= 1;

        // Define weights
        const weights = [10, 1, 3, 5, 7, 9, 11, 13, 15, 17, 19];

        // Calculate the weighted sum
        let sum = 0;
        for (let i = 0; i < abn.length; i++) {
            sum += abn[i] * weights[i];
        }

        // Check if the sum is divisible by 89
        return sum % 89 === 0;
    }

    handleSkillsChange(event) {
        this.skills = event.target.value;
    }

    documentNamesMap = {
        'Australia': ['Upload Draft Agreement','Upload DocuSign Agreement','Passport Copy for Dependent Visa', 'Visa copy', 'GST Certificate'],
        'USA': ['Upload Draft Agreement','Upload DocuSign Agreement','Passport copy for H1B', 'Visa copy', 'ID - Drivers Licence/ State ID', 'W-9 form', 'Cancelled Check'],
        'India': ['Upload Draft Agreement','Upload DocuSign Agreement','Candidate KYC', 'PAN Card', 'Aadhar Card', 'GST Certificate', 'MSME Certification']
    };

    connectedCallback() {
        this.checkNoJobApplication();
        this.checkNoAppSelected();
        this.fetchHiringStatus();
        this.fetchCandidateDetails().then(() => {
                this.initializeDocumentUploadStatus();
                this.initializeDataIfReady();
                this.fetchProjects();
            }).catch(error => {
                console.error('Error fetching candidate details:', error);
            });
            this.fetchOnboardingStatus();
    }

    refreshRecord() {
        if (this.position && this.position.fields && this.position.fields.Status__c) {
            getRecordNotifyChange([{ recordId: this.recordId }]);
            if (this.position.fields.Status__c.value == 'Joining Awaited' || this.position.fields.Status__c.value == 'Joined/Onboarded') {
                this.hiringStatus = true;
            } else {
                this.hiringStatus = false;
            }
        } else {
            console.error('Position data is not yet available');
        }
        if(this.onboardingStatus && this.onboardingStatus.fields && this.onboardingStatus.fields.Onboarding_Status__c){
            getRecordNotifyChange([{ recordId: this.recordId }]);
            if (this.onboardingStatus.fields.Onboarding_Status__c.value=='In Progress') {
                this.onboardingButtonLabel = 'Continue Onboarding';
                this.cmpLabel='Continue the Onboarding Process';
                this.onboardingStatus='In Progress';
            } else if(this.onboardingStatus.fields.Onboarding_Status__c.value == 'Onboarded') {
                this.onboardingButtonLabel = 'Onboarded';
                this.cmpLabel='Onboarding Process Completed';
                this.onboardingStatus='Onboarded';
            }
            else{
                this.onboardingButtonLabel = 'Start Onboarding';
                this.cmpLabel='Start the Onboarding Process';
            }
        }
    }

    checkNoJobApplication(){
        getApplication({ positionId: this.recordId })
            .then(result => {
               if(result==false){
                   this.noJobApplicationFlag=true;
               }
            })
            .catch(error => {
                console.error('Error fetching getJobAplication:', error);
            });
    }

    checkNoAppSelected(){
       getSelectedApplication({ positionId: this.recordId })
        .then(result => {
            if(result==false){
                this.noSelectedFlag=true;
            }
        })
        .catch(error => {
            console.error('Error fetching getJobAplication:', error);
        });
    }

    fetchCandidateDetails() {
        return getCandidateDetails({ positionId: this.recordId })
            .then(result => {
                if (result) {
                    this.employeeRecordId=result.Employee_Record__c;
                    if(result.Employee_Record__c){
                        this.isRecordCreated=true;
                        this.consultantId=result.Employee_Record__r.EmployeeID__c;
                        this.consultantEmail=result.Employee_Record__r.Email_ID__c;
                    }
                    else{
                        this.consultantId=result.Consultant_ID__c;
                        this.consultantEmail=result.Consultant_Email__c;
                    }
                    this.sowSent=result.SOW_Sent__c?'Yes':'No';
                    this.sowClass=this.sowSent=='Yes'?'sowYes':'sowNo';
                    this.hiringStatus=result.Status__c=='Joining Awaited'|| result.Status__c=='Joined/Onboarded'?true:false;
                    this.candidateRecordId=String(result.Selected_Candidate__r.Id);
                    this.contractorName=result.Selected_Candidate__r.First_Name__c+' '+result.Selected_Candidate__r.Last_Name__c;
                    this.contractorEmail=result.Selected_Candidate__r?.Email__c || 'Not Provided';
                    this.accountId=result.Vendor__c;
                    this.agreementSent=result.Agreement_Sent__c;
                    this.vendorName=result.Vendor_Name__c;
                    let tempDiv = document.createElement('div');
                    tempDiv.innerHTML = result.Hiring_Manager_name__c;
                    var linkElement = tempDiv.querySelector('a');
                    var linkText = linkElement.textContent;
                    this.reportingManager = linkText;
                    this.selectedRegion = result.Country1__c || '';
                    this.selectedCity = result.City1__c || '';
                    if(this.selectedCity!=''){
                        this.isCityDisabled=this.onboardingStatus==='Onboarded'? true:false;
                    }
                    this.assetsProvided=result.Assets_Provided__c?'Yes':'No';
                    this.assetsClass=this.assetsProvided=='Yes'?'assetYes':'assetNo';
                    this.showAssetSelection=this.assetsProvided=='Yes'?true:false;
                    if (result.Assets__c !== null && result.Assets__c !== undefined) {
                        this.selectedAssets = result.Assets__c.split(';');
                    } else {
                        this.selectedAssets = [];
                    }
                    this.bgvCheck=result.BGV_Check__c?'Yes':'No';
                    this.skills=result.Technical_Capabilities__c;
                    this.selectedVisaType = result.Visa_Type__c || '';
                    this.selectedAgreementType = result.Agreement_Type__c || '';
                    this.itAuditCompleted = result.IT_Audit_Completed__c ? 'Yes' : 'No';
                    this.selectedNatureOfEngagements=result.Nature_Of_Engagement__c;
                    this.isCorptoCorp=this.selectedAgreementType=='Corp-to-Corp'?true:false;
                    if (result.Has_ABN_Number__c) {
                        this.abnYesChecked = result.Has_ABN_Number__c;
                        this.abnNoChecked = !result.Has_ABN_Number__c;
                        if(this.abnYesChecked){
                            this.abnTrue=true;
                        }
                    } else {
                        console.warn('Has_ABN_Number__c is undefined in the result');
                    }
                    if (result.Has_CIN_Number__c !== undefined) {
                        this.esnYesChecked = result.Has_CIN_Number__c;
                        this.esnNoChecked = !result.Has_CIN_Number__c;
                        if(this.esnYesChecked ){
                            this.esnTrue=true;
                        }
                    } else {
                        console.warn('Has_CIN_Number__c is undefined in the result');
                    }
                    this.abnNumber=result.ABN_Number__c||'';
                    this.esnNumber=result.CIN_Number__c||null;
                    this.agreementStartDate=result.Contract_Start_Date__c;
                    this.agreementEndDate=result.Contract_End_Date__c;
                    this.projectStartDate=result.Project_Start_Date__c;
                    this.projectEndDate=result.Project_End_Date__c;
                    this.extendedDate=result.Project_Extended_Date__c;
                    this.eligibleToHire=result.Eligible_To_Re_Hire__c;
                    this.eligibleToHireYesorNo=result.Eligible_To_Re_Hire__c?'Yes':'No';
                    this.reasonForNotEligibleToRehire=result.Reason_for_Not_Eligible_to_Re_hire__c;
                    this.isProjectExtendedFlag=result.Is_Project_Extended__c? 'Yes' : 'No';
                    this.isProjectExtended=result.Is_Project_Extended__c;
                    this.documents = {
                        Doc_0: result.Agreement_Url__c || '',
                        Doc_1: result.Document_1__c || '',
                        Doc_2: result.Document_2__c || '',
                        Doc_3: result.Document_3__c || '',
                        Doc_4: result.Document_4__c || '',
                        Doc_5: result.Document_5__c || ''
                    };
                    this.isCandidateDataLoaded = true;
                    this.initializeDataIfReady();
                    this.address=result.Candidate_Address__c!=null?result.Candidate_Address__c:result.Selected_Candidate__r.Candidate_Current_Location__c;
                }
            })
            .catch(error => {
                console.error('Error fetching candidate details:', error);
                throw error;
            });
    }

    fetchHiringStatus() {
        getHiringStatus({ positionId: this.recordId })
        .then(status => {
            this.hiringStatus = status;
        })
        .catch(error => {
            console.error('Error fetching hiring status:', error);
        });
    }

    fetchOnboardingStatus(){
        getOnboardingStatus({ positionId: this.recordId })
        .then(status => {
            this.onboardingStatus = status;
            if(this.onboardingStatus=='Onboarded'){
                this.cmpLabel='Onboarding Process Completed';
                this.onboardingButtonLabel='Onboarded';
                this.isCityDisabled=true;
                this.isSubmitDisabled=true;
                this.isModalDisabled=true;
                this.firstModalNext='Next';
            }else if(this.onboardingStatus=='In Progress'){
                this.cmpLabel='Continue the Onboarding Process';
                this.onboardingButtonLabel='Continue Onboarding';
            }else{
                this.cmpLabel='Start the Onboarding Process';
                this.onboardingButtonLabel='Start Onboarding';
            }
        })
        .catch(error => {
            console.error('Error fetching Onboarding status:', error);
        });
    }

    // Getter for vendor picker visibility
    get vendorPickerStyle() {
        return this.isVendorNotFound ? 'display: none;' : '';
    }

    // Getter for input field visibility
    get inputFieldStyle() {
        return this.isVendorNotFound ? '' : 'display: none;';
    }

    //Fetch Projects worked on for the existing employee Records
    fetchProjects() {
        this.isProjectsLoaded = false;
        if (!this.employeeRecordId) {
            this.projects = [];
        } 
        else {
            getProjects({ employeeId: this.employeeRecordId })
                .then(data => {
                    console.log('Project Data',data);
                    if(data.length>0){
                        console.log('Greater than one');
                        this.isProjectsLoaded = true;
                    }
                    this.projects = data.map(project => {
                        return {
                            ...project,
                            projectName: project.Project__r ? project.Project__r.Name : 'N/A'
                        };
                    });
                })
                .catch(error => {
                    this.projects = undefined;
                    console.error('Error fetching projects:', error);
                });
        }
    }
    initializeDataIfReady() {
        if (this.isPicklistDataLoaded && this.isCandidateDataLoaded && this.selectedRegion) {
            this.handleRegionChange({ detail: { value: this.selectedRegion } });
        }
    }

    initializeDocumentUploadStatus() {
        const documents = this.documentNamesMap[this.selectedRegion] || [];
        const isDraftAgreementUploaded = this.agreementSent;
         
        this.documentUploadStatus = documents.map((doc, index) => {
            const docIndex = index;
            const docField = `Doc_${docIndex}`;
            const storedUrl = this.documents && this.documents[docField];
            const isUploaded = doc === 'Upload Draft Agreement' && isDraftAgreementUploaded;
            const isSent = isDraftAgreementUploaded  && doc === 'Upload Draft Agreement';
            console.log('isSent',isSent,'this.agreementSent;',this.agreementSent);
            return {
                document: doc,
                uploaded: isUploaded || !!storedUrl,
                uploading: false,
                sent:isSent,
                uploadProgress: 0,
                progressBarStyle: '',
                notStarted: !storedUrl && !isUploaded,
                fileName: '',
                file: null,
                fileUrl: storedUrl || ''
            };
        });
    }

    handleConsultantChange(event){
        this.selectedConsultant=event.detail.value;
    }

    populateAgreementDetails() {
        if (this.previousApplications.length > 0) {
            const app = this.previousApplications[0];

            if (!this.selectedRegion) {
                this.selectedRegion = app.Region__c;
                this.handleRegionChange({ detail: { value: this.selectedRegion } });
            }

            if (!this.agreementStartDate) {
                this.agreementStartDate = app.Contract_Start_Date__c;
            }

            if (!this.agreementEndDate) {
                this.agreementEndDate = app.Contract_End_Date__c;
            }

            if (!this.selectedAgreementType) {
                this.selectedAgreementType = app.Agreement_Type__c;
            }

            if (!this.consultantId) {
                this.consultantId = app.Consultant_ID__c != null ? app.Consultant_ID__c : '';
            }

            if (!this.skills) {
                this.skills = app.Skills__c ? app.Skills__c : '';
            }

            if (!this.visaType) {
                this.visaType = app.Visa_Type__c;
            }

            if (!this.eligibleToHireYesorNo) {
                this.eligibleToHireYesorNo = app.Eligible_to_Re_Hire__c;
            }

            if (!this.reasonForNotEligibleToRehire) {
                this.reasonForNotEligibleToRehire = app.Reason_for_Not_Eligible_to_Re_hire__c == true ? app.Reason_for_Not_Eligible_to_Re_hire__c : '';
            }

            if(!this.employeeRecordId){
                this.employeeRecordId=app.Employee_Record__c;
                this.exisitingRecord=false;
                this.isRecordCreated=true;
                let toggleBtn=document.querySelector(".toggleBtn");
                if(toggleBtn){
                    toggleBtn.style.display="none";
                }
            }

            const documentKeys = [
                app.Ageement_Sent__c,
                app.Agreement_URL__c,
                app.Document_1__c,
                app.Document_2__c,
                app.Document_3__c,
                app.Document_4__c,
                app.Document_5__c
            ];

            documentKeys.forEach((key, index) => {
                if (!this.documentUploadStatus[index].fileUrl) {
                    const url = key;
                    this.documentUploadStatus[index].fileUrl = url;
                    this.documentUploadStatus[index].uploaded = !!url;
                    this.documentUploadStatus[index].notStarted = !url;
                }
            });
        }
    }

    handleVendorNotFoundChange(event) {
        this.isVendorNotFound = event.target.checked;
    }

    handleManualVendorNameChange(event) {
        this.vendorName = event.target.value;
    }

    handleOpenModal() {
        if(this.noJobApplicationFlag==true){
             this.isModalOpen = false;
             this.noJobApplication=true;
        }
        else if(this.noSelectedFlag==true){
            this.isModalOpen = false;
            this.noApplicationSelected=true;
        }
        else{
            this.isModalOpen=true;
        }
       
        document.getElementById('modalBackdrop').removeAttribute('hidden');
    }

    handleReasonNotEligibleChange(event){
        this.reasonForNotEligibleToRehire=event.detail.value;
    }

    handleCloseModal() {
        this.isModalOpen = false;
    }

    handleCloseSecondModal() {
        this.isSecondModalOpen = false;
    }


    handleEligibleSelectionChange(event){
        this.eligibleToHireYesorNo=event.detail.value;
        this.isSubmitDisabled=false;
        this.eligibleToHire=this.eligibleToHireYesorNo==='Yes' ? true:false;
    }

    handleAssetsChange(event){
        this.assetsProvided=event.detail.value;
        this.isSubmitDisabled=false;
        this.showAssetSelection=this.assetsProvided=='Yes'?true:false;
        this.assetsClass=this.assetsProvided=='Yes'?'assetYes':'assetNo';
    }

    handleSOWSent(event){
        this.sowSent=event.detail.value;
        this.sowClass=this.sowSent=='Yes'?'sowYes':'sowNo';
    }

    handleAgreementTypeChange(event) {
        this.agreementType = event.target.value;
    }

    handleVisaTypeChange(event) {
        this.visaType = event.target.value;
    }

    handleITAuditChange(event) {
        this.itAuditCompleted = event.detail.value;
        this.isSubmitDisabled=false;
    }

    handleFileSelect(event) {
        const documentName = event.currentTarget.dataset.docName;
        this.template.querySelector(`input[data-doc-name="${documentName}"]`).click();
    }

    updateDocumentStatus(documentName, newStatus) {
        this.documentUploadStatus = this.documentUploadStatus.map(doc => {
            if (doc.document === documentName) {
                return { ...doc, ...newStatus };
            }
            return doc;
        });
    }

    handleVendorName(event) {
        this.accountId = event.detail.recordId;
    }

    @wire(getRecord, { recordId: '$accountId', fields: [ACCOUNT_NAME_FIELD] })
    wiredAccount({ error, data }) {
        if (data) {
            this.vendorName = data.fields.Name.value;
        } else if (error) {
            console.error('Error fetching account name:', error);
        }
    }

    handleRemoveFile(event) {
        const documentName = event.currentTarget.dataset.docName;
        this.updateDocumentStatus(documentName, {
            fileName: null,
            fileData: null,
            notStarted: true,
            uploading: false,
            uploaded: false,
            uploadProgress: 0
        });
    }

    handleSaveAndNext() {
        if(this.onboardingStatus!=='Onboarded'){
            if (!this.selectedRegion || !this.selectedCity || !this.selectedNatureOfEngagements) {
                this.isError = true;
                return;
            }
            this.isError = false;
            this.handleSaveCandidate()
            .then(() => {
                this.onboardingStatus='In Progress';
                this.cmpLabel='Continue the Onboarding Process';
                this.onboardingButtonLabel='Continue Onboarding';
                this.handleSaveOnboarding();
            })
            .catch(error => {
                console.error('Error saving candidate details:', error);
                this.showToast('Error', 'Error saving candidate details', 'error');
            });
            if (this.validateModalData()) {
                this.isModalOpen = false;
                this.isSecondModalOpen = true;
            }
        }
        else{
            this.isModalOpen = false;
            this.isSecondModalOpen = true;
        }
    }

    handleToggleExisiting(event) {
        this.exisitingRecord = event.target.checked;
    }

    get processedContracts() {
        return this.contracts.map((contract) => ({
            ...contract,
            isActive: contract.status === 'Active',
            isInactive: contract.status === 'Inactive',
        }));
    }

    handleEmployeeChange(event) {
        this.employeeRecordId = event.target.value; // Get the selected Employee ID
        if (this.employeeRecordId) {            // Pass both the employee ID and the current record ID
            fetchEmployeeContracts({ 
                employeeId: this.employeeRecordId, 
                currentRecordId: this.recordId // Ensure this.recordId is set appropriately
            })
            .then((data) => {
                this.contracts = data.map(contract => ({
                    id: contract.Id,
                    startDate: contract.Contract_Start_Date__c,
                    endDate: contract.Contract_End_Date__c,
                    status: new Date(contract.Contract_End_Date__c) >= new Date() ? 'Active' : 'Inactive',
                }));
                const hasActiveContracts = this.contracts.some(contract => contract.status === 'Active');
                
                // Assign a message based on the contract status
                this.contractMessage = hasActiveContracts 
                    ? 'This employee has active contracts. Proceed accordingly.'
                    : 'All contracts for this employee are expired. Proceed accordingly.';
                
                //Assign Class Dynamically for Message
                this.contractMessageClass = hasActiveContracts 
                ? 'contractMessageActive' 
                : 'contractMessageInActive';
                this.showModal = true; // Open the modal to show contracts
                this.isSecondModalOpen = false;
            })
            .catch((error) => {
                console.error('Error fetching contracts', error); // Log any errors
            });
            this.fetchProjects();
        }
    }

    @wire(getRecord, { recordId: '$employeeRecordId', fields: FIELDS })
    employeeRecord({ error, data }) {
        if (data) {
            this.consultantId = data.fields.EmployeeID__c.value;
            this.consultantEmail = data.fields.Email_ID__c.value;
        } else if (error) {
            this.error = error.body.message;
        }
    }

    handleSave() {
        if (this.validateDates()) {
            if (this.isSecondModalOpen) {
                this.handleSaveCandidate()
                .then(() => {
                    this.showToast('Success', 'Candidate details Saved As Draft', 'success');
                    this.onboardingStatus='In Progress';
                    this.handleSaveOnboarding();
                    this.onboardingButtonLabel='Continue Onboarding';
                    this.cmpLabel='Continue the Onboarding Process';
                })
                .catch(error => {
                    console.error('Error saving candidate details:', error);
                    this.showToast('Error', 'Error saving candidate details', 'error');
                });
            }
        }
       
    }

    handleSubmit() {
        const requiredFields = this.template.querySelectorAll('.requiredField');
        let allFieldsValid = true;

        requiredFields.forEach(field => {
            if (!field.value) {
                field.reportValidity();
                allFieldsValid = false;
            }
        });

        // Check for invalid ABN or ESN only if all required fields are filled
        if (allFieldsValid) {
            if (!this.isInvalidAbn && !this.isInvalidEsn) {
                if (this.validateDates()) {
                    this.isThirdModalOpen = true;
                    this.isSecondModalOpen = false;
                }
            } else {
                let errorMessage = '';
                if (this.isInvalidAbn) {
                    errorMessage += 'Please provide a valid ABN.';
                }
                if (this.isInvalidEsn) {
                    errorMessage += 'Please provide a valid SSN.';
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: errorMessage,
                        variant: 'error'
                    })
                );
            }
        } else {
            // Show error only if there are missing required fields
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please fill all required fields.',
                    variant: 'error'
                })
            );
        }
    }



    handleNo(){
        this.isThirdModalOpen=false;
        this.isSecondModalOpen=true;
    }

    handleYes(){
        if (this.isThirdModalOpen) {
            this.handleSaveCandidate()
            .then(() => {
                this.isThirdModalOpen=false;
                this.isSecondModalOpen=false;
                this.isModalDisabled = true;
                this.isSubmitDisabled=true;
                this.isCityDisabled=true;
                this.firstModalNext='Next';
                this.onboardingStatus='Onboarded';
                this.handleSaveOnboarding();
                this.showToast('Success', 'Submitted successfully !!!', 'success');
                this.onboardingButtonLabel='Onboarded';
                this.cmpLabel='Onboarding Process Completed';
            })
            .catch(error => {
                console.error('Error submitting candidate details:', error);
                this.showToast('Error', 'Error submitting candidate details', 'error');
                this.isThirdModalOpen=false;
            });
        }
    }
    handlePrevious() {
        if (this.isThirdModalOpen) {
            this.isThirdModalOpen = false;
            this.isSecondModalOpen = true;
        } else if (this.isSecondModalOpen) {
            this.isSecondModalOpen = false;
            this.isModalOpen = true;
        }
    }

    validateModalData() {
        return true;
    }

    get visaOptions() {
        return this.visaOptionsMap[this.selectedRegion] || [];
    }

    get yesNoOptions() {
        return [
            { label: 'Yes', value: 'Yes' },
            { label: 'No', value: 'No' }
        ];
    }

    get documentUploadList() {
        return this.documentNamesMap[this.region] || [];
    }

    handleCreateEmployee() {
        createEmployeeRecord({ jobId: this.recordId })
            .then(result => {
                const [employeeRecord,employeeId,employeeEmail]=result.split(',');
                this.employeeRecordId = employeeRecord;
                this.consultantId=employeeId;
                this.consultantEmail=employeeEmail.toLowerCase();
                this.isRecordCreated = true;
                this.handleSaveCandidate();
            })
            .catch(error => {
                console.error('Error creating employee record: ', error);
            });
    }

    navigateToEmployeeRecord() {
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.employeeRecordId,
                objectApiName: 'Employee__c',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, '_blank');
        });
    }

    handleViewEmployee() {
        if (this.employeeRecordId) {
            this.navigateToEmployeeRecord();
        } else {
            console.warn('Employee record not yet created.');
        }
    }
}