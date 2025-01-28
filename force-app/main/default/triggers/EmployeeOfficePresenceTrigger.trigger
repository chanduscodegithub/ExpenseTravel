trigger EmployeeOfficePresenceTrigger on Employee_Office_Presence__c (after insert, after update) {
	
    List<Employee_Office_Presence__c> employeeOfficePresenceList = new List<Employee_Office_Presence__c>();
    List<Service_Resource__c> srList = new List<Service_Resource__c>();
    
    if(Trigger.isAfter && Trigger.isInsert){
        for(Employee_Office_Presence__c eachEOP : employeeOfficePresenceList){
            Service_Resource__c srTemp = new Service_Resource__c();
            srTemp.Id = eachEOP.Employee__c;
            srTemp.At_Office_Today__c = eachEOP.Employee_Office_Presence__c;
            srList.add(srTemp);
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        for(Employee_Office_Presence__c eachEOP : employeeOfficePresenceList){
            if(Trigger.OldMap.get(eachEOP.Id).Employee_Office_Presence__c != eachEOP.Employee_Office_Presence__c && eachEOP.Date__c==Date.today()){
                Service_Resource__c srTemp = new Service_Resource__c();
                srTemp.Id = eachEOP.Employee__c;
                srTemp.At_Office_Today__c = eachEOP.Employee_Office_Presence__c;
                srList.add(srTemp);
            }
        }
    }
    
    if(srList.size()>0){
        update srList;
    }
    
}