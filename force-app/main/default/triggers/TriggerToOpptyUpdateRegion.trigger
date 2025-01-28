/**
 * @File Name          : TriggerToOpptyUpdateRegion.trigger
 * @Description        : 
 * @Author             : Rohit Pal
 * @Group              : 
 * @Last Modified On   : 4/7/2020, 7:49:01 pm
 * @Modification Log   : 
 * Ver       Date            Author                 Modification
 * 1.0    29/6/2020          Rohit Pal              Initial Version
**/
trigger TriggerToOpptyUpdateRegion on Opportunity (after Insert,after Update) {
   
    /*
    if(Trigger.isInsert){
     OpportunityRegionCustomerType.getOpportunityRegion(Trigger.New);
    }
    */
    //
    if (Trigger.isAfter&&Trigger.isInsert) {
        Map<Id, Opportunity> mapNewOpportunity = new Map<Id, Opportunity>();
        //
        for(Opportunity Iterator : Trigger.New){
            //
            if(Iterator.Opportunity_Stream__c == 'RFP Process'){
                mapNewOpportunity.put(Iterator.Id, Iterator);
            }
        }
        //
        if(!mapNewOpportunity.isEmpty()){
            OpportunityTriggerHelper.createRFPREcord(mapNewOpportunity ,false);
        }        
    }
    if(Trigger.isAfter &&Trigger.isUpdate){
        //
        Map<Id, Opportunity> mapOldOpportunity = New Map<Id, Opportunity>();
        mapOldOpportunity.putAll(Trigger.old);
        Map<Id, Opportunity> mapNewOpportunity = new Map<Id, Opportunity>();
        Map<Id, Opportunity> mapNewOpportunityupdateRFPRecord= new Map<Id, Opportunity>();
        //
        for(Opportunity Iterator : Trigger.New){
            //
            if(Iterator.Opportunity_Stream__c != mapOldOpportunity.get(Iterator.Id).Opportunity_Stream__c
                &&
                Iterator.Opportunity_Stream__c == 'RFP Process'){
                //
                mapNewOpportunity.put(Iterator.id, Iterator);
            }
            if (Iterator.Opportunity_Status__c !=  mapOldOpportunity.get(Iterator.Id).Opportunity_Status__c
                &&
                (Iterator.Opportunity_Status__c == 'Won' ||  Iterator.Opportunity_Status__c=='Lost')) {
                //
                mapNewOpportunityupdateRFPRecord.put(Iterator.id, Iterator);
            }
        }
        //
        if(!mapNewOpportunity.isEmpty()){
            OpportunityTriggerHelper.createRFPREcord(mapNewOpportunity , True);
        }
        //
        if (!mapNewOpportunityupdateRFPRecord.isEmpty()) {
            OpportunityTriggerHelper.updateRFPRecord(mapNewOpportunityupdateRFPRecord);
        }
    }
}