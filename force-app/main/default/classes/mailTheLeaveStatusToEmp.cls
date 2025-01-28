global class mailTheLeaveStatusToEmp implements Database.Batchable<sObject> {
    final static Map<String, String> regionMapping = new Map<String, String>{'India' => 'IND','Austrailia' => 'ANZ','USA' => 'US'};
        final static String CURRYEAR = String.valueOf(System.today().year());
    Map<String,List<Holiday__c>> holidayMapResult;
    public mailTheLeaveStatusToEmp(){
        holidayMapResult = new Map<String,List<Holiday__c>>();
        List<AggregateResult> aggrVersion = [SELECT Year__c, MAX(Version__c) FROM Holiday_Calendar__c WHERE Year__c =:CURRYEAR AND Active__c = true GROUP BY Year__c];
        if(aggrVersion.size() > 0){
            Decimal maxVersion = (Decimal)aggrVersion[0].get('expr0');
            List<Holiday_Calendar__c> regionCalendar = [SELECT Id, Region__c, Year__c, (SELECT Name, Date__c, Holiday_Calendar__c, Holiday_Type__c,Holiday_Description__c FROM Holidays__r  WHERE Date__c = YESTERDAY and Holiday_Type__c != 'Restricted Holiday' ORDER BY Date__c ASC) FROM Holiday_Calendar__c WHERE Year__c = :CURRYEAR AND Version__c = :maxVersion AND Active__c = true ];
            for(Holiday_Calendar__c holiday : regionCalendar){
                holidayMapResult.put(holiday.Region__c,holiday.Holidays__r.size() > 0 ? holiday.Holidays__r : new List<Holiday__c>{});
            }
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //List<String> empIds = new List<String>{'a0G19000003zNyOEAU'};
            return Database.getQueryLocator([select Id,Name,Avoid_AMS_Email__c,Country__c,Status__c,SF_User__c,EmployeeID__c,ReportingTo__r.SF_User__c,Email_ID__c,Corporate_Band__c  from Employee__c where Status__c = 'Active' and Type__c != 'Partner Resource' and SF_User__c != null and SF_User__r.IsActive != false]);
    }
    
    global void execute(Database.BatchableContext BC, List<Employee__c> empList) {
        try{
            Map<Id,Employee__c> employeeMapResult = new Map<Id,Employee__c>();
            List<Attendance__Share> allShare = new List<Attendance__Share>();
            Map<Id,List<Employee_Leave__c>> empLeaveSync = new Map<Id,List<Employee_Leave__c>>();
            
            for(Employee__c emp : empList){
                employeeMapResult.put(emp.Id,emp);
            }
            
            Map<Id,Employee_Leave__c> allLeaveList = new Map<Id,Employee_Leave__c>([Select Id,Start_Date__c,End_Date__c,Employee__c,Employee__r.Name,Applied_By__c,Duration__c,Status__c from Employee_Leave__c where Employee__c IN:employeeMapResult.keySet() 
                                                                                    and (Start_Date__c <= YESTERDAY  AND End_Date__c >= YESTERDAY) and Status__c != 'Rejected']);
            
            for(Employee_Leave__c empLeave : allLeaveList.values()){
                if(empLeaveSync.containsKey(empLeave.Employee__c)){
                    empLeaveSync.get(empLeave.Employee__c).add(empLeave);
                }else{
                    empLeaveSync.put(empLeave.Employee__c,new List<Employee_Leave__c>{empLeave}); 
                }
            }
            
            List<Attendance__c> allAtdList = [Select Id, Name, Status_Of_Day__c, Employee__c,Employee__r.Name from Attendance__c where Date__c = YESTERDAY and Employee__c IN: employeeMapResult.keySet()];
            
            Map<String,Attendance__c> atdMap = new Map<String,Attendance__c>();
            List<Attendance__c> createAttendance = new List<Attendance__c>();
            List<Messaging.SingleEmailMessage> sendEmail = new List<Messaging.SingleEmailMessage>();
            
            for(Attendance__c atd : allAtdList){
                atdMap.put(atd.Employee__c,atd);
            }
            
            for(Employee__c emp : empList){
                if(atdMap.containsKey(emp.Id) && emp.Avoid_AMS_Email__c == false &&emp.Corporate_Band__c != 'Band 4' && (atdMap.get(emp.Id).Status_Of_Day__c == 'HALF DAY' || atdMap.get(emp.Id).Status_Of_Day__c == 'ABSENT')){
                    Messaging.SingleEmailMessage maildata = mailContent(atdMap.get(emp.Id),emp);
                    sendEmail.add(maildata);
                }else if(!atdMap.containsKey(emp.Id)){
                    Boolean validateleaveOrHoliday = false;
                    Attendance__c atd = new Attendance__c();
                    atd.Employee__c = emp.Id;
                    atd.Date__c = System.today() - 1;
                    atd.Employee_User__c = emp.SF_User__c;
                    if(empLeaveSync.containskey(emp.Id) && empLeaveSync.get(emp.Id).size() > 0){
                        atd.Holiday_Status__c = 'On Leave';
                        validateleaveOrHoliday = true;
                    }else if(emp.Country__c != null  && holidayMapResult.containsKey(regionMapping.get(emp.Country__c)) && holidayMapResult.get(regionMapping.get(emp.Country__c)).size() > 0){
                        atd.Holiday_Status__c = 'Public Holiday';
                        validateleaveOrHoliday = true;
                    }
                    //atd.OwnerId = emp.SF_User__c;
                    createAttendance.add(atd);
                    
                    if(!validateleaveOrHoliday && emp.Corporate_Band__c != 'Band 4' && emp.Avoid_AMS_Email__c == false){
                        Messaging.SingleEmailMessage maildata = mailContent(null,emp);
                        sendEmail.add(maildata);
                    }  
                }
            }
            
            if(sendEmail.size() > 0){
                Messaging.sendEmail(sendEmail);
            }
            
            if(createAttendance.size() > 0){
                insert createAttendance;
                List<Attendance__Share> AtdMaualSharingRecord = manualSharing(createAttendance,employeeMapResult);
                if(AtdMaualSharingRecord.size() > 0){
                    insert AtdMaualSharingRecord;
                }
            }
            
        }catch(Exception e){
            Log__c log = new Log__c(Method_Name__c='mailTheLeaveStatusToEmp', Class_Name__c='mailTheLeaveStatusToEmp', Line_Number__c=e.getLineNumber(), Reason__c=e.getMessage());
            insert log;
        }
    }   
    
    global void finish(Database.BatchableContext BC) {
        Log__c log = new Log__c(Method_Name__c='mailTheLeaveStatusToEmp', Class_Name__c='mailTheLeaveStatusToEmp', Reason__c='Batch Id as Follows '+BC.getJobId());
        insert log;
    }
    
    public static Messaging.SingleEmailMessage mailContent(Attendance__c atd, Employee__c emp){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<String> to = new List<String>();
        //List<String> cc = new List<String>();
        
        OrgWideEmailAddress owAddressHR = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address='hrteam@crmit.com' limit 1];
        email.setOrgWideEmailAddressId(owAddressHR.Id);
        
        to.add(emp.Email_ID__c);
        //cc.add('aneesh.vemireddy@crmit.com');
        //cc.add('rajgopal.bv@crmit.com');
        email.setToAddresses(to);
        //email.setCcAddresses(cc);
        
        DateTime yourDate = Datetime.now()-1;
        String dateOutput = yourDate.format('dd-MM-yyyy');
        //System.debug('Debug: '+dateOutput);
        
        email.setSubject('You are absent');
        
        Date absentDate = System.today()-1;
        String body = 'Hi ';
        body += emp.Name + ',<br/><br/>' + 'You are marked as absent in CRMIT community portal on '+ dateOutput + ' the deatils are below.<br/><br/>';
        
        body += 'Status : '+ 'ABSENT <br/>';
        body += 'Start Date : '+ dateOutput +'<br/>';
        body += 'End Date : '+ dateOutput +'<br/>';
        body += 'Total No.of Days : '+ (atd != null ? (atd.Status_Of_Day__c == 'HALF DAY' ? '0.5' : '1.0') : '1.0') +'<br/><br/>';
        body += 'This is an auto generated email. Please do not reply.';
        email.setHtmlBody(body);
        
        return email;
    }
    
    public static List<Attendance__Share> manualSharing(List<Attendance__c> attendenceRecords,Map<Id,Employee__c> employeeMapResult){
        List<Attendance__Share> allShare = new List<Attendance__Share>();
        String leaderCRMIT = [SELECT Id FROM Group WHERE Name = 'LeaderShip'][0]?.Id;
        String hrGroupId = [SELECT Id FROM Group WHERE Name = 'HR Team'][0]?.Id;
        for(Attendance__c sharingAtd : attendenceRecords){
            
            if(employeeMapResult.get(sharingAtd.Employee__c).ReportingTo__r.SF_User__c != null){
                Attendance__Share atdShareRM = new Attendance__Share();
                atdShareRM.ParentId = sharingAtd.id;
                atdShareRM.UserOrGroupId = employeeMapResult.get(sharingAtd.Employee__c).ReportingTo__r.SF_User__c;
                atdShareRM.AccessLevel = 'Read';
                atdShareRM.RowCause = 'Manual';
                allShare.add(atdShareRM);
            }
            
            Attendance__Share atdShareEmp = new Attendance__Share();
            atdShareEmp.ParentId = sharingAtd.id;
            atdShareEmp.UserOrGroupId = employeeMapResult.get(sharingAtd.Employee__c).SF_User__c;
            atdShareEmp.AccessLevel = 'Read';
            atdShareEmp.RowCause = 'Manual';
            allShare.add(atdShareEmp);
            
            Attendance__Share atdShareLeaders = new Attendance__Share();
            atdShareLeaders.ParentId = sharingAtd.id;
            atdShareLeaders.UserOrGroupId = leaderCRMIT;
            atdShareLeaders.AccessLevel = 'Read';
            atdShareLeaders.RowCause = 'Manual';
            allShare.add(atdShareLeaders);
            
            Attendance__Share atdShareHR = new Attendance__Share();
            atdShareHR.ParentId = sharingAtd.id;
            atdShareHR.UserOrGroupId = hrGroupId;
            atdShareHR.AccessLevel = 'Read';
            atdShareHR.RowCause = 'Manual';
            allShare.add(atdShareHR);
        }
        return allShare;
    }
}