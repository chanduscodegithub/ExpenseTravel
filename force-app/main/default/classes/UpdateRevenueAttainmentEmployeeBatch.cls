global class UpdateRevenueAttainmentEmployeeBatch implements Database.Batchable<SObject>, Schedulable {
    
    private Set<Id> recordIds;
    
    public UpdateRevenueAttainmentEmployeeBatch(Set<Id> recordIds) {
        this.recordIds = recordIds;
    }
    
    global void execute(SchedulableContext sc) {
        Set<Id> recordIds = new Set<Id>();
        UpdateRevenueAttainmentEmployeeBatch obj = new UpdateRevenueAttainmentEmployeeBatch(recordIds);
        Database.executeBatch(obj, 100);
    }
    
    global Database.QueryLocator start(Database.BatchableContext context) {
        String query = 'SELECT Id, Opp_Owner__c, Milestone_Year__c, Milestone_Date__c, Milestone_Amount__c, Invoice_Amount__c,Invoice_Date__c,Billing_Currency_Code__c,CurrencyIsoCode,Account__c,OpportunityName__c FROM Billing__c WHERE Milestone_Date__c != null AND Opp_Owner__c != null AND (Invoice_Amount__c != NULL OR Milestone_Amount__c != NULL)';
        
        // Reset the quarterly attainment fields to zero before starting the batch
        List<Revenue_Stream_Employee__c> resetRevenueStreams = [
            SELECT Id, Q1_Revenue_Attainment__c, Q2_Revenue_Attainment__c,
            Q3_Revenue_Attainment__c, Q4_Revenue_Attainment__c
            FROM Revenue_Stream_Employee__c
        ];
        
        for (Revenue_Stream_Employee__c resetRevenueStream : resetRevenueStreams) {
            resetRevenueStream.Q1_Revenue_Attainment__c = 0;
            resetRevenueStream.Q2_Revenue_Attainment__c = 0;
            resetRevenueStream.Q3_Revenue_Attainment__c = 0;
            resetRevenueStream.Q4_Revenue_Attainment__c = 0;
        }
        
        update resetRevenueStreams; // Update the reset records
        
        return Database.getQueryLocator(query);
    }
    
    
    global void execute(Database.BatchableContext context, List<Billing__c> scope) {
        Set<String> employeeNames = new Set<String>();
        Map<Id, String> billingMilestoneYears = new Map<Id, String>(); 
        
        for (Billing__c billing : scope) {
            employeeNames.add(billing.Opp_Owner__c);
            billingMilestoneYears.put(billing.Id, billing.Milestone_Year__c);
        }
        
        List<Revenue_Stream_Employee__c> relevantRevenueStreams = [
            SELECT Id, Employees__c, Employees__r.Name, Q1_Revenue_Attainment__c, Q2_Revenue_Attainment__c,
            Q3_Revenue_Attainment__c, Q4_Revenue_Attainment__c, Finance_Year__c
            FROM Revenue_Stream_Employee__c
            WHERE Employees__r.Name IN :employeeNames
        ];
        
        Map<String, Revenue_Stream_Employee__c> employeeRevenueStreamMap = new Map<String, Revenue_Stream_Employee__c>();
        for (Revenue_Stream_Employee__c revenueStream : relevantRevenueStreams) {
            employeeRevenueStreamMap.put(revenueStream.Employees__r.Name, revenueStream);
        }
        
        Map<String, Map<Integer, Decimal>> quarterlyAttainmentMap = new Map<String, Map<Integer, Decimal>>();
        for (Billing__c billing : scope) {
            String employeeName = billing.Opp_Owner__c;
            Decimal milestoneAmount = billing.Invoice_Amount__c != null ? billing.Invoice_Amount__c : billing.Milestone_Amount__c;
            Integer quarter = getQuarter(billing.Milestone_Date__c);
            String milestoneYear = billingMilestoneYears.get(billing.Id);
            
            if (quarter != null && employeeName != null && employeeRevenueStreamMap.containsKey(employeeName) && milestoneYear != null) {
                Revenue_Stream_Employee__c relevantRevenueStream = employeeRevenueStreamMap.get(employeeName);
                
                if (milestoneYear == relevantRevenueStream.Finance_Year__c) {
                    if (!quarterlyAttainmentMap.containsKey(employeeName)) {
                        quarterlyAttainmentMap.put(employeeName, new Map<Integer, Decimal>());
                    }
                    Map<Integer, Decimal> employeeAttainmentMap = quarterlyAttainmentMap.get(employeeName);
                    
                    if (employeeAttainmentMap.containsKey(quarter)) {
                        employeeAttainmentMap.put(quarter, employeeAttainmentMap.get(quarter) + milestoneAmount);
                    } else {
                        employeeAttainmentMap.put(quarter, milestoneAmount);
                    }
                }
            }
        }
        
        List<Revenue_Stream_Employee__c> revenueStreamEmployeesToUpdate = new List<Revenue_Stream_Employee__c>();
        for (Revenue_Stream_Employee__c revenueStream : relevantRevenueStreams) {
            String employeeName = revenueStream.Employees__r.Name;
            Map<Integer, Decimal> employeeAttainmentMap = quarterlyAttainmentMap.get(employeeName);
            
            if (employeeAttainmentMap != null &&
                employeeRevenueStreamMap.containsKey(employeeName)) {
                    
                    Decimal q1Attainment = employeeAttainmentMap.containsKey(1) ? employeeAttainmentMap.get(1) : 0;
                    Decimal q2Attainment = employeeAttainmentMap.containsKey(2) ? employeeAttainmentMap.get(2) : 0;
                    Decimal q3Attainment = employeeAttainmentMap.containsKey(3) ? employeeAttainmentMap.get(3) : 0;
                    Decimal q4Attainment = employeeAttainmentMap.containsKey(4) ? employeeAttainmentMap.get(4) : 0;
                    
                    Revenue_Stream_Employee__c updatedRevenueStream = new Revenue_Stream_Employee__c();
                    updatedRevenueStream.Id = revenueStream.Id;
                    updatedRevenueStream.Q1_Revenue_Attainment__c =revenueStream.Q1_Revenue_Attainment__c + q1Attainment;
                    updatedRevenueStream.Q2_Revenue_Attainment__c =revenueStream.Q2_Revenue_Attainment__c + q2Attainment;
                    updatedRevenueStream.Q3_Revenue_Attainment__c =revenueStream.Q3_Revenue_Attainment__c + q3Attainment;
                    updatedRevenueStream.Q4_Revenue_Attainment__c =revenueStream.Q4_Revenue_Attainment__c + q4Attainment;
                    revenueStreamEmployeesToUpdate.add(updatedRevenueStream);
                }
        }
        
        if (!revenueStreamEmployeesToUpdate.isEmpty()) {
            Database.update(revenueStreamEmployeesToUpdate);
        }
        List<Revenue_Forecasting_Billing_Line_Item__c> newBillingLineItems = new List<Revenue_Forecasting_Billing_Line_Item__c>();
        for (Billing__c billing : scope) {
            String milestoneYear = billingMilestoneYears.get(billing.Id);
            for (Revenue_Stream_Employee__c RFE :relevantRevenueStreams) {
                if (billing.Opp_Owner__c == RFE.Employees__r.Name && milestoneYear == RFE.Finance_Year__c) {
                    Revenue_Forecasting_Billing_Line_Item__c jobLog = new Revenue_Forecasting_Billing_Line_Item__c(
                        Run_Date__c = Datetime.now(),
                        Processed_Record_Count__c = scope.size(),
                        Employee__c = billing.Opp_Owner__c,
                        Billing__c = billing.Id,
                        RFE__c = RFE.Employees__r.Name,
                        Revenue_Stream_Employee__c = RFE.Id,
                        Invoice_Amount__c = billing.Invoice_Amount__c,
                        Milestone_Date__c = billing.Milestone_Date__c,
                        Milestone_Amount__c = billing.Milestone_Amount__c,
                        Actual_Invoice_Date__c= billing.Invoice_Date__c,
                        Billing_Currency_Code__c= billing.Billing_Currency_Code__c,
                        Currency__c= billing.CurrencyIsoCode,
                        Account__c= billing.Account__c,
                        Opportunity__c= billing.OpportunityName__c
                    );
                    newBillingLineItems.add(jobLog);
                }
            }
        }
        
        if (!newBillingLineItems.isEmpty()) {
            Database.insert(newBillingLineItems);
        }
    }
    
    global void finish(Database.BatchableContext context) {
        
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