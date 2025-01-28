@IsTest
public class JournalEntryHistoryHelperTest {
    @IsTest
     static void createJournalEntry() {
 
     // —— DATA PREPARATION ——
     Account acc = new Account(
     name = 'test acc'
     );
         insert acc;
         
         Account acc1 = new Account(
     name = 'test acc1'
     );
         insert acc1;
     // 2 Cash GL-Account
         AcctSeed__GL_Account__c cashGL = new AcctSeed__GL_Account__c(
                 Name = '1000-Cash',
                 AcctSeed__Active__c = true,
                 AcctSeed__Type__c = 'Balance Sheet',
                 AcctSeed__Bank__c = true,
                 AcctSeed__Sub_Type_1__c = 'Assets',
                 AcctSeed__Sub_Type_2__c = 'Cash');
         insert CashGL;
         
         AcctSeed__GL_Account__c cashGL1 = new AcctSeed__GL_Account__c(
                 Name = '1000-Cash1',
                 AcctSeed__Active__c = true,
                 AcctSeed__Type__c = 'Balance Sheet',
                 AcctSeed__Bank__c = true,
                 AcctSeed__Sub_Type_1__c = 'Assets',
                 AcctSeed__Sub_Type_2__c = 'Cash');
         insert CashGL1;
         
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
 
     // insert 1 Ledger records
         AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c(
                 Name = 'Actual',
                 AcctSeed__Type__c = 'Transactional',
                 AcctSeed__Default_Bank_Account__c = CashGL.id,
                 AcctSeed__Default_Billing_Format__c = PDFformats[0].Id,
                 AcctSeed__Billing_Outstanding_Statement_Format__c = PDFformats[2].Id,
                 AcctSeed__Billing_Activity_Statement_Format__c = PDFformats[3].Id,
                 AcctSeed__Default_Purchase_Order_Format__c = PDFformats[4].Id,
                 AcctSeed__Default_Packing_Slip_Format__c = PDFformats[5].Id);
         insert ledger;
 
     // insert 2 Accounting Period
         AcctSeed__Accounting_Period__c acctPeriod = new AcctSeed__Accounting_Period__c(
                 Name = '1991-10',
                 AcctSeed__Start_Date__c = Date.newinstance(1991, 10, 1),
                 AcctSeed__End_Date__c = Date.newinstance(1991, 10, 31),
                 AcctSeed__Status__c = 'Open');
         insert acctPeriod;
         
         AcctSeed__Accounting_Period__c acctPeriod1 = new AcctSeed__Accounting_Period__c(
                 Name = '1992-10',
                 AcctSeed__Start_Date__c = Date.newinstance(1992, 10, 1),
                 AcctSeed__End_Date__c = Date.newinstance(1992, 10, 31),
                 AcctSeed__Status__c = 'Open');
         insert acctPeriod1;
 
     // —— START HERE ——
         AcctSeed__Journal_Entry__c je = new AcctSeed__Journal_Entry__c(
                 Name = 'Test JE',
             AcctSeed__Journal_Date__c = Date.newinstance(2023, 09, 25),
                 AcctSeed__Ledger__c = ledger.Id,
                 AcctSeed__Accounting_Period__c = acctPeriod.id
         );
 
         insert je;
         
         je.AcctSeed__Journal_Date__c = System.today();
         update je;
         
         je.AcctSeed__Accounting_Period__c = acctPeriod1.Id;
         update je;
         
         AcctSeed__Journal_Entry_Line__c jel = new AcctSeed__Journal_Entry_Line__c(
                 AcctSeed__GL_Account__c = CashGL.Id,
                 AcctSeed__Debit__c = 100,
                 AcctSeed__Account__c = acc.id,
             AcctSeed__Journal_Entry__c = je.Id
         );
 
         insert jel;
         
         jel.AcctSeed__Debit__c = 120;
         update jel;
         
         jel.AcctSeed__Account__c = acc1.id;
         update jel;
         
         
         jel.AcctSeed__GL_Account__c = CashGL1.id;
         update jel;
         
        delete jel;
         
         AcctSeed__Journal_Entry_Line__c jel1 = new AcctSeed__Journal_Entry_Line__c(
                 AcctSeed__GL_Account__c = CashGL.Id,
                 AcctSeed__Credit__c = 10,
                 AcctSeed__Account__c = acc.id,
             AcctSeed__Journal_Entry__c = je.Id
         );
 
         insert jel1;
         
         jel1.AcctSeed__Credit__c = 11;
         update jel1;
         
         delete jel1;
         
         AcctSeed__Journal_Entry__c je1 = new AcctSeed__Journal_Entry__c(
                 Name = 'Test JE1',
             AcctSeed__Journal_Date__c = Date.newinstance(2023, 09, 25),
                 AcctSeed__Ledger__c = ledger.Id,
                 AcctSeed__Accounting_Period__c = acctPeriod.id
         );
 
         insert je1;
         
         delete je1;
         
     }
}