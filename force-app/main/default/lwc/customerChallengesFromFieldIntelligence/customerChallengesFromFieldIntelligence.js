import { LightningElement,api } from 'lwc';
import CHALLEGEINTEL_FIELD from '@salesforce/schema/Account.Challenge_Field_Intel__c';
import CAMCRMITSOLVE_FIELD from '@salesforce/schema/Account.Can_CRMIT_Solve_Support_Field_Intel__c';
import DIRECTPARTNERED_FIELD from '@salesforce/schema/Account.Direct_Partnered_Field_Intel__c';
import SUGGESTEDACTION_FIELD from '@salesforce/schema/Account.Suggested_Action_Plan_Field_Intel__c';
export default class CustomerChallengesFromFieldIntelligence extends LightningElement {
    @api recordId;
    @api objectApiName;
   // Challenge_Field_Intel__c,Can_CRMIT_Solve_Support_Field_Intel__c,Direct_Partnered_Field_Intel__c,Suggested_Action_Plan_Field_Intel__c 
    fields = [CHALLEGEINTEL_FIELD, CAMCRMITSOLVE_FIELD, DIRECTPARTNERED_FIELD, SUGGESTEDACTION_FIELD];

}