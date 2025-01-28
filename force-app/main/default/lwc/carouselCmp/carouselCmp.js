import { LightningElement, wire, track } from 'lwc';
import getmessages from '@salesforce/apex/carouselclass.getmessages';
export default class CarouselCmp extends LightningElement {
    @track data;
    @wire(getmessages)
    messages(result) {
        if (result.data) {
            //console.log(result.data);
            this.data = result.data;
            this.error = undefined;
        } else if (result.error) {
            this.error = result.error;
            this.data = undefined;
        }
    }
}