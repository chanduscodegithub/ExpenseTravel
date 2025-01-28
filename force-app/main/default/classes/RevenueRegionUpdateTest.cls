@IsTest
public class RevenueRegionUpdateTest {
    private static Id getStandardUserProfileId() {
        Profile standardUserProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        return standardUserProfile.Id;
    }
    @IsTest
    public static void testUpdateRevenueAttainmentEmp() {
       
        User testUser = new User(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@example.com',
            Username = 'unique_username@example.com',  // Provide a unique username here
            Alias = 'jdoe',
            CommunityNickname = 'johnd',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            ProfileId = getStandardUserProfileId()
        );
        
        insert testUser;
        
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
        opp.OwnerId = testUser.Id;
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
        
        
        Financial_Planning__c finance=new Financial_Planning__c();
        finance.Name='test';
        finance.Calculate_RA__c = true;
        finance.Related_Records_Deleted__c = false;
        finance.FP_Year__c = '2023';
        insert finance;
        
        Revenue_Stream_Employee__c streamemp=new Revenue_Stream_Employee__c();
        streamemp.Revenue_Stream_Forecasting__c=finance.Id;
        streamemp.Name='RF_Budget_2023_Test';
        streamemp.Region__c='USA';
        streamemp.Employee__c=emp1.Id;
        streamemp.Employees__c=testUser.Id;
        streamemp.Currency__c='USD';
        streamemp.Q1_Revenue_Attainment__c=50000;
        streamemp.Q2_Revenue_Attainment__c=50000;
        streamemp.Q3_Revenue_Attainment__c=60000;
        streamemp.Q4_Revenue_Attainment__c=40000;
        insert streamemp;
        
        Revenue_Stream_Region__c streamreg=new Revenue_Stream_Region__c();
        streamreg.Revenue_Stream_Forecasting__c=finance.Id;
        streamreg.Name='RF_Budget_2023_USA';
        streamreg.Opportunity_Region__c='USA';
        
        streamreg.Currency__c='USD';
        streamreg.Q1_Revenue_Attainment__c=50000;
        streamreg.Q2_Revenue_Attainment__c=50000;
        streamreg.Q3_Revenue_Attainment__c=60000;
        streamreg.Q4_Revenue_Attainment__c=40000;
        insert streamreg;
        
        
        
       
        Billing__c bill=new Billing__c();
        bill.Name='Test billing';
        bill.Opportunity__c=opp.Id;
        bill.OpportunityName__c=opp.Id;
        bill.Milestone_Date__c=system.today();
        bill.Invoice_Amount__c=30000;
        bill.Credit_Period__c=7;
        bill.Resource_Name1__c=emp1.Id;
        //bill.Opp_Region__c = opp.Id;
        insert bill;
        
        test.startTest();
        Set<Id> recordIds = new Set<Id>();
        
        UpdateRevenueAttainmentBatch obj1=new UpdateRevenueAttainmentBatch(recordIds);
        database.executebatch(obj1);
       
        UpdateRevenueAttainmentEmployeeBatch obj2=new UpdateRevenueAttainmentEmployeeBatch(recordIds);
        database.executeBatch(obj2);
        
        test.stopTest();
        
      
    }       
}