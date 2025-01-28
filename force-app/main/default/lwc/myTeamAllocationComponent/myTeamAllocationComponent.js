import { LightningElement, api, wire, track } from 'lwc';
import findAllLastYearAllocated from '@salesforce/apex/TeamAllocationController.findAllLastYearAllocated';
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

export default class MyTeamAllocationComponent extends LightningElement {
    @api recordId;
    @track loading = false; 
    @track rowOffset = 0;
    @track teamAllocationData = [];
    @track columns = columns;
    @api cardIcon="custom:custom15";
    @api cardTitle="Employee Last Two Year Allocation";
    error;
    isDataAvailable;
    communityURL;

    async connectedCallback(){
        try{
            this.communityURL = await retrieveCommunityURL();
        }catch(er){
        }
       // console.log('Now calling...');
       this.isDataAvailable=false;
        this.fetchConfigData(); 
       

    }

    fetchConfigData(){
        this.loading = true;
        console.log('Now Started...calling...');
        findAllLastYearAllocated({teamAllocationRecordId:this.recordId }).then(result => {
            console.log(JSON.stringify(result));
            this.teamAllocationData = this.parseTeamAllocationData(result);
            this.isDataAvailable = this.teamAllocationData.length>0 ? true:false;
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
                projectUrl: this.getCommunityURL(teamAllocation.Project__c),
                //projectUrl: `/${teamAllocation.Project__c}`,
                StartDate: teamAllocation.StartDate__c,
                EndDate: teamAllocation.EndDate__c,
                BillableStatus: teamAllocation.Billing_Status__c,
                AllocationPercentage: teamAllocation.AllocationPercentage__c
            };
        });
    }

    getCommunityURL(projectId){
        if(this.communityURL != null)
          return this.communityURL +'/s/project/'+ projectId;
          else
           return '/'+projectId;
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