import { LightningElement,wire } from 'lwc';
import getBirthAnniversary from '@salesforce/apex/CommunitiesLandingController.getBirthdayAnniversaryList';
export default class NewHireComponent extends LightningElement {
    employeeEvents;

    @wire(getBirthAnniversary)
        wiredNewHires({ data, error }) {
            if (data) {
                console.log('Data is',data);
                this.employeeEvents = data;
            } else if (error) {
                console.error(error);
            }
    }
}