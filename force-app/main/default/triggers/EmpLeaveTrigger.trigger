trigger EmpLeaveTrigger on Employee_Leave__c (before insert, before update, after insert) {
    
    System.debug('********** Emp Leave Trigger - START **********');
    
    if(Trigger.isBefore && Trigger.isInsert){
        System.debug('********* IsBefore & IsInsert - START ********');
        List<Employee_Leave__c> newLeaves = Trigger.New;
        List<String> employee = new List<String>();
        for(Employee_Leave__c eachLeave : newLeaves){
            employee.add(eachLeave.Employee__c);
        }
        AMSAllTriggerHandler.empBalFieldUpdate(newLeaves, employee);
        System.debug('********* IsBefore & IsInsert - END ********');
    }
    
    
    /*if(Trigger.isBefore && Trigger.isUpdate){
        System.debug('********* IsBefore & IsUpdate - START ********');
        Map<Id, Employee_Leave__c> newEmpLeaveList = (Map<Id,Employee_Leave__c>) Trigger.newMap;
        Map<Id,Employee_Leave__c> oldMapLeave = new Map<Id,Employee_Leave__c>([SELECT Id, Employee_Leave_Balance__c, Employee__c, Region__c, Start_Date__c, Duration__c, Status__c  FROM Employee_Leave__c WHERE Id In: newEmpLeaveList.keySet()]);
        List<String> employeeList = new List<String>();
        List<String> YearList = new List<String>();
        List<String> RegionList = new List<String>();
        List<String> RejectedemployeeList = new List<String>();
        List<String> RejectedYearList = new List<String>();
        List<String> RejectedRegionList = new List<String>();
        Map<Id,Employee_Leave__c> rejectedEmpLeaves = new Map<Id,Employee_Leave__c>();
        for(Id eachId : newEmpLeaveList.keySet()){
            if(oldMapLeave.get(eachId).Duration__c != newEmpLeaveList.get(eachId).Duration__c){
                employeeList.add(newEmpLeaveList.get(eachId).Employee__c);
                YearList.add(newEmpLeaveList.get(eachId).Year__c);
                RegionList.add(newEmpLeaveList.get(eachId).Region__c);
            }
            System.debug('newEmpLeaveList.get(eachId).Status__c' + newEmpLeaveList.get(eachId).Status__c);
            System.debug('oldMapLeave.get(eachId).Status__c'+oldMapLeave.get(eachId).Status__c);
            if(oldMapLeave.get(eachId).Status__c != newEmpLeaveList.get(eachId).Status__c && newEmpLeaveList.get(eachId).Status__c == 'Rejected'){
                employeeList.add(newEmpLeaveList.get(eachId).Employee__c);
                YearList.add(newEmpLeaveList.get(eachId).Year__c);
                RegionList.add(newEmpLeaveList.get(eachId).Region__c);
                rejectedEmpLeaves.put(eachId,newEmpLeaveList.get(eachId));
            }
        }
        AMSAllTriggerHandler.leaveBalanceUpdate(newEmpLeaveList, oldMapLeave, employeeList, YearList, RegionList);
        if(rejectedEmpLeaves.size() > 0){
          AMSAllTriggerHandler.leaveBalanceUpdateOnRejection(rejectedEmpLeaves, employeeList, YearList, RegionList);  
        }
        System.debug('********* IsBefore & IsUpdate - END ********');
    }*/
    
    if(Trigger.isAfter && Trigger.isInsert){
        System.debug('********* IsAfter & IsInsert - START ********');
        List<Employee_Leave__c> empLeaveList = Trigger.new;
        List<String> employeeList = new List<String>();
        List<String> YearList = new List<String>();
        List<String> RegionList = new List<String>();
        for(Employee_Leave__c eachLeave : empLeaveList){
            employeeList.add(eachLeave.Employee__c);
            YearList.add(eachLeave.Year__c);
            RegionList.add(eachLeave.Region__c);
        }
        System.debug('empLeaveList'+empLeaveList);
        System.debug('employeeList'+employeeList);
        System.debug('RegionList'+RegionList);
        System.debug('YearList'+YearList);
        AMSAllTriggerHandler.leaveBalanceUpdateOnInsert(empLeaveList, employeeList, YearList, RegionList);
        System.debug('********* IsAfter & IsInsert - END ********');
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        System.debug('********* IsAfter & IsUpdate - START ********');
        Map<Id, Employee_Leave__c> newEmpLeaveList = (Map<Id,Employee_Leave__c>) Trigger.newMap;
        Map<Id,Employee_Leave__c> oldMapLeave = new Map<Id,Employee_Leave__c>([SELECT Id, Employee_Leave_Balance__c, Employee__r.Type__c, Reporting_Manager__r.Name, Employee__c, Region__c, Start_Date__c, Duration__c, Status__c, Leave_Type__c FROM Employee_Leave__c WHERE Id In: newEmpLeaveList.keySet()]);
        List<String> employeeList = new List<String>();
        List<String> YearList = new List<String>();
        List<String> RegionList = new List<String>();
        Map<Id, Employee_Leave__c> approvedEmpLeaves = new Map<Id, Employee_Leave__c>();
        Map<Id,Employee_Leave__c> rejectedEmpLeaves = new Map<Id,Employee_Leave__c>();
        for(Id eachId : newEmpLeaveList.keySet()){
            System.debug('newEmpLeaveList.get(eachId).Status__c' + newEmpLeaveList.get(eachId).Status__c);
            System.debug('oldMapLeave.get(eachId).Status__c'+oldMapLeave.get(eachId).Status__c);
            if(oldMapLeave.get(eachId).Status__c != newEmpLeaveList.get(eachId).Status__c && newEmpLeaveList.get(eachId).Status__c == 'Rejected'){
                employeeList.add(newEmpLeaveList.get(eachId).Employee__c);
                YearList.add(newEmpLeaveList.get(eachId).Year__c);
                RegionList.add(newEmpLeaveList.get(eachId).Region__c);
                rejectedEmpLeaves.put(eachId,newEmpLeaveList.get(eachId));
            }
            else if(oldMapLeave.get(eachId).Status__c != newEmpLeaveList.get(eachId).Status__c && newEmpLeaveList.get(eachId).Status__c == 'Approved' && newEmpLeaveList.get(eachId).Informed_Users__c != null && newEmpLeaveList.get(eachId).Informed_Users__c != ''){
                approvedEmpLeaves.put(eachId,newEmpLeaveList.get(eachId));
            }
        }
        if(rejectedEmpLeaves.size() > 0){
            AMSAllTriggerHandler.leaveBalanceUpdateOnRejection(rejectedEmpLeaves, employeeList, YearList, RegionList);
        }
        if(approvedEmpLeaves.size() > 0){
            AMSAllTriggerHandler.emailInformedUsers(approvedEmpLeaves, oldMapLeave);
        }
        System.debug('********* IsAfter & IsUpdate - END ********');
    }
    
    System.debug('********** Emp Leave Trigger - END **********');
}