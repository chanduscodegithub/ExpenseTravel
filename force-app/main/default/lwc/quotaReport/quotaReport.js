import { LightningElement, track, wire, api } from 'lwc';
import getFinancialYears from '@salesforce/apex/QuotaController.getSalesFinancialYears';
import getFinancialPlanningRecords from '@salesforce/apex/QuotaController.getSalesFinancialPlanningRecords';
import getRevenueStreamRegions from '@salesforce/apex/QuotaController.getSalesRevenueStreamRegions';
import getSalesRegions from '@salesforce/apex/QuotaController.getSalesRegions';
import SalesRevenueStreamEmployees from '@salesforce/apex/QuotaController.getSalesRevenueStreamEmployeesForLoggedInUser';
import isEligibleForQuota from '@salesforce/apex/QuotaController.isEligibleForQuota';
import isRevenueReview from '@salesforce/apex/QuotaController.isRevenueReview';
import getOpportunity from '@salesforce/apex/QuotaController.getOpportunity';
import getInvoice from '@salesforce/apex/QuotaController.getInvoice';

//import categoryReport from '@salesforce/apex/QuotaController.getAllRevenueStreamEmployeesBillingType';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const columnsList = [
    { label: 'Account Name', fieldName: 'accountName', type: 'String', sortable: "true" },
    {
        label: 'Opportunity name',
        fieldName: 'nameUrl',
        type: 'url',
        typeAttributes: {
            label: { fieldName: 'Name' },
            target: '_blank'
        },
        sortable: true
    },
    { label: 'Owner Name', fieldName: 'ownerName', type: 'String', sortable: "true" },
    { label: 'Currency', fieldName: 'CurrencyIsoCode', type: 'String', sortable: "true" },
    {
        label: 'Total Amount', fieldName: 'Amount', type: 'number', typeAttributes: {
            step: '0',
            minimumFractionDigits: '0',
            maximumFractionDigits: '0',

        }, sortable: "true",
    },
    { label: 'Opportunity Category', fieldName: 'OpportunityCategory', type: 'String', sortable: "true" }];


const columnsList2 = [
    { label: 'Account Name', fieldName: 'accountName', type: 'String', sortable: "true" },
    {
        label: 'Opportunity Name', fieldName: 'nameUrl', type: 'url', typeAttributes: {
            label: { fieldName: 'opportunityName' },
            target: '_blank'
        }, sortable: "true"
    },
    { label: 'Owner Name', fieldName: 'ownerName', type: 'String', sortable: "true" },
    { label: 'Currency', fieldName: 'CurrencyIsoCode', type: 'String', sortable: "true" },
    {
        label: 'Total Amount', fieldName: 'Amount', type: 'number', sortable: "true", typeAttributes: {
            step: '0',
            minimumFractionDigits: '0',
            maximumFractionDigits: '0',

        }
    },
    { label: 'Opportunity Category', fieldName: 'OpportunityCategory', type: 'String', sortable: "true", }];

export default class QuotaReport extends LightningElement {
    @api record;
    @api totalAttainment;
    @api totalAspirationAttainment;
    @api ecrbattainment;
    @api ecnbattainment;
    @api ncnbattainment;
    @track yearOptions = [];
    @track regionOptions = [];
    @track selectedYear;
    @track selectedRegion;
    @track showFinancialPlanningTab = false;
    @track financialPlanningTabLabel;
    @track financialPlanningRecords = [];
    @track BillingPlanningRecords = [];
    @track showModal = false;
    @track modalHeader = '';
    @track modalData = [];
    @track Ctrlbgcolor;
    @track errorMessage = '';
    @track financialPlanningRecords;
    @track totalAttainment = 0;
    @track totalAttainmentbillings = 0;
    @track ecrbattainment = 0;
    @track ecnbattainment = 0;
    @track ncnbattainment = 0;
    @track totalecrb;
    @track totalQuotaQ1;
    @track totalQuotaQ2;
    @track totalQuotaQ3;
    @track totalQuotaQ4;
    @track totalActualsQ1;
    @track totalActualsQ2;
    @track totalActualsQ3;
    @track totalActualsQ4;
    @track totalecnb;
    @track q1Aspiration;
    @track q2Aspiration;
    @track q3Aspiration;
    @track q4Aspiration;
    @track totalncnb;
    @track totalyearlyaspiration;

