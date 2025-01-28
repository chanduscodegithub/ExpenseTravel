@isTest
public class TestbillingFromBCController {
    
     @isTest
     public static void testCreateBilling() {
 
     // —— DATA PREPARATION ——
     // insert 1 Account
         Account acct = new Account(
                 Name = 'Test Account',
         Industry = 'Others');
         insert acct;
 
 
         
         
     // insert 4 billing formats
         AcctSeed__Billing_Format__c[] PDFformats = new List<AcctSeed__Billing_Format__c>();
         PDFformats.add(
                 new AcctSeed__Billing_Format__c(
                         Name = 'Default Billing Product',
                         AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF',
                         AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName,
                         AcctSeed__Type__c = 'Billing',
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
                         Name = '1000-Cash',
                         AcctSeed__Active__c = true,
                         AcctSeed__Type__c = 'Balance Sheet',
                         AcctSeed__Bank__c = true,
                         AcctSeed__Sub_Type_1__c = 'Assets',
                         AcctSeed__Sub_Type_2__c = 'Cash'
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
                 AcctSeed__Default_Packing_Slip_Format__c = PDFformats[5].Id,
                CurrencyIsoCode='USD'
         );
 
         insert ledger;
 
     // insert 1 Accounting Period
         AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(
                 Name = '2023-03',
                 AcctSeed__Start_Date__c = Date.newinstance(2023, 02, 1),
                 AcctSeed__End_Date__c = Date.newinstance(2023, 02, 28),
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
                         AcctSeed__Customer__c = [Select Id From Account limit 1].Id,
                         AcctSeed__Status__c = 'Approved',
                         AcctSeed__Due_Date2__c = System.today() + 30,
                         AcctSeed__Ledger__c = ledger.Id,
                         AcctSeed__Billing_Format__c = PDFformats[0].Id,
                         AcctSeed__Accounting_Period__c = [Select Id From AcctSeed__Accounting_Period__c limit 1].Id
                 )
         );
 
         billings.add(
                 new AcctSeed__Billing__c(
                         AcctSeed__Billing_Cycle_Start_Date__c = System.today(),
                         AcctSeed__Billing_Cycle_End_Date__c = System.today() + 30,
                         AcctSeed__Date__c = System.today(),
                         AcctSeed__Customer__c = [Select Id From Account limit 1].Id,
                         AcctSeed__Status__c = 'Approved',
                         AcctSeed__Due_Date2__c = System.today() + 30,
                         AcctSeed__Ledger__c = ledger.Id,
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
		
         Product2 pro=new Product2();
         pro.Name='Pro01';
         pro.IsActive=true;
         pro.AcctSeed__Revenue_GL_Account__c=glAccounts[1].id;
         insert pro;
         
         Opportunity opp=new Opportunity();
         opp.Name='TestOpp';
         opp.AccountId=acct.Id;
         opp.Currency__c='USD';
         opp.Amount=100;
         opp.Next_Contact_Date__c=System.today().addDays(30);
         opp.StageName='Opportunity Won';
         opp.Win_Loss__c='Good lead';
         opp.Opportunity_Status__c='Won';
         opp.Technology_Domain__c='Analytics';
         opp.Skills_Required__c='FSL';
         opp.Industry_Vertical__c='Consumer Goods';
         opp.Micro_Vertical__c='Household Products';
         opp.CloseDate=system.today();
         insert opp;
         
         Billing__c billingcust=new Billing__c();
         billingcust.Name='Test-001';
         billingcust.Account__c=acct.Id;
         billingcust.Opportunity__c=opp.Id;
         billingcust.OpportunityName__c=opp.Id;
         billingcust.Rate__c=100;
         billingcust.Qty__c=3;
         billingcust.CurrencyIsoCode='USD';
         billingcust.Product__c=pro.id;
         insert billingcust;
         
         
         
         ApexPages.StandardController sc = new ApexPages.standardController(billingcust);
		billingFromBCController cas = New billingFromBCController(sc);
         cas.createBilling();
         cas.createBillingAndPost();
         
     }

}