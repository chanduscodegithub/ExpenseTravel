/*------------------------------------------------------------------------------------
Author:        Sayath
Description:   Trigger to share records with Community users

Date            Author             Comments
--------------------------------------------------------------------------------------

------------------------------------------------------------------------------------*/
trigger SupportSLASharingTrigger on Support_SLA__c (after insert,after update) {
    switch on Trigger.operationType {
        when AFTER_INSERT {
            ManualSharingHandler.sharingSupportSLA(trigger.newMap);
        }
        when AFTER_UPDATE {
            ManualSharingHandler.sharingSupportSLA(trigger.newMap);
        }
    }
}