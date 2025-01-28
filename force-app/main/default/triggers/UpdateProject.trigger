trigger UpdateProject on Timesheet_Approval__c (after update) {

   // map<id,map<id,decimal>> projIdempIdhrspent=new map<id,map<id,decimal>>();
   Id tsaId;
   Id CE;
   String CEName;
   Id EmpId;
   Id timesheetId;
   Decimal costperhr=0.00;
   Decimal totalhrsspent=0.00;
    
   for(Timesheet_Approval__c tsa:trigger.new){
       if(tsa.Approval_Status__c=='Approved'){
         //  map<id,decimal> empIdhrspent=new Map<Id,Decimal>{tsa.OwnerId =>tsa.Total_Hours__c};
          // projIdempIdhrspent.put(tsa.Customer_Engagement__c,empIdhrspent);
          tsaId = tsa.Id;
          CE = tsa.Customer_Engagement__c;
          CEName = tsa.Customer_Engagement__r.Name;
          totalhrsspent += tsa.Total_Hours__c;
          EmpId=tsa.Employee__c;
          timesheetId=tsa.Timesheet__c;
           }
    }
    if(tsaId!=null){
        TeamAllocation__c ta =new TeamAllocation__c();
        List<Project__c> pro=[select id,Name from Project__c where id=:CE];
        if(pro.size()>0 && pro[0].Name == 'Others')
        {
         ta=[select Id,Name,RatePerHour__c,EmployeeName__c,EmployeeName__r.Cost_per_Hour__c,Project__c,Active__c from TeamAllocation__c where EmployeeName__c=:EmpId and Project__c=:CE LIMIT 1];
        }
        else{
          	Timesheet_Utils__c timeutil=[Select Id,Timesheet__c,Team_Allocation__c from Timesheet_Utils__c where Timesheet__c=:timesheetId and Team_Allocation__r.Project__c=:CE LIMIT 1];
            ta=[select Id,Name,RatePerHour__c,EmployeeName__c,EmployeeName__r.Cost_per_Hour__c,Project__c,Active__c from TeamAllocation__c where EmployeeName__c=:EmpId and Project__c=:CE and Id=:timeutil.Team_Allocation__c];
        }
        
    if(ta.EmployeeName__r.Cost_per_Hour__c!=null)
    costperhr +=ta.EmployeeName__r.Cost_per_Hour__c;
   //if(ta.RatePerHour__c!=null)
  // costperhr +=ta.RatePerHour__c;
    
    Project__c proj=[select id,Total_Cost__c,Total_Hours__c from Project__c where Id=:CE];
    if(proj.Total_Cost__c==null){proj.Total_Cost__c=0.00;}
    proj.Total_Cost__c +=  totalhrsspent * costperhr;
    if(proj.Total_Hours__c==null){proj.Total_Hours__c=0.00;}
    proj.Total_Hours__c += totalhrsspent;
    update proj;
     }
}