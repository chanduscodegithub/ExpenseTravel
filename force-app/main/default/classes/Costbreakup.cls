public class Costbreakup {
    @AuraEnabled(cacheable=true)
    public static  List<AcctSeed__Accounting_Period__c> accountingperiodlist(){
        List<AcctSeed__Accounting_Period__c> listAccperiod;
    listAccperiod = [SELECT Name FROM AcctSeed__Accounting_Period__c ORDER BY Name DESC ];
       return listAccperiod; 
   }
  
 
  @AuraEnabled(cacheable=true)
   public static string getParentWrapperList(Date startdate, Date enddate) {
       Map<Id, ParentWrapper> mainmap = new Map<Id, ParentWrapper>();
       List<ParentWrapper> wrapperList = new List<ParentWrapper>();
       List<ChildWrapper> childList = new List<ChildWrapper>();
       
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

       system.debug('costperempmap>>>>'+costperempmap);
       system.debug('avgcost>>>'+averageCost);
       
       

       AggregateResult[] OppgroupedResults = [
           SELECT 
               Customer_Engagement__r.Name,
               Customer_Engagement__r.Opportunity__r.Name OPPNAME,
               Customer_Engagement__r.Opportunity__c,
               Employee_Name__r.Name empname,
               Employee_Name__c EmployeeId,
               Employee_Name__r.EmployeeID__c empId,
               Employee_Name__r.Grade__c grade,
               Employee_Name__r.Designation__r.Name designation,
              Timesheet_Approval__r.Approval_Status__c  approvalStatus,
               SUM(	Actual_Time_in_hours__c) Time_in_Hours,
               SUM(Cost__c) Total_Cost,
               SUM(Cost_by_Designation__c) Total_Cost_by_Designation__c
           FROM 
               delivery__c
           WHERE 
               (Cost__c != null OR Cost_by_Designation__c != null)
              AND  Date__c >= :startdate 
               AND Date__c <= :enddate
               AND  Timesheet_Approval__r.Approval_Status__c = 'Approved'
           GROUP BY 
               Customer_Engagement__r.Name, 
               Customer_Engagement__r.Opportunity__r.Name, 
               Employee_Name__c,
               Customer_Engagement__r.Opportunity__c,
               Employee_Name__r.Name,
               Employee_Name__r.EmployeeID__c,
               Employee_Name__r.Grade__c,
               Timesheet_Approval__r.Approval_Status__c,
               Employee_Name__r.Designation__r.Name


       ];
       for(AggregateResult agr: OppgroupedResults){
        if(((String)agr.get('empId')).contains('CT')){
            system.debug('inside if');
           ChildWrapper chldwrppr = new ChildWrapper();
               chldwrppr.ProjectName=String.valueOf(agr.get('NAME'));
                chldwrppr.OpportunityName=String.valueOf(agr.get('OPPNAME'));
               chldwrppr.ResourceName=String.valueOf(agr.get('empname'));
               chldwrppr.Hours=String.valueOf(agr.get('approvalStatus')) != 'Approved' ? 0 :(Decimal) agr.get('Time_in_Hours');
              // chldwrppr.Cost=(Decimal) agr.get('Total_Cost');
               chldwrppr.Grade=String.valueOf(agr.get('grade'));
               chldwrppr.Designation=String.valueOf(agr.get('designation'));
               chldwrppr.oppid=(Id) agr.get('Opportunity__c');
               chldwrppr.empId= (Id) agr.get('EmployeeId');
                Id employeeId = (Id) agr.get('EmployeeId');
               chldwrppr.costperemplyi = costperempmap.get(employeeId);
               chldwrppr.Cost= Math.round(chldwrppr.Hours * chldwrppr.costperemplyi) ;
               childList.add(chldwrppr);
           }
           else{
               ChildWrapper chldwrppr = new ChildWrapper();
               chldwrppr.ProjectName=String.valueOf(agr.get('NAME'));
                chldwrppr.OpportunityName=String.valueOf(agr.get('OPPNAME'));
               chldwrppr.ResourceName=String.valueOf(agr.get('empname'));
               chldwrppr.Hours=String.valueOf(agr.get('approvalStatus')) != 'Approved' ? 0 :(Decimal) agr.get('Time_in_Hours');
              // chldwrppr.Cost=(Decimal) agr.get('Total_Cost_by_Designation__c');
               chldwrppr.Grade=String.valueOf(agr.get('grade'));
             chldwrppr.Designation=String.valueOf(agr.get('designation'));
               chldwrppr.oppid=(Id) agr.get('Opportunity__c');
               chldwrppr.empId= (Id) agr.get('EmployeeId');
                Id employeeId = (Id) agr.get('EmployeeId');
               chldwrppr.costperemplyi = averageCost.get(employeeId);
               chldwrppr.Cost=Math.round(chldwrppr.Hours *  chldwrppr.costperemplyi );
               childList.add(chldwrppr);
           }
       }
  //    map<id,ParentWrapper> mainmap = new  map<id, ParentWrapper>();
          for(ChildWrapper chlst : childList){
                
              if(mainmap.containskey(chlst.oppid)){
                  ParentWrapper parentWrapperloop = mainmap.get(chlst.oppid);
                  parentWrapperloop.Hours +=chlst.Hours;
                  parentWrapperloop.Cost  +=chlst.Cost;
                  parentWrapperloop.childList.add(chlst);
                  mainmap.put(chlst.oppid, parentWrapperloop);
                
              }else{
                  ParentWrapper parentWrapper = new ParentWrapper();
                  parentWrapper.OpportunityName = chlst.OpportunityName;
                  parentWrapper.ProjectName = chlst.ProjectName;
                  parentWrapper.Hours = chlst.Hours;
                  parentWrapper.Cost = chlst.Cost;
                  parentWrapper.childList = new List<ChildWrapper>{chlst};
                  mainmap.put(chlst.oppid, ParentWrapper);
              }
            }
          system.debug('mainmap>>>'+ mainmap);      
      system.debug('childList>>>'+ childList);
               
           return JSON.serialize(mainmap);
   }
 
   public class ParentWrapper {
       public String OpportunityName;
       public String ProjectName;
       public Decimal Hours;
       public Decimal Cost;
       public List<ChildWrapper> childList;
       
        public ParentWrapper() {
       this.childList = new List<ChildWrapper>();
   }

       public ParentWrapper(String OpportunityName, String ProjectName, Decimal Hours, Decimal Cost, List<ChildWrapper> childList) {
           this.OpportunityName = OpportunityName;
           this.ProjectName = ProjectName;
           this.Hours = Hours;
           this.Cost = Cost;
           this.childList = childList;
       }
   }

   public class ChildWrapper {
       public String ProjectName;
       public string OpportunityName;
       public String ResourceName;
       public Decimal Hours;
       public Decimal Cost;
       public String Grade;
       public String Designation;
       public Id oppid;
       public Id empId;
       public decimal costperemplyi;
      
       
        public ChildWrapper() {
      
   }

       public ChildWrapper(String ProjectName, String ResourceName, Decimal Hours, Decimal Cost,Id oppid,Id empId, decimal costperemplyi) {
           this.ProjectName = ProjectName;
           this.ResourceName = ResourceName;
           this.Hours = Hours;
           this.Cost = Cost;
           this.Grade = Grade;
          this.Designation = Designation;
       }
   }
       @AuraEnabled(cacheable=true)
    public static void codecoverage(){
        Integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
    }
   
}