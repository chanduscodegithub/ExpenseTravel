import { LightningElement,api } from 'lwc';
import CRMITALINGEMENTFU_FIELD from '@salesforce/schema/Account.CRMIT_s_Alingment_Future__c';
import FUTUREINITIATIVE_FIELD from '@salesforce/schema/Account.Future_Initiatives__c';
import INITIATIVEONERCLIENTFU_FIELD from '@salesforce/schema/Account.Initiative_Owner_Client_Future__c';
import SUGGESTEDACTIONPLANFU_FIELD from '@salesforce/schema/Account.Suggested_Action_Plan_Future__c';
import POTENTIALOPPOR_FIELD from '@salesforce/schema/Account.Potential_Opportunity_Name__c';
import BUDGETSTATUSAVAIL_FIELD from '@salesforce/schema/Account.Budget_Status_Availability__c';
export default class OpportunityInformationFuture extends LightningElement {
    @api recordId;
    @api objectApiName;
    
    //CRMIT_s_Alingment_Future__c,Future_Initiatives__c,Initiative_Owner_Client_Future__c,
     //Suggested_Action_Plan_Future__c,Potential_Opportunity_Name__c,Budget_Status_Availability__c

    fields = [CRMITALINGEMENTFU_FIELD, FUTUREINITIATIVE_FIELD, INITIATIVEONERCLIENTFU_FIELD, SUGGESTEDACTIONPLANFU_FIELD, POTENTIALOPPOR_FIELD, BUDGETSTATUSAVAIL_FIELD];

}