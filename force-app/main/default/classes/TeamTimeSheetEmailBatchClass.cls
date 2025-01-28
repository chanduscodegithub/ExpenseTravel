public class TeamTimeSheetEmailBatchClass implements
Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('Select id,Employee_Name__r.Email_ID__c,CreatedDate,Week_Start_Date__c,Status__c from Team_Timesheet__c where Week_Start_Date__c  =LAST_N_DAYS:6 and Status__c = \'Draft\'');
    }
    public void execute(Database.BatchableContext bc, List<Team_Timesheet__c> scope){
        for(Team_Timesheet__c tt:scope){
            List<String> sl = new List<String>();
            sl.add(tt.Employee_Name__r.Email_ID__c);
            System.debug('Email  = '+tt.Employee_Name__r.Email_ID__c);
            Messaging.SingleEmailMessage mail=new Messaging.SingleEmailMessage();
            mail.setSubject('Draft');
            mail.setPlainTextBody('You have timesheet saved as draft');
            mail.setToAddresses(sl);
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            System.debug('R data--> '+r);
        }
    }
    public void finish(Database.BatchableContext bc){
    }
    
}