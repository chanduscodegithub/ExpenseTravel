@isTest
public class appraisalReviewofEmpCtrltest {
    @isTest
    static void testLoadData() 
    {
     String currentQuarter = 'Q'+String.valueOf(math.round((System.today().month())/3.0));
        Employee__c Emp1 = new Employee__c();
        Emp1.Name='Aneesh Vemireddy';
        Emp1.Email_ID__c='aneesh.vemireddy@crmit.com';
        Emp1.Country__c='India';
        Emp1.Grade__c='M1';
        insert Emp1;
        Employee__c Emp = new Employee__c();
        Emp.Name='Test';
        Emp.Email_ID__c='tejasree.vuchuru@crmit.com';
        Emp.Country__c='India';
        Emp.Grade__c='M1';
        Emp.ReportingTo__c=Emp1.Id;
        insert Emp;
        Employee__c Emp2 = new Employee__c();
        Emp2.Name='Test1';
        Emp2.Email_ID__c='tejasree2.vuchuru@crmit.com';
        Emp2.Country__c='India';
        Emp2.Grade__c='M1';
        Emp2.ReportingTo__c=Emp1.Id;
        insert Emp2;
        Employee__c Emp3 = new Employee__c();
        Emp3.Name='Test2';
        Emp3.Email_ID__c='tejasree3.vuchuru@crmit.com';
        Emp3.Country__c='India';
        Emp3.Grade__c='M1';
        Emp3.ReportingTo__c=Emp1.Id;
        insert Emp3;
        //Appraisal__c Ap=[select id,Name,QPR_Start_Date__c,QPR_End_Date__c,Type__c,Current_Cycle__c,Current_Cycle_Start_Date__c,Q2_EmployeeSubmissionStartDate__c,Q2_EmployeeSubmissionEndDate__c,Q2_ManagerSubmissionStartDate__c,Q2_ManagerSubmissionEndDate__c,QPR_Year__c where Current_Cycle__c='Q2'];
        Appraisal__c Ap= new Appraisal__c();
        Ap.Name='2023 - Quarterly - Q2';
        Ap.QPR_Start_Date__c=Date.newInstance(2023, 1, 1);
        Ap.QPR_End_Date__c=system.today()+30;
        Ap.Type__c='Quarterly';
        Ap.Current_Cycle__c='Q2';
        Ap.Current_Cycle_Start_Date__c=system.today()+20;
        Ap.Q2_EmployeeSubmissionStartDate__c=system.today()+22;
        Ap.Q2_EmployeeSubmissionEndDate__c=system.today()+25;
        Ap.Q2_ManagerSubmissionStartDate__c=system.today()+26;
        Ap.Q2_ManagerSubmissionEndDate__c=system.today()+30;
        Ap.QPR_Year__c ='2023';
        insert Ap;
        Goal_Repository__c GR= new Goal_Repository__c();
        GR.Name='Continuous Improvement';
        GR.Band__c='B1';
        GR.Level__c='L1';
        GR.Goal_Category__c='Continuous Improvement';
        GR.KRA_order__c=1;
        GR.Status__c='Active';
        insert GR;
        Goal_Setting__c Gs = new Goal_Setting__c();
        Gs.Goal_Repository__c=GR.Id;
        Gs.KPI_1__c='KPI 1';
        Gs.KPI_1_Weightage__c=20;
        Gs.KPI_2__c='KPI 2';
        Gs.KPI_2_Weightage__c=20;
        Gs.KPI_3__c='KPI 3';
        Gs.KPI_3_Weightage__c=20;
        Gs.KPI_4__c='KPI 4';
        Gs.KPI_4_Weightage__c=20;
        Gs.KPI_5__c='KPI 5';
        Gs.KPI_5_Weightage__c=20;
        Gs.Employee__c=Emp.Id;
        insert Gs;
        Performance_Rating__c PR= new Performance_Rating__c();
        PR.Employee__c=Emp.Id;
        PR.Manager__c=Emp1.Id;
        PR.Appraisal_Cycle__c=Ap.Id;
        PR.Delegated_Manager__c=Emp2.id;
        PR.Delegated_Manager2__c=Emp3.Id;
        PR.Q2_Employee_Overall_Comments__c='good';
        
        Insert PR;
        List<Performance_Rating_Item__c> PRI = new List<Performance_Rating_Item__c>();
        
        for(Integer i=0;i<=5;i++)
        {
            Performance_Rating_Item__c PRIs= new  Performance_Rating_Item__c();
            PRIs.Performance_Rating__c=PR.Id;
            PRIs.KPI__c='KPI'+i;
            PRIs.Weightage__c=20;
            PRIs.Appraisal__c='Quater';
            PRIs.Quater__c='Q2';
            PRIs.Goal_Setting__c=Gs.Id;
            PRI.add(PRIs);
            
        }
        insert PRI;
        appraisalReviewOfEmpCtrlClone.getDetailsOfEmp();
    }
        
