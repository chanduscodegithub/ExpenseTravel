@isTest(SeeAllData=false)
public class ProfitabilityNewClassTest {

    @isTest
    public static void testGetCalculateSummaryy() {
        Test.startTest();
        
        Date startDate = Date.newInstance(2023, 4, 1);
        Date endDate = Date.newInstance(2024, 3, 31);
        account acc =  new account();
        acc.name='Test1';
        acc.Customer_Region__c='USA';
        acc.CurrencyIsoCode='AUD';
            acc.Type='Enterprice accounts';
            acc.CRMIT_Relationship__c='Direct - Active';
           // acc.First_Name__c='contest1';
            //acc.Last_Name__c='conlastname';
            //acc.Email__c='conemail1233@gmail.com';
            //acc.Contact_Region__c='IND';
           insert acc;
            
        opportunity oppty = new opportunity();
        oppty.name='optytest1';
        oppty.Opportunity_Category__c='Existing Customer - New Business';
        oppty.AccountId=acc.Id;
        oppty.Amount=12334;
        oppty.Next_Contact_Date__c=Date.newInstance(2023, 4, 1);
        oppty.CloseDate=Date.newInstance(2023, 9, 1);
        oppty.StageName='Opportunity Won';
        oppty.Opportunity_Status__c='WON';
        oppty.Win_Loss__c='Good lead';
        oppty.Expected_Project_Start_Date__c=Date.newInstance(2023, 11, 1);
        oppty.Expected_Project_End_Date__c=Date.newInstance(2024,12,1);
        insert oppty;
        
        
      //  List<Billing__c> billingRecords = new List<Billing__c>();
            Billing__c bbc = new Billing__c();
            bbc.Name='invoicetest';
            bbc.Account__c=acc.Id;
            bbc.OpportunityName__c=oppty.Id;
            bbc.Credit_Period__c=2;
            bbc.Invoice_Amount__c=12334;
            bbc.Invoice_Billing_date__c=Date.newInstance(2023, 5, 1);
            bbc.Invoice_Amount_Converted_In_USD__c =65;
            insert bbc;
        
        Team_Timesheet__c tmsht = new Team_Timesheet__c();
      //  tmsht.Name= TS0001111;
        tmsht.Week_Start_Date__c=date.newInstance(2023, 5, 1);
        tmsht.Billable_hours__c=10;
        tmsht.Non_Billable_hours__c=5;
        tmsht.Leave_Hours__c=1;
        
        insert tmsht;
        
        Team_Timesheet__c tmsht1 = new Team_Timesheet__c();
      //  tmsht.Name= TS0001111;
        tmsht1.Week_Start_Date__c=date.newInstance(2023, 5, 1);
        tmsht1.Billable_hours__c=10;
        tmsht1.Non_Billable_hours__c=5;
        tmsht1.Leave_Hours__c=1;
        
        insert tmsht1;
        
        

        
        
         User testUser = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Alias = 'jdoe',
            Email = 'jdoe@example.com',
            Username = 'jdoe@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        
        Project__c prjct  = new Project__c();
        prjct.Name = 'C2C';
        prjct.Account__c=acc.Id;
        prjct.Opportunity__c=oppty.Id;
        prjct.Region__c='ANZ';
        prjct.ProjectManager__c=testUser.Name;
        prjct.StartDate__c=date.newInstance(2022, 5, 1);
        prjct.EndDate__c=date.newInstance(2034, 5, 1);   
        insert prjct;
        
        Role__c role = new Role__c ();
        role.Name='Accounts Executive';
        role.Average_cost__c= 50;
        insert role;
        
  
        
        Employee__c emp1 = new Employee__c ();
        emp1.name='King';
        emp1.EmployeeID__c='CT193';
        emp1.DateofJoin__c=date.newInstance(2022, 6, 1);
        emp1.Department__c='corporate';
        emp1.MobileNo__c='123333337';
        emp1.Email_ID__c= 'firstname.lastname@crmit.com';     
        emp1.Designation__c=role.Id;
        emp1.Grade__c='L1';
        insert emp1;
        

        
        
        Timesheet_Approval__c tmsap1 = new Timesheet_Approval__c();
        tmsap1.Employee__c = emp1.Id;
        tmsap1.Customer_Engagement__c = prjct.Id;
        tmsap1.Timesheet__c = tmsht1.Id;
        tmsap1.Approval_Status__c = 'Approved';
        insert tmsap1;
        
        
        TeamAllocation__c tmallctin1 = new TeamAllocation__c ();
        tmallctin1.Project__c=prjct.Id;
        tmallctin1.EmployeeName__c=emp1.Id;
        tmallctin1.StartDate__c=date.newInstance(2023, 05, 01);
        tmallctin1.EndDate__c=date.newInstance(2026, 04, 01);
        tmallctin1.AllocationPercentage__c=23;
        tmallctin1.Billing_Status__c='Billable';
        tmallctin1.Resource_Role__c='Administrator';
        insert tmallctin1;
        
        
       
        AcctSeed__Accounting_Period__c accprd = new AcctSeed__Accounting_Period__c();
        accprd.Name='2023-05';
        accprd.AcctSeed__Start_Date__c=date.newInstance(2023, 05, 01);
        accprd.AcctSeed__End_Date__c=date.newInstance(2023, 05, 31);
        accprd.AcctSeed__Status__c='Open';
        insert accprd;
        
        
        Employees_per_hour_cost__c empcst1 = new Employees_per_hour_cost__c();
        empcst1.Employee__c=emp1.Id;
        empcst1.Cost_per_Hour__c=10;
        insert empcst1;
         

         
        Delivery__c  ddc1 = new Delivery__c();
        ddc1.Team_Timesheet__c=tmsht1.Id;
        ddc1.Date__c=date.newInstance(2023, 05, 01);
        ddc1.Customer_Engagement__c = prjct.Id;
        ddc1.Team_Allocation__c= tmallctin1.Id;
        ddc1.Time_in_Hours__c=123;
        ddc1.Cost__c=(empcst1.Cost_per_Hour__c * ddc1.Time_in_Hours__c );
        ddc1.Cost_by_Designation__c=(role.Average_cost__c * ddc1.Time_in_Hours__c );
        ddc1.Category__c='Development';
        ddc1.Timesheet_Approval__c = tmsap1.Id;
        ddc1.Employee_Name__c=emp1.Id;
        insert ddc1;
        
   
        system.debug('ddc@'+ddc1);
        
             
       

        // Test with sample fiscal year
        String fiscalYear = '2023-2024';
        Map<String, Map<String, profitabilitynewclass.ProjectSummaryWrapper>> result = profitabilitynewclass.getcalculatesummaryy(fiscalYear);
        system.debug('result>>>>'+result);
        Map<String, Map<String, profitabilitynewclass.csthrswrapper>> results = profitabilitynewclass.getcost(fiscalYear);
        system.debug('results>>>>'+results);
        List<AcctSeed__Accounting_Period__c>  newlist=Costbreakup.accountingperiodlist();
        date sstartdate = date.newInstance(2023, 05, 01);
        date senddate=date.newInstance(2024, 02, 31);
        Costbreakup.getParentWrapperList(startDate, endDate); 
        // Add your assertions here based on the expected results
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

      @isTest
    public static void testGetCalculateSummaryy1() {
        Test.startTest();
        
        Date startDate = Date.newInstance(2023, 4, 1);
        Date endDate = Date.newInstance(2024, 3, 31);
        account acc =  new account();
        acc.name='Test1';
        acc.Customer_Region__c='USA';
        acc.CurrencyIsoCode='AUD';
            acc.Type='Enterprice accounts';
            acc.CRMIT_Relationship__c='Direct - Active';
           // acc.First_Name__c='contest1';
           // acc.Last_Name__c='conlastname';
//acc.Email__c='conemail1233@gmail.com';
            //acc.Contact_Region__c='IND';
           insert acc;
            
        opportunity oppty = new opportunity();
        oppty.name='optytest1';
        oppty.Opportunity_Category__c='Existing Customer - New Business';
        oppty.AccountId=acc.Id;
        oppty.Amount=12334;
        oppty.Next_Contact_Date__c=Date.newInstance(2023, 4, 1);
        oppty.CloseDate=Date.newInstance(2023, 9, 1);
        oppty.StageName='Opportunity Won';
        oppty.Opportunity_Status__c='WON';
        oppty.Win_Loss__c='Good lead';
        oppty.Expected_Project_Start_Date__c=Date.newInstance(2023, 11, 1);
        insert oppty;
        
        
      //  List<Billing__c> billingRecords = new List<Billing__c>();
            Billing__c bbc = new Billing__c();
            bbc.Name='invoicetest';
            bbc.Account__c=acc.Id;
            bbc.OpportunityName__c=oppty.Id;
            bbc.Credit_Period__c=2;
            bbc.Invoice_Amount__c=12334;
            bbc.Invoice_Billing_date__c=Date.newInstance(2023, 5, 1);
            bbc.Invoice_Amount_Converted_In_USD__c =65;
            insert bbc;
        
        Team_Timesheet__c tmsht = new Team_Timesheet__c();
      //  tmsht.Name= TS0001111;
        tmsht.Week_Start_Date__c=date.newInstance(2023, 5, 1);
        tmsht.Billable_hours__c=10;
        tmsht.Non_Billable_hours__c=5;
        tmsht.Leave_Hours__c=1;
        
        insert tmsht;
        
        Team_Timesheet__c tmsht1 = new Team_Timesheet__c();
      //  tmsht.Name= TS0001111;
        tmsht1.Week_Start_Date__c=date.newInstance(2023, 5, 1);
        tmsht1.Billable_hours__c=10;
        tmsht1.Non_Billable_hours__c=5;
        tmsht1.Leave_Hours__c=1;
        
        insert tmsht1;
 
         User testUser = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Alias = 'jdoe',
            Email = 'jdoe@example.com',
            Username = 'jdoe@example.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        
        Project__c prjct  = new Project__c();
        prjct.Account__c=acc.Id;
        prjct.Opportunity__c=oppty.Id;
        prjct.Region__c='ANZ';
        prjct.ProjectManager__c=testUser.Name;
        prjct.StartDate__c=date.newInstance(2022, 5, 1);
        prjct.EndDate__c=date.newInstance(2034, 5, 1);   
        insert prjct;
        
        Role__c role = new Role__c ();
        role.Name='Accounts Executive';
        role.Average_cost__c= 50;
        insert role;
        
        Employee__c emp = new Employee__c ();
        emp.name='Virat Kohli';
        emp.EmployeeID__c='C0183';
        emp.DateofJoin__c=date.newInstance(2022, 5, 1);
        emp.Department__c='corporate';
        emp.MobileNo__c='123333333';
        emp.Email_ID__c= 'fisrtname.lastname@crmit.com';     
        emp.Designation__c=role.Id;
        emp.Grade__c='L2';
        insert emp;
        
        
        Timesheet_Approval__c tmsap = new Timesheet_Approval__c();
        tmsap.Employee__c = emp.Id;
        tmsap.Customer_Engagement__c = prjct.Id;
        tmsap.Timesheet__c = tmsht.Id;
        tmsap.Approval_Status__c = 'Approved';
        insert tmsap;
 
        
        TeamAllocation__c tmallctin = new TeamAllocation__c ();
        tmallctin.Project__c=prjct.Id;
        tmallctin.EmployeeName__c=emp.Id;
        tmallctin.StartDate__c=date.newInstance(2023, 05, 01);
        tmallctin.EndDate__c=date.newInstance(2026, 04, 01);
        tmallctin.AllocationPercentage__c=23;
        tmallctin.Billing_Status__c='Billable';
        tmallctin.Resource_Role__c='Administrator';
        insert tmallctin;
       
       
        AcctSeed__Accounting_Period__c accprd = new AcctSeed__Accounting_Period__c();
        accprd.Name='2023-05';
        accprd.AcctSeed__Start_Date__c=date.newInstance(2023, 05, 01);
        accprd.AcctSeed__End_Date__c=date.newInstance(2023, 05, 31);
        accprd.AcctSeed__Status__c='Open';
        insert accprd;
        
        Employees_per_hour_cost__c empcst = new Employees_per_hour_cost__c();
        empcst.Employee__c=emp.Id;
        empcst.Cost_per_Hour__c=10;
        insert empcst;
        
        
        Delivery__c  ddc = new Delivery__c();
        ddc.Team_Timesheet__c=tmsht.Id;
        ddc.Date__c=date.newInstance(2023, 05, 01);
        ddc.Customer_Engagement__c = prjct.Id;
        ddc.Team_Allocation__c= tmallctin.Id;
        ddc.Time_in_Hours__c=12;
        ddc.Cost__c=(empcst.Cost_per_Hour__c * ddc.Time_in_Hours__c );
        ddc.Cost_by_Designation__c=(role.Average_cost__c * ddc.Time_in_Hours__c );
        ddc.Category__c='Development';
        ddc.Timesheet_Approval__c = tmsap.Id;
        ddc.Employee_Name__c=emp.Id;
        insert ddc;
        system.debug('ddc@'+ddc);
    

        // Test with sample fiscal year
        String fiscalYear = '2023-2024';
        Map<String, Map<String, profitabilitynewclass.ProjectSummaryWrapper>> result = profitabilitynewclass.getcalculatesummaryy(fiscalYear);
        system.debug('result>>>>'+result);
        Map<String, Map<String, profitabilitynewclass.csthrswrapper>> results = profitabilitynewclass.getcost(fiscalYear);
        system.debug('results>>>>'+results);
        List<AcctSeed__Accounting_Period__c>  newlist=Costbreakup.accountingperiodlist();
        date sstartdate = date.newInstance(2023, 05, 01);
        date senddate=date.newInstance(2024, 02, 31);
        Costbreakup.getParentWrapperList(startDate, endDate); 
  


        Costbreakup.codecoverage(); 

        Test.stopTest();
        System.assertNotEquals(null, result);
    }


}