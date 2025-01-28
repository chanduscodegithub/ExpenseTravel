public class TimeSheetActivityTriggerHelper extends TriggerHandler {
    public override void afterInsert(){
        List<Delivery__c> allInsertedDTSA = (List<Delivery__c>)Trigger.new;
        Set<String> uniqueParentTS = new Set<String>();
        for(Delivery__c eachDTS: allInsertedDTSA){
            uniqueParentTS.add(eachDTS.Team_Timesheet__c);
        }
        for(String eachParentTS: uniqueParentTS){
            ProcessTimeSheetBreakdown.processTS(eachParentTS);
        }
    }
    public override void afterUpdate(){
        List<Delivery__c> allInsertedDTSA = (List<Delivery__c>)Trigger.new;
        Set<String> uniqueParentTS = new Set<String>();
        for(Delivery__c eachDTS: allInsertedDTSA){
            uniqueParentTS.add(eachDTS.Team_Timesheet__c);
        }
        for(String eachParentTS: uniqueParentTS){
            ProcessTimeSheetBreakdown.processTS(eachParentTS);
        }
    }
}