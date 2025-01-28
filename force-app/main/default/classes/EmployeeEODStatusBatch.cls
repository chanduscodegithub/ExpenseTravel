/*
Developer : Shailesh Kishore (C0391)
Description : This Batch class will Insert EmployeeEODStatus record for Each Employee on a daily basis EOD.
*/
public class EmployeeEODStatusBatch implements Database.Batchable<SObject> {
    
    public Database.QueryLocator start(Database.BatchableContext BC){
        try{
            String query = 'Select Id,Name,Region__c,Country__c,Site__c,Gender__c,Age__c,Covid_19_Safe__c,Covid_19_Suspect__c,Covid_19_Patient__c,Rating__c,Score__c from Service_Resource__c LIMIT 1';
            return Database.getQueryLocator(query);
        }catch(Exception e){
            System.debug('Exception line :'+e.getLineNumber());
            System.debug('Exception Message :'+e.getMessage());
            return null;
        }
    }
    
    public void execute(Database.BatchableContext BC, List<Service_Resource__c> scope){
        try{
            if(scope != null && scope.size() != 0){
                List<Employee_EOD_Status__c> listToInsertEODStatus = new List<Employee_EOD_Status__c>();
                for(Service_Resource__c eachSR : scope){
                    Employee_EOD_Status__c eachEODStatus = new Employee_EOD_Status__c();
                    eachEODStatus.Service_Resource_ID__c =  eachSR.Id;
                    eachEODStatus.SRRowId__c = eachSR.Id;
                    eachEODStatus.Name =  eachSR.Name;
                    if(eachSR.Age__c != null){
                        eachEODStatus.Age__c = eachSR.Age__c;
                    }
                    if(eachSR.Country__c != null){
                        eachEODStatus.Country__c = eachSR.Country__c;
                    }
                    if(eachSR.Gender__c != null){
                        eachEODStatus.Gender__c =  eachSR.Gender__c;
                    }
                    if(eachSR.Region__c != null){
                        eachEODStatus.Region__c =  eachSR.Region__c;
                    }
                    if(eachSR.Rating__c != null){
                        eachEODStatus.Risk_Rating__c = eachSR.Rating__c;
                    }
                    if(eachSR.Score__c != null){
                        eachEODStatus.Risk_Score__c = eachSR.Score__c;
                    }
                    if(eachSR.Site__c != null){
                        eachEODStatus.Site_State__c = eachSR.Site__c;
                    }
                    //Based on Priority Status picklist field will be assigned, being a patient is highest.
                    //Logic is to put First as unknown and check for low priority to High
                    eachEODStatus.Status__c = 'Unknown'; 
                    if(eachSR.Covid_19_Safe__c){
                        eachEODStatus.Status__c = 'Safe'; 
                    } 
                    if(eachSR.Covid_19_Suspect__c){
                        eachEODStatus.Status__c = 'Suspect'; 
                    } 
                    if(eachSR.Covid_19_Patient__c){
                        eachEODStatus.Status__c = 'Patient'; 
                    } 
                    //Current Date of Batch Run
                    eachEODStatus.Date__c = Date.today();
                    
                    listToInsertEODStatus.add(eachEODStatus);  
                }
                if(listToInsertEODStatus.size() > 0){
                    try{
                        System.debug('listToInsertEODStatus :'+listToInsertEODStatus);
                        insert listToInsertEODStatus;
                    }catch(Exception e){
                        System.debug('listToInsertEODStatus :'+listToInsertEODStatus);
                        System.debug('Exception in Inserting List of Employee_EOD_Status__c');
                        System.debug('Exception Message :'+e.getMessage());
                    }
                }  
            }//End of main If (scope != null && scope.size() != 0)
        }catch(Exception e){
            System.debug('Exception line :'+e.getLineNumber());
            System.debug('Exception Message :'+e.getMessage());
        }
    }
    
    public void finish(Database.BatchableContext BC){
        
    }
}