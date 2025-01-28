global class Covid19AssessmentReminder1 implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'select Name,Employee_Id__c,Email__c,User__r.Id, Last_Covid_Assessment_Date__c from Service_Resource__c where Covid_19_Safe__c=true AND Last_Covid_Assessment_Date__c != today AND Email__c!=null AND Active__c=true ORDER BY Employee_Id__c ASC';
        //String query = 'select Name,Email__c,User__r.Id, Last_Covid_Assessment_Date__c from Service_Resource__c where Last_Covid_Assessment_Date__c != today AND Email__c!=null AND Active__c=true AND (Employee_Id__c=\'C0472\' OR Employee_Id__c=\'C0584\' OR Employee_Id__c=\'C0518\' OR Employee_Id__c=\'C0107\' OR Employee_Id__c=\'CI002\' OR Employee_Id__c=\'C0295\'  OR Employee_Id__c=\'C0003\'  OR Employee_Id__c=\'C0297\'  OR Employee_Id__c=\'C0529\'  OR Employee_Id__c=\'C0490\' OR Employee_Id__c=\'C0260\' OR Employee_Id__c=\'C0024\')';
        return Database.getQueryLocator(query);	
    }
    
    global void execute(Database.BatchableContext BC, List<Service_Resource__c> scope)
    {   
        
        System.debug('Service Resources Size - '+scope.size());        
                
        for(Service_Resource__c sr : (List<Service_Resource__c>)scope) {
            sr.Today_s_Date_Backend__c = Date.today();
            //sr.Last_Covid_Assessment_Date__c = DateTime.now()-1;
        }
        
        update scope;
        
    } 
    
    global void finish(Database.BatchableContext BC){
        
    }
}