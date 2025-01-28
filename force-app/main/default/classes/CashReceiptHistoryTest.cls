@isTest
public class CashReceiptHistoryTest {
    @isTest(SeeAllData=false)
    static void testCashReceiptHistoryRecord() {
        // —— DATA PREPARATION ——
        // insert 1 Account
        Account acct = new Account(
            Name = 'Test Account');
        insert acct;
        
        Account acc = new Account();
        acc.Name = 'ytest';
        insert acc;
        
        // insert 1 Accounting Period
        AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(
            Name = '1991-10',
            AcctSeed__Start_Date__c = Date.newinstance(1991, 10, 1),
            AcctSeed__End_Date__c = Date.newinstance(1991, 10, 31),
            AcctSeed__Status__c = 'Open');
        insert acctPeriod;
        
        // insert 6 billing formats
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
        // #4
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
        
        // create GL Accounts
        AcctSeed__GL_Account__c[] glAccounts = new List<AcctSeed__GL_Account__c>();
        // 0
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1000-Cash',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Bank__c = true,
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash')
        );
        
        // 1
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1205-Unapplied A/R',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Cash'
            )
        );
        
        // 2
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1200-Accounts Receivable',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
        
        // 3
        glAccounts.add(
            new AcctSeed__GL_Account__c(
                Name = '1600-Work In Process',
                AcctSeed__Active__c = true,
                AcctSeed__Type__c = 'Balance Sheet',
                AcctSeed__Sub_Type_1__c = 'Assets',
                AcctSeed__Sub_Type_2__c = 'Current Assets'
            )
        );
        insert glAccounts;
        
        // insert 1 Ledger records
        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c(
            Name = 'Actual',
            AcctSeed__Type__c = 'Transactional',
            AcctSeed__Default_Bank_Account__c = glAccounts[0].Id,
            AcctSeed__Default_Billing_Format__c = PDFformats[0].Id,
            AcctSeed__Billing_Outstanding_Statement_Format__c = PDFformats[2].Id,
            AcctSeed__Billing_Activity_Statement_Format__c = PDFformats[3].Id,
            AcctSeed__Default_Purchase_Order_Format__c = PDFformats[4].Id,
            AcctSeed__Default_Packing_Slip_Format__c = PDFformats[5].Id);
        
        insert ledger;
        
        AcctSeed__Billing__c billing = new AcctSeed__Billing__c();
        billing.AcctSeed__Customer__c = acct.Id;
        billing.AcctSeed__Date__c = System.today();
        billing.AcctSeed__Accounting_Period__c = acctPeriod.Id;
        billing.AcctSeed__Billing_Format__c = ledger.Id;
        billing.AcctSeed__Billing_Format__c =PDFformats[0].Id;
        billing.AcctSeed__Ledger__c = ledger.id;
        insert billing;
        
        
        AcctSeed__Billing_Line__c billingLine = new AcctSeed__Billing_Line__c();
        billingLine.AcctSeed__Hours_Units__c = 1;
        billingLine.AcctSeed__Rate__c = 100;
        billingLine.AcctSeed__Billing__c = billing.Id;
        billingLine.AcctSeed__Revenue_GL_Account__c = glAccounts[1].id;
        insert billingLine;
        
        
        // Create Cash Receipt
        AcctSeed__Cash_Receipt__c CashR = new AcctSeed__Cash_Receipt__c(
            AcctSeed__Account__c = acct.Id,
            AcctSeed__Amount__c = 1,
            AcctSeed__Payment_Reference__c = '12345',
            AcctSeed__Bank_Account__c = glAccounts[0].Id, //'1000-Cash'
            AcctSeed__Credit_GL_Account__c = glAccounts[1].Id, //'1200-Accounts Receivable'
            AcctSeed__Accounting_Period__c = acctPeriod.id,
            AcctSeed__Ledger__c = ledger.id,
            AcctSeed__Receipt_Date__c = date.today(),
            AcctSeed__Status__c = 'Posted',
            Billing_Id__c = billing.Id
            
        );
        
        insert CashR;
        
        AcctSeed__Billing_Cash_Receipt__c bcr = new AcctSeed__Billing_Cash_Receipt__c();
        bcr.AcctSeed__Billing__c = billing.Id;
        bcr.AcctSeed__Cash_Receipt__c = CashR.id;
        bcr.AcctSeed__Applied_Amount__c = 100;
        insert bcr;
        
        // Create Cash Receipt
        AcctSeed__Cash_Receipt__c CashR1 = new AcctSeed__Cash_Receipt__c(
            AcctSeed__Account__c = acct.Id,
            AcctSeed__Amount__c = 1,
            AcctSeed__Payment_Reference__c = '12345',
            AcctSeed__Bank_Account__c = glAccounts[0].Id, //'1000-Cash'
            AcctSeed__Credit_GL_Account__c = glAccounts[1].Id, //'1200-Accounts Receivable'
            AcctSeed__Accounting_Period__c = acctPeriod.id,
            AcctSeed__Ledger__c = ledger.id,
            AcctSeed__Receipt_Date__c = date.today(),
            AcctSeed__Status__c = 'Apporved',
            Billing_Id__c = billing.Id
            
        );
        
        insert CashR1;
        
        CashR1.AcctSeed__Account__c = acc.Id;
        update CashR1;
        
        CashR1.AcctSeed__Amount__c = 10;
        update CashR1;
        
        delete CashR1;
            }
}