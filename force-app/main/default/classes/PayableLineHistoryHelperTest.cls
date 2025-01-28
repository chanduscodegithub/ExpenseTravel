@isTest
public class PayableLineHistoryHelperTest
{
    @isTest
    static void testCreatePayableHistoryRecord() {
        Account acc = new Account();
        acc.Name = 'test';
        acc.Type = 'Prospect';
        acc.AcctSeed__Accounting_Type__c = 'Customer';
        insert acc;
        
        Account acc1 = new Account();
        acc1.Name = 'test';
        acc1.Type = 'Prospect';
        acc1.AcctSeed__Accounting_Type__c = 'Customer';
        insert acc1;
        
        Contact con = new Contact ();
        con.LastName = 'test con1';
        con.AccountId = acc.Id;
        insert con;
        
        AcctSeed__Accounting_Period__c accPeriod = new AcctSeed__Accounting_Period__c();
        accPeriod.Name = '2023-08';
        accPeriod.AcctSeed__Start_Date__c = System.today();
        accPeriod.AcctSeed__End_Date__c = System.today() +325;
        accPeriod.AcctSeed__Status__c = 'Open';
        insert accPeriod;
        
        AcctSeed__Billing_Format__c pdf = new AcctSeed__Billing_Format__c();
        pdf.Name = 'Default Billing Product-INR';
        pdf.AcctSeed__Type__c = 'Billing';
        pdf.AcctSeed__Visualforce_PDF_Page__c = 'BillingProductPDF';
        pdf.AcctSeed__Default_Email_Template__c = [Select Id, DeveloperName From EmailTemplate limit 1].DeveloperName;
        insert pdf;
        
        AcctSeed__GL_Account__c glAccount = new AcctSeed__GL_Account__c();
        glAccount.Name = '10102-Citi Current A/c INR - 0044639807';
        glAccount.AcctSeed__Type__c = 'Revenue';
        glAccount.AcctSeed__Sub_Type_1__c = 'Product Revenue';
        //glAccount.AcctSeed__Sub_Type_2__c = 'Bank Accounts';
        glAccount.AcctSeed__Bank__c = true;
        insert glAccount;
        
        AcctSeed__GL_Account__c glAccount1 = new AcctSeed__GL_Account__c();
        glAccount1.Name = '10102-Citi Current A/c INR - 0044639807';
        glAccount1.AcctSeed__Type__c = 'Revenue';
        glAccount1.AcctSeed__Sub_Type_1__c = 'Product Revenue';
        //glAccount.AcctSeed__Sub_Type_2__c = 'Bank Accounts';
        //glAccount.AcctSeed__Bank__c = true;
        insert glAccount1;
        
        AcctSeed__GL_Account__c glAccount2 = new AcctSeed__GL_Account__c();
        glAccount2.Name = '10102-Citi Current A/c INR - 0044639807';
        glAccount2.AcctSeed__Type__c = 'Revenue';
        glAccount2.AcctSeed__Sub_Type_1__c = 'Product Revenue';
        //glAccount.AcctSeed__Sub_Type_2__c = 'Bank Accounts';
        //glAccount.AcctSeed__Bank__c = true;
        insert glAccount2;
        
        AcctSeed__Ledger__c ledger = new AcctSeed__Ledger__c();
        ledger.Name = 'Actual';
        ledger.AcctSeed__Type__c ='Transactional';
        ledger.AcctSeed__Billing_Activity_Statement_Format__c = pdf.id;
        ledger.AcctSeed__Billing_Outstanding_Statement_Format__c = pdf.id;
        ledger.AcctSeed__Default_Bank_Account__c = glAccount.id;
        ledger.AcctSeed__Default_Billing_Format__c = pdf.id;
        insert ledger;
        
        
        AcctSeed__Account_Payable__c invoice = new AcctSeed__Account_Payable__c(
            AcctSeed__Payee_Reference__c = '1',
            AcctSeed__Vendor__c = acc.Id,
            AcctSeed__Accounting_Period__c = accPeriod.Id,
            AcctSeed__Ledger__c = ledger.Id,
            AcctSeed__Date__c = Date.newinstance(2023, 09, 11),
            Description__c = 'test description'
            
        );
 
         insert invoice;
        
        
        AcctSeed__Account_Payable_Line__c payableLine = new AcctSeed__Account_Payable_Line__c();
        payableLine.AcctSeed__Date__c = System.today()-2;
        payableLine.AcctSeed__Account_Payable__c = invoice.Id;
        payableLine.AcctSeed__Expense_GL_Account__c = glAccount1.id;
        payableLine.AcctSeed__Unit_Cost__c = 100;
        insert payableLine;
        
        invoice.AcctSeed__Vendor__c = acc1.id;
        update invoice;
        
        invoice.Description__c ='TEST DESC';
        update invoice;
        
        delete invoice;
        
        
        AcctSeed__Account_Payable__c invoice1 = new AcctSeed__Account_Payable__c(
            AcctSeed__Payee_Reference__c = '1',
            AcctSeed__Vendor__c = acc.Id,
            AcctSeed__Accounting_Period__c = accPeriod.Id,
            AcctSeed__Ledger__c = ledger.Id
            
        );
 
         insert invoice1;
        
        
        AcctSeed__Account_Payable_Line__c payableLine1 = new AcctSeed__Account_Payable_Line__c();
        payableLine1.AcctSeed__Date__c = System.today();
        payableLine1.AcctSeed__Account_Payable__c = invoice1.Id;
        payableLine1.AcctSeed__Expense_GL_Account__c = glAccount1.id;
        payableLine1.AcctSeed__Unit_Cost__c = 100;
        insert payableLine1;
        
        payableLine1.AcctSeed__Date__c = System.today()+1;
        update payableLine1;
        
        payableLine1.AcctSeed__Expense_GL_Account__c = glAccount2.Id;
        update payableLine1;
        
        delete payableLine1;
        
        PayableHistoryHelper.fakeMethod();
        PayableLineHistoryHelper.fakeMethod();
    
    }
}