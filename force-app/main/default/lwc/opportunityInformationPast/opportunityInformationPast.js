import { LightningElement,api } from 'lwc';
import POAT12MOTHS_FIELD from '@salesforce/schema/Account.Past_12_Months_Engagement__c';
import CONTRACTVALUESIGNED_FIELD from '@salesforce/schema/Account.Contract_Value_Signed__c';
import REFERENCABLE_FIELD from '@salesforce/schema/Account.Referencable_Y_N__c';
import OPPWON_FIELD from '@salesforce/schema/Account.Opportunity_Won__c';
import DURATIONENGAGED_FIELD from '@salesforce/schema/Account.Duration_Engaged__c';
import KEYTAKEAWAYS_FIELD from '@salesforce/schema/Account.Key_Takeaways_if_any__c';
export default class OpportunityInformationPast extends LightningElement {
    @api recordId;
    @api objectApiName;
   // Past_12_Months_Engagement__c,Contract_Value_Signed__c,Referencable_Y_N__c
      //Opportunity_Won__c,Duration_Engaged__c,Key_Takeaways_if_any__c
    fields = [POAT12MOTHS_FIELD, CONTRACTVALUESIGNED_FIELD, REFERENCABLE_FIELD, OPPWON_FIELD, DURATIONENGAGED_FIELD,KEYTAKEAWAYS_FIELD];

}