trigger TotalCountOfApplicants on Job_Application__c (after INSERT, after UPDATE, after DELETE) {

Set <Id> positionIds = new Set <Id>();
List <Position__c> lstPositionToUpdate = new List <Position__c>();
 if(Trigger.isInsert){
    for(Job_Application__c job:trigger.new){
        positionIds.add(job.Position__c);
    }
}
if(Trigger.isUpdate|| Trigger.isDelete){
    for(Job_Application__c job:trigger.old){
        positionIds.add(job.Position__c);
    }
}

for(Position__c pos:[SELECT Id, Sourced_profiles__c,(Select Id from Job_Applications__r ) from Position__c  where Id IN: positionIds]){
    Position__c posObj = new Position__c ();
    posObj.Id = pos.Id;
    posObj.Sourced_profiles__c = pos.Job_Applications__r.size();
   lstPositionToUpdate.add(posObj);
}

UPDATE lstPositionToUpdate;
}