import { LightningElement, wire,track} from 'lwc';
// importing accounts
import getAccperiodList from '@salesforce/apex/LWCExampleController.getAccperiodList';
import getgstreturnList from '@salesforce/apex/LWCExampleController.getgstreturnList';
import getcsv from '@salesforce/apex/LWCExampleController.getcsv';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


// imported to show toast messages


// datatable columns
const columns = [
   
    {label: 'supplierName',fieldName: 'supplierName__c'}, 
    {label: 'documentType',fieldName: 'documentType__c'}, 
    {label: 'documentNumber',fieldName: 'documentNumber__c'}, 
    {label: 'documentDate',fieldName: 'documentDate__c'}, 
    {label: 'returnFilingMonth',fieldName: 'returnFilingMonth__c'}, 
    {label: 'placeOfSupply',fieldName: 'placeOfSupply__c'},
];

export default class ExportDataToCSVInLWC extends LightningElement {
    @track error;
    @track data;
    @track AccperList = [];
    @track NewList = [];
    @track columns = columns;
    @track searchString;
    @track initialRecords;
    selectedValue;
    @track options;
    @track gstreturnsAccperiod ;
    @track gstreturnsTransaction;
    @track fileName;
       //To Send the accounting period to the newly created obj gst returns file(to store the files)
    @track myallData;
    value='';
    typevalue='';

    get optionstype() {
        return [
            { label: 'Purchase', value: 'Purchase' },
            { label: 'Sales', value: 'Sales' },
        ];
    }

    @wire(getAccperiodList)
    wiredAccperList({ error, data }) {
        if (data) {
            console.log(data);
            //this.AccperList=data;

            this.myallData = data;
            let options = [];
            if (data) {
                data.forEach(r => {
                options.push({
                  label: r,
                  value: r,
                });
              });
            }
            this.options = options;           
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.options = undefined;
        }
    }
    

    handleChangeap(event){
        console.log('recap>>>>'+ event.detail.value);
        this.value=event.detail.value;
    }

    handleChangetype(event){
        console.log('rectype>>>>'+ event.detail.value);
        this.typevalue=event.detail.value;
    }