    @track opportunities = [];
    @track showOpportunities = false;
    @track columns = columnsList;
    @track sortBy;
    @track sortDirection;

    @track invoiceList = [];
    @track showInvoice = false;
    @track columnsInvoice = columnsList2;

    isEligibleForForecast = false;
    isEligibleForQuota = false;
    isRevenueReview = false;
    totalQuota;
    totalQuotabilling;
    totalyearlyaspiration;
    totalActualsbillings;
    totalActuals;
    baseURL;

    @track selectedTabLabel;


    get tabLabels() {
        return ['FY-' + this.selectedYear + '-Aspiration'];
    }

    get selectedTabLabelContainsQuota() {
        return this.selectedTabLabel && this.selectedTabLabel.toLowerCase().includes('quota');
    }

    get selectedTabLabelContainsBudget() {
        return this.selectedTabLabel && this.selectedTabLabel.toLowerCase().includes('budget');
    }

    get selectedTabLabelContainsAspiration() {
        return this.selectedTabLabel && this.selectedTabLabel.toLowerCase().includes('aspiration');
    }

    connectedCallback() {
        this.baseURL = window.location.origin;
        //console.log('this.baseURL::' + this.baseURL);
        //console.log('this.baseURLPath::'+this.baseURLPath);
    }

    handleTabSelection(event) {
        this.selectedTabLabel = event.target.label;
    }

    handleRegionChange(event) {
        this.selectedRegion = event.detail.value;
        this.fetchFinancialPlanningRecords();
        //console.log('handleRegionChange - Selected Region:', this.selectedRegion);
    }

    @wire(isEligibleForQuota)
    wiredIsEligibleForQuota({ error, data }) {
        if (data) {
            this.isEligibleForQuota = data;
            //console.log('wiredIsEligibleForQuota - Data:', data);
        } else if (error) {
            console.log('Error fetching eligibility:', error);
        }
    }


    @wire(isRevenueReview)
    wiredisRevenueReview({ error, data }) {
        if (data) {
            this.isRevenueReview = data;
            //console.log('wiredisRevenueReview - Data:', data);
        } else if (error) {
            console.log('Error fetching Revenue:', error);
        }
    }

    @wire(getFinancialYears)
    wiredFinancialYears({ error, data }) {
        if (data) {
            this.yearOptions = data.map(year => ({ label: year, value: year }));
            this.selectedYear = this.yearOptions[0].value;
            this.fetchFinancialPlanningRecords();
            //console.log('wiredFinancialYears - Data:', data);
        } else if (error) {
            console.error('Error:', error);
        }
    }



    @wire(getSalesRegions)
    wiredSalesRegions({ error, data }) {
        if (data) {
            this.regionOptions = data.map(region => ({ label: region, value: region }));
            this.fetchFinancialPlanningRecords();
            //console.log('wiredSalesRegions - Data:', data);
        } else if (error) {
            console.error('Error:', error);
        }
    }

    navigateToRecordList() {
        let urlPath = '';
        if (this.baseURL.includes('site')) {
            urlPath = this.baseURL + '/CRMITCommunity/s/recordlist/Revenue_Stream_Employee__c/00B1K00000ANLnGUAX';
        } else {
            urlPath = this.baseURL + '/lightning/o/Revenue_Stream_Employee__c/list?filterName=00B1K00000ANLnGUAX';
        }
        window.open(urlPath);
    }

    getOpportunityAspiration(event) {
        console.log('data::' + JSON.stringify(this.financialPlanningRecords[event.target.dataset.id]));
    }


