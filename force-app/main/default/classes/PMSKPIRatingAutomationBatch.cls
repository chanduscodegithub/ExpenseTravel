public class PMSKPIRatingAutomationBatch implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([Select Id,Status__c,Employee__c, Employee__r.Name from Performance_Rating__c where Status__c IN ('Open','In Progress','Draft')]);
    }
    public void execute(Database.BatchableContext BC, list<Performance_Rating__c> performanceRating) {
        try{
            List<Performance_Rating__c>perFormanceRatingToUpdate = new List<Performance_Rating__c>();
            Map<Id,Performance_Rating__c>performanceRatingMap = new Map<Id,Performance_Rating__c>();
            for(Performance_Rating__c performance : performanceRating){
                performanceRatingMap.put(performance.Id,performance);
            }
            List<Performance_Rating_Item__c>performanceRatingItems = [Select Id,Employee_Rating__c,Quater__c,Status__c,Completed__c,compleed__c,Performance_Rating__c,Employee_Comments__c from Performance_Rating_Item__c where Performance_Rating__c =: performanceRatingMap.keySet() and Status__c IN ('Open','In progress')];
            Map<Id,List<Performance_Rating_Item__c>>performanceRatingsWithPR = new Map<Id,List<Performance_Rating_Item__c>>();
            for(Performance_Rating_Item__c performanceItem : performanceRatingItems){
                if(!performanceRatingsWithPR.containsKey(performanceItem.Performance_Rating__c)){
                    performanceRatingsWithPR.put(performanceItem.Performance_Rating__c,new List<Performance_Rating_Item__c>());
                }
                performanceRatingsWithPR.get(performanceItem.Performance_Rating__c).add(performanceItem);
            }
            List<Performance_Rating_Item__c>performanceItemsToUpdate = new List<Performance_Rating_Item__c>();
            for(Id performanceId : performanceRatingsWithPR.keySet()){
                Performance_Rating__c performance = performanceRatingMap.get(performanceId);
                List<Performance_Rating_Item__c>performanceItems = performanceRatingsWithPR.get(performanceId);
                String quaterStatus ;
                for(Performance_Rating_Item__c performanceItem : performanceItems){
                    quaterStatus = performanceItem.Quater__c;
                    performanceItem.Status__c = 'Employee Submitted';
                    performanceItem.Employee_Rating__c = 2.5;
                    performanceItem.Employee_Comments__c = 'Defaulted';
                    performanceItemsToUpdate.add(performanceItem);
                }
                if(quaterStatus == 'QPR-I'){
                    performance.Status__c = 'QPR-I Emp Submitted';
                }else if(quaterStatus == 'QPR-II'){
                    performance.Status__c = 'QPR-II Emp Submitted';
                }else if(quaterStatus == 'QPR-III'){
                    performance.Status__c = 'QPR-III Emp Submitted';
                }else if(quaterStatus == 'Annual Cycle'){
                    performance.Status__c = 'QPR-IV/Annual Review Emp Submitted';
                }
                perFormanceRatingToUpdate.add(performance);
            }
            if(perFormanceRatingToUpdate.size() > 0){update perFormanceRatingToUpdate;}
            if(performanceItemsToUpdate.size() > 0){update performanceItemsToUpdate;}
        }catch(Exception ex){
            
        }
    }
    public void finish(Database.BatchableContext BC) {}   
}