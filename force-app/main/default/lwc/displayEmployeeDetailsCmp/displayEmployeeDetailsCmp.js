import { LightningElement, api, track } from 'lwc';
export default class DisplayEmployeeDetailsCmp extends LightningElement {
    @api empDetails;
    @api designation;
    @api empreportManager;
    @api ccm;

}