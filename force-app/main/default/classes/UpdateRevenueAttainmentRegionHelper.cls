public class UpdateRevenueAttainmentRegionHelper {
    // Helper function to get the quarter based on the month of the date
    public static Integer getQuarter(Date milestone) {
        if (milestone != null) {
            Integer month = milestone.month();
            
            if (month >= 1 && month <= 3) {
                return 1;
            } else if (month >= 4 && month <= 6) {
                return 2;
            } else if (month >= 7 && month <= 9) {
                return 3;
            } else if (month >= 10 && month <= 12) {
                return 4;
            }
        }
        
        return null;
    }
    
    public static void updateRevenueAttainment(List<Billing__c> newBillings) {
        // Collect the unique Opportunity Region values from the billing records
        Set<String> oppRegions = new Set<String>();
        for (Billing__c billing : newBillings) {
            oppRegions.add(billing.Opp_Region__c);
        }
        
        // Retrieve the relevant Revenue_Stream_Region__c records based on matching Opportunity Regions
        List<Revenue_Stream_Region__c> relevantRevenueStreams = [
            SELECT Id, Opportunity_Region__c, Q1_Revenue_Attainment__c, Q2_Revenue_Attainment__c,
                   Q3_Revenue_Attainment__c, Q4_Revenue_Attainment__c
            FROM Revenue_Stream_Region__c
            WHERE Opportunity_Region__c IN :oppRegions
        ];
        
        // Create a map to store the quarterly revenue attainment
        Map<String, List<Decimal>> quarterlyAttainmentMap = new Map<String, List<Decimal>>();
        
        // Initialize the quarterly attainment for each Opportunity Region
        for (String oppRegion : oppRegions) {
            quarterlyAttainmentMap.put(oppRegion, new List<Decimal>{0, 0, 0, 0});
        }
        
        // Calculate the quarterly revenue attainment for each billing record
        for (Billing__c billing : newBillings) {
            String oppRegion = billing.Opp_Region__c;
            Date milestoneDate = billing.Milestone_Date__c;
            Decimal milestoneAmount = billing.Milestone_Amount__c;
            Integer quarter = getQuarter(milestoneDate);
            
            if (quarter != null && quarterlyAttainmentMap.containsKey(oppRegion)) {
                List<Decimal> quarterlyAttainment = quarterlyAttainmentMap.get(oppRegion);
                quarterlyAttainment[quarter - 1] += milestoneAmount;
                quarterlyAttainmentMap.put(oppRegion, quarterlyAttainment);
            }
        }
        
        // Update the revenue attainment fields on the relevant Revenue_Stream_Region__c records
        List<Revenue_Stream_Region__c> revenueStreamRegionsToUpdate = new List<Revenue_Stream_Region__c>();
        
        for (Revenue_Stream_Region__c revenueStream : relevantRevenueStreams) {
            String oppRegion = revenueStream.Opportunity_Region__c;
            
            if (quarterlyAttainmentMap.containsKey(oppRegion)) {
                List<Decimal> quarterlyAttainment = quarterlyAttainmentMap.get(oppRegion);
                
                revenueStream.Q1_Revenue_Attainment__c = (revenueStream.Q1_Revenue_Attainment__c != null)
                    ? revenueStream.Q1_Revenue_Attainment__c + quarterlyAttainment[0]
                    : quarterlyAttainment[0];
                
                revenueStream.Q2_Revenue_Attainment__c = (revenueStream.Q2_Revenue_Attainment__c != null)
                    ? revenueStream.Q2_Revenue_Attainment__c + quarterlyAttainment[1]
                    : quarterlyAttainment[1];
                
                revenueStream.Q3_Revenue_Attainment__c = (revenueStream.Q3_Revenue_Attainment__c != null)
                    ? revenueStream.Q3_Revenue_Attainment__c + quarterlyAttainment[2]
                    : quarterlyAttainment[2];
                
                revenueStream.Q4_Revenue_Attainment__c = (revenueStream.Q4_Revenue_Attainment__c != null)
                    ? revenueStream.Q4_Revenue_Attainment__c + quarterlyAttainment[3]
                    : quarterlyAttainment[3];
                
                revenueStreamRegionsToUpdate.add(revenueStream);
            }
        }
        
        // Perform the bulk update of Revenue_Stream_Region__c records
        if (!revenueStreamRegionsToUpdate.isEmpty()) {
            update revenueStreamRegionsToUpdate;
        }
    }
}