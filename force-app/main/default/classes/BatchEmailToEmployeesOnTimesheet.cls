public class BatchEmailToEmployeesOnTimesheet implements Database.Batchable<sObject>, Database.Stateful{
   
   public Database.QueryLocator start(Database.BatchableContext BC){
       // Quering all the list of employees from Organization 
       List<Employee__c> empList = [SELECT Id ,Email_ID__c FROM Employee__c WHERE Active__c=true];
        List<ID> lstEmpId;      
        String empIds;      
        for(Employee__c e : empList){
            if(empIds==null){
                empIds='\''+e.Id+'\',';
            }else{
            empIds+='\''+e.Id+'\',';
            }
        }
        empIds = empIds.removeEnd(',');
        System.debug('empIds'+empIds);      
       // Taking all the records who did not submit the timesheet
       List<Team_Timesheet__c> records1  = [SELECT Id,Week_Start_Date__c,Employee_Name__c,Employee_Name__r.Name,Employee_Name__r.Email_ID__c FROM Team_Timesheet__c where  ((Week_Start_Date__c = LAST_N_DAYS:7 AND Status__c ='Draft') OR (Week_Start_Date__c != LAST_N_DAYS:7))];
       List<Team_Timesheet__c> records2  = [SELECT Id,Week_Start_Date__c,Employee_Name__c,Employee_Name__r.Name,Employee_Name__r.Email_ID__c,Status__c FROM Team_Timesheet__c where  (Week_Start_Date__c = LAST_N_DAYS:7 AND Status__c !='Draft' AND Week_Start_Date__c != TODAY)];
       List<Team_Timesheet__c> subtractedRecords = new List<Team_Timesheet__c>();
        Set<Id> recordIds2 = new Set<Id>();
        system.debug('records1'+records1);
        for (Team_Timesheet__c record : records2) {
            system.debug('record'+record);
            recordIds2.add(record.Employee_Name__c);
        }
       
        for (Team_Timesheet__c record : records1) {
            system.debug('record2'+record);
            if (!recordIds2.contains(record.Employee_Name__c)) {
                subtractedRecords.add(record);
            }
        }
        system.debug('subtractedRecords'+subtractedRecords);
        String queryTS = 'SELECT Id,Week_Start_Date__c,Employee_Name__c,Employee_Name__r.Name,Employee_Name__r.Email_ID__c FROM Team_Timesheet__c WHERE Id IN :subtractedRecords AND Employee_Name__c IN ('+empIds+')';      
       
        return Database.getQueryLocator(queryTS);
   }

   public void execute(Database.BatchableContext BC, List<Team_Timesheet__c> scope){
       System.debug('BC'+BC);
     System.debug('scope'+scope);      
       set<String> emailids = new set<String>();
       Map<String,String> emailnames = new Map<String,String>();
       for(Team_Timesheet__c t : scope){  
            if(!emailids.contains(t.Employee_Name__r.Email_ID__c)){
                emailids.add(t.Employee_Name__r.Email_ID__c);
                emailnames.put(t.Employee_Name__r.Email_ID__c,t.Employee_Name__r.Name);
            }
       }      
       for(String record:emailnames.keySet()){
           system.debug('record'+record);
           system.debug('value'+emailnames.get(record));
           List<string> toAddress = new List<string>();
           toAddress.add(record);
           system.debug('toAddress'+toAddress);
        // Sending emails to the employee who did not submit the Timesheet
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(toAddress);
                mail.setSubject(emailnames.get(record) + ' - ' +'Last Week Timesheet Not Submitted');
                mail.setPlainTextBody('Dear '+emailnames.get(record)+',\n\n'+
                    'Request you to submit last week’s timesheet.\n'+              
                    'Noncompliance of timely submission of the timesheet on a weekly basis will affect your performance review during quarterly appraisal.\n\n'+
                     'IT Team');
                mail.setSaveAsActivity(false);
                mail.setUseSignature(false);
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            allmsg.add(mail);
           Messaging.sendEmail(allmsg);
       system.debug('mail'+mail);
           
            
       }
        
   }

   public void finish(Database.BatchableContext BC){
       system.debug('finish');
             
   }

}