public class fromJSON{
	public cls_invoice invoice;
	public class cls_invoice {
		public cls_transaction transactions;
        public cls_custom_fields custom_fields;
	}
	public class cls_transaction {
		public String Version;	//1.1
		public cls_TranDtls TranDtls;
		public cls_DocDtls DocDtls;
		public cls_SellerDtls SellerDtls;
		public cls_BuyerDtls BuyerDtls;
	//	public cls_DispDtls DispDtls;
		public cls_ShipDtls ShipDtls;
		public cls_ItemList[] ItemList;
		public cls_ValDtls ValDtls;
		public cls_PayDtls PayDtls;
		public cls_RefDtls RefDtls;
		//public cls_AddlDocDtls[] AddlDocDtls;
		public cls_ExpDtls ExpDtls;
		//public cls_EwbDtls EwbDtls; 
	}
	public class cls_TranDtls {
		public String TaxSch;	//GST
		public String SupTyp;	//B2B
		public String RegRev;	//Y
		//public cls_EcmGstin EcmGstin;
		//public String IgstOnIntra;	//N
	}
	/*public class cls_EcmGstin {
	}*/
	public class cls_DocDtls {
		public String Typ;	//INV
		public String No;	//DAOC/007
		public String Dt;	//24/03/2023
	}
	public class cls_SellerDtls {
		public String Gstin;	//29AAFCD5862R000
		public String LglNm;	//NIC company pvt ltd
		//public String TrdNm;	//NIC Industries
		public String Addr1;	//5th block, kuvempu layout
		public String Addr2;	//kuvempu layout
		public String Loc;	//GANDHINAGAR
		public Integer Pin;	//560037
		public String Stcd;	//29
		//public String Ph;	//9000000000
		//public String Em;	//abc@gmail.com
	}
	public class cls_BuyerDtls {
		public String Gstin;	//29AWGPV7107B1Z1
		public String LglNm;	//XYZ company pvt ltd
		//public String TrdNm;	//XYZ Industries
		public String Pos;	//12
		public String Addr1;	//7th block, kuvempu layout
		//public String Addr2;	//kuvempu layout
		public String Loc;	//GANDHINAGAR
		public Integer Pin;	//562160
		public String Stcd;	//29
		//public String Ph;	//91111111111
		//public String Em;	//xyz@yahoo.com
	}
	/*public class cls_DispDtls {
		public String Nm;	//ABC company pvt ltd
		public String Addr1;	//7th block, kuvempu layout
		//public String Addr2;	//kuvempu layout
		public String Loc;	//Banagalore
		public Integer Pin;	//562160
		public String Stcd;	//29
	}*/
	public class cls_ShipDtls {
	public String Gstin;	//29AWGPV7107B1Z1
		public String LglNm;	//CBE company pvt ltd
		//public String TrdNm;	//kuvempu layout
		public String Addr1;	//7th block, kuvempu layout
		//public String Addr2;	//kuvempu layout
		public String Loc;	//Banagalore
		public Integer Pin;	//562160
		public String Stcd;	//29
	}
	public class cls_ItemList {
		public String SlNo;	//1
		public String PrdDesc;	//Rice
		public String IsServc;	//N
		public String HsnCd;	//10019920
		//public String Barcde;	//123456
		public Double Qty;	//100.345
		/*public Integer FreeQty;	//10
		public String Unit;	//BAG*/
		public Double UnitPrice;	//99.545
		public Double TotAmt;	//9988.84
	//	public Integer Discount;	//10
		//public Integer PreTaxVal;	//1
		public Double AssAmt;	//9978.84
		public Integer GstRt;	//12
		public Double IgstAmt;	//1197.46
		public Double CgstAmt;	//0
		public Double SgstAmt;	//0
		/*public Integer CesRt;	//5
		public Double CesAmt;	//498.94
		public Integer CesNonAdvlAmt;	//10
		public Integer StateCesRt;	//12
		public Double StateCesAmt;	//1197.46
		public Integer StateCesNonAdvlAmt;	//5
		public Integer OthChrg;	//10*/
		public Double TotItemVal;	//12897.7
		/*public String OrdLineRef;	//3256
		public String OrgCntry;	//AG
		public String PrdSlNo;	//12345*/
		public cls_BchDtls BchDtls;
		//public cls_AttribDtls[] AttribDtls;
	}
	public class cls_BchDtls {
		public String Nm;	//123456
	//	public String ExpDt;	//24/03/2024
	//	public String WrDt;	//24/03/2023
	}
	/*public class cls_AttribDtls {
		public String Nm;	//Rice
		public String Val;	//10000
	}*/
	public class cls_ValDtls {
		public Double AssVal;	//9978.84
		public Double CgstVal;	//0
		public Double SgstVal;	//0
		public Double IgstVal;	//1197.46
		/*public Double CesVal;	//508.94
		public Double StCesVal;	//1202.46
		public Integer Discount;	//10
		public Integer OthChrg;	//20
		public Double RndOffAmt;	//0.3*/
		public Double TotInvVal;	//12908
	//	public Double TotInvValFc;	//12897.7
	}
	public class cls_PayDtls {
		public String Nm;	//ABCDE
		public String AccDet;	//5697389713210
		//public String Mode;	//Cash
		public String FinInsBr;	//SBIN11000
		public String PayTerm;	//100
		//public String PayInstr;	//Gift
		//public String CrTrn;	//test
		//public String DirDr;	//test
		//public Integer CrDay;	//100
		//public Integer PaidAmt;	//10000
		//public Integer PaymtDue;	//5000
	}
	public class cls_RefDtls {
		public String InvRm;	//TESTCRMIT
		public cls_DocPerdDtls DocPerdDtls;
		//public cls_PrecDocDtls[] PrecDocDtls;
		public cls_ContrDtls[] ContrDtls;
	}
	public class cls_DocPerdDtls {
		public String InvStDt;	//24/03/2023
		public String InvEndDt;	//24/03/2024
	}
	/*public class cls_PrecDocDtls {
		public String InvNo;	//DOC/003
		public String InvDt;	//24/03/2023
		//public String OthRefNo;	//123456
	}*/
	public class cls_ContrDtls {
		//public String RecAdvRefr;	//Doc/003
		//public String RecAdvDt;	//24/03/2023
		//public String TendRefr;	//Abc001
		//public String ContrRefr;	//Co123
		//public String ExtRefr;	//Yo456
		//public String ProjRefr;	//Doc-456
		public String PORefr;	//Doc-789
		public String PORefDt;	//24/03/2023
	}
	/*public class cls_AddlDocDtls {
		public String Url;	//https://einv-apisandbox.nic.in
		public String Docs;	//Test Doc
		public String Info;	//Document Test
	}*/
	public class cls_ExpDtls {
		//public String ShipBNo;	//A-248
		//public String ShipBDt;	//01/08/2020
		//public String Port;	//INABG1
		//public String RefClm;	//N
		//public String ForCur;	//AED
		public String CntCode;	//AE mandatory
	}
	/*public class cls_EwbDtls {
		//public String TransId;	//12AWGPV7107B1Z1
		//public String TransName;	//XYZ EXPORTS
		public Integer Distance;	//100
		//public String TransDocNo;	//DOC01
		//public String TransDocDt;	//24/03/2023
		//public String VehNo;	//ka123456
		//public String VehType;	//R
		//public String TransMode;	//1
	}*/
	 public class cls_custom_fields {
      public String BankName;
      public String BranchCode;
      public String SwiftCode;
      public String AuthorizedDealerCode;
     
    }
	public static fromJSON parse(String json){
		return (fromJSON) System.JSON.deserialize(json, fromJSON.class);
	}
}