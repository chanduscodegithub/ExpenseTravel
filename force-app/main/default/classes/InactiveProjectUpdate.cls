/*
*********************************************************
Apex Class Name    :InactiveProjectUpdate 
Created Date       :July 26, 2023
@description       :This is class is used for when the project end date is reached it will update the billing status of employee
@author            :Yuvathi
schedulerclass     :InactiveProjectschedulable
*********************************************************
*/
global class InactiveProjectUpdate implements Database.Batchable<sObject>  {
    global List<TeamAllocation__c> start(Database.BatchableContext BC) {
        List<TeamAllocation__c> TeamAlloclist =[SELECT Id, Name,EmployeeName__c,EndDate__c FROM TeamAllocation__c where EndDate__c=LAST_N_DAYS:2 and EndDate__c!=TODAY ]; 
        return TeamAlloclist;
        
    }
    global void execute(Database.BatchableContext BC, List<TeamAllocation__c> TeamAlloclist) {
        system.debug('TeamAlloclist'+TeamAlloclist);
        List<Id> employees = new List<Id>();
        set<Id> teamallocId= new set<Id>();
        if(TeamAlloclist.size()>0)
        {
            for(TeamAllocation__c teamAll:TeamAlloclist)
            {
                if(!employees.contains(teamAll.EmployeeName__c)){
                employees.add(teamAll.EmployeeName__c);
                }
                teamallocId.add(teamAll.Id);
            }
            Map<Id,TeamAllocation__c> TeamAllocdata= new Map<Id,TeamAllocation__c>([select id,Active__c,EmployeeName__c from TeamAllocation__c where Id IN:teamallocId]);
            system.debug('TeamAllocdata'+TeamAllocdata);
            EmployeeBillableStatusService.updateEmployee(employees,TeamAllocdata);
        }
    }
    global void finish(Database.BatchableContext BC) {
        List<String> toMail = new List<String>();
                               toMail.add('lakkaraju.yuvathi@crmit.com');
                               //toMail.add('aneesh.vemireddy@crmit.com');
         AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:bc.getJobId()]; 
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(toMail);
        
        mail.setSubject('Inative Batch Status Mail. The result is ' + a.Status);
        
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
                              
                              ' batches with '+ a.NumberOfErrors + ' failures.');
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
        
    }