    getOpportunity(event) {
        this.showInvoice = false;
        //console.log('data::' + JSON.stringify(this.financialPlanningRecords[event.target.dataset.index].employeeDetails[event.target.dataset.id].Employees__c));
        //const quotaName = 'FY-' + this.selectedYear + '-Quota';
        const employeeId = this.financialPlanningRecords[event.target.dataset.index].employeeDetails[event.target.dataset.id].Employees__c;
        const currencyCode = this.financialPlanningRecords[event.target.dataset.index].employeeDetails[event.target.dataset.id].Currency__c;
        //console.log('result:::' + JSON.stringify(this.financialPlanningRecords[event.target.dataset.index].employeeDetails[event.target.dataset.id]));
        if (event.target.dataset.msg === 'Year') {
            //console.log('employeeId:::' + employeeId);
            //console.log('currencyCode:::' + currencyCode);
            this.handleOpportunity(employeeId, 'Year', this.selectedYear, null, currencyCode);
        } else if (event.target.dataset.msg === 'Quater') {
            //const employeeId = this.financialPlanningRecords[event.target.dataset.index].employeeDetails[event.target.dataset.id].Employees__c;
            this.handleOpportunity(employeeId, 'Quater', this.selectedYear, event.target.name, currencyCode);
        }
    }

    //Opportunity
    async handleOpportunity(employeeId, yearOrQuater, selectedYear, selectedQuater, currencyCodeEmp) {
        await getOpportunity({ empId: employeeId, yearOrQuaterInApex: yearOrQuater, selectedYearInApex: selectedYear, selectedQuaterInApex: selectedQuater, empCurrency: currencyCodeEmp })
            .then(result => {
                //console.log('result:::' + JSON.stringify(result));
                let nameUrl;
                let ownerName;
                let accountName;
                this.opportunities = result.map(row => {
                    if (this.baseURL.includes('site')) {
                        nameUrl = this.baseURL + '/CRMITCommunity/s/detail/' + row.OpportunityId;
                    } else {
                        nameUrl = this.baseURL + '/lightning/r/Opportunity/' + row.OpportunityId + '/view';
                    }
                    /*ownerName = row.Owner.Name;
                    accountName = row.Account.Name;//ownerName, , accountName*/
                    return { ...row, nameUrl }
                })
                this.showOpportunities = true;


            }).catch(error => {
                console.log(JSON.stringify(error));
            });
    }

    //Invoice
    getInvoice(event) {
        this.showOpportunities = false;
        //const quotaName = 'FY-' + this.selectedYear + '-Quota';
        //&& this.financialPlanningRecords[event.target.dataset.index].Name === quotaName
        const employeeId = this.financialPlanningRecords[event.target.dataset.index].employeeDetails[event.target.dataset.id].Employees__c;
        const currencyCode = this.financialPlanningRecords[event.target.dataset.index].employeeDetails[event.target.dataset.id].Currency__c;
        //console.log('employeeId:::' + employeeId);
        if (event.target.dataset.msg === 'Year') {
            this.handleInvoice(employeeId, 'Year', this.selectedYear, null, currencyCode);
        } else if (event.target.dataset.msg === 'Quater') {
            //const employeeId = this.financialPlanningRecords[event.target.dataset.index].employeeDetails[event.target.dataset.id].Employees__c;
            this.handleInvoice(employeeId, 'Quater', this.selectedYear, event.target.name, currencyCode);
        }
    }

    async handleInvoice(employeeId, yearOrQuater, selectedYear, selectedQuater, currencyCodeEmp) {
        await getInvoice({ empId: employeeId, yearOrQuaterInApex: yearOrQuater, selectedYearInApex: selectedYear, selectedQuaterInApex: selectedQuater, empCurrency: currencyCodeEmp })
            .then(result => {
                //console.log('result:::' + JSON.stringify(result));
                let nameUrl;
                let ownerName;
                let accountName;
                let opportunityName;
                this.invoiceList = result.map(row => {
                    if (this.baseURL.includes('site')) {
                        nameUrl = this.baseURL + '/CRMITCommunity/s/detail/' + row.OpportunityId;
                    } else {
                        nameUrl = this.baseURL + '/lightning/r/Opportunity/' + row.OpportunityId + '/view';
                    }
                    //ownerName = row.OpportunityName__r.Owner.Name;
                    //accountName = row.Account__r.Name;
                    //opportunityName = row.OpportunityName__r.Name;
                    //, ownerName,accountName, opportunityName
                    return { ...row, nameUrl }
                })
                this.showInvoice = true;
            }).catch(error => {
                console.log(JSON.stringify(error));
            });
    }

