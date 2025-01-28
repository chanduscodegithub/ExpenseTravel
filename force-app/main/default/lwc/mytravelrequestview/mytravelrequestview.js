import { LightningElement, track, wire } from 'lwc';
import getAccounts from '@salesforce/apex/Travelrequestclass.gettravelrequestdata';
import getbillsdata from '@salesforce/apex/Travelrequestclass.getbillsdata';
import createrecords from '@salesforce/apex/Travelrequestclass.createrecords';
import getApexData from '@salesforce/apex/Travelrequestclass.getloggindata';
import submitForApproval from '@salesforce/apex/TravelRequestApprovalController.submitForApproval'; // New Apex method import

import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class Mytravelrequestview extends LightningElement {
    fields = [



        { label: true, name: 'Destination__c', },
        { label: true, name: 'Purpose_of_Visit1__c' },
        { label: true, name: 'Date_of_Departure__c' },
        { label: true, name: 'Date_of_Return__c' },
        { label: true, name: 'Travel_Type__c' },
        { label: true, name: 'Mode_of_Transport__c' },
        { label: false, name: 'Billed_to_Customer__c' },
        { label: false, name: 'Project__c' },
        { label: true, name: 'Cost_Centre__c' },
        { label: true, name: 'Description__c' },
        { label: true, name: 'CurrencyIsoCode' },
        { label: true, name: 'Requested_Amount__c' },
        { label: false, name: 'Do_you_have_an_existing_Travel_Card__c' },
        { label: false, name: 'Travel_Card_Number__c' },
        { label: false, name: 'Employee__c', readonly: true, value: '' },
    ];


    showList = false;
    showRecord = false;
    noapprovaldata = false;
    @track accounts;
    accountsdata = false;
    buttonname;
    traveltype1;
    datedep;
    datere;
    dest;
    purposevisit;
    billcus;
    cus;
    dep;
    des;
    curr;
    reqamo;
    existra;
    card;
    empname;


    modetr;
    wiredData;
    accounts;
    date;
    @track isModalOpen = false;
    @track billedToCustomerChecked = false;
    @track hasTravelCard = false;
    @track purposeOfVisit;
    @track customerRequired = false;
    keyIndex = 0;
    traveltype;

    empid;
    showDetailsSection = false;
    recordId;
    billsdata;
    @track filedata;
    selectedStatus = 'Pending for Approval';
    @track itemList = [
        {
            id: 0
        }
    ];

    // Update the active tab (optional)
    renderedCallback() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                if (field.fieldName == 'Employee__c')
                    field.value = this.empid;
            });
        }

    }
    openModal() {
        this.showDetailsSection = false;
        this.isModalOpen = true;
        this.recordId = '';
        const newRow = {
            id: 0,
            file: null,
            recId: '',
            filename: ''
        };
        this.itemList = [newRow];

    }

    closeModal() {
        this.isModalOpen = false;
        this.showRecord = false;
        this.showList = true;
    }
    


    @wire(getAccounts)
    wiredAccounts({ error, data }) {

        if (data) {
            let accParsedData = JSON.parse(JSON.stringify(data));

            accParsedData.forEach(acc => {

                if (acc.Employee__c) {
                    acc.Employee_Name = acc.Employee__r.Name;



                }

            });
            this.accounts = accParsedData;
            if (this.accounts.length > 0) {
                this.showList = true;
            }
            else {
                this.showList = false;
            }
            console.log('this.accounts', this.accounts);


        }
        else if (error) {
            console.error('Error fetching accounts:', error);
        }
    }



    addRow() {
        console.log('iam add row');
        const newRow = {
            id: this.itemList.length + 1,
            file: null,
            date: null,
            recId: '',
            filename: '',
            fileid: '',
            parentId: '',
            status: false
        };
        this.itemList = [...this.itemList, newRow];
    }
    async handleRowAction(event) {
        this.recordId = event.currentTarget.dataset.id;
        console.log(' this.recordId', this.recordId);
        this.dest = event.currentTarget.dataset.destination;
        this.purposevisit = event.currentTarget.dataset.purposeofvisit;
        this.billcus = event.currentTarget.dataset.billedtocustomer;
        this.cus = event.currentTarget.dataset.customer;
        this.datedep = event.currentTarget.dataset.dateofdeparture;
        this.datere = event.currentTarget.dataset.dateofreturn;
        this.modetr = event.currentTarget.dataset.modeoftransport;
                this.traveltype1 = event.currentTarget.dataset.traveltype;

        this.dep = event.currentTarget.dataset.department;
        this.des = event.currentTarget.dataset.descripton;
                this.curr = event.currentTarget.dataset.currency;
        this.reqamo = event.currentTarget.dataset.requestedamount;
                this.existra = event.currentTarget.dataset.existindtravelcard;
        this.card = event.currentTarget.dataset.cardno;
                this.empname = event.currentTarget.dataset.employeeName;





        const status = event.currentTarget.status;
        this.isModalOpen = true;
        if (this.recordId != null) {
            console.log('insidebillsdata');
            try {
                const result = await getbillsdata({ recordId: this.recordId });
                this.itemList = result;

                console.log('this.itemList', JSON.stringify(this.itemList));
                if (this.itemList.length == 0) {
                    this.addRow();
                    this.billsdata = false;
                }
                else {
                    this.billsdata = true;
                }
                this.error = undefined;
            }
            catch (error) {
                this.error = error;
                console.log('this.error', this.error);
                this.itemList = [];
                this.addRow();
            }
        }
        if (status == 'Waiting For Approval' || status != 'Draft') {
            this.showRecord = true;
            this.showList = false;
            this.isModalOpen = false;

        }
        else if (status == 'Draft') {

            this.showRecord = false;
            this.showList = true;
        }

    }

    removeRow(event) {
        let array = [];
        this.itemList = this.itemList.filter(function (element) {
            console.log('element.id', element.id);
            console.log('element.id', element.recId);
            console.log('event.target.accessKey', event.target.accessKey);
            if (element.id == event.target.accessKey) {
                if (element.recId) {

                    array.push({
                        recId: element.recId,
                        fileid: element.fileid
                    });


                    //this.removedItems=[...removedItems,array];
                }
            }

            return parseInt(element.id) !== parseInt(event.target.accessKey);
        });
        this.removedItems = array;


        if (this.itemList.length == 0) {
            this.addRow();
        }
    }


    openfileUpload(event) {
        const rowIndex = event.currentTarget.dataset.index;
        const file = event.target.files[0];

        if (file) {
            const reader = new FileReader();

            reader.onload = () => {
                const base64 = reader.result.split(',')[1];

                // Update the itemList with file details and set uploaded to true
                this.itemList[rowIndex].filename = file.name;
                this.itemList[rowIndex].file = base64;
                this.itemList[rowIndex].uploaded = true; // Mark as uploaded
            };

            reader.readAsDataURL(file);
        }
    }




    handlenext(event) {
         if (event.target.name == 'Draft') {
            this.buttonname = 'Draft';
        }
        else if (event.target.name == 'Submit') {

            this.buttonname = 'Waiting For Approval';
            console.log('this.buttonname123', this.buttonname);
        }
        event.preventDefault();

        console.log('check fields', event.detail.fields);



        let isFormValid = true;
        let travelCardNumberValue = null; // To store Travel Card Number value
        let hasTravelCardValue = null;
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        inputFields.forEach(inputField => {
            const isValid = inputField.reportValidity();
            isFormValid = isFormValid && isValid;
            if (inputField.name === 'Travel_Card_Number__c') {
                travelCardNumberValue = inputField.value;
            }
            if (inputField.name === 'Do_you_have_an_existing_Travel_Card__c') {
                hasTravelCardValue = inputField.value;
            }
            // Validate the field




            // Check if "Billed to Customer" is checked and if the "Project__c" field is filled
            if (this.billedToCustomerChecked && inputField.name === 'Project__c') {
                if (!inputField || !inputField.value) {
                    isFormValid = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Customer field is required when "Billed to Customer" is checked.',
                            variant: 'error',
                        })
                    );
                }
            }
            if (this.purposeOfVisit === 'Client Visit' || this.purposeOfVisit === 'Onsite Project' && inputField.name === 'Project__c') {
                if (!inputField || !inputField.value) {
                    isFormValid = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Customer field is required because Purpose of Visit is "Client Visit" or "Onsite Project".',
                            variant: 'error',
                        })
                    );
                }
            }
            if (inputField.name === 'Travel_Card_Number__c') {
                if (this.hasTravelCard && !inputField.value) {
                    isFormValid = false;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Travel Card Number is required when "Do you have an existing Travel Card" is checked.',
                            variant: 'error',
                        })
                    );
                }
            }
            if (travelCardNumberValue && !hasTravelCardValue) {
                isFormValid = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'The field "Do you have an existing Travel Card" is required because Travel Card Number is populated.',
                        variant: 'error',
                    })
                );
            }


        });

        // Submit the form if all validations pass
        if (isFormValid) {
            // Submit the form or
             this.template.querySelectorAll('lightning-record-edit-form').forEach(element => {
                console.log(' this.buttonname', this.buttonname);
                element.Status__c = this.buttonname;
                //element.Reporting_To__c=this.reporting;
                //element.Cost_center_manager__c=this.ccm;
                console.log('element', element.Status__c);
                element.submit();
            });
        }
    }



    handleSuccess(event) {
        console.log('onsuccess event recordEditForm', event.detail.id);
        if (event.detail.id != null) {
            var isVal = true;
            this.template.querySelectorAll('lightning-input').forEach(element => {
                console.log('element', element);
                isVal = isVal && element.reportValidity();
            });
            if (isVal) {
                const hasValues = this.itemList.every(item => {
                    // Check each field for non-empty values (adjust fields as needed)
                    return item.filename;
                });

                console.log('itemList',JSON.stringify(this.itemList));
                if (hasValues) {
                    createrecords({ records: JSON.stringify(this.itemList), parentid: event.detail.id, status: this.buttonname, rm: this.reporting, ccm: this.ccm })
                        .then(result => {

                            console.log('this.itemList', result);
                            this.isModalOpen = false;
                            this.error = undefined;
                        })
                        .catch(error => {
                            this.error = error;
                            console.log('this.error', this.error);

                        })
                }
                else {
                    createrecords({ records: '', parentid: event.detail.id, status: this.buttonname, rm: this.reporting, ccm: this.ccm })
                        .then(result => {

                            console.log('this.itemList', result);
                            this.isModalOpen = false;
                            this.error = undefined;
                        })
                        .catch(error => {
                            this.error = error;
                            console.log('this.error', this.error);

                        })
                    this.isModalOpen = false; 
                }
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: 'Please enter all the required fields',
                        variant: 'error',
                    }),
                );
            }

        }

    }




    handleChange(event) {
        const fieldName = event.target.name;
        const fieldValue = event.target.value;

        if (fieldName === 'Billed_to_Customer__c') {
            this.billedToCustomerChecked = fieldValue === 'true' || fieldValue === true; // Ensure boolean check
        }
        if (fieldName === 'Purpose_of_Visit1__c') {
            this.purposeOfVisit = fieldValue; // Store the value of the purpose field
        }
        if (fieldName === 'Do_you_have_an_existing_Travel_Card__c') {
            this.hasTravelCard = fieldValue === 'true' || fieldValue === true; // Convert to boolean
        }

        // Store the field values in a map or object for validation in `handlenext`
        if (!this.fieldValues) {
            this.fieldValues = {};
        }
        this.fieldValues[fieldName] = fieldValue;
    }




    connectedCallback() {

        this.fetchData();



    }
    fetchData() {

        getApexData()

            .then(result => {

                this.data = result;
                //this.itenarytype=result.Itinerary_type__c;
                this.empid = result.Id;
                this.reporting = result.ReportingTo__r.SF_User__c;
                this.ccm = result.BU_Head__r.SF_User__c;
                /*if(result.Country__c=='	Australia')
                {
                  this.isbillabletocustomer='AUD';
                }
                else if(result.Country__c=='India')
                {
                      this.isbillabletocustomer='INR'; 
                }
                 else if(result.Country__c=='USA')
                {
                      this.currency='USD'; 
                } */


                console.log('Data received:', result);

            })

            .catch(error => {

                this.error = error;

                console.error('Error:', error);

            });

    }
    closeDetail(e) {
        this.selectedRow = null;
        this.showRecord = false;
        this.showList = true;
    }



}