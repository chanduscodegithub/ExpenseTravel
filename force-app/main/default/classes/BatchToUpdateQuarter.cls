/*
* Author : Harsha.c
* Batch : To update the billing Quarter.
* 
*/
global class BatchToUpdateQuarter implements Database.Batchable<sObject>, Database.Stateful{
    Integer totalLead = 0;
    Integer total = 0;
    global List<String> exception_List = new List<String>();
    global List<String> success_List = new List<String>();
    Set<Id> failIds = new Set<Id>();
    Set<Id> successIds = new Set<Id>();
    Integer successOpportunitiesCount = 0;
    Integer failureOpportunitiesCount = 0;
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('$start() ------------- STARTS');
        String QueryOpty='Select Id,Invoice_Date__c, Balance_Opportunity_Amount__c,Invoice_Amount__c from Billing__c where Invoice_Date__c != null ';
        System.debug('$start() ------------- ENDS');
        return Database.getQueryLocator(QueryOpty); 
    }
    global void execute(Database.BatchableContext bc, List<sObject> billList1)
    {
        List<Billing__c> billList = new  List<Billing__c>();
        List<Billing__c> billingList = (List<Billing__c >)billList1;
        
        for( Integer i=0;i<billingList.size();i++){
            if(billingList[i].Invoice_Date__c != null){
                Integer month = billingList[i].Invoice_Date__c.month();
                Integer year = billingList[i].Invoice_Date__c.year();
                System.debug('month  '+month);
                System.debug('year  '+year);
                
                if( month == 1){
                    billingList[i].Invoice_Month__c = 'JAN';
                }
                else if( month == 2){
                    billingList[i].Invoice_Month__c = 'FEB';
                }
                else if( month == 3){
                    billingList[i].Invoice_Month__c = 'MAR';
                }
                else if( month == 4){
                    billingList[i].Invoice_Month__c = 'APR';
                }
                else if( month == 5){
                    billingList[i].Invoice_Month__c = 'MAY';
                }
                else if( month == 6){
                    billingList[i].Invoice_Month__c= 'JUN';
                }
                else if( month == 7){
                    billingList[i].Invoice_Month__c= 'JUL';
                }
                else if( month == 8){
                    billingList[i].Invoice_Month__c = 'AUG';
                }
                else if( month == 9){
                    billingList[i].Invoice_Month__c= 'SEP';
                }
                else if( month == 10){
                    billingList[i].Invoice_Month__c = 'OCT';
                }
                else if( month == 11){
                    billingList[i].Invoice_Month__c = 'NOV';
                }
                else if( month == 12){
                    billingList[i].Invoice_Month__c = 'DEC';
                }
                
                if(month >= 1 && month <= 3){
                    billingList[i].Invoice_Quarter__c  = 'Q4 - ' +year;
                }
                else if(month >= 4 && month <= 6){
                    billingList[i].Invoice_Quarter__c = 'Q1 - '+ year ;
                }
                else if(month >= 7 && month <= 9){
                    billingList[i].Invoice_Quarter__c = 'Q2 - '+ year ;
                }
                else if(month >= 10 && month <= 12){
                    billingList[i].Invoice_Quarter__c= 'Q3 - '+ year ;
                }
            }
            billList.add(billingList[i]);
        }
        
        Database.SaveResult[]  SaveResultListLead;
        if(!billList.isEmpty()){
            SaveResultListLead = Database.update(billList, false);
            totalLead = totalLead + billList.size();
            for(integer i =0; i<billList.size();i++){
                String msg11='';
                String msg22='';
                If(!SaveResultListLead[i].isSuccess()){
                    failIds.add(billList.get(i).id);
                    msg11 += billList.get(i).id + '==>'+'Error: "';        
                    for(Database.Error err: SaveResultListLead[i].getErrors()){  
                        msg11 += err.getmessage()+'\n';
                        failureOpportunitiesCount = failureOpportunitiesCount +1;
                    } 
                }else{
                    successIds.add(billList.get(i).id);
                    successOpportunitiesCount = successOpportunitiesCount +1;
                    msg22= msg22+''+ billList.get(i).id +'==>'+'SUCCESS: Updated!';
                }
                if(msg11!='')
                    exception_List.add(msg11);
                if(msg22!='')
                    success_List.add(msg22);
            }       
        }
        
    }
    global void finish(Database.BatchableContext bc){
        System.debug('$Finish() --------- STARTS');
        System.debug('exception_List'+exception_List);
        System.debug('success_List'+success_List);
        System.debug('SUCCESS'+successOpportunitiesCount);
        System.debug('FAILURE'+failureOpportunitiesCount);
        System.debug('$Finish() --------- ENDS'+total);
        System.debug('$Finish() --------- ENDS'+totalLead);
    }
}