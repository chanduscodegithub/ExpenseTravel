import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class ResourceRequisitionHeader extends NavigationMixin(LightningElement) {
    @api recordId;

}