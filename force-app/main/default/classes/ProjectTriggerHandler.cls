/*------------------------------------------------------------------------------------
Author:        Paras Prajapati
Description:   Handler Class for ProjectTrigger

History
Date            Author             Comments
--------------------------------------------------------------------------------------
16-03-2020      Paras Prajapati        Initial Release
------------------------------------------------------------------------------------*/
public inherited sharing  class ProjectTriggerHandler {
    public static void handleBeforInsert(List<Project__c> listOfProject){
        Map<Id,Project__c> newProjectMap = new Map<Id,Project__c>();
        for(Project__c projectRecord : listOfProject){
            newProjectMap.put(projectRecord.Id,projectRecord);
        }
        ProjectTriggerService.setProjectManagerEmail(newProjectMap,null);
    }
    
    public static void handleBeforeUpdate(Map<Id,Project__c> newProjectMap,Map<Id,Project__c> oldProjectMap){
        ProjectTriggerService.setFunctionalAndTechnicalUserEmails(newProjectMap, oldProjectMap);
        ProjectTriggerService.handleProjectEndDateChange(newProjectMap,oldProjectMap);
        ProjectTriggerService.setProjectManagerEmail(newProjectMap,oldProjectMap);
        ProjectTriggerService.updateProjectEndDate(newProjectMap,oldProjectMap);
    }
}