    handleChange(event){
        this.NewList =[];

        if(this.value == ''|| this.value == undefined){
//alert('please select the Accounting Period');
const evt = new ShowToastEvent({
    title: 'Accouting Period',
    message: 'please select the Accounting Period',
    variant: 'warning',
});
this.dispatchEvent(evt);
return;
        }
        if(this.typevalue == ''|| this.typevalue == undefined){
           // alert('please select the Transaction type');
           const evt = new ShowToastEvent({
            title: 'Transaction Type',
            message: 'please select the Transaction type',
            variant: 'warning',
        });
        this.dispatchEvent(evt);
            return;
                    }

        getgstreturnList({ selectedPeriod: this.value,selectedType : this.typevalue })
            .then(result => {
              //  console.log("result13" + JSON.stringify(result));
                if(result == [] || result == undefined || result == '' || result == null){
                   // alert('No records found');
                   const evt = new ShowToastEvent({
                    title: 'No Records',
                    message: 'No records found for the selected Accounting Period and Transaction type',
                    variant: 'warning',
                });
                this.dispatchEvent(evt);
                    return;
                                   }
                //console.log("result1" + JSON.stringify(result.data.records));
                this.AccperList = result;
               var i;
              // let familydata={};

              if(this.typevalue == 'Sales'){

                this.gstreturnsAccperiod = this.AccperList[0].returnFilingMonth__c;
                this.gstreturnsTransaction = 'Sales ';
                this.fileName = this.gstreturnsTransaction + this.gstreturnsAccperiod ; 
                for(i=0;i<this.AccperList.length;i++){
                    let familydata={};
                   
				
				if(this.AccperList[i].documentType__c == 'Invoice'){
                    familydata.documentType__c =this.AccperList[i].documentType__c == undefined ? '':this.AccperList[i].documentType__c;
                    familydata.documentDate__c =this.AccperList[i].documentDate__c == undefined ? '':this.AccperList[i].documentDate__c;
				familydata.documentNumber__c =this.AccperList[i].documentNumber__c == undefined ? '':this.AccperList[i].documentNumber__c;
                }
				else{
                familydata.documentType__c='Credit Note';
				familydata.documentDate__c =this.AccperList[i].documentDate__c == undefined ? '':this.AccperList[i].Invoice_date__c;
				familydata.documentNumber__c=this.AccperList[i].documentDate__c == undefined ? '':this.AccperList[i].documentNumber__c;

				
				}
				

				familydata.customerName__c =this.AccperList[i].customerName__c == undefined ? '':this.AccperList[i].customerName__c;
				
				familydata.customerGstin__c =this.AccperList[i].customerGstin__c == undefined ? '':this.AccperList[i].customerGstin__c;
				
				familydata.placeOfSupply__c =this.AccperList[i].placeOfSupply__c == undefined ? '':this.AccperList[i].placeOfSupply__c;
				
                if(this.AccperList[i].IsService__c == 'Y'){
				familydata.IsService__c =this.AccperList[i].IsService__c == undefined ? '':'S';}
                else if(this.AccperList[i].IsService__c == 'N'){
               familydata.IsService__c =this.AccperList[i].IsService__c == undefined ? '':'G';
                }
                else{
                    familydata.IsService__c ='';
                }
				
				familydata.hsnSacCode__c =this.AccperList[i].hsnSacCode__c == undefined ? '':this.AccperList[i].hsnSacCode__c;
				
				
				familydata.itemTaxableAmount__c =this.AccperList[i].itemTaxableAmount__c == undefined ? '': Math.abs(parseFloat(this.AccperList[i].itemTaxableAmount__c/this.AccperList[i].Currency_Conversion_Rate__c).toFixed(2));

                //familydata.gstRate__c =this.AccperList[i].gstRate__c == undefined ? '': Math.abs(this.AccperList[i].gstRate__c);
				familydata.gstRate__c=0;
				familydata.cgstRate__c =this.AccperList[i].cgstRate__c == undefined ? '': Math.abs(this.AccperList[i].cgstRate__c);

			familydata.cgstAmount__c =this.AccperList[i].cgstAmount__c == undefined ? '':  Math.abs(parseFloat(this.AccperList[i].cgstAmount__c).toFixed(2));
				
			familydata.sgstRate__c =this.AccperList[i].sgstRate__c == undefined ? '': Math.abs(this.AccperList[i].sgstRate__c);

            familydata.sgstAmount__c =this.AccperList[i].sgstAmount__c == undefined ? '':  Math.abs(parseFloat(this.AccperList[i].sgstAmount__c).toFixed(2));

				familydata.igstRate__c =this.AccperList[i].igstRate__c == undefined ? '': Math.abs(this.AccperList[i].igstRate__c);
				
				familydata.igstAmount__c =this.AccperList[i].igstAmount__c == undefined ? '': Math.abs(parseFloat(this.AccperList[i].igstAmount__c).toFixed(2));
				
				familydata.reasonforIssuingCDN ='';

                if(this.AccperList[i].isReverseCharge__c == 'Y'){
                    familydata.isReverseCharge__c =this.AccperList[i].isReverseCharge__c == undefined ? '':'Y';}
                    else{
                        familydata.isReverseCharge__c ='';
                    }
                if(this.AccperList[i].GST_Subtype__c == 'Dexp'){
                        familydata.GST_Subtype__c =this.AccperList[i].GST_Subtype__c == undefined ? '':'Deemed Export';}
                        else if(this.AccperList[i].GST_Subtype__c == 'SEZWP'){
                            familydata.GST_Subtype__c =this.AccperList[i].GST_Subtype__c == undefined ? '':'SEZ with payment of GST';}
                            else if(this.AccperList[i].GST_Subtype__c == 'SEZWOP'){
                                familydata.GST_Subtype__c =this.AccperList[i].GST_Subtype__c == undefined ? '':'SEZ without payment of GST';}
                                else if(this.AccperList[i].GST_Subtype__c == 'EXPWP'){
                                    familydata.GST_Subtype__c =this.AccperList[i].GST_Subtype__c == undefined ? '':'Export with payment of GST';}
                                    else if(this.AccperList[i].GST_Subtype__c == 'EXPWOP'){
                                        familydata.GST_Subtype__c =this.AccperList[i].GST_Subtype__c == undefined ? '':'Export without payment of GST';}
                                        else if(this.AccperList[i].GST_Subtype__c == 'DEXP'){
                                            familydata.GST_Subtype__c =this.AccperList[i].GST_Subtype__c == undefined ? '':'';}
                        else{

                        
                            familydata.GST_Subtype__c ='';
                        }
				
				if(this.AccperList[i].isTdsDeducted__c == 'Y'){
				familydata.isTdsDeducted__c =this.AccperList[i].isTdsDeducted__c == undefined ? '':'Y';}
                else{
                    familydata.isTdsDeducted__c ='';
                }
				familydata.MyGSTIN__c = this.AccperList[i].MyGSTIN__c == undefined ? '':this.AccperList[i].MyGSTIN__c;
				if(this.AccperList[i].Is_this_document_Cancelled__c == 'Y'){
				familydata.Is_this_document_Cancelled__c =this.AccperList[i].Is_this_document_Cancelled__c == undefined ? '':'Y';}
                else{
                    familydata.Is_this_document_Cancelled__c ='';
                }
				familydata.C_Dealer_UIN__c =this.AccperList[i].C_Dealer_UIN__c == undefined ? '':this.AccperList[i].C_Dealer_UIN__c;

				
				familydata.returnFilingMonth__c = '';
				
				familydata.returnfilingQuarter = '';
				familydata.OriginalDocumentDate = '';
				familydata.OriginalDocumentNumber ='';
				familydata.OriginalCustomerBillingGSTIN ='';
                familydata.DateLinkedAdvanceReceipt='';
				familydata.VoucherNumberofLinkedAdvanceReceipt = '';
				familydata.AdjustmentAmountoftheLinkedAdvanceReceipt = '';
				
                familydata.Document_total_value__c =this.AccperList[i].Document_total_value__c == undefined ? '': Math.abs(parseFloat(this.AccperList[i].Document_total_value__c/this.AccperList[i].Currency_Conversion_Rate__c).toFixed(2));
				console.log('new ');
                familydata.LinkedInvoiceNumber=this.AccperList[i].documentNumber__c == undefined ? '':this.AccperList[i].Original_Invoice_Number__c;
				familydata.LinkedInvoiceDate=this.AccperList[i].documentNumber__c == undefined ? '':this.AccperList[i].Invoice_date__c;
				familydata.LinkedCustomerBillingGSTIN=this.AccperList[i].MyGSTIN__c == undefined ? '':this.AccperList[i].MyGSTIN__c;
                familydata.SupplierLegalName='CRMIT Solutions Private Limited';
				/*if(this.AccperList[i].documentType__c == 'Credit Memo'){
				
				familydata.CDNDate =this.AccperList[i].documentDate__c == undefined ? '':this.AccperList[i].documentDate__c;
				familydata.CDNNumber =this.AccperList[i].documentNumber__c == undefined ? '':this.AccperList[i].documentNumber__c;
				familydata.CDNtype ='C';
				familydata.cdnReason__c =this.AccperList[i].cdnReason__c == undefined ? '':this.AccperList[i].cdnReason__c;
				}
				else{
				familydata.CDNDate ='';
				familydata.CDNNumber ='';
				familydata.CDNtype ='';
				familydata.cdnReason__c='';

				}*/
				
				
                    
                    this.NewList.push(familydata);
                }

                

              }

              else {
                this.gstreturnsAccperiod = this.AccperList[0].returnFilingMonth__c;
                this.gstreturnsTransaction ='Purchase ';
                this.fileName=this.gstreturnsTransaction + this.gstreturnsAccperiod;
                                for(i=0;i<this.AccperList.length;i++){
                    let familydata={};
                   if(this.AccperList[i].documentType__c == 'Invoice'){familydata.documentDate__c =this.AccperList[i].documentDate__c == undefined ? '':this.AccperList[i].documentDate__c;
                    familydata.documentNumber__c =this.AccperList[i].documentNumber__c == undefined ? '':this.AccperList[i].documentNumber__c;}
                    
                    else{
                    familydata.documentDate__c =this.AccperList[i].supplierCity__c == undefined ? '':this.AccperList[i].Invoice_date__c;
                    familydata.documentNumber__c=this.AccperList[i].supplierCity__c == undefined ? '':this.AccperList[i].Original_Invoice_Number__c;
                    
                    }

					familydata.supplierName__c =this.AccperList[i].supplierName__c == undefined ? '':this.AccperList[i].supplierName__c;
					
					familydata.supplierGstin__c =this.AccperList[i].supplierGstin__c == undefined ? '':this.AccperList[i].supplierGstin__c;
					
					familydata.supplierState__c =this.AccperList[i].supplierState__c == undefined ? '':this.AccperList[i].supplierState__c;
					
					if(this.AccperList[i].IsService__c == 'Y'){
				familydata.IsService__c =this.AccperList[i].IsService__c == undefined ? '':'S';}
                else if(this.AccperList[i].IsService__c == 'N'){
               familydata.IsService__c =this.AccperList[i].IsService__c == undefined ? '':'G';
                }
                else{
                    familydata.IsService__c ='';
                }

					
					familydata.hsnSacCode__c =this.AccperList[i].hsnSacCode__c == undefined ? '':this.AccperList[i].hsnSacCode__c;
					
					familydata.itemQuantity__c =this.AccperList[i].itemQuantity__c == undefined ? '':this.AccperList[i].itemQuantity__c;
					
					familydata.itemUnitPrice__c = 0;
					
					familydata.itemTaxableAmount__c =this.AccperList[i].itemTaxableAmount__c == undefined ? '': Math.abs(parseFloat(this.AccperList[i].itemTaxableAmount__c/this.AccperList[i].Currency_Conversion_Rate__c).toFixed(2));
					
					familydata.cgstRate__c =this.AccperList[i].cgstRate__c == undefined ? '': Math.abs(this.AccperList[i].cgstRate__c);

					 familydata.cgstAmount__c =this.AccperList[i].cgstAmount__c == undefined ? '': Math.abs(parseFloat(this.AccperList[i].cgstAmount__c/this.AccperList[i].Currency_Conversion_Rate__c).toFixed(2));
                    
                    familydata.sgstRate__c =this.AccperList[i].sgstRate__c == undefined ? '': Math.abs(this.AccperList[i].sgstRate__c);
                    
                    familydata.sgstAmount__c =this.AccperList[i].sgstAmount__c == undefined ? '':  Math.abs(parseFloat(this.AccperList[i].sgstAmount__c/this.AccperList[i].Currency_Conversion_Rate__c).toFixed(2));
                    
                    familydata.igstRate__c =this.AccperList[i].igstRate__c == undefined ? '': Math.abs(this.AccperList[i].igstRate__c);
                    
                    familydata.igstAmount__c =this.AccperList[i].igstAmount__c == undefined ? '': Math.abs(this.AccperList[i].igstAmount__c);
					familydata.cessRate = '';
					familydata.cessAmount = '';
					familydata.ITC_Claim_Type__c = this.AccperList[i].ITC_Claim_Type__c == undefined ? '':this.AccperList[i].ITC_Claim_Type__c;
					familydata.cgstItcClaimAmount = '' ;
					familydata.sgstItcClaimAmount = '';
					familydata.igstItcClaimAmount = '';
					familydata.cessItcClaimAmount = '';
                    //console.log(this.AccperList[i]+'else AccperList ');

                    console.log(this.AccperList[i].documentType__c+'else ended cperList[i].documentType__c286 ');



                     if(this.AccperList[i].documentType__c == 'Credit Memo'){
                         familydata.Credit_Debit_Note_Date__c =this.AccperList[i].Credit_Debit_Note_Date__c == undefined ? '':this.AccperList[i].Credit_Debit_Note_Date__c;
                         familydata.Credit_Debit_Note_Number__c =this.AccperList[i].Credit_Debit_Note_Number__c == undefined ? '':this.AccperList[i].Credit_Debit_Note_Number__c;
                          familydata.NoteType  = 'C';

                         }
                                        else{
                                            familydata.Credit_Debit_Note_Date__c ='';
                          familydata.Credit_Debit_Note_Number__c='';

                          familydata.NoteType='';
                                        }
					familydata.Reason_for_issuing_CDN__c = this.AccperList[i].Reason_for_issuing_CDN__c ==undefined ? '':this.AccperList[i].Reason_for_issuing_CDN__c;
					
					familydata.Is_this_a_Bill_of_Supply__c =this.AccperList[i].Is_this_a_Bill_of_Supply__c == undefined ? '':this.AccperList[i].Is_this_a_Bill_of_Supply__c;
					
					familydata.GST_Type__c =this.AccperList[i].GST_Type__c == undefined ? '':this.AccperList[i].GST_Type__c;
					
					familydata.isReverseCharge__c =this.AccperList[i].isReverseCharge__c == undefined ? '':this.AccperList[i].isReverseCharge__c;
					familydata.Type_of_Import_Goods_Services_SEZ__c =this.AccperList[i].Type_of_Import_Goods_Services_SEZ__c == undefined ? '':this.AccperList[i].Type_of_Import_Goods_Services_SEZ__c;
					
					familydata.BillofEntryPortCode = '';
					familydata.BillofEntryNumber = '';
					familydata.BillofEntryDate = '';
					
					familydata.Is_this_document_Cancelled__c =this.AccperList[i].Is_this_document_Cancelled__c == undefined ? '':this.AccperList[i].Is_this_document_Cancelled__c;
					
					familydata.Is_the_supplier_a_Composition_dealer__c =this.AccperList[i].Is_the_supplier_a_Composition_dealer__c == undefined ? '':this.AccperList[i].Is_the_supplier_a_Composition_dealer__c;
					
					familydata.returnFilingMonth__c =this.AccperList[i].returnFilingMonth__c == undefined ? '':this.AccperList[i].returnFilingMonth__c;
                     //let  year = familydata.returnFilingMonth__c.substring(0, 4);
                     //let date = familydata.returnFilingMonth__c.substring(5,7);
                     familydata.returnFilingMonth__c = familydata.returnFilingMonth__c.substring(5,7)+'-'+ familydata.returnFilingMonth__c.substring(0, 4);

					
					familydata.ReturnFilingQuarter = '';
					
					familydata.customerGstin__c =this.AccperList[i].customerGstin__c == undefined ? '':this.AccperList[i].customerGstin__c;
					
					familydata.StatePlaceofSupply = '29';
					
					familydata.supplierAddress__c =this.AccperList[i].supplierAddress__c == undefined ? '':this.AccperList[i].supplierAddress__c;
					
					familydata.supplierCity__c =this.AccperList[i].supplierCity__c == undefined ? '':this.AccperList[i].supplierCity__c;
					
					familydata.OriginalInvoiceDate ='';
					familydata.OriginalInvoiceNumber = '';
					familydata.OriginalSupplierGSTIN = '';
					familydata.DateofLinkedAdvancePayment = '';
					familydata.VoucherNumberofLinkedAdvancePayment = '';
					familydata.AdjustmentAmountofLinkedAdvancePayment = '';
					familydata.paymentDueDate__c =this.AccperList[i].paymentDueDate__c == undefined ? '':this.AccperList[i].paymentDueDate__c;
					
					familydata.Document_total_value__c = Math.abs(this.AccperList[i].Document_total_value__c == undefined ? '': parseFloat(this.AccperList[i].Document_total_value__c/this.AccperList[i].Currency_Conversion_Rate__c).toFixed(2));
                   // familydata.Document_total_value__c= ("\""+ familydata.Document_total_value__c +"\""); to add the 0.00 in the csv formate 
                    this.NewList.push(familydata);
                    console.log("this.NewList inside else>>>>" + JSON.stringify(this.NewList));

                }

            }

                
                

                console.log("this.NewList>>>>" + JSON.stringify(this.NewList));
               // location.reload();
              

            })
            .catch(error => {
                //this.partcode = error;
            });

    }



