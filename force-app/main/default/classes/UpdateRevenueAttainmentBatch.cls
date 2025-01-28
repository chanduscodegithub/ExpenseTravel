global class UpdateRevenueAttainmentBatch implements Database.Batchable<SObject>, Schedulable {
    
    private Set<Id> recordIds;
    
    public UpdateRevenueAttainmentBatch(Set<Id> recordIds) {
        this.recordIds = recordIds;
    }
    
    public void execute(SchedulableContext sc) {
        Set<Id> recordIds = new Set<Id>();
        UpdateRevenueAttainmentBatch obj = new UpdateRevenueAttainmentBatch(recordIds);
        Database.executeBatch(obj, 1);
    }
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, Name, Opp_Region__c, Milestone_Year__c, Milestone_Date__c, Milestone_Amount__c, Invoice_Amount__c,Invoice_Date__c,Billing_Currency_Code__c,CurrencyIsoCode,Account__c,OpportunityName__c FROM Billing__c WHERE Milestone_Date__c != null AND (Invoice_Amount__c != NULL OR Milestone_Amount__c != NULL)';
        // Reset the quarterly attainment fields to zero before starting the batch
        List<Revenue_Stream_Region__c> resetRevenueStreams = [
            SELECT Id, Q1_Revenue_Attainment__c, Q2_Revenue_Attainment__c,
            Q3_Revenue_Attainment__c, Q4_Revenue_Attainment__c
            FROM Revenue_Stream_Region__c
        ];
        
        for (Revenue_Stream_Region__c resetRevenueStream : resetRevenueStreams) {
            resetRevenueStream.Q1_Revenue_Attainment__c = 0;
            resetRevenueStream.Q2_Revenue_Attainment__c = 0;
            resetRevenueStream.Q3_Revenue_Attainment__c = 0;
            resetRevenueStream.Q4_Revenue_Attainment__c = 0;
        }
        
        update resetRevenueStreams; // Update the reset records
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext context, List<Billing__c> scope) {
        
        Set<String> oppRegions = new Set<String>();
        for (Billing__c billing : scope) {
            oppRegions.add(billing.Opp_Region__c);
        }
        
        List<Revenue_Stream_Region__c> relevantRevenueStreams = [
            SELECT Id, Opportunity_Region__c, Q1_Revenue_Attainment__c, Q2_Revenue_Attainment__c,
            Q3_Revenue_Attainment__c, Q4_Revenue_Attainment__c, Finance_Year__c
            FROM Revenue_Stream_Region__c
            WHERE Opportunity_Region__c IN :oppRegions
        ];
        
        Map<String, List<Decimal>> quarterlyAttainmentMap = new Map<String, List<Decimal>>();
        for (Billing__c billing : scope) {
            String oppRegion = billing.Opp_Region__c;
            Decimal milestoneAmount = billing.Invoice_Amount__c != null ? billing.Invoice_Amount__c : billing.Milestone_Amount__c;
            Integer quarter = getQuarter(billing.Milestone_Date__c);
            String milestoneYear = billing.Milestone_Year__c;
            
            if (quarter != null && milestoneYear != null) {
                String key = oppRegion + '_' + quarter + '_' + milestoneYear;
                if (quarterlyAttainmentMap.containsKey(key)) {
                    quarterlyAttainmentMap.get(key).add(milestoneAmount);
                } else {
                    quarterlyAttainmentMap.put(key, new List<Decimal>{milestoneAmount});
                }
            }
        }
        
        List<Revenue_Stream_Region__c> revenueStreamRegionsToUpdate = new List<Revenue_Stream_Region__c>();
        for (Revenue_Stream_Region__c revenueStream : relevantRevenueStreams) {
            String oppRegion = revenueStream.Opportunity_Region__c;
            String financeYear = revenueStream.Finance_Year__c;
            
            Map<Integer, Decimal> quarterlyAttainmentMapByQuarter = new Map<Integer, Decimal>();
            
            for (Integer quarter = 1; quarter <= 4; quarter++) {
                quarterlyAttainmentMapByQuarter.put(quarter, 0);
            }
            
            for (Integer quarter = 1; quarter <= 4; quarter++) {
                String key = oppRegion + '_' + quarter + '_' + financeYear;
                
                if (quarterlyAttainmentMap.containsKey(key)) {
                    List<Decimal> quarterlyAttainment = quarterlyAttainmentMap.get(key);
                    
                    Decimal totalAttainment = 0;
                    for (Decimal amount : quarterlyAttainment) {
                        totalAttainment += amount;
                    }
                    
                    quarterlyAttainmentMapByQuarter.put(quarter, totalAttainment);
                }
            }
            
            revenueStream.Q1_Revenue_Attainment__c += quarterlyAttainmentMapByQuarter.get(1);
            revenueStream.Q2_Revenue_Attainment__c += quarterlyAttainmentMapByQuarter.get(2);
            revenueStream.Q3_Revenue_Attainment__c += quarterlyAttainmentMapByQuarter.get(3);
            revenueStream.Q4_Revenue_Attainment__c += quarterlyAttainmentMapByQuarter.get(4);
            
            revenueStreamRegionsToUpdate.add(revenueStream);
        }
        
        if (!revenueStreamRegionsToUpdate.isEmpty()) {
            update revenueStreamRegionsToUpdate;
        }
        
        List<Revenue_Forecasting_Billing_Line_Item__c> newBillingLineItems = new List<Revenue_Forecasting_Billing_Line_Item__c>();
        
        for (Billing__c billing : scope) {
            System.debug('billing::'+billing);
            for(Revenue_Stream_Region__c RFR : revenueStreamRegionsToUpdate){
                System.debug('RFR::'+RFR);
                if(billing.Opp_Region__c == RFR.Opportunity_Region__c && billing.Milestone_Year__c == RFR.Finance_Year__c){
                    Revenue_Forecasting_Billing_Line_Item__c jobLog = new Revenue_Forecasting_Billing_Line_Item__c();
                    jobLog.Run_Date__c = Datetime.now();
                    jobLog.Processed_Record_Count__c = scope.size();
                    jobLog.Opportunity_Region__c = billing.Opp_Region__c;
                    jobLog.Billing__c = billing.Id;
                    jobLog.RFR__c = RFR.Opportunity_Region__c;
                    jobLog.Revenue_Stream_Region__c = RFR.id;
                    jobLog.Invoice_Amount__c = billing.Invoice_Amount__c;
                    jobLog.Milestone_Date__c = billing.Milestone_Date__c;
                    jobLog.Milestone_Amount__c = billing.Milestone_Amount__c;
                    jobLog.Actual_Invoice_Date__c= billing.Invoice_Date__c;
                    jobLog.Billing_Currency_Code__c= billing.Billing_Currency_Code__c;
                    jobLog.Currency__c= billing.CurrencyIsoCode;
                    jobLog.Account__c= billing.Account__c;
                    jobLog.Opportunity__c= billing.OpportunityName__c;
                    newBillingLineItems.add(jobLog);
                }
            }
        }
        
        if (!newBillingLineItems.isEmpty()) {
            System.debug('newBillingLineItems::'+newBillingLineItems);
            insert newBillingLineItems;
        }
    }
    
    global void finish(Database.BatchableContext context) {
        /* */
    }
    
    public Integer getQuarter(Date milestone) {
        if (milestone != null) {
            Integer month = milestone.month();
            
            if (month >= 4 && month <= 6) {
                return 1;
            } else if (month >= 7 && month <= 9) {
                return 2;
            } else if (month >= 10 && month <= 12) {
                return 3;
            } else if (month >= 1 && month <= 3) {
                return 4;
            }
        }
        
        return null;
    }
}