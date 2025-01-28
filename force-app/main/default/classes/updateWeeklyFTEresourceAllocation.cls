global class updateWeeklyFTEresourceAllocation implements Database.Batchable<sObject> {
    private Integer weekNumberInMonth = null;
    private String month = null;
    private String year = null;
    final static Date CURRENTDAY = System.today() - 1;
    
    public updateWeeklyFTEresourceAllocation(){
        DateTime currentDate = System.now() - 1;
        
        Integer dayOfMonth = currentDate.day();
        
        Integer dayOfWeek = Integer.valueOf(currentDate.format('u'));
        
        this.weekNumberInMonth = (dayOfMonth + (8 - dayOfWeek)) / 7;
        this.month = currentDate.format('MMMM');
        this.year = String.valueOf(currentDate.year());
        
        if (weekNumberInMonth == 0) {
            currentDate = currentDate.addDays(-dayOfMonth);
            dayOfMonth = currentDate.day();
            dayOfWeek = Integer.valueOf(currentDate.format('u'));
            this.weekNumberInMonth = (dayOfMonth + (8 - dayOfWeek)) / 7;
            this.month = currentDate.format('MMMM');
            this.year = String.valueOf(currentDate.year());
        }
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([SELECT Id, Billable_Week1_FTE__c, Billable_Week2_FTE__c, Billable_Week3_FTE__c, Billable_Week5_FTE__c, Billable_Week4_FTE__c, Shadow_Week1_FTE__c, Shadow_Week2_FTE__c, Shadow_Week3_FTE__c, Shadow_Week4_FTE__c, Shadow_Week5_FTE__c, Project_Name__c, Month__c, Year__c FROM FTE__c where Year__c =: year and Month__c =:month]);
    }
    
    global void execute(Database.BatchableContext BC, List<FTE__c> FTEList){
        try{
            List<String> projectIds = new List<String>();
            
            for(FTE__c fte : FTEList){
                projectIds.add(fte.Project_Name__c);
            }
            
            //List<TeamAllocation__c> teamAllocation = ;
            Map<String,List<TeamAllocation__c>> projectAllocation = new Map<String,List<TeamAllocation__c>>();
            
            for(TeamAllocation__c team : [SELECT Id,Name,Project__c,Billing_Status__c,EmployeeName__c,AllocationPercentage__c FROM TeamAllocation__c where StartDate__c <=: CURRENTDAY AND EndDate__c >=: CURRENTDAY and Project__c IN:projectIds]){
                if(projectAllocation.containsKey(team.Project__c)){
                    projectAllocation.get(team.Project__c).add(team);
                }else{
                    projectAllocation.put(team.Project__c,new List<TeamAllocation__c>{team});
                }
            }
            
            List<FTE__c> updateFTEWeekAllocation = new List<FTE__c>();
            for(FTE__c fte : FTEList){
                Decimal billableResource = 0;
                Decimal shadowResource = 0;
                if(projectAllocation.containsKey(fte.Project_Name__c)){
                    for(TeamAllocation__c teamAllocation : projectAllocation.get(fte.Project_Name__c)){
                        if(teamAllocation.Billing_Status__c == 'Billable'){
                            billableResource += (teamAllocation.AllocationPercentage__c/100);
                        }else if(teamAllocation.Billing_Status__c == 'Shadow Dev'){
                            shadowResource += (teamAllocation.AllocationPercentage__c/100);
                        }
                    }
                    
                    switch on weekNumberInMonth{
                        when 1{
                            FTE__c fteAllocation = new FTE__c();
                            fteAllocation.Id = fte.Id;
                            fteAllocation.Billable_Week1_FTE__c = billableResource;
                            fteAllocation.Shadow_Week1_FTE__c = shadowResource;
                            updateFTEWeekAllocation.add(fteAllocation);
                        }when 2{
                            FTE__c fteAllocation = new FTE__c();
                            fteAllocation.Id = fte.Id;
                            fteAllocation.Billable_Week2_FTE__c = billableResource;
                            fteAllocation.Shadow_Week2_FTE__c = shadowResource;
                            updateFTEWeekAllocation.add(fteAllocation);  
                        }when 3{
                            FTE__c fteAllocation = new FTE__c();
                            fteAllocation.Id = fte.Id;
                            fteAllocation.Billable_Week3_FTE__c = billableResource;
                            fteAllocation.Shadow_Week3_FTE__c = shadowResource;
                            updateFTEWeekAllocation.add(fteAllocation); 
                        }when 4{
                            FTE__c fteAllocation = new FTE__c();
                            fteAllocation.Id = fte.Id;
                            fteAllocation.Billable_Week4_FTE__c = billableResource;
                            fteAllocation.Shadow_Week4_FTE__c = shadowResource;
                            updateFTEWeekAllocation.add(fteAllocation); 
                        }when 5{
                            FTE__c fteAllocation = new FTE__c();
                            fteAllocation.Id = fte.Id;
                            fteAllocation.Billable_Week5_FTE__c = billableResource;
                            fteAllocation.Shadow_Week5_FTE__c = shadowResource;
                            updateFTEWeekAllocation.add(fteAllocation);
                        }
                    }
                }
            }
            
            if(updateFTEWeekAllocation.size() > 0){
                update updateFTEWeekAllocation;
            }
            
            
        }catch(Exception e){
            Log__c log = new Log__c(Method_Name__c='updateWeeklyFTEresourceAllocation', Class_Name__c='updateWeeklyFTEresourceAllocation', Line_Number__c=e.getLineNumber(), Reason__c=e.getMessage());
            insert log;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        Log__c log = new Log__c(Method_Name__c='updateWeeklyFTEresourceAllocation', Class_Name__c='updateWeeklyFTEresourceAllocation', Reason__c='Batch Id as Follows '+BC.getJobId());
        insert log;
    }
}