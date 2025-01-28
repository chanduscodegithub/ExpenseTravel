public without sharing class pmsGoalSettingCmpCtrl {
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getReporteesOfCurrentUser() {
        try{
            Id userId = UserInfo.getUserId();
            String currentYear = String.valueOf(System.today().year());

            Map<Id, List<Employee__c>> reportingManagerMap = new Map<Id, List<Employee__c>>();

            Map<Id, Employee__c> empMap = new Map<Id, Employee__c>([Select Id, Name, ReportingTo__c, ReportingTo__r.Name, EmployeeID__c, ReportingTo__r.SF_User__c,(select Id, Name, Status__c from Goal_Settings__r where Appraisal_Cycle__r.QPR_Year__c =: currentYear limit 1) from Employee__c Where Type__c != 'Partner Resource' and Active__c = true]);
            
            List<String> myReportees = new List<String>();

            for (Employee__c emp : empMap.values()) {
                if(emp.ReportingTo__r.SF_User__c == userId){
                    myReportees.add(emp.Id);
                }
                if (emp.ReportingTo__c != null) {
                    if (!reportingManagerMap.containsKey(emp.ReportingTo__c)) {
                        reportingManagerMap.put(emp.ReportingTo__c, new List<Employee__c>());
                    }
                    reportingManagerMap.get(emp.ReportingTo__c).add(emp);
                }
            }

            List<Map<String, Object>> hierarchy = new List<Map<String, Object>>();
            for (Id managerId : myReportees) {
                Map<String, Object> managerNode = new Map<String, Object>{
                    'name' => empMap.containsKey(managerId) ? empMap.get(managerId).Name : managerId,
                     'EmployeeId' => empMap.containsKey(managerId) ? empMap.get(managerId).EmployeeID__c : 'Not Found',
                     'Status' => (empMap.containsKey(managerId) && empMap.get(managerId).Goal_Settings__r.size() > 0 ? empMap.get(managerId).Goal_Settings__r[0].Status__c : 'Not Submitted'),
                     '_children' => (reportingManagerMap.containsKey(managerId) && reportingManagerMap.get(managerId).size() > 0 ? getReportees(reportingManagerMap, managerId, empMap) : null)
                };
                hierarchy.add(managerNode);
            }
         return hierarchy;
        }catch(Exception exp){
            throw new AuraHandledException(exp.getMessage());
        }
    }

    private static List<Map<String, Object>> getReportees(Map<Id, List<Employee__c>> reportingManagerMap, Id managerId, Map<Id, Employee__c> empMap) {
        List<Map<String, Object>> reportees = new List<Map<String, Object>>();
        
        if (managerId != null && reportingManagerMap.containsKey(managerId)) {
            List<Employee__c> reporteeList = reportingManagerMap.get(managerId);
            for (Employee__c reportee : reporteeList) {
                Map<String, Object> reporteeNode = new Map<String, Object>{
                    'name' => empMap.containsKey(reportee.Id) ? empMap.get(reportee.Id).Name : reportee.Id,
                	'EmployeeId' => empMap.containsKey(reportee.Id) ? empMap.get(reportee.Id).EmployeeID__c : 'Not Found',
                 	'Status' => (empMap.containsKey(reportee.Id) && empMap.get(reportee.Id).Goal_Settings__r.size() > 0 ? empMap.get(reportee.Id).Goal_Settings__r[0].Status__c : 'Not Submitted'),
                	'_children' => (reportingManagerMap.containsKey(reportee.Id) && reportingManagerMap.get(reportee.Id).size() > 0 ? getReportees(reportingManagerMap, reportee.Id, empMap) : null)
                };
                reportees.add(reporteeNode);
            }
        }
        
        return reportees;
    }
    
    @AuraEnabled
    public static String createOrUpdateGoalSetting(String arrayResult,String empRecordString,String action){
        try{
            Employee__c empRecord = (Employee__c) JSON.deserialize(empRecordString, Employee__c.class);
            
            Id userId = UserInfo.getUserId();
            
            Boolean validationVerified = false;
            Boolean loopEnter = false;
            
            if(action != 'saveAsDraft' && userId == empRecord.SF_User__c && (empRecord.Business_Function__c != 'Human Resource' && empRecord.Business_Function__c != 'Sales' && empRecord.Business_Function__c != 'Presales' && empRecord.Business_Function__c != 'Finance & Accounts' && empRecord.Business_Function__c != 'Marketing' &&  empRecord.Business_Function__c != 'IT Administration' && empRecord.Business_Function__c != 'Corporate') && empRecord.Corporate_Band__c != 'Band 4'){
                loopEnter = true;
                
                list<Career_Goal_Line_Items__c> cdpItems = [SELECT Id FROM Career_Goal_Line_Items__c WHERE Career_Goal_and_Training_Plan__r.Employee_Name__c =: empRecord.Id];
                
                list<Recommended_Certification__c> recoCertItem=[Select id FROM Recommended_Certification__c Where Career_Goal_and_Training_Plan__r.Employee_Name__c =: empRecord.Id];
                
                list<Training_Plan__c> enablementItem=[SELECT Id FROM Training_Plan__c WHERE Career_Goal_and_Training_Plan__r.Employee_Name__c  =: empRecord.Id];
                
                if(cdpItems.size() > 0 && recoCertItem.size() > 0 && enablementItem.size() > 0){
                    validationVerified = true;
                }
            }
            
            if(loopEnter == true && validationVerified == false){
                return 'No Career';
            }else if(arrayResult != null){
                List<Goal_Setting__c> upsertRecords = (List<Goal_Setting__c>) JSON.deserialize(arrayResult, List<Goal_Setting__c>.class); 
                //System.debug('upsertRecords:::'+upsertRecords);
                upsert upsertRecords;
                return 'success';
            }
            return 'fail';
        }catch(Exception exp){
            System.debug('exp:::'+exp);
            throw new AuraHandledException(exp.getMessage());
        }
    }
    
    @AuraEnabled
    public static String handleKRAWeightageCtrl(String arrayResult){
        try{
            if(arrayResult != null){
                List<Goal_Setting__c> updateRecords = (List<Goal_Setting__c>) JSON.deserialize(arrayResult, List<Goal_Setting__c>.class); 
                //System.debug('updateRecords:::'+updateRecords);
                upsert updateRecords;
                return 'success';
            }
            return 'fail';
        }catch(Exception exp){
            System.debug('exp:::'+exp);
            throw new AuraHandledException(exp.getMessage());
        }
    }
    
    @AuraEnabled
    public static String rejectGoalSettingCtrl(String arrayResult){
        try{
            if(arrayResult != null){
                List<Goal_Setting__c> updateRecords = (List<Goal_Setting__c>) JSON.deserialize(arrayResult, List<Goal_Setting__c>.class); 
                //System.debug('updateRecords:::'+updateRecords);
                update updateRecords;
                return 'success';
            }
            return 'fail';
        }catch(Exception exp){
            System.debug('exp:::'+exp);
            throw new AuraHandledException(exp.getMessage());
        }
    }
    
    @AuraEnabled
    public static String upsertKraDiscription(String arrayResult){
        try{
            if(arrayResult != null){
                Goal_Setting__c updateRecords = (Goal_Setting__c) JSON.deserialize(arrayResult, Goal_Setting__c.class); 
                System.debug('updateRecords:::'+updateRecords);
                upsert updateRecords;
                return 'success';
            }
            return 'fail';
        }catch(Exception exp){
            System.debug('exp:::'+exp);
            throw new AuraHandledException(exp.getMessage());
        }
    }
    
    /*@AuraEnabled(cacheable=true)
public static List<Employee__c> getReportiesOfCurrentUser(){
Id userId = UserInfo.getUserId();

String currentYear = String.valueOf(system.today().year());

List<Employee__c> allRMEmp = [Select Id,Name,ReportingTo__c,BU_Head__c,ReportingTo__r.Name,EmployeeID__c,BU_Head__r.SF_User__c,ReportingTo__r.SF_User__c,(select Id,Name,Status__c from Goal_Settings__r where Appraisal_Cycle__r.QPR_Year__c =: currentYear limit 1) from Employee__c Where Type__c != 'Partner Resource' and Active__c = true and (ReportingTo__r.SF_User__c =:userId or BU_Head__r.SF_User__c =:userId)];
}*/
    
    @AuraEnabled(cacheable=true)
    public static wrapReportingManagerAndCCM getReportiesAndCCM(){
        
        try{
            Id userId =UserInfo.getUserId();
            
            String currentYear = String.valueOf(system.today().year());
            
            List<Employee__c> allRMEmp = [Select Id,Name,ReportingTo__c,BU_Head__c,ReportingTo__r.Name,EmployeeID__c,BU_Head__r.SF_User__c,ReportingTo__r.SF_User__c,(select Id,Name,Status__c from Goal_Settings__r where Appraisal_Cycle__r.QPR_Year__c =: currentYear limit 1) from Employee__c Where (Type__c != 'Partner Resource' or Name = 'Mickey Bedi') and Active__c = true and (ReportingTo__r.SF_User__c =:userId or BU_Head__r.SF_User__c =:userId) and Status__c = 'Active']; // Where ReportingTo__c =:userId or BU_Head__c =:userId
            
            wrapReportingManagerAndCCM wrapdata = new wrapReportingManagerAndCCM();
            
            if(allRMEmp.size() > 0){
                List<Employee__c> reportingManager = new List<Employee__c>();
                List<Employee__c> ccManager = new List<Employee__c>();
                
                wrapdata.noRM = true;
                wrapdata.noCCM = true;
                
                for(Employee__c emp : allRMEmp){
                    if(emp.ReportingTo__c != null && emp.ReportingTo__r.SF_User__c == userId){
                        wrapdata.noRM = false;
                        reportingManager.add(emp);
                    }if(emp.BU_Head__c != null && emp.BU_Head__r.SF_User__c == userId){
                        wrapdata.noCCM = false;
                        ccManager.add(emp);
                    }
                }
                
                wrapdata.ReportingManager = reportingManager;
                wrapdata.ReportingCCM = ccManager;
                return wrapdata;
            }else{
                wrapdata.noRM = true;
                wrapdata.noCCM = true;
                wrapdata.ReportingManager = null;
                wrapdata.ReportingCCM = null;
                return wrapdata;
            }
        }catch(Exception exp){
            System.debug('exp:::'+exp);
            throw new AuraHandledException(exp.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static parentWrap getGoalSettingDetails(String empId,String ManagerDetails){
        
        String currentYear = String.valueOf(system.today().year());
        Appraisal__c appraisalCycle = [Select id, Current_Cycle__c,Total_KPI_Limit__c from Appraisal__c  where QPR_Year__c =: currentYear limit 1];
        
        Employee__c emp = new Employee__c();
        
        if(!String.isBlank(empId)){
            emp = [SELECT Id,Business_Function__c,Name,Email_ID__c,EmployeeID__c,Grade__c,Corporate_Band__c,Designation__r.Name,ReportingTo__c,ReportingTo__r.Name,ReportingTo__r.EmployeeID__c,BU_Head__c,BU_Head__r.Name,BU_Head__r.Corporate_Band__c,BU_Head__r.Grade__c,Country__c,SF_User__c FROM Employee__c where EmployeeID__c =: empId];
        }else{
            emp = [SELECT Id,Business_Function__c,Name,Email_ID__c,EmployeeID__c,Grade__c,Corporate_Band__c,Designation__r.Name,ReportingTo__c,ReportingTo__r.Name,ReportingTo__r.EmployeeID__c,BU_Head__c,BU_Head__r.Name,BU_Head__r.Corporate_Band__c,BU_Head__r.Grade__c,Country__c,SF_User__c FROM Employee__c where SF_User__c =: UserInfo.getUserId() and Status__c = 'Active'];
        }
        
        String band = emp.Corporate_Band__c.replace('Band ','B');
        
        List<Goal_Repository__c> empKRA = [SELECT Id,Name,Maximum_KRA_Wightage__c,Description__c,(select Id,Name,Status__c,KRA_Weightage__c,Is_KRA_Weightage_Edited__c,KRA_Status__c,Is_KRA_Edited__c,Is_KRA_Status_Is_Locked__c,KRA_Discription__c,Total_KRA_Weightage__c,Description__c,KPI_1__c, KPI_2__c, KPI_3__c, KPI_4__c, KPI_5__c, KPI_1_Weightage__c, KPI_2_Weightage__c, KPI_3_Weightage__c, KPI_4_Weightage__c, KPI_5_Weightage__c  from Goal_Settings__r where Appraisal_Cycle__c =: appraisalCycle.Id and Employee__c =: emp.Id) from Goal_Repository__c where Band__c =:band and level__c =: emp.Grade__c and Business_Function__c =: emp.Business_Function__c and Status__c='Active' and Year__c=:currentYear order by KRA_order__c asc];
        
        List<wrapGoalSetting> allChildWrap = new List<wrapGoalSetting>();
        
        for(Goal_Repository__c kra : empKRA){
            wrapGoalSetting  goalRecord = new wrapGoalSetting();
            goalRecord.goalRespository = kra;
            goalRecord.checkNoZeroKPISize = kra.Goal_Settings__r.size() > 0 ? TRUE : FALSE;
            goalRecord.editable = FALSE;
            goalRecord.showGrKRADiscription = FALSE;
            goalRecord.goalSettingId = '';
            goalRecord.KRAWieghtage = 0;
            goalRecord.MaximunKRAWieghtage = kra.Maximum_KRA_Wightage__c;
            if(goalRecord.checkNoZeroKPISize == TRUE){
                goalRecord.goalSettingId = kra.Goal_Settings__r[0].Id;
                goalRecord.KRAWieghtage = kra.Goal_Settings__r[0].Total_KRA_Weightage__c;
                goalRecord.goalSetting = kra.Goal_Settings__r[0];
                if(kra.Goal_Settings__r[0].Is_KRA_Weightage_Edited__c){
                    goalRecord.MaximunKRAWieghtage = kra.Goal_Settings__r[0].KRA_Weightage__c;
                }
            }
            allChildWrap.add(goalRecord);
        }
        
        List<Goal_Setting__c> goalSettingOfReportingManager = [Select Id,Status__c from Goal_Setting__c where Appraisal_Cycle__c =: appraisalCycle.Id and Employee__c =: emp.ReportingTo__c limit 1];
        
        Boolean checkValidation = false;
        if(empKRA.size() > 0 && empKRA[0].Goal_Settings__r.size() > 0){
            if(String.isBlank(ManagerDetails)){
                if((goalSettingOfReportingManager.size() > 0 && goalSettingOfReportingManager[0].Status__c == 'CCM Approved')){
                    checkValidation = (empKRA[0].Goal_Settings__r[0].Status__c != null && (empKRA[0].Goal_Settings__r[0].Status__c != 'Not Submitted' && empKRA[0].Goal_Settings__r[0].Status__c != 'Manager Rejected' && empKRA[0].Goal_Settings__r[0].Status__c != 'CCM Rejected') ? TRUE : FALSE) ;
                }else{ 
                    checkValidation = true;
                }
            }else if(!String.isBlank(ManagerDetails) && ManagerDetails == 'RM'){
                checkValidation = (empKRA[0].Goal_Settings__r[0].Status__c == 'Submitted' ? FALSE : TRUE);
            }else if(!String.isBlank(ManagerDetails) && ManagerDetails == 'CCM'){
                checkValidation = (empKRA[0].Goal_Settings__r[0].Status__c == 'Manager Approved' ? FALSE : TRUE);
            }else if(!String.isBlank(ManagerDetails) && ManagerDetails == 'PreviewRM'){
                checkValidation = TRUE;
            }else{
                checkValidation = TRUE;
            }
        }else if(String.isBlank(empId) && goalSettingOfReportingManager.size() > 0 && goalSettingOfReportingManager[0].Status__c == 'CCM Approved'){
            checkValidation = FALSE;
        }else{
            checkValidation = TRUE;
        }
        
        //special case under band 4
        if(String.isBlank(empId) && emp.ReportingTo__r.Name == 'Vinod N Reddy'){
            checkValidation = (empKRA.size() > 0 && empKRA[0].Goal_Settings__r.size() > 0 && empKRA[0].Goal_Settings__r[0].Status__c != null && empKRA[0].Goal_Settings__r[0].Status__c != 'Not Submitted' ? TRUE : FALSE);
        }
        
        
        parentWrap allWrap = new parentWrap();
        allWrap.emp = emp;
        if(emp.ReportingTo__c != null && emp.ReportingTo__r.Name == 'Vinod N Reddy'){
            allWrap.reportingManagerEmpId = [select EmployeeID__c from Employee__c where Designation__r.Name = 'Chief Operating Officer'].EmployeeID__c;
        }else if(emp.ReportingTo__c != null && ManagerDetails != 'PreviewRM'){
            allWrap.reportingManagerEmpId = emp.ReportingTo__r.EmployeeID__c;
        }else{
            allWrap.reportingManagerEmpId = empId;
        }
        allWrap.apprailCycle = appraisalCycle;
        allWrap.checkCCMAndRM = (emp.ReportingTo__c == emp.BU_Head__c ? TRUE : FALSE);
        allWrap.goalRespotaryvalidation = checkValidation;
        allWrap.hideManagerGoal = (!String.isBlank(ManagerDetails) && ManagerDetails == 'PreviewRM' && empKRA[0].Goal_Settings__r.size() > 0 && empKRA[0].Goal_Settings__r[0].Status__c == 'CCM Approved') ? TRUE : FALSE; 
        //allWrap.hideKRAWeightage = (empKRA[0].Goal_Settings__r.size() > 0 && empKRA[0].Goal_Settings__r[0].size() > 0 && ) empKRA[0].Goal_Settings__r[0].Is_KRA_Weightage_Edited__c ? TRUE : FALSE;
        allWrap.employeeStatus = (empKRA.size() > 0 && empKRA[0].Goal_Settings__r.size() > 0 && empKRA[0].Goal_Settings__r[0].Status__c != null) ? empKRA[0].Goal_Settings__r[0].Status__c : 'Not Submitted';
        allWrap.childRecords = allChildWrap;
        return allWrap;
    }
    
    public class wrapReportingManagerAndCCM{
        @AuraEnabled
        public Boolean noRM;
        
        @AuraEnabled
        public Boolean noCCM;
        
        @AuraEnabled
        public List<Employee__c> ReportingManager;
        
        @AuraEnabled
        public List<Employee__c> ReportingCCM;
    }
    
    
    //Wrapper  Details of Emp
    public class parentWrap{
        @AuraEnabled
        public Employee__c emp;
        
        @AuraEnabled
        public String reportingManagerEmpId;
        
        @AuraEnabled
        public Appraisal__c apprailCycle;
        
        @AuraEnabled
        public Boolean checkCCMAndRM;
        
        @AuraEnabled
        public Boolean goalRespotaryvalidation;
        
        @AuraEnabled
        public Boolean hideManagerGoal;
        
        @AuraEnabled
        public String employeeStatus;
        
        @AuraEnabled
        public List<wrapGoalSetting> childRecords;
    }
    
    public class wrapGoalSetting{ 
        @AuraEnabled
        public Goal_Repository__c goalRespository;
        
        @AuraEnabled
        public Decimal KRAWieghtage;
        
        @AuraEnabled
        public Decimal MaximunKRAWieghtage;
        
        @AuraEnabled
        public Boolean checkNoZeroKPISize;
        
        @AuraEnabled
        public Boolean editable;
        
        @AuraEnabled
        public Boolean showGrKRADiscription;
        
        @AuraEnabled
        public String goalSettingId;
        
        @AuraEnabled
        public Goal_Setting__c goalSetting;
    }    
}