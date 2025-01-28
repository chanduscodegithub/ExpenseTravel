trigger JobApplicaitonTrigger on Job_Application__c (after update, after insert,after delete,after undelete) {
    if(Trigger.isAfter && Trigger.isUpdate){
        List<Job_Application__c> jobApplication = Trigger.New;
        set<Id> jobappId = new set<Id>();
        
        System.debug('jobApplication - '+jobApplication);
        Map<Id,Integer> positionExtended = new Map<Id,Integer>();
        
        for(Job_Application__c eachJA : jobApplication){
            if(Trigger.OldMap.get(eachJA.Id).Picklist__c != eachJA.Picklist__c && eachJA.Picklist__c == 'Extend an Offer'){
                System.debug('Inside If Condition');
                positionExtended.put(eachJA.Position__c,positionExtended.get(eachJA.Position__c)!=null ? positionExtended.get(eachJA.Position__c) + 1 : 1);
            }
            else if(Trigger.OldMap.get(eachJA.Id).Picklist__c != eachJA.Picklist__c && eachJA.Picklist__c == 'Rejected'){
                if(positionExtended.get(eachJA.Position__c) == null || positionExtended.get(eachJA.Position__c) == 0){
                    positionExtended.put(eachJA.Position__c,0);
                }
                else{
                    positionExtended.put(eachJA.Position__c,positionExtended.get(eachJA.Position__c) - 1);
                }
            }
            else if(Trigger.OldMap.get(eachJA.Id).Number_of_Interviews__c!=eachJA.Number_of_Interviews__c && eachJA.Number_of_Interviews__c!=null && eachJA.Position__c!=null)
            {
                jobappId.add(eachJA.Position__c);
                
            }
        }
        
        Set<Id> positionsIds = new Set<Id>();
        for(Id eachPosId : positionExtended.keySet()){
            if(positionsIds.contains(eachPosId)==false){
                positionsIds.add(eachPosId);
            }
        }
        
        List<Position__c> positionList = [SELECT Id, Name, Number_of_Offers_Extended__c FROM Position__c where Id IN :positionsIds];
        System.debug('positionList - '+positionList);
        
        for(Id eachPosId : positionExtended.keySet()){
            for(Position__c eachPos : positionList){  
                if(eachPosId == eachPos.Id){
                    if(eachPos.Number_of_Offers_Extended__c == null || eachPos.Number_of_Offers_Extended__c==0){
                        if(positionExtended.get(eachPosId)>0){
                            eachPos.Number_of_Offers_Extended__c = positionExtended.get(eachPosId);
                        }
                    }
                    else{
                        eachPos.Number_of_Offers_Extended__c = eachPos.Number_of_Offers_Extended__c + positionExtended.get(eachPosId);
                    }
                    break;
                }
            }
        }
        update positionList;
        JobApplicationTriggerHandler.updateinterviews(jobappId);        
        
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
        List<Job_Application__c> jobApplication = Trigger.New;
        
        Set<Id> positionId = new Set<Id>();
        set<Id> jobappId = new set<Id>();
        
        for(Job_Application__c eachJA : jobApplication){
            if(positionId.contains(eachJA.Position__c)==false){
                positionId.add(eachJA.Position__c);
            }
            if(eachJA.Number_of_Interviews__c!=null && eachJA.Position__c!=null)
            {
                jobappId.add(eachJA.Position__c);
            }
        }
        
        
        JobApplicationTriggerHandler.updateinterviews(jobappId);        
        List<Position__c> updatePositions = new List<Position__c>();
        for(Id eachId : positionId){
            Position__c temp = new Position__c();
            temp.Id = eachId;
            temp.Status__c = 'In Progress';
            updatePositions.add(temp);
        }
        update updatePositions;
    }
    
      Set<Id> positionIds = new Set<Id>();

    // Collect Position Ids from new and old Job Applications
    if (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete) {
        for (Job_Application__c jobApp : Trigger.new) {
            if (jobApp.Position__c != null) {
                positionIds.add(jobApp.Position__c);
            }
        }
    }

    if (Trigger.isDelete || Trigger.isUpdate) {
        for (Job_Application__c jobApp : Trigger.old) {
            if (jobApp.Position__c != null) {
                positionIds.add(jobApp.Position__c);
            }
        }
    }

    // Query for Positions and their Job Applications
    List<Position__c> positions = [SELECT Id, (SELECT Id FROM Job_Applications__r) FROM Position__c WHERE Id IN :positionIds];

    // Update the Total Job Applications count
    List<Position__c> positionsToUpdate = new List<Position__c>();
    for (Position__c pos : positions) {
        pos.Total_Job_Applications__c = pos.Job_Applications__r.size();
        positionsToUpdate.add(pos);
    }

    // Perform the update
    if (!positionsToUpdate.isEmpty()) {
        update positionsToUpdate;
    }

}