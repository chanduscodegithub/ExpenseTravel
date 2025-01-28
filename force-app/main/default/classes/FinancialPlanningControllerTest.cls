@IsTest
public class FinancialPlanningControllerTest {
    /*@IsTest
    static void testGetFinancialYears() {
        List<String> expectedYears = new List<String>();
        Integer currentYear = Date.today().year();
        Integer startYear = 2023;
 
        for (Integer year = startYear; year <= currentYear; year++) {
            expectedYears.add(String.valueOf(year));
        }

        List<String> actualYears = FinancialPlanningController.getFinancialYears();

        System.assertEquals(expectedYears, actualYears);
    }

    @IsTest
    static void testGetFinancialPlanningRecords() {
               
        Role__c role=new Role__c();
        role.Name='Developer';
        insert role;
        
        Account acc=new Account();
        acc.Name='test account';
        acc.Customer_Region__c='ANZ';
        //acc.CurrencyIsoCode='EUR-Euro';
        acc.Type='Enterprise Account';
        acc.CRMIT_Relationship__c='	Direct - Active';
        insert acc;
        
        Schema.RecordTypeInfo oppRecordTypeInfo = Opportunity.SObjectType.getDescribe().getRecordTypeInfosByName().get('USA Region');
        Id oppRecordTypeId = oppRecordTypeInfo.getRecordTypeId();
        
        Opportunity opp= new Opportunity();
        opp.Name='Test opp';
        opp.AccountId=acc.Id;
        opp.Opportunity_Category__c='Existing Customer - Repeat / Renewals';
        //opp.CurrencyIsoCode='EUR-Euro';
        opp.Amount=7000;
        opp.Next_Contact_Date__c=system.today();
        opp.CloseDate=system.today();
        opp.StageName='	Opportunity Identified';
        opp.Opportunity_Status__c='Open';
        opp.RecordTypeId = oppRecordTypeId;
        
        insert opp;
        
        Employee__c emp=new Employee__c();
        emp.Name='test emp';
        emp.EmployeeID__c='C0777';
        emp.Country__c='India';
        emp.DateofJoin__c=system.today();
        emp.Department__c='Corporate';
        emp.MobileNo__c='7898765434';
        emp.Email_ID__c='testemp@gmail.com';
        emp.Designation__c=role.Id;
        emp.Past_Experience__c=5;
        insert emp;
        
        Employee__c emp1=new Employee__c();
        emp1.Name='test emp1';
        emp1.EmployeeID__c='C0776';
        emp1.Country__c='India';
        emp1.DateofJoin__c=system.today();
        emp1.Department__c='Corporate';
        emp1.MobileNo__c='7898765435';
        emp1.Email_ID__c='testemp1@gmail.com';
        emp1.ReportingTo__c=emp.Id;
        emp1.Designation__c=role.Id;
        emp1.Past_Experience__c=8;
        insert emp1;
        
        
        Integer currentYear = Date.today().year();
    Integer startYear = 2023;

    Financial_Planning__c finance = new Financial_Planning__c();
    finance.Name = 'test';
    finance.FP_Year__c = String.valueOf(currentYear); // Set the FP_Year__c field with the current year
    insert finance;
        List<Financial_Planning__c> result = FinancialPlanningController.getFinancialPlanningRecords('Test Financial Planning');

    List<String> expectedYears = new List<String>();
    for (Integer year = startYear; year <= currentYear; year++) {
        expectedYears.add(String.valueOf(year));
    }

    List<String> actualYears = FinancialPlanningController.getFinancialYears();

    System.assertEquals(expectedYears, actualYears);
       
    }

    @IsTest
    static void testGetRevenueStreamRegions() {
        
         Role__c role=new Role__c();
        role.Name='Developer';
        insert role;
        Financial_Planning__c finance=new Financial_Planning__c();
        finance.Name='test';
        insert finance;
 List<Financial_Planning__c> financialPlanningRecords = [SELECT Id FROM Financial_Planning__c WHERE Name = 'RF_Budget_2023'];

    Id financialPlanningId;
    if (!financialPlanningRecords.isEmpty()) {
        financialPlanningId = financialPlanningRecords[0].Id;
    } else {
        // Handle the scenario where the Financial_Planning__c record is not found
    }
        
      
        Revenue_Stream_Region__c streamreg=new Revenue_Stream_Region__c();
        streamreg.Revenue_Stream_Forecasting__c=finance.Id;
        streamreg.Name='RF_Budget_2023_USA';
        streamreg.Opportunity_Region__c='USA';
        streamreg.Currency__c='USD';
        streamreg.Q1_Revenue_Attainment__c=50000;
        streamreg.Q2_Revenue_Attainment__c=50000;
        streamreg.Q3_Revenue_Attainment__c=60000;
        streamreg.Q4_Revenue_Attainment__c=40000;
        streamreg.Actual_Gross_Margin__c=80;
        streamreg.Annual_Gross_Margin__c=40;
        streamreg.Quarter_1_Target__c=10;
        streamreg.Quarter_2_Target__c=20;
        streamreg.Quarter_3_Target__c=20;
        streamreg.Quarter_4_Target__c=10;
        
        
        
        insert streamreg;
          List<Revenue_Stream_Region__c> result = FinancialPlanningController.getRevenueStreamRegions('Test Financial Planning');
    }

    @IsTest
    static void testGetRevenueStreamEmployees() {
         Role__c role=new Role__c();
        role.Name='Developer';
        insert role; 
        
        Employee__c emp=new Employee__c();
        emp.Name='test emp';
        emp.EmployeeID__c='C0777';
        emp.Country__c='India';
        emp.DateofJoin__c=system.today();
        emp.Department__c='Corporate';
        emp.MobileNo__c='7898765434';
        emp.Email_ID__c='testemp@gmail.com';
        emp.Designation__c=role.Id;
        emp.Past_Experience__c=5;
        insert emp;
        
        
        
        
        Financial_Planning__c finance=new Financial_Planning__c();
        finance.Name='test';
        insert finance;
     List<Financial_Planning__c> financialPlanningRecords = [SELECT Id FROM Financial_Planning__c WHERE Name = 'RF_Budget_2023'];

    Id financialPlanningId;
    if (!financialPlanningRecords.isEmpty()) {
        financialPlanningId = financialPlanningRecords[0].Id;
    } else {
        // Handle the scenario where the Financial_Planning__c record is not found
    }

  
      Revenue_Stream_Employee__c streamemp = new Revenue_Stream_Employee__c();
        streamemp.Revenue_Stream_Forecasting__c = finance.Id;
        streamemp.Name = 'RF_Budget_2023_Test';
        streamemp.Region__c = 'USA';
        streamemp.Employee__c = emp.Id;
        streamemp.Currency__c = 'USD';
        streamemp.Q1_Revenue_Attainment__c = 50000;
        streamemp.Q2_Revenue_Attainment__c = 50000;
        streamemp.Q3_Revenue_Attainment__c = 60000;
        streamemp.Q4_Revenue_Attainment__c = 40000;
        streamemp.Gross_Margin_Attainment__c = 50;
        streamemp.Annual_Gross_Margin__c = 60;
        streamemp.Q1_Target__c = 10;
        streamemp.Q2_Target__c = 20;
        streamemp.Q3_Target__c = 10;
        streamemp.Q4_Target__c = 50;
        insert streamemp;

        // Call the method under test
        List<Revenue_Stream_Employee__c> result = FinancialPlanningController.getRevenueStreamEmployees('Test Financial Planning');

        
    }*/
}