        @isTest
    static void testLoadData1() 
    {
         String currentQuarter = 'Q'+String.valueOf(math.round((System.today().month())/3.0));
        Employee__c Emp1 = new Employee__c();
        Emp1.Name='Aneesh Vemireddy';
        Emp1.Email_ID__c='aneesh.vemireddy@crmit.com';
        Emp1.Country__c='India';
        Emp1.Grade__c='M1';
        insert Emp1;
        Employee__c Emp = new Employee__c();
        Emp.Name='Test';
        Emp.Email_ID__c='tejasree.vuchuru@crmit.com';
        Emp.Country__c='India';
        Emp.Grade__c='M1';
        Emp.ReportingTo__c=Emp1.Id;
        insert Emp;
        Employee__c Emp2 = new Employee__c();
        Emp2.Name='Test1';
        Emp2.Email_ID__c='tejasree2.vuchuru@crmit.com';
        Emp2.Country__c='India';
        Emp2.Grade__c='M1';
        Emp2.ReportingTo__c=Emp1.Id;
        insert Emp2;
        Employee__c Emp3 = new Employee__c();
        Emp3.Name='Test2';
        Emp3.Email_ID__c='tejasree3.vuchuru@crmit.com';
        Emp3.Country__c='India';
        Emp3.Grade__c='M1';
        Emp3.ReportingTo__c=Emp1.Id;
        insert Emp3;
        //Appraisal__c Ap=[select id,Name,QPR_Start_Date__c,QPR_End_Date__c,Type__c,Current_Cycle__c,Current_Cycle_Start_Date__c,Q2_EmployeeSubmissionStartDate__c,Q2_EmployeeSubmissionEndDate__c,Q2_ManagerSubmissionStartDate__c,Q2_ManagerSubmissionEndDate__c,QPR_Year__c where Current_Cycle__c='Q2'];
        Appraisal__c Ap= new Appraisal__c();
        Ap.Name='2023 - Quarterly - Q2';
        Ap.QPR_Start_Date__c=Date.newInstance(2023, 1, 1);
        Ap.QPR_End_Date__c=system.today()+30;
        Ap.Type__c='Quarterly';
        Ap.Current_Cycle__c='Q2';
        Ap.Current_Cycle_Start_Date__c=system.today()+20;
        Ap.Q2_EmployeeSubmissionStartDate__c=system.today()+22;
        Ap.Q2_EmployeeSubmissionEndDate__c=system.today()+25;
        Ap.Q2_ManagerSubmissionStartDate__c=system.today()+26;
        Ap.Q2_ManagerSubmissionEndDate__c=system.today()+30;
        Ap.QPR_Year__c ='2023';
        insert Ap;
        Goal_Repository__c GR= new Goal_Repository__c();
        GR.Name='Continuous Improvement';
        GR.Band__c='B1';
        GR.Level__c='L1';
        GR.Goal_Category__c='Continuous Improvement';
        GR.KRA_order__c=1;
        GR.Status__c='Active';
        insert GR;
        Goal_Setting__c Gs = new Goal_Setting__c();
        Gs.Goal_Repository__c=GR.Id;
        Gs.KPI_1__c='KPI 1';
        Gs.KPI_1_Weightage__c=20;
        Gs.KPI_2__c='KPI 2';
        Gs.KPI_2_Weightage__c=20;
        Gs.KPI_3__c='KPI 3';
        Gs.KPI_3_Weightage__c=20;
        Gs.KPI_4__c='KPI 4';
        Gs.KPI_4_Weightage__c=20;
        Gs.KPI_5__c='KPI 5';
        Gs.KPI_5_Weightage__c=20;
        Gs.Employee__c=Emp.Id;
        insert Gs;
        Performance_Rating__c PR= new Performance_Rating__c();
        PR.Employee__c=Emp.Id;
        PR.Manager__c=Emp1.Id;
        PR.Appraisal_Cycle__c=Ap.Id;
        PR.Delegated_Manager__c=Emp2.id;
        PR.Delegated_Manager2__c=Emp3.Id;
        PR.Q2_Employee_Overall_Comments__c='good';
        
        Insert PR;
        List<Performance_Rating_Item__c> PRI = new List<Performance_Rating_Item__c>();
        
        for(Integer i=0;i<=5;i++)
        {
            Performance_Rating_Item__c PRIs= new  Performance_Rating_Item__c();
            PRIs.Performance_Rating__c=PR.Id;
            PRIs.KPI__c='KPI'+i;
            PRIs.Weightage__c=20;
            PRIs.Appraisal__c='Quater';
            PRIs.Quater__c='Q2';
            PRIs.Goal_Setting__c=Gs.Id;
            PRI.add(PRIs);
            
        }
        insert PRI;

        
        appraisalReviewOfEmpCtrlClone.KPIWrapper kpiWrapper = new appraisalReviewOfEmpCtrlClone.KPIWrapper();
        kpiWrapper.KPI = 'Test KPI';
        kpiWrapper.Id = PRI[0].Id;
        kpiWrapper.KPIWeightage = '10%';
        kpiWrapper.EmpRating = '4.5';
        kpiWrapper.EmpComment = 'Test Comment';
        kpiWrapper.NoEdit = false;
           
        appraisalReviewOfEmpCtrlClone.KRAWrapper kraWrapper = new appraisalReviewOfEmpCtrlClone.KRAWrapper();
        kraWrapper.KRA = 'Test KRA';
        kraWrapper.TotalKRAWieghteage = '50%';
        kraWrapper.KRAdiscription = 'Test Description';
        kraWrapper.PerformanceRatingId = PR.Id;
        kraWrapper.childWrapperDetails = new List<appraisalReviewOfEmpCtrlClone.KPIWrapper>{kpiWrapper};
        List< appraisalReviewOfEmpCtrlClone.KRAWrapper> kraWrappers = new List< appraisalReviewOfEmpCtrlClone.KRAWrapper>{kraWrapper};
       
        
        // Convert parentWrapper to JSON format
        String dataList = JSON.serialize(kraWrappers);
        system.debug('dataList'+dataList);
        appraisalReviewOfEmpCtrlClone.saveAsDraft(dataList, 'futurePotentials', PR.Id, 'Draft');
        
    }

}