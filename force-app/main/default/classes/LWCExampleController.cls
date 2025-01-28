public with sharing class LWCExampleController {
    @AuraEnabled(Cacheable = true)
    public static List<String> getAccperiodList(){
      List<String> accperList=new List<String>();
      List<AcctSeed__Accounting_Period__c> listAccperiod= [SELECT name FROM AcctSeed__Accounting_Period__c ORDER BY name DESC];
    for(AcctSeed__Accounting_Period__c acc:listAccperiod){
      accperList.add(acc.Name);
    }
    return accperList;
    }
    @AuraEnabled(Cacheable = true)
    public static List<GST_Returns__c> getgstreturnList(String selectedPeriod,String selectedType){
      List<GST_Returns__c> gstdata =  [SELECT Invoice_date__c,Currency_Conversion_Rate__c,Is_the_supplier_a_Composition_dealer__c,Type_of_Import_Goods_Services_SEZ__c,Credit_Debit_Note_Date__c,Is_Reverse_Charge_Applicable__c,GST_Subtype__c,Type_of_Export__c,Original_Invoice_Number__c,GST_Type__c,Is_this_a_Bill_of_Supply__c,Reason_for_issuing_CDN__c,Credit_Debit_Note_Number__c,ITC_Claim_Type__c , Document_total_value__c,C_Dealer_UIN__c,documentType__c,documentDate__c,documentNumber__c,customerName__c,customerGstin__c,placeOfSupply__c,IsService__c,hsnSacCode__c,gstRate__c,itemTaxableAmount__c,cgstRate__c,cgstAmount__c,sgstRate__c,sgstAmount__c,igstRate__c,igstAmount__c,cdnReason__c,isReverseCharge__c,returnFilingMonth__c,supplierName__c,LinkedAdvanceDocumentNumber__c,linkedAdvanceDocumentDate__c,linkedAdvanceAdjustmentAmount__c,linkedInvoiceNumber__c,linkedInvoiceDate__c,linkedInvoiceCustomerGstin__c,supplierGstin__c,customerAddress__c,customerCity__c,customerState__c,supplierAddress__c,supplierCity__c,supplierState__c,customerTaxpayerType__c,zeroTaxCategory__c,isTdsDeducted__c,itemQuantity__c,itemUnitPrice__c,paymentDueDate__c,MyGSTIN__c,Is_this_document_Cancelled__c FROM GST_Returns__c where returnFilingMonth__c=:selectedPeriod and RecordType.Name=:selectedType];     
       return gstdata;
    }
    @AuraEnabled
    public static void getcsv(String getcsvString,String Transactiontype,String AccountingPeriod ) {
      system.debug('getcsvString '+getcsvString);
      String filename = Transactiontype + '-' + AccountingPeriod;
      List<GST_Return_Files__c> delgstList = [Select Id,Name from GST_Return_Files__c where Name =: filename ];
      if(delgstList.size()>0)
      Delete delgstList;
      
      GST_Return_Files__c gstfiles = new GST_Return_Files__c();
      gstfiles.Name = Transactiontype + '-' + AccountingPeriod ;
      gstfiles.Transaction_Type__c =Transactiontype ;
      gstfiles.Accounting_Period__c = AccountingPeriod;
      // if(gstfiles.Transaction_Type__c == 'Purchase'){
      // gstfiles.templateType__c = 'purchase';
      // gstfiles.templateID__c= '60e5613ff71f4a7aeca4336b';
      // gstfiles.tenant__c='MAXITC';
      // }
      // else {
      //   gstfiles.templateID__c='618a5623836651c01c1498ad';
      //   gstfiles.templateType__c='sales';
      //   gstfiles.tenant__c='GSTSALES';
      // }

      insert gstfiles;

Attachment attachment = new Attachment();
attachment.ParentId = gstfiles.Id;
attachment.Name = gstfiles.Name+'.csv';
attachment.Body =Blob.valueOf(getcsvString); 
insert attachment;







    }



}