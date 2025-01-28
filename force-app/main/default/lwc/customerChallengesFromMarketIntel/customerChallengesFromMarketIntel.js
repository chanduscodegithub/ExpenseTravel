import { LightningElement,api } from 'lwc';
import CHALLEGEMARKETINTEL_FIELD from '@salesforce/schema/Account.Challenge_Market_Intel__c';
import CAMCRMITSOLVEMI_FIELD from '@salesforce/schema/Account.Can_CRMIT_Solve_Support_Market_Intel__c';
import DIRECTPARTNEREDMI_FIELD from '@salesforce/schema/Account.Direct_Partnered_Market_Intel__c';
import SUGGESTEDACTIONMI_FIELD from '@salesforce/schema/Account.Suggested_Action_Plan_Market_Intel__c';
export default class CustomerChallengesFromMarketIntel extends LightningElement {
    @api recordId;
    @api objectApiName;
  fields = [CHALLEGEMARKETINTEL_FIELD, CAMCRMITSOLVEMI_FIELD, DIRECTPARTNEREDMI_FIELD, SUGGESTEDACTIONMI_FIELD];

}