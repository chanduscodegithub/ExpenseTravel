import { LightningElement, api, wire, track } from 'lwc';
import fetchWrapper from '@salesforce/apex/careerDevelopmentAndEnablementController.getCareerAndEnablementData'
import { refreshApex } from '@salesforce/apex';

export default class CareerDevelopmentAndEnablement extends LightningElement {

    @api empId = '';
    @api from;
    @api isFromGoalSetting = '';
    @api isEditable;
    @api isEditableCareer = false;
    @api isEditableTraining = false;
    @track employeeDetails;
    @track cdpCompleteDetails;
    @track cdepCompleteDetails;

    @track isDataLoaded = false;
    @track wiredResult = ""


    /* connectedCallback(){
         console.log('Calling Connected Call Back')
         fetchWrapper(({empid:this.empId}))
         .then( CDEPStringData => JSON.parse( CDEPStringData ) )
         .then( CDEPData => {
             this.employeeDetails = CDEPData.EmpDetails;
             console.log('CDEPData.addTrainDetails', CDEPData.addTrainDetails);
             this.cdpCompleteDetails = { comments: CDEPData.cdepDetails, cdpData: CDEPData.cdpDetails };
             this.cdepCompleteDetails = { 
                 comments: CDEPData.cdepDetails, 
                 cdepData: { 
                     certificationDetails: CDEPData.certificationDetails,
                     recommendedCertificates: CDEPData.recoCertDetails,
                     enablementDetails: CDEPData.addTrainDetails
                 }
             };
 
             this.isDataLoaded = true;
         })
         .catch(error => {
             console.error('The error is'+error)
         });
     } */

    @wire(fetchWrapper, { empid: '$empId' })
    wiredData(result) {
        this.wiredResult = result
        if (result.data) {
            const cdepData = JSON.parse(result.data);

            this.employeeDetails = cdepData.EmpDetails;
            this.cdpCompleteDetails = {
                comments: cdepData.cdepDetails,
                cdpData: cdepData.cdpDetails
            };
            this.cdepCompleteDetails = {
                comments: cdepData.cdepDetails,
                cdepData: {
                    certificationDetails: cdepData.certificationDetails,
                    recommendedCertificates: cdepData.recoCertDetails,
                    enablementDetails: cdepData.addTrainDetails
                }
            };
            
            if (this.isFromGoalSetting === 'true') {
                this.isEditableCareer = this.cdpCompleteDetails.cdpData.length > 0 ? false : true;
                this.isEditableTraining = this.cdepCompleteDetails.cdepData.recommendedCertificates.length > 0 && this.cdepCompleteDetails.cdepData.enablementDetails.length > 0 ? false : true;
            } else if (this.isFromGoalSetting === '' && this.isEditable === true) {
                this.isEditableCareer = true;
                this.isEditableTraining = true;
            }

            this.isDataLoaded = true;
        } else if (result.error) {
            console.error('The error is', result.error);
        }
    }

    handleCancelGS() {
        this.dispatchEvent(new CustomEvent('callcancelagain', {
            detail: {
                message: 'cancel',
            }
        }));
    }

    refreshData() {
        console.log('The refreshApex is called')
        console.log('wiredResult', this.wiredResult)
        refreshApex(this.wiredResult)
    }
    get employeeReportingManagerName() {
        return (this.employeeDetails.ReportingTo__r?.Name) ? this.employeeDetails.ReportingTo__r?.Name : '';
    }

    get employeeCCMName() {
        return (this.employeeDetails.BU_Head__r?.Name) ? this.employeeDetails.BU_Head__r.Name : '';
    }
}