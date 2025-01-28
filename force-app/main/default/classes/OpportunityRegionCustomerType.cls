public class OpportunityRegionCustomerType {
		@AuraEnabled
    public static void getOpportunityRegion(LIST<Opportunity>oppt){
        Set<Id> opptyid =  new set<Id>();
        for(Opportunity opp : oppt){
          opptyid.add(opp.Id); 
        }
		List<Opportunity> oppList = [Select Id, AccountId from Opportunity where Id IN :opptyid];
        Set<Id> accIdList = new Set<Id>();
        for(Opportunity oppty : oppList){
           accIdList.add(oppty.AccountId);
        }
        List<Opportunity> opptyToUpdateRegion = new List<Opportunity>();
        for(Account eachAcc : [Select Customer_Region__c,Type,CurrencyIsoCode, (Select Id from Opportunities) from Account where Id IN : accIdList]){
            for(Opportunity eachOpp : eachAcc.Opportunities){
 			eachOpp.Opportunity_Region__c= eachAcc.Customer_Region__c;
            eachOpp.CurrencyIsoCode=eachAcc.CurrencyIsoCode;    
             eachOpp.Customer_Type__c= eachAcc.Type;
                opptyToUpdateRegion.add(eachOpp);
            }
            update opptyToUpdateRegion;

        }

    }
}