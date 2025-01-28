public class ProcessTimesheetUtilization extends TriggerHandler{
    private class hrs_childTS{
        private Decimal actualHrs;
        private Decimal allocHrs;
        private List<Delivery__c> childTSList {get;set;}
    }
    private class weekSpanWrapper{
        private Decimal alloc_calculated;
        private Date startWeekDate_calculated;
        private Date endWeekDate_calculated;
    }
    public static void processUtil(String TSId){
        //Map of Project.Id (as Key) and hrs_childTS (Hrs and List of Child TS)
        Map<Id, hrs_childTS> projWrap = new Map<Id, hrs_childTS>();
        Set<String> uniqueTAIds = new Set<String>();
        Team_Timesheet__c TS = [SELECT Id, Employee_Name__c, Week_Start_Date__c, Week_End_Date__c FROM Team_Timesheet__c WHERE Id=:TSId];
        List<Delivery__c> allChildTS = [SELECT Team_Allocation__c, Team_Allocation__r.Project__c, Team_Allocation__r.AllocationPercentage__c, Billing_Status__c, Category__c, Time_in_Hours__c, WeekStart__c, WeekEnd__c FROM Delivery__c WHERE Team_Timesheet__c=:TS.Id AND Team_Allocation__r.Project__r.Name != 'Others'];
        for(Delivery__c eachChildTS: allChildTS){
            uniqueTAIds.add(eachChildTS.Team_Allocation__c);
        }
        Map<Id, TeamAllocation__c> teamAllocationMap = new Map<Id, TeamAllocation__c>([SELECT Id, Name, StartDate__c, EndDate__c, AllocationPercentage__c FROM TeamAllocation__c WHERE Id IN :uniqueTAIds]);
        for(Delivery__c eachChildTS: allChildTS){
            if(projWrap.containsKey(eachChildTS.Team_Allocation__c)){
                hrs_childTS existingWrapper = projWrap.get(eachChildTS.Team_Allocation__c);
                existingWrapper.actualHrs += eachChildTS.Time_in_Hours__c;
                existingWrapper.childTSList.add(eachChildTS);
            }else{
                hrs_childTS newWrapper = new hrs_childTS();
                TeamAllocation__c currTeamAllocation = teamAllocationMap.get(eachChildTS.Team_Allocation__c);
                weekSpanWrapper date_and_AllocWrap = weekSpan_allocTime(eachChildTS.WeekStart__c, eachChildTS.WeekEnd__c, currTeamAllocation);
                newWrapper.allocHrs = date_and_AllocWrap.alloc_calculated;
                newWrapper.actualHrs = eachChildTS.Time_in_Hours__c;
                List<Delivery__c> childList = new List<Delivery__c>();
                childList.add(eachChildTS);
                newWrapper.childTSList = childList;
                projWrap.put(eachChildTS.Team_Allocation__c,newWrapper);
            }
        }
        List<TeamAllocation__c> blankAlloc = [SELECT Id, Name, EndDate__c, StartDate__c, AllocationPercentage__c FROM TeamAllocation__c WHERE EmployeeName__c=:TS.Employee_Name__c AND Project__r.Name!='Others' AND Id NOT IN :uniqueTAIds AND ((StartDate__c>= :TS.Week_Start_Date__c AND EndDate__c>= :TS.Week_End_Date__c AND StartDate__c<= :TS.Week_End_Date__c) OR (StartDate__c<= :TS.Week_Start_Date__c AND EndDate__c>= :TS.Week_End_Date__c)OR(StartDate__c<= :TS.Week_Start_Date__c AND EndDate__c<= :TS.Week_End_Date__c AND EndDate__c>= :TS.Week_Start_Date__c) OR (StartDate__c>= :TS.Week_Start_Date__c AND EndDate__c<= :TS.Week_End_Date__c))];
        for(TeamAllocation__c eachBlank : blankAlloc){
            hrs_childTS newWrapper = new hrs_childTS();
            newWrapper.actualHrs = 0.00;
            weekSpanWrapper date_and_AllocWrap = weekSpan_allocTime(TS.Week_Start_Date__c, TS.Week_End_Date__c, eachBlank);
            newWrapper.allocHrs = date_and_AllocWrap.alloc_calculated;
            projWrap.put(eachBlank.Id, newWrapper);
        }
        saveUtils(projWrap, TSId, TS.Employee_Name__c);
    }    
    // Calculating allocation hours
    private static weekSpanWrapper weekSpan_allocTime(Date dtsStart, Date dtsEnd, TeamAllocation__c currTA){
        //System.debug('Week: '+dtsStart+' - '+dtsEnd);
        //System.debug('Alloc Start: '+currTA.StartDate__c);
        //System.debug('Alloc End: '+currTA.EndDate__c);
        weekSpanWrapper dateAllocCal = new weekSpanWrapper();
        if(currTA.StartDate__c < dtsStart){
            dateAllocCal.startWeekDate_calculated = dtsStart;
        }else{
            dateAllocCal.startWeekDate_calculated = currTA.StartDate__c;
        }
        if(currTA.EndDate__c < dtsEnd){
            dateAllocCal.endWeekDate_calculated = currTA.EndDate__c;
        }else{
            dateAllocCal.endWeekDate_calculated = dtsEnd;
        }
        System.debug('Team Alloc: '+currTA.Name);
        System.debug('Calculated Alloc Start: '+dateAllocCal.startWeekDate_calculated);
        System.debug('Calculated Alloc End: '+dateAllocCal.endWeekDate_calculated);
        Decimal percentageby100 = double.valueOf(currTA.AllocationPercentage__c)/100;
		Date startofCurrWeek =  dateAllocCal.startWeekDate_calculated.toStartofWeek();
        System.debug('Start of Curr Week: '+startofCurrWeek);
        System.debug('%/100: '+percentageby100);
        Date endofWeek = startofCurrWeek.addDays(5);
		dateAllocCal.endWeekDate_calculated = dateAllocCal.endWeekDate_calculated < endofWeek ? dateAllocCal.endWeekDate_calculated : endofWeek;
		Integer dayInBW = Integer.valueOf(dateAllocCal.startWeekDate_calculated.daysBetween(dateAllocCal.endWeekDate_calculated))+1;
        System.debug('Start Considered: '+dateAllocCal.startWeekDate_calculated);
        System.debug('End Considered: '+dateAllocCal.endWeekDate_calculated);
        System.debug('Day in B/W: '+dayInBW);
		if(dayInBW>0){
			dateAllocCal.alloc_calculated = dayInBW * percentageby100 * 8;
		}else{
    		dateAllocCal.alloc_calculated = 0;
		}
        return dateAllocCal;
    }
    // Generating Records
    private static void saveUtils(Map<Id, hrs_childTS> allocationWrap, String tsID, String empId){
        List<Timesheet_Utils__c> TUListexisting = [SELECT Id,Team_Allocation__c,Team_Allocation__r.Project__c FROM Timesheet_Utils__c WHERE Timesheet__c=:TSId];
        system.debug('TUListexisting>>>'+TUListexisting);
        set<id> taIdset=new set<id>();
        for(Timesheet_Utils__c tu:TUListexisting){
            taIdset.add(tu.Team_Allocation__c);
        }
        system.debug('taIdset>>>'+taIdset);
        
        List<Timesheet_Utils__c> TUList = new List<Timesheet_Utils__c>();
        for(Id taId: allocationWrap.keySet()){
            if(!taIdset.contains(taId)){
            hrs_childTS existingWrapper = allocationWrap.get(taId);
            Timesheet_Utils__c eachTU = new Timesheet_Utils__c();
            eachTU.Actual_Hours__c = existingWrapper.actualHrs;
            eachTU.Allocated_Hours__c = existingWrapper.allocHrs;
            eachTU.Team_Allocation__c = taId;
            eachTU.Timesheet__c = tsID;
            eachTU.Employee__c = empId;
            TUList.add(eachTU);
        }
        }
        insert TUList;
    }
    // Deleting Utils
    public static void deleteUtils(String TSId){
        set<String> projName=new set<String>();
        boolean rejected;
        List<Timesheet_Approval__c> tsaList=[SELECT Id,Approval_Status__c,Customer_Engagement__c,Customer_Engagement__r.Name,Timesheet__r.Status__c from Timesheet_Approval__c where Timesheet__c=:TSId and Approval_Status__c='Rejected'];
        for(Timesheet_Approval__c ta:tsaList){
            projName.add(ta.Customer_Engagement__r.Name);
            if(ta.Timesheet__r.Status__c=='Rejected')
            rejected=true;
                
        }
        system.debug('projName>>>'+projName);
        List<Timesheet_Utils__c> TUList=new List<Timesheet_Utils__c>();
        if(rejected==true){
        TUList = [SELECT Id,Project__c FROM Timesheet_Utils__c WHERE Timesheet__c=:TSId];
        system.debug('TUList>>>'+TUList);
        delete TUList;
        }
        else{
        TUList = [SELECT Id,Project__c FROM Timesheet_Utils__c WHERE Project__c=:projName and Timesheet__c=:TSId];
        system.debug('TUList>>>'+TUList);
        delete TUList;
            }
    }
}