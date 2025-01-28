/*------------------------------------------------------------------------------------
Author:        Paras Prajapati
Description:   Service Class for ProjectTrigger

History
Date            Author             Comments
--------------------------------------------------------------------------------------
16-03-2020      Paras Prajapati        Initial Release
------------------------------------------------------------------------------------*/
public inherited sharing  class ProjectTriggerService {
    /**
* @author       Paras Prajapat
* @date         16-03-2020
* @description  Set Email field for Functional and Technical User, so that mail can be sent those users.
* @param  		 Map<Id, Project__c> newProjectMap,Map<Id, Project__c> oldProjectMap
* @return       void
*/
    public static void setFunctionalAndTechnicalUserEmails(Map<Id,Project__c> newProjectMap,Map<Id,Project__c> oldProjectMap){
        Set<String> userRecordIds = new Set<String>();
        Map<Id,Project__c> mapOfFunctionalUserIdAndProject = new Map<Id,Project__c>();
        Map<Id,Project__c> mapOfTechnicalUserIdAndProject = new Map<Id,Project__c>();
        for(String projectRecordId : newProjectMap.KeySet()){
            Project__c newProject = newProjectMap.get(projectRecordId);
            Project__c oldProject = oldProjectMap.get(projectRecordId);
            if(newProject.FuturePointOfContactFunctional__c!=null && 
               ( oldProject.FuturePointOfContactFunctional__c==null || newProject.FuturePointOfContactFunctional__c!=oldProject.FuturePointOfContactFunctional__c)){
                   userRecordIds.add(newProject.FuturePointOfContactFunctional__c);
                   mapOfFunctionalUserIdAndProject.put(newProject.FuturePointOfContactFunctional__c,newProject);
               }
            if(newProject.FuturePointOfContactFunctional__c==null){
                newProject.Functional_Contact_Email__c=null;
            }
            if(newProject.FuturePointOfContactTechnical__c!=null && 
               ( oldProject.FuturePointOfContactTechnical__c==null || newProject.FuturePointOfContactTechnical__c!=oldProject.FuturePointOfContactTechnical__c)){
                   userRecordIds.add(newProject.FuturePointOfContactTechnical__c);
                   mapOfTechnicalUserIdAndProject.put(newProject.FuturePointOfContactTechnical__c,newProject);
               }
            if(newProject.FuturePointOfContactTechnical__c==null){
                newProject.Technical_Contact_Email__c=null;
            }
        }
        if(!userRecordIds.isEmpty()){
            List<User> listOfUserRecords = [Select Id,Email from User where Id IN:userRecordIds];
            if(listOfUserRecords!=null && !listOfUserRecords.isEmpty()){
                for(User userRecord : listOfUserRecords){
                    if(mapOfFunctionalUserIdAndProject.containsKey(userRecord.Id)){
                        Project__c projectRecord = mapOfFunctionalUserIdAndProject.get(userRecord.Id); 
                        projectRecord.Functional_Contact_Email__c = userRecord.Email;
                    }
                    if(mapOfTechnicalUserIdAndProject.containsKey(userRecord.Id)){
                        Project__c projectRecord = mapOfTechnicalUserIdAndProject.get(userRecord.Id); 
                        projectRecord.Technical_Contact_Email__c = userRecord.Email;
                    }
                }
            }
        }
    }
    /**
* @author       Paras Prajapat
* @date         16-03-2020
* @description  Set Project Manager Email, so that mail can be sent to Project Manager.
* @param  		 Map<Id, Project__c> newProjectMap,Map<Id, Project__c> oldProjectMap
* @return       void
*/
    public static void setProjectManagerEmail(Map<Id,Project__c> newProjectMap,Map<Id,Project__c> oldProjectMap){
        Set<String> userRecordIds = new Set<String>();
        Map<Id,List<Project__c>> mapOfProjectManagerAndProjectIDs = new Map<Id,List<Project__c>>();
        for(String projectRecordId : newProjectMap.KeySet()){
            Project__c newProject = newProjectMap.get(projectRecordId);
            Project__c oldProject = null;
            Boolean isProjectManagerChanged = true;
            if(oldProjectMap!=null){
               oldProject = oldProjectMap.get(projectRecordId);
                if(newProject.ProjectManager__c==oldProject.ProjectManager__c){
                    isProjectManagerChanged = false;
                }
            }
            if(newProject.ProjectManager__c!=null && isProjectManagerChanged){
                   userRecordIds.add(newProject.ProjectManager__c);
                if(!mapOfProjectManagerAndProjectIDs.containsKey(newProject.ProjectManager__c)){
                    mapOfProjectManagerAndProjectIDs.put(newProject.ProjectManager__c,new List<Project__c>());
                }
                mapOfProjectManagerAndProjectIDs.get(newProject.ProjectManager__c).add(newProject);
            }
        }
        if(!userRecordIds.isEmpty()){
            List<User> listOfUserRecords = [Select Id,Email from User where Id IN:userRecordIds];
            if(listOfUserRecords!=null && !listOfUserRecords.isEmpty()){
                for(User userRecord : listOfUserRecords){
                    if(mapOfProjectManagerAndProjectIDs.containsKey(userRecord.Id)){
                        List<Project__c> projectRecords = mapOfProjectManagerAndProjectIDs.get(userRecord.Id); 
                        for(Project__c projectRecord : projectRecords){
                            projectRecord.Project_Manager_Email__c = userRecord.Email;
                        }
                    }
                }
            }
        }
    }
    /**
* @author       Paras Prajapat
* @date         16-03-2020
* @description  Count Escalation Email Counts based on End Date Modification
* @param  		 Map<Id, Project__c> newProjectMap,Map<Id, Project__c> oldProjectMap
* @return       void
*/
    public static void handleProjectEndDateChange(Map<Id,Project__c> newProjectMap,Map<Id,Project__c> oldProjectMap){
        for(String projectRecordId : newProjectMap.KeySet()){
            Project__c newProject = newProjectMap.get(projectRecordId);
            Project__c oldProject = oldProjectMap.get(projectRecordId);
            if(oldProject.EndDate__c!=null){
                if(newProject.EndDate__c!=null && newProject.EndDate__c!=oldProject.EndDate__c && newProject.EndDate__c > oldProject.EndDate__c){
                    Integer numberDays = oldProject.EndDate__c.daysBetween(newProject.EndDate__c);
                    if(newProject.EndDate__c>=Date.today()){
                        newProject.Escalation_Email_Counts__c = 0;  
                    }else{
                        numberDays = newProject.EndDate__c.daysBetween(Date.today());
                        if(numberDays>4){
                            newProject.Escalation_Email_Counts__c = 0;
                        }else{
                            newProject.Escalation_Email_Counts__c = numberDays-1;
                        }
                    }
                }
            }
        }
    }
    /**
    * @author       Sayath
    * @date         2021-05-12
    * @description  Update End Date on Customer Engagement based on Client on Hold field
    * @param  		 Map<Id, Project__c> newProjectMap,Map<Id, Project__c> oldProjectMap
    * @return       void
    */
    public static void updateProjectEndDate(Map<Id, Project__c> newProjectMap,Map<Id, Project__c> oldProjectMap){
        List<Id> projectsEndingToday = new List<Id>();
        for(String projectRecordId : newProjectMap.KeySet()){
            Project__c newProject = newProjectMap.get(projectRecordId);
            Project__c oldProject = oldProjectMap.get(projectRecordId);
            if(oldProject.EndDate__c!=null){
                if(newProject.EndDate__c!=null && newProject.EndDate__c!=oldProject.EndDate__c && newProject.EndDate__c == System.today()){
                    //get all Team Allocations to this project and update their end date
                    projectsEndingToday.add(newProject.Id);
                }
            }
        }
        List<TeamAllocation__c> updateTeamAlloctionList = new List<TeamAllocation__c>();
        for(TeamAllocation__c team : [SELECT Id, Name,Active__c, EndDate__c,Project__c 
                                      FROM TeamAllocation__c WHERE Project__c IN :projectsEndingToday])
        {
            team.EndDate__c = System.today();
            updateTeamAlloctionList.add(team);
        }
        if(!updateTeamAlloctionList.isEmpty()){
            Database.update(updateTeamAlloctionList);
        }
    }
}