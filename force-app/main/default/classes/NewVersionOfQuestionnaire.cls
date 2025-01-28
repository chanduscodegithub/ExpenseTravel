public class NewVersionOfQuestionnaire {
    @AuraEnabled
    public static String createNewVersionOfQuestionnaire(String recordId){
        try{
            List<Covid_19_Questionnaire__c> covid19Questionnaire = [SELECT Id, Name, Region__c,NotifyOnSuspect__c,Version_Number__c, Country__c, Site__c, Active__c, 
                                                                             Name__c, (SELECT Id, Name, Sequence_Number__c, Question__c, 
                                                                                                Weightage__c, Label__c, API_Name__c, Field_Type__c, 
                                                                                                Picklist_Values__c, Picklist_Values_for_Weightage__c 
                                                                                                FROM Covid_19_Questionnaire_Line_Items__r) 
                                                                             FROM Covid_19_Questionnaire__c where Id =:recordId limit 1];
            System.debug('Covid19Questionnaire - '+covid19Questionnaire);
            
            List<Covid_19_Questionnaire_Line_Item__c> covid19QuestionnaireLineItems = covid19Questionnaire[0].Covid_19_Questionnaire_Line_Items__r;
            System.debug('Covid19 Questionnaire Line Items - '+covid19QuestionnaireLineItems);
            
            List<Covid_19_Assessment_Rating_Line_Item__c> covid19RiskProfiles = [SELECT Name, Risk_Rating_Value__c, Risk_Rating_Label__c, 
                                                                                          Risk_Score_Label__c, Risk_Rating_API__c, Risk_Score_API__c, 
                                                                                          Upper_Limit__c, Recommendation__c, Color__c, Covid_19_Assessment_Rating__c, 
                                                                                          Lower_Limit__c, Mark_as_Suspect__c, Id FROM Covid_19_Assessment_Rating_Line_Item__c where Covid_19_Assessment_Rating__r.Covid_19_Questionnaire__c =:recordId];
            
            
            Covid_19_Questionnaire__c newQuestionnaire = new Covid_19_Questionnaire__c();
            newQuestionnaire.Name__c = covid19Questionnaire[0].Name__c;
            newQuestionnaire.Active__c = false;
            newQuestionnaire.Version_Number__c  = covid19Questionnaire[0].Version_Number__c + 1;
            newQuestionnaire.Region__c = covid19Questionnaire[0].Region__c;
            newQuestionnaire.Country__c = covid19Questionnaire[0].Country__c;
            newQuestionnaire.Site__c = covid19Questionnaire[0].Site__c;
            newQuestionnaire.NotifyOnSuspect__c = covid19Questionnaire[0].NotifyOnSuspect__c;
            insert newQuestionnaire;
            System.debug('newQuestionnaire Inserted');
            
            for(Covid_19_Questionnaire_Line_Item__c eachLineItem : covid19QuestionnaireLineItems){
                eachLineItem.Id = null;
                eachLineItem.Covid_19_Questionnaire__c = newQuestionnaire.Id;
            }
            insert covid19QuestionnaireLineItems;
            System.debug('Questionnaire Line Items Inserted');
            
            Covid_19_Assessment_Rating__c covid19RiskProfile = new Covid_19_Assessment_Rating__c(Covid_19_Questionnaire__c=newQuestionnaire.Id);
            insert covid19RiskProfile;
            System.debug('covid19RiskProfile Inserted');
            
            for(Covid_19_Assessment_Rating_Line_Item__c eachLineItem : covid19RiskProfiles){
                eachLineItem.Id = null;
                eachLineItem.Covid_19_Assessment_Rating__c = covid19RiskProfile.Id;
            }
            insert covid19RiskProfiles;
            System.debug('covid19RiskProfiles Inserted');
            return 'success';
        }
        catch(Exception e){
            System.debug('Exception at line - '+e.getLineNumber());
            System.debug('Exception e - '+e.getMessage());
            return e.getMessage();
        }
    }
}