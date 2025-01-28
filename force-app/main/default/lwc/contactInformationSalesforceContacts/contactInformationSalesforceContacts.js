import { LightningElement,track } from 'lwc';
const columns = [
    { label: 'Salesforce Region', fieldName: 'Salesforce_Region__c' ,editable :'true'},
    { label: 'Contact Full Name (Salesforce)', fieldName: 'Contact_Full_Name_l2__c' ,editable :'true'},
    { label: 'Background Notes (Salesforce)', fieldName: 'Background_Notes_b__c',editable :'true' },
    { label: 'Relationship Strength (Salesforce)', fieldName: 'Relationship_Strength_b__c',editable :'true'},
    { label: 'Title & Role (Salesforce)', fieldName: 'Title_Role_b__c',type: 'text'},
    { label: 'CRMITs Contact (Salesforce)', fieldName: 'CRMIT_s_Contact_b__c',editable :'true'},
    { label: 'Suggested Action Plan (Salesforce)', fieldName: 'Suggested_Action_Plan_bv__c',editable :'true' }
];
export default class ContactInformationSalesforceContacts extends LightningElement {
    columns =columns ;
    @track draftValue =[];
@track salesforceContacts = [{Salesforce_Region__c:'',
                              Contact_Full_Name_l1__c: '',
                              Background_Notes_b__c:'',
                              Relationship_Strength_b__c,
                              Title_Role_b__c,
                              CRMIT_s_Contact_b__c,
                              Suggested_Action_Plan_bv__c}];
 handleClickRowAdd() {                          
               const newRow={Salesforce_Region__c:'',
                              Contact_Full_Name_l1__c: '',
                              Background_Notes_b__c:'',
                              Relationship_Strength_b__c,
                              Title_Role_b__c,
                              CRMIT_s_Contact_b__c,
                            Suggested_Action_Plan_bv__c}
                                
                                this.salesforceContacts = [...this.salesforceContacts,newRow];
                           }                            
}