public class generateeInvoice {
    
    @Future (callout=true)
    public static void eInvoice(List<Id> BillListId){
       	system.debug('BillListId>'+BillListId);
        List<Bank_Accounts__c> bankaccounts= Bank_Accounts__c.getAll().values();
        system.debug('bankaccounts>>>'+bankaccounts);
        List<AcctSeed__Billing__c> billing=new  List<AcctSeed__Billing__c>();
        billing = [Select Id,Name,Irn__c,AcctSeed__Billing_Comment__c,AcctSeed__PO_Number__c,GST_Subtype__c,Reverse_Charge__c,AcctSeed__Ledger__r.GSTIN__c,HSN_Code__c,AcctSeed__Proprietary_Billing_Number__c,Company_Bussiness_Number__c,AcctSeed__Ledger__r.AcctSeed__Default_Billing_Format__r.AcctSeed__VAT_Identification_Number__c,AcctSeed__Customer__r.GSTIN__c,
                    AcctSeed__Ledger__r.AcctSeed__Default_Billing_Format__r.Name,Billing_Customer__r.Product__r.AcctSeed__Tax_Group__r.Name,AcctSeed__Currency_Conversion_Rate__c,
                    AcctSeed__Ledger__r.AcctSeed__Default_Billing_Format__r.EIN_Number__c,AcctSeed__Type__c,AcctSeed__Date__c,AcctSeed__Billing_Format__c,CurrencyIsoCode,
                   AcctSeed__Billing_Format__r.AcctSeed__Company_Name__c,AcctSeed__Billing_Format__r.AcctSeed__Company_Street2__c,AcctSeed__Billing_Format__r.AcctSeed__Company_City__c,
                    AcctSeed__Billing_Format__r.AcctSeed__Company_State__c,AcctSeed__Billing_Format__r.AcctSeed__Company_PostalCode__c,AcctSeed__Sub_Total__c,AcctSeed__Total__c,
                   AcctSeed__Customer__c,AcctSeed__Customer__r.AcctSeed__Billing_Days_Due__c,AcctSeed__Customer__r.Country_code__c,AcctSeed__Customer__r.Name,AcctSeed__Customer__r.Statecode_del1_del__c,AcctSeed__Customer__r.BillingStreet,AcctSeed__Customer__r.BillingCity,AcctSeed__Customer__r.BillingPostalCode,AcctSeed__Due_Date2__c,AcctSeed__Customer__r.ShippingStreet,AcctSeed__Customer__r.ShippingCity,AcctSeed__Customer__r.ShippingPostalCode,(Select id,AcctSeed__Rate__c,AcctSeed__Sub_Total__c,AcctSeed__Tax_Rate__c,AcctSeed__Total__c,AcctSeed__Tax_Group__c,AcctSeed__Tax_Group__r.AcctSeed__Tax_Rate_Count__c,Ledger_sub_total__c,Content_discription__c,AcctSeed__Hours_Units__c from AcctSeed__Project_Billing_Lines__r) from AcctSeed__Billing__c where id=:BillListId];
        
      List<fromJSON> fromJsonList=new List<fromJSON>();
        
        try{
            
        for(AcctSeed__Billing__c bill:billing){
            fromJSON fromJson=new fromJSON();
        fromJSON.cls_invoice inv = new fromJSON.cls_invoice();
       
        
        
        //inv.custom_fields=custom_fields;
        
        /*for(integer i=0;i<=1;i++){*/
            fromJSON.cls_TranDtls trandtls= new fromJSON.cls_TranDtls();
       // fromJSON.cls_EcmGstin EcmGstin=new fromJSON.cls_EcmGstin();
        fromJSON.cls_transaction transactions=new fromJSON.cls_transaction();
         trandtls.TaxSch='GST';
         trandtls.SupTyp=bill.GST_Subtype__c;// billing new field- GST Subtype
         trandtls.RegRev=bill.Reverse_Charge__c;// billing new field - Reverse Charge - (picklist - y,n)
        //trandtls.EcmGstin=EcmGstin;
        //trandtls.IgstOnIntra='N';
        
		
        
        fromJSON.cls_DocDtls docdtls= new fromJSON.cls_DocDtls();
           
            if(bill.AcctSeed__Type__c == 'Invoice'){
        docdtls.Typ= 'INV';//billing.AcctSeed__Type__c;
                }
          else if(bill.AcctSeed__Type__c == 'Credit Memo'){
                docdtls.Typ= 'CRN';
            }
                
        docdtls.No=bill.AcctSeed__Proprietary_Billing_Number__c;//billing.Name;
        docdtls.Dt=String.valueOf(bill.AcctSeed__Date__c);//
        
        fromJSON.cls_SellerDtls SellerDtls=new fromJSON.cls_SellerDtls();
            
        SellerDtls.Gstin=bill.AcctSeed__Ledger__r.GSTIN__c;
        // ledger field - GSTIN
        SellerDtls.LglNm=bill.AcctSeed__Billing_Format__r.AcctSeed__Company_Name__c;
       // SellerDtls.TrdNm='NIC Industries';
        SellerDtls.Addr1=bill.AcctSeed__Billing_Format__r.AcctSeed__Company_Street2__c;
        //SellerDtls.Addr2=bill.AcctSeed__Billing_Format__r.AcctSeed__Company_Street2__c;
        SellerDtls.Loc=bill.AcctSeed__Billing_Format__r.AcctSeed__Company_City__c +','+ bill.AcctSeed__Billing_Format__r.AcctSeed__Company_State__c;
        SellerDtls.Pin=Integer.valueOf(bill.AcctSeed__Billing_Format__r.AcctSeed__Company_PostalCode__c);
        SellerDtls.Stcd='29';//
       // SellerDtls.Ph='9000000000';
		//SellerDtls.EM='abc@gmail.com';
        
        fromJSON.cls_BuyerDtls BuyerDtls=new fromJSON.cls_BuyerDtls();
        BuyerDtls.Gstin=bill.AcctSeed__Customer__r.GSTIN__c;	//29AWGPV7107B1Z1
		BuyerDtls.LglNm=bill.AcctSeed__Customer__r.Name;	//XYZ company pvt ltd
		//BuyerDtls.TrdNm='XYZ Industries';	//XYZ Industries
		BuyerDtls.Pos=bill.AcctSeed__Customer__r.Statecode_del1_del__c;	//12
		BuyerDtls.Addr1=bill.AcctSeed__Customer__r.BillingStreet;//String.valueOf(billing.AcctSeed__Customer__r.BillingAddress);	//7th block, kuvempu layout
	//	BuyerDtls.Addr2='kuvempu layout';	//kuvempu layout
		BuyerDtls.Loc=bill.AcctSeed__Customer__r.BillingCity;	//billing.AcctSeed__Customer__r.Billing_State__c
		BuyerDtls.Pin=Integer.valueOf(bill.AcctSeed__Customer__r.BillingPostalCode);	//562160 Integer.valueOf(billing.AcctSeed__Customer__r.BillingPostalCode)
		BuyerDtls.Stcd=bill.AcctSeed__Customer__r.Statecode_del1_del__c;	//29
		//BuyerDtls.Ph='91111111111';	//91111111111
		//BuyerDtls.Em='xyz@yahoo.com';
        
       /* fromJSON.cls_DispDtls DispDtls=new fromJSON.cls_DispDtls();
        DispDtls.Nm='ABC company pvt ltd';	//ABC company pvt ltd
		DispDtls.Addr1='7th block, kuvempu layout';	//7th block, kuvempu layout
		//DispDtls.Addr2='kuvempu layout';	//kuvempu layout
		DispDtls.Loc='Banagalore';	//Banagalore
		DispDtls.Pin=562160;	//562160
		DispDtls.Stcd='29';	//29*/
        fromJSON.cls_ShipDtls ShipDtls=new fromJSON.cls_ShipDtls();
        ShipDtls.Gstin=bill.AcctSeed__Customer__r.GSTIN__c;	//29AWGPV7107B1Z1
		ShipDtls.LglNm=bill.AcctSeed__Customer__r.Name;	//CBE company pvt ltd
	//	ShipDtls.TrdNm='kuvempu layout';	//kuvempu layout
		ShipDtls.Addr1=bill.AcctSeed__Customer__r.ShippingStreet;	//7th block, kuvempu layout
		//ShipDtls.Addr2='kuvempu layout';	//kuvempu layout
		ShipDtls.Loc=bill.AcctSeed__Customer__r.ShippingCity;	//Banagalore
		ShipDtls.Pin=Integer.valueOf(bill.AcctSeed__Customer__r.ShippingPostalCode);	//562160
		ShipDtls.Stcd=bill.AcctSeed__Customer__r.Statecode_del1_del__c;	//29



                fromJSON.cls_BchDtls BchDtls=new fromJSON.cls_BchDtls();
		BchDtls.Nm='123456';	//123456 - Oprional Need to be tested with Commented
		//BchDtls.ExpDt='24/03/2024';	//24/03/2024
		//BchDtls.WrDt='24/03/2023';	//24/03/2023

        /*List<fromJSON.cls_AttribDtls> AttribDtlsList=new List<fromJSON.cls_AttribDtls>();
		fromJSON.cls_AttribDtls AttribDtls=new fromJSON.cls_AttribDtls();
        AttribDtls.Nm='Rice';	//Rice
		AttribDtls.Val='10000';	//10000
        AttribDtlsList.add(AttribDtls);*/
           
        List<fromJSON.cls_ItemList> ListItemList=new List<fromJSON.cls_ItemList>();//billing lines 
            Decimal totalcgst=0;
            Decimal totalsgst=0;
            Decimal totaligst=0;
            Integer Count=0;
            for(AcctSeed__Billing_Line__c billingLine:bill.AcctSeed__Project_Billing_Lines__r){
                fromJSON.cls_ItemList ItemList=new fromJSON.cls_ItemList();
       		Count++;
          ItemList.SlNo=String.valueOf(Count);	//1
		ItemList.PrdDesc=billingLine.Content_discription__c;	//Rice
		ItemList.IsServc='Y';	//N
		ItemList.HsnCd=bill.HSN_Code__c;	//10019920 Billing new field Name - HSN code (Picklist - 2 values)
		//ItemList.Barcde='123456';	//123456
		ItemList.Qty=billingLine.AcctSeed__Hours_Units__c;	//100.345
		//ItemList.FreeQty=10;	//10
		//ItemList.Unit='BAG';	//BAG billing name
		ItemList.UnitPrice=billingLine.AcctSeed__Rate__c;	//99.545
		ItemList.TotAmt=billingLine.Ledger_sub_total__c;	//9988.84
		//ItemList.Discount=10;	//10
		//ItemList.PreTaxVal=1;	//1
		ItemList.AssAmt=billingLine.Ledger_sub_total__c;	//9978.84 - sub total
		ItemList.GstRt=Integer.valueOf(billingLine.AcctSeed__Tax_Rate__c);	//12 - tax rate
                if(billingLine.AcctSeed__Tax_Group__r.AcctSeed__Tax_Rate_Count__c == 2){
        ItemList.IgstAmt=0;	//1197.46
                    Decimal cgstA=((billingLine.AcctSeed__Tax_Rate__c/2)*billingLine.Ledger_sub_total__c/100).setscale(2);
                     Decimal sgstA=((billingLine.AcctSeed__Tax_Rate__c/2)*billingLine.Ledger_sub_total__c/100).setscale(2);
		ItemList.CgstAmt=cgstA;	//0
		ItemList.SgstAmt=sgstA;	//0
                    totalcgst +=ItemList.CgstAmt;
                    totalsgst +=ItemList.SgstAmt;
                    totaligst +=ItemList.IgstAmt;
                    
                }
                else{
                   // decimal igstA=((billingLine.AcctSeed__Tax_Rate__c*billingLine.Ledger_sub_total__c)/100).setscale(3);
		ItemList.IgstAmt=((billingLine.AcctSeed__Tax_Rate__c*billingLine.Ledger_sub_total__c)/100).setscale(2);	//1197.46
		ItemList.CgstAmt=0;	//0
		ItemList.SgstAmt=0;	//0 
                    totalcgst +=ItemList.CgstAmt;
                    totalsgst +=ItemList.SgstAmt;
                    totaligst +=ItemList.IgstAmt;
                }
		//ItemList.CesRt=5;	//5
		//ItemList.CesAmt=498.94;	//498.94
		/*ItemList.CesNonAdvlAmt=10;	//10
		ItemList.StateCesRt=12;	//12
		ItemList.StateCesAmt=1197.46;	//1197.46
		ItemList.StateCesNonAdvlAmt=5;	//5
		ItemList.OthChrg=10;	//10*/
         decimal TotItemV=(billingLine.AcctSeed__Total__c/bill.AcctSeed__Currency_Conversion_Rate__c).setscale(2);
		ItemList.TotItemVal=(TotItemV);	//12897.7 - total
		//ItemList.OrdLineRef='3256';	//3256
		//ItemList.OrgCntry='AG';	//AG
		//ItemList.PrdSlNo='12345';	//12345
		ItemList.BchDtls=BchDtls;
		//ItemList.AttribDtls=AttribDtlsList;
        ListItemList.add(ItemList);
            }
       
        fromJSON.cls_ValDtls ValDtls=new fromJSON.cls_ValDtls();
            decimal assV=(bill.AcctSeed__Sub_Total__c / bill.AcctSeed__Currency_Conversion_Rate__c).setscale(2);
        ValDtls.AssVal=(assV);	//9978.84 - billing sub total
            ValDtls.CgstVal=totalcgst;	//0
		ValDtls.SgstVal=totalsgst;	//0
		ValDtls.IgstVal=totaligst;	//1197.46
		/*ValDtls.CesVal=508.94;	//508.94
		ValDtls.StCesVal=1202.46;	//1202.46
		ValDtls.Discount=10;	//10
		ValDtls.OthChrg=20;	//20
		ValDtls.RndOffAmt=0.3;	//0.3*/
        decimal totV=(bill.AcctSeed__Total__c/bill.AcctSeed__Currency_Conversion_Rate__c).setscale(2);
		ValDtls.TotInvVal=totV;	//12908 - billing total
		//ValDtls.TotInvValFc=12897.7;	//12897.7
        
        fromJSON.cls_PayDtls PayDtls=new fromJSON.cls_PayDtls();
            if(bill.CurrencyIsoCode == 'USD'){
        Bank_Accounts__c bankact = Bank_Accounts__c.getValues('USD');
 		system.debug('bankact>>>'+bankact);
        PayDtls.Nm=bankact.Benificiary_Name__c;	//ABCDE
		PayDtls.AccDet=bankact.ACC_No__c;	//5697389713210
		//PayDtls.Mode='Cash';	//Cash
		PayDtls.FinInsBr=bankact.IFSC_Code__c;	//SBIN11000
		PayDtls.PayTerm=String.valueOf(bill.AcctSeed__Customer__r.AcctSeed__Billing_Days_Due__c)+' Days';	//100
		//PayDtls.PayInstr='Gift';	//Gift
		//PayDtls.CrTrn='test';	//test
		//PayDtls.DirDr='test';	//test
		//PayDtls.CrDay=100;	//100
		//PayDtls.PaidAmt=10000;	//10000
		//PayDtls.PaymtDue=5000;	//5000
		}
        if(bill.CurrencyIsoCode == 'AUD'){
        Bank_Accounts__c bankact = Bank_Accounts__c.getValues('AUD');
 		system.debug('bankact>>>'+bankact);
        PayDtls.Nm=bankact.Benificiary_Name__c;	//ABCDE
		PayDtls.AccDet=bankact.ACC_No__c;	//5697389713210
		//PayDtls.Mode='Cash';	//Cash
		PayDtls.FinInsBr=bankact.IFSC_Code__c;	//SBIN11000
		PayDtls.PayTerm=String.valueOf(bill.AcctSeed__Customer__r.AcctSeed__Billing_Days_Due__c);	//100
		//PayDtls.PayInstr='Gift';	//Gift
		//PayDtls.CrTrn='test';	//test
		//PayDtls.DirDr='test';	//test
		//PayDtls.CrDay=100;	//100
		//PayDtls.PaidAmt=10000;	//10000
		//PayDtls.PaymtDue=5000;	//5000
		}
        if(bill.CurrencyIsoCode == 'GBP'){
        Bank_Accounts__c bankact = Bank_Accounts__c.getValues('GBP');
 		system.debug('bankact>>>'+bankact);
        PayDtls.Nm=bankact.Benificiary_Name__c;	//ABCDE
		PayDtls.AccDet=bankact.ACC_No__c;	//5697389713210
		//PayDtls.Mode='Cash';	//Cash
		PayDtls.FinInsBr=bankact.IFSC_Code__c;	//SBIN11000
		PayDtls.PayTerm=String.valueOf(bill.AcctSeed__Customer__r.AcctSeed__Billing_Days_Due__c);//100
		//PayDtls.PayInstr='Gift';	//Gift
		//PayDtls.CrTrn='test';	//test
		//PayDtls.DirDr='test';	//test
		//PayDtls.CrDay=100;	//100
		//PayDtls.PaidAmt=10000;	//10000
		//PayDtls.PaymtDue=5000;	//5000
		}
             if(bill.CurrencyIsoCode == 'EUR'){
         Bank_Accounts__c bankact = Bank_Accounts__c.getValues('EUR');
 		system.debug('bankact>>>'+bankact);
        PayDtls.Nm=bankact.Benificiary_Name__c;	//ABCDE
		PayDtls.AccDet=bankact.ACC_No__c;	//5697389713210
		//PayDtls.Mode='Cash';	//Cash
		PayDtls.FinInsBr=bankact.IFSC_Code__c;	//SBIN11000
		PayDtls.PayTerm=String.valueOf(bill.AcctSeed__Customer__r.AcctSeed__Billing_Days_Due__c);
		//PayDtls.PayInstr='Gift';	//Gift
		//PayDtls.CrTrn='test';	//test
		//PayDtls.DirDr='test';	//test
		//PayDtls.CrDay=100;	//100
		//PayDtls.PaidAmt=10000;	//10000
		//PayDtls.PaymtDue=5000;	//5000
		}
         if(bill.CurrencyIsoCode == 'INR'){
         Bank_Accounts__c bankact = Bank_Accounts__c.getValues('INR');
 		system.debug('bankact>>>'+bankact);
        PayDtls.Nm=bankact.Benificiary_Name__c;	//ABCDE
		PayDtls.AccDet=bankact.ACC_No__c;	//5697389713210
		//PayDtls.Mode='Cash';	//Cash
		PayDtls.FinInsBr=bankact.IFSC_Code__c;	//SBIN11000
		PayDtls.PayTerm=String.valueOf(bill.AcctSeed__Customer__r.AcctSeed__Billing_Days_Due__c);	//100
		//PayDtls.PayInstr='Gift';	//Gift
		//PayDtls.CrTrn='test';	//test
		//PayDtls.DirDr='test';	//test
		//PayDtls.CrDay=100;	//100
		//PayDtls.PaidAmt=10000;	//10000
		//PayDtls.PaymtDue=5000;	//5000
		}

		fromJSON.cls_DocPerdDtls DocPerdDtls=new fromJSON.cls_DocPerdDtls();
        DocPerdDtls.InvStDt=String.valueOf(bill.AcctSeed__Date__c);	//24/03/2023 - billing date
		DocPerdDtls.InvEndDt=String.valueOf(bill.AcctSeed__Due_Date2__c);	//24/03/2024 - billing due date
        
        /*List<fromJSON.cls_PrecDocDtls> PrecDocDtlsList=new List<fromJSON.cls_PrecDocDtls>();
        fromJSON.cls_PrecDocDtls PrecDocDtls=new fromJSON.cls_PrecDocDtls();
        PrecDocDtls.InvNo='DOC/003';	//DOC/003
		PrecDocDtls.InvDt='24/03/2023';	//24/03/2023
		//PrecDocDtls.OthRefNo='123456';	//123456
        PrecDocDtlsList.add(PrecDocDtls);*/
        
        List<fromJSON.cls_ContrDtls> ContrDtlsList=new List<fromJSON.cls_ContrDtls>();
        fromJSON.cls_ContrDtls ContrDtls=new fromJSON.cls_ContrDtls();
        
        //ContrDtls.RecAdvRefr='Doc/003';	//Doc/003
		//ContrDtls.RecAdvDt='24/03/2023';	//24/03/2023
		//ContrDtls.TendRefr='Abc001';	//Abc001
		//ContrDtls.ContrRefr='Co123';	//Co123
		//ContrDtls.ExtRefr='Yo456';	//Yo456
		//ContrDtls.ProjRefr='Doc-456';	//Doc-456
		ContrDtls.PORefr= bill.AcctSeed__PO_Number__c;	//Doc-789
		//ContrDtls.PORefDt='24/03/2023';	//24/03/2023
        ContrDtlsList.add(ContrDtls);
        
        fromJSON.cls_RefDtls RefDtls=new fromJSON.cls_RefDtls();
        RefDtls.InvRm=bill.AcctSeed__Billing_Comment__c;	//TESTCRMIT
		RefDtls.DocPerdDtls=DocPerdDtls;
		//RefDtls.PrecDocDtls=PrecDocDtlsList;
		RefDtls.ContrDtls=ContrDtlsList;
        
        /*List<fromJSON.cls_AddlDocDtls> ListAddlDocDtls=new  List<fromJSON.cls_AddlDocDtls>();
       fromJSON.cls_AddlDocDtls AddlDocDtls=new fromJSON.cls_AddlDocDtls();
        AddlDocDtls.Url='https://einv-apisandbox.nic.in';
        AddlDocDtls.Docs='Test Doc';
        AddlDocDtls.Info='Document Test';
        ListAddlDocDtls.add(AddlDocDtls);E*/
        
        fromJSON.cls_ExpDtls ExpDtls=new fromJSON.cls_ExpDtls();
       // ExpDtls.ShipBNo='A-248';	//A-248
		//ExpDtls.ShipBDt='01/08/2020';	//01/08/2020
		//ExpDtls.Port='INABG1';	//INABG1
		//ExpDtls.RefClm='N';	//N
		//ExpDtls.ForCur='AED';	//AED
		ExpDtls.CntCode=bill.AcctSeed__Customer__r.Country_code__c;	//A


 //fromJSON.cls_EwbDtls EwbDtls=new fromJSON.cls_EwbDtls();
     /*  EwbDtls.TransId='12AWGPV7107B1Z1';	//12AWGPV7107B1Z1
	   EwbDtls.TransName='XYZ EXPORTS';	//XYZ EXPORTS*/
	  // EwbDtls.Distance=100;	//100 - Comment and check the code
	  /* EwbDtls.TransDocNo='DOC01';	//DOC01
	   EwbDtls.TransDocDt='24/03/2023';	//24/03/2023
	   EwbDtls.VehNo='ka123456';	//ka123456
	   EwbDtls.VehType='R';	//R
	   EwbDtls.TransMode='1';
      /*  
       */
        fromJSON.cls_custom_fields custom_fields=new fromJSON.cls_custom_fields();
        if(bill.CurrencyIsoCode == 'AUD'){
         Bank_Accounts__c bankact = Bank_Accounts__c.getValues('AUD');
 		system.debug('bankact>>>'+bankact);
        custom_fields.BankName=bankact.Bank_Name__c;	//CustomFieldValue1
		custom_fields.BranchCode=bankact.Branch_Code__c;	//CustomFieldValue2
		custom_fields.SwiftCode=bankact.SWIFT_Code__c;	//CustomFieldValue3
            custom_fields.AuthorizedDealerCode=bankact.Authorized_Dealer_Code__c;}
            
            if(bill.CurrencyIsoCode == 'EUR'){
         Bank_Accounts__c bankact = Bank_Accounts__c.getValues('EUR');
 		system.debug('bankact>>>'+bankact);
        custom_fields.BankName=bankact.Bank_Name__c;	//CustomFieldValue1
		custom_fields.BranchCode=bankact.Branch_Code__c;	//CustomFieldValue2
		custom_fields.SwiftCode=bankact.SWIFT_Code__c;	//CustomFieldValue3
            custom_fields.AuthorizedDealerCode=bankact.Authorized_Dealer_Code__c;}
            
             if(bill.CurrencyIsoCode == 'GBP'){
         Bank_Accounts__c bankact = Bank_Accounts__c.getValues('GBP');
 		system.debug('bankact>>>'+bankact);
        custom_fields.BankName=bankact.Bank_Name__c;	//CustomFieldValue1
		custom_fields.BranchCode=bankact.Branch_Code__c;	//CustomFieldValue2
		custom_fields.SwiftCode=bankact.SWIFT_Code__c;	//CustomFieldValue3
            custom_fields.AuthorizedDealerCode=bankact.Authorized_Dealer_Code__c;}
            
            if(bill.CurrencyIsoCode == 'INR'){
         Bank_Accounts__c bankact = Bank_Accounts__c.getValues('INR');
 		system.debug('bankact>>>'+bankact);
        custom_fields.BankName=bankact.Bank_Name__c;	//CustomFieldValue1
		custom_fields.BranchCode=bankact.Branch_Code__c;	//CustomFieldValue2
		custom_fields.SwiftCode=bankact.SWIFT_Code__c;	//CustomFieldValue3
            custom_fields.AuthorizedDealerCode=bankact.Authorized_Dealer_Code__c;}
            
            if(bill.CurrencyIsoCode == 'USD'){
         Bank_Accounts__c bankact = Bank_Accounts__c.getValues('USD');
 		system.debug('bankact>>>'+bankact);
        custom_fields.BankName=bankact.Bank_Name__c;	//CustomFieldValue1
		custom_fields.BranchCode=bankact.Branch_Code__c;	//CustomFieldValue2
		custom_fields.SwiftCode=bankact.SWIFT_Code__c;	//CustomFieldValue3
            custom_fields.AuthorizedDealerCode=bankact.Authorized_Dealer_Code__c;}
        
        transactions.Version='1.1';	//1.1
		transactions.TranDtls=trandtls;
		transactions.DocDtls=docdtls;
		transactions.SellerDtls=SellerDtls;
		transactions.BuyerDtls=BuyerDtls;
		//transactions.DispDtls=DispDtls;
		transactions.ShipDtls=ShipDtls;
		transactions.ItemList=ListItemList;
		transactions.ValDtls=ValDtls;
		transactions.PayDtls=PayDtls;
		transactions.RefDtls=RefDtls;
		//transactions.AddlDocDtls=ListAddlDocDtls;
		transactions.ExpDtls=ExpDtls;
		//transactions.EwbDtls=EwbDtls;
		//transactions.customfields=custom_fields;
            inv.transactions=transactions;
            inv.custom_fields=custom_fields;
            fromJson = new fromJson();
            fromJson.invoice = inv;
            fromJsonList.add(fromJson);
        }
        
        //}
        //fromJson.invoice=inv;
            String prejsonRequestBody = JSON.serialize(fromJsonList);
            system.debug('prejsonRequestBody>>'+prejsonRequestBody);
        String pre1jsonRequestBody= prejsonRequestBody.replace('"invoice":{','');
        String pre2jsonRequestBody= pre1jsonRequestBody.replace('"transactions":', '"transaction":');
        String pre3jsonRequestBody= pre2jsonRequestBody.replace('}}}}', '}}}');
            String jsonRequestBody= pre3jsonRequestBody.replace('}}}]', '}}]');       
            system.debug('jsonRequestBody>>'+jsonRequestBody);
           ClearTaxIntegration__c cleartaxendurl = ClearTaxIntegration__c.getOrgDefaults();
        system.debug('cleartaxendurl>>>'+cleartaxendurl);
        
        HTTPRequest req = new HTTPRequest();
        req.setEndPoint(cleartaxendurl.Endpoint_URL__c+'/einv/v2/eInvoice/generate');
        req.setHeader('Accept-Encoding','gzip,deflate,br');
        req.setHeader('Content-Type','application/json');
        req.setHeader('Connection','Keep-Alive');
        req.setHeader('User-Agent','Apache-HttpClient/4.5.5 (Java/16.0.1)');
        req.setHeader('X-Cleartax-Auth-Token',cleartaxendurl.X_Cleartax_Auth_Token__c);
        req.setHeader('gstin',cleartaxendurl.gstin__c);
        req.setHeader('owner_id',cleartaxendurl.owner_id__c);
        req.setbody(jsonRequestBody);
        req.setMethod('PUT');
        system.debug('req>>>'+req);
        Http http = new Http();
        
        HTTPResponse res = http.send(req);
        
        System.debug('resbody>>'+res.getBody());
        system.debug('responseStatus>>'+res.getStatus());
        system.debug('responseCode>>'+res.getStatusCode());
        List<cls_responsewrap> responsewrap=new List<cls_responsewrap>();
        String IrnGeneratedafter = res.getBody().substringAfter('"document_status":"');
        String IrnGenerated = IrnGeneratedafter.substringBefore('","error_response"');
        
        If(IrnGenerated == 'IRN_GENERATED'){
         responsewrap = ( List<cls_responsewrap>)JSON.deserialize(res.getbody(),  List<cls_responsewrap>.class); 

        }
        system.debug('responsewrap>>'+responsewrap);
        Map<String,String> irntransacMap = new Map<String,String>();
        for(cls_responsewrap reswrap:responsewrap){
            if(reswrap.document_status == 'IRN_GENERATED'){
                String Irn= reswrap.govt_response.Irn;
                String transac=reswrap.transaction_id;
                String trns=transac.subStringAfter('_');
                String transactionId = trns.substringBefore('_');
                irntransacMap.put(transactionId,Irn);
            }
        }
        List<AcctSeed__Billing__c> BillList=new List<AcctSeed__Billing__c>();
            if(Test.isrunningTest()){
                for(AcctSeed__Billing__c bl:billing){
                    bl.Irn__c='79afb8c3554c5a389029b7fb9c26fb01f45b02c300c448f7ce59622b1350905b';
                    BillList.add(bl);
                }  
            }
            else{
            for(AcctSeed__Billing__c bl:billing){
            if(irntransacMap.containsKey(bl.AcctSeed__Proprietary_Billing_Number__c)){
                bl.Irn__c=irntransacMap.get(bl.AcctSeed__Proprietary_Billing_Number__c);
                BillList.add(bl);
            }
            
        }
            }
            
        system.debug('BillList>>'+BillList);
       
        generateeInvoicePDF.eInvoicepdf(BillList);
        
     CreateErrorLog.createLog(jsonRequestBody,res.getBody(),res.getStatusCode(),res.getStatus());
            }
        catch(Exception e){
            system.debug('ex:'+ e.getLineNumber());
            system.debug('ex:'+ e.getMessage());
           CreateErrorLog.createLog('Data Error',e.getMessage()+String.valueOf(e.getLineNumber()),e.getLineNumber(),'Data Issue');
        }
    }
    
    
    
    
   public class cls_responsewrap {
		public cls_custom_fields custom_fields;
		public boolean deleted;
		public String document_status;	//IRN_GENERATED
		public cls_error_response error_response;
		public cls_errors errors;
		public cls_govt_response govt_response;
		public cls_group_id group_id;
		public String gstin;	//29AAFCD5862R000
		public boolean is_deleted;
		public cls_owner_id owner_id;
		public cls_tag_identifier tag_identifier;
		public cls_transaction transactions;
		public String transaction_id;	//29AAFCD5862R000_INVtest-04_INV_2023
		public cls_transaction_metadata transaction_metadata;
	}
	public class cls_custom_fields {
	}
	public class cls_error_response {
	}
	public class cls_errors {
	}
	public class cls_govt_response {
		public String Success;	//Y
		public String AckNo;	//112310154840606
		public String AckDt;	//2023-04-21 08:39:00
		public String Irn;	//4ce4c2f9d782805b141e180540564675916c333fed92239d6268caf9701f7a51
		public String SignedInvoice;	//eyJhbGciOiJSUzI1NiIsImtpZCI6IjE1MTNCODIxRUU0NkM3NDlBNjNCODZFMzE4QkY3MTEwOTkyODdEMUYiLCJ0eXAiOiJKV1QiLCJ4NXQiOiJGUk80SWU1R3gwbW1PNGJqR0w5eEVKa29mUjgifQ.eyJkYXRhIjoie1wiQWNrTm9cIjoxMTIzMTAxNTQ4NDA2MDYsXCJBY2tEdFwiOlwiMjAyMy0wNC0yMSAwODozOTowMFwiLFwiSXJuXCI6XCI0Y2U0YzJmOWQ3ODI4MDViMTQxZTE4MDU0MDU2NDY3NTkxNmMzMzNmZWQ5MjIzOWQ2MjY4Y2FmOTcwMWY3YTUxXCIsXCJWZXJzaW9uXCI6XCIxLjFcIixcIlRyYW5EdGxzXCI6e1wiVGF4U2NoXCI6XCJHU1RcIixcIlN1cFR5cFwiOlwiQjJCXCIsXCJSZWdSZXZcIjpcIllcIn0sXCJEb2NEdGxzXCI6e1wiVHlwXCI6XCJJTlZcIixcIk5vXCI6XCJJTlZ0ZXN0LTA0XCIsXCJEdFwiOlwiMjEvMDQvMjAyM1wifSxcIlNlbGxlckR0bHNcIjp7XCJHc3RpblwiOlwiMjlBQUZDRDU4NjJSMDAwXCIsXCJMZ2xObVwiOlwiQ1JNSVQgU09MVVRJT05TXCIsXCJBZGRyMVwiOlwiSFNSIDZ0aCBzZWN0b3JcIixcIkxvY1wiOlwiS2FybmF0YWthXCIsXCJQaW5cIjo1NjAwNjgsXCJTdGNkXCI6XCIyOVwifSxcIkJ1eWVyRHRsc1wiOntcIkdzdGluXCI6XCIyN0FBQkNVOTYwM1IxWk5cIixcIkxnbE5tXCI6XCJUYXRhIFBvd2VyXCIsXCJQb3NcIjpcIjI3XCIsXCJBZGRyMVwiOlwiQVVSQU5HQUJBRCwgUGF0b2RhXCIsXCJMb2NcIjpcIlBhdG9kYVwiLFwiUGluXCI6NDE0MjA0LFwiU3RjZFwiOlwiMjdcIn0sXCJJdGVtTGlzdFwiOlt7XCJJdGVtTm9cIjowLFwiU2xOb1wiOlwiMVwiLFwiSXNTZXJ2Y1wiOlwiWVwiLFwiSHNuQ2RcIjpcIjk5ODMxM1wiLFwiVW5pdFByaWNlXCI6ODAwLjAsXCJUb3RBbXRcIjo4MDAuMDAsXCJBc3NBbXRcIjo4MDAuMDAsXCJHc3RSdFwiOjE4LjAwMCxcIklnc3RBbXRcIjoxNDQuMDAsXCJDZ3N0QW10XCI6MC4wMCxcIlNnc3RBbXRcIjowLjAwLFwiVG90SXRlbVZhbFwiOjk0NC4wMCxcIkJjaER0bHNcIjp7XCJObVwiOlwiMTIzNDU2XCJ9fV0sXCJWYWxEdGxzXCI6e1wiQXNzVmFsXCI6ODAwLjAwLFwiQ2dzdFZhbFwiOjAuMDAsXCJTZ3N0VmFsXCI6MC4wMCxcIklnc3RWYWxcIjoxNDQuMDAsXCJUb3RJbnZWYWxcIjo5NDQuMDB9LFwiUmVmRHRsc1wiOntcIkRvY1BlcmREdGxzXCI6e1wiSW52U3REdFwiOlwiMjEvMDQvMjAyM1wiLFwiSW52RW5kRHRcIjpcIjIxLzA0LzIwMjNcIn19fSIsImlzcyI6Ik5JQyBTYW5kYm94In0.jTWjtJYcJ9GunLy0rMMvafN2LqKWpEP4S8hAYudyRimGtsbHhH4dIrBaueb7uW3SDeBTJQZNIrB8Hnh7rIkhxuqghlz2sPngrOvlj-MJurleB167x-JRDactF9l3T5mdia7ss_QxslXjGpVf93ehF72vOR0jphSjpGYEOkekD3rveoGY82dOvVq4vt97k1mdSBzvB8I8E3AsuFE1cm3-XOv-gX3zlYyxm22gCPHN0krEcuWwtzZKi-Z_TFWOnkN9slvwBUhh25ndsiU2_BkJIGTBIH3OI1qZXZcDHhRukwQKY0xcrxaMnrXEoz9ZalxBfVhiwREKfouLyfApLeVuXw
		public String SignedQRCode;	//eyJhbGciOiJSUzI1NiIsImtpZCI6IjE1MTNCODIxRUU0NkM3NDlBNjNCODZFMzE4QkY3MTEwOTkyODdEMUYiLCJ0eXAiOiJKV1QiLCJ4NXQiOiJGUk80SWU1R3gwbW1PNGJqR0w5eEVKa29mUjgifQ.eyJkYXRhIjoie1wiU2VsbGVyR3N0aW5cIjpcIjI5QUFGQ0Q1ODYyUjAwMFwiLFwiQnV5ZXJHc3RpblwiOlwiMjdBQUJDVTk2MDNSMVpOXCIsXCJEb2NOb1wiOlwiSU5WdGVzdC0wNFwiLFwiRG9jVHlwXCI6XCJJTlZcIixcIkRvY0R0XCI6XCIyMS8wNC8yMDIzXCIsXCJUb3RJbnZWYWxcIjo5NDQuMDAsXCJJdGVtQ250XCI6MSxcIk1haW5Ic25Db2RlXCI6XCI5OTgzMTNcIixcIklyblwiOlwiNGNlNGMyZjlkNzgyODA1YjE0MWUxODA1NDA1NjQ2NzU5MTZjMzMzZmVkOTIyMzlkNjI2OGNhZjk3MDFmN2E1MVwiLFwiSXJuRHRcIjpcIjIwMjMtMDQtMjEgMDg6Mzk6MDBcIn0iLCJpc3MiOiJOSUMgU2FuZGJveCJ9.PTv2xIekvH53ziexCOrqM_Pk1t3tvWQbngkpT2VXKcgL7R7664P9d3NP1Mr1L32URzZ-rnxjwIcvn5jXenXjNlzjaldFO0Vgysxz2iqx8B-S4xYp50TTXDiBZGxAGZ4pFVxDYJKsDc93FgnzXpDAR3K7aDS_-CFNALU9Tao7o1Ku_7qgL0z9-vg3k1bBQ4s1P4oq25VwZaW3mS6pk8V6trEdzlGPKHSU3tJ0NhkwlmI07KRZg-kURzRF35oaExEbtedLFfZ_i36tUNw1yCTtDXJ7jtzX0EXRwz1capib2aiQabC4QEeMgmXYjtVBAbe8xaU_b4KJMYcGO8JSNmtaeg
		public String Status;	//ACT
		public cls_info[] info;
		public cls_ErrorDetails[] ErrorDetails;
	}
    
