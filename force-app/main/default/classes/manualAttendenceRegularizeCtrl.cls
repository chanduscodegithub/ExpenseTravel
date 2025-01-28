public without sharing class manualAttendenceRegularizeCtrl {
    
     @auraEnabled(cacheable=true)
    public static Attendance__c getNameDetails(String atdId){
        if(atdId != null){
            return [select Id,Name,Regularization_Status__c,Employee__r.ReportingTo__r.SF_User__c From Attendance__c Where Id =:atdId];
        }
        return null;
    }
    
    @auraEnabled(cacheable=true)
    public static Attendance__c getRecordDetails(String atdId,String userId){
        try{
            Attendance__c atd =  [select Id,Date__c,Status_Of_Day__c,Regularization_Status__c,Duration_In_Min_Date_and_Time__c,Employee__r.SF_User__c,Employee__r.Name,Employee__r.ReportingTo__r.Name, First_Check_In__c,First_Check_In_Date_and_Time__c,Last_Check_Out_Date_and_Time__c,Last_Check_Out__c from Attendance__c where Id =: atdId];   
            if(userId == atd.Employee__r.SF_User__c){
                return atd;
            }else{
                return null;
            }
        }catch(Exception exp){
            throw new AuraHandledException(exp.getMessage());
        }
    }
    
    @auraEnabled(cacheable=false)
    public static void updateRegularizedDate(String data){
        try{
            Attendance__c updateRegularizedRecords = (Attendance__c) JSON.deserialize(data, Attendance__c.class);
            update updateRegularizedRecords;
        }catch(Exception exp){
            throw new AuraHandledException(exp.getMessage());
        }  
    }
    
    @auraEnabled(cacheable=false)
    public static String approveRejectCtrl(String recId,String Status,String managerComment){
        try{
            if(Status == 'approve'){
                Attendance__c atd  = [select Id,Regularized_check_In__c, Regularized_check_out__c, Date__c,Regularization_Status__c from Attendance__c where Id =: recId];
                
                List<Attendance_Activity__c> activityRecords = new List<Attendance_Activity__c>();
                
                Attendance_Activity__c atdCheckIn = new Attendance_Activity__c();
                atdCheckIn.Attendance__c = recId;
                atdCheckIn.Action_Time__c = atd.Regularized_check_In__c;
                atdCheckIn.Action_Type__c = 'Check In';
                atdCheckIn.Action_Date_and_Time__c = Datetime.newInstance(atd.Date__c,atd.Regularized_check_In__c);
                atdCheckIn.Mode__c = 'Regularized';
                activityRecords.add(atdCheckIn);
                
                Attendance_Activity__c atdCheckOut = new Attendance_Activity__c();
                atdCheckOut.Attendance__c = recId;
                atdCheckOut.Action_Time__c = atd.Regularized_check_out__c;
                atdCheckOut.Action_Type__c = 'Check Out';
                atdCheckOut.Action_Date_and_Time__c = Datetime.newInstance(atd.Date__c,atd.Regularized_check_out__c);
                atdCheckOut.Mode__c = 'Regularized';
                activityRecords.add(atdCheckOut);
                
                insert activityRecords;
                
                atd.Regularization_Status__c = 'Approved';
                if(!String.isBlank(managerComment)){
                    atd.Manager_Comment__c = managerComment;
                }
                update atd;
                
                return 'successApproved';

            }else if(Status == 'reject'){
                Attendance__c atd = new Attendance__c();
                atd.Id = recId;
                atd.Regularization_Status__c = 'Rejected';
                if(!String.isBlank(managerComment)){
                    atd.Manager_Comment__c = managerComment;
                }
                update atd;
                return 'successRejected';
            }
            return null;
            
        }catch(Exception exp){
            throw new AuraHandledException(exp.getMessage());
        }  
    }
    
    /*@auraEnabled(cacheable=false)
    public static String createRegularizedDate(String data){
        try{
            Attendance__c createRecords = (Attendance__c) JSON.deserialize(data, Attendance__c.class);
            
            createRecords.Employee__c = [select Id from Employee__c where SF_User__c =: createRecords.Employee_User__c].Id;
            System.debug('createRecords:::'+createRecords);
            insert createRecords;
            
            return createRecords.Id;
        }catch(Exception exp){
            throw new AuraHandledException(exp.getMessage());
        }  
    }*/
}