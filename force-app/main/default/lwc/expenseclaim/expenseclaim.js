import { LightningElement, wire, track } from 'lwc';
import getAccounts from '@salesforce/apex/Expenseclaimclass.getexpenseclaimdata';
import getbillsdata from '@salesforce/apex/Expenseclaimclass.getbillsdata';
import createrecords from '@salesforce/apex/Expenseclaimclass.createrecords';
import deleterecords from '@salesforce/apex/Expenseclaimclass.deleterecords';
import getApexData from '@salesforce/apex/Expenseclaimclass.getloggindata';
import getPendingApprovals from '@salesforce/apex/Expenseclaimclass.getPendingApprovals';

import isbillUnique from '@salesforce/apex/Expenseclaimclass.isbillUnique';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class Expenseclaim extends LightningElement {
    

    fields = [
        { label: true, name: 'Expense_Category__c', readonly: false },
        { label: true, name: 'Department__c', readonly: false },
        { label: true, name: 'Currency__c', readonly: false },
        { label: true, name: 'Bill_Amount__c', readonly: false },
        { label: false, name: 'Employee_Comments__c', readonly: false },
        { label: false, name: 'Expense_Requesting_Date__c', readonly: true },
        { label: false, name: 'Employee_ID__c', readonly: true },

    ];
    showList = false;
    showRecord = false;
    accounts;
    removedItems = [];
    detaillist=[];
    noapprovaldata = false;
    detailView=false;
    accounts;
    accountsdata = false;
    buttonname;
    totalbillamount;
    date;
    @track isModalOpen = false;

    keyIndex = 0;
    category;
    expdate;
    department;
    currency;
    categry;
    empname;
    curre;
    empcomments;
    depatment;
    tbillamount;
    empid;
    showDetailsSection = false;
    recordId;
    removedrows;
    billsdata;
    submitstatus;
    @track filedata;
    selectedStatus = 'Pending for Approval';
    @track itemList = [
        {
            id: 0
        }
    ];

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
        console.log('Selected Tab Panel:', this.template.querySelector(`.tab-panel[data-tab="Myexpenseclaims"]`));

        // Show the selected tab and set the active class on the button
       
         if(selectedTab =="Myexpenseclaims")
        {
              console.log('selectedTab123');
          const selectedTabPanel = this.template.querySelector(`.tab-panel[data-tab="Myexpenseclaims"]`);
            selectedTabPanel.classList.remove('slds-hide'); // Show the selected tab
            selectedTabPanel.classList.add('active'); 
        }
        else 
        {
            console.log('selectedTab');
         const selectedTabPanel = this.template.querySelector(`.tab-panel[data-tab="Myteamexpenseclaims"]`);
          selectedTabPanel.classList.remove('slds-hide'); // Show the selected tab
            selectedTabPanel.classList.add('active'); 
        }
       

        event.target.classList.add('active'); // Highlight the clicked button
        this.activeTab = selectedTab; // Update the active tab (optional)
    }

    // Function to close detail view
    closeDetail() {
        console.log('detailView',this.detailView);
        this.detailView = false;
        this.selectedRow = null;
        this.showRecord = false;
        this.showList = true;
        console.log('detailView',this.detailView);
    }

    @wire(getAccounts)
    wiredAccounts({ error, data }) {

        if (data) {
            let accParsedData = JSON.parse(JSON.stringify(data));

            accParsedData.forEach(acc => {

                if (acc.Employee_ID__c) {

                    acc.Employee_Name = acc.Employee_ID__r.Name;

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


        } else if (error) {
            console.error('Error fetching accounts:', error);
        }
    }

    async handleRowAction(event) {
        this.detailView=true;
        console.log('event.detail', event.currentTarget.dataset.id);
        console.log('event.detail.row', JSON.stringify(event.currentTarget.dataset));
        this.recordId = event.currentTarget.dataset.id;
        console.log('this.recordId ',this.recordId );
       // this.recordId = event.currentTarget.dataset.id;
        this.expdate = event.currentTarget.dataset.expenseRequestingDate;
        this.categry = event.currentTarget.dataset.expenseCategory;
        this.empname = event.currentTarget.dataset.employeeName;
        this.curre = event.currentTarget.dataset.currency;
        this.empcomments = event.currentTarget.dataset.employeeComments;
        this.depatment = event.currentTarget.dataset.department;
        this.tbillamount = event.currentTarget.dataset.billAmount;
        const status=event.currentTarget.status;
        //this.isModalOpen = true;

        if (this.recordId != null) {
            console.log('insidebillsdata');
            try{
                console.log('recordId',this.recordId);
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
     this.isModalOpen = false;
            this.showRecord = true;
            this.showList = false;
            //this.detaillist=this.itemList;
            //this.itemList=[];
            console.log('this.itemListdadsfsf',  this.itemList);

            

        }
        else if (status == 'Draft') {

            this.showRecord = false;
            this.showList = true;
        }

    }
    renderedCallback() {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                if (field.fieldName == 'Department__c')
                    field.value = this.department;
                if (field.fieldName == 'Currency__c')
                    field.value = this.currency;
                if (field.fieldName == 'Employee_ID__c')
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
            comments: '',
            recId: '',
            amtsptdate: '',
            filename: '',
            billamount: 0,
            billnumber: ''

        };
        this.itemList = [newRow];

    }

    closeModal() {
        this.isModalOpen = false;
        this.showRecord = false;
        this.showList = true;
    }
    addRow() {
        console.log('iam add row');
        const newRow = {
            id: this.itemList.length + 1,
            file: null,
            comments: '',
            date: null,
            recId: '',
            amtsptdate: '',
            filename: '',
            billamount: 0,
            fileid: '',
            parentId: '',
            billnumber: '',
            status: false


        };
        console.log('newRow', newRow);
        this.itemList = [...this.itemList, newRow];
        console.log('this.itemList', this.itemList);

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
        console.log('event.currentTarget.id', event.currentTarget.id);
        console.log('event.currentTarget.dataset.index', event.currentTarget.dataset.index);
        var row = event.currentTarget.dataset.index;
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]

            this.itemList[row].filename = file.name;
            this.itemList[row].file = base64;



        }
        reader.readAsDataURL(file)
    }
    handlenext(event) {
        console.log('event.target.name', event.target.name);
        if (event.target.name == 'Draft') {
            this.buttonname = 'Draft';
        }
        else if (event.target.name == 'Submit') {

            this.buttonname = 'Waiting For Approval';
            console.log('this.buttonname123', this.buttonname);
        }
        event.preventDefault();
        console.log(event.detail.fields);
        var isVal = true;
        var isbVal = true;
        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            if (element.fieldName == 'Bill_Amount__c') {
                this.totalbillamount = element.value;
            }

            isVal = isVal && element.reportValidity();
        });
        var amount = 0;
        console.log('this.itemList', JSON.stringify(this.itemList));
        this.itemList.forEach((item, index) => {
            console.log('item.billnumber', item.billamount);
            console.log('item.billnumber', item.billnumber);
            console.log('item.amtsptdate', item.amtsptdate);
            amount = amount + parseFloat(item.billamount);
            if (item.billamount > 0 && (!item.billnumber || !item.amtsptdate)) {
                isbVal = false;
                var row = index + 1
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Validation Error',
                        message: 'Row ' + row + ': Bill Number and Amount Spent Date are required when Bill Amount is provided.',
                        variant: 'error',
                        mode: 'sticky',
                    })
                );
            }
        });
        console.log('amount', amount);
        console.log('this.totalbillamount', this.totalbillamount);
        if (this.totalbillamount != amount) {
            isbVal = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Validation Error',
                    message: 'Total Bill Amount equals the sum of all the Supporting Documentation Bill Amounts.',
                    variant: 'error',

                })
            );
        }
        if (isVal & isbVal) {
            this.template.querySelectorAll('lightning-record-edit-form').forEach(element => {
                console.log(' this.buttonname', this.buttonname);
                element.Status__c = this.buttonname;
                //element.Reporting_To__c=this.reporting;
                //element.Cost_center_manager__c=this.ccm;
                console.log('element', element.Status__c);
                element.submit();
            });

        } else if (isVal == false) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: 'Please enter all the required fields',
                    variant: 'error',
                }),
            );
        }
        if (this.removedItems.length > 0) {
            deleterecords({ records: JSON.stringify(this.removedItems) })
                .then(result => {

                    console.log('this.itemList', result);
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    console.log('this.error', this.error);

                })
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
                    return item.comments || item.amtsptdate || item.billamount !== 0 || item.billnumber || item.filename;
                });
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
                    //this.isModalOpen = false; 
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
        if (event.target.name == 'comments') {
            this.itemList[event.currentTarget.dataset.index].comments = event.target.value;
        }
        else if (event.target.name == 'Billnumber') {
            this.itemList[event.currentTarget.dataset.index].billnumber = event.target.value;
        }
        else if (event.target.name == 'Amount Spend date') {
            let dateCmp = this.template.querySelector(".dateVal");
            console.log('dateCmp', dateCmp.value);

            const today = new Date();
            const formattedToday = today.toISOString().split('T')[0]; // Extract YYYY-MM-DD
            console.log(formattedToday);
            console.log('today', today);
            if (dateCmp.value > formattedToday) {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error ',
                        message: 'Amount Spend Date should always be less than or equal to Expense Requesting Date',
                        variant: 'error',
                        mode: 'pester',
                    }),

                );
                dateCmp.setCustomValidity("complete this field");
                dateCmp.reportValidity();
            }
            else {
                const index = event.currentTarget.dataset.index;
                const updatedItem = { ...this.itemList[index] }; // Clone the object
                updatedItem.amtsptdate = event.target.value; // Update the value
                this.itemList = [
                    ...this.itemList.slice(0, index),
                    updatedItem,
                    ...this.itemList.slice(index + 1)
                ];
                dateCmp.setCustomValidity("");
                dateCmp.reportValidity();
            }
        }
        else if (event.target.name == 'billamount') {
            this.itemList[event.currentTarget.dataset.index].billamount = event.target.value;

        }
    }
    connectedCallback() {

        this.fetchData();
        //this.fetchPendingApprovals(this.selectedStatus);

    }

    fetchData() {

        getApexData()

            .then(result => {
                console.log('result', result);
                this.data = result;
                this.department = result.Department__c;
                this.empid = result.Id;
                this.reporting = result.ReportingTo__r.SF_User__c;
                this.ccm = result.BU_Head__r.SF_User__c;
                if (result.Country__c == '	Australia') {
                    this.currency = 'AUD';
                }
                else if (result.Country__c == 'India') {
                    this.currency = 'INR';
                }
                else if (result.Country__c == 'USA') {
                    this.currency = 'USD';
                }


                console.log('Data received:', result);

            })

            .catch(error => {

                this.error = error;

                console.error('Error:', error);

            });

    }
    // closeDetail(e) {
    //     this.selectedRow = null;
    //     this.showRecord = false;
    //     this.showList = true;
    // }
}