    public class cls_ErrorDetails {
		public String error_code;	//107
		public String error_message;	//EInvoice.ItemList[0].TotItemVal : Invalid total item value, must be equal to (Taxable Value of Item + SGST Value of Item + CGST Value of Item + IGST Value of Item + Cess Value of Item + State Cess Value of Item + Non-Advol Cess Value of Item + State Cess Non-advol value of Item + Other charges.). Please correct the total Item Value and try again
		public String error_source;	//CLEARTAX
	}
    
    public class cls_info {
		public String InfCd;	//EWBERR
		public cls_Desc[] Descs;
	}
    public class cls_Desc {
		public String ErrorCode;	//6002
		public String ErrorMessage;	//E-Way Bill can be generated provided at least HSN of one item belongs to goods.
		public String ErrorSource;	//CLEARTAX
	}
	public class cls_group_id {
	}
	public class cls_owner_id {
	}
	public class cls_tag_identifier {
	}
	public class cls_transaction {
		public String Version;	//1.1
		public cls_TranDtls TranDtls;
		public cls_DocDtls DocDtls;
		public cls_SellerDtls SellerDtls;
		public cls_BuyerDtls BuyerDtls;
		public cls_ItemList[] ItemList;
		public cls_ValDtls ValDtls;
		public cls_RefDtls RefDtls;
		//public cls_EwbDtls EwbDtls;
	}
	public class cls_TranDtls {
		public String TaxSch;	//GST
		public String RegRev;	//Y
		public String SupTyp;	//B2B
	}
	public class cls_DocDtls {
		public String Typ;	//INV
		public String No;	//INVtest-04
		public String Dt;	//21/04/2023
	}
	public class cls_SellerDtls {
		public String Gstin;	//29AAFCD5862R000
		public String LglNm;	//CRMIT SOLUTIONS
		public String Addr1;	//HSR 6th sector
		public String Loc;	//Karnataka
		public Integer Pin;	//560068
		public String Stcd;	//29
	}
	public class cls_BuyerDtls {
		public String Gstin;	//27AABCU9603R1ZN
		public String LglNm;	//Tata Power
		public String Pos;	//27
		public String Addr1;	//AURANGABAD, Patoda
		public String Loc;	//Patoda
		public Integer Pin;	//414204
		public String Stcd;	//27
	}
	public class cls_ItemList {
		public String SlNo;	//1
		public String IsServc;	//Y
		public String HsnCd;	//998313
		public Integer UnitPrice;	//800
		public Integer TotAmt;	//800
		public Integer AssAmt;	//800
		public Integer GstRt;	//18
		public Integer IgstAmt;	//144
		public Double CgstAmt;	//0
		public Double SgstAmt;	//0
		public Integer TotItemVal;	//944
		public cls_BchDtls BchDtls;
	}
	public class cls_BchDtls {
		public String Nm;	//123456
	}
	public class cls_ValDtls {
		public Double AssVal;	//800
		public Double CgstVal;	//0
		public Double SgstVal;	//0
		public Double IgstVal;	//144
		public Double TotInvVal;	//944
	}
	public class cls_RefDtls {
		public cls_DocPerdDtls DocPerdDtls;
	}
	public class cls_DocPerdDtls {
		public String InvStDt;	//21/04/2023
		public String InvEndDt;	//21/04/2023
	}
	/*public class cls_EwbDtls {
		public Integer Distance;	//100
	}*/
	public class cls_transaction_metadata {
	}
	

	
    
}