import { LightningElement,api } from 'lwc';
import CRMITALINGEMENT_FIELD from '@salesforce/schema/Account.CRMIT_s_Alingment_Present__c';
import RENENUEOPP_FIELD from '@salesforce/schema/Account.Revenue_Opportunity__c';
import OPPORPIPLELINE_FIELD from '@salesforce/schema/Account.Opportunity_Pipeline__c';
import INITIATIVEONERCLIENT_FIELD from '@salesforce/schema/Account.Initiative_Owner_Client_Present__c';
import PRESENRINVOLVED_FIELD from '@salesforce/schema/Account.Present_Involved_Initiatives__c';
import SUGGESTEDACTIONPLAN_FIELD from '@salesforce/schema/Account.Suggested_Action_Plan_Present__c';
export default class OpportunityInformationPresent extends LightningElement {
    @api recordId;
    @api objectApiName;
    //
    //CRMIT_s_Alingment_Present__c,Revenue_Opportunity__c,Opportunity_Pipeline__c,
    //Initiative_Owner_Client_Present__c,Present_Involved_Initiatives__c,Suggested_Action_Plan_Present__c
    fields = [CRMITALINGEMENT_FIELD, RENENUEOPP_FIELD, OPPORPIPLELINE_FIELD, INITIATIVEONERCLIENT_FIELD, PRESENRINVOLVED_FIELD, SUGGESTEDACTIONPLAN_FIELD];

}