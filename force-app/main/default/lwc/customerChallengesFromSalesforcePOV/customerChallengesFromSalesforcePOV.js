import { LightningElement,api } from 'lwc';

import CAMCRMITSOLVESALESFORCE_FIELD from '@salesforce/schema/Account.Can_CRMIT_Solve_Support_Salesforce_POV__c';
import CHALLEGESALESFORCEPOV_FIELD from '@salesforce/schema/Account.Challenge_Salesforce_POV__c';
import DIRECTPARTNEREDSALESFORCEPOV_FIELD from '@salesforce/schema/Account.Direct_Partnered_Salesforce_POV__c';
import SUGGESTEDACTIONSALESFORCEPOV_FIELD from '@salesforce/schema/Account.Suggested_Action_Plan_Salesforce_POV__c';
export default class CustomerChallengesFromSalesforcePOV extends LightningElement {
    @api recordId;
    @api objectApiName;
   // Can_CRMIT_Solve_Support_Salesforce_POV__c,Challenge_Salesforce_POV__c,
//Direct_Partnered_Salesforce_POV__c,Suggested_Action_Plan_Salesforce_POV__c
    fields = [CAMCRMITSOLVESALESFORCE_FIELD, CHALLEGESALESFORCEPOV_FIELD, DIRECTPARTNEREDSALESFORCEPOV_FIELD, SUGGESTEDACTIONSALESFORCEPOV_FIELD];

}