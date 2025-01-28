import { LightningElement,api } from 'lwc';
export default class ViewEmployeeRecord extends LightningElement {

    @api recordId;
    @api reportingmanager = '';
    @api costcentermanager = '';
    @api empdesignation = '';

}