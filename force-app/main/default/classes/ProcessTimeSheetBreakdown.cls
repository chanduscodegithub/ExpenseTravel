public class ProcessTimeSheetBreakdown{
    public static void processTS(String parentTSId){
        Team_Timesheet__c parentTS = [SELECT Id, Billable_hours__c, Non_Billable_hours__c, Leave_Hours__c FROM Team_Timesheet__c WHERE Id=:parentTSId];
        List<Delivery__c> allChildTS = [SELECT Billing_Status__c, Category__c, Time_in_Hours__c FROM Delivery__c WHERE Team_Timesheet__c=:parentTSId];
        Decimal billableHrs = 0.00;
        Decimal nonBillableHrs = 0.00;
        Decimal leaveHrs = 0.00;
        
        for(Delivery__c eachChildTS: allChildTS){
            if(eachChildTS.Category__c=='Leave' || eachChildTS.Billing_Status__c=='Long Leave'){
                leaveHrs += eachChildTS.Time_in_Hours__c; 
            }else if(eachChildTS.Billing_Status__c == 'Billable'){
                billableHrs += eachChildTS.Time_in_Hours__c;
            }else{
                nonBillableHrs += eachChildTS.Time_in_Hours__c;
            }
        }
        
        parentTS.Billable_hours__c = billableHrs;
        parentTS.Non_Billable_hours__c = nonBillableHrs;
        parentTS.Leave_Hours__c = leaveHrs;
        
        update parentTS;
    }
}