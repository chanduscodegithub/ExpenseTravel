trigger LeadAssignment on Lead (after insert ,after update) {
    List<Lead> LeadList = new List<Lead>();
    public static Boolean isFirstTime = true;
     for(Lead currLead : Trigger.New)
     {
         if((Trigger.isInsert && Trigger.isAfter) && isFirstTime )
         {
             isFirstTime=false;
             LeadList.add(new Lead(id = currLead.id));
         }
         else if((Trigger.isUpdate && Trigger.isAfter) && isFirstTime)
         {
             isFirstTime=false;
             LeadList.add(new Lead(id = currLead.Id));
         }
     }
    AssignmentRule AR = [select id from AssignmentRule where SobjectType = 'Lead' and Active = true  limit 1];
    Database.DMLOptions dmo = new Database.DMLOptions();
    dmo.assignmentRuleHeader.assignmentRuleId = AR.Id;
    Database.update(LeadList, dmo);

}