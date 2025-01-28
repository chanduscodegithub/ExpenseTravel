/*------------------------------------------------------------
Author       :  Maaz Rahman
Company      :  CRMIT Pvt. Ltd.
Description  :  _
Inputs       :  Mentioned before each methods. No constructor for the LeaveHandler class.
Test Class   :  _

History
<Date>         <Authors Name>        <Brief Description of Change>
------------------------------------------------------------------*/
public without sharing class HolidayHandler {
    final static String CURRYEAR = String.valueOf(System.today().year());
    private class CustomLogicException extends Exception {
    }
    /**
* @description Region Mapping
*/
    final static Map<String, String> regionMapping = new Map<String, String>{
        'India' => 'IND',
            'Austrailia' => 'ANZ',
            'USA' => 'US'
            };
                /**
* This function returns a list of holidays for the current year and region of the current user based on a query from the Holiday__c and Holiday_Calendar__c objects.
* @return {List<Holiday__c>} The list of holidays for the current year and region of the current user.
* @throws {CustomLogicException} If there is any error in the query or the holiday data.
* @throws {AuraHandledException} If there is any other exception in the process.
* @AuraEnabled(cacheable=true) This function can be called from an Aura component and can be cached on the client side.
* @author Maaz
* @since 03/07/2023
*/
                @AuraEnabled(cacheable=true)
                public static List<Holiday__c> getHolidays(){
                    try {
                        List<Employee__c> empList = [SELECT Id, Name, Country__c, Gender__c, Region__c FROM Employee__c WHERE SF_User__c = :UserInfo.getUserId() and Active__c = true WITH SYSTEM_MODE];
                        if(empList.size() > 1){
                            throw new CustomLogicException('Error: Found multiple employee record, contact Admin Team.');
                        }else if(empList.size() == 0){
                            throw new CustomLogicException('Error: No employee record found, contact Admin Team.');
                        }
                        else {
                            if(empList[0].Region__c == null || empList[0].Region__c == ''){
                                if(regionMapping.containsKey(empList[0].Country__c)){
                                    empList[0].Region__c = regionMapping.get(empList[0].Country__c);
                                }else{
                                    throw new CustomLogicException('Error: Both Region and Country data is missing, contact Admin Team');
                                }
                            }
                        }
                        List<AggregateResult> aggrVersion = [SELECT Year__c, MAX(Version__c) FROM Holiday_Calendar__c WHERE Year__c =:CURRYEAR AND Region__c = :empList[0].Region__c AND Active__c = true WITH SYSTEM_MODE GROUP BY Year__c];
                        if(aggrVersion.size() == 0){
                            throw new CustomLogicException('Error: Found no Holiday data, contact HR Team.');
                        }
                        Decimal maxVersion = (Decimal)aggrVersion[0].get('expr0');
                        List<Holiday_Calendar__c> regionCalendar = [SELECT Id, Region__c, Year__c, (SELECT Name, Date__c, Holiday_Calendar__c, Holiday_Type__c FROM Holidays__r ORDER BY Date__c ASC) FROM Holiday_Calendar__c WHERE Year__c = :CURRYEAR AND Version__c = :maxVersion AND Active__c = true AND Region__c = :empList[0].Region__c WITH SYSTEM_MODE];
                        if(regionCalendar.size() > 1){
                            throw new CustomLogicException('Error: Found multiple Holiday data, contact HR Team.');
                        }else if(regionCalendar.size() == 0){
                            throw new CustomLogicException('Error: Found no Holiday data, contact HR Team.');
                        }
                        if((List<Holiday__c>)regionCalendar[0].getSObjects('Holidays__r') == null){
                            throw new CustomLogicException('Error: Found no Holiday data, contact HR Team.');
                        }
                        List<Holiday__c> holidays = (List<Holiday__c>)regionCalendar[0].getSObjects('Holidays__r');
                        return holidays;
                    } catch (Exception e) {
                        System.debug('Issue in: HolidayHandler @ getHolidays method');
                        System.debug('Err Msg: ' + e.getMessage());
                        System.debug('@ Line: ' + e.getLineNumber());
                        throw new AuraHandledException(e.getMessage());
                    }
                }
    
    @AuraEnabled(cacheable=true)
    public static List<Holiday__c> getHolidayListOfDifferentLocation(String region){
        try {
            List<AggregateResult> aggrVersion = [SELECT Year__c, MAX(Version__c) FROM Holiday_Calendar__c WHERE Year__c =:CURRYEAR AND Region__c = :region AND Active__c = true WITH SYSTEM_MODE GROUP BY Year__c];
            if(aggrVersion.size() == 0){
                throw new CustomLogicException('Error: Found no Holiday data, contact HR Team.');
            }
            Decimal maxVersion = (Decimal)aggrVersion[0].get('expr0');
            
            List<Holiday_Calendar__c> regionCalendar = [SELECT Id, Region__c, Year__c, (SELECT Name, Date__c, Holiday_Calendar__c, Holiday_Type__c FROM Holidays__r ORDER BY Date__c ASC) FROM Holiday_Calendar__c WHERE Year__c = :CURRYEAR AND Version__c = :maxVersion AND Active__c = true AND Region__c = :region WITH SYSTEM_MODE];
            if(regionCalendar.size() > 1){
                throw new CustomLogicException('Error: Found multiple Holiday data, contact HR Team.');
            }else if(regionCalendar.size() == 0){
                throw new CustomLogicException('Error: Found no Holiday data, contact HR Team.');
            }
            if((List<Holiday__c>)regionCalendar[0].getSObjects('Holidays__r') == null){
                throw new CustomLogicException('Error: Found no Holiday data, contact HR Team.');
            }
            List<Holiday__c> holidays = (List<Holiday__c>)regionCalendar[0].getSObjects('Holidays__r');
            return holidays;
        } catch (Exception e) {
            System.debug('Issue in: HolidayHandler @ getHolidays method');
            System.debug('Err Msg: ' + e.getMessage());
            System.debug('@ Line: ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
}