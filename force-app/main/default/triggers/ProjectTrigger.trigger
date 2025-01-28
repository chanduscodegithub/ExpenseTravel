/*------------------------------------------------------------------------------------
Author:        Paras Prajapati
Description:   Trigger for Project Records

History
Date            Author             Comments
--------------------------------------------------------------------------------------
16-03-2020      Paras Prajapati        Initial Release
------------------------------------------------------------------------------------*/
trigger ProjectTrigger on Project__c (before insert, after insert, before update,after update, before delete) {
    switch on Trigger.operationType {
        when BEFORE_INSERT {
            ProjectTriggerHandler.handleBeforInsert(Trigger.new);
        }
        when BEFORE_UPDATE {
            ProjectTriggerHandler.handleBeforeUpdate(Trigger.newMap,Trigger.oldmap); 
        }
        WHEN AFTER_INSERT{
            ManualSharingHandler.shareProjectAccountWithManager(Trigger.newMap,null);
        }
        WHEN AFTER_UPDATE{
            ManualSharingHandler.shareProjectAccountWithManager(Trigger.newMap,Trigger.oldMap);
        }
    }

}