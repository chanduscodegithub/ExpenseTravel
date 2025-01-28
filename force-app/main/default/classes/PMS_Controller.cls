/**
* @description       : A class for Performance Rating Management System Controller
* @author            : Vinay Chandra G
* @group             : 
* @last modified on  : 
* @last modified by  : 
* Modifications Log   
* Test Class Name    : 
* Ver   Date         Author                               Modification
* -------------------------------------------------------------------------
* 1.0	07-07-2023  Vinay Chandra G    Initial Version (PMS Phase-I implementation)
* 2.0   01-09-2023  Vinay Chandra G    Added methods related to the implementation of tree structure (PMS Phase-II implementation)
**/

public without sharing class PMS_Controller {

    public static Map<String,List<String>> empEmailTree = new Map<String,List<String>>();//Added as a part of PMS-II
    public static string currentURL;
    /*
    *Static Block to set the current URL.
    */
    static{
    try{
            currentURL = ConnectApi.Communities.getCommunity(Network.getNetworkId()).siteUrl+'/s/avishkaar-manager-review';
            System.debug('~~currentURL'+currentURL);
        }catch(Exception ex){
            System.debug('~~Error Msg -- '+ex.getMessage());
            System.debug('~~Error Line No. -- '+ex.getLineNumber());
            currentURL=URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/n/Performance_Management_System';
            System.debug('~~currentURL'+currentURL);

        }
  }
    
    /**
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * Added as a part of PMS-II
  * Get all employees data from the Performance Rating and maps Manager Emails with the list
  * of there reporties Employee emails.
  * ────────────────────────────────────────────────────────────────────────────────────────────────
  * @return   Void    
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
    public static void employeeTree(){
        System.debug('~~URL--'+URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/n/avishkaar-manager-review');
        try{
            List<Performance_Rating__c> currentYearPerformanceRatings = [select id,Status__c,Employee__r.Name,Employee__r.Email_ID__c,Employee__c, Manager__r.Email_ID__c from Performance_Rating__c where CreatedDate = THIS_YEAR];
            for(Performance_Rating__c eachPR: currentYearPerformanceRatings){
                if(empEmailTree!=null && empEmailTree.containsKey(eachPR.Manager__r.Email_ID__c)){
                    empEmailTree.get(eachPR.Manager__r.Email_ID__c).add(eachPR.Employee__r.Email_ID__c);
                }
                else{
                    empEmailTree.put(eachPR.Manager__r.Email_ID__c, new String[]{eachPR.Employee__r.Email_ID__c});
                }
            }
             System.debug('empEmailTree'+empEmailTree.get('pradipta.sahu@crmit.com'));
        }
      
        catch(Exception ex){
            System.debug('~~Error Msg -- '+ex.getMessage());
            System.debug('~~Error Line No. -- '+ex.getLineNumber());
        }
    }
    /**
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * Added as a part of PMS-II
  * Based on the current login user emails this will return the tree structure of the employees
  * ────────────────────────────────────────────────────────────────────────────────────────────────
  * @return   hierarchyWrapper    return hierarchyWrapper wrapper class
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
    @auraEnabled
    public static String getPRData(String prName, String userId){
        List<Performance_Rating__c> prData = [select id,Name from Performance_Rating__c Where Name =: prName and (Employee__r.ReportingTo__r.SF_User__c =: userId OR Employee__r.ReportingTo__r.ReportingTo__r.SF_User__c =: userId)];
        //List<Performance_Rating__c> prData = [select id,Name from Performance_Rating__c Where Name =: prName];
        system.debug('prData'+prData);
        if(prData.size() == 1){
            return prData[0].Id;
        }else{
            return null;
        }
    }
    @AuraEnabled
    public static hierarchyWrapper getAllLoginUserEmployees(){
        employeeTree();
        String currentEmail = userInfo.getUserEmail();
        List<String> listEmpEmails = new List<String>();
        Integer i=0;
        if(empEmailTree.containsKey(currentEmail)){
            System.debug('~~empEmailTree.get(currentEmail) '+empEmailTree.get(currentEmail));
            //This loop will iterate all the manager emails from empEmailTree.
            while(true){
                for(String eachEmail : empEmailTree.get(currentEmail)){
                    if(!listEmpEmails.contains(eachEmail)){
                        listEmpEmails.add(eachEmail);
                    }
                }
                if(i>=listEmpEmails.size()){
                    break;
                }else{
                    //i++;
                    //This loop will chek if the reporties have any sub reporties.
                    while(true){
                        if(empEmailTree.containsKey(listEmpEmails[i])){
                            currentEmail=listEmpEmails[i];
                            break;
                        }else{
                            currentEmail='';
                        }
                        i++;
                        if(i>=listEmpEmails.size()){
                            break;
                        }
                    }
                }
                i++;
                System.debug('~~currentEmail '+currentEmail);
                if(currentEmail=='') break;
            } 
        }else{
            listEmpEmails.add(currentEmail);
        }
        System.debug('~~listEmpEmails '+listEmpEmails);
        List<Performance_Rating__c> currentYearPerformanceRatings = [select id,Name,Appraisal_Cycle__r.Current_Cycle__c,Status__c,Employee__r.Name,Employee__r.Email_ID__c,Employee__c,Manager__c,Manager__r.Email_ID__c from Performance_Rating__c where Employee__r.Email_ID__c =: listEmpEmails and CreatedDate = THIS_YEAR];
      
        return getAllHirarchy(currentYearPerformanceRatings,'Manager__c');
    }
  /**
  * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
  *Added as a part of PMS-II
  * Builds the data necessary for the tree structure based on the parentFieldApiName
  * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
  * @param   recordList   	    recordList contains the list of records that need to make the tree structure.
  * @param   parentFieldApiName	parentFieldApiName is the field name that need to consider for making hte tree structure.
  * @param   appraisalCycleId   appraisalCycleId is of Type String and it Appraisal cycle record Id
  * @return  hierarchyWrapper     Returns the hierarchyWrapper wrapper class
  * ──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
  */
    @auraEnabled
    public static hierarchyWrapper getAllHirarchy(List<Performance_Rating__c> recordList, String parentFieldApiName){
        Map<String,List<childData>> mapofparentwithlistOfchild = new map<String, List<childData>>();
        List<Performance_Rating__c> parentList = new List<Performance_Rating__c>();
        for(Performance_Rating__c record: recordList){
            System.debug('record'+record);
            childData childObj = new childData();
            childObj.Id = record.Employee__c;
            childObj.Name = record.Employee__r.Name;
            childObj.ReportingTo = record.Manager__c;
            childObj.Status = record.Status__c;
            childObj.Quarter = record.Appraisal_Cycle__r.Current_Cycle__c;
            childObj.empPMSurl += '?c__prId='+record.Name+'&c__eId='+record.Employee__c;
            //childObj.empPMSurl += '?c__prId='+record.id;//+'&c__ccId='+record.Appraisal_Cycle__r.Current_Cycle__c+'&c__acId='+record.Appraisal_Cycle__c;
            
            if(record.get(parentFieldApiName) != null){
                if(mapofparentwithlistOfchild.containskey((String)record.get(parentFieldApiName))){
                    mapofparentwithlistOfchild.get((String)record.get(parentFieldApiName)).add(childObj);
                }else{
                    mapofparentwithlistOfchild.put((String)record.get(parentFieldApiName), new list<childData>{childObj});
                }
            }else{
                parentList.add(record);
            }
        }
        System.debug('parentList'+ mapofparentwithlistOfchild.get('a0G1K00001MSfpmUAD'));
        hierarchyWrapper wrapper = new hierarchyWrapper();
        wrapper.superParentList = [select id, name,ReportingTo__c from Employee__c where Email_ID__c  =:userInfo.getUserEmail()];//aneesh.vemireddy@crmit.com
        wrapper.parentMap = mapofparentwithlistOfchild;
        
        return wrapper;
    }
    //Added as a part of PMS-II
    public class childData{
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String ReportingTo;
        @AuraEnabled
        public String Status='Open';
        @AuraEnabled
        public String Quarter='QPR-II';
        @AuraEnabled
        public String empPMSurl = currentURL;//=URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/n/Performance_Management_System';
        @AuraEnabled
        public Integer Year = System.Today().year();
        
    }
    //Added as a part of PMS-II
    public class hierarchyWrapper{
        @AuraEnabled public List<SObject> superParentList{get;set;}
        @AuraEnabled public Map<String,List<childData>> parentMap{get;set;}
    }
    
     /**
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * getReporties is to get the all the reporties and delegated reporties(Project Leader)
  * of the curresnt logged in USER.
  * ────────────────────────────────────────────────────────────────────────────────────────────────
  * @return   reportiesWrappeData    return reportiesWrappeData wrapper class
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
    @AuraEnabled(cacheable=true)
    public static reportiesWrappeData getReporties(){
        employeeTree();
        System.debug('~~empEmailTree -- '+empEmailTree);
        String currentYear = String.valueOf(system.today().year());
        try{
            Appraisal__c[] appraisalCycle = [Select id, Current_Cycle__c,Current_Cycle_Start_Date__c,Q1ManagerSubmissionStartDate__c,Q2_ManagerSubmissionStartDate__c,Q3_ManagerSubmissionStartDate__c,Q4_ManagerSubmissionStartDate__c,
                                             Q1ManagerSubmissionEndDate__c,Q2_ManagerSubmissionEndDate__c,Q3_ManagerSubmissionEndDate__c,Q4_ManagerSubmissionEndDate__c,
                                             Q1ManagerExtensionEndDate__c,Q2ManagerExtensionEndDate__c,Q3_ManagerExtensionEndDate__c,Q4_ManagerExtensionEndDate__c
                                             from Appraisal__c  where QPR_Year__c =:currentYear limit 1];
            
            reportiesWrappeData repData = new reportiesWrappeData();
            
            repData.currenyCycleStardDate = appraisalCycle[0].Current_Cycle_Start_Date__c;
             if(appraisalCycle[0].Current_Cycle__c =='QPR-I')
            {
            repData.managerSubmissionEndDate = appraisalCycle[0].Q1ManagerSubmissionEndDate__c;
            }else if(appraisalCycle[0].Current_Cycle__c =='QPR-II'){
                repData.managerSubmissionEndDate = appraisalCycle[0].Q2_ManagerSubmissionEndDate__c;
            }else if(appraisalCycle[0].Current_Cycle__c =='QPR-III'){
                 repData.managerSubmissionEndDate = appraisalCycle[0].Q3_ManagerSubmissionEndDate__c;
            }else if(appraisalCycle[0].Current_Cycle__c =='Annual Cycle'){
                 repData.managerSubmissionEndDate = appraisalCycle[0].Q4_ManagerSubmissionEndDate__c;
            }
            //repData.managerSubmissionEndDate = appraisalCycle[0].Q2_ManagerSubmissionEndDate__c;//this need to make Dynamic
            repData.currentQuarter = appraisalCycle[0].Current_Cycle__c; 
            repData.appraisalCycleId = appraisalCycle[0].Id;
            repData.managerSubmissionExtensionEndDate = appraisalCycle[0].Current_Cycle_Start_Date__c;
            repData.logInUserEmail = userInfo.getUserEmail();
            
            //repData.reportiesData = new List<Performance_Rating__c>();//No need as a part of PMS-II implementation
            repData.delegateReportiesData = new List<Performance_Rating__c>();
            
            String loginUserEmail = userInfo.getUserEmail();
            String currentEmail = userInfo.getUserEmail();

            /*No need as a part of PMS-II implementation
            repData.reportiesData = [select id,Employee__r.Name,Employee__c, Manager__c, Status__c,Delegated_Manager__c,Delegated_Manager2__c from Performance_Rating__c where Employee__r.Email_ID__c =: listEmpEmails];
            repData.reportiesData = [select id,Employee__r.Name,Employee__c, Manager__c, Status__c,Delegated_Manager__c,Delegated_Manager2__c from Performance_Rating__c where Manager__r.Email_ID__c  =:userInfo.getUserEmail()];
            */
              if(appraisalCycle[0].Current_Cycle__c =='QPR-I'){
                    repData.delegateReportiesData = [select id,Employee__r.Name,Employee__c, Manager__c, Status__c,Delegated_Manager__c,Delegated_Manager2__c from Performance_Rating__c where Appraisal_Cycle__r.QPR_Year__c=:currentYear and (QPR_I_Project_Associate_1__r.Email_ID__c =:userInfo.getUserEmail() or QPR_I_Project_Associate_2__r.Email_ID__c  =:userInfo.getUserEmail())];
              }else if(appraisalCycle[0].Current_Cycle__c =='QPR-II'){
            repData.delegateReportiesData = [select id,Employee__r.Name,Employee__c, Manager__c, Status__c,Delegated_Manager__c,Delegated_Manager2__c from Performance_Rating__c where  Appraisal_Cycle__r.QPR_Year__c=:currentYear and (Delegated_Manager__r.Email_ID__c =:userInfo.getUserEmail() or Delegated_Manager2__r.Email_ID__c  =:userInfo.getUserEmail())];
                  
              }else if(appraisalCycle[0].Current_Cycle__c =='QPR-III'){
            repData.delegateReportiesData = [select id,Employee__r.Name,Employee__c, Manager__c, Status__c,Delegated_Manager__c,Delegated_Manager2__c from Performance_Rating__c where  Appraisal_Cycle__r.QPR_Year__c=:currentYear and  (QPR_III_Project_Associate_1__r.Email_ID__c =:userInfo.getUserEmail() or QPR_III_Project_Associate_2__r.Email_ID__c  =:userInfo.getUserEmail())];
              }else if(appraisalCycle[0].Current_Cycle__c =='Annual Cycle'){
            repData.delegateReportiesData = [select id,Employee__r.Name,Employee__c, Manager__c, Status__c,Delegated_Manager__c,Delegated_Manager2__c from Performance_Rating__c where  Appraisal_Cycle__r.QPR_Year__c=:currentYear and  (QPR_IV_Project_Associate_1__r.Email_ID__c =:userInfo.getUserEmail() or QPR_IV_Project_Associate_2__r.Email_ID__c  =:userInfo.getUserEmail())];
  
              }
                  
            repData.loggedInEmpId = [select id, name from Employee__c where Email_ID__c =:userInfo.getUserEmail()]?.id;
            repData.reportiesDataTree = PMS_Controller.getAllLoginUserEmployees();

            if(appraisalCycle[0].Current_Cycle__c =='QPR-I'){
                repData.managerSubmissionStartDate = appraisalCycle[0].Q1ManagerSubmissionStartDate__c;
                repData.managerSubmissionExtensionEndDate = appraisalCycle[0].Q1ManagerExtensionEndDate__c;
            }else if(appraisalCycle[0].Current_Cycle__c =='QPR-II'){
                repData.managerSubmissionStartDate = appraisalCycle[0].Q2_ManagerSubmissionStartDate__c;
                repData.managerSubmissionExtensionEndDate = appraisalCycle[0].Q2ManagerExtensionEndDate__c;
            }else if(appraisalCycle[0].Current_Cycle__c =='QPR-III'){
                repData.managerSubmissionStartDate = appraisalCycle[0].Q3_ManagerSubmissionStartDate__c;
                repData.managerSubmissionExtensionEndDate = appraisalCycle[0].Q3_ManagerExtensionEndDate__c;
            }else if(appraisalCycle[0].Current_Cycle__c =='Annual Cycle'){
                repData.managerSubmissionStartDate = appraisalCycle[0].Q4_ManagerSubmissionStartDate__c;
                repData.managerSubmissionExtensionEndDate = appraisalCycle[0].Q4_ManagerExtensionEndDate__c;
            }
            
            if(repData.managerSubmissionStartDate <= system.today()){
                repData.chkManagerSubmissionStartDate = true;
            }else{
                repData.chkManagerSubmissionStartDate = false;
            }
            
            if(repData.managerSubmissionEndDate < system.today() || (repData.managerSubmissionExtensionEndDate != null && repData.managerSubmissionExtensionEndDate < system.today())){
                repData.chkManagerSubmissionEndDate = false;
            }else{
                repData.chkManagerSubmissionEndDate = true;
            }
            
            return repData;
        }catch (Exception e) {
            System.debug('~~Error Msg -- '+e.getMessage());
            System.debug('~~Error Line No. -- '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
            
        }
        
    }
  /**
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * getData is the main method to disply KPI , KRA and Controless for Reporting manger View and 
  * Project Manager Login in PMS_Rating LWC component.
  * ────────────────────────────────────────────────────────────────────────────────────────────────
  * @param   recId   			recId is type String and it is Performance_Rating__c record Id.
  * @param   currentCycle		currentCycle is of Type String, it represents the QUARTER of the year
  * @param   appraisalCycleId   appraisalCycleId is of Type String and it Appraisal cycle record Id
  * @return  wrapData     Returns the wrapData wrapper class
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
    @AuraEnabled(cacheable=true)
    public static wrapData getData(String currentCycle,String selectedyear,String emplId){
        String currentQuarter = currentCycle;
        Integer c=1;
         System.debug('currentQuarter'+currentCycle); 
          System.debug('selectedyear'+selectedyear); 
         System.debug('emplId'+emplId);
          String currentEmail = userInfo.getUserEmail();
        //List<Performance_Rating__c> pr=[select id  from Performance_Rating__c where Employee__r.BU_Head__r.Email_ID__c =:currentEmail and id=:recId];//CCM
      // List<Performance_Rating__c> pr=[select id  from Performance_Rating__c where Employee__r.ReportingTo__r.ReportingTo__r.Email_ID__c =:currentEmail and id=:recId];//skip level
               List<Performance_Rating__c> pr=[select id  from Performance_Rating__c where Employee__c =:emplId and Appraisal_Cycle__r.QPR_Year__c  =:selectedyear and ((Employee__r.ReportingTo__r.ReportingTo__r.Email_ID__c =:currentEmail) or ( Employee__r.ReportingTo__r.EmployeeID__c='C0003' and (Employee__r.ReportingTo__r.ReportingTo__c=null or Employee__r.ReportingTo__r.ReportingTo__c='')))];

        try {
            if(emplId != null && emplId != ''){
                //Goal_Setting__r.Weightage__c //Goal_Setting__r.Total_KRA_Weightage__c
                List<Performance_Rating_Item__c> priList = [select Id,KPI__c,KRA__c,KRA_Weightage__c, Weightage__c, Employee_Rating__c, Employee_Comments__c,Manager_Rating__c, Manager_comments__c, Delegated_Manager__c, Delegated_Manager_Comments__c,
                                                            Goal_Setting__r.Total_KRA_Weightage__c,Goal_Setting__r.Goal_Repository__r.Name,Goal_Setting__r.Goal_Repository__r.Description__c,
                                                            Performance_Rating__r.Status__c,Goal_Setting__c,
                                                            
                                                            Performance_Rating__r.Q1_Overall_Rating_Manager__c,Performance_Rating__r.Q2_Overall_Rating_Manager__c,Performance_Rating__r.Q3_Overall_Rating_Manager__c, Performance_Rating__r.Q4_Overall_Rating_Manager__c, 
                                                            
                                                            Performance_Rating__c,Performance_Rating__r.Employee__c,
                                                            Performance_Rating__r.Employee__r.Name,Performance_Rating__r.Employee__r.Designation__r.Name,Performance_Rating__r.Employee__r.Country__c,Performance_Rating__r.Employee__r.BU_Head__r.Name,
                                                            Performance_Rating__r.Employee__r.EmployeeID__c,Performance_Rating__r.Employee__r.Corporate_Band__c , Performance_Rating__r.Employee__r.Grade__c,
                                                            
                                                            Performance_Rating__r.Manager__c,  Performance_Rating__r.Manager__r.Name,Performance_Rating__r.Delegated_Manager__c,Performance_Rating__r.Delegated_Manager__r.Name,
                                                            
                                                            Performance_Rating__r.Q1_Delegated_Manager_Comments__c, Performance_Rating__r.Q2_Delegated_Manager_Comments__c, Performance_Rating__r.Q3_Delegated_Manager_Comments__c, Performance_Rating__r.Q4_Delegated_Manager_Comments__c,
                                                            Performance_Rating__r.Q1_Delegated_Manager2_Comments__c, Performance_Rating__r.Q2_Delegated_Manager2_Comments__c,Performance_Rating__r.Q3_Delegated_Manager2_Comments__c, Performance_Rating__r.Q4_Delegated_Manager2_Comments__c, 
                                                            
                                                            Performance_Rating__r.Q1_Employee_Overall_Comments__c, Performance_Rating__r.Q2_Employee_Overall_Comments__c,Performance_Rating__r.Q3_Employee_Overall_Comments__c,Performance_Rating__r.Q4_Employee_Overall_Comments__c,
                                                            Performance_Rating__r.Q1_Manager_Overall_Comments__c, Performance_Rating__r.Q2_Manager_Overall_Comments__c, Performance_Rating__r.Q3_Manager_Overall_Comments__c, Performance_Rating__r.Q4_Manager_Overall_Comments__c, 
                                                            Performance_Rating__r.Delegated_Manager_status__c,Performance_Rating__r.Delegated_Manager2_status__c,
                                                            Performance_Rating__r.Q1_Overall_Rating_Employee__c,Performance_Rating__r.Q2_Overall_Rating_Employee__c,Performance_Rating__r.Q3_Overall_Rating_Employee__c,Performance_Rating__r.Q4_Overall_Rating_Employee__c,
                                                            Performance_Rating__r.Delegated_Manager2__r.Name,Performance_Rating__r.Delegated_Manager2__c,Performance_Rating__r.QPR_I_Project_Associate_1__r.Name,Performance_Rating__r.QPR_I_Project_Associate_2__r.Name, Performance_Rating__r.QPR_III_Project_Associate_1__r.Name,Performance_Rating__r.QPR_III_Project_Associate_2__r.Name,
                                                            
                                                            Performance_Rating__r.Reject_Reason__c, Performance_Rating__r.QPR_I_Project_Associate_1__c, Performance_Rating__r.QPR_I_Project_Associate_2__c, Performance_Rating__r.QPR_III_Project_Associate_1__c, Performance_Rating__r.QPR_III_Project_Associate_2__c, Performance_Rating__r.QPR_IV_Project_Associate_1__c, Performance_Rating__r.QPR_IV_Project_Associate_2__c,Performance_Rating__r.Appraisal_Cycle__r.Current_Cycle__c,Performance_Rating__r.Q1_Comments1__c,Performance_Rating__r.Q1_Comments2__c,Performance_Rating__r.Q3_Comments1__c,Performance_Rating__r.Q3_Comments2__c,Performance_Rating__r.Q4_Comments1__c,Performance_Rating__r.Q4_Comments2__c,Performance_Rating__r.Comments1__c,Performance_Rating__r.Comments2__c,Performance_Rating__r.QPR_IV_Project_Associate_1__r.Name,Performance_Rating__r.QPR_IV_Project_Associate_2__r.Name,Performance_Rating__r.Reviewer_rating__c,Performance_Rating__r.ReviewerComments__c,Performance_Rating__r.Appraisal_Cycle__r.Manager_Rating_Weightage__c,Performance_Rating__r.Appraisal_Cycle__r.Self_Rating_Weightage__c ,Performance_Rating__r.Appraisal_Cycle__r.Reviewer_Rating_Weightage__c	
                                                            
                                                            from Performance_Rating_Item__c where  Performance_Rating__r.Employee__c =:emplId and Performance_Rating__r.Appraisal_Cycle__r.QPR_Year__c  =:selectedyear and Quater__c =:currentCycle and Appraisal__c ='Quater'  order by Goal_Setting__r.Goal_Repository__r.KRA_order__c asc];
                 System.debug('priList'+priList.size()+priList);                                           
                if(priList.size()>0)
                {
                List<Performance_Rating_Item__c> priL = new List<Performance_Rating_Item__c>();
                
                wrapData KRASDATA = new wrapData();
                KRASDATA.isReviewer=(pr.size()>0?true:false);
                KRASDATA.status=priList[0].Performance_Rating__r.Status__c;
                KRASDATA.AppraisalQuater =priList[0].Performance_Rating__r.Appraisal_Cycle__r.Current_Cycle__c;
                KRASDATA.KRAS = new Map<String,List<Performance_Rating_Item__c>>();
                KRASDATA.empName = priList[0].Performance_Rating__r.Employee__r.Name;
                KRASDATA.reportingMngName = priList[0].Performance_Rating__r.Manager__r.Name;
                system.debug('reportingMngName'+KRASDATA.reportingMngName);
                KRASDATA.band = priList[0].Performance_Rating__r.Employee__r.Corporate_Band__c;
                KRASDATA.grade = priList[0].Performance_Rating__r.Employee__r.Grade__c;
                KRASDATA.desigination = priList[0].Performance_Rating__r.Employee__r.Designation__r.Name;
                // KRASDATA.Weightage = priList[0].Goal_Setting__r.Weightage__c;
                KRASDATA.Weightage = priList[0].Goal_Setting__r.Total_KRA_Weightage__c;
                KRASDATA.delegateManagerId = priList[0].Performance_Rating__r.Delegated_Manager__c;
                KRASDATA.delegateManager2Id = priList[0].Performance_Rating__r.Delegated_Manager2__c;
                KRASDATA.employeeId = priList[0].Performance_Rating__r.Employee__c;
                KRASDATA.managerId = priList[0].Performance_Rating__r.Manager__c;
                KRASDATA.loggedInEmpId = [select id, name from Employee__c where Email_ID__c =:userInfo.getUserEmail()]?.id;
                KRASDATA.currentQuarter = priList[0].Performance_Rating__r.Appraisal_Cycle__r.Current_Cycle__c;
                KRASDATA.empCode = priList[0].Performance_Rating__r.Employee__r.EmployeeID__c;
                KRASDATA.empLocation = priList[0].Performance_Rating__r.Employee__r.Country__c;
                //KRASDATA.delegateMg1Name = priList[0].Performance_Rating__r.Delegated_Manager__r.Name;
                //KRASDATA.delegateMg2Name = priList[0].Performance_Rating__r.Delegated_Manager2__r.Name;
                KRASDATA.ccm = (priList[0].Performance_Rating__r.Employee__r.BU_Head__r.Name != null && priList[0].Performance_Rating__r.Employee__r.BU_Head__r.Name != '')?priList[0].Performance_Rating__r.Employee__r.BU_Head__r.Name:'';
                KRASDATA.isDelegateManagerSubmitted = (priList[0].Performance_Rating__r.Delegated_Manager_status__c || priList[0].Performance_Rating__r.Delegated_Manager2_status__c);
                KRASDATA.isDelegateMg1Submitted = priList[0].Performance_Rating__r.Delegated_Manager_status__c ;
                KRASDATA.isDelegateMg2Submitted = priList[0].Performance_Rating__r.Delegated_Manager2_status__c;
                KRASDATA.rejectReason =  (priList[0].Performance_Rating__r.Reject_Reason__c != null)?priList[0].Performance_Rating__r.Reject_Reason__c:'';
                KRASDATA.Q1selfRating= (priList[0].Performance_Rating__r.Q1_Overall_Rating_Employee__c);
                KRASDATA.Q2selfRating=(priList[0].Performance_Rating__r.Q2_Overall_Rating_Employee__c);
                KRASDATA.Q3selfRating=(priList[0].Performance_Rating__r.Q3_Overall_Rating_Employee__c);
                KRASDATA.Q4selfRating = (priList[0].Performance_Rating__r.Q4_Overall_Rating_Employee__c);
                KRASDATA.Q1manaRating= (priList[0].Performance_Rating__r.Q1_Overall_Rating_Manager__c);
                KRASDATA.Q2manaRating = (priList[0].Performance_Rating__r.Q2_Overall_Rating_Manager__c);
                KRASDATA.Q3manaRating = (priList[0].Performance_Rating__r.Q3_Overall_Rating_Manager__c); 
                KRASDATA.Q4manaRating = (priList[0].Performance_Rating__r.Q4_Overall_Rating_Manager__c); 
                if(currentQuarter =='QPR-I'){
                    KRASDATA.ManagerComments1=priList[0].Performance_Rating__r.Q1_Comments1__c;
                    KRASDATA.ManagerComments2=priList[0].Performance_Rating__r.Q1_Comments2__c;
                    KRASDATA.delegateMg1Name = priList[0].Performance_Rating__r.QPR_I_Project_Associate_1__r.Name;
                    KRASDATA.delegateMg2Name = priList[0].Performance_Rating__r.QPR_I_Project_Associate_2__r.Name;
                    KRASDATA.delegateManagerId = priList[0].Performance_Rating__r.QPR_I_Project_Associate_1__c;
                    KRASDATA.delegateManager2Id = priList[0].Performance_Rating__r.QPR_I_Project_Associate_2__c;
                    KRASDATA.delegateManager1FeedBack = priList[0].Performance_Rating__r.Q1_Delegated_Manager_Comments__c;
                    KRASDATA.delegateManager2FeedBack = priList[0].Performance_Rating__r.Q1_Delegated_Manager2_Comments__c;
                    KRASDATA.mngOverallComments = (priList[0].Performance_Rating__r.Q1_Manager_Overall_Comments__c != null && priList[0].Performance_Rating__r.Q1_Manager_Overall_Comments__c != '')?priList[0].Performance_Rating__r.Q1_Manager_Overall_Comments__c:'';
                    KRASDATA.empOverallComments = (priList[0].Performance_Rating__r.Q1_Employee_Overall_Comments__c != null && priList[0].Performance_Rating__r.Q1_Employee_Overall_Comments__c != '')?priList[0].Performance_Rating__r.Q1_Employee_Overall_Comments__c:'';
                    KRASDATA.empOverallRating = priList[0].Performance_Rating__r.Q1_Overall_Rating_Employee__c;
                    KRASDATA.mngOverallRating = priList[0].Performance_Rating__r.Q1_Overall_Rating_Manager__c;
                    //KRASDATA.isManagerSubmitted=true;
                    //KRASDATA.isEmpSubmitted=false;
                    KRASDATA.isManagerSubmitted = (priList[0].Performance_Rating__r.Status__c == 'QPR-I Manager submitted'||(currentQuarter!=priList[0].Performance_Rating__r.Appraisal_Cycle__r.Current_Cycle__c && priList[0].Performance_Rating__r.Status__c != 'QPR-I Manager submitted'))?true:false;
                    KRASDATA.isEmpSubmitted = (priList[0].Performance_Rating__r.Status__c == 'QPR-I Emp Submitted')?true:false;
                    
                }else if(currentQuarter =='QPR-II'){
                    KRASDATA.ManagerComments1=priList[0].Performance_Rating__r.Comments1__c;
                    KRASDATA.ManagerComments2=priList[0].Performance_Rating__r.Comments2__c;
                    KRASDATA.delegateManagerId = priList[0].Performance_Rating__r.Delegated_Manager__c;
                    KRASDATA.delegateManager2Id = priList[0].Performance_Rating__r.Delegated_Manager2__c;
                    KRASDATA.delegateMg1Name = priList[0].Performance_Rating__r.Delegated_Manager__r.Name;
                    KRASDATA.delegateMg2Name = priList[0].Performance_Rating__r.Delegated_Manager2__r.Name;
                    KRASDATA.delegateManager1FeedBack = priList[0].Performance_Rating__r.Q2_Delegated_Manager_Comments__c;
                    KRASDATA.delegateManager2FeedBack = priList[0].Performance_Rating__r.Q2_Delegated_Manager2_Comments__c;
                    KRASDATA.mngOverallComments = (priList[0].Performance_Rating__r.Q2_Manager_Overall_Comments__c != null && priList[0].Performance_Rating__r.Q2_Manager_Overall_Comments__c != '')?priList[0].Performance_Rating__r.Q2_Manager_Overall_Comments__c:'';
                    KRASDATA.empOverallComments = (priList[0].Performance_Rating__r.Q2_Employee_Overall_Comments__c != null && priList[0].Performance_Rating__r.Q2_Employee_Overall_Comments__c != '')?priList[0].Performance_Rating__r.Q2_Employee_Overall_Comments__c:'';
                    KRASDATA.empOverallRating = priList[0].Performance_Rating__r.Q2_Overall_Rating_Employee__c;
                    KRASDATA.mngOverallRating = priList[0].Performance_Rating__r.Q2_Overall_Rating_Manager__c;
                    system.debug('priList[0].Performance_Rating__r.Status__c'+priList[0].Performance_Rating__r.Status__c);
                   system.debug('currentQuarter'+currentQuarter);
                    system.debug('priList[0].Performance_Rating__r.Appraisal_Cycle__r.Current_Cycle__c'+priList[0].Performance_Rating__r.Appraisal_Cycle__r.Current_Cycle__c);
                    //KRASDATA.isManagerSubmitted = (priList[0].Performance_Rating__r.Status__c == 'QPR-II Manager submitted')?true:false;
                    KRASDATA.isManagerSubmitted = (priList[0].Performance_Rating__r.Status__c == 'QPR-II Manager submitted'||(currentQuarter!=priList[0].Performance_Rating__r.Appraisal_Cycle__r.Current_Cycle__c && priList[0].Performance_Rating__r.Status__c != 'QPR-II Manager submitted'))?true:false;

                    KRASDATA.isEmpSubmitted = (priList[0].Performance_Rating__r.Status__c == 'QPR-II Emp Submitted'||((currentQuarter!=priList[0].Performance_Rating__r.Appraisal_Cycle__r.Current_Cycle__c) && (priList[0].Performance_Rating__r.Status__c != 'QPR-II Emp Submitted')))?true:false;
                }else if(currentQuarter =='QPR-III'){
                    KRASDATA.ManagerComments1=priList[0].Performance_Rating__r.Q3_Comments1__c;
                    KRASDATA.ManagerComments2=priList[0].Performance_Rating__r.Q3_Comments2__c;
                    KRASDATA.delegateMg1Name = priList[0].Performance_Rating__r.QPR_III_Project_Associate_1__r.Name;
                    KRASDATA.delegateMg2Name = priList[0].Performance_Rating__r.QPR_III_Project_Associate_2__r.Name;
                    KRASDATA.delegateManagerId = priList[0].Performance_Rating__r.QPR_III_Project_Associate_1__c;
                    KRASDATA.delegateManager2Id = priList[0].Performance_Rating__r.QPR_III_Project_Associate_2__c;
                    KRASDATA.delegateManager1FeedBack = priList[0].Performance_Rating__r.Q3_Delegated_Manager_Comments__c;
                    KRASDATA.delegateManager2FeedBack = priList[0].Performance_Rating__r.Q3_Delegated_Manager2_Comments__c;
                    KRASDATA.mngOverallComments = (priList[0].Performance_Rating__r.Q3_Manager_Overall_Comments__c != null && priList[0].Performance_Rating__r.Q3_Manager_Overall_Comments__c != '')?priList[0].Performance_Rating__r.Q3_Manager_Overall_Comments__c:'';
                    KRASDATA.empOverallComments = (priList[0].Performance_Rating__r.Q3_Employee_Overall_Comments__c != null && priList[0].Performance_Rating__r.Q3_Employee_Overall_Comments__c != '')?priList[0].Performance_Rating__r.Q3_Employee_Overall_Comments__c:'';
                    KRASDATA.empOverallRating = priList[0].Performance_Rating__r.Q3_Overall_Rating_Employee__c;
                    KRASDATA.mngOverallRating = priList[0].Performance_Rating__r.Q3_Overall_Rating_Manager__c;
                    KRASDATA.isManagerSubmitted = (priList[0].Performance_Rating__r.Status__c == 'QPR-III Manager submitted'||(currentQuarter!=priList[0].Performance_Rating__r.Appraisal_Cycle__r.Current_Cycle__c && priList[0].Performance_Rating__r.Status__c !='QPR-III Manager submitted'))?true:false;
                    KRASDATA.isEmpSubmitted = (priList[0].Performance_Rating__r.Status__c == 'QPR-III Emp Submitted')?true:false;
                }else if(currentQuarter =='Annual Cycle'){
                    if(priList[0].Performance_Rating__r.Q3_Overall_Rating_Employee__c>0 && priList[0].Performance_Rating__r.Q3_Overall_Rating_Manager__c>0)
                    {
                        c=c+1;
                    }
                    if(priList[0].Performance_Rating__r.Q2_Overall_Rating_Employee__c>0 && priList[0].Performance_Rating__r.Q2_Overall_Rating_Manager__c>0)
                    {
                        c=c+1;
                    }
                    if(priList[0].Performance_Rating__r.Q1_Overall_Rating_Employee__c>0 && priList[0].Performance_Rating__r.Q1_Overall_Rating_Manager__c>0)
                    {
                        c=c+1;  
                    }


                    
                    KRASDATA.delegateMg1Name = priList[0].Performance_Rating__r.QPR_IV_Project_Associate_1__r.Name;
                    KRASDATA.delegateMg2Name = priList[0].Performance_Rating__r.QPR_IV_Project_Associate_2__r.Name;
                    KRASDATA.delegateManagerId = priList[0].Performance_Rating__r.QPR_IV_Project_Associate_1__c;
                    KRASDATA.delegateManager2Id = priList[0].Performance_Rating__r.QPR_IV_Project_Associate_2__c;
                    KRASDATA.ManagerComments1=priList[0].Performance_Rating__r.Q4_Comments1__c;
                    KRASDATA.ManagerComments2=priList[0].Performance_Rating__r.Q4_Comments2__c;
                    KRASDATA.delegateManager1FeedBack = priList[0].Performance_Rating__r.Q4_Delegated_Manager_Comments__c;
                    KRASDATA.delegateManager2FeedBack = priList[0].Performance_Rating__r.Q3_Delegated_Manager2_Comments__c;
                    KRASDATA.mngOverallComments = (priList[0].Performance_Rating__r.Q4_Manager_Overall_Comments__c != null && priList[0].Performance_Rating__r.Q4_Manager_Overall_Comments__c != '')?priList[0].Performance_Rating__r.Q4_Manager_Overall_Comments__c:'';
                    KRASDATA.empOverallComments = (priList[0].Performance_Rating__r.Q4_Employee_Overall_Comments__c != null && priList[0].Performance_Rating__r.Q4_Employee_Overall_Comments__c != '')?priList[0].Performance_Rating__r.Q4_Employee_Overall_Comments__c:'';
                    KRASDATA.empOverallRating = priList[0].Performance_Rating__r.Q4_Overall_Rating_Employee__c;
                    KRASDATA.mngOverallRating = priList[0].Performance_Rating__r.Q4_Overall_Rating_Manager__c;
                    KRASDATA.isManagerSubmitted = (priList[0].Performance_Rating__r.Status__c == 'QPR-IV/Annual Review Manager submitted'||( KRASDATA.loggedInEmpId!=KRASDATA.managerId && priList[0].Performance_Rating__r.Status__c == 'QPR-IV/Annual Review Emp Submitted'))?true:false;
                    KRASDATA.isEmpSubmitted = (priList[0].Performance_Rating__r.Status__c == 'QPR-IV/Annual Review Emp Submitted')?true:false;
                    KRASDATA.reviewerRating=(priList[0].Performance_Rating__r.Reviewer_rating__c!=null?priList[0].Performance_Rating__r.Reviewer_rating__c:0);
                    KRASDATA.reviewercommentsdata=(priList[0].Performance_Rating__r.ReviewerComments__c!=null?priList[0].Performance_Rating__r.ReviewerComments__c:'');
                    if(KRASDATA.reviewerRating!=0 && KRASDATA.reviewerRating!=null)
                    {
                        system.debug('count'+c);
                        Decimal overallquaterselfrating=((priList[0].Performance_Rating__r.Q1_Overall_Rating_Employee__c+priList[0].Performance_Rating__r.Q2_Overall_Rating_Employee__c+priList[0].Performance_Rating__r.Q3_Overall_Rating_Employee__c+ priList[0].Performance_Rating__r.Q4_Overall_Rating_Employee__c)/c).setScale(1);
                        Decimal overallManagerrating=((priList[0].Performance_Rating__r.Q1_Overall_Rating_Manager__c+priList[0].Performance_Rating__r.Q2_Overall_Rating_Manager__c+priList[0].Performance_Rating__r.Q3_Overall_Rating_Manager__c+priList[0].Performance_Rating__r.Q4_Overall_Rating_Manager__c)/c).setScale(1);
                        system.debug('overallquaterselfrating'+overallquaterselfrating);
                         system.debug('overallManagerrating'+overallManagerrating);
                       KRASDATA.finalRating=((priList[0].Performance_Rating__r.Reviewer_rating__c*(priList[0].Performance_Rating__r.Appraisal_Cycle__r.Reviewer_Rating_Weightage__c/100))+((priList[0].Performance_Rating__r.Appraisal_Cycle__r.Self_Rating_Weightage__c/100)*(overallquaterselfrating))+((priList[0].Performance_Rating__r.Appraisal_Cycle__r.Manager_Rating_Weightage__c/100)*(overallManagerrating))).setScale(1);
                    }
                }
                KRASDATA.isManagerSubmitted = ((priList[0].Performance_Rating__r.Status__c == 'Manager Rejected')&&(currentQuarter==priList[0].Performance_Rating__r.Appraisal_Cycle__r.Current_Cycle__c))?false:KRASDATA.isManagerSubmitted;
                KRASDATA.isEmpSubmitted = (priList[0].Performance_Rating__r.Status__c == 'Manager Rejected')?false:KRASDATA.isEmpSubmitted;
                for(Performance_Rating_Item__c pri: priList){
                    if(KRASDATA.KRAS != null && KRASDATA.KRAS.containsKey(pri.Goal_Setting__r.Goal_Repository__r.Name)){
                        KRASDATA.KRAS.get(pri.Goal_Setting__r.Goal_Repository__r.Name).add(pri);
                    }
                    else if(pri.Goal_Setting__r.Goal_Repository__r.Name != null){
                        List<Performance_Rating_Item__c> priL1 = new List<Performance_Rating_Item__c>();
                        priL1.add(pri);
                        KRASDATA.KRAS.put(pri.Goal_Setting__r.Goal_Repository__r.Name,priL1);
                    }
                }
                
                System.debug('~~KRASDATA.KRAS '+KRASDATA.KRAS);
                return KRASDATA;
                }
                else
                {
                    return null;
                }
            }
        
                

            return null;   
        
        } catch (Exception e) {
            System.debug('~~Error Msg -- '+e.getMessage());
            System.debug('~~Error Line No. -- '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
            
        }
    }
    
    /**
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * updatePRI to update the performance rating items.
  * ────────────────────────────────────────────────────────────────────────────────────────────────
  * @param   pri2update   		.
  * @param   statusFlage		.
  * @param   prId               .
  * @param   mngOverallComts
  * @param   currentQuarter
  * @return  void    
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
    @AuraEnabled
    public static void updatePRI(Map<String,Map<String,String>> pri2update,String statusFlage,string prId,String mngOverallComts, String currentQuarter){
        //System.debug('~~pri2update -- '+pri2update);
        List<Performance_Rating_Item__c> priList2update = new List<Performance_Rating_Item__c>();
         Map<Id,Goal_Setting__c> gskpiupdate= new Map<Id,Goal_Setting__c>();
        for(String kpi: pri2update.keySet()){
            Performance_Rating_Item__c pri = new Performance_Rating_Item__c(Id = kpi); 
            pri.Manager_Rating__c = double.valueOf(pri2update.get(kpi).get('managerRating'));
            pri.Manager_comments__c = pri2update.get(kpi).get('managerComments');
            pri.Weightage__c = double.valueOf(pri2update.get(kpi).get('kpiWeightage'));
            pri.KRA_Weightage_of_Manager_New__c = (double.valueOf(pri2update.get(kpi).get('kpiWeightage'))*double.valueOf(pri2update.get(kpi).get('managerRating')))/100;
            if((string.isNotBlank(pri2update.get(kpi).get('kpi')))){
                pri.KPI__c = pri2update.get(kpi).get('kpi');
            }
            if(statusFlage == 'true'){
                pri.Status__c = 'Manager Submitted';
            }
            if(pri2update.get(kpi).get('index')!=null)
            {
               
                if(!gskpiupdate.containskey(pri2update.get(kpi).get('gsid')))
                   {
                       Goal_Setting__c Gs = new Goal_Setting__c();
                       Gs.Id= pri2update.get(kpi).get('gsid');
                       gskpiupdate.put(Gs.Id,Gs);
                   }                
           
                
                if(pri2update.get(kpi).get('index')=='0')
                {
                  
                   gskpiupdate.get(pri2update.get(kpi).get('gsid')).KPI_1__c=pri2update.get(kpi).get('kpi');
                   gskpiupdate.get(pri2update.get(kpi).get('gsid')).KPI_1_Weightage__c=double.valueOf(pri2update.get(kpi).get('kpiWeightage'));
                  
                }
                else if(pri2update.get(kpi).get('index')=='1')
                {
                   
                 gskpiupdate.get(pri2update.get(kpi).get('gsid')).KPI_2__c=pri2update.get(kpi).get('kpi');
                 gskpiupdate.get(pri2update.get(kpi).get('gsid')).KPI_2_Weightage__c=double.valueOf(pri2update.get(kpi).get('kpiWeightage'));
                }
                else if(pri2update.get(kpi).get('index')=='2')
                {
          
                   gskpiupdate.get(pri2update.get(kpi).get('gsid')).KPI_3__c=pri2update.get(kpi).get('kpi');
                   gskpiupdate.get(pri2update.get(kpi).get('gsid')).KPI_3_Weightage__c=double.valueOf(pri2update.get(kpi).get('kpiWeightage'));
                }
                 else if(pri2update.get(kpi).get('index')=='3')
                {
                  
                   gskpiupdate.get(pri2update.get(kpi).get('gsid')).KPI_4__c=pri2update.get(kpi).get('kpi');
                   gskpiupdate.get(pri2update.get(kpi).get('gsid')).KPI_4_Weightage__c=double.valueOf(pri2update.get(kpi).get('kpiWeightage'));
                }
                else if(pri2update.get(kpi).get('index')=='4')
                {
                   
                   gskpiupdate.get(pri2update.get(kpi).get('gsid')).KPI_5__c=pri2update.get(kpi).get('kpi');
                   gskpiupdate.get(pri2update.get(kpi).get('gsid')).KPI_5_Weightage__c=double.valueOf(pri2update.get(kpi).get('kpiWeightage'));
                }
              

            }
            if(gskpiupdate.size()>0)
            {
                update gskpiupdate.values();
            }
            pri.Manager_Submitted_Date__c = System.now();
            priList2update.add(pri);
        }
        if(currentQuarter == 'QPR-I' && statusFlage == 'true'){
            update 	new Performance_Rating__c(id = prId,Status__c='QPR-I Manager submitted', Q1_Manager_Overall_Comments__c = mngOverallComts);
        }
        else if(currentQuarter == 'QPR-II' && statusFlage == 'true'){
            update 	new Performance_Rating__c(id = prId,Status__c='QPR-II Manager submitted', Q2_Manager_Overall_Comments__c = mngOverallComts);
        }
        else if(currentQuarter == 'QPR-III' && statusFlage == 'true'){
            update 	new Performance_Rating__c(id = prId,Status__c='QPR-III Manager submitted', Q3_Manager_Overall_Comments__c = mngOverallComts);
        }
        else if(currentQuarter == 'Annual Cycle' && statusFlage == 'true'){
            update 	new Performance_Rating__c(id = prId,Status__c='QPR-IV/Annual Review Manager submitted', Q4_Manager_Overall_Comments__c = mngOverallComts);
        }
        else if(statusFlage == 'false' && currentQuarter == 'QPR-I'){
            update 	new Performance_Rating__c(id = prId, Q1_Manager_Overall_Comments__c = mngOverallComts);
        }
        else if(statusFlage == 'false' && currentQuarter == 'QPR-II'){
            update 	new Performance_Rating__c(id = prId, Q2_Manager_Overall_Comments__c = mngOverallComts);
        }
        else if(statusFlage == 'false' && currentQuarter == 'QPR-III'){
            update 	new Performance_Rating__c(id = prId, Q3_Manager_Overall_Comments__c = mngOverallComts);
        }
        else if(statusFlage == 'false' && currentQuarter == 'Annual Cycle'){
            update 	new Performance_Rating__c(id = prId, Q4_Manager_Overall_Comments__c = mngOverallComts);
        }
        try{
            
            update priList2update;
        }catch (Exception e) {
            System.debug('~~Error Msg -- '+e.getMessage());
            System.debug('~~Error Line No. -- '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
            
        }
        
    }
    
  /**
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * updateDelegateManagerCommenets to update the performance rating items.
  * ────────────────────────────────────────────────────────────────────────────────────────────────
  * @param   comments   		Comments given by the delegate manager.
  * @param   delMgId		    Delegate manager id.
  * @param   quater               .
  * @param   prId               Performance Rating Record Id  
  * @param   currentQuarter     Quarter of value.
  * @return  void    
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
    @AuraEnabled
    public static void updateDelegateManagerCommenets(String comments,String delMgId, String quater, string prId,String currentQuarter){
        
        try {
            Performance_Rating__c pr=[Select id,Delegated_Manager__c,Delegated_Manager2__c,QPR_III_Project_Associate_1__c,QPR_III_Project_Associate_2__c,QPR_I_Project_Associate_1__c,QPR_I_Project_Associate_2__c,QPR_IV_Project_Associate_1__c,QPR_IV_Project_Associate_2__c from Performance_Rating__c where id =: prId];
            
            boolean isDeleMg1 = (pr.Delegated_Manager__c == delMgId||pr.QPR_III_Project_Associate_1__c==delMgId||pr.QPR_I_Project_Associate_1__c==delMgId||pr.QPR_IV_Project_Associate_1__c==delMgId)?true:false;//need to make dynamic for qpr1 and qpr 4
            boolean isDelMg2 = (pr.Delegated_Manager2__c == delMgId||pr.QPR_III_Project_Associate_2__c==delMgId||pr.QPR_I_Project_Associate_2__c==delMgId||pr.QPR_IV_Project_Associate_2__c==delMgId)?true:false;
            
            if(isDeleMg1 == true){
                if(currentQuarter == 'QPR-I'){
                    update new Performance_Rating__c(id=prId,Delegated_Manager_status__c = true,
                                                     Q1_Delegated_Manager_Comments__c = comments
                                                    );
                }
                else if(currentQuarter == 'QPR-II'){
                    update new Performance_Rating__c(id=prId,Delegated_Manager_status__c = true,
                                                     Q2_Delegated_Manager_Comments__c = comments
                                                    );
                }
                else if(currentQuarter == 'QPR-III'){
                    update new Performance_Rating__c(id=prId,Delegated_Manager_status__c = true,
                                                     Q3_Delegated_Manager_Comments__c = comments
                                                    );
                }
                else if(currentQuarter == 'Annual Cycle'){
                    update new Performance_Rating__c(id=prId,Delegated_Manager_status__c = true,
                                                     Q4_Delegated_Manager_Comments__c = comments
                                                    );
                }
                
            }
            else if(isDelMg2 == true){
                if(currentQuarter == 'QPR-I'){
                    update new Performance_Rating__c(id=prId,Delegated_Manager2_status__c = true,
                                                     Q1_Delegated_Manager2_Comments__c = comments
                                                    );
                }
                else if(currentQuarter == 'QPR-II'){
                    update new Performance_Rating__c(id=prId,Delegated_Manager2_status__c = true,
                                                     Q2_Delegated_Manager2_Comments__c = comments
                                                    );
                }
                else if(currentQuarter == 'QPR-III'){
                    update new Performance_Rating__c(id=prId,Delegated_Manager2_status__c = true,
                                                     Q3_Delegated_Manager2_Comments__c = comments
                                                    );
                }
                else if(currentQuarter == 'Annual Cycle'){
                    update new Performance_Rating__c(id=prId,Delegated_Manager2_status__c = true,
                                                     Q4_Delegated_Manager2_Comments__c = comments
                                                    );
                }
                
            }
        }catch (Exception e) {
            System.debug('~~Error Msg -- '+e.getMessage());
            System.debug('~~Error Line No. -- '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
  * ───────────────────────────────────────────────────────────────────────────────────────────────┐
  * updateReject to update the performance rating status when it is rejected by Manager.
  * ────────────────────────────────────────────────────────────────────────────────────────────────
  * @param   rejReson   		rejReson is the details entered by the manager.
  * @param   prId               Performance Rating Record Id.
  * @return  void    
  * ───────────────────────────────────────────────────────────────────────────────────────────────┘
  */
    @AuraEnabled
    public static void updateReject(String rejReson, string prId){
        try{
            
        update new Performance_Rating__c(id=prId, Status__c = 'Manager Rejected',
                                             Reject_Reason__c = rejReson
                                            );
        }catch (Exception e) {
            System.debug('~~Error Msg -- '+e.getMessage());
            System.debug('~~Error Line No. -- '+e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
            
        }
        
    }
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getPicklistValues() {
        List<Schema.PicklistEntry> entries = Appraisal__c.Current_Cycle__c.getDescribe().getPicklistValues();
        List<Map<String, String>> values = new List<Map<String, String>>();
        for (Schema.PicklistEntry entry : entries) {
           
            Map<String, String> valueMap = new Map<String, String>();
          
            valueMap.put('label', entry.getLabel());
            valueMap.put('value', entry.getValue());
           
            values.add(valueMap);
        }
        
        return values;
    }
     @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getyearPicklistValues() {
        List<Schema.PicklistEntry> entries = Appraisal__c.QPR_Year__c.getDescribe().getPicklistValues();
        List<Map<String, String>> values = new List<Map<String, String>>();
        for (Schema.PicklistEntry entry : entries) {
           
            Map<String, String> valueMap = new Map<String, String>();
          
            valueMap.put('label', entry.getLabel());
            valueMap.put('value', entry.getValue());
           
            values.add(valueMap);
        }
        
        return values;
    }
      @AuraEnabled(cacheable=true)
                        public static List<Employee__c> searchCoachByName( String coachName ){
                            try {
                                if(coachName!='')
                                {
                                coachName = '%' + coachName + '%';
                                return [ SELECT ID, Name FROM Employee__c WHERE Name LIKE :coachName ];
                                }
                              return new List<Employee__c>();
                            } catch (Exception e) {
                                throw new AuraHandledException(e.getMessage());
                            }
                        }

    @AuraEnabled
    public static Performance_Rating__c updatereviewer(String prId,String status,double rating,String comments,Boolean flag)
    {
        Integer c=1;
       system.debug('status'+status);
       Performance_Rating__c Pr = new Performance_Rating__c();
        Pr.Id=prId;
        if(flag==false)
        {
             //Pr.Status__c=status;
        }
        else
        {
        Pr.Status__c='Reviewer Submitted';
        }
        pr.Reviewer_rating__c=rating;
        pr.ReviewerComments__c=comments;
          
        update pr;
          //return pr;
         List<Performance_Rating_Item__c> priList = [select Id,KPI__c,KRA__c,KRA_Weightage__c, Weightage__c, Employee_Rating__c, Employee_Comments__c,Manager_Rating__c, Manager_comments__c, Delegated_Manager__c, Delegated_Manager_Comments__c,
                                                            Goal_Setting__r.Total_KRA_Weightage__c,Goal_Setting__r.Goal_Repository__r.Name,Goal_Setting__r.Goal_Repository__r.Description__c,
                                                            Performance_Rating__r.Status__c,Goal_Setting__c,
                                                            
                                                            Performance_Rating__r.Q1_Overall_Rating_Manager__c,Performance_Rating__r.Q2_Overall_Rating_Manager__c,Performance_Rating__r.Q3_Overall_Rating_Manager__c, Performance_Rating__r.Q4_Overall_Rating_Manager__c, 
                                                            
                                                            Performance_Rating__c,Performance_Rating__r.Employee__c,
                                                            Performance_Rating__r.Employee__r.Name,Performance_Rating__r.Employee__r.Designation__r.Name,Performance_Rating__r.Employee__r.Country__c,Performance_Rating__r.Employee__r.BU_Head__r.Name,
                                                            Performance_Rating__r.Employee__r.EmployeeID__c,Performance_Rating__r.Employee__r.Corporate_Band__c , Performance_Rating__r.Employee__r.Grade__c,
                                                            
                                                            Performance_Rating__r.Manager__c,  Performance_Rating__r.Manager__r.Name,Performance_Rating__r.Delegated_Manager__c,Performance_Rating__r.Delegated_Manager__r.Name,
                                                            
                                                            Performance_Rating__r.Q1_Delegated_Manager_Comments__c, Performance_Rating__r.Q2_Delegated_Manager_Comments__c, Performance_Rating__r.Q3_Delegated_Manager_Comments__c, Performance_Rating__r.Q4_Delegated_Manager_Comments__c,
                                                            Performance_Rating__r.Q1_Delegated_Manager2_Comments__c, Performance_Rating__r.Q2_Delegated_Manager2_Comments__c,Performance_Rating__r.Q3_Delegated_Manager2_Comments__c, Performance_Rating__r.Q4_Delegated_Manager2_Comments__c, 
                                                            
                                                            Performance_Rating__r.Q1_Employee_Overall_Comments__c, Performance_Rating__r.Q2_Employee_Overall_Comments__c,Performance_Rating__r.Q3_Employee_Overall_Comments__c,Performance_Rating__r.Q4_Employee_Overall_Comments__c,
                                                            Performance_Rating__r.Q1_Manager_Overall_Comments__c, Performance_Rating__r.Q2_Manager_Overall_Comments__c, Performance_Rating__r.Q3_Manager_Overall_Comments__c, Performance_Rating__r.Q4_Manager_Overall_Comments__c, 
                                                            Performance_Rating__r.Delegated_Manager_status__c,Performance_Rating__r.Delegated_Manager2_status__c,
                                                            Performance_Rating__r.Q1_Overall_Rating_Employee__c,Performance_Rating__r.Q2_Overall_Rating_Employee__c,Performance_Rating__r.Q3_Overall_Rating_Employee__c,Performance_Rating__r.Q4_Overall_Rating_Employee__c,
                                                            Performance_Rating__r.Delegated_Manager2__r.Name,Performance_Rating__r.Delegated_Manager2__c,Performance_Rating__r.QPR_I_Project_Associate_1__r.Name,Performance_Rating__r.QPR_I_Project_Associate_2__r.Name, Performance_Rating__r.QPR_III_Project_Associate_1__r.Name,Performance_Rating__r.QPR_III_Project_Associate_2__r.Name,
                                                            
                                                            Performance_Rating__r.Reject_Reason__c, Performance_Rating__r.QPR_I_Project_Associate_1__c, Performance_Rating__r.QPR_I_Project_Associate_2__c, Performance_Rating__r.QPR_III_Project_Associate_1__c, Performance_Rating__r.QPR_III_Project_Associate_2__c, Performance_Rating__r.QPR_IV_Project_Associate_1__c, Performance_Rating__r.QPR_IV_Project_Associate_2__c,Performance_Rating__r.Appraisal_Cycle__r.Current_Cycle__c,Performance_Rating__r.Q1_Comments1__c,Performance_Rating__r.Q1_Comments2__c,Performance_Rating__r.Q3_Comments1__c,Performance_Rating__r.Q3_Comments2__c,Performance_Rating__r.Q4_Comments1__c,Performance_Rating__r.Q4_Comments2__c,Performance_Rating__r.Comments1__c,Performance_Rating__r.Comments2__c,Performance_Rating__r.QPR_IV_Project_Associate_1__r.Name,Performance_Rating__r.QPR_IV_Project_Associate_2__r.Name,Performance_Rating__r.Reviewer_rating__c,Performance_Rating__r.ReviewerComments__c,Performance_Rating__r.Appraisal_Cycle__r.Manager_Rating_Weightage__c,Performance_Rating__r.Appraisal_Cycle__r.Self_Rating_Weightage__c ,Performance_Rating__r.Appraisal_Cycle__r.Reviewer_Rating_Weightage__c	
                                                            
                                                            from Performance_Rating_Item__c where Performance_Rating__c =: prId];
                    if(priList[0].Performance_Rating__r.Q3_Overall_Rating_Employee__c>0 && priList[0].Performance_Rating__r.Q3_Overall_Rating_Manager__c>0)
                    {
                        c=c+1;
                    }
                    if(priList[0].Performance_Rating__r.Q2_Overall_Rating_Employee__c>0 && priList[0].Performance_Rating__r.Q2_Overall_Rating_Manager__c>0)
                    {
                        c=c+1;
                    }
                    if(priList[0].Performance_Rating__r.Q1_Overall_Rating_Employee__c>0 && priList[0].Performance_Rating__r.Q1_Overall_Rating_Manager__c>0)
                    {
                        c=c+1;  
                    }
                    if(priList[0].Performance_Rating__r.Reviewer_rating__c!=null){

                       Decimal overallquaterselfrating=((priList[0].Performance_Rating__r.Q1_Overall_Rating_Employee__c+priList[0].Performance_Rating__r.Q2_Overall_Rating_Employee__c+priList[0].Performance_Rating__r.Q3_Overall_Rating_Employee__c+ priList[0].Performance_Rating__r.Q4_Overall_Rating_Employee__c)/c).setScale(1);
                       Decimal overallManagerrating=((priList[0].Performance_Rating__r.Q1_Overall_Rating_Manager__c+priList[0].Performance_Rating__r.Q2_Overall_Rating_Manager__c+priList[0].Performance_Rating__r.Q3_Overall_Rating_Manager__c+priList[0].Performance_Rating__r.Q4_Overall_Rating_Manager__c)/c).setScale(1);
                       Decimal finalRating=((priList[0].Performance_Rating__r.Reviewer_rating__c*(priList[0].Performance_Rating__r.Appraisal_Cycle__r.Reviewer_Rating_Weightage__c/100))+((priList[0].Performance_Rating__r.Appraisal_Cycle__r.Self_Rating_Weightage__c/100)*(overallquaterselfrating))+((priList[0].Performance_Rating__r.Appraisal_Cycle__r.Manager_Rating_Weightage__c/100)*(overallManagerrating))).setScale(1);
                       Performance_Rating__c Prfinal = new Performance_Rating__c();

                       Prfinal.Id=prId;
                       Prfinal.Final_Rating__c=finalRating;
                       Prfinal.Employee_Annual_Rating__c= overallquaterselfrating;
                       Prfinal.Manager_Annual_Rating__c= overallManagerrating;
                       update Prfinal;
                    }

                       return pr;

   
      
   
              
    }
   
       @AuraEnabled
        public static void updatemanagerdata(String del1,String del2,String comment1,String comment2,Id pId,String currentCycle ){
            Performance_Rating__c Pr = new Performance_Rating__c();
            System.debug('logLevel'+currentCycle );
            if(currentCycle=='QPR-I')
            {   
               pr.Id=pId;
               if(del1!=null && del1!='')
               {
                   pr.QPR_I_Project_Associate_1__c=del1;
                   pr.Q1_Comments1__c=(comment1!=null && comment1!='')?comment1:'';
               }
               if(del2!=null && del2!='')
               {
                  Pr.QPR_I_Project_Associate_2__c=del2;
                  pr.Q1_Comments2__c=(comment2!=null && comment2!='')?comment2:'';
               }
               update pr;

               
            }
            else if(currentCycle=='QPR-II')
            {
                pr.Id=pId;
               if(del1!=null && del1!='')
               {
                   pr.Delegated_Manager__c=del1;
                   pr.Comments1__c=(comment1!=null && comment1!='')?comment1:'';
               }
               if(del2!=null && del2!='')
               {
                  Pr.Delegated_Manager2__c=del2;
                  pr.Comments2__c=(comment2!=null && comment2!='')?comment2:'';
               }
                system.debug('pr'+pr);
               update pr;
            }
             else if(currentCycle=='QPR-III')
            {
                system.debug('del78798989'+del1);
                system.debug('comment1'+comment1);
                 pr.Id=pId;
               if(del1!=null && del1!='')
               {
                   pr.QPR_III_Project_Associate_1__c=del1;
                   pr.Q3_Comments1__c=(comment1!=null && comment1!='')?comment1:'';
               }
               if(del2!=null && del2!='')
               {
                  Pr.QPR_III_Project_Associate_2__c=del2;
                  pr.Q3_Comments2__c=(comment2!=null && comment2!='')?comment2:'';
               }
               update pr;
               
            }
             else if(currentCycle=='Annual Cycle')
            {
                system.debug('del78798989'+del1);
                system.debug('comment1'+comment1);
                 pr.Id=pId;
               if(del1!=null && del1!='')
               {
                   pr.QPR_IV_Project_Associate_1__c=del1;
                   pr.Q4_Comments1__c=(comment1!=null && comment1!='')?comment1:'';
               }
               if(del2!=null && del2!='')
               {
                  Pr.QPR_IV_Project_Associate_2__c=del2;
                  pr.Q4_Comments2__c=(comment2!=null && comment2!='')?comment2:'';
               }
               update pr;
               
            }

        }
        public class wrapData{
        @AuraEnabled
        public Map<String,List<Performance_Rating_Item__c>> KRAS;
        @AuraEnabled
        public string empName;
        @AuraEnabled
        public string status;
        @AuraEnabled
        public string reportingMngName;
        @AuraEnabled
        public string band;
        @AuraEnabled
        public string grade;
        @AuraEnabled
        public string desigination;
        @AuraEnabled
        public decimal Weightage;
        @AuraEnabled
        public boolean isManagerSubmitted;
        @AuraEnabled
        public boolean isReviewer;
        @AuraEnabled
        public boolean isEmpSubmitted;
        @AuraEnabled
        public string managerId;
        @AuraEnabled
        public string delegateManagerId;
        @AuraEnabled
        public string delegateManager2Id;
        @AuraEnabled
        public string employeeId;
        @AuraEnabled
        public string loggedInEmpId;
        @AuraEnabled
        public string delegateManager1FeedBack;
        @AuraEnabled
        public string delegateManager2FeedBack;
        @AuraEnabled
        public string currentQuarter;
        @AuraEnabled
        public string empCode;
        @AuraEnabled
        public string empLocation;
        @AuraEnabled
        public string empOverallComments;
        @AuraEnabled
        public string mngOverallComments;
        @AuraEnabled
        public double mngOverallRating;
        @AuraEnabled
        public double empOverallRating;
        @AuraEnabled
        public double reviewerRating;
        @AuraEnabled
        public double finalRating;
        @AuraEnabled
        public String reviewercommentsdata;
        @AuraEnabled
        public boolean isDelegateManagerSubmitted;
        @AuraEnabled
        public string ccm;
        @AuraEnabled
        public boolean isDelegateMg1Submitted;
        @AuraEnabled
        public boolean isDelegateMg2Submitted;
        @AuraEnabled
        public String delegateMg1Name;
        @AuraEnabled
        public String delegateMg2Name;
        @AuraEnabled
        public String rejectReason;
        @AuraEnabled
        public String ManagerComments1;
        @AuraEnabled
        public String ManagerComments2;
         @AuraEnabled
        public String AppraisalQuater;
        @AuraEnabled
        public double Q1selfRating;
        @AuraEnabled
        public double Q2selfRating;
        @AuraEnabled
        public double Q3selfRating;
        @AuraEnabled
        public double Q4selfRating;
        @AuraEnabled
        public double Q1manaRating;
        @AuraEnabled
        public double Q2manaRating;
        @AuraEnabled
        public double Q3manaRating;
        @AuraEnabled
        public double Q4manaRating;
        
    }
    
    public class reportiesWrappeData{
        @AuraEnabled
        public List<Performance_Rating__c> reportiesData;
        @AuraEnabled
        public List<Performance_Rating__c> delegateReportiesData;
        @AuraEnabled
        public string loggedInEmpId;
        public date currenyCycleStardDate;
        @AuraEnabled
        public date managerSubmissionStartDate;
        @AuraEnabled
        public date managerSubmissionEndDate;
        @AuraEnabled
        public date managerSubmissionExtensionEndDate;
        @AuraEnabled
        public boolean chkManagerSubmissionStartDate;
        @AuraEnabled
        public boolean chkManagerSubmissionEndDate;
        @AuraEnabled
        public string currentQuarter;
        @AuraEnabled
        public string appraisalCycleId;
        @AuraEnabled
        public string logInUserEmail;
        @AuraEnabled
        public Map<String,List<String>> employeeEmailTree = new Map<String,List<String>>();
        @AuraEnabled
        public map<String,Performance_Rating__c> employeeTreeData = new map<String,Performance_Rating__c>();
        @AuraEnabled
        public hierarchyWrapper reportiesDataTree = new hierarchyWrapper();   
    }
    public class ProjectManagersdata{
        @AuraEnabled
        public string projectassoc1;
        @AuraEnabled
        public string projectassoc2;
        @AuraEnabled
        public string comments1;
        @AuraEnabled
        public string comments2;
    }

}