    handleSearch(event) {
        const searchKey = event.target.value.toLowerCase();
 
        if (searchKey) {
            this.data = this.initialRecords;
 
            if (this.data) {
                let searchRecords = [];
 
                for (let record of this.data) {
                    let valuesArray = Object.values(record);
 
                    for (let val of valuesArray) {
                        console.log('val is ' + val);
                        let strVal = String(val);
 
                        if (strVal) {
 
                            if (strVal.toLowerCase().includes(searchKey)) {
                                searchRecords.push(record);
                                break;
                            }
                        }
                    }
                }
 
                console.log('Matched Accounts are ' + JSON.stringify(searchRecords));
                this.data = searchRecords;
            }
        } else {
            this.data = this.initialRecords;
        }
    }


    // this method validates the data and creates the csv file to download
    downloadCSVFile() {   


        let map1 = new Map([["documentType__c", "documentType"],["documentNumber__c", "documentNumber"],["documentDate__c", "documentDate"],["returnFilingMonth__c", "returnFilingMonth"],["placeOfSupply__c", "placeOfSupply"],["supplierName__c", "supplierName"],["itemQuantity__c", "itemQuantity"],["itemUnitPrice__c", "itemUnitPrice"],["itemTaxableAmount__c", "itemTaxableAmount"],["gstRate__c", "gstRate"],["cgstRate__c", "cgstRate"],["cgstAmount__c", "cgstAmount"],["sgstRate__c", "sgstRate"],["sgstAmount__c", "sgstAmount"],["igstRate__c", "igstRate"],["igstAmount__c", "igstAmount"],["paymentDueDate__c", "paymentDueDate"]]);


        
        let rowEnd = '\n';
        let csvString = '';
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();
        
        // getting keys from data
        this.NewList.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                rowData.add(key);
            });
        });

        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        console.log('rowData...set'+rowData);

        let columnHeader = [];

        if(this.typevalue == 'Sales'){
            columnHeader =  ['Document Type Code','documentDate','Document Number','Recipient Billing Name','Recipient Billing GSTIN','Place of Supply','Is the item a GOOD (G) or SERVICE (S)','HSN or SAC code','Item Taxable Value','GST Rate','CGST Rate','CGST Amount','SGST Rate','SGST Amount','IGST Rate','IGST Amount','Reason for issuing CDN','Is Reverse Charge Applicable?','Type of Export','Has GST/IDT TDS been deducted','My GSTIN','Is this document cancelled?','Is the customer a Composition dealer or UIN registered?','Return Filing Month','Return Filing Quarter','Original Document Date (In case of amendment)','Original Document Number (In case of amendment)','Original Customer Billing GSTIN (In case of amendment)','Date of Linked Advance Receipt','Voucher Number of Linked Advance Receipt','Adjustment Amount of the Linked Advance Receipt','Total Document Value','Linked Invoice Number (Filled In case of CDN)','Linked Invoice Date (Filled In case of CDN)','Linked Customer Billing GSTIN (Filled In case of CDN)','Supplier Legal Name'] }        
            else{
                columnHeader =  ['Invoice Date','Invoice Number','Supplier Name','Supplier GSTIN','Supplier State','Is the item a GOOD (G) or SERVICE (S)','HSN or SAC code','Item Quantity','Item Rate','Item Taxable Value','CGST Rate','CGST Amount','SGST Rate','SGST Amount','IGST Rate','IGST Amount','CESS Rate','CESS Amount','ITC Claim Type','CGST ITC Claim Amount','SGST ITC Claim Amount','IGST ITC Claim Amount','CESS ITC Claim Amount','Credit/Debit Note Date','Credit/Debit Note Number','Credit(C)/ Debit(D) Note Type','Reason for issuing CDN','Is this a Bill of Supply','GST Type','Is Reverse Charge Applicable?','Type of Import(Goods Services SEZ)','Bill of Entry Port Code','Bill of Entry Number','Bill of Entry Date','Is this document cancelled?','Is the supplier a Composition dealer?','Return Filing Month','Return Filing Quarter',' My GSTIN','State Place of Supply','Supplier Address','Supplier City','Original Invoice Date (In case of amendment)','Original Invoice Number (In case of amendment)','Original Supplier GSTIN (In case of amendment)','Date of Linked Advance Payment','Voucher Number of Linked Advance Payment','Adjustment Amount of Linked Advance Payment','Payment Due date','Total Transaction Value']        }        // splitting using ','    
        //csvString += rowData.join(',');
        //csvString += rowEnd;

        /*columnHeader.forEach(element => {            
            csvString += '"'+ element +'"';          
        });*/
        csvString += columnHeader.join(',');
        csvString += rowEnd;

        //alert('csvString::'+JSON.stringify(this.AccperList));
        // main for loop to get the data based on key value
        for(let i=0; i < this.NewList.length; i++){
            let colValue = 0;

            // validating keys in data
            for(let key in rowData) {

                let rowKey = rowData[key];

               // alert('value...set:::'+this.AccperList[i][rowKey]);

                if(rowData.hasOwnProperty(key)) {
                    // Key value 
                    // Ex: Id, Name
                    
                    
                    //alert('rowKey::'+rowKey);
                    // add , after every value except the first.
                    if(colValue > 0){
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    //alert('rowKey2::'+this.AccperList[i][rowKey]);
                    //alert('value...set:::'+this.AccperList[i][rowKey]);
                    let value = this.NewList[i][rowKey] === undefined ? '' : this.NewList[i][rowKey];
                    //alert('value...set:::'+value);
                    csvString += '"'+ value +'"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }
        console.log('csvString...set'+csvString);
        // Creating anchor element to download
        let downloadElement = document.createElement('a');

        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csvString);
        downloadElement.target = '_self';
        // CSV File Name
        downloadElement.download = 'GST Returns '+this.fileName+'.csv';
        // below statement is required if you are using firefox browser
        document.body.appendChild(downloadElement);
        // click() Javascript function to download CSV file
        downloadElement.click(); 
        console.log('csvStringdownloadElement...set'+downloadElement);

        //csvString
    getcsv({ getcsvString: csvString,Transactiontype: this.gstreturnsTransaction , AccountingPeriod : this.gstreturnsAccperiod})
        .then(result => {
            console.log("result" + JSON.stringify(result));
        })
        .catch(error => {
            console.log('error'+JSON.stringify(error));
            
            })
     
                                   


//          if(this.csvString){
//         createGSTReturnsFile({ fileName: this.fileContent.name, fileContent: this.csvString })
//         .then(result => {
//             this.showToast('Success', 'File uploaded successfully.', 'success');
//         })
//         .catch(error => {
//             this.showToast('Error', 'Error uploading file: ' + error.body.message, 'error');
//         });
//     }
//  else {
//     this.showToast('Error', 'No file selected.', 'error');
// }

     }
}