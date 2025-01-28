public without sharing class ResumeController {
    @AuraEnabled
    public static Job_Application_Analysis__c getResumeInsightRecord(String recordId) 
    {
        String jobApplicationPrefix = Schema.getGlobalDescribe().get('Job_Application__c').getDescribe().getKeyPrefix();
        String interviewPrefix = Schema.getGlobalDescribe().get('Review__c').getDescribe().getKeyPrefix();
        if (recordId!=null && recordId.startsWithIgnoreCase(interviewPrefix)) 
        {
            Review__c interviewRecord=[SELECT Id,Job_Application__c FROM Review__c WHERE Id=:recordId LIMIT 1];
            recordId= interviewRecord.Job_Application__c;
        }
        
        return [
            SELECT
            Id,
            Name,
            Candidate_Name__c,
            Email_Address__c,
            Phone_Number__c,
            Total_Experience_Months__c,
            Current_Location__c,
            Trailhead_Url__c,
            LinkedIn_Url__c,
            Max_Time_Spent_in_a_Company__c,
            Min_Time_Spent_in_a_Company__c,
            Average_Tenure__c,
            Worked_in_Banglore_Before__c,
            Expecting_a_Hybrid_Work_Model__c,
            Found_Skills__c,
            Advanced_Certifications__c,
            Companies_Worked_for__c,
            Expertise_and_Experience_Summary__c,
            Latest_Role__c,
            Job_Application__r.Position__r.Job_Role__r.Min_Months_of_Experience__c,
            Job_Application__r.Position__r.Job_Role__r.Max_Months_of_Experience__c,
            Job_Application__r.Position__r.Job_Role__r.Min_Tenure_in_a_Company__c,
            Job_Application__r.Position__r.Job_Role__r.Avg_Tenure_in_a_Company__c,
            Essential_Tech_Skills_Analysis__c,Missing_Tech_Skills__c,
            Advanced_Tech_Skills_Analysis__c,
            Essential_Admin_Skills_Analysis__c,Missing_Admin_Skills__c,
            Advanced_Admin_Skills_Analysis__c,
            Essential_Tools_Analysis__c,Missing_Tools__c,
            Advanced_Tools_Analysis__c,
            Salesforce_Clouds_Analysis__c,Missing_Clouds__c,
            Verticals_Analysis__c,Missing_Verticals__c,Essential_Administration_Skills_Score__c,Advanced_Administration_Skills_Score__c,
            Essential_Certifications_Analysis__c,Missing_Certifications__c,Missing_Tech_Skills_Additional__c,Missing_Admin_Skills_Additional__c,
            Missing_Tools_Additional__c,Missing_Certifications_Additional__c,
            Overall_Score__c,
            Advanced_Certitfications_Analysis__c,Advanced_Tech_Score__c,Essential_Tech_Score__c,Advanced_Tools_Score__c,Essental_Tools_Score__c,Verticals_Score__c,Salesforce_Clouds_Score__c,
            Advanced_Certifications_Score__c,Essential_Certifications_Score__c,
            Job_Application__r.Position__r.Location__c
            FROM Job_Application_Analysis__c
            WHERE Job_Application__c = :recordId ORDER BY Createddate DESC
            LIMIT 1
        ];
    }
    
    @AuraEnabled
    public static void updateSummaryOpened(String jobApplicationRecordId)
    {
        Job_Application__c jobApp=new Job_Application__c();
        jobApp.Id=jobApplicationRecordId;
        jobApp.Summary_Opened__c=true;
        update jobApp;
    }
}