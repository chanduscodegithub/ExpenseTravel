trigger PositionExternalHires on Position__c (before insert, before update, after insert, after update) {
    if(Trigger.isBefore && Trigger.isInsert){
        List<Position__c> positionList = Trigger.New;
          Map<String,Position__c> updateResourceReq = new Map<String,Position__c>();
        Recruiting_Owner_Id__c recruitingOwner = Recruiting_Owner_Id__c.getInstance();
        
        for(Position__c eachPosition : positionList){
            //eachPosition.Hiring_Manager__c = eachPosition.OwnerId;
            //eachPosition.Recruiting_Owner__c = recruitingOwner.Recruiting_Owner_Id__c;
            //eachPosition.Approver__c = '00541000002ZSbnAAG';
            //eachPosition.Sales_Owner__c='0051K000008nuvqQAA';
            
            if(eachPosition.Position_Title__c!=null)
            {
                updateResourceReq.put(eachPosition.Position_Title__c,eachPosition);
            }
        }
        ResourceRequisitionTriggerHandler.autoPopulateSkills(updateResourceReq);
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        List<Position__c> positionList = Trigger.New;
       Map<String,Position__c> updateResourceReq=new Map<String,Position__c>();
        for(Position__c eachPosition : positionList){
            if(Trigger.OldMap.get(eachPosition.Id).Number_of_Openings__c != eachPosition.Number_of_Openings__c){
                eachPosition.addError('To change the Number of Openings value, you have to create a new record.');
            }
            if(Trigger.OldMap.get(eachPosition.Id).Close_Date__c  != eachPosition.Close_Date__c ){
                eachPosition.Old_Internal_Closure_Date_Backend__c = Trigger.OldMap.get(eachPosition.Id).Close_Date__c;
            }
            if(eachPosition.Approval_Status__c == 'Approved' && eachPosition.Status_Approved_Date__c == null){
                 eachPosition.Status_Approved_Date__c = Date.today();
            }
            if(eachPosition.Is_Recruiter_Assigned__c==True && Trigger.OldMap.get(eachPosition.Id).Is_Recruiter_Assigned__c==False && eachPosition.Close_Date__c==null){
               
                Datetime tod = Date.today();
                Integer daysToAdd = 0;
                String dayOfWeek = tod.format('E');
                if(dayOfWeek == 'Sun' || dayOfWeek == 'Sat'){
                    daysToAdd =2;
                }
                date openDate = Date.today().addDays(daysToAdd);                
                eachPosition.opened_date__c = Date.today().addDays(daysToAdd);
                eachPosition.Close_Date__c = openDate.addDays(90);
            }
            else if(eachPosition.Approval_Status__c == 'PS - Approval Not Required'){
                date created = eachPosition.CreatedDate.date();
                eachPosition.Close_Date__c = created.addDays(90);
            }
            
            if(eachPosition.Position_Title__c!=null && eachPosition.Position_Title__c != Trigger.OldMap.get(eachPosition.Id).Position_Title__c)
            {
              updateResourceReq.put(eachPosition.Position_Title__c,eachPosition);
            }
                                            
        }
        ResourceRequisitionTriggerHandler.autoPopulateSkills(updateResourceReq);
    }

    if(Trigger.isAfter && Trigger.isInsert)
    {
        Map<Id,Id> recruiterMap = new Map<Id,Id>();
       
         if(!System.isFuture()) {
       List<Position__c> positionList = Trigger.New;
        Map<String,Position__c> updateJdLink = new Map<String,Position__c>();
              
         for(Position__c eachPosition : positionList){
              if(eachPosition.Position_Title__c!=null)
            {
                system.debug('eachPosition.Job_Role__c'+eachPosition.Job_Role__c);
                updateJdLink.put(eachPosition.Position_Title__c,eachPosition);
            }
             
         }
           Integer batchSize = 1;
           String jsonString = json.serialize(updateJdLink);
            //ResourceRequisitionTriggerHandler.populateJdLink(jsonString);
        
              //JdAttachmentsBatch batchClassInstance = new JdAttachmentsBatch(updateJdLink);
            //Database.executeBatch(new JdAttachmentsBatch(updateJdLink),batchSize);
        }
        
         
    }
    if(Trigger.isAfter && Trigger.isUpdate)
    {
                 Datetime tod = Date.today();

         if(!System.isFuture()) {
           
         Map<String,Position__c> updateJdLink = new Map<String,Position__c>();
        List<Position__c> Unlockrecords = new List<Position__c>();

         List<Position__c> positionList = Trigger.New;
         Map<Id,Position__c> positionList1 = Trigger.OldMap;
         set<Id> deleIds= new set<Id>();
             List<Position__c> updateshare = new List<Position__c>();
         system.debug('positionList'+positionList);
         system.debug('positionList1'+positionList1);
        
         for(Position__c eachPosition : positionList){
              system.debug('positionList'+eachPosition.Position_Title__c);
              system.debug('Trigger.OldMap.get(eachPosition.Id).Position_Title__c'+Trigger.OldMap.get(eachPosition.Id).Position_Title__c);
              if(Trigger.OldMap.get(eachPosition.Id).Position_Title__c!=eachPosition.Position_Title__c && eachPosition.Position_Title__c!=null)
              {
                 
                   updateJdLink.put(eachPosition.Position_Title__c,eachPosition);
              }
              if(eachPosition.Close_Date__c< tod)
             {
                 
                updateshare.add(eachPosition);


             }
             
            /* if(Trigger.OldMap.get(eachPosition.Id).Approval_Status__c!=eachPosition.Approval_Status__c && eachPosition.Approval_Status__c == 'Approved' )
             {
                 Unlockrecords.add(eachPosition);
             }
             Approval.UnLockResult[] lrList = Approval.Unlock(Unlockrecords, false);*/

    }
            
           Integer batchSize = 1;
           String jsonString = json.serialize(updateJdLink);
           system.debug('jsonString'+jsonString);
           ResourceRequisitionTriggerHandler.populateJdLink(jsonString);
           //Database.executeBatch(new JdAttachmentsBatch(updateJdLink),batchSize);

        
         List<Position__Share> lstPositionShareRecordsToInsert = new List<Position__Share>();
        for(Position__c p: updateshare)
        {
            if(p.Recruiter__c!=null)
            {
               lstPositionShareRecordsToInsert.add(new Position__Share(AccessLevel='Read',UserOrGroupId=p.Recruiter__c,ParentId=p.Id,RowCause='Manual'));
            }
             if(p.Recruiter_2__c!=null)
            {
               lstPositionShareRecordsToInsert.add(new Position__Share(AccessLevel='Read',UserOrGroupId=p.Recruiter_2__c,ParentId=p.Id,RowCause='Manual'));
            }
          
            
        }
         insert lstPositionShareRecordsToInsert;
         }
    
}
}