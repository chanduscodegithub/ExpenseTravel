import { LightningElement,wire,track, api } from 'lwc';
import getAwardedStars from '@salesforce/apex/starRouterClass.getAwardedStars';
import { refreshApex } from '@salesforce/apex';

const columns = [
    // { label: 'Id', fieldName: 'Id',sortable: true,type:'text'},
    // { label: 'Name', fieldName: 'Name',sortable: true,type:'text'},
    //{ label: 'Called On', fieldName: 'createdDate',sortable: true, type:'date',initialWidth:150},
    { label: 'Awarded Date', fieldName: 'CreatedDate',sortable: true,type:'date',typeAttributes:{
        year: "numeric",
        month: "long",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit"
    },initialWidth:170},   
    { label: 'Awared To', fieldName: 'Awarded',sortable: true,type:'text',wrapText: true},
    { label: 'Star Type', fieldName: 'Star',sortable: true,type:'text',wrapText: true},
    { label: 'Comments', fieldName: 'Comment',sortable: false,type:'text',wrapText: true},
];


export default class ListOfAwardStar extends LightningElement {

    lstOfStars;
    recordReff;
    @track defaultSortDirection = 'asc';
    @track sortDirection = 'asc';
    @track sortedBy;

    @track columns = columns;
    @wire(getAwardedStars)
    wiredStarRecords(result) {
        if (result.data) {
            try {
                this.recordReff=result;
                this.lstOfStars=[];
                this.lstOfStars = JSON.parse(result.data);   
            } catch (error) {
                console.log(error);
            }                                           
        } else if (result.error) {
            this.error = result.error;
            console.log('Error in StarAwardContainer');
            console.log(error);
        }
    }

    @api
    refreshTable(){
        return refreshApex(this.recordReff);
    }

    
    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [...this.lstOfStars];

        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        //this.taskList = cloneData;
        this.lstOfStars = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
    }
}