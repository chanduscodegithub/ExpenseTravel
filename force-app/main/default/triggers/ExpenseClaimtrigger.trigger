trigger ExpenseClaimtrigger on Expense_Claim__c (before insert,after update) {
    set<Id> empIds= new set<Id>();
    if(trigger.isbefore && trigger.isinsert)
    {
        if(!trigger.new.isEmpty())
        {
            for(Expense_Claim__c expObj : trigger.new)
            {
                if(expObj.Employee_ID__c!=null)
                {
                    empIds.add(expObj.Employee_ID__c);
                }
            }
            Map<Id,Employee__c> empdata=new Map<Id,Employee__c>([SELECT Id, Name, Email_ID__c,Department__c, Country__c,ReportingTo__r.SF_User__c, BU_Head__r.SF_User__c FROM Employee__c where Id IN:empIds]);
            for(Expense_Claim__c expObj : trigger.new)
            {
                if(empdata.get(expObj.Employee_ID__c).ReportingTo__r.SF_User__c!=null)
                {
                expObj.Reporting_To__c=empdata.get(expObj.Employee_ID__c).ReportingTo__r.SF_User__c;
                }
                if(empdata.get(expObj.Employee_ID__c).BU_Head__r.SF_User__c!=null)
                {
                expObj.Cost_center_manager__c=empdata.get(expObj.Employee_ID__c).BU_Head__r.SF_User__c;
                }
            }
        }
    }
    if(trigger.isafter && trigger.isupdate)
    {
        
    }
}