/*************************************************************************************************************
 * @name            OpportunityTriggerHelper
 * @author          Rohit Pal   <rohit.pal@crmit.com>
 * @created         29 / 06 / 2020
 * @description     Description of your code
 *
 * Changes (version)
 * -----------------------------------------------------------------------------------------------------------
 *              No.     Date            Author                  Description
 *              ----    ------------    --------------------    ----------------------------------------------
 * @version     1.0     2020-06-29      Rohit Pal               
 *
**************************************************************************************************************/
public class OpportunityTriggerHelper {
    

    /**
    * @description 
    * @author Rohit Pal | 29/6/2020 
    * @param mapNewOpportunity 
    * @return void 
    **/
    public static void createRFPREcord(Map<Id, Opportunity> mapNewOpportunity , Boolean isUpdate){
        //
        Map<Id, RFPProcess__c> mapRFPProcess = new Map<Id, RFPProcess__c>();
        //
        for (Opportunity iterator : mapNewOpportunity.values()) {
            //
            if(!mapRFPProcess.containsKey(iterator.Id)){
                //
                RFPProcess__c objRFPProcess = new RFPProcess__c();
                objRFPProcess.RFPDescription__c= iterator.Description;
                objRFPProcess.CurrencyIsoCode = iterator.Currency__c;
                objRFPProcess.Opportunity__c = iterator.id;
                objRFPProcess.Region__c = iterator.Opportunity_Region__c;
                objRFPProcess.AccountName__c = iterator.AccountId;
                if(isUpdate){
                objRFPProcess.OwnerId= iterator.ownerId;
                }
                mapRFPProcess.put(iterator.id , objRFPProcess);
            }
        }
        //
        if(!mapRFPProcess.isEmpty()){
            try {
                insert mapRFPProcess.values();
            } catch (Exception e) {
                System.debug('Exception Message Is ' + e.getMessage() + 'Cause - ' +e.getCause()+'Line'+ e.getLineNumber());
            }
        }
    }

     /**
    * @description : This is used when the Opportunity Status change  to Won / Los 
                     change the  respective RFP Process status to same Won / Los.
    * @author Rohit Pal | 04/7/2020 
    * @param updateRFPRecord 
    * @return void 
    **/
    public static void updateRFPRecord(Map<Id, Opportunity> mapNewOpportunity){
        //
        List<RFPProcess__c> listUpdateRFPProcess = new List<RFPProcess__c>();
        //
        if(!mapNewOpportunity.isEmpty()){
            //
            for(RFPProcess__c iteratorRFPProcess : [SELECT Id,
                                                           Name,
                                                           RFPStatus__c,
                                                           Opportunity__c
                                                    FROM RFPProcess__c
                                                    WHERE Opportunity__c IN : mapNewOpportunity.keyset()]){
                //
                iteratorRFPProcess.RFPStatus__c = mapNewOpportunity.get(iteratorRFPProcess.Opportunity__c).Opportunity_Status__c ;
                //
                listUpdateRFPProcess.add(iteratorRFPProcess);
            }
        }
        if(!listUpdateRFPProcess.isEmpty()){
            try {
                update listUpdateRFPProcess;
            } catch (Exception e) {
                System.debug('Exception Message Is ' + e.getMessage() + 'Cause - ' +e.getCause()+'Line'+ e.getLineNumber());
            }
        }
    }
}