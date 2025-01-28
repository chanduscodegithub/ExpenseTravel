trigger BillingUpdatetoCleartax on AcctSeed__Billing__c (after Update) {
    if(shouldIRun.canIRun()){ 
    List<Id> billListId=new List<Id>();
    for(AcctSeed__Billing__c bill:Trigger.New){
        if((bill.AcctSeed__Status__c == 'Posted' && bill.Ledger_Name__c == 'CRMIT - India' && bill.AcctSeed__Type__c == 'Invoice') ||Test.isRunningTest()) {
            billListId.add(bill.Id);
        }
    }
    
    if(billListId.size()>0){
       generateeInvoice.eInvoice(billListId); 
    }
    } 
}