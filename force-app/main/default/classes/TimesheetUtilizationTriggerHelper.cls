public class TimesheetUtilizationTriggerHelper extends TriggerHandler{
	/*public override void afterInsert(){
    	List<Team_Timesheet__c> allParent = (List<Team_Timesheet__c>)Trigger.new;
        Set<String> uniqueParentTS = new Set<String>();
        for(Team_Timesheet__c eachTS: allParent){
            if(eachTS.Status__c=='Submitted'){
                uniqueParentTS.add(eachTS.id);
            }
        }
        for(String eachParentTS: uniqueParentTS){
            ProcessTimesheetUtilization.processUtil(eachParentTS);
        }
    }*/
    public override void afterUpdate(){
        List<Team_Timesheet__c> allParent = (List<Team_Timesheet__c>)Trigger.new;
        List<Team_Timesheet__c> oldParents = (List<Team_Timesheet__c>)Trigger.old;
        Set<String> uniqueParentTS = new Set<String>();
        Set<String> uniqueParentTS_forDeletion = new Set<String>();
        for(Team_Timesheet__c eachTS: allParent){
            for(Team_Timesheet__c oldTS : oldParents){
                //System.debug('New '+eachTS.Status__c);
                //System.debug('Old '+oldTS.Status__c);
                if(eachTS.Status__c=='Submitted' && (oldTS.Status__c != eachTS.Status__c)){
                	uniqueParentTS.add(eachTS.id);
                }else if(eachTS.Status__c=='Rejected' || eachTS.Status__c=='Partially Rejected'/*&& oldTS.Status__c != eachTS.Status__c*/){
                    uniqueParentTS_forDeletion.add(eachTS.id);
                }
            }
        }
        for(String eachParentTS: uniqueParentTS){
            ProcessTimesheetUtilization.processUtil(eachParentTS);
        }
        for(String eachParentTS: uniqueParentTS_forDeletion){
            ProcessTimesheetUtilization.deleteUtils(eachParentTS);
        }
    }
}