/**
 * @description       : 
 * @author            : Ambika
 * @group             : 
 * @last modified on  : 05-02-2024
 * @last modified by  : Ambika
 * Modifications Log
 * Ver   Date         Author   Modification
 * 1.0   04-12-2024   Ambika   Initial Version
**/
public with sharing class profitabilitynewclass {
    
    private static Date constructStartDate(String fiscalYear) {
        Integer startYear = Integer.valueOf(fiscalYear.substring(0, 4));
        return Date.newInstance(startYear, 4, 1);
    }
    
    private static Date constructEndDate(String fiscalYear) {
        Integer endYear = Integer.valueOf(fiscalYear.substring(5, 9));
        return Date.newInstance(endYear, 3, 31);
    }
    
    
    
    @AuraEnabled //(cacheable=true)
    public static Map<String,Map<String,ProjectSummaryWrapper>> getcalculatesummaryy(string fiscalYear)
    {
        Date startDate = constructStartDate(fiscalYear);
        System.debug('startDate'+startDate);
        Date endDate = constructEndDate(fiscalYear);
        set<Id> opsid = new set<Id> ();       
        set<string> accname = new set<string>();
        set<string> optname = new set<string> ();
        Map<Integer, String> formonth = new Map<Integer, String>{1 => '13January',2 => '14February',3 => '15March',
            4 => '4April',5 => '5May',6 => '6June',7 => '7July',8 => '8August', 9 => '9September', 10 => '10October',
            11 => '11November',12 => '12December'};
                
                Map<Integer, String> formonthIntial = new Map<Integer, String>{13 => '13January',14 => '14February',15 => '15March',
                    4 => '4April',5 => '5May',6 => '6June',7 => '7July',8 => '8August', 9 => '9September', 10 => '10October',
                    11 => '11November',12 => '12December'};
                        
                        Map<String,Map<String,ProjectSummaryWrapper>> SummaryMap = new Map<String,Map<String,ProjectSummaryWrapper>>(); //Invoice_date__c   Invoice_Billing_date__c
                        system.debug('SummaryMap@oppquery>>>>'+SummaryMap);
        List<opportunity> opplist = [select Id, name,StageName, Account.name, (select id, name from Projects__r) from opportunity where StageName = 'Opportunity Won' and Expected_Project_End_Date__c >= :startDate  and Expected_Project_Start_Date__c  <= :endDate ];
        
        system.debug('opplist->>');
        //string projectNames;
        set<Id> opplistid = new set<Id>();
        Map<String, ProjectSummaryWrapper> oppSummaryWraps;
        for(Opportunity opp:opplist){
            
            opplistid.add(Opp.id);
            
            List<Project__c> projects = opp.Projects__r;
            List<String> projectNamesList = new List<String>();

            for (Project__c proj : projects) {
                
           projectNameslist.add(proj.Name);
           system.debug('projectNameslist>>>' +projectNameslist);
          // projectNames = proj.Name;
          for(string projectNames: projectNamesList){
            for(integer i=4;i<=15;i++)
            {
                if(SummaryMap.containskey(opp.name))
                {
                    Map<String,ProjectSummaryWrapper>OppSummaryWrap = SummaryMap.get(opp.name);
                   // OppSummaryWrap.put(formonthIntial.get(i),new ProjectSummaryWrapper('','',0,0,0,0,''));
                    OppSummaryWrap.put(formonthIntial.get(i),new ProjectSummaryWrapper(opp.name,opp.Account.name,0,0,0,0,projectNames));

                    SummaryMap.put((opp.name),OppSummaryWrap);
                    system.debug('SummaryMap@oppquery>>>>'+SummaryMap);
                }
                else
                {
                    Map<String,ProjectSummaryWrapper>OppSummaryWrap = new Map<String,ProjectSummaryWrapper>();
                   // OppSummaryWrap.put(formonthIntial.get(i),new ProjectSummaryWrapper('','',0,0,0,0,''));
                   OppSummaryWrap.put(formonthIntial.get(i),new ProjectSummaryWrapper(opp.name,opp.Account.name,0,0,0,0,projectNames));

                    SummaryMap.put(opp.name, OppSummaryWrap);
                    system.debug('SummaryMap@oppquery>>>>'+SummaryMap);
                }
                system.debug('SummaryMap@oppquery>>>>'+SummaryMap);
            }
        }
    }
}
        system.debug('SummaryMap@oppquery>>>>'+SummaryMap);
        system.debug('opplistid ->>>'+opplistid);
        
        List<AggregateResult> OppgroupedResults = [
            SELECT  
            OpportunityName__r.Id,
            OpportunityName__r.Name,
            OpportunityName__r.Account.Name Accname,
            CALENDAR_MONTH(Invoice_Billing_date__c) month,
            SUM(Invoice_Amount_Converted_In_USD__c) totalInvoiceAmount
            FROM 
            Billing__c
            WHERE 
            OpportunityName__r.Id IN :opplistid 
            AND OpportunityName__r.StageName = 'Opportunity Won'
            AND Invoice_Billing_date__c >= :startDate 
            AND Invoice_Billing_date__c <= :endDate
            GROUP BY 
            OpportunityName__r.Id, 
            OpportunityName__r.Name, 
            OpportunityName__r.Account.Name, 
            CALENDAR_MONTH(Invoice_Billing_date__c)
        ];
        System.debug('OppgroupedResults>>>>' + OppgroupedResults);
        
        
        
        for(AggregateResult ar : OppgroupedResults)
        {
            Id opportunityId = (Id)ar.get('Id');
            opsid.add(opportunityId);
            string opsname = (string)ar.get('Name');
            optname.add(opsname);
            string accnames=(string)ar.get('Accname');
            accname.add(accnames); //(String)ar.get('Id')
            for(integer i=4;i<=15;i++)
            {
                if(SummaryMap.containskey((String)ar.get('Name')) && !SummaryMap.get((String)ar.get('Name')).containskey(formonthIntial.get(i)))
                {
                    Map<String,ProjectSummaryWrapper>OppSummaryWrap = SummaryMap.get((String)ar.get('Name'));
                    OppSummaryWrap.put(formonthIntial.get(i),new ProjectSummaryWrapper('','',0,0,0,0,''));
                    SummaryMap.put((String)ar.get('Name'),OppSummaryWrap);
                }
                else
                {
                    Map<String,ProjectSummaryWrapper>OppSummaryWrap = new Map<String,ProjectSummaryWrapper>();
                    OppSummaryWrap.put(formonthIntial.get(i),new ProjectSummaryWrapper('','',0,0,0,0,''));
                    SummaryMap.put((String)ar.get('Name'),OppSummaryWrap);
                    
                    
                    
                }
            }
            
        }
        List<Project__c> projects = [select id, name,Opportunity__c from Project__c where Opportunity__c =:opsid];
        
        
        system.debug('FirstMap@@'+SummaryMap);
        
        for(AggregateResult ar : OppgroupedResults)
        {

            
             String projectName = ''; // Initialize projectName
             for (Project__c pr : projects) {
                if (pr.Opportunity__c == (Id)ar.get('Id')) {
                    projectName = pr.Name; // Assign projectName if project is found
            //         break;
              //  }
          //  }
            
            if(SummaryMap.containskey((String)ar.get('Name')))
            {
             
                if(SummaryMap.get((String)ar.get('Name')).containskey(formonth.get((Integer)ar.get('month'))))
                {
                   
                    ProjectSummaryWrapper PrWrap = SummaryMap.get((String)ar.get('Name')).get(formonth.get((Integer)ar.get('month')));
                    PrWrap.OpportunityName = (String)ar.get('Name');
                    PrWrap.Accountname = (String)ar.get('Accname') !=null ? (String)ar.get('Accname') : '-';
                    PrWrap.ActualRevenue = (Decimal)ar.get('totalInvoiceAmount') != null ? Math.round((Decimal)ar.get('totalInvoiceAmount')) : 0;
                    PrWrap.ProjectName = projectName;
                    PrWrap.ProfitMargin=calculateProfitMargin( PrWrap.ActualRevenue, PrWrap.TimeSheetCost);
                    PrWrap.Netprofit=calculateNetProfit(PrWrap.ActualRevenue, PrWrap.TimeSheetCost);     
                    system.debug('PrWrap77'+PrWrap);

                    // PrWrap.ActualRevenue = ((Decimal)ar.get('totalInvoiceAmount')).setScale(2);
                    SummaryMap.get((String)ar.get('Name')).put((formonth.get((Integer)ar.get('month'))) ,PrWrap);
                    
                }
                else
                {
                  
                    Map<String,ProjectSummaryWrapper>OppSummaryWrap = SummaryMap.get((String)ar.get('Name'));  //(Decimal)ar.get('cost') != null ? (Decimal)ar.get('cost') : 0 ;
                    OppSummaryWrap.put((formonth.get((Integer)ar.get('month'))),new ProjectSummaryWrapper((String)ar.get('Name'),(String)ar.get('Accname') !=null ? (String)ar.get('Accname') : '',(Decimal)ar.get('totalInvoiceAmount'),0,0,0,projectName));
                    SummaryMap.put((String)ar.get('Name'),OppSummaryWrap);
                    system.debug('OppSummaryWrap@@'+OppSummaryWrap);
                }
            }
            else
            {
               
                Map<String,ProjectSummaryWrapper>OppSummaryWrap = new Map<String,ProjectSummaryWrapper>{(formonth.get((Integer)ar.get('month'))) =>new ProjectSummaryWrapper((String)ar.get('Name'),(String)ar.get('Accname') !=null ? (String)ar.get('Accname') : '',(Decimal)ar.get('totalInvoiceAmount'),0,0,0,projectName)};
                system.debug('PrWrap77'+OppSummaryWrap);
                    SummaryMap.put((String)ar.get('Name'),OppSummaryWrap);
            }
        }
    }
}
        system.debug('opsid>>>>'+opsid);
        system.debug('accname>>>>'+accname);
        system.debug('SummaryMapsecond>>>>'+SummaryMap);
        
     
                
        // AggregateResult[] TAgroupedResults = [Select SUM(Cost__c)cost,Customer_Engagement__r.Opportunity__r.Name,CALENDAR_MONTH(Date__c )month from Delivery__c WHERE Date__c >=:startDate   AND Date__c <=: enddate AND Timesheet_Approval__r.Approval_Status__c IN ('Submitted', 'Approved') and Customer_Engagement__r.Opportunity__r.Name=:optname   and Billing_Status__c='Billable'   GROUP BY Customer_Engagement__r.Opportunity__r.Name,Date__c ]; and Billing_Status__c='Billable'
        AggregateResult[] TAgroupedResults = [Select SUM(Cost__c)cost, SUM(Cost_by_Designation__c)costByDesignation, Employee_Name__r.EmployeeID__c empId,Employee_Name__r.Name empname,Employee_Name__c EmployeeId, Customer_Engagement__r.Opportunity__r.Name,Customer_Engagement__r.Account__r.name accname,Timesheet_Approval__r.Approval_Status__c  approvalStatus, CALENDAR_MONTH(Date__c )month from Delivery__c WHERE Date__c >=:startDate   AND Date__c <=: enddate AND Timesheet_Approval__r.Approval_Status__c IN ('Approved') and Customer_Engagement__r.Opportunity__r.id=:opplistid    GROUP BY Employee_Name__c, Customer_Engagement__r.Opportunity__r.Name,Date__c,Customer_Engagement__r.Account__r.name,Employee_Name__r.Name, Employee_Name__r.EmployeeID__c, Timesheet_Approval__r.Approval_Status__c
 ];
        system.debug('TAgroupedResults>>>>'+TAgroupedResults);

        for(AggregateResult ar : TAgroupedResults){  
            if(SummaryMap.containskey((String)ar.get('Name'))) //(formonth.get((Integer)ar.get('month'))) ProjectSummaryWrapper PrSummay = SummaryMap.get((String)ar.get('Name')).get(formonth.get((Integer)ar.get('month')));
            {
                if(SummaryMap.get((String)ar.get('Name')).containskey(formonth.get((Integer)ar.get('month'))))
                {
                    ProjectSummaryWrapper PrSummay = SummaryMap.get((String)ar.get('Name')).get(formonth.get((Integer)ar.get('month')));
                    if((Decimal)ar.get('cost') != null){
                        if(((String)ar.get('empId')).contains('CT')){
                       // PrSummay.Hours +=(Decimal) ar.get('Time_in_Hours');
                        Id employeeId = (Id) ar.get('EmployeeId');
                        system.debug('employeeId>>>'+employeeId);
                       // PrSummay.costperemplyi = costperempmap.get(employeeId);
                       // PrSummay.Designation=String.valueOf(ar.get('designation'));
                       // PrSummay.ResourceName=String.valueOf(ar.get('empname'));


                        //PrSummay.TimeSheetCost= Math.round(PrSummay.Hours * PrSummay.costperemplyi) ;
                        PrSummay.TimeSheetCost += (Decimal)ar.get('cost') != null ?(Decimal)ar.get('cost') : 0;
                        PrSummay.Accountname=PrSummay.Accountname.length()<1 ? (String)ar.get('accname') : PrSummay.Accountname;
                        PrSummay.OpportunityName=PrSummay.OpportunityName.length()<1 ? (String)ar.get('Name') : PrSummay.OpportunityName;
                        
                        system.debug('PrSummay.TimeSheetCost>>>'+PrSummay.TimeSheetCost);
                        system.debug('PrSummay>>>>>'+PrSummay);
                        PrSummay.ProfitMargin=calculateProfitMargin( PrSummay.ActualRevenue, PrSummay.TimeSheetCost);
                        PrSummay.Netprofit=calculateNetProfit( PrSummay.ActualRevenue, PrSummay.TimeSheetCost);
                        SummaryMap.get((String)ar.get('Name')).put((formonth.get((Integer)ar.get('month'))) ,PrSummay);
                        system.debug('SummaryMap Inside if cost>>>' +SummaryMap);
                    }
                
                    else{
                       //PrSummay.Hours += (Decimal) ar.get('Time_in_Hours');

                              Id employeeId = (Id) ar.get('EmployeeId');
                            // PrSummay.costperemplyi = averageCost.get(employeeId);
                            // PrSummay.ResourceName=String.valueOf(ar.get('empname'));

                             // PrSummay.TimeSheetCost=Math.round(PrSummay.Hours *  PrSummay.costperemplyi );
                        PrSummay.TimeSheetCost += (Decimal)ar.get('costByDesignation') != null ? (Decimal)ar.get('costByDesignation') : 0 ;
                        PrSummay.Accountname=PrSummay.Accountname.length()<1 ? (String)ar.get('accname') : PrSummay.Accountname;
                        PrSummay.OpportunityName=PrSummay.OpportunityName.length()<1 ? (String)ar.get('Name') :  PrSummay.OpportunityName;
                       // PrSummay.Designation=String.valueOf(ar.get('designation'));

                        system.debug('PrSummay.TimeSheetCost>>>'+PrSummay.TimeSheetCost);
                        system.debug('PrSummay>>>>>'+PrSummay);
                        PrSummay.ProfitMargin=calculateProfitMargin( PrSummay.ActualRevenue, PrSummay.TimeSheetCost);
                        PrSummay.Netprofit=calculateNetProfit( PrSummay.ActualRevenue, PrSummay.TimeSheetCost);
                        SummaryMap.get((String)ar.get('Name')).put((formonth.get((Integer)ar.get('month'))) ,PrSummay);
                        system.debug('SummaryMap Inside if costByDesignation>>>' +SummaryMap);
                }
            }
        } 
        }
        
    }
        for(string summap : SummaryMap.keyset())
        {
            Decimal Opptotalrev = 0;
            Decimal Opptotalcost = 0;
            Decimal Opptotalnetpft =0;
            Decimal ttlprofitmargin=0;
            
            for(string monthmap :SummaryMap.get(summap).keyset())
            {
                Opptotalrev +=SummaryMap.get(summap).get(monthmap).ActualRevenue;
                Opptotalcost += Math.round(SummaryMap.get(summap).get(monthmap).TimeSheetCost);
                ttlprofitmargin=calculateProfitMargin(Opptotalrev, Opptotalcost);
                if(SummaryMap.get(summap).get(monthmap).Netprofit !=null){
                    Opptotalnetpft =  Math.round(Opptotalrev - Opptotalcost);
                }
                system.debug('Opptotalrev>>>>'+ Opptotalrev);
                system.debug('Opptotalcost>>>>' + Opptotalcost);
                system.debug('Opptotalnetpft>>>>'+ Opptotalnetpft);
                system.debug('ttlprofitmargin>>>>'+ ttlprofitmargin);
                
            }
            ProjectSummaryWrapper PrWraps = new ProjectSummaryWrapper('','',0,0,0,0,'');
            PrWraps.ActualRevenue = Opptotalrev;
            PrWraps.TimeSheetCost = Opptotalcost;
            PrWraps.Netprofit = Opptotalnetpft;
            PrWraps.ProfitMargin = ttlprofitmargin;
            
            
            
            //Map<string,ProjectSummaryWrapper>TotalSumWrap = new Map<string,ProjectSummaryWrapper>{'Total'=> new ProjectSummaryWrapper('','',Opptotalrev,0)};
            SummaryMap.get(summap).put('Total',PrWraps);
            
        }
        Map<String,ProjectSummaryWrapper> CountMonthRev = new Map<String,ProjectSummaryWrapper>();
        for(string summap : SummaryMap.keyset())
        {
            for(string monthmap :SummaryMap.get(summap).keyset())
            {
                if(CountMonthRev.containskey(monthmap))
                {
                    ProjectSummaryWrapper currentwrap = CountMonthRev.get(monthmap);
                    currentwrap.ActualRevenue += Math.round(SummaryMap.get(summap).get(monthmap).ActualRevenue);
                    currentwrap.TimeSheetCost +=  Math.round(SummaryMap.get(summap).get(monthmap).TimeSheetCost);
                    if(SummaryMap.get(summap).get(monthmap).Netprofit !=null){ 
                        currentwrap.Netprofit =(currentwrap.ActualRevenue - currentwrap.TimeSheetCost);
                    }

                    currentwrap.ProfitMargin = calculateProfitMargin(currentwrap.ActualRevenue, currentwrap.TimeSheetCost);
                    system.debug('currentwrap.ActualRevenue>>'+currentwrap.ActualRevenue);
                    system.debug('currentwrap.TimeSheetCost>>'+currentwrap.TimeSheetCost);
                    system.debug('currentwrap.Netprofit>>'+currentwrap.Netprofit);
                    System.debug('SummaryMap>>'+SummaryMap);
                    system.debug('ínside if 183');
                    CountMonthRev.put(monthmap,currentwrap);
                    
                }
                else
                {
                    system.debug('inside else in last line 188');
                    //  CountMonthRev.put(monthmap,new ProjectSummaryWrapper('','',SummaryMap.get(summap).get(monthmap).ActualRevenue,SummaryMap.get(summap).get(monthmap).TimeSheetCost,SummaryMap.get(summap).get(monthmap).Netprofit,SummaryMap.get(summap).get(monthmap).ProfitMargin));
                    ProjectSummaryWrapper newWrapper = new ProjectSummaryWrapper(
                        '',
                        '',
                        SummaryMap.get(summap).get(monthmap).ActualRevenue,
                        SummaryMap.get(summap).get(monthmap).TimeSheetCost,
                        SummaryMap.get(summap).get(monthmap).Netprofit,
                        0, // Set ProfitMargin to 0 initially
                        ''
                        //SummaryMap.get(summap).get(monthmap).Hours,
                       // SummaryMap.get(summap).get(monthmap).costperemplyi
                    );
                    
                    // Calculate ProfitMargin
                    newWrapper.ProfitMargin = calculateProfitMargin(newWrapper.ActualRevenue, newWrapper.TimeSheetCost);
                    
                    CountMonthRev.put(monthmap, newWrapper);
                    
                    
                    
                }
            }
        }
        system.debug('CountMonthRev>>>>'+CountMonthRev);
        SummaryMap.put('Totals',CountMonthRev);
        system.debug('SummaryMap>>>>'+SummaryMap);
        
        return SummaryMap;
    }
    public class ProjectSummaryWrapper {
        @AuraEnabled
        public String OpportunityName { get; set; }
        @AuraEnabled
        public string Accountname{ get; set; }
        @AuraEnabled
        public Decimal ActualRevenue { get; set; } 
        @AuraEnabled
        public Decimal TimeSheetCost { get; set; }   
        @AuraEnabled
        public Decimal ProfitMargin { get; set; }
        @AuraEnabled
        public Decimal Netprofit { get; set; }
        @AuraEnabled
        public String projectname { get; set; }

        
        //   @AuraEnabled  
        //public Decimal ttlprofitmargin { get; set; }
        
        public ProjectSummaryWrapper( String opportunityName,String accountname, Decimal actualRevenue,Decimal timesheetcost, Decimal Netprofit, Decimal ttlprofitmargin, string projectname) {
            this.OpportunityName = opportunityName;  
            this.Accountname =accountname;
            this.ActualRevenue= (actualRevenue);
            this.TimeSheetCost =timesheetcost;
            this.Netprofit= (Netprofit);
            this.projectname=projectname;
            
            // this.ProfitMargin = calculateProfitMargin(actualRevenue, timesheetcost);
            
        }
        
    } //ProfitMargin
    Public static  Decimal calculateProfitMargin(Decimal revenue, Decimal cost) {
        system.debug('revenue>>>'+revenue);
        system.debug('cost>>>'+cost);
        //  decimal profit;
        if (revenue != 0) {
            return ((revenue - cost) / revenue * 100).setScale(1);
            
        } else {
            return 0;
        }
    }
    
    private static Decimal calculateNetProfit(Decimal revenue, Decimal cost) {
        system.debug('190revenue>>>'+revenue);
        system.debug('191cost>>>'+cost);
        //  if (revenue != 0 ) {
        return  Math.round(revenue - cost);
        
        // }
        // return 0;
    }
    
    
     @AuraEnabled
    public static Map<String, Map<String, csthrswrapper>> getcost(String fiscalYear) {
        Map<String, Map<String, csthrswrapper>> costmap = new Map<String, Map<String, csthrswrapper>>();
        
        Date startDate = constructStartDate(fiscalYear);
        Date endDate = constructEndDate(fiscalYear);
        system.debug('startDate inside getcost>.'+startDate);
        system.debug('endDate inside getcost>.'+endDate);
        
       list<Employees_per_hour_cost__c> costlist = [SELECT ID,Employee__c, Cost_per_Hour__c FROM Employees_per_hour_cost__c where Cost_per_Hour__c !=null];
       list<Employee__c>averageCostList = [SELECT id, Designation__r.Average_cost__c from Employee__c where Designation__r.Average_cost__c !=null];
        map<Id, Decimal> costperempmap = new map<Id, Decimal>();
       for(Employees_per_hour_cost__c emcost : costlist){
           costperempmap.put(emcost.Employee__c, emcost.Cost_per_Hour__c);
       }
       map<Id, Decimal> averageCost = new map<Id, Decimal>();
       for(Employee__c avgcost : averageCostList){
           averageCost.put(avgcost.id, avgcost.Designation__r.Average_cost__c);
       }

        // Querying non Bench
       List<AggregateResult> dlist1 = [Select SUM(Cost__c)totalcostt, SUM(Cost_by_Designation__c)totalcost, Employee_Name__r.EmployeeID__c empId,Employee_Name__c EmployeeId, Customer_Engagement__r.Opportunity__r.Name,Customer_Engagement__r.Account__r.name accname, SUM(Actual_Time_in_hours__c)totalhours,Employee_Name__r.Designation__r.Name designation,Timesheet_Approval__r.Approval_Status__c  approvalStatus,CALENDAR_MONTH(Date__c) monthNumeric from Delivery__c WHERE Date__c >=:startDate   AND Date__c <=: enddate AND Timesheet_Approval__r.Approval_Status__c IN ('Approved') AND  Team_Allocation__r.Billing_Status__c NOT IN ('Bench','Shadow Resource')   GROUP BY Employee_Name__c, Customer_Engagement__r.Opportunity__r.Name,Date__c,Customer_Engagement__r.Account__r.name, Employee_Name__r.EmployeeID__c, Timesheet_Approval__r.Approval_Status__c, Employee_Name__r.Designation__r.Name  ORDER BY 
                                        MIN(Date__c)];
        
       /* List<AggregateResult> dlist1 = [
            SELECT 
            CALENDAR_MONTH(Date__c) monthNumeric,
            SUM(Actual_Time_in_hours__c) totalhours, 
            Employee_Name__r.EmployeeID__c empId,
            SUM(Cost_by_Designation__c) totalcost,
            SUM(Cost__c) totalCostt
            FROM 
            delivery__c 
            WHERE 
            (Cost_by_Designation__c !=null OR Cost__c != null) AND
            Team_Allocation__r.Billing_Status__c NOT IN ('Bench','Shadow Dev')
            AND 
            Date__c >= :startDate 
            AND Date__c <= :endDate 
            GROUP BY 
            CALENDAR_MONTH(Date__c),
            Employee_Name__r.EmployeeID__c
            ORDER BY 
            MIN(Date__c)
        ];*/
        system.debug('dlist1>>>'+dlist1);
        // Query for Bench          
        List<AggregateResult> dlist2 = [Select SUM(Cost__c)totalcostt, SUM(Cost_by_Designation__c)totalcost, Employee_Name__r.EmployeeID__c empId,Employee_Name__c EmployeeId, Customer_Engagement__r.Opportunity__r.Name,Customer_Engagement__r.Account__r.name accname, SUM(Time_in_Hours__c)totalhours,Employee_Name__r.Designation__r.Name designation,Timesheet_Approval__r.Approval_Status__c  approvalStatus,CALENDAR_MONTH(Date__c) monthNumeric from Delivery__c WHERE Date__c >=:startDate   AND Date__c <=: enddate AND Timesheet_Approval__r.Approval_Status__c IN ('Approved') AND  Team_Allocation__r.Billing_Status__c IN ('Bench')   GROUP BY Employee_Name__c, Customer_Engagement__r.Opportunity__r.Name,Date__c,Customer_Engagement__r.Account__r.name, Employee_Name__r.EmployeeID__c, Timesheet_Approval__r.Approval_Status__c, Employee_Name__r.Designation__r.Name  ORDER BY 
                                        MIN(Date__c)];

        /*List<AggregateResult> dlist2 = [
            SELECT 
            CALENDAR_MONTH(Date__c) monthNumeric,
            SUM(Actual_Time_in_hours__c) totalhours, 
            Employee_Name__r.EmployeeID__c empId,
            SUM(Cost_by_Designation__c) totalcost,
            SUM(Cost__c) totalCostt
            FROM 
            delivery__c 
            WHERE 
            (Cost_by_Designation__c !=null OR Cost__c != null) AND
            Team_Allocation__r.Billing_Status__c IN ('Bench') 
            AND Date__c >= :startDate 
            AND Date__c <= :endDate
            GROUP BY 
            CALENDAR_MONTH(Date__c),
            Employee_Name__r.EmployeeID__c
            ORDER BY 
            MIN(Date__c)
        ];*/
        system.debug('dlist2>>>'+dlist2);
        List<AggregateResult> dlist3 = [Select SUM(Cost__c)totalcostt, SUM(Cost_by_Designation__c)totalcost, Employee_Name__r.EmployeeID__c empId,Employee_Name__c EmployeeId, Customer_Engagement__r.Opportunity__r.Name,Customer_Engagement__r.Account__r.name accname, SUM(Actual_Time_in_hours__c)totalhours,Employee_Name__r.Designation__r.Name designation,Timesheet_Approval__r.Approval_Status__c  approvalStatus,CALENDAR_MONTH(Date__c) monthNumeric from Delivery__c WHERE Date__c >=:startDate   AND Date__c <=: enddate AND Timesheet_Approval__r.Approval_Status__c IN ('Approved') AND  Team_Allocation__r.Billing_Status__c IN ('Shadow Resource')   GROUP BY Employee_Name__c, Customer_Engagement__r.Opportunity__r.Name,Date__c,Customer_Engagement__r.Account__r.name, Employee_Name__r.EmployeeID__c, Timesheet_Approval__r.Approval_Status__c, Employee_Name__r.Designation__r.Name  ORDER BY 
                                        MIN(Date__c)];
       /* List<AggregateResult> dlist3 = [
            SELECT 
            CALENDAR_MONTH(Date__c) monthNumeric,
            SUM(Actual_Time_in_hours__c) totalhours, 
            Employee_Name__r.EmployeeID__c empId,
            SUM(Cost_by_Designation__c) totalcost,
            SUM(Cost__c) totalCostt           
            FROM 
            delivery__c 
            WHERE 
            (Cost_by_Designation__c !=null OR Cost__c != null) AND
            Team_Allocation__r.Billing_Status__c IN ('Shadow Dev')
            AND 
            Date__c >= :startDate 
            AND Date__c <= :endDate 
            GROUP BY 
            CALENDAR_MONTH(Date__c),
            Employee_Name__r.EmployeeID__c
            ORDER BY 
            MIN(Date__c)
        ];*/
        system.debug('dlist3>>>'+dlist3);
        
        
        if(dlist1 !=null && !dlist1.isEmpty()){
            system.debug('inside if>>>>');
            processResults(costmap, 'Billable', dlist1); 
        }
        
        
        
        if(dlist2 !=null && !dlist2.isEmpty()){
            system.debug('inside if22>>>>');
            processResults(costmap, 'Bench', dlist2);
        }

        if(dlist3 !=null && !dlist3.isEmpty()){
            system.debug('inside if33>>>>');
            processResults(costmap, 'Shadow Resource', dlist3);
        }
        
        
        
        System.debug('costmap: ' + costmap);
        return costmap;
    }
    
    private static void processResults(Map<String, Map<String, csthrswrapper>> costmap, String billingStatus, List<AggregateResult> dlist) {
        Integer[] allMonths = new Integer[]{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12};
        list<Employees_per_hour_cost__c> costlist = [SELECT ID,Employee__c, Cost_per_Hour__c FROM Employees_per_hour_cost__c where Cost_per_Hour__c !=null];
       list<Employee__c>averageCostList = [SELECT id, Designation__r.Average_cost__c from Employee__c where Designation__r.Average_cost__c !=null];
        map<Id, Decimal> costperempmap = new map<Id, Decimal>();
       for(Employees_per_hour_cost__c emcost : costlist){
           costperempmap.put(emcost.Employee__c, emcost.Cost_per_Hour__c);
       }
       map<Id, Decimal> averageCost = new map<Id, Decimal>();
       for(Employee__c avgcost : averageCostList){
           averageCost.put(avgcost.id, avgcost.Designation__r.Average_cost__c);
       }
            
            if (!dlist.isEmpty()) {
                Decimal totalTotalHours = 0;
                Decimal totalTotalCost = 0;
                Set<Integer> existingMonths = new Set<Integer>();
                
                for (AggregateResult ar : dlist) {
                    Integer monthNumeric = (Integer) ar.get('monthNumeric');
                    existingMonths.add(monthNumeric);
                    String monthName = getMonthName(monthNumeric);
                    
                    if (!costmap.containsKey(billingStatus)) {
                        costmap.put(billingStatus, new Map<String, csthrswrapper>());
                    }
                    
                    csthrswrapper prWrap = new csthrswrapper();
                   // prWrap.totalhours = (Decimal) ar.get('totalhours') != null ? (Decimal) ar.get('totalhours') : 0;
                   prWrap.totalhours=String.valueOf(ar.get('approvalStatus')) != 'Approved' ? 0 :(Decimal) ar.get('totalhours');

                    if(((String)ar.get('empId')).contains('CT')){
                        Id employeeId = (Id) ar.get('EmployeeId');
                        prWrap.costperemplyi = costperempmap.get(employeeId);
                       // prWrap.totalcost= Math.round(prWrap.totalhours * prWrap.costperemplyi) ;
                        prWrap.totalcost = (Decimal) ar.get('totalCostt') != null ? (Decimal) ar.get('totalCostt') : 0;
                    }
                    else
                        {
                Id employeeId = (Id) ar.get('EmployeeId');
               prWrap.costperemplyi = averageCost.get(employeeId);
               //prWrap.totalcost=Math.round(prWrap.totalhours * prWrap.costperemplyi );
                   prWrap.totalcost = (Decimal) ar.get('totalcost') != null ? (Decimal) ar.get('totalcost') : 0;
                    }
                    
                    if (!costmap.get(billingStatus).containsKey(monthName)) {
                        costmap.get(billingStatus).put(monthName, prWrap);
                    } else {
                        csthrswrapper existingWrap = costmap.get(billingStatus).get(monthName);
                        existingWrap.totalhours += prWrap.totalhours != null ? prWrap.totalhours : 0;
                        existingWrap.totalcost += prWrap.totalcost != null ? prWrap.totalcost : 0;
                    }
                    
                    totalTotalHours += prWrap.totalhours != null ? prWrap.totalhours : 0;

                    totalTotalCost += prWrap.totalcost != null ? prWrap.totalcost : 0;
                }
                
                for (Integer monthNumeric : allMonths) {
                    if (!existingMonths.contains(monthNumeric)) {
                        String missingMonthName = getMonthName(monthNumeric);
                        csthrswrapper zeroWrapper = new csthrswrapper();
                        zeroWrapper.totalhours = 0;
                        zeroWrapper.totalcost = 0;
                        costmap.get(billingStatus).put(missingMonthName, zeroWrapper);
                    }
                }
                
                csthrswrapper totalWrapper = new csthrswrapper();
                totalWrapper.totalhours = totalTotalHours != null ? totalTotalHours : 0;
                totalWrapper.totalcost = totalTotalCost != null ? totalTotalCost : 0;
                
                costmap.get(billingStatus).put('Total', totalWrapper);
            }
        costmap.remove('Total');
        // After processing billable and bench records, calculate the total for each month
        for (Integer monthNumeric : allMonths) {
            String monthName = getMonthName(monthNumeric);
            csthrswrapper totalMonthWrapper = new csthrswrapper();
            Decimal totalBillableHours = 0;
            Decimal totalBillableCost = 0;
            Decimal totalBenchHours = 0;
            Decimal totalBenchCost = 0;
            Decimal totalshadowdevHours = 0;
            Decimal totalshadowdevCost = 0;
            
            if (costmap.containsKey('Billable')) {
                csthrswrapper billableWrapper = costmap.get('Billable').get(monthName);
                if (billableWrapper != null) {
                    totalBillableHours = billableWrapper.totalhours;
                    totalBillableCost = billableWrapper.totalcost;
                }
            }
            
            if (costmap.containsKey('Bench')) {
                csthrswrapper benchWrapper = costmap.get('Bench').get(monthName);
                if (benchWrapper != null) {
                    totalBenchHours = benchWrapper.totalhours;
                    totalBenchCost = benchWrapper.totalcost;
                }
            }
            if (costmap.containsKey('Shadow Resource')) {
                csthrswrapper shadowWrapper = costmap.get('Shadow Resource').get(monthName);
                if (shadowWrapper != null) {
                    totalshadowdevHours = shadowWrapper.totalhours;
                    totalshadowdevCost = shadowWrapper.totalcost;
                }
            }
            
            totalMonthWrapper.totalhours = totalBillableHours + totalBenchHours + totalshadowdevHours;
            totalMonthWrapper.totalcost = totalBillableCost + totalBenchCost + totalshadowdevCost;
            
            // Check if the 'Total' key exists in costmap
            if (!costmap.containsKey('Total')) {
                costmap.put('Total', new Map<String, csthrswrapper>());
            }
            
            costmap.get('Total').put(monthName, totalMonthWrapper);
        }
        
        // Finally, add the 'Total' entry after processing both billable and bench records
        csthrswrapper totalTotalWrapper = new csthrswrapper();
        totalTotalWrapper.totalhours = 0;
        totalTotalWrapper.totalcost = 0;
        for (Integer monthName : allMonths) {
            string month = getMonthName(monthName);
            if (costmap.containsKey('Total')) {
                csthrswrapper totalMonthWrapper = costmap.get('Total').get(month);
                if (totalMonthWrapper != null) {
                    totalTotalWrapper.totalhours += totalMonthWrapper.totalhours;
                    totalTotalWrapper.totalcost += totalMonthWrapper.totalcost;
                }
            }
        }
        costmap.get('Total').put('Total', totalTotalWrapper);
    }
    
    
    
    private static String getMonthName(Integer monthNumeric) {
        String[] monthNames = new String[]{
            'January', 'February', 'March', 'April', 'May', 'June',
                'July', 'August', 'September', 'October', 'November', 'December'
                };
                    return monthNames[monthNumeric - 1];
    }
    
    public class csthrswrapper{
        @AuraEnabled
        public Decimal totalcost { get; set; }
        @AuraEnabled
        public Decimal totalhours { get; set; }
        public Id empId;
        public decimal costperemplyi;
    }
       
}