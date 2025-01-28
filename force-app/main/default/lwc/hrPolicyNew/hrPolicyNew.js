import { LightningElement, track, wire } from 'lwc';
export default class HrPolicyNew extends LightningElement {

        switchTab(event) {
        const selectedTab = event.target.dataset.tab;
        console.log('Selected Tab:', selectedTab);

        const allTabs = this.template.querySelectorAll('.tab-panel');
        const allTabButtons = this.template.querySelectorAll('.tab-button');

        // Hide all tabs and remove the active class from buttons
        allTabs.forEach((tab) => {
            tab.classList.add('slds-hide'); // Hide the tab
            tab.classList.remove('active'); // Optional, in case "active" is on panels too
        });
        allTabButtons.forEach((button) => button.classList.remove('active'));

        // Show the selected tab and set the active class on the button
        const selectedTabPanel = this.template.querySelector(`.tab-panel[data-tab="${selectedTab}"]`);
        if (selectedTabPanel) {
            selectedTabPanel.classList.remove('slds-hide'); // Show the selected tab
            selectedTabPanel.classList.add('active'); // Show the selected tab
        }

        event.target.classList.add('active'); // Highlight the clicked button
        this.activeTab = selectedTab; // Update the active tab (optional)
    }








}