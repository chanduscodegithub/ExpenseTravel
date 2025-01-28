import { LightningElement,wire,track } from 'lwc';
import getAppraisalRecord from '@salesforce/apex/AppraisalCycleHRController.appraisalYear';
import { CloseActionScreenEvent } from 'lightning/actions';
import getRatingPicklistValues from '@salesforce/apex/AppraisalCycleHRController.getPicklistValues';
import getrecorddata from '@salesforce/apex/AppraisalCycleHRController.chkthisyeardata';
import { RefreshEvent } from 'lightning/refresh';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class AppraisalCycleHR extends LightningElement {
 @track year=String(new Date().getFullYear());
 @track isedit=true;
 @track recordId='';
 @track readonly=false;
 @track create=false;
 @track edit=false;
 @track showoption=true;
 @track data;
 @track selectedyear;
 
 currentyear;
 @track disablesave=false;
fields = ['Name','QPR_Start_Date__c','QPR_End_Date__c','QPR_Year__c','Q1ManagerSubmissionStartDate__c','Q1ManagerSubmissionEndDate__c','Q1EmployeeSubmissionStartDate__c','Q1EmployeeSubmissionEndDate__c','Emp_goalsetting_Start_date__c','Emp_Goalsetting_End_date__c','Mngr_Goalsetting_End_Date__c','CCM_End_Date__c'];

    appraisalYearHandler(event){
        this.year=event.detail.value;
        this.selectedyear=this.year;
        this.getquaterdetails(this.year);
    }
    connectedCallback() {
        console.log('onload',this.year);
        this.selectedyear=this.year;
        this.year=new Date().getFullYear();
        this.getquaterdetails(this.year);
        this.currentyear=new Date().getFullYear();
    }

    updateHandler(event) {
        this.dispatchEvent(new RefreshEvent());
         this.showToast('Successfully Updated','Appraisal Submission dates has been updated Successfully','success');
    
      this.closeAction();
    }
     @wire(getRatingPicklistValues, {})
    // Define a wired property for rating picklist values
    wiredRatingPicklistValues({ error, data }) {
        // If data is returned from the wire function
        if (data) {
            // Map the data to an array of options
            this.ratingOptions = data.map(option => {
                return {
                  
                    label: option.label,
                    value: option.value
                };
            });
        }
        // If there is an error
        else if (error) {
            // Log the error to the console
            console.error(error);
        }
    }
     @wire(getrecorddata, {})
       wiredRatingPicklistValuesss({ error, data }) {
           
              this.isedit=data;
    
     
    if (error) {
            
            // Log the error to the console
            console.error(error);
        }
     }
    // Define a wired property for rating picklist values
    
    

    handleSuccess(event) {
        event.preventDefault(); // stop the form from submitting
        const fields = event.detail.fields;
        if( fields.QPR_Year__c!=this.currentyear)
        {
           this.showToast('You cannot select previous and next year','','Error');
        }
      
       else{
        this.template.querySelector('lightning-record-form').submit(fields);
        const evt = new ShowToastEvent({
            title: "Account created",
            message: "Successfully",
            variant: "success"
        });
        this.dispatchEvent(evt);
       }
    }
    handlecancel()
    {
        this.closeAction();
    }
    showToast(tostTitl, msg, variant) {
        const event = new ShowToastEvent({
            title: tostTitl,
            message: msg,
            variant: variant,
            // mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }
    closeAction(){
        this.dispatchEvent(new CloseActionScreenEvent());
    }
    getquaterdetails(year)
    {
       
        getAppraisalRecord({ year:year})
		.then(result => {
		 this.recordId=result;
        
        if(this.year==this.currentyear)
        {
         this.readonly=false;   
        }
        else{
          this.readonly=true;  
        }
       
		})
		.catch(error => {
		  this.readonly=true;
            console.error(error);
        this.showToast('Error','Please select current or previous Years','Error');
		})
	} 
    
}