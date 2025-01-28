public class PerformanceRatingItemController {
    public static List<Performance_Rating_Item__c> loadData(Goal_Setting__c goal,String PerformanceRatingId,String currentQuarter){
        List<Performance_Rating_Item__c> allPerformanceRatingItem = new List<Performance_Rating_Item__c>();
        
        if(goal.KPI_1__c != null){
            Performance_Rating_Item__c perRatingItem1 = new Performance_Rating_Item__c();
            perRatingItem1.Performance_Rating__c = PerformanceRatingId;
            perRatingItem1.Goal_Setting__c = goal.Id;
            perRatingItem1.KPI__c = goal.KPI_1__c;
            perRatingItem1.Weightage__c = goal.KPI_1_Weightage__c;
            perRatingItem1.Status__c = 'Open';
            perRatingItem1.Appraisal__c = 'Quater';
            perRatingItem1.Quater__c = currentQuarter;
            allPerformanceRatingItem.add(perRatingItem1);
        }if(goal.KPI_2__c != null){
            Performance_Rating_Item__c perRatingItem2 = new Performance_Rating_Item__c();
            perRatingItem2.Performance_Rating__c = PerformanceRatingId;
            perRatingItem2.Goal_Setting__c = goal.Id;
            perRatingItem2.KPI__c = goal.KPI_2__c;
            perRatingItem2.Weightage__c = goal.KPI_2_Weightage__c;
            perRatingItem2.Status__c = 'Open';
            perRatingItem2.Appraisal__c = 'Quater';
            perRatingItem2.Quater__c = currentQuarter;
            allPerformanceRatingItem.add(perRatingItem2);
        }if(goal.KPI_3__c != null){
            Performance_Rating_Item__c perRatingItem3 = new Performance_Rating_Item__c();
            perRatingItem3.Performance_Rating__c = PerformanceRatingId;
            perRatingItem3.Goal_Setting__c = goal.Id;
            perRatingItem3.KPI__c = goal.KPI_3__c;
            perRatingItem3.Weightage__c = goal.KPI_3_Weightage__c;
            perRatingItem3.Status__c = 'Open';
            perRatingItem3.Appraisal__c = 'Quater';
            perRatingItem3.Quater__c = currentQuarter;
            allPerformanceRatingItem.add(perRatingItem3);
        }if(goal.KPI_4__c != null){
            Performance_Rating_Item__c perRatingItem4 = new Performance_Rating_Item__c();
            perRatingItem4.Performance_Rating__c = PerformanceRatingId;
            perRatingItem4.Goal_Setting__c = goal.Id;
            perRatingItem4.KPI__c = goal.KPI_4__c;
            perRatingItem4.Weightage__c = goal.KPI_4_Weightage__c;
            perRatingItem4.Status__c = 'Open';
            perRatingItem4.Appraisal__c = 'Quater';
            perRatingItem4.Quater__c = currentQuarter;
            allPerformanceRatingItem.add(perRatingItem4);
        }if(goal.KPI_5__c != null){
            Performance_Rating_Item__c perRatingItem5 = new Performance_Rating_Item__c();
            perRatingItem5.Performance_Rating__c = PerformanceRatingId;
            perRatingItem5.Goal_Setting__c = goal.Id;
            perRatingItem5.KPI__c = goal.KPI_5__c;
            perRatingItem5.Weightage__c = goal.KPI_5_Weightage__c;
            perRatingItem5.Status__c = 'Open';
            perRatingItem5.Appraisal__c = 'Quater';
            perRatingItem5.Quater__c = currentQuarter;
            allPerformanceRatingItem.add(perRatingItem5);
        }
        return allPerformanceRatingItem;
    }
}