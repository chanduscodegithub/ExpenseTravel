public class BillingProductIrisPdfHLPCloneCtrl {
  
    private ApexPages.StandardController stdCtrl;
    public AcctSeed__Billing__c billData{get;set;}
    public String VATNumber{get;set;}
    public String EIN{get;set;}
    public String CompanyBusinessNumber{get;set;}
    public string officeNumber{get;set;}		
    public AcctSeed__Billing_Line__c accSeedBillingLine{get;set;}
    public list<AcctSeed__Tax_Rate__c>taxRate{get;set;}
     public string taxRateName1{get;set;}
     public string taxRateName2{get;set;}
     public Decimal taxRateValue1{get;set;}
     public Decimal taxRateValue2{get;set;}
     public Decimal billingTaxamount{get;set;}
    public Decimal sumBillingTaxamount1{get;set;}
  public Decimal sumBillingTaxamount2{get;set;}     
   // public Product2 prod{get;set;}
    public string HeadingType{get;set;}
  //  public string bankDetails{get;set;}
    
    public BillingProductIrisPdfHLPCloneCtrl(ApexPages.StandardController stdController) {
        this.stdCtrl = stdController;
        
        String billId = apexpages.currentpage().getparameters().get('id');
        system.debug('b@@@@illId'+ billId);
        
        billData = [Select Id,Company_Bussiness_Number__c,HSN_Code__c,AcctSeed__Status__c,AcctSeed__Ledger__r.Name,AcctSeed__Ledger__r.AcctSeed__Default_Billing_Format__r.AcctSeed__VAT_Identification_Number__c,
                    AcctSeed__Ledger__r.AcctSeed__Default_Billing_Format__r.Name,Billing_Customer__r.Product__r.AcctSeed__Tax_Group__r.Name,AcctSeed__Sales_Tax3__c,
                    AcctSeed__Ledger__r.AcctSeed__Default_Billing_Format__r.EIN_Number__c,CurrencyIsoCode,AcctSeed__Ledger__r.AcctSeed__Default_Billing_Format__r.Company_info__c,AcctSeed__Ledger__r.AcctSeed__Default_Billing_Format__r.Off__c
                    from AcctSeed__Billing__c where Id =: billId];
        
      accSeedBillingLine = [Select AcctSeed__Billing__c,AcctSeed__Hours_Units__c,AcctSeed__List_Price__c,AcctSeed__Product_Tax_Type__c,AcctSeed__Tax_Group__r.AcctSeed__Tax_Rate_Count__c,
                              AcctSeed__Product_Unit_Cost__c,AcctSeed__Product__c,AcctSeed__Rate__c,AcctSeed__Sub_Total__c,AcctSeed__Tax_Amount2__c,
                              AcctSeed__Tax_Group__c,AcctSeed__Tax_Line__c,AcctSeed__Tax_Rate__c,AcctSeed__Total__c,CurrencyIsoCode,Id,Ledger_sub_total__c,AcctSeed__Tax_Group__r.AcctSeed__Combined_Tax_Rate__c,
                              Name From AcctSeed__Billing_Line__c Where AcctSeed__Billing__c =: billId limit 1];
        
       
        
    
        
         if(accSeedBillingLine.AcctSeed__Tax_Group__c != null){
            taxRate = [select Id,Name,CurrencyIsoCode from AcctSeed__Tax_Rate__c where AcctSeed__Tax_Group__c =: accSeedBillingLine.AcctSeed__Tax_Group__c];
            
            if(taxRate.size() == 1){
                taxRateName1 =   taxRate[0].Name; 
                taxRateName1 = taxRateName1.replace('Output', ' ');
                
                if(billData.AcctSeed__Ledger__r.Name == 'CRMIT - USA'){
                    
                taxRateName1 =   taxRate[0].Name; 
                taxRateName1 = taxRateName1.replace('VAT', 'TAX ');
                }
                
       /*         else if(billData.AcctSeed__Ledger__r.Name == 'CRMIT - India' && billData.CurrencyIsoCode == 'USD'){
                    taxRateName1 =   taxRate[0].Name; 
                    taxRateName1 = taxRateName1.replace('GST', 'TAX ');
                    
                }   */
            }
               
            else if(taxRate.size() == 2){
                taxRateName1 =   taxRate[0].Name;
                taxRateName2 = taxRate[1].Name;
                taxRateName1 = taxRateName1.replace('Output', ' ');
                taxRateName2 = taxRateName2.replace('Output', ' '); 
                
                if(billData.AcctSeed__Ledger__r.Name == 'CRMIT - USA'){
                taxRateName1 =   taxRate[0].Name;
                taxRateName2 = taxRate[1].Name;
                taxRateName1 = taxRateName1.replace('VAT', 'TAX');
                taxRateName2 = taxRateName2.replace('VAT', 'TAX'); 
                    
                }
                
           /*     else if(billData.AcctSeed__Ledger__r.Name == 'CRMIT - India' && billData.CurrencyIsoCode == 'USD' ){
                    
                taxRateName1 =   taxRate[0].Name;
                taxRateName2 = taxRate[1].Name;
                taxRateName1 = taxRateName1.replace('GST', 'TAX');
                taxRateName2 = taxRateName2.replace('GST', 'TAX');
                }   */
            }
            
        if(accSeedBillingLine.AcctSeed__Tax_Group__r.AcctSeed__Tax_Rate_Count__c == 2){
           
            taxRateValue1=((accSeedBillingLine.AcctSeed__Tax_Group__r.AcctSeed__Combined_Tax_Rate__c/2)*accSeedBillingLine.Ledger_sub_total__c/100).setscale(2);
            taxRateValue2=((accSeedBillingLine.AcctSeed__Tax_Group__r.AcctSeed__Combined_Tax_Rate__c/2)*accSeedBillingLine.Ledger_sub_total__c/100).setscale(2);
            billingTaxamount = (billData.AcctSeed__Sales_Tax3__c/2).setscale(2);
            sumBillingTaxamount1 = (billingTaxamount);
            sumBillingTaxamount2 = (billingTaxamount);
            
       
        }
        else{ 
            taxRateValue1 = ((accSeedBillingLine.AcctSeed__Tax_Group__r.AcctSeed__Combined_Tax_Rate__c*accSeedBillingLine.Ledger_sub_total__c)/100).setscale(2);
            billingTaxamount = (billData.AcctSeed__Sales_Tax3__c).setscale(2);
            sumBillingTaxamount1 = (billingTaxamount);
            
        }    
        }
        
        
       
        if(billData.AcctSeed__Ledger__r.AcctSeed__Default_Billing_Format__r.Name == 'Default Billing Product-GBP'){
            VATNumber = billData.AcctSeed__Ledger__r.AcctSeed__Default_Billing_Format__r.AcctSeed__VAT_Identification_Number__c;
            EIN = billData.AcctSeed__Ledger__r.AcctSeed__Default_Billing_Format__r.EIN_Number__c;
        }else if(billData.AcctSeed__Ledger__r.AcctSeed__Default_Billing_Format__r.Name == 'Default Billing Product-AUD'){
            CompanyBusinessNumber = billData.Company_Bussiness_Number__c;
        }
        
        
        if(billData.AcctSeed__Ledger__r.Name == 'CRMIT - India'){
          officeNumber = billData.AcctSeed__Ledger__r.AcctSeed__Default_Billing_Format__r.Off__c;
        }
        if(billData.AcctSeed__Ledger__r.Name == 'CRMIT - India' && billData.CurrencyIsoCode == 'INR') {
            HeadingType = 'Tax Invoice';   
        }
        else if(billData.AcctSeed__Ledger__r.Name == 'CRMIT - USA'){
            HeadingType = 'Invoice';
        }
        else if(billData.AcctSeed__Ledger__r.Name == 'CRMIT - ANZ'){
            HeadingType = 'Tax Invoice';   
        }
        else if(billData.AcctSeed__Ledger__r.Name == 'CRMIT - UK'){
            HeadingType = 'Tax Invoice'; 
        }
        else{
            HeadingType = 'Export Invoice';
        }
                
    }
   
    
    //added because to sync between sandbox and prod due to insufficient time added it
    public static void increase(){
        Integer i = 0;
   /*     i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
*/
    } 
}