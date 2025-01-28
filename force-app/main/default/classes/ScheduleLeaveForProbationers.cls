global class ScheduleLeaveForProbationers implements Schedulable {
    // Define variables to store current date information
    Date currentDate = System.today();
    Integer currentDay = currentDate.day();
    Integer currentMonth = currentDate.month();
    Integer currentYear = currentDate.year();
    
    global void execute(SchedulableContext SC) {
        try {
            
            
            // Query for Employee_Leave_Balance__c records for probationer employees in India
            List<Employee_Leave_Balance__c> toBeUpdatedEmpBalList = new List<Employee_Leave_Balance__c>();
            
            // Query Employee_Leave_Balance__c records and related Employee__c records
            Map<Id, Employee_Leave_Balance__c> probationerEmpMapIndia = new Map<Id, Employee_Leave_Balance__c>([
                SELECT Id, Privilege_Paid_Leave_in_days__c, Casual_Leave__c, Probationer_Casual_Leave_in_days__c, Probationer_Paid_Leave_in_days__c,
                Employee__r.Geo_Date_of_Joining__c, Employee__r.DateofJoin__c, Employee__r.Id
                FROM Employee_Leave_Balance__c
                WHERE Employee_Status__c = 'Probationer'
                AND Region__c = 'IND'
                AND Active__c = true
            ]);
            
            
            // Process each Employee_Leave_Balance__c record
            for(Id eachId : probationerEmpMapIndia.keySet()) {
                // Retrieve Employee_Leave_Balance__c record from the map
                Employee_Leave_Balance__c empLeaveBal = probationerEmpMapIndia.get(eachId);
                
                // Retrieve related Employee__c record
                Employee__c emp = empLeaveBal.Employee__r;
                List<Employee_Leave__c> empLeaveRec = [SELECT Id, Employee__c, Employee_Leave_Balance__c, Leave_Type__c, Duration__c 
                                                       FROM Employee_Leave__c 
                                                       WHERE Employee__c = :emp.Id 
                                                       AND Status__c IN ('Applied', 'Approved')];
                // Variables to calculate leave duration

                Decimal paidTotalduration=0;
                Decimal casualTotalduration = 0;
                Decimal monthsBetween = 0;
                
                // Reset probationer leave balances
                empLeaveBal.Probationer_Casual_Leave_in_days__c =0;
                empLeaveBal.Probationer_Paid_Leave_in_days__c =0;
                
                // Calculate total leave duration
                system.debug('empLeaverec'+empLeaverec);
                for(Employee_Leave__c empleave : empLeaverec ){
                    if(empleave.Leave_Type__c == 'Privilege/Paid Leave'){
                        paidTotalduration += empleave.Duration__c;
                        
                        //LeaveType = empleave.Leave_Type__c;
                    } 
                    system.debug('paidTotalduration'+paidTotalduration);
                    if(empleave.Leave_Type__c == 'Casual Leave'){
                        casualTotalduration += empleave.Duration__c;
                    }
                    
                }
                // Calculate months between joining date and current date
                monthsBetween =  emp.DateofJoin__c.monthsBetween(system.today());
                
                // Process leave balances based on join date and current date
                if(emp.DateofJoin__c.month() == currentMonth && emp.DateofJoin__c.day() < 15) {
                    system.debug('Current month <15 employee>>>>>>>>>>>>>>>>>');
                    empLeaveBal.Privilege_Paid_Leave_in_days__c += 1;
                    empLeaveBal.Casual_Leave__c += 1;
                    empLeaveBal.Probationer_Casual_Leave_in_days__c += 1;
                    empLeaveBal.Probationer_Paid_Leave_in_days__c += 1;
                } else if(emp.DateofJoin__c.month() == currentMonth && emp.DateofJoin__c.day() >= 15){
                   // No changes for employees joining after 15th
                    empLeaveBal.Privilege_Paid_Leave_in_days__c = 0;
                    empLeaveBal.Casual_Leave__c = 0;
                    empLeaveBal.Probationer_Casual_Leave_in_days__c = 0;
                    empLeaveBal.Probationer_Paid_Leave_in_days__c = 0;
                    // No changes for employees joining after 15th
                } else if(emp.DateofJoin__c.month() != currentMonth){
                    // Calculate leave duration for previous months
                    // MonthDuration = currentMonth - emp.DateofJoin__c.month();
                    // monthsBetween =  emp.DateofJoin__c.monthsBetween(system.today());
                    // Reset leave balances and calculate for previous months
                    empLeaveBal.Probationer_Casual_Leave_in_days__c =0;
                    empLeaveBal.Probationer_Paid_Leave_in_days__c =0;
                    empLeaveBal.Privilege_Paid_Leave_in_days__c = 0;
                    empLeaveBal.Casual_Leave__c = 0;
                    
                   // Calculate leave balances for previous months
                    if(emp.DateofJoin__c.day() < 15) {
                        monthsBetween += 1;
                    } else if(emp.DateofJoin__c.day()>= 15){
                        monthsBetween =monthsBetween;
                        // No changes for employees joining after 15th
                    }
                    
                    empLeaveBal.Probationer_Casual_Leave_in_days__c = monthsBetween;
                    empLeaveBal.Probationer_Paid_Leave_in_days__c = monthsBetween;
                    empLeaveBal.Privilege_Paid_Leave_in_days__c = monthsBetween - paidTotalduration;
                    empLeaveBal.Casual_Leave__c = monthsBetween - casualTotalduration;
                    // empLeaveBal.id=eachId;
                    toBeUpdatedEmpBalList.add(empLeaveBal);
                    
                } else{
                    // No changes for other cases
                    system.debug('not met any criteria');
                }
                //toBeUpdatedEmpBalList.add(empLeaveBal);
                
            }
            
            // Update the modified leave balance records
            if(toBeUpdatedEmpBalList.size()>0) {
                update toBeUpdatedEmpBalList;
            }
        } catch(Exception e) {
            // Log any exceptions
            System.debug('Issue in ScheduleLeaveForProbationers execute method');
            System.debug('Error Message: ' + e.getMessage());
            System.debug('Line Number: ' + e.getLineNumber());
            throw e;
        }
    }
}