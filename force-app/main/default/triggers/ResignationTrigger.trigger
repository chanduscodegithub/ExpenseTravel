trigger ResignationTrigger on Resignation__c (before insert, after insert, before update, after update) {
    if(trigger.isBefore && trigger.isInsert){
        List<Resignation__c> res = (List<Resignation__c>)Trigger.new;
        ResignationTriggerHelper.beforeInsert(res);
    }
    if(trigger.isAfter && trigger.isInsert){
        
    }
    if(trigger.isAfter && trigger.isUpdate){
        List<Resignation__c> res = (List<Resignation__c>)Trigger.new;
        Map<Id, Resignation__c> oldResMap = (Map<Id, Resignation__c>)Trigger.oldMap;
        // ResignationTriggerHelper.afterUpdate(res, oldResMap);
    }
    if(trigger.isBefore && trigger.isUpdate){
        List<Resignation__c> res = (List<Resignation__c>)Trigger.new;
        Map<Id, Resignation__c> oldResMap = (Map<Id, Resignation__c>)Trigger.oldMap;
        ResignationTriggerHelper.beforeUpdate(res, oldResMap);
    }
}