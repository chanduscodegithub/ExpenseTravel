import { LightningElement,api } from 'lwc';
import ANNUALREPORTED_FIELD from '@salesforce/schema/Account.Annual_Revenue_as_Reported__c';
import ANNUALRENUVAL_FIELD from '@salesforce/schema/Account.Annual_Revenue__c';
import MARKET_FIELD from '@salesforce/schema/Account.Market_Cap__c';
import CLIENTEBITDA_FIELD from '@salesforce/schema/Account.Client_EBITDA__c';
import CLIENTCAGR_FIELD from '@salesforce/schema/Account.Client_CAGR__c';
import SUGGESTEDACCOUNT_FIELD from '@salesforce/schema/Account.Suggested_Action_Plan_if_Any_Account_Ins__c';
import ENTITYPROFIT_FIELD from '@salesforce/schema/Account.Entity_Annual_Net_Profit__c';
import ANNUALMEDIAN_FIELD from '@salesforce/schema/Account.Annual_Median_FCF__c';
import ENTITYBS_FIELD from '@salesforce/schema/Account.Entity_B_S_size__c';


export default class AccountInsights extends LightningElement {
    @api recordId;
    @api objectApiName;
    fields = [ANNUALREPORTED_FIELD, ANNUALRENUVAL_FIELD, MARKET_FIELD, CLIENTEBITDA_FIELD, CLIENTCAGR_FIELD, CLIENTCAGR_FIELD, SUGGESTEDACCOUNT_FIELD,ENTITYPROFIT_FIELD,ANNUALMEDIAN_FIELD,ENTITYBS_FIELD];

}