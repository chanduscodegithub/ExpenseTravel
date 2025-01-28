public class ManualSharingHandler {
    /**
    * @author       Sayath
    * @date         2021-05-09
    * @description  Share Project and Account
    * @param        Map<Id,TeamAllocation__c> teamAllocations from which Sharing is calculated
    * @DML          inserts Project__Share and AccountShare records
    * @return       void
    */
    public static void calculateSharingRules(Map<Id,TeamAllocation__c> teamAllocationsMap){
        System.debug('the Allocation Map '+teamAllocationsMap);
        Map<Id,TeamAllocation__c> allocationsMap = new Map<Id,TeamAllocation__c>([SELECT Id, Project__c, EmployeeName__r.SF_User__c, 
                                                                                  Project__r.Account__c
                                                                                  FROM TeamAllocation__c 
                                                                                  WHERE Id IN :teamAllocationsMap.keySet()]);
        //missed Active Status
        List<Project__Share> projectShares = new List<Project__Share>();
        List<AccountShare> accountShares = new List<AccountShare>();
        for(Id alloc : teamAllocationsMap.keySet()){
            if(allocationsMap.get(alloc).EmployeeName__r.SF_User__c != null){
                Project__Share ps = new Project__Share();
                ps.ParentId = allocationsMap.get(alloc).Project__c;
                ps.UserOrGroupId = allocationsMap.get(alloc).EmployeeName__r.SF_User__c;
                ps.AccessLevel = 'Read';
                ps.RowCause = 'Manual';
                projectShares.add(ps);
                System.debug('Project_Share records '+projectShares);
                if(allocationsMap.get(alloc).Project__r.Account__c != null){
                    AccountShare accShare = new AccountShare();
                    accShare.AccountId = allocationsMap.get(alloc).Project__r.Account__c;
                    accShare.UserOrGroupId = allocationsMap.get(alloc).EmployeeName__r.SF_User__c;
                    accShare.AccountAccessLevel = 'Edit';
                    accShare.ContactAccessLevel = 'Read';
                    accShare.CaseAccessLevel = 'None';
                    accShare.OpportunityAccessLevel = 'Read';
                    accShare.RowCause = 'Manual';
                    accountShares.add(accShare);
                }
            }
        }
        try{
            if(!projectShares.isEmpty())
            Database.upsert(projectShares,false);
            if(!accountShares.isEmpty())
            Database.upsert(accountShares,false);
        }Catch(Exception e){
            system.debug('the error'+e.getMessage());
        }
    }
    
    /**
    * @author       Sayath
    * @date         2021-05-09
    * @description  Share Project and Account
    * @param        Map<Id,TeamAllocation__c> teamAllocations from which Sharing is calculated
    * @DML          inserts Support_SLA__Share records
    * @return       void
    */
    public static void sharingSupportSLA(Map<Id,Support_SLA__c> supportSLAMap){
        List<Id> accountIdList = new List<Id>();
        for(Support_SLA__c sla : supportSLAMap.values()){
            accountIdList.add(sla.Customer_Name__c);
        }
        Map<Id,Account> accountsMap = new Map<Id,Account>();
        if(!accountIdList.isEmpty()){
            accountsMap.putAll(new Map<Id,Account>([SELECT Id, Name FROM Account WHERE Id IN :accountIdList]));
        }
        List<Support_SLA__Share> slaShares = new List<Support_SLA__Share>();
        
        //get Customer Enagements realted to SUpport SLA Account
        Map<Id,Project__c> customerEngagementsMap = new Map<Id,Project__c>();
        if(!accountIdList.isEmpty()){
            for(Project__c p : [SELECT Id,Account__c,ProjectManager__c FROM Project__c 
                                WHERE Account__c IN :accountIdList ORDER BY CreatedDate  DESC]){
                                    customerEngagementsMap.put(p.Account__c, p);
                                }
        }
        //get Roles for the manager
        //This is wrong, instead of role we indivually share with Customer engagement projectmanager
        //Above approach fails when there are multiple projects with single Customer
        /*Group grp = [SELECT Id,Name,RelatedId,Type FROM Group 
                     WHERE RelatedId IN (SELECT Id FROM userRole 
                                         WHERE Name='CRMIT Partner Manager') and type='Role'];*/
        
        
        for(Support_SLA__c sla : supportSLAMap.values()){
            if(customerEngagementsMap.containsKey(sla.Customer_Name__c)){
                Support_SLA__Share slaShare = new Support_SLA__Share();
                slaShare.parentId = sla.Id;
                slaShare.UserorGroupId = customerEngagementsMap.get(sla.Customer_Name__c).Id;
                slaShare.RowCause = 'Manual';
                slaShare.AccessLevel = 'Edit';
                slaShares.add(slaShare);
            }
        }
        if(!slaShares.isEmpty()){
            try{
                Database.upsert(slaShares,false);
            }Catch(Exception e){
                system.debug('the error'+e.getMessage());
            }
        }
    }
    /**
    * @author       Sayath
    * @date         2021-05-09
    * @description  Share Project and Account
    * @param        Map<Id,Case> Case from which Sharing is calculated
    * @DML          inserts CaseShare records
    * @return       void
    */
 /*   public static void caseSharingRules(Map<Id,Case> casesMap){
        Map<Id,Case> queryCaseMap = new Map<Id,Case>([SELECT Id, Opportunity_Engagement_Name__r.ProjectManager__c 
                                                      FROM Case 
                                                      WHERE Id IN :casesMap.keySet() AND Opportunity_Engagement_Name__c != null]);
        List<CaseShare> caseShareList = new List<CaseShare>();
        for(Case newCase : queryCaseMap.values()){
            CaseShare newCaseShare = new CaseShare();
            newCaseShare.CaseId = newCase.Id;
            newCaseShare.UserOrGroupId = queryCaseMap.get(newCase.Id).Opportunity_Engagement_Name__r.ProjectManager__c;
            newCaseShare.RowCause = 'Manual';
            newCaseShare.CaseAccessLevel = 'Edit';
            caseShareList.add(newCaseShare);
        }
        if(!caseShareList.isEmpty()){
            try{
                Database.upsert(caseShareList,false);
            }Catch(Exception e){
                system.debug('the error'+e.getMessage());
            }
        }
    }*/
     /**
    * @author       Sayath
    * @date         2021-05-19
    * @description  Share Project's Account with Project Manager
    * @param        newMap : Map<Id,Project__c> map of Project to be shared
    * @param        oldMap : Map<Id,Project__c> map of Project to be shared in case of change in Project Manager
    * @DML          inserts Project__Share records
    * @return       void
    */
    public static void shareProjectAccountWithManager(Map<Id,Project__c> newMap, Map<Id,Project__c> oldMap){
        Set<Id> projectsToShare = new Set<Id>();
        List<AccountShare> accountShares = new List<AccountShare>();
        List<Project__Share> projectShares = new List<Project__Share>();
        if(!(oldMap == null)){//if old map not NULL check if the Project manager is changed
            for(Id projectId : oldMap.keySet()){
                if(newMap.get(projectId).ProjectManager__c != oldMap.get(projectId).ProjectManager__c){
                    projectsToshare.addAll(newMap.keySet());
                }
            }
        }else{
            projectsToshare.addAll(newMap.keySet());
        }
        System.debug('the share records'+projectsToshare);
        if(!projectsToshare.isEmpty()){
            //then share the account to Project Manager
            for(Id projectId : projectsToshare){
                Project__c project = newMap.get(projectId);
                AccountShare accShare = new AccountShare();
                accShare.AccountId = project.Account__c;
                accShare.UserOrGroupId = project.ProjectManager__c;
                accShare.AccountAccessLevel = 'Edit';
                accShare.ContactAccessLevel = 'None';
                accShare.CaseAccessLevel = 'Edit';
                accShare.OpportunityAccessLevel = 'None';
                accShare.RowCause = 'Manual';
                accountShares.add(accShare);
                
                Project__Share ps = new Project__Share();
                ps.ParentId = project.Id;
                ps.UserOrGroupId = project.ProjectManager__c;
                ps.AccessLevel = 'Edit';
                ps.RowCause = 'Manual';
                projectShares.add(ps);
            }
        }
        system.debug('shares '+accountShares);
        system.debug('shares '+projectShares);
        try{
            if(!projectShares.isEmpty())
            Database.upsert(projectShares,false);
            if(!accountShares.isEmpty())
            Database.upsert(accountShares,false);
        }Catch(Exception e){
            system.debug('the error'+e.getMessage());
        }
    }
}