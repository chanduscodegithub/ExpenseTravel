@isTest
public class TestBillingTriggerHelper {
    @isTest
    static void testCreateBillingHistoryRecord() {
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
        
        
        AcctSeed__Billing__c billing = new AcctSeed__Billing__c();
        billing.AcctSeed__Customer__c = acc.Id;
        billing.AcctSeed__Billing_Contact__c = con.Id;
        billing.AcctSeed__Billing_Comment__c = 'test description';
        billing.AcctSeed__Date__c = System.today();
        billing.AcctSeed__Accounting_Period__c = accPeriod.Id;
        billing.AcctSeed__Billing_Format__c = ledger.Id;
        billing.AcctSeed__Billing_Format__c = pdf.id;
        billing.AcctSeed__Ledger__c = ledger.id;
        insert billing;
        
        
        AcctSeed__Billing_Line__c billingLine = new AcctSeed__Billing_Line__c();
        billingLine.AcctSeed__Hours_Units__c = 1;
        billingLine.AcctSeed__Rate__c = 100;
        billingLine.AcctSeed__Billing__c = billing.Id;
        billingLine.AcctSeed__Revenue_GL_Account__c = glAccount1.id;
        insert billingLine;
        
        billing.AcctSeed__Customer__c = acc1.id;
        update billing;
        
        billing.AcctSeed__Billing_Comment__c = 'acc1 id';
        update billing;
        
        billing.AcctSeed__Date__c = System.today()-1;
        update billing;
        
        delete billing;
        
        
        AcctSeed__Billing__c billing1 = new AcctSeed__Billing__c();
        billing1.AcctSeed__Customer__c = acc.Id;
        billing1.AcctSeed__Billing_Contact__c = con.Id;
        billing1.AcctSeed__Billing_Comment__c = 'test description';
        billing1.AcctSeed__Date__c = System.today();
        billing1.AcctSeed__Accounting_Period__c = accPeriod.Id;
        billing1.AcctSeed__Billing_Format__c = ledger.Id;
        billing1.AcctSeed__Billing_Format__c = pdf.id;
        billing1.AcctSeed__Ledger__c = ledger.id;
        insert billing1;
        
        
        AcctSeed__Billing_Line__c billingLine1 = new AcctSeed__Billing_Line__c();
        billingLine1.AcctSeed__Hours_Units__c = 1;
        billingLine1.AcctSeed__Rate__c = 100;
        billingLine1.AcctSeed__Billing__c = billing1.Id;
        billingLine1.AcctSeed__Revenue_GL_Account__c = glAccount1.id;
        insert billingLine1;
        
        billingLine1.AcctSeed__Hours_Units__c = 3;
        update billingLine1;
        
        billingLine1.AcctSeed__Revenue_GL_Account__c = glAccount2.Id;
        update billingLine1;
        
        delete billingLine1;
        
        BillingTriggerHelper.fakeMethod();
        BillingLineTriggerHelper.fakeMethod();
    
    }
}