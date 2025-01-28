public class dummyClass {
    public static void cls(){
        List<TeamAllocation__c> scope = [SELECT Id, EmployeeName__r.Name, EmployeeName__r.Id, EmployeeName__r.Email_ID__c,  EndDate__c, StartDate__c FROM TeamAllocation__c WHERE ((StartDate__c>= LAST_N_DAYS:6  AND EndDate__c>= TODAY  AND StartDate__c<= TODAY ) OR (StartDate__c<= LAST_N_DAYS:6  AND EndDate__c>= TODAY )OR(StartDate__c<= LAST_N_DAYS:6 AND EndDate__c<= TODAY  AND EndDate__c>= LAST_N_DAYS:6 )OR(StartDate__c>= LAST_N_DAYS:6  AND EndDate__c<= TODAY ) )];
        Set<String> empIDs = new Set<String>();
        for(TeamAllocation__c eachTA: scope){
            empIDs.add(eachTA.EmployeeName__r.Name);
        }
        System.debug(empIDs.size());
        for(String n: empIDs){
            System.debug(n);
        }
    }
}