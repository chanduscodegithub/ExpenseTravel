import { LightningElement,api,track } from 'lwc';

export default class EmployeeMainComponent extends LightningElement {
    @api recordId;
    @api cardIcon="custom:custom14";
    @api cardTitle="My Project";
    @track activeSectionMessage = '';

    handleToggleSection(event) {
        this.activeSectionMessage =
            'Open section name:  ' + event.detail.openSections;
    }

    handleSetActiveSectionC() {
        const accordion = this.template.querySelector('.example-accordion');
        accordion.activeSectionName = 'C';
    }
}