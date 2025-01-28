import { LightningElement, track } from 'lwc';
const columns = [
    { label: 'CContact Full Name (Client)', fieldName: 'Contact_Full_Name_l1__c' ,editable :'true' },
    { label: 'Background Notes (Client)', fieldName: 'Background_Notes__c', editable :'true' },
    { label: 'Relationship Strength (Client)', fieldName: 'Relationship_Strength__c', editable :'true' },
    { label: 'Title & Role (Client)', fieldName: 'Title_Role__c', editable :'true' },
    { label: 'CRMITs Contact (Client)', fieldName: 'CRMIT_s_Contact__c', editable :'true' },
    { label: 'Suggested Action Plan (Client)', fieldName: 'Suggested_Action_Plan_c__c', editable :'true' }
];
export default class ContactInformationClientContacts extends LightningElement {
   
    columns = columns;
    @track draftValue =[];
    @track focusedAccountList = [{Contact_Full_Name_l1__c: '',
    Background_Notes__c: '',
    Relationship_Strength__c: '',
    Title_Role__c: '',
    CRMIT_s_Contact__c: '',
    Suggested_Action_Plan_c__c: ''}];
    @track index = 0;


    handleClickRowAdd() {
       

        const newRow=   {Contact_Full_Name_l1__c: '',
            Background_Notes__c: '',
            Relationship_Strength__c: '',
            Title_Role__c: '',
            CRMIT_s_Contact__c: '',
            Suggested_Action_Plan_c__c: ''};
        
        this.focusedAccountList = [...this.focusedAccountList,newRow];
   }
}