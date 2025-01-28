trigger TriggerToPopulateBalanceoptyAmount on Billing__c (After insert ,After Update) {
    if(Trigger.IsInsert){
        for(Billing__c b : Trigger.new){
            OpportunityInvoiceAmount.getOpportunityBillingAmountOnInsert(b.Id);
        }
    }
    
    if(Trigger.IsUpdate){
        list<Billing__c> changedIsMainList = new list<Billing__c>();
        Boolean invoicefield = false;
        Boolean dateupdate = false;
        Decimal inamnt =0;
        for(Billing__c b : trigger.new){
            if(b.Invoice_Amount__c  != trigger.oldMap.get(b.Id).Invoice_Amount__c ){
                invoicefield = true; 
                inamnt = trigger.oldMap.get(b.Id).Invoice_Amount__c; 
                
            }
            if(b.Invoice_Date__c  != trigger.oldMap.get(b.Id).Invoice_Date__c ){
                dateupdate = true; 
                
            }
            OpportunityInvoiceAmount.getOpportunityBillingAmountOnUpdate(b.OpportunityName__c,b.Id,invoicefield,dateupdate,inamnt);
        }
    }
}