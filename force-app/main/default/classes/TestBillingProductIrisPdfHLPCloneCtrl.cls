/*@isTest
public class BillingProductIrisPdfHLPCloneCtrlTest {
    static testMethod void validateHelloWorld(){
        Test.startTest();
        BillingProductIrisPdfHLPCloneCtrl.increase();
        CreateBillingPDFCloneController.increase();
        Test.stopTest();
    }
}  */


@isTest
public class TestBillingProductIrisPdfHLPCloneCtrl {
    @isTest
    public static void testBillingProductIrisPdfHLPCloneCtrl() {
        // Create test data
        Account acc = new Account(
            Name = 'Kaseya US, LLC'
        );
        insert acc;
        Opportunity opp = new Opportunity(
            Name = 'Test opp',
            AccountId = acc.Id,
            Amount = 113,
            StageName = 'Contracts Sent',
            CloseDate = System.today(),
            Next_Contact_Date__c = System.today()
            
        );
        insert opp;
        
        Billing__c billCust = new Billing__c(
            Account__c = acc.Id,
            OpportunityName__c = opp.Id
        );
        insert billCust;
        AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(
                 Name = '1991-10',
                 AcctSeed__Start_Date__c =system.today(),
                 AcctSeed__End_Date__c =system.today(),
                 AcctSeed__Status__c = 'Open');
         insert acctPeriod;
        
        AcctSeed__Billing_Format__c pdfFormat = new AcctSeed__Billing_Format__c(
            Name = 'Default Billing Product-GBP',
            AcctSeed__Type__c = 'Billing',
            AcctSeed__Visualforce_PDF_Page__c = 'BillingProductIrisPdfHLPClone',
            AcctSeed__Default_Email_Template__c = 'Billing_Email_Template'  
        );
        insert pdfFormat;

        AcctSeed__GL_Account__c cashGL = new AcctSeed__GL_Account__c(
                 Name = '4000-Product Revenue',
                 AcctSeed__Active__c = true,
                 AcctSeed__Type__c = 'Balance Sheet',
                 AcctSeed__Bank__c = true,
                 AcctSeed__Sub_Type_1__c = 'Assets',
                 AcctSeed__Sub_Type_2__c = 'Bank Accounts');
         insert CashGL;
        
        AcctSeed__GL_Account__c cashGL2 = new AcctSeed__GL_Account__c(
                 Name = '4000-Product Revenue',
                 AcctSeed__Active__c = true,
                 AcctSeed__Type__c = 'Balance Sheet',
                 AcctSeed__Bank__c = false,
                 AcctSeed__Sub_Type_1__c = 'Liabilities',
                 AcctSeed__Sub_Type_2__c = 'Current LiabilitiesS');
         insert cashGL2;
        
         AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c(
                 Name = 'CRMIT - India',
                 AcctSeed__Type__c = 'Transactional',
                 AcctSeed__Default_Bank_Account__c = CashGL.id,
                 AcctSeed__Default_Billing_Format__c = pdfFormat.Id,
                 AcctSeed__Billing_Outstanding_Statement_Format__c = pdfFormat.Id,
                 AcctSeed__Billing_Activity_Statement_Format__c = pdfFormat.Id,
                 AcctSeed__Default_Purchase_Order_Format__c = pdfFormat.Id,
                 AcctSeed__Default_Packing_Slip_Format__c = pdfFormat.Id
         );
                insert ledger;
        
        AcctSeed__Billing__c testBillingRecord = new AcctSeed__Billing__c(
          //  Name = 'Test Billing'
            AcctSeed__Status__c = 'Approved',
            CurrencyIsoCode = 'USD',
            IsService__c = 'Y',
            GST_Subtype__c = 'B2B',
            Billing_Customer__c = billCust.Id,
            AcctSeed__Customer__c =  acc.Id,
            AcctSeed__Accounting_Period__c = acctPeriod.Id,
            AcctSeed__Billing_Format__c = pdfFormat.Id,
            AcctSeed__Ledger__c = ledger.Id,
            AcctSeed__Currency_Conversion_Rate__c = 5
            
            // Add other required fields here
        );
        insert testBillingRecord;
        
        AcctSeed__Tax_Group__c txGrp = new AcctSeed__Tax_Group__c(
        AcctSeed__Tax_Type__c = 'Sales',   
       // AcctSeed__Combined_Tax_Rate__c =  12,
        Name = 'abc'        
        );
        insert txGrp;
        
        AcctSeed__Tax_Rate__c taxRt = new AcctSeed__Tax_Rate__c(
        Name = 'Abc',
        AcctSeed__Tax_Group__c =  txGrp.Id,
        AcctSeed__Tax_Rate__c =  2.1,
        AcctSeed__Sales_Tax_Liability_GL_Account__c = cashGL2.Id
        );
        insert taxRt;
        
        
        
        AcctSeed__Billing_Line__c billingLine1 = new AcctSeed__Billing_Line__c(
        AcctSeed__Date__c = system.today(),
            AcctSeed__Hours_Units__c = 500,
            AcctSeed__Rate__c = 6,
            AcctSeed__Tax_Group__c = txGrp.Id,
            AcctSeed__Billing__c = testBillingRecord.Id
        );
        insert billingLine1;

        // Create a PageReference instance
        PageReference pageRef = Page.BillingProductIrisPdfHLPClone; // Replace with the actual page name
        pageRef.getParameters().put('id', testBillingRecord.Id);

        // Set the current page to the test PageReference
        Test.setCurrentPage(pageRef);

        // Instantiate the controller
        ApexPages.StandardController stdController = new ApexPages.StandardController(testBillingRecord);
        BillingProductIrisPdfHLPCloneCtrl controller = new BillingProductIrisPdfHLPCloneCtrl(stdController);

        // Test different scenarios
        System.assertEquals(testBillingRecord.Company_Bussiness_Number__c, controller.CompanyBusinessNumber);
        
        
        

        // Add more assertions as needed for different scenarios

        // Test HeadingType based on ledger and currency
        System.assertEquals('Export Invoice', controller.HeadingType);
        
        

        // Test with different ledger and currency
        testBillingRecord.AcctSeed__Ledger__c = ledger.Id;
        testBillingRecord.CurrencyIsoCode = 'AUD';
        update testBillingRecord;
        controller = new BillingProductIrisPdfHLPCloneCtrl(stdController);
        System.assertEquals('Export Invoice', controller.HeadingType);
    }
    
