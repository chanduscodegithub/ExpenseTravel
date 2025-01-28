public class billingFromBCController {
    
    public Billing__c transactionRec{get;set;}
     public String selectedAccPer {get; set;}
    public List<AcctSeed__Ledger__c> ledgerList{get;set;}
    public String defaultledger{get;set;}
    public List<wrappedLines> lineitems{get;set;}
    public String revenueGLaccount{get;set;}
    public String Ledgernames{get;set;}
    public Decimal Headertotal{get;set;}
    public boolean NoTax{get;set;}
    public Date invoiceDate{get;set;}
    public Decimal Quantity{get;set;}
    public Date invoiceLineDate{get;set;}
    Public decimal subtotalamount{get;set;}
    Public String DaysDue{get;set;}
    //Public Id tranID{get;set;}
    Public date Invoicedateies {get;set;}
     public  date startdate;
     public  date enddate;
    public static decimal totalhours {get;set;}
     public  Decimal totalHoursSum {get;set;}
    Public Id tranID{get;set;}
     public static string projectId;
     public List<SelectOption> accperList { get; set; }
    public boolean accprd{get;set;} 
    
    
    public billingFromBCController(ApexPages.StandardController stdController) {
        System.debug('inv::'+ invoiceDate);
        subtotalamount = 0.0;
        //DaysDue = 0; HSN_Code__c
        transactionRec=new Billing__c();
        ledgerList=new List<AcctSeed__Ledger__c>();
        Id tranID=((Billing__c) stdController.getrecord()).Id;
        transactionRec =  [SELECT Account__c,Opportunity__c,PO_Number__c,Account__r.AcctSeed__Billing_Days_Due__c,Account__r.Name,CurrencyIsoCode,Date_of_Payment_1__c,Date_of_Payment_2__c,
                           Date_of_Payment_3__c,Description__c,Due_Date__c,Id,Invoice_Amount__c,Invoice_Date__c,Invoice_Month__c,Name,OpportunityName__c,OpportunityVO_Id_c__c,OpportunityName__r.AccountId,
                           OpportunityName__r.Account.Name,Payment_Received_1__c,Payment_Received_2__c,Payment_Received_3__c,Product__c,Qty__c,Rate__c,Record_ID__c,Resource_Name__c,
                           Status__c,Total_Invoiced_Amount__c,Total_Opportunity_Amount__c,Total_Payment_Received__c,Product__r.AcctSeed__Tax_Group__c,
                           Product__r.AcctSeed__Tax_Group__r.AcctSeed__Combined_Tax_Rate__c,Product__r.AcctSeed__Revenue_GL_Account__c,Billing_Period__c,Ledger__r.name FROM Billing__c where Id=:tranID];
        if(transactionRec.Product__r.AcctSeed__Revenue_GL_Account__c==null){
            revenueGLaccount='30005-Consulting Income';
        }
        
		DaysDue = transactionRec.Account__r.AcctSeed__Billing_Days_Due__c != null ? String.valueOf(transactionRec.Account__r.AcctSeed__Billing_Days_Due__c) + '  Days'  : '';
        
        System.debug('DaysDue::'+DaysDue);
        if(transactionRec.Qty__c == null || transactionRec.Rate__c == null ||transactionRec.Ledger__c == null ) {
         transactionRec.addError('Quantity, Rate and Ledger cannot be blank');
       // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quantity Rate and Ledger cannot be empty'));
        }
        else{

        lineitems=new List<wrappedLines>();
        wrappedLines wrap=new wrappedLines();
        wrap.billingLineRec=transactionRec;
       subtotalamount = transactionRec.Rate__c * transactionRec.Qty__c;
        if(transactionRec.Product__r.AcctSeed__Tax_Group__r.AcctSeed__Combined_Tax_Rate__c !=null){
            wrap.Taxamount=((transactionRec.Rate__c * transactionRec.Qty__c) * (transactionRec.Product__r.AcctSeed__Tax_Group__r.AcctSeed__Combined_Tax_Rate__c / 100)).setscale(2);
            Headertotal=((transactionRec.Rate__c * transactionRec.Qty__c) + (transactionRec.Rate__c * transactionRec.Qty__c) * (transactionRec.Product__r.AcctSeed__Tax_Group__r.AcctSeed__Combined_Tax_Rate__c / 100)).setscale(2);
            system.debug('Headertotal>'+Headertotal);
        }
        else{
            NoTax=true;
            wrap.Taxamount=0;
            Headertotal=(transactionRec.Rate__c * transactionRec.Qty__c).setscale(2);
            system.debug('Headertotal>'+Headertotal);
        }
        lineitems.add(wrap);
        
        
        for(AcctSeed__Ledger__c legd : [Select Id,Name,AcctSeed__Type__c FROM AcctSeed__Ledger__c where AcctSeed__Type__c='Transactional']){
            if(transactionRec.Ledger__r.name == legd.name){
                defaultledger=legd.name;
            }
        }
        }
        
        
        system.debug('defaultledger>>>'+defaultledger);
        
        getaccperList();
    }
    
    
    /*public list<SelectOption> getLedgernames()
{
list<SelectOption> soList = new list<SelectOption>();
for(AcctSeed__Ledger__c legd : [Select Id,Name,AcctSeed__Type__c FROM AcctSeed__Ledger__c where AcctSeed__Type__c='Transactional']){
if(transactionRec.CurrencyIsoCode == legd.CurrencyIsoCode){
defaultledger=legd.CurrencyIsoCode;}
soList.add(new SelectOption(legd.id, legd.Name));
}

return soList;
}*/
    
    
    
    
    public PageReference createBilling()
    {
        
         if(transactionRec.Qty__c == null || transactionRec.Rate__c == null ||transactionRec.Ledger__c == null ) {
             system.debug('inside if++');
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quantity, Rate and Ledger cannot be blank'));
             return Null;
        }     
          else{
              system.debug('inside else+++');
        if(invoiceDate==null && !Test.isRunningTest()){
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Please Provide the Billing Date'));
            return Null;
        }
        
        Date today=System.today();
        AcctSeed__Billing__c createBilling=new AcctSeed__Billing__c();
        if(Test.isRunningTest()){
            createBilling.AcctSeed__Date__c = system.today();
            invoiceDate = system.today();
        }else{
            createBilling.AcctSeed__Date__c = invoiceDate; 
        }
        createBilling.Billing_Terms_Name__c = DaysDue;
        createBilling.AcctSeed__Customer__c = transactionRec.OpportunityName__r.AccountId;
        createBilling.AcctSeed__Status__c = 'Approved';
        createBilling.Billing_Customer__c = transactionRec.id;
        createBilling.AcctSeed__Opportunity__c = transactionRec.OpportunityName__c;
        createBilling.AcctSeed__PO_Number__c = transactionRec.PO_Number__c;
        //createBilling.AcctSeed__Due_Date2__c = System.today() + 30,
        createBilling.AcctSeed__Ledger__c = [Select Id,Name,AcctSeed__Type__c FROM AcctSeed__Ledger__c where name=:defaultledger and AcctSeed__Type__c = 'Transactional' LIMIT 1].Id;
        createBilling.AcctSeed__Billing_Format__c =  [Select Id,Name,AcctSeed__Type__c,AcctSeed__Default_Billing_Format__c FROM AcctSeed__Ledger__c where name=:defaultledger and AcctSeed__Type__c = 'Transactional' LIMIT 1].AcctSeed__Default_Billing_Format__c;
        //createBilling.AcctSeed__Accounting_Period__c = [Select Id,AcctSeed__Start_Date__c,AcctSeed__End_Date__c From AcctSeed__Accounting_Period__c where AcctSeed__Start_Date__c <= today and AcctSeed__End_Date__c >= today and AcctSeed__Status__c = 'Open' limit 1].Id;
        
        String accountingPeriodName = String.valueOf(invoiceDate.year()) + '-' + (invoiceDate.month() >= 1 && invoiceDate.month() <= 9 ? '0' + String.valueOf(invoiceDate.month()) : String.valueOf(invoiceDate.month()));
        list<AcctSeed__Accounting_Period__c> lsacccprrd =  [Select Id,Name From AcctSeed__Accounting_Period__c where Name =: accountingPeriodName];
        if(lsacccprrd.size()> 0){
             createBilling.AcctSeed__Accounting_Period__c = [Select Id,Name From AcctSeed__Accounting_Period__c where Name =: String.valueOf(invoiceDate.year()) + '-' + (invoiceDate.month() >= 1 &&  invoiceDate.month() <= 9 ?  '0' + String.valueOf(invoiceDate.month()) : String.valueOf(invoiceDate.month())) and AcctSeed__Status__c = 'Open' limit 1].Id;
        }else{
             ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'particular accounting period is not available!'));
            return Null;
           
        }
        
      
       
        
        
        createBilling.CurrencyIsoCode=transactionRec.CurrencyIsoCode;
        //createBilling.Ledger_Name__c= transactionRec.Ledger__c;
        createBilling.AcctSeed__Proprietary_Billing_Number__c=transactionRec.Name;
           
        AcctSeed__Ledger__c ldgr = [select Id,Name from AcctSeed__Ledger__c where Name = 'CRMIT - India'];
        if(ldgr.Name == 'CRMIT - India'){
           // createBilling.HSN_Code__c = transactionRec.HSN_Code__c;
        }
        
        insert createBilling;
        System.debug('createBilling::'+createBilling);
        
        List<AcctSeed__Billing_Line__c> billinglinelist=new List<AcctSeed__Billing_Line__c>();
        for(wrappedLines wrap:lineitems) {
            AcctSeed__Billing_Line__c objBillingLine = new AcctSeed__Billing_Line__c();
            objBillingLine.AcctSeed__Billing__c = createBilling.id;
            if(Test.isRunningTest()){
                objBillingLine.AcctSeed__Date__c = system.today();
            }else{
                objBillingLine.AcctSeed__Date__c = invoiceDate;
            }
            objBillingLine.AcctSeed__Rate__c = wrap.billingLineRec.Rate__c;
            objBillingLine.AcctSeed__Hours_Units__c = wrap.billingLineRec.Qty__c;
            objBillingLine.AcctSeed__Tax_Group__c=wrap.billingLineRec.Product__r.AcctSeed__Tax_Group__c;
            objBillingLine.AcctSeed__Revenue_GL_Account__c = wrap.billingLineRec.Product__r.AcctSeed__Revenue_GL_Account__c;
            String Str=(wrap.billingLineRec.Description__c != null ? wrap.billingLineRec.Description__c : '');
               Str+= +'<br/>'+(wrap.billingLineRec.Billing_Period__c != null ? wrap.billingLineRec.Billing_Period__c : '');
                Str+=+'<br/>'+(wrap.billingLineRec.Resource_Name__c != null ? wrap.billingLineRec.Resource_Name__c : '');
            objBillingLine.AcctSeed__Comment__c = Str.stripHtmlTags() ;
            objBillingLine.AcctSeed__Product__c= wrap.billingLineRec.Product__c;
            objBillingLine.Content_discription__c = Str.stripHtmlTags() ;
            billinglinelist.add(objBillingLine);
        }
        insert billinglinelist;
        
        Billing__c billingUpdate=new Billing__c();
        billingUpdate.Id = transactionRec.id;
        billingUpdate.Invoice_Date__c=invoiceDate;
       // billingUpdate.Milestone_Amount__c = subtotalamount;
        billingUpdate.Invoice_Amount__c = subtotalamount;
        billingUpdate.Invoice_Billing_date__c=Invoicedateies;
        update billingUpdate;
        
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Billing Record Created Successfully!'));
        PageReference pg = new PageReference(URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/AcctSeed__Billing__c/'+createBilling.id+'/view');
        pg.setRedirect(true);
        return pg;  
        
    }
    }
    public PageReference createBillingAndPost()
    {
         if(transactionRec.Qty__c == null || transactionRec.Rate__c == null ||transactionRec.Ledger__c == null ) {
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Quantity Rate and Ledger cannot be blank'));
             return Null;
        }
        else{
        if(invoiceDate==null && !Test.isRunningTest()){
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Please Provide the Billing Date'));
            return Null;
        }

        Date today=System.today();
        List<AcctSeed__Billing__c> billinglist=new List<AcctSeed__Billing__c>();
        
        AcctSeed__Billing__c createBilling=new AcctSeed__Billing__c();
        if(Test.isRunningTest()){
            createBilling.AcctSeed__Date__c = system.today();
            invoiceDate = system.today();
        }else{
            createBilling.AcctSeed__Date__c = invoiceDate; 
        }
        
        createBilling.AcctSeed__Customer__c = transactionRec.OpportunityName__r.AccountId;
        createBilling.Billing_Customer__c = transactionRec.id;
        createBilling.AcctSeed__Status__c = 'Approved';
        createBilling.AcctSeed__Opportunity__c = transactionRec.OpportunityName__c;
        createBilling.AcctSeed__PO_Number__c = transactionRec.PO_Number__c;
        createBilling.Billing_Terms_Name__c = DaysDue;
        //createBilling.AcctSeed__Due_Date2__c = System.today() + 30,
        createBilling.AcctSeed__Ledger__c = [Select Id,Name,AcctSeed__Type__c,AcctSeed__Default_Billing_Format__c FROM AcctSeed__Ledger__c where name=:defaultledger and AcctSeed__Type__c = 'Transactional' LIMIT 1].Id;
        createBilling.AcctSeed__Billing_Format__c =  [Select Id,Name,AcctSeed__Type__c,AcctSeed__Default_Billing_Format__c FROM AcctSeed__Ledger__c where name=:defaultledger and AcctSeed__Type__c = 'Transactional' LIMIT 1].AcctSeed__Default_Billing_Format__c;
     
        String accountingPeriodName = String.valueOf(invoiceDate.year()) + '-' + (invoiceDate.month() >= 1 && invoiceDate.month() <= 9 ? '0' + String.valueOf(invoiceDate.month()) : String.valueOf(invoiceDate.month()));
        list<AcctSeed__Accounting_Period__c> lsacccprrd =  [Select Id,Name From AcctSeed__Accounting_Period__c where Name =: accountingPeriodName];
        if(lsacccprrd.size()> 0){
             createBilling.AcctSeed__Accounting_Period__c = [Select Id,Name From AcctSeed__Accounting_Period__c where Name =: String.valueOf(invoiceDate.year()) + '-' + (invoiceDate.month() >= 1 &&  invoiceDate.month() <= 9 ?  '0' + String.valueOf(invoiceDate.month()) : String.valueOf(invoiceDate.month())) and AcctSeed__Status__c = 'Open' limit 1].Id;
        }else{
             ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'particular accounting period is not available!'));
            return Null;
           
        }
        
       
        createBilling.CurrencyIsoCode=transactionRec.CurrencyIsoCode;
       // createBilling.Ledger_Name__c = transactionRec.Ledger__c;
        createBilling.AcctSeed__Proprietary_Billing_Number__c=transactionRec.Name;
        createBilling.AcctSeed__Billing_Comment__c=transactionRec.Description__c;
        insert createBilling;
        billinglist.add(createBilling);
        List<AcctSeed__Billing_Line__c> billinglinelist=new List<AcctSeed__Billing_Line__c>();
        for(wrappedLines wrap:lineitems) {
            AcctSeed__Billing_Line__c objBillingLine = new AcctSeed__Billing_Line__c();
            objBillingLine.AcctSeed__Billing__c = createBilling.id;
            if(Test.isRunningTest()){
                objBillingLine.AcctSeed__Date__c = system.today();
            }else{
                objBillingLine.AcctSeed__Date__c = invoiceDate;
            }
            objBillingLine.AcctSeed__Rate__c = wrap.billingLineRec.Rate__c;
            objBillingLine.AcctSeed__Hours_Units__c = wrap.billingLineRec.Qty__c;
            objBillingLine.AcctSeed__Tax_Group__c=wrap.billingLineRec.Product__r.AcctSeed__Tax_Group__c;
            objBillingLine.AcctSeed__Revenue_GL_Account__c = wrap.billingLineRec.Product__r.AcctSeed__Revenue_GL_Account__c;
           String Str=(wrap.billingLineRec.Description__c != null ? wrap.billingLineRec.Description__c : '');
               Str+= +'<br/>'+(wrap.billingLineRec.Billing_Period__c != null ? wrap.billingLineRec.Billing_Period__c : '');
                Str+=+'<br/>'+(wrap.billingLineRec.Resource_Name__c != null ? wrap.billingLineRec.Resource_Name__c : '');
            objBillingLine.AcctSeed__Comment__c = Str.stripHtmlTags() ;
            objBillingLine.AcctSeed__Product__c= wrap.billingLineRec.Product__c;
            objBillingLine.Content_discription__c = Str.stripHtmlTags() ;
            billinglinelist.add(objBillingLine);
        }
        insert billinglinelist;
        AcctSeed.PostResult[] postResults = AcctSeed.BillingPostService.postBillings(billinglist);
        
        // Loop through post results
        for (AcctSeed.PostResult theResult : postResults) {
            if (theResult.isSuccess) {
                System.debug('Successfully posted billing: ' + theResult.id);
            } 
            else {
                System.debug('Error posting billing ' + theResult.id);
                for (AcctSeed.PostResult.PostErrorResult errorResult: theResult.errors) {
                    System.debug('Error status code ' + errorResult.statusCode);
                    System.debug('Error message ' + errorResult.message);
                }
            }
        }
        
        Billing__c billingUpdate=new Billing__c();
        billingUpdate.Id = transactionRec.id;
       // billingUpdate.Milestone_Amount__c = subtotalamount;
        billingUpdate.Invoice_Amount__c = subtotalamount;
        update billingUpdate;
        
        ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Billing Record Created Successfully!'));
        PageReference pg = new PageReference(URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/AcctSeed__Billing__c/'+createBilling.id+'/view');
        pg.setRedirect(true);
        return pg;  
    }
    }
    /* public PageReference cancel()
{
PageReference pg = new PageReference(URL.getSalesforceBaseUrl().toExternalForm()+'/lightning/r/Billing__c/'+transactionRec.id+'/view');
pg.setRedirect(true);
return pg;  

}*/
    public void getautopopultevalue()
    {
        invoiceLineDate=invoiceDate;
    }
    public class wrappedLines       
    {
        public Boolean isSelected{get;set;}
        public Billing__c billingLineRec{get;set;}
        public Decimal Taxamount{get;set;}
    }
    
      public List<SelectOption> getaccperList() {
        List<SelectOption> Options = new List<SelectOption>();
        List<AcctSeed__Accounting_Period__c> listAccperiod = [
            SELECT Name FROM AcctSeed__Accounting_Period__c ORDER BY Name DESC
        ];
          system.debug('listAccperiod>>>'+listAccperiod);
        for (AcctSeed__Accounting_Period__c acc : listAccperiod) {
            // Create a SelectOption object and add it to accperList
            Options.add(new SelectOption(acc.Name, acc.Name));
        }

        // Set the accperList property
        accperList = Options;
system.debug('accperList>>>'+accperList);
        return Options;
    }
 public void handleSelectionChange() {
        String inputDate = selectedAccPer;
        String outputDateStr = inputDate + '-01';

// Convert the string to a Date
Date outputDate = Date.valueOf(outputDateStr);
Invoicedateies=outputDate;
System.debug('Output Date: ' + Invoicedateies);
      
     /*   system.debug('selectedAccPer>>'+selectedAccPer);
        list<AcctSeed__Accounting_Period__c> acclist = [select id, name,
                                                         AcctSeed__Start_Date__c,
                                                         AcctSeed__End_Date__c 
                                                         from AcctSeed__Accounting_Period__c
                                                         where name=:selectedAccPer];
         system.debug('acclist>>>'+acclist);
        for(AcctSeed__Accounting_Period__c aclists : acclist ){
              startdate =aclists.AcctSeed__Start_Date__c;
              enddate=aclists.AcctSeed__End_Date__c;
        }
        
        system.debug('startdate>>>'+startdate);
        system.debug('enddate>>>'+enddate);
         totalHoursSum=0;
        
         Id optid =[select id, OpportunityName__c from Billing__c where id = :tranID ].OpportunityName__c;
        Id projectif =[select Id, Opportunity__c from Project__c where Opportunity__r.id=:optid].Id;
        projectId=projectif;
        system.debug('projectif>>>'+projectId);
         totalHoursSum=0;
          // tisheetactivity(startdate, enddate, projectId); */
    }  
    
    
}