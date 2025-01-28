public without sharing class attendenceTimerCmpCtrl {
    public class customHandlerException extends Exception {}
    
    @auraEnabled(cacheable=true)
    public static Attendance_Activity__c getLoginDetails(){
        String userId = UserInfo.getUserId();
        Employee__c emp = [select Id,Work_Mode__c,Country__c  from Employee__c where SF_User__c =: userId and Active__c = true];
        
        Date todayDate = System.today();
        Date yeserdayDate = System.today()-1;
        DateTime currentDatetime = System.now();
        
        if(emp.Country__c == 'USA'){
            Datetime dt = System.now();
            String formattedDt = dt.format('yyyy-MM-dd HH:mm:ss', 'America/New_York');
            todayDate = Date.valueOf(formattedDt.substring(0, 10));
            yeserdayDate = todayDate-1;
            
            Datetime USACurrentDateTime = getTimeZone(formattedDt);
            currentDatetime = USACurrentDateTime.addMinutes(-1 * (TimeZone.getTimeZone('Asia/Kolkata').getOffset(USACurrentDateTime)/(1000 * 60)));//(TimeZone.getTimeZone('Asia/Kolkata').getOffset(USACurrentDateTime) / 1000);
            currentDatetime = getTimeZone(USACurrentDateTime.format('yyyy-MM-dd HH:mm:ss','GMT'));
            
        }
        System.debug('currentDatetime::'+currentDatetime);

        List<Attendance_Activity__c> activtidata = [select Id,Date__c,Attendance__r.Duration_In_Min_Date_and_Time__c,Action_Type__c,Attendance__c,Attendance__r.Duration_In_Hour_and_Minutes__c,Attendance__r.First_Check_In__c,Attendance__r.First_Check_In_Date_and_Time__c  from Attendance_Activity__c where Attendance__r.Date__c =: todayDate and Attendance__r.Employee_User__c =: userId order by Action_Date_and_Time__c desc limit 1];
        System.debug('activtidata::'+activtidata);
        if(activtidata.size() > 0){
            Datetime firstCheckIn = activtidata[0].Attendance__r.First_Check_In_Date_and_Time__c!= null ? activtidata[0].Attendance__r.First_Check_In_Date_and_Time__c.addhours(15) : null;

            if(firstCheckIn != null &&  currentDatetime >  firstCheckIn){
                return null;
            }else {
                return activtidata[0];
            }
            
        }else{
            List<Attendance_Activity__c> activityYesterday = [select Id,Date__c,Attendance__r.Duration_In_Min_Date_and_Time__c,Action_Type__c,Attendance__c,Attendance__r.Duration_In_Hour_and_Minutes__c,Attendance__r.First_Check_In__c,Attendance__r.First_Check_In_Date_and_Time__c  from Attendance_Activity__c where Attendance__r.Date__c =: yeserdayDate and Attendance__r.Employee_User__c =: userId order by Action_Date_and_Time__c desc limit 1];
            System.debug('activityYesterday::'+activityYesterday);
            if(activityYesterday.size() > 0){
                Datetime firstCheckIn = activityYesterday[0].Attendance__r.First_Check_In_Date_and_Time__c != null ? activityYesterday[0].Attendance__r.First_Check_In_Date_and_Time__c.addhours(15) : null;
                
                if(firstCheckIn != null && currentDatetime >  firstCheckIn){
                    return null;
                }else{
                    return activityYesterday[0];
                }
            }
            
            return null;
            /*if(activityYesterday.size() > 0  && Integer.ValueOf(activityYesterday[0].Attendance__r.Duration_In_Min_Date_and_Time__c.split(':')[0]) < 12 && activityYesterday[0].Action_Type__c == 'Check Out'){

}else{
return null;
}*/
        }
    }
    
    public static Datetime getTimeZone(String formattedDt){
        Datetime result = DateTime.newInstanceGmt(
                Date.valueOf(formattedDt.substring(0, 10)),
                Time.newInstance(
                    Integer.valueOf(formattedDt.substring(11, 13)),
                    Integer.valueOf(formattedDt.substring(14, 16)),
                    Integer.valueOf(formattedDt.substring(17, 19)),
                    0
                )
            );
        return result;
    }
    
    @auraEnabled(cacheable=true)
    public static Boolean getEmpDetails(){
        String userId = UserInfo.getUserId();
        
        Employee__c emp = [select Id,Type__c,AMS_Access_To_Contracters__c,Work_Mode__c,Country__c from Employee__c where SF_User__c =: userId and Active__c = true];
        
        if( emp.Country__c == 'India' && emp.Work_Mode__c == 'Work from Office'){
            return true;
        }else if(emp.Type__c == 'Partner Resource' && !emp.AMS_Access_To_Contracters__c){
            return true;
        }else{
            return false;
        }
    }
    
    @auraEnabled(cacheable=false)
    public static String updateCheckInOut(String atdId,String attendenceActivity){
        
        try{
            Employee__c emp = [select Id,Work_Mode__c,Country__c,SF_User__c,ReportingTo__c,ReportingTo__r.SF_User__c from Employee__c where SF_User__c =: UserInfo.getUserId()];
            if( emp.Country__c == 'India' && emp.Work_Mode__c == 'Work from Office'){
                return 'access denied';
            }
            
            Date todayDateBasedRegion = System.today();
            if(emp.Country__c == 'USA'){
                Datetime dt = System.now();
                String formattedDt = dt.format('yyyy-MM-dd HH:mm:ss', 'America/New_York');
                todayDateBasedRegion = Date.valueOf(formattedDt.substring(0, 10));
            }

            if(atdId != null){
                Attendance_Activity__c updateActivty = (Attendance_Activity__c) JSON.deserialize(attendenceActivity, Attendance_Activity__c.class);
                updateActivty.Action_Date_and_Time__c = DateTime.newInstance(todayDateBasedRegion, updateActivty.Action_Time__c);
                insert updateActivty;
                System.debug(updateActivty);
                return 'success';
            }else{
                Date todayDate = System.today();
                String userId = UserInfo.getUserId(); 
                List<Attendance__c> todayAtd =  [select Id,Date__c from Attendance__c where Date__c =: todayDateBasedRegion and Employee_User__c =: userId limit 1];
                
                if(todayAtd.size() == 1){
                    return 'Record Exist';
                }
                
                Attendance__c atd = new Attendance__c();
                atd.Date__c = System.today();
                atd.Employee_User__c = UserInfo.getUserId();
                atd.Employee__c = emp.Id;
                insert as system atd;
                System.debug('atd::'+atd);
                
                manualSharing(atd,emp,FALSE);
                
                Attendance_Activity__c updateActivty = (Attendance_Activity__c) JSON.deserialize(attendenceActivity, Attendance_Activity__c.class);
                updateActivty.Attendance__c = atd.Id;
                updateActivty.Action_Date_and_Time__c = DateTime.newInstance(todayDateBasedRegion, updateActivty.Action_Time__c);
                insert as system updateActivty;
                System.debug(updateActivty);
                return atd.id;
            }  
        }catch(Exception exp){
            throw new AuraHandledException(exp.getMessage());
        } 
    }
    
    public static void manualSharing(Attendance__c atd,Employee__c emp,Boolean fromBioMetric){
        List<Attendance__Share> allShare = new List<Attendance__Share>();
        
        if(fromBioMetric == TRUE && emp.SF_User__c != null){
            Attendance__Share atdShareCurrentUser = new Attendance__Share();
            atdShareCurrentUser.ParentId = atd.id;
            atdShareCurrentUser.UserOrGroupId = emp.SF_User__c ;
            atdShareCurrentUser.AccessLevel = 'Read';
            atdShareCurrentUser.RowCause = 'Manual';
            allShare.add(atdShareCurrentUser);            
        }
        
        String hrGroupId = [SELECT Id FROM Group WHERE Name = 'HR Team'][0]?.Id;
        if(hrGroupId != null){
            Attendance__Share atdShareHr = new Attendance__Share();
            atdShareHr.ParentId = atd.id;
            atdShareHr.UserOrGroupId = hrGroupId;
            atdShareHr.AccessLevel = 'Read';
            atdShareHr.RowCause = 'Manual';
            allShare.add(atdShareHr);
        }
        String leaderCRMIT = [SELECT Id FROM Group WHERE Name = 'LeaderShip'][0]?.Id;
        if(leaderCRMIT != null){
            Attendance__Share atdShareLeader = new Attendance__Share();
            atdShareLeader.ParentId = atd.id;
            atdShareLeader.UserOrGroupId = leaderCRMIT;
            atdShareLeader.AccessLevel = 'Read';
            atdShareLeader.RowCause = 'Manual';
            allShare.add(atdShareLeader);
        }
        if(emp.ReportingTo__r.SF_User__c != null){
            Attendance__Share atdShareRM = new Attendance__Share();
            atdShareRM.ParentId = atd.id;
            atdShareRM.UserOrGroupId = emp.ReportingTo__r.SF_User__c;
            atdShareRM.AccessLevel = 'Read';
            atdShareRM.RowCause = 'Manual';
            allShare.add(atdShareRM);
        }
        if(allShare.size() > 0){
            insert as system allShare;
        }
    }
    
    @auraEnabled
    public static List<Employee__c> employeDetails(String empName){       
        string data = '%' + empName + '%';
        
        return [select Id,Name,EmployeeID__c,ReportingTo__r.Name,BU_Head__r.Name,Designation__r.Name from Employee__c  where name Like : data and Active__c = true limit 7];
    }
    
    public static void updateModes(Set<Id> AllAtdIds){
        List<Attendance_Activity__c> AllActivity = [Select Id,Mode__c ,Action_Date_and_Time__c, Action_Type__c,Attendance__c from Attendance_Activity__c where Attendance__c IN:AllAtdIds];
        
        Map<Id,Attendance_Activity__c> maxRecord = new Map<Id,Attendance_Activity__c>();
        Map<Id,Attendance_Activity__c> minRecord = new Map<Id,Attendance_Activity__c>();
        
        for(Attendance_Activity__c actRecord : AllActivity){
            //Max
            if(actRecord.Action_Type__c == 'Check Out' && actRecord.Action_Date_and_Time__c != null){
                if(maxRecord.containsKey(actRecord.Attendance__c) && (actRecord.Action_Date_and_Time__c > maxRecord.get(actRecord.Attendance__c).Action_Date_and_Time__c)){
                    maxRecord.put(actRecord.Attendance__c,actRecord);
                }else if(!maxRecord.containsKey(actRecord.Attendance__c)){
                    maxRecord.put(actRecord.Attendance__c,actRecord);
                }
            }
            
            //Min
            if(actRecord.Action_Type__c == 'Check In' && actRecord.Action_Date_and_Time__c != null){
                if(minRecord.containsKey(actRecord.Attendance__c) && (actRecord.Action_Date_and_Time__c < minRecord.get(actRecord.Attendance__c).Action_Date_and_Time__c)){
                    minRecord.put(actRecord.Attendance__c,actRecord);
                }else if(!minRecord.containsKey(actRecord.Attendance__c)){
                    minRecord.put(actRecord.Attendance__c,actRecord);
                }
            }
        }
        
        List<Attendance__c> allAttendence = new List<Attendance__c>();
        
        for(Id AttendenceId : AllAtdIds){
            Attendance__c atd = new Attendance__c();
            atd.Id = AttendenceId;
            if(minRecord.containsKey(AttendenceId)){
                atd.First_Check_In_Mode__c = minRecord.get(AttendenceId).Mode__c;   
            }
            if(maxRecord.containsKey(AttendenceId)){
                atd.Last_Check_Out_Mode__c = maxRecord.get(AttendenceId).Mode__c;            
            }
            allAttendence.add(atd);   
        }
        if(allAttendence.size() > 0){
            update allAttendence;
            System.debug('allAttendence:::'+allAttendence);
        }
    }
}