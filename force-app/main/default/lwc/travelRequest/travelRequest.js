import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class Travelrequest extends LightningElement {
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
        console.log('Selected Tab Panel:', this.template.querySelector(`.tab-panel[data-tab="Mytravelrequests"]`));

        // Show the selected tab and set the active class on the button
       
         if(selectedTab =="Mytravelrequests")
        {
              console.log('selectedTab123');
          const selectedTabPanel = this.template.querySelector(`.tab-panel[data-tab="Mytravelrequests"]`);
            selectedTabPanel.classList.remove('slds-hide'); // Show the selected tab
            selectedTabPanel.classList.add('active'); 
        }
        else 
        {
            console.log('selectedTab');
         const selectedTabPanel = this.template.querySelector(`.tab-panel[data-tab="Myteamtravelrequests"]`);
          selectedTabPanel.classList.remove('slds-hide'); // Show the selected tab
            selectedTabPanel.classList.add('active'); 
        }
       

        event.target.classList.add('active'); // Highlight the clicked button
        this.activeTab = selectedTab; // Update the active tab (optional)
    }
}