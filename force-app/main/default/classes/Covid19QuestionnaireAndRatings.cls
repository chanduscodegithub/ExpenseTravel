public class Covid19QuestionnaireAndRatings {
    public static List<Covid_19_Questionnaire__c> getQuestionnaireLineItems(String region, String country, String site){
        try{
            Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();    
            Map <String, Schema.SObjectField> fieldMap = new Map <String, Schema.SObjectField>();
            
            String queryCovid19QuestionnaireLineItems = 'Select ';
            fieldMap = gd.get('Covid_19_Questionnaire_Line_Item__c').getDescribe().fields.getMap();
            for(Schema.SObjectField fieldAPI : fieldMap.values())
            {
                if(String.valueOf(fieldAPI).contains('__c')){
                    queryCovid19QuestionnaireLineItems = queryCovid19QuestionnaireLineItems + fieldAPI+',';
                }
            }
            queryCovid19QuestionnaireLineItems = queryCovid19QuestionnaireLineItems.removeEnd(',');
            queryCovid19QuestionnaireLineItems = queryCovid19QuestionnaireLineItems + ' from Covid_19_Questionnaire_Line_Items__r Order By Sequence_Number__c ASC limit 100';
            
            String queryQuestionnaire = 'SELECT Id, NotifyOnSuspect__c,('+queryCovid19QuestionnaireLineItems+') FROM Covid_19_Questionnaire__c where Active__c=true AND Region__c=:region AND Country__c=:country AND Site__c=:site';
            System.debug('queryQuestionnaire - '+queryQuestionnaire);
            List<Covid_19_Questionnaire__c> covid19Questionnaire = new List<Covid_19_Questionnaire__c>();
            covid19Questionnaire = Database.query(queryQuestionnaire);
            //The below part of the code has to be Optimized yet.
            if(covid19Questionnaire.size()==0){
                queryQuestionnaire = 'SELECT Id, NotifyOnSuspect__c,('+queryCovid19QuestionnaireLineItems+') FROM Covid_19_Questionnaire__c where Active__c=true AND Region__c=:region AND Country__c=:country AND Site__c=\'All\'';
                covid19Questionnaire = Database.query(queryQuestionnaire);
                if(covid19Questionnaire.size()==0){
                    queryQuestionnaire = 'SELECT Id, NotifyOnSuspect__c,('+queryCovid19QuestionnaireLineItems+') FROM Covid_19_Questionnaire__c where Active__c=true AND Region__c=:region AND Country__c=:country';
                    covid19Questionnaire = Database.query(queryQuestionnaire);
                    if(covid19Questionnaire.size()==0){
                        queryQuestionnaire = 'SELECT Id, NotifyOnSuspect__c,('+queryCovid19QuestionnaireLineItems+') FROM Covid_19_Questionnaire__c where Active__c=true AND Region__c=:region';
                        covid19Questionnaire = Database.query(queryQuestionnaire);
                        System.debug('covid19Questionnaire - '+covid19Questionnaire);
                        System.debug('covid19QuestionnaireLineItems - '+covid19Questionnaire[0].Covid_19_Questionnaire_Line_Items__r);
                        return covid19Questionnaire;
                    }
                    else{
                        System.debug('covid19QuestionnaireLineItems - '+covid19Questionnaire[0].Covid_19_Questionnaire_Line_Items__r);
                        System.debug('covid19Questionnaire - '+covid19Questionnaire);
                        return covid19Questionnaire;
                    }
                }
                else{
                    System.debug('covid19QuestionnaireLineItems - '+covid19Questionnaire[0].Covid_19_Questionnaire_Line_Items__r);
                    System.debug('covid19Questionnaire - '+covid19Questionnaire);
                    return covid19Questionnaire;
                }
            }
            else{
                System.debug('covid19Questionnaire - '+covid19Questionnaire);
                return covid19Questionnaire;
            }
        }
        catch(Exception e){
            System.debug('Exception at line - '+e.getLineNumber());
            System.debug('Exception e - '+e.getMessage());
            return null;
        }
    }
}