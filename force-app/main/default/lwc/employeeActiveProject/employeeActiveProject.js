import { LightningElement, api, wire, track } from 'lwc';
import myActiveProject from '@salesforce/apex/TeamAllocationController.myActiveProject';
import retrieveCommunityURL from '@salesforce/apex/TeamAllocationController.retrieveCommunityURL';

const columns = [
    { label: 'Project',
    fieldName: 'projectUrl',
    type: 'url',
    typeAttributes: {label: { fieldName: 'ProjectName' }, 
    target: '_blank'},
    sortable: true
},
    { label: 'Start Date', fieldName: 'StartDate' },
    { label: 'End Date', fieldName: 'EndDate' },
    { label: 'Billable Status', fieldName: 'BillableStatus' },
    { label: 'Allocation %', fieldName: 'AllocationPercentage', type:'number'}
];


export default class EmployeeActiveProject extends LightningElement {
    @api employeerecordid;
    @track loading = false; 
    @track rowOffset = 0;
    @track employeeData = [];
    @track columns = columns;
    communityURL;

    @api nodatamessage;
    @api whatprojects;
    error;
    isDataAvailable;

    async connectedCallback(){
        try{
            this.communityURL = await retrieveCommunityURL();
        }catch(er){
            
        }
        this.isDataAvailable=false;
        this.fetchConfigData(); 

    }

    fetchConfigData(){
        this.loading = true;
        myActiveProject({employeeId:this.employeerecordid,whatProjects:this.whatprojects }).then(result => {
            this.employeeData = this.parseemployeeData(result);
            this.isDataAvailable = this.employeeData.length>0 ? true:false;
            this.error = undefined;
            this.loading = false;
        })
        .catch(error => {
            console.log('Now Started...calling...ERROR' + error);
            this.error = error;
            this.loading = false;
        })
    }

    parseemployeeData(employeeData) {
        return employeeData.map(employee => {
            return {
                id:employee.id,
                ProjectName : employee.Project__r.Name,
                projectUrl: this.getCommunityURL(employee.Project__c),//`/${employee.Project__c}`,
                StartDate: employee.StartDate__c,
                EndDate: employee.EndDate__c,
                BillableStatus: employee.Billing_Status__c,
                AllocationPercentage: employee.AllocationPercentage__c
            };
        });
    }

    getCommunityURL(projectId){
        if(this.communityURL != null)
          return this.communityURL +'/s/project/'+ projectId;
          else
           return '/'+projectId;
    }

   /* async connectedCallback(){
        try{
            this.communityURL = await retrieveCommunityURL();
        }catch(er){
            
        }
    }*/

}