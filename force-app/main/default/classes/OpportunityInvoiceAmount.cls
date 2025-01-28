public class OpportunityInvoiceAmount {
    private static Boolean abc = false;
    @AuraEnabled
    public static void getOpportunityBillingAmountOnInsert(Id id){
        
        Billing__c billList = [Select Id, OpportunityName__c ,Total_Opportunity_Amount__c,Invoice_Date__c ,Balance_Opportunity_Amount__c,Invoice_Amount__c  from Billing__c where Id =: id];
        Opportunity Opty = [Select no_of_invoices__c,Invoice_Opportunity_Amount__c,Invoice_OpportunityAmount__c  from Opportunity Where Id =:billList.OpportunityName__c];
        if(billList.Invoice_Date__c != null){
            Integer month = billList.Invoice_Date__c.month();
            Integer year = billList.Invoice_Date__c.year();	
            if( month == 1){
                billList.Invoice_Month__c = 'JAN';
            }
            else if( month == 2){
                billList.Invoice_Month__c = 'FEB';
            }
            else if( month == 3){
                billList.Invoice_Month__c = 'MAR';
            }
            else if( month == 4){
                billList.Invoice_Month__c = 'APR';
            }
            else if( month == 5){
                billList.Invoice_Month__c = 'MAY';
            }
            else if( month == 6){
                billList.Invoice_Month__c = 'JUN';
            }
            else if( month == 7){
                billList.Invoice_Month__c = 'JUL';
            }
            else if( month == 8){
                billList.Invoice_Month__c = 'AUG';
            }
            else if( month == 9){
                billList.Invoice_Month__c = 'SEP';
            }
            else if( month == 10){
                billList.Invoice_Month__c = 'OCT';
            }
            else if( month == 11){
                billList.Invoice_Month__c = 'NOV';
            }
            else if( month == 12){
                billList.Invoice_Month__c = 'DEC';
            }
            
            if(month >= 1 && month <= 3){
                billList.Invoice_Quarter__c  = 'Q4 - '+ year;
            }
            else if(month >= 4 && month <= 6){
                billList.Invoice_Quarter__c  = 'Q1 - '+ year;
            }
            else if(month >= 7 && month <= 9){
                billList.Invoice_Quarter__c  = 'Q2 - '+ year;
            }
            else if(month >= 10 && month <= 12){
                billList.Invoice_Quarter__c  = 'Q3 - '+ year;
            }
        }
        Decimal count = Opty.no_of_invoices__c;
        if(count > 0){
            billList.Balance_Opportunity_Amount__c = Opty.Invoice_OpportunityAmount__c;
            if(billList.Invoice_Amount__c == null){
                billList.Invoice_Amount__c =0;
            }
            Opty.Invoice_OpportunityAmount__c = billList.Balance_Opportunity_Amount__c - billList.Invoice_Amount__c;
        }else{
            if(billList.Invoice_Amount__c == null){
                billList.Invoice_Amount__c =0;
            }
            Opty.Invoice_OpportunityAmount__c =  billList.Total_Opportunity_Amount__c - billList.Invoice_Amount__c;
        }
        billList.Balance_Opportunity_Amount__c = Opty.Invoice_OpportunityAmount__c;
        
        update Opty;
        update billList;
    }
    @AuraEnabled
    public static void getOpportunityBillingAmountOnUpdate(Id id,Id id1,boolean invoicemount ,boolean dateupdate,Decimal inamnt){
        if(abc == true) return ;
        Billing__c billList = [Select Id, OpportunityName__c ,Total_Opportunity_Amount__c,Invoice_Date__c, Balance_Opportunity_Amount__c,Invoice_Amount__c  from Billing__c where Id =: id1];
        Opportunity Opty = [Select no_of_invoices__c,Invoice_Opportunity_Amount__c,Invoice_OpportunityAmount__c  from Opportunity Where Id =:id];
        if(dateupdate == true){
            if(billList.Invoice_Date__c != null){
                Integer month = billList.Invoice_Date__c.month();
                Integer year = billList.Invoice_Date__c.year();	
                if( month == 1){
                    billList.Invoice_Month__c = 'JAN';
                }
                else if( month == 2){
                    billList.Invoice_Month__c = 'FEB';
                }
                else if( month == 3){
                    billList.Invoice_Month__c = 'MAR';
                }
                else if( month == 4){
                    billList.Invoice_Month__c = 'APR';
                }
                else if( month == 5){
                    billList.Invoice_Month__c = 'MAY';
                }
                else if( month == 6){
                    billList.Invoice_Month__c = 'JUN';
                }
                else if( month == 7){
                    billList.Invoice_Month__c = 'JUL';
                }
                else if( month == 8){
                    billList.Invoice_Month__c = 'AUG';
                }
                else if( month == 9){
                    billList.Invoice_Month__c = 'SEP';
                }
                else if( month == 10){
                    billList.Invoice_Month__c = 'OCT';
                }
                else if( month == 11){
                    billList.Invoice_Month__c = 'NOV';
                }
                else if( month == 12){
                    billList.Invoice_Month__c = 'DEC';
                }
                
                if(month >= 1 && month <= 3){
                    billList.Invoice_Quarter__c  = 'Q4 - '+ year;
                }
                else if(month >= 4 && month <= 6){
                    billList.Invoice_Quarter__c  = 'Q1 - '+ year;
                }
                else if(month >= 7 && month <= 9){
                    billList.Invoice_Quarter__c  = 'Q2 - '+ year;
                }
                else if(month >= 10 && month <= 12){
                    billList.Invoice_Quarter__c  = 'Q3 - '+ year;
                }
            }
        }
        if(invoicemount == true){
            Decimal count = Opty.no_of_invoices__c;
            System.debug('count'+count);
            if(count == 1 ){
                if(billList.Invoice_Amount__c == null){
                    billList.Invoice_Amount__c =0;
                }
                billList.Balance_Opportunity_Amount__c = billList.Total_Opportunity_Amount__c;
                Opty.Invoice_OpportunityAmount__c = billList.Balance_Opportunity_Amount__c - billList.Invoice_Amount__c;
                System.debug('billList.Invoice_Amount__c'+billList.Invoice_Amount__c);
                System.debug('Opty.Invoice_OpportunityAmount__c'+Opty.Invoice_OpportunityAmount__c);
                
            }else if(count > 1) {
                if(billList.Invoice_Amount__c == null){
                    billList.Invoice_Amount__c =0;
                }
                if(inamnt == null){
                    inamnt=0;
                }
               billList.Balance_Opportunity_Amount__c =  Opty.Invoice_OpportunityAmount__c +inamnt;
                Opty.Invoice_OpportunityAmount__c =  billList.Balance_Opportunity_Amount__c - billList.Invoice_Amount__c;
            }
            billList.Balance_Opportunity_Amount__c = Opty.Invoice_OpportunityAmount__c;
             System.debug('billList.Balance_Opportunity_Amount__c 12345   '+billList.Balance_Opportunity_Amount__c);
            
            
        }
        abc = true;
        update Opty;
        update billList;
        abc = false;
    }
}