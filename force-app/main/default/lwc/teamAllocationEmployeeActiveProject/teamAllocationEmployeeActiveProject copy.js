import { LightningElement, api, wire, track } from 'lwc';
import myActiveTeamAllocationRecords from '@salesforce/apex/TeamAllocationController.myActiveTeamAllocationRecords';
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
export default class TeamAllocationEmployeeActiveProject extends LightningElement {
    
    @api recordId;
    @track loading = false; 
    @track rowOffset = 0;
    @track teamAllocationData = [];
    @track columns = columns;
    
    @api cardIcon="custom:custom15";
    @api cardTitle="Employee Active Project";
    error;
    isDataAvailable;

    connectedCallback(){
        console.log('Now calling...');
        this.isDataAvailable=false;
        this.fetchConfigData(); 

    }

    fetchConfigData(){
        this.loading = true;
        console.log('Now Started...calling...');
        myActiveTeamAllocationRecords({teamAllocationRecordId:this.recordId }).then(result => {
            console.log(JSON.stringify(result));
            this.teamAllocationData = this.parseTeamAllocationData(result);
            console.log(this.teamAllocationData.length);
            this.isDataAvailable = this.teamAllocationData.length>0 ? true:false;
            console.log(this.isDataAvailable);
            this.error = undefined;
            this.loading = false;
        })
        .catch(error => {
            console.log('Now Started...calling...ERROR' + error);
            this.error = error;
            this.loading = false;
        })
    }

    parseTeamAllocationData(teamAllocationsData) {
        return teamAllocationsData.map(teamAllocation => {
            return {
                id:teamAllocation.id,
                ProjectName : teamAllocation.Project__r.Name,
                projectUrl: `/${teamAllocation.Project__c}`,
                StartDate: teamAllocation.StartDate__c,
                EndDate: teamAllocation.EndDate__c,
                BillableStatus: teamAllocation.Billing_Status__c,
                AllocationPercentage: teamAllocation.AllocationPercentage__c
            };
        });
    }

   
    handleContactView(event) {
        // Navigate to contact record page
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: event.target.value,
                objectApiName: 'Project__C',
                actionName: 'view',
            },
        });
    }
}