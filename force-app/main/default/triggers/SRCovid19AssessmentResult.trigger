trigger SRCovid19AssessmentResult on SR_Covid_19_Assessment_Check__c (before insert) {
    if(Trigger.isInsert && Trigger.isBefore){
        System.debug('******** Inside SRCovid19AssessmentResult Trigger ***************');
        Boolean isUpdate = false;
        Set<String> emailId = new Set<String>();
        Set<Id> questionnaireId = new Set<Id>();
        //Get all the Email Id's of the inserted Assessment Result Records.
        List<SR_Covid_19_Assessment_Check__c> listAssessmentResults = Trigger.New;
        System.debug('listAssessmentResults - '+listAssessmentResults);
        for(SR_Covid_19_Assessment_Check__c eachAssessment : listAssessmentResults){
            if(emailId.contains(eachAssessment.Email__c)==false){
                emailId.add(eachAssessment.Email__c);
            }
        }
                
        List<Employee_Office_Presence__c> listEmployeeOfficePresence = new List<Employee_Office_Presence__c>();
        
        if(emailId.size()>0){
            //Fetch all the Employees based upon those Email Id' you have got.
            //Then update those employee's record w.r.t to the Assessments they have taken.
            //Also update the SR Asseessment Result record with the Employee's Lookup.
            List<Service_Resource__c> serviceResourceList = [Select Id,Email__c,(Select Id, Name from Employee_Office_Presence__r where Date__c=TODAY) from Service_Resource__c where Email__c =:emailId];
            System.debug('serviceResourceList - '+serviceResourceList);
            for(SR_Covid_19_Assessment_Check__c eachAssessment : listAssessmentResults){
                for(Service_Resource__c eachSR : serviceResourceList){
                    if(eachAssessment.Email__c == eachSR.Email__c){
                        System.debug('Inside IF - '+eachSR.Email__c);
                        
                        System.debug('Employee Office Presence - '+eachSR.Employee_Office_Presence__r);
                        if(eachSR.Employee_Office_Presence__r.size()>0){
                            List<Employee_Office_Presence__c> tempList = eachSR.Employee_Office_Presence__r;
                            Employee_Office_Presence__c tempEOP = new Employee_Office_Presence__c();
                            tempEOP.Id = tempList[0].Id;
                            tempEOP.Employee_Office_Presence__c = eachAssessment.Employee_Office_Presence__c;
                            listEmployeeOfficePresence.add(tempEOP);
                        }
                        else{
                            Employee_Office_Presence__c tempEOP = new Employee_Office_Presence__c();
                            tempEOP.Date__c = Date.today();
                            tempEOP.Employee_Office_Presence__c = eachAssessment.Employee_Office_Presence__c;
                            tempEOP.Employee__c = eachSR.Id;
                            listEmployeeOfficePresence.add(tempEOP);
                        }
                        System.debug('listEmployeeOfficePresence - '+listEmployeeOfficePresence);
                        if(questionnaireId.contains(eachAssessment.Covid_19_Questionnaire__c)==false){
                            questionnaireId.add(eachAssessment.Covid_19_Questionnaire__c);
                        }
                        if(eachAssessment.Are_you_vaccinated__c != null && eachAssessment.Are_you_vaccinated__c!=''){
                            eachSR.Vaccination_Status__c = eachAssessment.Are_you_vaccinated__c;
                        }
                        isUpdate = true;
                        eachSR.Rating__c = eachAssessment.Rating__c;
                        eachSR.Score__c = eachAssessment.Score__c;
                        eachSR.Last_Opt_in_Date_Time__c = eachAssessment.Last_Opt_in_Date_Time__c;
                        eachSR.Last_Covid_Assessment_Date__c = eachAssessment.Screening_Date__c;
                        eachSR.At_Office_Today__c = eachAssessment.Employee_Office_Presence__c;
                        eachAssessment.Service_Resource__c = eachSR.Id;
                        if(eachAssessment.Mark_as_Suspect__c == true){
                            System.debug('Inside Suspect');
                            eachSR.Covid_19_Suspect__c = true;
                            eachSR.Covid_19_Safe__c = false;
                            eachSR.Covid_19_Suspect_Start_Date_Time__c = eachAssessment.Screening_Date__c;
                        }
                        else{
                            System.debug('Inside Safe');
                            eachSR.Covid_19_Safe__c = true;
                            eachSR.Covid_19_Safe_Date_Time__c = DateTime.now();
                        }
                    }
                }
            }
            if(isUpdate){
                list<Covid_19_Questionnaire__c> listQuestionnaire = new list<Covid_19_Questionnaire__c>();
                for(Id eachId : questionnaireId){
                    Covid_19_Questionnaire__c temp = new Covid_19_Questionnaire__c();
                    temp.Id  = eachId;
                    temp.Used__c = true;
					listQuestionnaire.add(temp);                    
                }
                if(listQuestionnaire.size()>0){
                    update listQuestionnaire;
                }
                update serviceResourceList;
            }
            if(listEmployeeOfficePresence.size()>0){
                upsert listEmployeeOfficePresence;
                System.debug('Employee Office Presence Upserted Successfully');
            }
        }
        
    }
}