    handleClickHide() {
        this.showOpportunities = false;
    }
    handleClickHideInvoice() {
        this.showInvoice = false;
    }

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        if (event.target.name === '') {

        } else {

        }
        this.sortData(this.sortBy, this.sortDirection, event.target.name);
    }

    sortData(fieldname, direction, eventName) {
        let parseData;
        if (eventName === 'opt') {
            parseData = JSON.parse(JSON.stringify(this.opportunities));
        } else if (eventName === 'inv') {
            parseData = JSON.parse(JSON.stringify(this.invoiceList));
        }
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });

        if (eventName === 'opt') {
            this.opportunities = parseData
        } else if (eventName === 'inv') {
            this.invoiceList = parseData
        }
    }

    async getOpportunityList() {

    }

    handleYearChange(event) {
        this.selectedYear = event.detail.value;
        this.fetchFinancialPlanningRecords();
        console.log('handleYearChange - Selected Year:', this.selectedYear);
    }

    handleRegionChange(event) {
        this.selectedRegion = event.detail.value;
        this.fetchFinancialPlanningRecords();
        console.log('handleRegionChange - Selected Region:', this.selectedRegion);
    }

    getEmployeeAttainmentColor(attainment) {
        this.Ctrlbgcolor = attainment < 90 ? 'bgClolor1' : 'bgClolor2';
    }

    get recordType() {
        if (this.recordName) {
            if (this.recordName.includes('Quota')) {
                return 'Quota';
            } else if (this.recordName.includes('Aspiration')) {
                return 'Aspiration';
            } else if (this.recordName.includes('Budget')) {
                return 'Budget';
            }
        }
        return null;
    }

    fetchFinancialPlanningRecords() {
        getFinancialPlanningRecords({ year: this.selectedYear, region: this.selectedRegion })
            .then(result => {
                this.financialPlanningRecords = result.map(record => ({
                    ...record,
                    showFinancialPlanningTab: true,
                    employeeDetails: []
                }));

                if (this.financialPlanningRecords.length === 0) {
                    this.financialPlanningRecords = [{
                        showFinancialPlanningTab: false,
                        employeeDetails: []
                    }];
                } else {
                    const promises = this.financialPlanningRecords.map(record => {
                        return new Promise((resolve, reject) => {
                            SalesRevenueStreamEmployees({ financialPlanningName: record.Name })
                                .then(employeeResult => {
                                    record.employeeDetails = employeeResult.filter(employee => employee.Region__c === this.selectedRegion);
                                    resolve();
                                })
                                .catch(error => {
                                    console.error('Error fetching employee details:', error);
                                    reject(error);
                                });
                        });
                    });

                    Promise.all(promises)
                        .then(() => {
                            this.calculateTotals();
                            this.calculateQuarterlyTotals();
                            this.calculateTotalsforbillings();
                            this.calculateAspirationyearly();
                            this.calculateQuarterlyAspirations();
                        })
                        .catch(error => {
                            console.error('Error fetching employee details:', error);
                        });
                }
                //console.log('fetchFinancialPlanningRecords - Result:', result);
            })
            .catch(error => {
                console.error('Error:', error);

                let errorMessage = 'An error occurred while fetching data.';

                if (error.body && error.body.message) {
                    errorMessage = error.body.message;
                }

                const toastEvent = new ShowToastEvent({
                    title: 'Error',
                    message: errorMessage,
                    variant: 'error'
                });
                this.dispatchEvent(toastEvent);

                this.financialPlanningRecords = null;
            });
    }

    calculateTotals() {
        let totalQuota = 0;
        let totalActuals = 0;

        this.financialPlanningRecords.forEach(record => {
            record.employeeDetails.forEach(employee => {
                totalQuota += employee.Yearly_Target__c || 0;
                totalActuals += employee.Yearly_Opportunity_Actuals__c || 0;
            });
        });

        let attainment = totalQuota !== 0 ? (totalActuals / totalQuota) * 100 : 0;

        this.totalQuota = totalQuota;
        this.totalActuals = this.roundToInteger(totalActuals);
        this.totalAttainment = attainment.toFixed(1);
    }
    get getClassForAttainment() {
        if (this.totalAttainment >= 100) {
            return 'slds-text-align_right2 bgClolor1';
        } else if (this.totalAttainment >= 80) {
            return 'slds-text-align_right2 bgClolor3';
        } else {
            return 'slds-text-align_right2 bgClolor2';
        }
    }


    calculateTotalsforbillings() {
        let totalQuotabilling = 0;
        let totalActualsbillings = 0;
        let totalecrb = 0;
        let totalecnb = 0;
        let totalncnb = 0;

        this.financialPlanningRecords.forEach(record => {
            record.employeeDetails.forEach(employee => {
                // Sum up the values for each column
                totalQuotabilling += employee.Total_Billing_Target__c || 0;
                totalActualsbillings += employee.Billing_Yearly_Actual__c || 0;
                totalecrb += employee.ECRB_total__c || 0;
                totalecnb += employee.ECNB_total__c || 0;
                totalncnb += employee.NCNB_total__c || 0;

                // Similarly, sum up the values for other columns
            });
        });

        // Calculate attainment
        let attainment = totalQuotabilling !== 0 ? (totalActualsbillings / totalQuotabilling) * 100 : 0;
        let ecrbattainment = totalQuotabilling !== 0 ? (totalecrb / totalQuotabilling) * 100 : 0;
        let ecnbattainment = totalQuotabilling !== 0 ? (totalecnb / totalQuotabilling) * 100 : 0;
        let ncnbattainment = totalQuotabilling !== 0 ? (totalncnb / totalQuotabilling) * 100 : 0;

        // Assign values to the corresponding properties
        this.totalQuotabilling = totalQuotabilling;
        this.totalecrb = totalecrb;
        this.totalecnb = totalecnb;
        this.totalncnb = totalncnb;
        this.totalActualsbillings = this.roundToInteger(totalActualsbillings);
        this.totalAttainmentbillings = attainment.toFixed(1);
        this.ecrbattainment = ecrbattainment.toFixed(1);
        this.ecnbattainment = ecnbattainment.toFixed(1);
        this.ncnbattainment = ncnbattainment.toFixed(1);
    }


    get getClassForAttainmentbilling() {
        if (this.totalAttainmentbillings >= 100) {
            return 'slds-text-align_right2 bgClolor1';
        } else if (this.totalAttainmentbillings >= 80) {
            return 'slds-text-align_right2 bgClolor3';
        } else {
            return 'slds-text-align_right2 bgClolor2';
        }
    }

    calculateQuarterlyTotals() {
        this.totalQuotaQ1 = 0;
        this.totalQuotaQ2 = 0;
        this.totalQuotaQ3 = 0;
        this.totalQuotaQ4 = 0;
        this.totalActualsQ1 = 0;
        this.totalActualsQ2 = 0;
        this.totalActualsQ3 = 0;
        this.totalActualsQ4 = 0;
        this.totalAttainment1 = 0;
        this.totalAttainment2 = 0;
        this.totalAttainment3 = 0;
        this.totalAttainment4 = 0;

        this.financialPlanningRecords.forEach(record => {
            record.employeeDetails.forEach(employee => {
                const q1Target = isNaN(parseFloat(employee.Q1_Target__c)) ? 0 : parseFloat(employee.Q1_Target__c);
                const q2Target = isNaN(parseFloat(employee.Q2_Target__c)) ? 0 : parseFloat(employee.Q2_Target__c);
                const q3Target = isNaN(parseFloat(employee.Q3_Target__c)) ? 0 : parseFloat(employee.Q3_Target__c);
                const q4Target = isNaN(parseFloat(employee.Q4_Target__c)) ? 0 : parseFloat(employee.Q4_Target__c);

                // Parse actuals as floats
                const q1Actuals = isNaN(parseFloat(employee.Q1_Opportunity_Actuals__c)) ? 0 : parseFloat(employee.Q1_Opportunity_Actuals__c);
                const q2Actuals = isNaN(parseFloat(employee.Q2_Opportunity_Actuals__c)) ? 0 : parseFloat(employee.Q2_Opportunity_Actuals__c);
                const q3Actuals = isNaN(parseFloat(employee.Q3_Opportunity_Actuals__c)) ? 0 : parseFloat(employee.Q3_Opportunity_Actuals__c);
                const q4Actuals = isNaN(parseFloat(employee.Q4_Opportunity_Actuals__c)) ? 0 : parseFloat(employee.Q4_Opportunity_Actuals__c);

                this.totalQuotaQ1 += q1Target;
                this.totalQuotaQ2 += q2Target;
                this.totalQuotaQ3 += q3Target;
                this.totalQuotaQ4 += q4Target;

                // Round or keep actuals as decimals
                this.totalActualsQ1 += Math.round(q1Actuals); // If you want to round actuals to the nearest whole number

                this.totalActualsQ2 += Math.round(q2Actuals); // If you want to round actuals to the nearest whole number

                this.totalActualsQ3 += Math.round(q3Actuals); // If you want to round actuals to the nearest whole number

                this.totalActualsQ4 += Math.round(q4Actuals); // If you want to round actuals to the nearest whole number

                this.totalAttainment1 = this.totalQuotaQ1 !== 0 ? ((this.totalActualsQ1 / this.totalQuotaQ1) * 100).toFixed(1) : 0;
                this.totalAttainment2 = this.totalQuotaQ2 !== 0 ? ((this.totalActualsQ2 / this.totalQuotaQ2) * 100).toFixed(1) : 0;
                this.totalAttainment3 = this.totalQuotaQ3 !== 0 ? ((this.totalActualsQ3 / this.totalQuotaQ3) * 100).toFixed(1) : 0;
                this.totalAttainment4 = this.totalQuotaQ4 !== 0 ? ((this.totalActualsQ4 / this.totalQuotaQ4) * 100).toFixed(1) : 0;
            });
        });
    }

    get getClassForAttainment1() {
        if (this.totalAttainment1 >= 100) {
            return 'slds-text-align_right2 bgClolor1';
        } else if (this.totalAttainment1 >= 80) {
            return 'slds-text-align_right2 bgClolor3';
        } else {
            return 'slds-text-align_right2 bgClolor2';
        }
    }

    get getClassForAttainment2() {
        if (this.totalAttainment2 >= 100) {
            return 'slds-text-align_right2 bgClolor1';
        } else if (this.totalAttainment2 >= 80) {
            return 'slds-text-align_right2 bgClolor3';
        } else {
            return 'slds-text-align_right2 bgClolor2';
        }
    }

    get getClassForAttainment3() {
        if (this.totalAttainment3 >= 100) {
            return 'slds-text-align_right2 bgClolor1';
        } else if (this.totalAttainment3 >= 80) {
            return 'slds-text-align_right2 bgClolor3';
        } else {
            return 'slds-text-align_right2 bgClolor2';
        }
    }

    get getClassForAttainment4() {
        if (this.totalAttainment4 >= 100) {
            return 'slds-text-align_right2 bgClolor1';
        } else if (this.totalAttainment4 >= 80) {
            return 'slds-text-align_right2 bgClolor3';
        } else {
            return 'slds-text-align_right2 bgClolor2';
        }
    }
    @api Q4_Attainment__c;
    @api Q3_Attainment__c;
    getClassForAttainment5() {
        console.log('Q4_Attainment__c:', this.Q4_Attainment__c);
        if (this.Q4_Attainment__c >= 100) {
            console.log('Returning green');
            return 'green';
        } else if (this.Q4_Attainment__c >= 80) {
            console.log('Returning orange');
            return 'orange';
        } else {
            console.log('Returning red');
            return 'red';
        }
    }

    get getClassForAspirationAttainment() {
        if (this.totalAspirationAttainment >= 100) {
            return 'slds-text-align_right2 bgClolor1';
        } else if (this.totalAspirationAttainment >= 80) {
            return 'slds-text-align_right2 bgClolor3';
        } else {
            return 'slds-text-align_right2 bgClolor2';
        }
    }

    calculateAspirationyearly() {
        let totalyearlyaspiration = 0;
        let totalActuals = 0;

        this.financialPlanningRecords.forEach(record => {
            record.employeeDetails.forEach(employee => {
                totalyearlyaspiration += employee.Yearly_Aspiration_Goals__c || 0;
                totalActuals += employee.Yearly_Opportunity_Actuals__c || 0;
            });
        });
        let attainment1 = totalyearlyaspiration !== 0 ? (totalActuals / totalyearlyaspiration) * 100 : 0;
        this.totalyearlyaspiration = totalyearlyaspiration;
        this.totalActuals = this.roundToInteger(totalActuals);
        this.totalAspirationAttainment = attainment1.toFixed(1);
    }

    calculateQuarterlyAspirations() {
        this.q1Aspiration = 0;
        this.q2Aspiration = 0;
        this.q3Aspiration = 0;
        this.q4Aspiration = 0;
        this.totalAspirationAttainment1 = 0;
        this.totalAspirationAttainment2 = 0;
        this.totalAspirationAttainment3 = 0;
        this.totalAspirationAttainment4 = 0;

        this.financialPlanningRecords.forEach(record => {
            record.employeeDetails.forEach(employee => {
                const q1ag = isNaN(parseFloat(employee.Q1_Aspiration_Goals__c)) ? 0 : parseFloat(employee.Q1_Aspiration_Goals__c);
                const q2ag = isNaN(parseFloat(employee.Q2_Aspiration_Goals__c)) ? 0 : parseFloat(employee.Q2_Aspiration_Goals__c);
                const q3ag = isNaN(parseFloat(employee.Q3_Aspiration_Goals__c)) ? 0 : parseFloat(employee.Q3_Aspiration_Goals__c);
                const q4ag = isNaN(parseFloat(employee.Q4_Aspiration_Goals__c)) ? 0 : parseFloat(employee.Q4_Aspiration_Goals__c);

                this.q1Aspiration += q1ag;
                this.q2Aspiration += q2ag;
                this.q3Aspiration += q3ag;
                this.q4Aspiration += q4ag;

                this.totalAspirationAttainment1 = this.q1Aspiration !== 0 ? ((this.totalActualsQ1 / this.q1Aspiration) * 100).toFixed(1) : 0;
                this.totalAspirationAttainment2 = this.q2Aspiration !== 0 ? ((this.totalActualsQ2 / this.q2Aspiration) * 100).toFixed(1) : 0;
                this.totalAspirationAttainment3 = this.q3Aspiration !== 0 ? ((this.totalActualsQ3 / this.q3Aspiration) * 100).toFixed(1) : 0;
                this.totalAspirationAttainment4 = this.q4Aspiration !== 0 ? ((this.totalActualsQ4 / this.q4Aspiration) * 100).toFixed(1) : 0;

            });
        });
    }

    get getClassForAspirationAttainment1() {
        if (this.totalAspirationAttainment1 >= 100) {
            return 'slds-text-align_right2 bgClolor1';
        } else if (this.totalAspirationAttainment1 >= 80) {
            return 'slds-text-align_right2 bgClolor3';
        } else {
            return 'slds-text-align_right2 bgClolor2';
        }
    }

    get getClassForAspirationAttainment2() {
        if (this.totalAspirationAttainment2 >= 100) {
            return 'slds-text-align_right2 bgClolor1';
        } else if (this.totalAspirationAttainment2 >= 80) {
            return 'slds-text-align_right2 bgClolor3';
        } else {
            return 'slds-text-align_right2 bgClolor2';
        }
    }

    get getClassForAspirationAttainment3() {
        if (this.totalAspirationAttainment3 >= 100) {
            return 'slds-text-align_right2 bgClolor1';
        } else if (this.totalAspirationAttainment3 >= 80) {
            return 'slds-text-align_right2 bgClolor3';
        } else {
            return 'slds-text-align_right2 bgClolor2';
        }
    }

    get getClassForAspirationAttainment4() {
        if (this.totalAspirationAttainment4 >= 100) {
            return 'slds-text-align_right2 bgClolor1';
        } else if (this.totalAspirationAttainment4 >= 80) {
            return 'slds-text-align_right2 bgClolor3';
        } else {
            return 'slds-text-align_right2 bgClolor2';
        }
    }

    createTabs(record) {
        SalesRevenueStreamEmployees({ financialPlanningName: record.Name })
            .then(result => {
                record.employeeDetails = result.filter(employee => employee.Region__c === this.selectedRegion);
            })
            .catch(error => {
                console.error('Error:', error);
            });

        getRevenueStreamRegions({ financialPlanningName: record.Name })
            .then(result => {
                record.regionDetails = result;
            })
            .catch(error => {
                console.error('Error:', error);

                if (error.body && error.body.message) {
                    errorMessage = error.body.message;

                    if (errorMessage.includes('Logged In User dont have access to selected region.')) {
                        this.showModal = true;
                        this.modalHeader = 'Validation Error';
                        this.modalData = [{ message: 'No data found.' }];
                    }
                }
            });
    }

    loadEmployeeDetails(event) {
        const financialPlanningName = event.target.label;
        const record = this.financialPlanningRecords.find(
            record => record.Name === financialPlanningName
        );
        if (record) {
            if (record.employeeDetails.length === 0) {
                getRevenueStreamEmployees({ financialPlanningName })
                    .then(result => {
                        record.employeeDetails = result;
                        console.log('loadEmployeeDetails - Result:', result);
                    })
                    .catch(error => {
                        console.error('Error:', error);
                    });
            }
        }
    }

    loadRegionDetails(event) {
        const financialPlanningName = event.target.label;
        const record = this.financialPlanningRecords.find(
            record => record.Name === financialPlanningName
        );
        if (record) {
            if (record.regionDetails.length === 0) {
                getRevenueStreamRegions({ financialPlanningName })
                    .then(result => {
                        record.regionDetails = result;
                        console.log('loadRegionDetails - Result:', result);
                    })
                    .catch(error => {
                        console.error('Error:', error);
                    });
            }
        }
    }

    findEmployeeDetails(employeeId) {
        let details = null;
        this.financialPlanningRecords.forEach(record => {
            record.employeeDetails.forEach(employee => {
                if (employee.Id === employeeId) {
                    details = employee;
                }
            });
        });
        return details;
    }

    handleRegionClick(event) {
        event.preventDefault();
        const regionId = event.currentTarget.dataset.id;
        const regionDetails = this.findRegionDetails(regionId);
        this.modalHeader = regionDetails.Name;
        this.modalData = [regionDetails];
        this.showModal = true;
        console.log('handleRegionClick - Region Details:', regionDetails);
    }

    findRegionDetails(regionId) {
        let details = null;
        this.financialPlanningRecords.forEach(record => {
            record.regionDetails.forEach(region => {
                if (region.Id === regionId) {
                    details = region;
                }
            });
        });
        return details;
    }
    roundToInteger(value) {
        // Check if the value is a valid number
        if (!isNaN(value)) {
            // Round the value to the nearest integer
            return Math.round(value);
        }
        // Return original value if it's not a valid number
        return value;
    }

}