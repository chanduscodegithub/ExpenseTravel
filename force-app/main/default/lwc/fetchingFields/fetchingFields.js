import { LightningElement ,wire, api} from 'lwc';
import getRecord from '@salesforce/apex/FetchingFieldsController.getIndividualEmailResult';
import { NavigationMixin } from 'lightning/navigation';

export default class FetchingFields extends NavigationMixin(LightningElement)  {
    @api recordId;
    record;   

    @wire(getRecord, {recordId: '$recordId'})
    wiredAccount({ error, data }) {
        if (data) {
            this.record = data;
            console.log('data',data);
        } else if (error) {
            console.log('Something went wrong:', error);
        }
    }
    handleClick(event) {
        console.log(`inside handleClick`);
        // Stop the event's default behavior (don't follow the HREF link) and prevent click bubbling up in the DOM...
        event.preventDefault();
        event.stopPropagation();
        // Navigate as requested...        
        this.navigateToRecordViewPage(event.target.dataset.id);
        console.log(`inside handleClick End =${JSON.stringify(event.target.dataset.id)}` );
    }        
    navigateToRecordViewPage(eventRecordId) {
        console.log('this.record.id'+this.record.id);
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId :eventRecordId ,
                objectApiName: 'et4ae5__IndividualEmailResult__c',
                actionName: 'view',
            },
        });
    }
    
}