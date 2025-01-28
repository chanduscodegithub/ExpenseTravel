import { LightningElement } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { getErrorBody } from './utils';
import getEmployeeDetails from '@salesforce/apex/ExitManagementController.getEmployeeDetails';

export default class ExitManagementParent extends LightningElement {
    loaded = false;
    activeTab = 'myResignationTab';
    empData;

    async connectedCallback() {
        try {
            this.empData = await getEmployeeDetails();
            console.clear();
            this.loaded = true;
        } catch (error) {
            this.loaded = true;
            const evt = new ShowToastEvent(getErrorBody(error, 'sticky'));
            this.dispatchEvent(evt);
        }
    }
    switchTab(event) {
        const selectedTab = event.target.dataset.tab;
        const allTabs = this.template.querySelectorAll('.tab-panel');
        const allTabButtons = this.template.querySelectorAll('.tab-button');
        allTabs.forEach((tab) => {
            tab.classList.add('slds-hide');
            tab.classList.remove('active');
        });
        allTabButtons.forEach((button) => button.classList.remove('active'));
        const selectedTabPanel = this.template.querySelector(`.tab-panel[data-tab="${selectedTab}"]`);
        if (selectedTabPanel) {
            selectedTabPanel.classList.remove('slds-hide');
            selectedTabPanel.classList.add('active');
        }
        event.target.classList.add('active');
        this.activeTab = selectedTab;
    }
}