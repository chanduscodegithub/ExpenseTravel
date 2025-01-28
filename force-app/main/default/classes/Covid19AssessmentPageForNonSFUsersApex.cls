public without sharing class Covid19AssessmentPageForNonSFUsersApex {
    
    public Class QuestionSetWithWeightage{
        @AuraEnabled
        public String question{get; set;}
        @AuraEnabled
        public String apiName{get; set;}
        @AuraEnabled
        public String value{get; set;}
        @AuraEnabled
        public Integer weightage{get; set;}
        @AuraEnabled
        public String type{get; set;}
        @AuraEnabled
        public List<String> picklistValues{get; set;}
        @AuraEnabled
        public String picklistValuesWeightage{get; set;}
        
    }

    public Class WrapQuestionPicklist{
        @AuraEnabled
        public List<QuestionSetWithWeightage> questionSet{get;set;}
        @AuraEnabled
        public date todayDate {get;set;}
        @AuraEnabled
        public String serviceResourceURL {get;set;}
        @AuraEnabled
        public Covid_19_Questionnaire__c covidQuestionnaire {get;set;}
        @AuraEnabled
        public String headerNote {get;set;}
        @AuraEnabled
        public Boolean showRiskScore {get;set;}
        @AuraEnabled
        public Boolean isCovid19Patient {get;set;}
        @AuraEnabled
        public Boolean isServiceResource {get;set;}
        @AuraEnabled
        public Boolean isValidUser {get;set;}
        @AuraEnabled
        public List<Covid_19_Assessment_Rating_Line_Item__c> covid19AssessmentResultList {get;set;}
        @AuraEnabled
        public String areYouVaccinated {get;set;}
        
    }
    
    //To fetch the questions to be asked for the Technicians.
    @AuraEnabled
    public static WrapQuestionPicklist fetchSymptomQuestions(String idToken){
        try{
            WrapQuestionPicklist wrapQuesPick = new WrapQuestionPicklist();
            GoogleOAuthWrapper googleOAuthWrap = new GoogleOAuthWrapper();
            Google_OAuth__c googleOAuth = Google_OAuth__c.getInstance();
            
            //Fetching the Google Authenticated User's details.
            googleOAuthWrap = GoogleOAuthUserDetails.getClientIdAndMailId(idToken);
            
            //Verifying if the User have logged with proper Creds.
            if(googleOAuthWrap.clientId!=googleOAuth.Client_Id__c || googleOAuthWrap.email==null || googleOAuthWrap.email==''){
                wrapQuesPick.isServiceResource = false;
                return wrapQuesPick;
            }
            
            System.debug('googleOAuthWrap - '+googleOAuthWrap);
            Covid_19_Metadata__c covid19Metadata = Covid_19_Metadata__c.getInstance();
            wrapQuesPick.showRiskScore = covid19Metadata.Show_Risk_Score__c;
            Service_Resource__c serviceResource;
            try{
                serviceResource = [Select Id ,Name,Covid_19_Patient__c,Vaccination_Status__c,Covid_19_Suspect__c,Region__c,Country__c,Site__c from Service_Resource__c where Email__c=:googleOAuthWrap.email limit 1]; 
                //serviceResource = [Select Id , Name from Service_Resource__c where User__c='0052v00000XZQSVAA5' limit 1];
            }
            catch(Exception e){
                System.debug('Exception at line - '+e.getLineNumber());
                System.debug('Exception e - '+e.getMessage());
                wrapQuesPick.isServiceResource = false;
                return wrapQuesPick;  
            }
            if(serviceResource.Covid_19_Patient__c == true || serviceResource.Covid_19_Suspect__c==true){
                wrapQuesPick.isCovid19Patient = true;
                return wrapQuesPick;                
            }
            
            //The Note in Header Card.
            wrapQuesPick.headerNote = googleOAuth.Note_1__c+' '+googleOAuth.Note_2__c;
            wrapQuesPick.isServiceResource = true;
            wrapQuesPick.isCovid19Patient = false;
            wrapQuesPick.serviceResourceURL = serviceResource.Id;
            wrapQuesPick.areYouVaccinated = serviceResource.Vaccination_Status__c;
            wrapQuesPick.todayDate = Date.today();
            
            //Fetching the Questionnaire records with respect the Employee's Region, Country, State/Site.
            List<Covid_19_Questionnaire__c> covidQuestionnaire = Covid19QuestionnaireAndRatings.getQuestionnaireLineItems(serviceResource.Region__c,serviceResource.Country__c,serviceResource.Site__c);
            List<Covid_19_Questionnaire_Line_Item__c> listCovid19Questionnaire = covidQuestionnaire[0].Covid_19_Questionnaire_Line_Items__r;
            
            System.debug('listCovid19Questionnaire - '+listCovid19Questionnaire);
            wrapQuesPick.covidQuestionnaire = covidQuestionnaire[0];
            System.debug('wrapQuesPick.covidQuestionnaire - '+wrapQuesPick.covidQuestionnaire);
            
            //Fetching all the Risk profiles belonging to that Questionnaire.
            wrapQuesPick.covid19AssessmentResultList = [SELECT Id, Name, Mark_as_Suspect__c,Color__c,Risk_Rating_Value__c, Risk_Rating_Label__c, Risk_Rating_API__c, Risk_Score_Label__c, Risk_Score_API__c, Upper_Limit__c, Recommendation__c FROM Covid_19_Assessment_Rating_Line_Item__c where Covid_19_Assessment_Rating__r.Covid_19_Questionnaire__c=:wrapQuesPick.covidQuestionnaire.Id  Order By Upper_Limit__c ASC limit 50];
            System.debug('covid19AssessmentResultList - '+wrapQuesPick.covid19AssessmentResultList);
            
            // Setting the Questionnaire to the required format for UI.
            wrapQuesPick.questionSet = new List<QuestionSetWithWeightage>();
            for(Covid_19_Questionnaire_Line_Item__c eachRecord : listCovid19Questionnaire){
                QuestionSetWithWeightage temp = new QuestionSetWithWeightage();
                temp.question = '';
                if(eachRecord.Question__c.contains('OR')){
                    List<String> questionList =  eachRecord.Question__c.split('OR');
                    Integer z=0;
                    for(String eachQuestion : questionList){
                        if(z!=questionList.size()-1){
                            temp.question = temp.question + eachQuestion + '<br/> OR ';
                        }
                        else{
                            temp.question = temp.question + eachQuestion;
                        }
                        z++;
                    }
                }
                else{
                    temp.question = eachRecord.Question__c;
                }
                temp.apiName = eachRecord.API_Name__c;
                temp.weightage = Integer.valueOf(eachRecord.Weightage__c);
                temp.type = eachRecord.Field_Type__c;
                temp.picklistValues = new List<String>();
                if(temp.type == 'Picklist'){
                    if(eachRecord.Picklist_Values__c.contains(',')){
                        temp.picklistValues = eachRecord.Picklist_Values__c.split(',');
                    }
                    else{
                        temp.picklistValues.add(eachRecord.Picklist_Values__c);
                    }
                    temp.picklistValuesWeightage = eachRecord.Picklist_Values_for_Weightage__c;
                }
                System.debug('Each Question set - '+temp);
                wrapQuesPick.questionSet.add(temp); 
            }
            System.debug('List of Ordered Question sets - '+wrapQuesPick.questionSet);
            return wrapQuesPick;
        }
        catch(Exception e){
            System.debug('Exception at line - '+e.getLineNumber());
            System.debug('Exception e - '+e.getMessage());
            return null;
        }
    }
    
    
    //To Store the Technician's Assessment Results as an RI to Service Resource Record.
    @AuraEnabled
    public static String storeTechAssessmentResults(Map<String,String> resultDetailsMap, String score, String risk, String recommendation,String idToken, Covid_19_Questionnaire__c covidQuestionnaire,List<Covid_19_Assessment_Rating_Line_Item__c> covid19AssessmentResultList,String optInDateTimeString, Boolean employeeComingToOfficeToday){
        
        System.debug('resultDetailsMap - '+resultDetailsMap);
        System.debug('score - '+score);
        System.debug('risk - '+risk);
        System.debug('recommendation - '+recommendation);
        System.debug('covidQuestionnaire - '+covidQuestionnaire);
        System.debug('covid19AssessmentResultList - '+covid19AssessmentResultList);
        System.debug('optInDateTimeString - '+optInDateTimeString);
        
        String dateString = optInDateTimeString.split(' ')[0];
        String timeString = optInDateTimeString.split(' ')[1];
        
        GoogleOAuthWrapper googleOAuthWrap = new GoogleOAuthWrapper();
        Google_OAuth__c googleOAuth = Google_OAuth__c.getInstance();
        
        googleOAuthWrap = GoogleOAuthUserDetails.getClientIdAndMailId(idToken);
        
        if(googleOAuthWrap.clientId!=googleOAuth.Client_Id__c || googleOAuthWrap.email==null || googleOAuthWrap.email==''){
            return 'fail';
        }
        
        //This result part has to be yet made dynamic according to Employee's Region, Country and Site.
        Integer indexOfAssessmentRating=0;
        
        //Get the Index number of the Risk Profile based upon the Risk Profile's Upper Limit and Employee's Assessment Score.
        for(Integer i=0;i<covid19AssessmentResultList.size();i++){
            if(Integer.valueOf(score) <= covid19AssessmentResultList[i].Upper_Limit__c){
                indexOfAssessmentRating = i;
                break;
            }
        }
        
        //Creation of Employee's Self-Assessment record.
        SR_Covid_19_Assessment_Check__c insertSRCovid19Assessment = new SR_Covid_19_Assessment_Check__c();
        if(resultDetailsMap!=null){
            Set<String> apiNamesSet = resultDetailsMap.keySet();
            System.debug('apiNamesSet - '+apiNamesSet);
            System.debug('apiNamesSet Size - '+apiNamesSet.size());
            for(String eachKey : apiNamesSet){
                insertSRCovid19Assessment.put(eachKey,resultDetailsMap.get(eachKey));
            } 
            
            System.debug('covid19AssessmentResultList[indexOfAssessmentRating] - '+covid19AssessmentResultList[indexOfAssessmentRating]);
            insertSRCovid19Assessment.put(covid19AssessmentResultList[indexOfAssessmentRating].Risk_Rating_API__c,risk);
            insertSRCovid19Assessment.put(covid19AssessmentResultList[indexOfAssessmentRating].Risk_Score_API__c,Decimal.valueOf(score));
            insertSRCovid19Assessment.Mark_as_Suspect__c = covid19AssessmentResultList[indexOfAssessmentRating].Mark_as_Suspect__c;
            insertSRCovid19Assessment.Email__c = googleOAuthWrap.email;
            insertSRCovid19Assessment.Covid_19_Questionnaire__c = covidQuestionnaire.Id;
            insertSRCovid19Assessment.NotifyOnSuspect__c = covidQuestionnaire.NotifyOnSuspect__c;
            insertSRCovid19Assessment.Screening_Date__c = DateTime.now();
            insertSRCovid19Assessment.Recommendation__c = recommendation;
            insertSRCovid19Assessment.Last_Opt_in_Date_Time__c = DateTime.newInstance(Integer.valueOf(dateString.split('/')[2]), Integer.valueOf(dateString.split('/')[1]), Integer.valueOf(dateString.split('/')[0]),Integer.valueOf(timeString.split(':')[0]),Integer.valueOf(timeString.split(':')[1]),0);
            insertSRCovid19Assessment.Employee_Office_Presence__c = employeeComingToOfficeToday;
            insert insertSRCovid19Assessment;
            
            return 'success';
        }
        else{
            return 'fail';
        }
    }
}