    @isTest
    public static void againtestBillingProductIrisPdfHLPCloneCtrl() {
        // Create test data
        Account acc = new Account(
            Name = 'Kaseya US, LLC'
        );
        insert acc;
        Opportunity opp = new Opportunity(
            Name = 'Test opp',
            AccountId = acc.Id,
            Amount = 113,
            StageName = 'Contracts Sent',
            CloseDate = System.today(),
            Next_Contact_Date__c = System.today()
            
        );
        insert opp;
        
        Billing__c billCust = new Billing__c(
            Account__c = acc.Id,
            OpportunityName__c = opp.Id
        );
        insert billCust;
        AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(
                 Name = '1991-10',
                 AcctSeed__Start_Date__c =system.today(),
                 AcctSeed__End_Date__c =system.today(),
                 AcctSeed__Status__c = 'Open');
         insert acctPeriod;
        
        AcctSeed__Billing_Format__c pdfFormat = new AcctSeed__Billing_Format__c(
            Name = 'Default Billing Product-AUD',
            AcctSeed__Type__c = 'Billing',
            off__c = '1234567897',
            AcctSeed__Visualforce_PDF_Page__c = 'BillingProductIrisPdfHLPClone',
            AcctSeed__Default_Email_Template__c = 'Billing_Email_Template'  
        );
        insert pdfFormat;

        AcctSeed__GL_Account__c cashGL = new AcctSeed__GL_Account__c(
                 Name = '1000-Cash',
                 AcctSeed__Active__c = true,
                 AcctSeed__Type__c = 'Balance Sheet',
                 AcctSeed__Bank__c = true,
                 AcctSeed__Sub_Type_1__c = 'Assets',
                 AcctSeed__Sub_Type_2__c = 'Cash');
         insert CashGL;
        
        AcctSeed__GL_Account__c cashGL2 = new AcctSeed__GL_Account__c(
                 Name = '4000-Product Revenue',
                 AcctSeed__Active__c = true,
                 AcctSeed__Type__c = 'Balance Sheet',
                 AcctSeed__Bank__c = false,
                 AcctSeed__Sub_Type_1__c = 'Liabilities',
                 AcctSeed__Sub_Type_2__c = 'Current Liabilities - Duties & Taxes');
         insert cashGL2;
            
         AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c(
                 Name = 'Actual',
                 AcctSeed__Type__c = 'Transactional',
                 AcctSeed__Default_Bank_Account__c = CashGL.id,
                 AcctSeed__Default_Billing_Format__c = pdfFormat.Id,
                 AcctSeed__Billing_Outstanding_Statement_Format__c = pdfFormat.Id,
                 AcctSeed__Billing_Activity_Statement_Format__c = pdfFormat.Id,
                 AcctSeed__Default_Purchase_Order_Format__c = pdfFormat.Id,
                 AcctSeed__Default_Packing_Slip_Format__c = pdfFormat.Id
         );
                insert ledger;
        
        AcctSeed__Billing__c testBillingRecord = new AcctSeed__Billing__c(
          //  Name = 'Test Billing'
            AcctSeed__Status__c = 'Approved',
            CurrencyIsoCode = 'USD',
            IsService__c = 'Y',
            GST_Subtype__c = 'B2B',
            Billing_Customer__c = billCust.Id,
            AcctSeed__Customer__c =  acc.Id,
            AcctSeed__Currency_Conversion_Rate__c = 3,
            AcctSeed__Accounting_Period__c = acctPeriod.Id,
            AcctSeed__Billing_Format__c = pdfFormat.Id,
            AcctSeed__Ledger__c = ledger.Id
            
            // Add other required fields here
        );
        insert testBillingRecord;
        system.debug('@@@@testBillingRecord'+ testBillingRecord);
        
        AcctSeed__Tax_Group__c txGrp = new AcctSeed__Tax_Group__c(
        AcctSeed__Tax_Type__c = 'Sales',  
       //  AcctSeed__Tax_Rate_Count__c = 1,
       // AcctSeed__Combined_Tax_Rate__c =  12,
        Name = 'abc'        
        );
        insert txGrp;
        
        AcctSeed__Tax_Rate__c taxRt = new AcctSeed__Tax_Rate__c(
        Name = 'Abc',  
        AcctSeed__Tax_Group__c =  txGrp.Id,
        AcctSeed__Tax_Rate__c =  1,
        AcctSeed__Sales_Tax_Liability_GL_Account__c = cashGL2.Id
        );
        insert taxRt;
        
        AcctSeed__Tax_Rate__c taxRt2 = new AcctSeed__Tax_Rate__c(
        Name = 'Abc',  
        AcctSeed__Tax_Group__c =  txGrp.Id,
        AcctSeed__Tax_Rate__c =  1,
        AcctSeed__Sales_Tax_Liability_GL_Account__c = cashGL2.Id
        );
        insert taxRt2;
        
        AcctSeed__Billing_Line__c billingLine1 = new AcctSeed__Billing_Line__c(
        AcctSeed__Date__c = system.today(),
            AcctSeed__Hours_Units__c = 50,
            AcctSeed__Rate__c = 6,
            AcctSeed__Tax_Group__c = txGrp.Id,
            AcctSeed__Billing__c = testBillingRecord.Id
        );
        insert billingLine1;
        

        // Create a PageReference instance
      //  PageReference pageRef = Page.BillingProductIrisPdfHLPClone; // Replace with the actual page name
        //pageRef.getParameters().put('id', testBillingRecord.Id);

        // Set the current page to the test PageReference
        //Test.setCurrentPage(pageRef);

        // Instantiate the controller
      //  ApexPages.StandardController stdController = new ApexPages.StandardController(testBillingRecord);
       // BillingProductIrisPdfHLPCloneCtrl controller = new BillingProductIrisPdfHLPCloneCtrl(stdController);
        
        PageReference pageRef = Page.BillingProductIrisPdfHLPClone;
         Test.setCurrentPage(pageRef);

     pageRef.getParameters().put('id', String.valueOf(testBillingRecord.Id));
     ApexPages.StandardController sc = new ApexPages.StandardController(testBillingRecord);
     BillingProductIrisPdfHLPCloneCtrl testAccPlan = new BillingProductIrisPdfHLPCloneCtrl(sc);

        // Test different scenarios
     //   System.assertEquals(testBillingRecord.Company_Bussiness_Number__c, controller.CompanyBusinessNumber);
        
        
        

        // Add more assertions as needed for different scenarios

        // Test HeadingType based on ledger and currency
      //  System.assertEquals('Export Invoice', controller.HeadingType);	
        
        

        // Test with different ledger and currency
        testBillingRecord.AcctSeed__Ledger__c = ledger.Id;
        testBillingRecord.CurrencyIsoCode = 'AUD';
        update testBillingRecord;
       // controller = new BillingProductIrisPdfHLPCloneCtrl(stdController);
       // System.assertEquals('Export Invoice', controller.HeadingType);
    }  
}