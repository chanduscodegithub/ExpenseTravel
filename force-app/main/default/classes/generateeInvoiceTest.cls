@isTest
public class generateeInvoiceTest {

    @isTest
    static void test_eInvoice() {
      // —— DATA PREPARATION ——
     // insert 1 Account
         Account acct = new Account(
                 Name = 'Test Account',
         BillingPostalCode='560068',
         Statecode_del1_del__c='29',
         ShippingPostalCode ='562160');
         insert acct;
 
     // insert 4 billing formats
         AcctSeed__Billing_Format__c[] PDFformats = new List<AcctSeed__Billing_Format__c>();
         PDFformats.add(
                 new AcctSeed__Billing_Format__c(
                         Name = 'Default Billing Product',
                         AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF',
                         AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                         AcctSeed__Type__c = 'Billing',
                     	AcctSeed__Company_PostalCode__c='560068',
                         AcctSeed__Sort_Field__c = 'Name'
                 )
         );
 
         PDFformats.add(
                 new AcctSeed__Billing_Format__c(
                         Name = 'Default Billing Service',
                         AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
                         AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                         AcctSeed__Type__c = 'Billing',
                         AcctSeed__Sort_Field__c = 'Name'
                 )
         );
 
         PDFformats.add(
                 new AcctSeed__Billing_Format__c (
                         Name = 'Billing Outstanding Statement',
                         AcctSeed__Visualforce_PDF_Page__c = 'BillingOutstandingStatementPDF',
                         AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                         AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                         AcctSeed__Type__c = 'Outstanding Statement'
                 )
         );
 
         PDFformats.add(
                 new AcctSeed__Billing_Format__c (
                         Name = 'Billing Activity Statement',
                         AcctSeed__Visualforce_PDF_Page__c = 'BillingActivityStatementPDF',
                         AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                         AcctSeed__ReplyTo_Email__c = 'test3463464364646@gmail.com',
                         AcctSeed__Type__c = 'Activity Statement'
                 )
         );
 
         PDFformats.add(
                 new AcctSeed__Billing_Format__c(
                         Name = 'Default Purchase Order',
                         AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
                         AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                         AcctSeed__Type__c = 'Purchase Order',
                         AcctSeed__Sort_Field__c = 'Name'
                 )
         );
 
         PDFformats.add(
                 new AcctSeed__Billing_Format__c(
                         Name = 'Default Packing Slip',
                         AcctSeed__Visualforce_PDF_Page__c = 'BillingServicePDF',
                         AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                         AcctSeed__Type__c = 'Packing Slip',
                         AcctSeed__Sort_Field__c = 'Name'
                 )
         );
 
         insert PDFformats;
 
     // insert 2 cash flow GL Accounts
         AcctSeed__GL_Account__c [] glAccounts = new List<AcctSeed__GL_Account__c>();
         //#0
         glAccounts.add(
                 new AcctSeed__GL_Account__c(
                         Name = '12001-Accounts Receivable',
                         AcctSeed__Active__c = true,
                         AcctSeed__Type__c = 'Balance Sheet',
                         AcctSeed__Bank__c = true,
                         AcctSeed__Sub_Type_1__c = 'Assets',
                         AcctSeed__Sub_Type_2__c = 'Current Assets'
                 )
         );
 
         //#1
         glAccounts.add(
                 new AcctSeed__GL_Account__c(
                         Name = '1205-Unapplied A/R',
                         AcctSeed__Active__c = true,
                         AcctSeed__Type__c = 'Balance Sheet',
                         AcctSeed__Sub_Type_1__c = 'Assets',
                         AcctSeed__Sub_Type_2__c = 'Cash'
 
                 )
         );
 
         insert glAccounts;
 
     // insert 1 Ledger records
         AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c(
                 Name = 'Actual',
                 AcctSeed__Type__c = 'Transactional',
                 AcctSeed__Default_Bank_Account__c = glAccounts[0].id,
                 AcctSeed__Default_Billing_Format__c = PDFformats[0].Id,
                 AcctSeed__Billing_Outstanding_Statement_Format__c = PDFformats[2].Id,
                 AcctSeed__Billing_Activity_Statement_Format__c = PDFformats[3].Id,
                 AcctSeed__Default_Purchase_Order_Format__c = PDFformats[4].Id,
                 AcctSeed__Default_Packing_Slip_Format__c = PDFformats[5].Id);
 
         insert ledger;
 
     // insert 1 Accounting Period
         AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(
                 Name = '1991-10',
                 AcctSeed__Start_Date__c = Date.newinstance(2023, 05, 1),
                 AcctSeed__End_Date__c = Date.newinstance(2023, 05, 31),
                 AcctSeed__Status__c = 'Open');
         insert acctPeriod;
 
     // --- START HERE ---
     // Create BILLING RECORDS to post and unpost
         AcctSeed__Billing__c[] billings = new List <AcctSeed__Billing__c> ();
 
         billings.add(
                 new AcctSeed__Billing__c(
                         AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
                         AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
                         AcctSeed__Date__c = System.today(),
                         AcctSeed__Customer__c = acct.Id,
                         AcctSeed__Status__c = 'Approved',
                         AcctSeed__Due_Date2__c = System.today() + 30,
                         AcctSeed__Ledger__c = ledger.Id, 
                     	AcctSeed__Currency_Conversion_Rate__c=0.0097,
                         AcctSeed__Billing_Format__c = PDFformats[0].Id,
                         AcctSeed__Accounting_Period__c = [Select Id From AcctSeed__Accounting_Period__c limit 1].Id
                 )
         );
 
         billings.add(
                 new AcctSeed__Billing__c(
                         AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
                         AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
                         AcctSeed__Date__c = System.today(),
                         AcctSeed__Customer__c = acct.Id,
                         AcctSeed__Status__c = 'Approved',
                         AcctSeed__Due_Date2__c = System.today() + 30,
                         AcctSeed__Ledger__c = ledger.Id,
                     	CurrencyIsoCode='AUD',
                     AcctSeed__Currency_Conversion_Rate__c=0.0097,
                         AcctSeed__Billing_Format__c = PDFformats[0].Id,
                         AcctSeed__Accounting_Period__c = [Select Id From AcctSeed__Accounting_Period__c limit 1].Id
                 )
         );
        billings.add(
                 new AcctSeed__Billing__c(
                         AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
                         AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
                         AcctSeed__Date__c = System.today(),
                         AcctSeed__Customer__c = acct.Id,
                         AcctSeed__Status__c = 'Approved',
                         AcctSeed__Due_Date2__c = System.today() + 30,
                         AcctSeed__Ledger__c = ledger.Id,
                     	CurrencyIsoCode='EUR',
                     AcctSeed__Currency_Conversion_Rate__c=0.0097,
                         AcctSeed__Billing_Format__c = PDFformats[0].Id,
                         AcctSeed__Accounting_Period__c = [Select Id From AcctSeed__Accounting_Period__c limit 1].Id
                 )
         );
        billings.add(
                 new AcctSeed__Billing__c(
                         AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
                         AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
                         AcctSeed__Date__c = System.today(),
                         AcctSeed__Customer__c = acct.Id,
                         AcctSeed__Status__c = 'Approved',
                         AcctSeed__Due_Date2__c = System.today() + 30,
                         AcctSeed__Ledger__c = ledger.Id,
                     	CurrencyIsoCode='INR',
                     AcctSeed__Currency_Conversion_Rate__c=0.0097,
                         AcctSeed__Billing_Format__c = PDFformats[0].Id,
                         AcctSeed__Accounting_Period__c = [Select Id From AcctSeed__Accounting_Period__c limit 1].Id
                 )
         );
        billings.add(
                 new AcctSeed__Billing__c(
                         AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
                         AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
                         AcctSeed__Date__c = System.today(),
                         AcctSeed__Customer__c = acct.Id,
                         AcctSeed__Status__c = 'Approved',
                         AcctSeed__Due_Date2__c = System.today() + 30,
                         AcctSeed__Ledger__c = ledger.Id,
                     	CurrencyIsoCode='GBP',
                     AcctSeed__Currency_Conversion_Rate__c=0.0097,
                         AcctSeed__Billing_Format__c = PDFformats[0].Id,
                         AcctSeed__Accounting_Period__c = [Select Id From AcctSeed__Accounting_Period__c limit 1].Id
                 )
         );
        billings.add(
                 new AcctSeed__Billing__c(
                         AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
                         AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
                         AcctSeed__Date__c = System.today(),
                         AcctSeed__Customer__c = acct.Id,
                         AcctSeed__Status__c = 'Approved',
                         AcctSeed__Due_Date2__c = System.today() + 30,
                         AcctSeed__Ledger__c = ledger.Id,
                     	CurrencyIsoCode='USD',
                     AcctSeed__Currency_Conversion_Rate__c=0.0097,
                         AcctSeed__Billing_Format__c = PDFformats[0].Id,
                         AcctSeed__Accounting_Period__c = [Select Id From AcctSeed__Accounting_Period__c limit 1].Id
                 )
         );
 
         insert billings;
 
         System.assertEquals(1, [Select count() FROM AcctSeed__Billing__c WHERE Id = :billings[0].Id]);
 
 
     // Create billing line records to post and unpost
         AcctSeed__Billing_Line__c[] bLines = new List <AcctSeed__Billing_Line__c> ();
 
         for (AcctSeed__Billing__c bill : billings) {
             AcctSeed__Billing_Line__c objBillingLine = new AcctSeed__Billing_Line__c();
             objBillingLine.AcctSeed__Billing__c = bill.id;
             objBillingLine.AcctSeed__Date__c = System.today();
             objBillingLine.AcctSeed__Rate__c = 25;
             objBillingLine.AcctSeed__Hours_Units__c = 1;
             objBillingLine.AcctSeed__Tax_Amount2__c=10;
             objBillingLine.AcctSeed__Revenue_GL_Account__c = glAccounts[1].id;
             bLines.add(objBillingLine);
 
             objBillingLine = new AcctSeed__Billing_Line__c();
             objBillingLine.AcctSeed__Billing__c = bill.id;
             objBillingLine.AcctSeed__Date__c = System.today();
             objBillingLine.AcctSeed__Rate__c = 25;
             objBillingLine.AcctSeed__Hours_Units__c = 2;
             objBillingLine.AcctSeed__Revenue_GL_Account__c = glAccounts[1].id;
             bLines.add(objBillingLine);
         }
 
         insert bLines;
         System.assertEquals(1, [Select count() FROM AcctSeed__Billing_Line__c WHERE Id = :bLines[0].Id LIMIT 1]);
 
        ClearTaxIntegration__c cleartax=new ClearTaxIntegration__c();
        cleartax.Endpoint_URL__c='https://api-sandbox.clear.in';
        cleartax.gstin__c='29AAFCD5862R000';
        cleartax.X_Cleartax_Auth_Token__c='1.43ec5d43-f6f7-4e03-b078-28443168ec87_085db816b8abec110a510bb2c107b18eeaac856b16e219d7b237f2002965e8a3';
        cleartax.owner_id__c='0d8170ac-7b6b-44ef-beb2-fe8213a216e8';
        insert cleartax;
        
        List<Bank_Accounts__c> bnkactsList=new List<Bank_Accounts__c>();
        Bank_Accounts__c bnkacts=new Bank_Accounts__c();
        bnkacts.ACC_No__c='50200079636461';
        bnkacts.Bank_Name__c='HDFC Bank Ltd';
        bnkacts.Benificiary_Name__c='M/s CRMIT Solutions Private Limited';
        bnkacts.Branch_Code__c='BTM Layout, Bangalore, India';
        bnkacts.SWIFT_Code__c='HDFCINBB';
        bnkacts.Authorized_Dealer_Code__c='05111838400009';
        bnkacts.IFSC_Code__c='HDFCINBB';
        bnkacts.Name='USD';
        bnkactsList.add(bnkacts);
        
        Bank_Accounts__c bnkacts1=new Bank_Accounts__c();
        bnkacts1.ACC_No__c='50200079636461';
        bnkacts1.Bank_Name__c='HDFC Bank Ltd';
        bnkacts1.Benificiary_Name__c='M/s CRMIT Solutions Private Limited';
        bnkacts1.Branch_Code__c='BTM Layout, Bangalore, India';
        bnkacts1.SWIFT_Code__c='HDFCINBB';
        bnkacts1.Authorized_Dealer_Code__c='05111838400009';
        bnkacts1.IFSC_Code__c='HDFCINBB';
        bnkacts1.Name='INR';
        bnkactsList.add(bnkacts1);
        
        Bank_Accounts__c bnkacts2=new Bank_Accounts__c();
        bnkacts2.ACC_No__c='50200079636461';
        bnkacts2.Bank_Name__c='HDFC Bank Ltd';
        bnkacts2.Benificiary_Name__c='M/s CRMIT Solutions Private Limited';
        bnkacts2.Branch_Code__c='BTM Layout, Bangalore, India';
        bnkacts2.SWIFT_Code__c='HDFCINBB';
        bnkacts2.Authorized_Dealer_Code__c='05111838400009';
        bnkacts2.IFSC_Code__c='HDFCINBB';
        bnkacts2.Name='EUR';
        bnkactsList.add(bnkacts2);
        
         Bank_Accounts__c bnkacts3=new Bank_Accounts__c();
        bnkacts3.ACC_No__c='50200079636461';
        bnkacts3.Bank_Name__c='HDFC Bank Ltd';
        bnkacts3.Benificiary_Name__c='M/s CRMIT Solutions Private Limited';
        bnkacts3.Branch_Code__c='BTM Layout, Bangalore, India';
        bnkacts3.SWIFT_Code__c='HDFCINBB';
        bnkacts3.Authorized_Dealer_Code__c='05111838400009';
        bnkacts3.IFSC_Code__c='HDFCINBB';
        bnkacts3.Name='AUD';
        bnkactsList.add(bnkacts3);
        
		Bank_Accounts__c bnkacts4=new Bank_Accounts__c();
        bnkacts4.ACC_No__c='50200079636461';
        bnkacts4.Bank_Name__c='HDFC Bank Ltd';
        bnkacts4.Benificiary_Name__c='M/s CRMIT Solutions Private Limited';
        bnkacts4.Branch_Code__c='BTM Layout, Bangalore, India';
        bnkacts4.SWIFT_Code__c='HDFCINBB';
        bnkacts4.Authorized_Dealer_Code__c='05111838400009';
        bnkacts4.IFSC_Code__c='HDFCINBB';
        bnkacts4.Name='GBP';
        bnkactsList.add(bnkacts4);  
        
        insert bnkactsList;
        // Call the method to test
        
		       
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Test_RestMock());
        Test.stopTest();
    }
    @IsTest
    static void testParse() {
        // Create a sample JSON string
        String jsonString = '{"invoice":{"transactions":{"Version":"1.1","TranDtls":{"TaxSch":"GST","SupTyp":"B2B","RegRev":"Y"},"DocDtls":{"Typ":"INV","No":"DAOC/007","Dt":"24/03/2023"},"SellerDtls":{"Gstin":"29AAFCD5862R000","LglNm":"NIC company pvt ltd","Addr1":"5th block, kuvempu layout","Addr2":"kuvempu layout","Loc":"GANDHINAGAR","Pin":560037,"Stcd":"29"},"BuyerDtls":{"Gstin":"29AWGPV7107B1Z1","LglNm":"XYZ company pvt ltd","Pos":"12","Addr1":"7th block, kuvempu layout","Loc":"GANDHINAGAR","Pin":562160,"Stcd":"29"},"ShipDtls":{"Gstin":"29AWGPV7107B1Z1","LglNm":"CBE company pvt ltd","Addr1":"7th block, kuvempu layout","Loc":"Banagalore","Pin":562160,"Stcd":"29"},"ItemList":[{"SlNo":"1","PrdDesc":"Rice","IsServc":"N","HsnCd":"10019920","Qty":100.345,"UnitPrice":99.545,"TotAmt":9988.84,"AssAmt":9978.84,"GstRt":12,"IgstAmt":1197.46,"CgstAmt":0,"SgstAmt":0,"TotItemVal":12897.7,"BchDtls":{"Nm":"123456"}}],"ValDtls":{"AssVal":9978.84,"CgstVal":0,"SgstVal":0,"IgstVal":1197.46,"TotInvVal":12908}}}}';

        // Call the parse method to deserialize the JSON string
        fromJSON result = fromJSON.parse(jsonString);

        // Perform assertions to verify the deserialized object
        System.assertEquals('1.1', result.invoice.transactions.Version);
        System.assertEquals('GST', result.invoice.transactions.TranDtls.TaxSch);
        System.assertEquals('INV', result.invoice.transactions.DocDtls.Typ);
        System.assertEquals('DAOC/007', result.invoice.transactions.DocDtls.No);
        // Add more assertions as per your requirement
    }
}