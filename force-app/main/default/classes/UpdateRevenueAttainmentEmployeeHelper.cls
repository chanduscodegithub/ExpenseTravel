public class UpdateRevenueAttainmentEmployeeHelper {
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
    
    public static void updateRevenueAttainmentEmp(List<Billing__c> billings) {
        // Collect the unique Employee__c values from the billing records
        Set<Id> employeeIds = new Set<Id>();
        for (Billing__c billing : billings) {
            employeeIds.add(billing.Resource_Name1__c);
        }
        
        // Retrieve the Revenue_Stream_Employee__c records for the matching Employee__c IDs
        List<Revenue_Stream_Employee__c> revenueStreamEmployees = [
            SELECT Id, Q1_Revenue_Attainment__c, Q2_Revenue_Attainment__c, Q3_Revenue_Attainment__c, Q4_Revenue_Attainment__c, Employee__c
            FROM Revenue_Stream_Employee__c
            WHERE Employee__c IN :employeeIds
        ];
        
        // Iterate over the Revenue_Stream_Employee__c records and update the revenue attainment fields
        for (Revenue_Stream_Employee__c revenueStream : revenueStreamEmployees) {
            Decimal q1RevenueAttainment = revenueStream.Q1_Revenue_Attainment__c != null ? revenueStream.Q1_Revenue_Attainment__c : 0;
            Decimal q2RevenueAttainment = revenueStream.Q2_Revenue_Attainment__c != null ? revenueStream.Q2_Revenue_Attainment__c : 0;
            Decimal q3RevenueAttainment = revenueStream.Q3_Revenue_Attainment__c != null ? revenueStream.Q3_Revenue_Attainment__c : 0;
            Decimal q4RevenueAttainment = revenueStream.Q4_Revenue_Attainment__c != null ? revenueStream.Q4_Revenue_Attainment__c : 0;
            
            for (Billing__c billing : billings) {
                Decimal milestoneAmount = billing.Milestone_Amount__c;
                Date milestoneDate = billing.Milestone_Date__c;
                
                if (milestoneAmount != null && milestoneDate != null && billing.Resource_Name1__c == revenueStream.Employee__c) {
                    Integer quarter = getQuarter(milestoneDate);
                    
                    if (quarter != null) {
                        switch on quarter {
                            when 1 {
                                q1RevenueAttainment += milestoneAmount;
                            }
                            when 2 {
                                q2RevenueAttainment += milestoneAmount;
                            }
                            when 3 {
                                q3RevenueAttainment += milestoneAmount;
                            }
                            when 4 {
                                q4RevenueAttainment += milestoneAmount;
                            }
                        }
                    }
                }
            }
            
            // Assign the updated values to the corresponding fields
            revenueStream.Q1_Revenue_Attainment__c = q1RevenueAttainment;
            revenueStream.Q2_Revenue_Attainment__c = q2RevenueAttainment;
            revenueStream.Q3_Revenue_Attainment__c = q3RevenueAttainment;
            revenueStream.Q4_Revenue_Attainment__c = q4RevenueAttainment;
        }
        
        // Perform the bulk update of Revenue_Stream_Employee__c records
        if (!revenueStreamEmployees.isEmpty()) {
            update revenueStreamEmployees;
        }
    }
}