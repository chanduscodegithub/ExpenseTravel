/*------------------------------------------------------------------------------------
Author:        Paras Prajapati
Description:   TeamAllocation__c Handler Trigger to manage custom operation

History
Date            Author             Comments
--------------------------------------------------------------------------------------

------------------------------------------------------------------------------------*/
    trigger TeamAllocationTrigger on TeamAllocation__c (before insert, after insert, before update, after update) {
    switch on Trigger.operationType {
        when BEFORE_INSERT {
         /* List<Talent_Loading__c> talentList = new List<Talent_Loading__c>();
         for (TeamAllocation__c teamAlloc: Trigger.New) {
        Date startDate = teamAlloc.StartDate__c;
         Date  endDate = teamAlloc.EndDate__c;
        Decimal days = 0;  
         
        for(integer i=0; i <= startDate.daysBetween(endDate); i++)  
        {  
            Date dt = startDate + i;  
            DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());  
            String todayDay = currDate.format('EEEE');  
            if(todayDay != 'Saturday' && todayDay !='Sunday')  
                {  
                    days = days + 1;  
                }     
               
        } 
                 system.debug('days1>>'+days);
             if(teamAlloc.AllocationHours__c == null){
                 teamAlloc.AllocationHours__c = 0;
             }
            Decimal d=(teamAlloc.AllocationHours__c/(days*8))*100;
            system.debug('d>>'+d);
                teamAlloc.AllocationPercentage__c = d;*/

            TeamAllocationTriggerHandler.BeforeTeamAllocationInsert(Trigger.new);
       // }
        }
        when BEFORE_UPDATE {
/*List<Talent_Loading__c> talentList = new List<Talent_Loading__c>();
         for (TeamAllocation__c teamAlloc: Trigger.New) {
        Date startDate = teamAlloc.StartDate__c;
         Date  endDate = teamAlloc.EndDate__c;
        Decimal days = 0;  
         
        for(integer i=0; i <= startDate.daysBetween(endDate); i++)  
        {  
            Date dt = startDate + i;  
            DateTime currDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());  
            String todayDay = currDate.format('EEEE');  
            if(todayDay != 'Saturday' && todayDay !='Sunday')  
                {  
                    days = days + 1;  
                }     
               
        } 
                 system.debug('days1>>'+days);
             if(teamAlloc.AllocationHours__c == null){
                 teamAlloc.AllocationHours__c = 0;
             }
            Decimal d=(teamAlloc.AllocationHours__c/(days*8))*100;
            system.debug('d>>'+d);
                teamAlloc.AllocationPercentage__c = d;*/
            
   
 //   TeamAllocationTriggerHandler.preventUpdateifTSAttached(Trigger.newMap, Trigger.oldMap);
    TeamAllocationTriggerHandler.BeforeTeamAllocationUpdate(Trigger.newMap, Trigger.oldMap);
         //}
}
        when AFTER_INSERT {
         List<Talent_Loading__c> talentList = new List<Talent_Loading__c>();
        
            // Retrieve all TalentLoading records associated with the Project
            List<Talent_Loading__c> talentRecords = [
                SELECT Id, Role__c, RoleForm__c,MappedHours__c,Talent_Hours__c, Engagement__c, (SELECT AllocationHours__c FROM Team_Allocations__r),
                    (SELECT Hour__c FROM Talent_Loading_Lines__r)
                FROM Talent_Loading__c
                WHERE Engagement__c = :Trigger.new[0].Project__c // Assuming all TeamAllocation records belong to the same Project
            ];

        for (Talent_Loading__c ta : talentRecords) {
            Decimal totalHours = 0;
             Decimal totalAllocatedHours = 0;
            for (Talent_Loading_Line__c childRecord : ta.Talent_Loading_Lines__r) {
                if (childRecord.Hour__c == null) {
                    childRecord.Hour__c = 0;
                }
                totalHours += childRecord.Hour__c;
            }
     for (TeamAllocation__c teamAllocation : ta.Team_Allocations__r) {
                        if (teamAllocation.AllocationHours__c != null) {
                            totalAllocatedHours += teamAllocation.AllocationHours__c;
                        }
                    }
    
    if (totalAllocatedHours > ta.Talent_Hours__c) {
                for (TeamAllocation__c teamAllocation : Trigger.new) {
                    if (teamAllocation.Talent_Loading__c == ta.Id) {
                        teamAllocation.addError('Mapped hours cannot exceed Talent Hours for the associated Talent Loading record.');
                    }
                }
            }
            ta.MappedHours__c = totalAllocatedHours;
    
            // Check if the Talent Loading record is used in Team Allocation
            Boolean isMapped = [SELECT COUNT() FROM TeamAllocation__c WHERE Talent_Loading__c = :ta.Id AND Project__c = :ta.Engagement__c] > 0;
    
            // Update the RoleForm__c field with the mapped/unmapped label
             ta.RoleForm__c = ta.Role__c + ' | ' + totalHours + ' hrs | ' + (isMapped ? 'Mapped | '+ta.MappedHours__c+' hrs' : 'Unmapped');
            talentList.add(ta);

        
    }

    update talentList;
            // Call the handler to update Billable and Shadow counts
            TeamAllocationTriggerHandler.updateProjectCounts(Trigger.new);
            
            TeamAllocationTriggerHandler.afterTeamAllocationInsert(Trigger.newMap);
            ManualSharingHandler.calculateSharingRules(trigger.newMap);
        }
        when AFTER_UPDATE {
 List<Talent_Loading__c> talentList = new List<Talent_Loading__c>();

    // Retrieve all TalentLoading records associated with the Project
    List<Talent_Loading__c> talentRecords = [
        SELECT Id, Role__c, RoleForm__c,MappedHours__c, Engagement__c,Talent_Hours__c, (SELECT AllocationHours__c FROM Team_Allocations__r),
            (SELECT Hour__c FROM Talent_Loading_Lines__r)
        FROM Talent_Loading__c
        WHERE Engagement__c = :Trigger.new[0].Project__c // Assuming all TeamAllocation records belong to the same Project
    ];

    for (Talent_Loading__c ta : talentRecords) {
        Decimal totalHours = 0;
         Decimal totalAllocatedHours = 0;
        for (Talent_Loading_Line__c childRecord : ta.Talent_Loading_Lines__r) {
            if (childRecord.Hour__c == null) {
                childRecord.Hour__c = 0;
            }
            totalHours += childRecord.Hour__c;
        }
 for (TeamAllocation__c teamAllocation : ta.Team_Allocations__r) {
                    if (teamAllocation.AllocationHours__c != null) {
                        totalAllocatedHours += teamAllocation.AllocationHours__c;
                    }
                }
if (totalAllocatedHours > ta.Talent_Hours__c) {
            for (TeamAllocation__c teamAllocation : Trigger.new) {
                if (teamAllocation.Talent_Loading__c == ta.Id) {
                    teamAllocation.addError('Mapped hours cannot exceed Talent Hours for the associated Talent Loading record.');
                }
            }
        }
    

        ta.MappedHours__c = totalAllocatedHours;

        // Check if the Talent Loading record is used in Team Allocation
        Boolean isMapped = [SELECT COUNT() FROM TeamAllocation__c WHERE Talent_Loading__c = :ta.Id AND Project__c = :ta.Engagement__c] > 0;
        
        // Update the RoleForm__c field with the mapped/unmapped label
        ta.RoleForm__c = ta.Role__c + ' | ' + totalHours + ' hrs | ' + (isMapped ? 'Mapped | '+ta.MappedHours__c+' hrs' : 'Unmapped');

        talentList.add(ta);

        
    }

    update talentList;
            
            // Call the handler to update Billable and Shadow counts
            TeamAllocationTriggerHandler.updateProjectCounts(Trigger.new);
            
            TeamAllocationTriggerHandler.afterTeamAllocationUpdate(Trigger.newMap, Trigger.oldMap);
            ManualSharingHandler.calculateSharingRules(trigger.newMap);
        }

    }
}