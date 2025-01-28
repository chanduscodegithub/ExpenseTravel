trigger EmployeeTrigger on Employee__c (after insert,after update, before insert, before update) {
    System.debug('********** Employee Trigger - START **********');
    List<Employee__c> listEmployeesTrigger = Trigger.New;
    List<Service_Resource__c> listServiceResources = new List<Service_Resource__c>();
    String CURRYEAR = String.valueOf(System.today().year());
    //String CURRYEAR = String.valueOf(2023);
    Regional_Leave_Limit__c traineeLimitANZ = [SELECT Employee_Status__c, Region__c, Bereavement_Leave__c, Sick_Leave__c, Casual_Leave__c, Privilege_Paid_Leave__c, Paternity_Leave__c, Maternity_Leave__c, Celebration_Leave__c, Restricted_Holiday__c, Loss_of_Pay_LOP__c, Long_Leave__c, CarryForward__c, Carry_Forward_Sick_Leave__c, Carry_Forward_Celebration_Leave__c, Carry_Forward_Privilege_Leave__c FROM Regional_Leave_Limit__c WHERE Region__c = 'ANZ' AND Year__c =:CURRYEAR AND Employee_Status__c = 'FTE(1+ - 10 years)' WITH SYSTEM_MODE limit 1];
    Regional_Leave_Limit__c traineeLimitUS = [SELECT Employee_Status__c, Region__c, Bereavement_Leave__c, Sick_Leave__c, Casual_Leave__c, Privilege_Paid_Leave__c, Paternity_Leave__c, Maternity_Leave__c, Celebration_Leave__c, Restricted_Holiday__c, Loss_of_Pay_LOP__c, Long_Leave__c, CarryForward__c, Carry_Forward_Sick_Leave__c, Carry_Forward_Celebration_Leave__c, Carry_Forward_Privilege_Leave__c FROM Regional_Leave_Limit__c WHERE Region__c = 'US' AND Year__c =:CURRYEAR AND Employee_Status__c = 'FTEUS(3 or 3 - 4 years)' WITH SYSTEM_MODE limit 1];
    if(Trigger.isBefore && Trigger.isInsert){
        System.debug('********* IsBefore & IsInsert - START ********');
        for(Employee__c eachEmp : listEmployeesTrigger){
            eachEmp.Geo_Date_of_Joining__c = eachEmp.Region__c == 'ANZ' ? eachEmp.DateofJoin__c : eachEmp.Geo_Date_of_Joining__c;
        }
        System.debug('********* IsBefore & IsInsert - END ********');
    }
    
    if(Trigger.isAfter && Trigger.isInsert){
        System.debug('********* IsAfter & IsInsert - START ********');
        Map<Id, Employee__c> newJoineeANZMap = new Map<Id, Employee__c>();
        Map<Id, Employee__c> newJoineeUSMap = new Map<Id, Employee__c>();
        for(Employee__c eachEmp : listEmployeesTrigger){
            Service_Resource__c tempSR = new Service_Resource__c();
            tempSR.Name = eachEmp.Name;
            tempSR.Active__c = eachEmp.Active__c;
            tempSR.Employee_Id__c = eachEmp.EmployeeID__c;
            tempSR.Email__c = eachEmp.Email_ID__c;
            tempSR.Gender__c = eachEmp.Gender__c;
            tempSR.Mobile__c = eachEmp.MobileNo__c;
            tempSR.Covid_19_Safe__c = true;
            tempSR.Region__c = 'APAC';
            listServiceResources.add(tempSR);
            if(eachEmp.Region__c == 'ANZ'){
                newJoineeANZMap.put(eachEmp.Id, eachEmp);
            }
            if(eachEmp.Region__c == 'US'){
               newJoineeUSMap.put(eachEmp.Id, eachEmp);
            }
        }
        if(newJoineeANZMap.size() > 0){
            AMSAllTriggerHandlerANZ.balanceDataInsertionNew(traineeLimitANZ, newJoineeANZMap);
        }
        if(newJoineeUSMap.size() > 0){
            AMSAllTriggerHandlerUS.balanceDataInsertionNew(traineeLimitUS, newJoineeUSMap);
        }
        System.debug('********* Is After & Is Insert - END ********');
    }
    
    if(Trigger.isBefore && Trigger.isUpdate){
        System.debug('********* IsBefore & IsUpdate - START ********');
        Map<Id, Employee__c> oldMapOfEmployee = (Map<Id, Employee__c>)Trigger.oldMap;
        for(Employee__c eachEmp : listEmployeesTrigger){
            if(eachEmp.Geo_Date_of_Joining__c == null && eachEmp.Region__c != oldMapOfEmployee.get(eachEmp.Id).Region__c && (eachEmp.Region__c == 'ANZ' || eachEmp.Region__c == 'US')){
                eachEmp.Geo_Date_of_Joining__c.addError('It is mandatory to update Geo Joining Date for Australia/US Region Employees');
            }
        }
        System.debug('********* IsBefore & IsUpdate - END ********');
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        System.debug('********* IsAfter & IsUpdate - START ********');
        
        Set<String> empEmailIds = new Set<String>();
        Set<Id> employeeMadePermanentId = new Set<Id>();
        Set<String> employeeRegions = new Set<String>();
        List<Employee__c> allEmployees = (List<Employee__c>)Trigger.new;
        Map<Id, Employee__c> oldMapOfEmployee = (Map<Id, Employee__c>)Trigger.oldMap;
        Map<Id, Employee__c> newJoineeANZMap = new Map<Id, Employee__c>();
        Map<Id, Employee__c> newJoineeUSMap = new Map<Id, Employee__c>();
        Map<Id, Employee__c> traineeToFTEMap = new Map<Id, Employee__c>();
        Map<Id, Employee__c> traineeUSToFTEUSMap = new Map<Id, Employee__c>();
        Map<Id, Employee__c> FTEToSeniorMap = new Map<Id, Employee__c>();
        Map<Id, Employee__c> FTEToSeniorMapUS = new Map<Id, Employee__c>();
        Map<Id, Employee__c> updateFTEToSeniorMap = new Map<Id, Employee__c>();
        for(Employee__c eachEmp : allEmployees){
            if(eachEmp.Type__c == 'Permanent' && oldMapOfEmployee.get(eachEmp.Id).Type__c == 'Probationer'){
                employeeMadePermanentId.add(eachEmp.Id);
                employeeRegions.add(eachEmp.Region__c);
            }
            if(eachEmp.Region__c != oldMapOfEmployee.get(eachEmp.Id).Region__c && eachEmp.Region__c == 'ANZ'){
                newJoineeANZMap.put(eachEmp.Id, eachEmp);
            }
            if(eachEmp.Region__c != oldMapOfEmployee.get(eachEmp.Id).Region__c && eachEmp.Region__c == 'US'){
                newJoineeUSMap.put(eachEmp.Id, eachEmp);
            }
            //Code block for seniority check in Australia 2023
            
            /*if(eachEmp.ANZ_Workforce_Category__c != oldMapOfEmployee.get(eachEmp.Id).ANZ_Workforce_Category__c && eachEmp.ANZ_Workforce_Category__c == 'FTEUS(3 or 3 - 4 years)' && eachEmp.Region__c == 'US'){
                traineeUSToFTEUSMap.put(eachEmp.Id, eachEmp);
            }
            if(eachEmp.ANZ_Workforce_Category__c != oldMapOfEmployee.get(eachEmp.Id).ANZ_Workforce_Category__c && eachEmp.ANZ_Workforce_Category__c == 'SeniorUS(4-4+ years)' && eachEmp.Region__c == 'US'){
                FTEToSeniorMapUS.put(eachEmp.Id, eachEmp);
            }
            if(eachEmp.ANZ_Workforce_Category__c != oldMapOfEmployee.get(eachEmp.Id).ANZ_Workforce_Category__c && eachEmp.ANZ_Workforce_Category__c == 'FTE(1+ - 10 years)' && eachEmp.Region__c == 'ANZ'){
                traineeToFTEMap.put(eachEmp.Id, eachEmp);
            }*/
            /*if(eachEmp.Onsite_Experience__c == 11 && eachEmp.Onsite_Experience__c != oldMapOfEmployee.get(eachEmp.Id).Onsite_Experience__c  && eachEmp.Region__c == 'ANZ'){
                FTEToSeniorMap.put(eachEmp.Id, eachEmp);
            }
            Decimal remainder = 0;
            if(eachEmp.Onsite_Experience__c != 0 && eachEmp.Onsite_Experience__c != null){
                Decimal firstResult = eachEmp.Onsite_Experience__c / 10; 
                Decimal flooredResult = math.floor(firstResult);
                Decimal flooredProduct = flooredResult * 10;
                remainder = eachEmp.Onsite_Experience__c - flooredProduct; 
            }
            if(remainder == 1 && eachEmp.Onsite_Experience__c > 11 && eachEmp.Onsite_Experience__c != oldMapOfEmployee.get(eachEmp.Id).Onsite_Experience__c  && eachEmp.Region__c == 'ANZ'){
                updateFTEToSeniorMap.put(eachEmp.Id, eachEmp);
            }*/
        }
        
        for(Employee__c eachEmp : listEmployeesTrigger){
            if(empEmailIds.contains(eachEmp.Email_ID__c)==false){
                empEmailIds.add(eachEmp.Email_ID__c);
            }
        }
        System.debug('empEmailIds - '+empEmailIds);
        
        List<Service_Resource__c> listServiceResourcesRecords = [Select Id,Email__c from Service_Resource__c where Email__c IN :empEmailIds];
        System.debug('listServiceResourcesRecords - '+listServiceResourcesRecords);
        
        for(Employee__c eachEmp : listEmployeesTrigger){
            for(Service_Resource__c eachSR : listServiceResourcesRecords){
                if(eachEmp.Email_ID__c == eachSR.Email__c){
                    Boolean isUpdate = false;
                    Service_Resource__c tempSR = new Service_Resource__c();
                    tempSR.Id = eachSR.Id;
                    if(Trigger.OldMap.get(eachEmp.Id).Active__c != eachEmp.Active__c){
                        tempSR.Active__c = eachEmp.Active__c;
                        isUpdate = true;
                    }
                    if(Trigger.OldMap.get(eachEmp.Id).Email_ID__c != eachEmp.Email_ID__c){
                        tempSR.Email__c = eachEmp.Email_ID__c;
                        isUpdate = true;
                    }
                    if(Trigger.OldMap.get(eachEmp.Id).Name != eachEmp.Name){
                        tempSR.Name = eachEmp.Name;
                        isUpdate = true;
                    }
                    if(Trigger.OldMap.get(eachEmp.Id).MobileNo__c != eachEmp.MobileNo__c){
                        tempSR.Mobile__c = eachEmp.MobileNo__c;
                        isUpdate = true;
                    }
                    if(Trigger.OldMap.get(eachEmp.Id).EmployeeID__c != eachEmp.EmployeeID__c){
                        tempSR.Employee_Id__c = eachEmp.EmployeeID__c;
                        isUpdate = true;
                    }
                    if(isUpdate){
                        listServiceResources.add(tempSR); 
                    }
                }                
            }
        }
        if(employeeMadePermanentId.size()>0){
            EmployeeProbationToPermanent.probationToPermanent(employeeMadePermanentId, employeeRegions);
        }
        if(newJoineeANZMap.size() > 0){
            AMSAllTriggerHandlerANZ.balanceDataInsertionNew(traineeLimitANZ, newJoineeANZMap);
        }
        /*if(traineeToFTEMap.size() > 0){
            AMSAllTriggerHandlerANZ.newBalanceOnTraineeToFTE(traineeToFTEMap);
        }*/
        /*if(FTEToSeniorMap.size() > 0){
            AMSAllTriggerHandlerANZ.insertSeniorEmpBal(FTEToSeniorMap);
        }
        if(updateFTEToSeniorMap.size() > 0){
            AMSAllTriggerHandlerANZ.updateSeniorEmpLongLeave(updateFTEToSeniorMap);
        }*/
        if(newJoineeUSMap.size() > 0){
            AMSAllTriggerHandlerUS.balanceDataInsertionNew(traineeLimitUS, newJoineeUSMap);
        }
        /*if(traineeUSToFTEUSMap.size() > 0){
            AMSAllTriggerHandlerUS.newBalanceOnTraineeUSToFTEUS(traineeUSToFTEUSMap);
        }
        if(FTEToSeniorMapUS.size() > 0){
            AMSAllTriggerHandlerUS.insertSeniorEmpBalUS(FTEToSeniorMapUS);     
         }*/
        System.debug('********* IsAfter & IsUpdate - END ********');
    }
    if(listServiceResources.size()>0){
        upsert listServiceResources;
    }
    System.debug('********** Employee Trigger - END **********');
}