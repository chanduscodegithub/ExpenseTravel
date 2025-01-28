/*
* Description primary purpose is to share Case records with Manual sharing to community users.
*/
trigger TicketManagement on Case (after insert, after update) {
    
    
   /* SWITCH on Trigger.operationType{
        WHEN AFTER_UPDATE {
            ManualSharingHandler.caseSharingRules(trigger.newMap);
        }
        WHEN AFTER_INSERT {
            ManualSharingHandler.caseSharingRules(trigger.newMap);
        }
    }  */
    
    // Ticket assigned owner
    
    List<Case> CaseList = new List<Case>();
    public static Boolean isFirstTime = true;
    for(Case currCase : Trigger.New)
    {
        if((Trigger.isInsert && Trigger.isAfter) && isFirstTime )
        {
            isFirstTime=false;
            CaseList.add(new Case(id = currCase.id));
        }
        /*else if((Trigger.isUpdate && Trigger.isAfter) && isFirstTime)
        {
            isFirstTime=false;
            caseList.add(new Case(id = currCase.Id));
        }*/
    }
    AssignmentRule AR = [select id from AssignmentRule where SobjectType = 'Case' and Active = true  limit 1];
    Database.DMLOptions dmo = new Database.DMLOptions();
    dmo.assignmentRuleHeader.assignmentRuleId = AR.Id;
    Database.update(CaseList, dmo);
    
    // sharing ticket management record with approver
    
    /*List<CaseShare> csShareList = new List<CaseShare>();
      for(Case cs:trigger.new){
      if(cs.Employee_Manager__c!=Null){
      CaseShare csShare = new CaseShare();
      csShare.CaseAccessLevel = 'Read';
      csShare.CaseId = cs.id;
      csShare.UserOrGroupId = cs.Employee_Manager__c;
      csShare.RowCause='Manual';
      csShareList.add( csShare );
     }
   }
      insert csShareList;   */
    
    
}