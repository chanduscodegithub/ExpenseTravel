public class TestTimesheet {
    public static void getCMD(){
        /*Map<Id, Team_Timesheet__c> allTS = new Map<Id, Team_Timesheet__c>([SELECT Id FROM Team_Timesheet__c]);
        List<Timesheet_Utils__c> allUtils = [SELECT Id, Timesheet__c FROM Timesheet_Utils__c];
        for(Timesheet_Utils__c eachUtil: allUtils){
            if(allTS.containsKey(eachUtil.Timesheet__c)){
                allTS.remove(eachUtil.Timesheet__c);
            }
        }*/
        
        Map<Id, Timesheet_Utils__c> allUtils = new Map<Id, Timesheet_Utils__c>([SELECT Id, Timesheet__c, Team_Allocation__c FROM Timesheet_Utils__c]);
        Map<Id, List<Id>> timesheetvsTeamalloc = new Map<Id, List<Id>>();
        for(Id eachUtils: allUtils.keySet()){
            Timesheet_Utils__c currUtils = allUtils.get(eachUtils);
            if(timesheetvsTeamalloc.containsKey(currUtils.Timesheet__c)){
                List<Id> allTeamalloc = timesheetvsTeamalloc.get(currUtils.Timesheet__c);
                if(allTeamalloc.contains(currUtils.Team_Allocation__c)){
                    System.debug('Error');
                    System.debug(currUtils.Timesheet__c);
                }else{
                    allTeamalloc.add(currUtils.Team_Allocation__c);
                }
            }else{
                List<Id> allTeamalloc = new List<Id>();
                allTeamalloc.add(currUtils.Team_Allocation__c);
                timesheetvsTeamalloc.put(currUtils.Timesheet__c, allTeamalloc);
            }
        }
    }
    public static void createUtil(){
        List<Team_Timesheet__c> allTTS = [SELECT Id, Name FROM Team_Timesheet__c WHERE (Status__c='Approved' OR Status__c='Submitted') AND Util_Created__c=0 limit 20 OFFSET 160];
        for(Team_Timesheet__c eachTS: allTTS){
            ProcessTimesheetUtilization.processUtil(eachTS.Id);
        }
    }
    public static void wrongSave(){
        List<Delivery__c> misplacedDTS = new List<Delivery__c>();
        Set<String> employeeIdList = new Set<String>();
        List<Delivery__c> tsAL = [SELECT id,Employee_Name__r.Name, Employee_Name__c, WeekStart__c, Date__c,  Team_Timesheet__r.Week_Start_Date__c, Team_Timesheet__r.Week_End_Date__c FROM Delivery__c ORDER BY Team_Timesheet__r.Week_Start_Date__c];
        //List<Delivery__c> tsAL = [Select id,Employee_Name__r.Name, Date__c, Team_Timesheet__r.Week_Start_Date__c, Team_Timesheet__r.Week_End_Date__c from Delivery__c where Team_Timesheet__r.Week_Start_Date__c  >= 2022-03-28 order by Team_Timesheet__r.Week_Start_Date__c];
        for(Delivery__c i: tsAL){
            if(i.Date__c > i.Team_Timesheet__r.Week_End_Date__c || i.Date__c < i.Team_Timesheet__r.Week_Start_Date__c){
                System.debug(i.Employee_Name__r.Name);
                System.debug('DTS: ');
                System.debug(i);
                /*if(i.Employee_Name__r.Name.containsIgnoreCase('Riya')){
                    System.debug('Name: '+i.Employee_Name__r.Name);
                    System.debug('DTS Id: '+i.Id);
                }*/
                misplacedDTS.add(i);
                employeeIdList.add(i.Employee_Name__c);
            }
        }
        List<Delivery__c> toUpdate = new List<Delivery__c>();
        List<Team_Timesheet__c> allParent = [SELECT ID, Week_Start_Date__c, Week_End_Date__c, Employee_Name__c, Employee_Name__r.Name FROM Team_Timesheet__c WHERE Employee_Name__c IN :employeeIdList];
        for(Team_Timesheet__c eachParent: allParent){
            for(Delivery__c eachMisplacedDTS: misplacedDTS){
                if(eachMisplacedDTS.Employee_Name__c == eachParent.Employee_Name__c && eachParent.Week_Start_Date__c==eachMisplacedDTS.WeekStart__c && eachParent.Week_Start_Date__c<=eachMisplacedDTS.Date__c && eachParent.Week_End_Date__c>=eachMisplacedDTS.Date__c){
                    eachMisplacedDTS.Team_Timesheet__c = eachParent.Id;
                    System.debug(eachMisplacedDTS.Date__c+' : Date went in b/w --> '+eachParent.Week_Start_Date__c+' to '+eachParent.Week_End_Date__c);
                    System.debug('For Empl: '+eachMisplacedDTS.Employee_Name__r.Name);
                    toUpdate.add(eachMisplacedDTS);
                }
			}
        }
        update toUpdate;
    }
}