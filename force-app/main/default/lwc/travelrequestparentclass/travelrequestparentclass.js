import { LightningElement } from 'lwc';
export default class Travelrequestparentclass extends LightningElement {
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