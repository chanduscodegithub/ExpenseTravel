public without sharing class appraisalReviewOfEmpCtrlClone {
    private class CustomLogicException extends Exception {}
    
    @AuraEnabled(cacheable=true) 
    public static String getDetailsOfEmp(String empId,String selectedQuarter,String currentYr){   
        try{
            String currentYear = currentYr != '' ? currentYr : String.valueOf(system.today().year());
            
            Appraisal__c appraisalCycle = [Select id, Current_Cycle__c,Current_Cycle_Start_Date__c,Q1ManagerSubmissionStartDate__c,Q2_ManagerSubmissionStartDate__c,Q3_ManagerSubmissionStartDate__c,Q4_ManagerSubmissionStartDate__c,
                                           Q1ManagerSubmissionEndDate__c,Q2_ManagerSubmissionEndDate__c,Q3_ManagerSubmissionEndDate__c,Q4_ManagerSubmissionEndDate__c,
                                           Q1ManagerExtensionEndDate__c,Q2ManagerExtensionEndDate__c,Q3_ManagerExtensionEndDate__c,Q4_ManagerExtensionEndDate__c,	Q2_EmployeeSubmissionStartDate__c,Q2_EmployeeSubmissionEndDate__c,Q1EmployeeSubmissionStartDate__c,Q1EmployeeSubmissionEndDate__c,Q3_EmployeeSubmissionStartDate__c,Q3_EmployeeSubmissionEndDate__c,Q4_EmployeeSubmissionStartDate__c,Q4_EmployeeSubmissionEndDate__c
                                           from Appraisal__c  where QPR_Year__c =: currentYear limit 1];
            
            String currentQuarter = (selectedQuarter==''||selectedQuarter==null) ? appraisalCycle.Current_Cycle__c:selectedQuarter;
            
            if(empId == '' && selectedQuarter == ''){
                throw new CustomLogicException('Please select the year and quater');
            }
            
            Employee__c emp;
            if(empId != null && empId != ''){
                emp = [SELECT Id, Name, Email_ID__c,EmployeeID__c,Grade__c,Corporate_Band__c,Designation__r.Name,ReportingTo__c,ReportingTo__r.Name,BU_Head__r.Name,Country__c
                       FROM Employee__c where Id =:empId];
            }else{
                emp = [SELECT Id, Name, Email_ID__c,EmployeeID__c,Grade__c,Corporate_Band__c,Designation__r.Name,ReportingTo__c,ReportingTo__r.Name,BU_Head__r.Name,Country__c
                       FROM Employee__c where Email_ID__c =:UserInfo.getUserEmail()];
            }
            
            //System.debug('emp'+emp);
            List<Performance_Rating_Item__c> perRating = [Select Id,Performance_Rating__c,Goal_Setting__c,Status__c,Name,KPI__c,Weightage__c,Employee_Rating__c,Employee_Comments__c,
                                                          Performance_Rating__r.Q1_Employee_Overall_Comments__c,Performance_Rating__r.Q2_Employee_Overall_Comments__c,
                                                          Performance_Rating__r.Q3_Employee_Overall_Comments__c,Performance_Rating__r.Q4_Employee_Overall_Comments__c,
                                                          Performance_Rating__r.Delegated_Manager__c,Performance_Rating__r.Delegated_Manager2__c,Performance_Rating__r.Status__c,Goal_Setting__r.Status__c
                                                          from Performance_Rating_Item__c where Goal_Setting__r.Employee__c =: emp.Id and Quater__c =: currentQuarter
                                                          and Appraisal__c = 'Quater' and Performance_Rating__r.Appraisal_Cycle__r.QPR_Year__c =: currentYear
                                                          order by Goal_Setting__r.Goal_Repository__r.KRA_order__c asc];
            
            String empcomments;
            System.debug('~~perRating -- '+perRating);
            if(!(perRating.size() > 0)){
                return null;
            }else if(perRating[0].Goal_Setting__r.Status__c != 'CCM Approved' && selectedQuarter != '' && currentYear != '2023'){
                throw new CustomLogicException('You can\'t submit your self appraisal until your CCM is not Approved Your Goals.');
            }
            
            if(currentQuarter == 'QPR-I'){
                empcomments = perRating[0].Performance_Rating__r.Q1_Employee_Overall_Comments__c;
            }else if(currentQuarter == 'QPR-II'){
                empcomments = perRating[0].Performance_Rating__r.Q2_Employee_Overall_Comments__c;
            }else if(currentQuarter == 'QPR-III'){
                empcomments = perRating[0].Performance_Rating__r.Q3_Employee_Overall_Comments__c;
            }else{
                empcomments = perRating[0].Performance_Rating__r.Q4_Employee_Overall_Comments__c;
            }
            
            Map<Id,List<Performance_Rating_Item__c>> mappedGoalSetting = new Map<Id,List<Performance_Rating_Item__c>>();
            
            for(Performance_Rating_Item__c per : perRating){
                if(mappedGoalSetting.containsKey(per.Goal_Setting__c)){
                    mappedGoalSetting.get(per.Goal_Setting__c).add(per);
                }else{
                    mappedGoalSetting.put(per.Goal_Setting__c, new List<Performance_Rating_Item__c>{per});
                }
            }
            
            Map<Id,Goal_Setting__c> allGoalSetting = new Map<Id,Goal_Setting__c>([SELECT Id, Name,Goal_Repository__r.Name,Goal_Repository__r.Description__c,Total_KRA_Weightage__c,Description__c,KRA_Discription__c,Is_KRA_Edited__c,Is_KRA_Weightage_Edited__c,KRA_Weightage__c
                                                                                  FROM Goal_Setting__c WHERE Id IN : mappedGoalSetting.keySet()]);
            
            List<KRAWrapper> allKRAWrapper = new List<KRAWrapper>();
            
            Boolean displayTotalScore = FALSE;
            
            for(Id per : mappedGoalSetting.keySet()){
                KRAWrapper KRAWrap = new KRAWrapper();
                List<KPIWrapper> AllKPIWrapper = new List<KPIWrapper>();
                Decimal TotalPercentage = 0;
                for(Performance_Rating_Item__c PerRatingItem : mappedGoalSetting.get(per)){
                    
                    TotalPercentage += PerRatingItem.Weightage__c;
                    
                    KPIWrapper KPIWrap = new KPIWrapper();
                    KPIWrap.KPI = PerRatingItem.KPI__c;
                    KPIWrap.KPIWeightage = String.valueOf(PerRatingItem.Weightage__c.setScale(0) + '%');
                    KPIWrap.EmpRating = String.valueOf(PerRatingItem.Employee_Rating__c!= null ? PerRatingItem.Employee_Rating__c.stripTrailingZeros() : PerRatingItem.Employee_Rating__c);
                    KPIWrap.EmpComment = PerRatingItem.Employee_Comments__c;
                    KPIWrap.Id = PerRatingItem.Id;
                    if(PerRatingItem.Performance_Rating__r.Status__c == 'QPR-II Emp Submitted' || PerRatingItem.Performance_Rating__r.Status__c == 'QPR-II Manager submitted'){
                        KPIWrap.NoEdit = TRUE;
                        displayTotalScore = TRUE;
                        System.debug('here::');
                    }else if(PerRatingItem.Performance_Rating__r.Status__c == 'QPR-I Emp Submitted' || PerRatingItem.Performance_Rating__r.Status__c == 'QPR-I Manager submitted'||appraisalCycle.Current_Cycle__c!=selectedQuarter){
                        KPIWrap.NoEdit = TRUE;
                        displayTotalScore = TRUE;
                    }else if(PerRatingItem.Performance_Rating__r.Status__c == 'QPR-III Emp Submitted' || PerRatingItem.Performance_Rating__r.Status__c == 'QPR-III Manager submitted'||appraisalCycle.Current_Cycle__c!=selectedQuarter){
                        KPIWrap.NoEdit = TRUE;
                        displayTotalScore = TRUE;
                    }else if(PerRatingItem.Performance_Rating__r.Status__c == 'QPR-IV/Annual Review Manager submitted' || PerRatingItem.Performance_Rating__r.Status__c == 'QPR-IV/Annual Review Emp Submitted'||appraisalCycle.Current_Cycle__c!=selectedQuarter){
                        KPIWrap.NoEdit = TRUE;
                        displayTotalScore = TRUE;
                    }
                    else if(PerRatingItem.Performance_Rating__r.Status__c=='Reviewer Submitted')
                    {
                        KPIWrap.NoEdit = TRUE;
                        displayTotalScore = TRUE;
                    }
                    else{
                        KPIWrap.NoEdit = FALSE;
                    }
                    AllKPIWrapper.add(KPIWrap);
                }
                KRAWrap.KRA = allGoalSetting.get(per).Goal_Repository__r.Name;
                KRAWrap.TotalKRAWieghteage = String.valueOf(TotalPercentage.setScale(0))+'%';
                //KRAWrap.KRAdiscription = 'Develop and execute comprehensive brand strategies to enhance brand equity and awareness.';
                KRAWrap.KRAdiscription = !allGoalSetting.get(per).Is_KRA_Edited__c ? allGoalSetting.get(per).Goal_Repository__r.Description__c : allGoalSetting.get(per).KRA_Discription__c ;
                KRAWrap.perstatus = perRating[0].Performance_Rating__r.Status__c;
                KRAWrap.childWrapperDetails = AllKPIWrapper;
                allKRAWrapper.add(KRAWrap);
            }
            
            ParentWrapperDetails wrap = new ParentWrapperDetails();
            wrap.EmpDetails = emp;
            wrap.appraisal = appraisalCycle;
            wrap.PerformanceId = perRating[0].Performance_Rating__c;
            wrap.DelegatedManger1 = perRating[0].Performance_Rating__r.Delegated_Manager__c; //perRating[0].Performance_Rating__r.Delegated_Manager__c != null ? perRating[0].Performance_Rating__r.Delegated_Manager__c : '';
            wrap.DelegatedManger2 = perRating[0].Performance_Rating__r.Delegated_Manager__c; //perRating[0].Performance_Rating__r.Delegated_Manager2__c != null ? perRating[0].Performance_Rating__r.Delegated_Manager2__c : '';
            wrap.EmpComments = empcomments;
            wrap.displayTotalScoreInlwc = displayTotalScore;
            wrap.KRAWrapperDetails = allKRAWrapper;
            wrap.Status=perRating[0].Performance_Rating__r.Status__c;
            if(UserInfo.getUserEmail()==emp.Email_ID__c)
            {
                wrap.isEmpLogIn = TRUE;
            }
            else{
                wrap.isEmpLogIn = false;
            }
            //System.debug('wrap::'+wrap);
            
            return JSON.serialize(wrap);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled(Cacheable=false)
    public static String saveAsDraft(String datalist,String futurePotentials,String PerId,String DraftOrSubmitted){
        try{
            String currentYear = String.valueOf(system.today().year());
            Appraisal__c appraisalCycle = [Select id, Current_Cycle__c
                                           from Appraisal__c  where QPR_Year__c =: currentYear limit 1];
            String currentQuarter = appraisalCycle.Current_Cycle__c;
            //String currentQuarter = 'Q'+ String.valueOf( Integer.valueOf(Math.ceil(System.today().month() / 3)));
            List<KRAWrapper> allKPIWrapper = (List<KRAWrapper>) JSON.deserialize(datalist, List<KRAWrapper>.class);
            List<Performance_Rating_Item__c> allPerformanceRatingItem = new List<Performance_Rating_Item__c>();
            
            for(KRAWrapper kpi : allKPIWrapper){
                for(KPIWrapper child : kpi.childWrapperDetails){
                    if(child.EmpRating != null || child.EmpComment != null){
                        Performance_Rating_Item__c perRatingItem = new Performance_Rating_Item__c();
                        perRatingItem.Id = child.Id;
                        perRatingItem.Employee_Rating__c = Decimal.valueOf(child.EmpRating);
                        
                        if(child.EmpRating != null){
                            perRatingItem.KRA_Weightage_New__c = Decimal.valueOf(child.EmpRating) * ( Decimal.valueOf(child.KPIWeightage.replace('%','')) / 100 );
                        }if(child.EmpComment != null){
                            perRatingItem.Employee_Comments__c = child.EmpComment;
                        }
                        if(DraftOrSubmitted == 'Draft'){
                            perRatingItem.Status__c = 'In progress';
                            
                        }else{
                            //checkEmpSubmitted = TRUE;
                            perRatingItem.Status__c = 'Employee Submitted';
                            perRatingItem.Employee_Submitted_Date__c = System.now();
                        }
                        
                        allPerformanceRatingItem.add(perRatingItem);
                    }
                }  
            }
            if(futurePotentials != null){
                Performance_Rating__c per = new Performance_Rating__c();
                per.Id = PerId;
                
                if(currentQuarter == 'QPR-I'){
                    per.Q1_Employee_Overall_Comments__c = futurePotentials;
                    if(DraftOrSubmitted != 'Draft'){
                        per.Status__c = 'QPR-I Emp Submitted';
                    }
                }else if(currentQuarter == 'QPR-II'){
                    per.Q2_Employee_Overall_Comments__c = futurePotentials;
                    if(DraftOrSubmitted != 'Draft'){
                        per.Status__c = 'QPR-II Emp Submitted';
                    }
                }else if(currentQuarter == 'QPR-III'){
                    per.Q3_Employee_Overall_Comments__c = futurePotentials;
                    if(DraftOrSubmitted != 'Draft'){
                        per.Status__c = 'QPR-III Emp Submitted';
                    }
                }else if(currentQuarter == 'Annual Cycle'){
                    per.Q4_Employee_Overall_Comments__c = futurePotentials;
                    if(DraftOrSubmitted != 'Draft'){
                        per.Status__c = 'QPR-IV/Annual Review Emp Submitted';
                    }
                }
                update per;
                //System.debug('per::'+per);
            }
            
            if(allPerformanceRatingItem.size() > 0){
                update allPerformanceRatingItem;
                //System.debug('exp::'+allPerformanceRatingItem);
                return 'success';
            }
            
            
        }catch(Exception e){
            throw new AuraHandledException(e.getStackTraceString() +'-'+ e.getMessage());
        }
        return null;
    }
    
    public class ParentWrapperDetails{
        @AuraEnabled
        public Employee__c EmpDetails;
        @AuraEnabled
        public Appraisal__c appraisal;
        @AuraEnabled
        public String PerformanceId;
        @AuraEnabled
        public String DelegatedManger1;
        @AuraEnabled
        public String DelegatedManger2;
        @AuraEnabled
        public String EmpComments;
        @AuraEnabled
        public String Status;
        @AuraEnabled
        public Boolean displayTotalScoreInlwc;
        @AuraEnabled
        public Boolean isEmpLogIn;
        
        @AuraEnabled
        public List<KRAWrapper> KRAWrapperDetails;
    }
    public class KRAWrapper{
        @AuraEnabled
        public String perstatus;
        @AuraEnabled
        public String KRA;
        @AuraEnabled
        public String TotalKRAWieghteage;
        @AuraEnabled
        public String KRAdiscription;
        @AuraEnabled
        public String PerformanceRatingId;
        @AuraEnabled
        public List<KPIWrapper> childWrapperDetails;
    }
    public class KPIWrapper{
        @AuraEnabled
        public String KPI;
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String KPIWeightage;
        @AuraEnabled
        public String EmpRating;
        @AuraEnabled
        public String EmpComment;
        @AuraEnabled
        public Boolean NoEdit;
    } 
}