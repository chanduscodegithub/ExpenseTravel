import { LightningElement,wire } from 'lwc';
//import { newCasePageRef } from "c/navigationToPitStop";
import { NavigationMixin } from "lightning/navigation";
import IMAGES from "@salesforce/resourceUrl/engagementIcon";
import { CurrentPageReference } from 'lightning/navigation';



export default class Engagement360HomePage extends LightningElement {
        baseURL;
        customerEngagementImg = IMAGES + '/engagementIcon/customer.jpg';
        teamAllocationImg = IMAGES + '/engagementIcon/teamAllocation.jpg';
        timesheetImg = IMAGES + '/engagementIcon/timesheet.png';
        timesheetApprovalImg = IMAGES + '/engagementIcon/approval1.png';
        @wire(CurrentPageReference)
        getPageReference(currentPage) {
            if (currentPage && currentPage.attributes) {
                // Construct the base URL from the attributes
                const host = window.location.origin; // Get the domain
                const communityPath = currentPage.attributes.sitePath || 'CRMITCommunity'; // Fallback to an empty string if undefined
                this.baseURL = `${host}/${communityPath}/s`; // Ensure '/s/' and the community path are appended correctly
                console.log('Base URL:', this.baseURL, 'Community Path:', communityPath);
            } else {
                console.warn('CurrentPageReference attributes are undefined or currentPage is unavailable.');
            }
        }


        handleNavigatePitStop(event) {
        
        /*const defaultValues = encodeDefaultFieldValues({
            Type: 'Function HR',
            Sub_Type__c: 'Avishkaar - DreamDrive360',
        });*/

        let returnArray = newCasePageRef();
        this[NavigationMixin.Navigate](returnArray);

    }

    handleNavigation(event) {
        const targetURL = event.currentTarget.dataset.target; // Target URL from the dataset
        if (this.baseURL && targetURL) {
            // Combine the base URL with the target page
            window.location.href = `${this.baseURL}/${targetURL}`;
        } else {
            console.error('Base URL or target URL is missing.');
        }
    }
    

}