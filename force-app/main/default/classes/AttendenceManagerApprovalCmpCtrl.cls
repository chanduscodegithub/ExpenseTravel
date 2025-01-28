public without sharing class AttendenceManagerApprovalCmpCtrl {
    
    public AttendenceManagerApprovalCmpCtrl(ApexPages.StandardController controller){
        
    }
        
    
    @Auraenabled(cacheable=false)
    public static void createTimeSheetActivity(String data,String managerComment){
        
        try{
            List<Attendance_Activity__c> activityRecords = (List<Attendance_Activity__c>) JSON.deserialize(data, List<Attendance_Activity__c>.class);
            System.debug('activityRecords:::'+activityRecords);
            
            if(activityRecords.size() > 0){
                //insert activityRecords;
                //System.debug('activityRecords:::'+activityRecords);
                
                List<Attendance__c> updateStatus = new List<Attendance__c>();
                Set<Id> atdIds = new Set<Id>();
                for(Attendance_Activity__c actvity : activityRecords){
                    atdIds.add(actvity.Attendance__c);
                }
                System.debug('atdIds:::'+atdIds);
                Set<String> attdIds = new Set<String>();
                Map<Id,Attendance__c> allApprovedAtd = new Map<Id,Attendance__c>([select Id,Date__c,Regularized_check_In__c,Regularized_check_out__c from Attendance__c Where Id IN:atdIds]);
                
                for(Attendance_Activity__c actvity : activityRecords){
                    if(actvity.Action_Type__c == 'Check Out' && actvity.Action_Time__c != null){
                        Integer checkOutHour = Integer.valueOf(String.valueOf(allApprovedAtd.get(actvity.Attendance__c).Regularized_check_out__c).split(':')[0]);
                        Integer checkInHour = Integer.valueOf(String.valueOf(allApprovedAtd.get(actvity.Attendance__c).Regularized_check_In__c).split(':')[0]);
                        if(checkOutHour >= checkInHour && checkOutHour <= 23){
                            actvity.Action_Date_and_Time__c = Datetime.newInstance(allApprovedAtd.get(actvity.Attendance__c).Date__c,actvity.Action_Time__c);               
                        }else{
                            actvity.Action_Date_and_Time__c = Datetime.newInstance(allApprovedAtd.get(actvity.Attendance__c).Date__c.addDays(1),actvity.Action_Time__c);  
                        }
                    }else{
                        actvity.Action_Date_and_Time__c = Datetime.newInstance(allApprovedAtd.get(actvity.Attendance__c).Date__c,actvity.Action_Time__c);               
                    }
                    
                    //attendence Upadte
                    if(!attdIds.contains(actvity.Attendance__c)){
                        Attendance__c atd = new Attendance__c();
                        atd.Id = actvity.Attendance__c;
                        atd.Regularization_Status__c = 'Approved';
                        if(managerComment != null){
                            atd.Manager_Comment__c = managerComment;
                        }
                        attdIds.add(actvity.Attendance__c);
                        updateStatus.add(atd);
                    }
                }
                
                System.debug('activityRecords:::'+activityRecords);
                insert activityRecords;
                System.debug('updateStatus:::'+updateStatus);
                if(updateStatus.size() > 0){
                    update updateStatus;
                }
            }
            
        }catch(Exception exp){
            throw new AuraHandledException(exp.getMessage());
        }
    }
    
    @Auraenabled(cacheable=false)
    public static void rejectTimeSheetActivity(String data){
        try{
            List<Attendance__c> activityRecords = (List<Attendance__c>) JSON.deserialize(data, List<Attendance__c>.class);
            System.debug('activityRecords:::'+activityRecords);
            
            if(activityRecords.size() > 0){
                update activityRecords;
                System.debug('activityRecords:::'+activityRecords);
            }
            
        }catch(Exception exp){
            throw new AuraHandledException(exp.getMessage());
        }
    }
    
    @Auraenabled(cacheable=true)
    public static List<wrapWaitingForApproval> getApprovalDetails(){
        try{  
            List<wrapWaitingForApproval> appdResult = new List<wrapWaitingForApproval>();
            String userId = UserInfo.getUserId(); 
            
            for(Attendance__c atd : [select Id,Date__c,Duration_In_Hour_and_Minutes__c,Regularized_Duration_Hour_and_Min__c,is_Regularized__c,Employee__r.Name,Employee__r.ReportingTo__r.Name, First_Check_In__c, Last_Check_Out__c,Regularized_check_In__c,Regularized_check_out__c,Regularized_Duration_Min__c from Attendance__c where Regularization_Status__c = 'Approved' and Employee__r.ReportingTo__r.SF_User__c =: userId order by createdDate desc]){
                wrapWaitingForApproval wfa = new wrapWaitingForApproval();
                wfa.atdId = atd.Id;
                wfa.status = 'Approved';
                wfa.empName = atd.Employee__r.Name;
                wfa.attendenceDay = atd.Date__c;
                wfa.checkInOld = atd.First_Check_In__c != null ? DateTime.newInstance(atd.Date__c,atd.First_Check_In__c) : null ;
                wfa.checkOutOld = atd.Last_Check_Out__c != null ? DateTime.newInstance(atd.Date__c,atd.Last_Check_Out__c) : null;
                wfa.durationOld = atd.Duration_In_Hour_and_Minutes__c != null ? atd.Duration_In_Hour_and_Minutes__c : 'Absent';
                appdResult.add(wfa);
            }
            return appdResult;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }        
    }
    
    @Auraenabled(cacheable=true)
    public static List<wrapWaitingForApproval> getWfaDetails(){
        try{
            List<wrapWaitingForApproval> wfaResult = new List<wrapWaitingForApproval>();
            String userId = UserInfo.getUserId(); 
            
            for(Attendance__c atd : [select Id,Date__c,Employee_Comment__c,Reason_for_Regularization__c,Regularization_Status__c,Duration_In_Hour_and_Minutes__c,Regularized_Duration_Hour_and_Min__c,is_Regularized__c,Employee__r.Name,Employee__r.ReportingTo__r.Name, First_Check_In__c, Last_Check_Out__c,Regularized_check_In__c,Regularized_check_out__c,Regularized_Duration_Min__c from Attendance__c where Regularization_Status__c = 'Waiting For Approval'and Employee__r.ReportingTo__r.SF_User__c =: userId  order by createdDate desc]){
                wrapWaitingForApproval wfa = new wrapWaitingForApproval();
                wfa.atdId = atd.Id;
                wfa.status = 'Waiting For Approval';
                wfa.empName = atd.Employee__r.Name;
                wfa.attendenceDay = atd.Date__c;
                wfa.checkInOld = atd.First_Check_In__c != null ? DateTime.newInstance(atd.Date__c,atd.First_Check_In__c) : null ;
                wfa.checkInNew = DateTime.newInstance(atd.Date__c,atd.Regularized_check_In__c);
                wfa.checkOutOld = atd.Last_Check_Out__c != null ? DateTime.newInstance(atd.Date__c,atd.Last_Check_Out__c) : null;
                wfa.checkOutNew = DateTime.newInstance(atd.Date__c,atd.Regularized_check_out__c);
                wfa.durationOld = atd.Duration_In_Hour_and_Minutes__c != null ? atd.Duration_In_Hour_and_Minutes__c : 'Absent';
                wfa.durationNew = atd.Regularized_Duration_Hour_and_Min__c;
                wfa.Reason = atd.Reason_for_Regularization__c;
                wfa.empComment = atd.Employee_Comment__c;
                wfaResult.add(wfa);
            }
            return wfaResult;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }  
    }
    
    @Auraenabled(cacheable=true)
    public static List<wrapWaitingForApproval> getRejectedDetails(){
        try{
            List<wrapWaitingForApproval> rejectedResult = new List<wrapWaitingForApproval>();
            String userId = UserInfo.getUserId(); 

            for(Attendance__c atd : [select Id,Date__c,Manager_Comment__c,Employee_Comment__c,Reason_for_Regularization__c,Regularization_Status__c,Duration_In_Hour_and_Minutes__c,Regularized_Duration_Hour_and_Min__c,is_Regularized__c,Employee__r.Name,Employee__r.ReportingTo__r.Name, First_Check_In__c, Last_Check_Out__c,Regularized_check_In__c,Regularized_check_out__c,Regularized_Duration_Min__c from Attendance__c where Regularization_Status__c = 'Rejected' and Employee__r.ReportingTo__r.SF_User__c =: userId order by createdDate desc]){
                wrapWaitingForApproval wfa = new wrapWaitingForApproval();
                wfa.atdId = atd.Id;
                wfa.status = 'Rejected';
                wfa.empName = atd.Employee__r.Name;
                wfa.attendenceDay = atd.Date__c;
                wfa.checkInOld = atd.First_Check_In__c != null ? DateTime.newInstance(atd.Date__c,atd.First_Check_In__c) : null ;
                wfa.checkInNew = DateTime.newInstance(atd.Date__c,atd.Regularized_check_In__c);
                wfa.checkOutOld = atd.Last_Check_Out__c != null ? DateTime.newInstance(atd.Date__c,atd.First_Check_In__c) : null;
                wfa.checkOutNew = DateTime.newInstance(atd.Date__c,atd.Regularized_check_out__c);
                wfa.durationOld = atd.Duration_In_Hour_and_Minutes__c != null ? atd.Duration_In_Hour_and_Minutes__c : 'Absent';
                wfa.durationNew = atd.Regularized_Duration_Hour_and_Min__c;
                wfa.Reason = atd.Reason_for_Regularization__c;
                wfa.empComment = atd.Employee_Comment__c;
                wfa.mangComment = atd.Manager_Comment__c;
                rejectedResult.add(wfa);
            }
            return rejectedResult;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }  
    }
    
    public class wrapWaitingForApproval{
        @auraEnabled
        public String atdId;
        @auraEnabled
        public String empName;
        @auraEnabled
        public String status;
        @auraEnabled
        public Date attendenceDay;
        @auraEnabled
        public datetime checkInOld;
        @auraEnabled
        public datetime checkInNew;
        @auraEnabled
        public datetime checkOutOld;
        @auraEnabled
        public datetime checkOutNew;
        @auraEnabled
        public String durationOld;
        @auraEnabled
        public String durationNew;
        @auraEnabled
        public String Reason;
        @auraEnabled
        public String empComment;
        @auraEnabled
        public String mangComment;
    }
    
}