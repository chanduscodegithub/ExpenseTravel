global class PerformanceRatingQuaterLoadBatch implements Database.Batchable<sObject> {
    
    public Appraisal__c recId;
    public Set<Id> selectedEmpIds;
    public PerformanceRatingQuaterLoadBatch(){
        recId = new Appraisal__c();
        selectedEmpIds = new Set<Id>();
        String year = String.valueOf( System.today().year());
        recId = [Select Id,Current_Cycle__c from Appraisal__c where QPR_Year__c =: year];
    }
    
    public PerformanceRatingQuaterLoadBatch(Set<Id> EmpIds){
        //system.debug('hi');
        recId = new Appraisal__c();
        selectedEmpIds = new Set<Id>();
        String year = String.valueOf( System.today().year());
        recId = [Select Id,Current_Cycle__c from Appraisal__c where QPR_Year__c =: year];
        if(EmpIds.size() > 0){
            this.selectedEmpIds = EmpIds;
        }  
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        if(selectedEmpIds.size() > 0){
            return Database.getQueryLocator([Select Id,Name,ReportingTo__c,Email_ID__c from Employee__c where Id IN:selectedEmpIds]);
        }else{
            return Database.getQueryLocator([Select Id,Name,ReportingTo__c,Email_ID__c from Employee__c where Status__c = 'Active']);
        }
    }
    
    global void execute(Database.BatchableContext bc, List<Employee__c> records){  
        Set<Id> empIds = new Set<Id>();
        Set<String> empEmails = new Set<String>(); 
        Map<Id,Employee__c> EmpData= new Map<Id,Employee__c>();
        
        for(Employee__c emp : records){
            empIds.add(emp.Id);
            EmpData.put(emp.Id, emp);
            empEmails.add(emp.Email_ID__c);
        }
        
        Map<String,user> userDetails= new Map<String,user>();
        for(user usr : [select Id,Email from User where Email IN:empEmails and IsActive=true and (Profile.Name ='Partner Community Login User_Employee' or  Profile.Name ='Partner Community Login User_Manager')]){
            userDetails.put(usr.Email, usr);
        }
        
        // process each batch of records
        Map<String,List<Goal_Setting__c>> mapedDetailsOfEmp = new Map<String,List<Goal_Setting__c>>();
        Map<String,List<Performance_Rating__c>> mapedDetailsOfEmpAndPerRating = new Map<String,List<Performance_Rating__c>>();
        
        for(Goal_Setting__c goal : [Select Id,Employee__c,Employee__r.Email_ID__c,KPI_1__c,KPI_1_Weightage__c, KPI_2__c,KPI_2_Weightage__c,KPI_3__c,KPI_3_Weightage__c,KPI_4__c,KPI_4_Weightage__c,KPI_5__c,KPI_5_Weightage__c  from Goal_Setting__c where Employee__c IN:empIds and Appraisal_Cycle__c = :recId.Id]){
            if(mapedDetailsOfEmp.containsKey(goal.Employee__c)){
                mapedDetailsOfEmp.get(goal.Employee__c).add(goal);
            }else{
                mapedDetailsOfEmp.put(goal.Employee__c, new List<Goal_Setting__c>{goal});
            }
        }
        
        //System.debug('mapedDetailsOfEmp::'+mapedDetailsOfEmp);
        
        List<Performance_Rating__c> perRating = [Select Id,Name,Employee__c,Employee__r.ReportingTo__c from Performance_Rating__c where Employee__c IN: empIds and CreatedDate = THIS_YEAR];
        //System.debug('perRating::'+perRating);
		List<Performance_Rating__c> updatedperRating= new  List<Performance_Rating__c>();
        
        if(perRating.size() > 0){
            for(Performance_Rating__c pr:perRating)
            {
                Performance_Rating__c prs= new Performance_Rating__c();
                prs.Id=pr.Id;
                prs.Manager__c=pr.Employee__r.ReportingTo__c;
                prs.Status__c='Open';
                
                if(recId.Current_Cycle__c=='QPR-I')
                {
                    prs.Q1_Manager__c= pr.Employee__r.ReportingTo__c;
                }
                else if(recId.Current_Cycle__c=='QPR-II')
                {
                    prs.Q2_Manager__c=pr.Employee__r.ReportingTo__c;
                }
                else if(recId.Current_Cycle__c=='QPR-III')
                {
                    prs.Q3_Manager__c=pr.Employee__r.ReportingTo__c;
                }
                else if(recId.Current_Cycle__c=='Annual Cycle')
                {
                    prs.Q4_Manager__c=pr.Employee__r.ReportingTo__c;
                }
                updatedperRating.add(prs);
            }

            update updatedperRating;
            
            for(Performance_Rating__c per : perRating){
                if(mapedDetailsOfEmpAndPerRating.containsKey(per.Employee__c)){
                    mapedDetailsOfEmpAndPerRating.get(per.Employee__c).add(per);
                }else{
                    mapedDetailsOfEmpAndPerRating.put(per.Employee__c, new List<Performance_Rating__c>{per});
                }
            }
        }
        
        
        
        //System.debug('mapedDetailsOfEmpAndPerRating::'+mapedDetailsOfEmpAndPerRating);
        
        List<Performance_Rating__c> allPerformanceRating = new List<Performance_Rating__c>();
        List<Performance_Rating_Item__c> allPerformanceRatingItem = new List<Performance_Rating_Item__c>();
        
        for(String key : mapedDetailsOfEmp.keyset()){
            if(mapedDetailsOfEmpAndPerRating.containsKey(key) ){
                //System.debug('Hi if::');
                if(mapedDetailsOfEmp.get(key).size() > 0){
                    for(Goal_Setting__c goal : mapedDetailsOfEmp.get(key)){
                        List<Performance_Rating_Item__c> allPerformanceRatingOfGoal = PerformanceRatingItemController.loadData(goal,mapedDetailsOfEmpAndPerRating.get(key)[0].Id,recId.Current_Cycle__c);
                        allPerformanceRatingItem.addAll(allPerformanceRatingOfGoal);
                    }
                }
            }else{
                //System.debug('Hi else::');
                Performance_Rating__c perRatings = new Performance_Rating__c();
                perRatings.Appraisal_Cycle__c = recId.Id;
                perRatings.Manager__c = EmpData.get(key).ReportingTo__c;
                perRatings.Employee__c = key;
				 if(recId.Current_Cycle__c=='QPR-I')
            {
               perRatings.Q1_Manager__c= EmpData.get(key).ReportingTo__c;
            }
            else if(recId.Current_Cycle__c=='QPR-II')
            {
                perRatings.Q2_Manager__c=EmpData.get(key).ReportingTo__c;
            }
            else if(recId.Current_Cycle__c=='QPR-III')
            {
                perRatings.Q3_Manager__c=EmpData.get(key).ReportingTo__c;
            }
                else if(recId.Current_Cycle__c=='Annual Cycle')
                {
                     perRatings.Q4_Manager__c=EmpData.get(key).ReportingTo__c;
                }
                //system.debug('userDetails.get(EmpData.get(key).Email_ID__c).Id'+userDetails.get(EmpData.get(key).Email_ID__c).Id);
                //system.debug('EmpData.get(key).Email_ID__c- above'+EmpData.get(key).Email_ID__c);
                if(userDetails.containsKey(EmpData.get(key).Email_ID__c)){
                    //system.debug('EmpData.get(key).Email_ID__c'+EmpData.get(key).Email_ID__c);
                    perRatings.OwnerId= userDetails.get(EmpData.get(key).Email_ID__c).Id;
                }
                allPerformanceRating.add(perRatings);
            }
        }
        //System.debug('allPerformanceRatingItem::'+allPerformanceRatingItem);
        if(allPerformanceRatingItem.size() > 0){
            insert allPerformanceRatingItem;
            //System.debug('allPerformanceRatingItem::'+allPerformanceRatingItem);
        }
        
        allPerformanceRatingItem.clear();
        
        
        if(allPerformanceRating.size() >0){
            
            insert allPerformanceRating;
            //System.debug('allPerformanceRating::'+allPerformanceRating);
            //allPerformanceRatingItem.clear();
            
            for(Performance_Rating__c per : allPerformanceRating){
                if(mapedDetailsOfEmp.get(per.Employee__c).size() > 0){
                    for(Goal_Setting__c goal : mapedDetailsOfEmp.get(per.Employee__c)){
                        List<Performance_Rating_Item__c> allPerformanceRatingOfGoal = PerformanceRatingItemController.loadData(goal,per.Id,recId.Current_Cycle__c);
                        allPerformanceRatingItem.addAll(allPerformanceRatingOfGoal);
                    }
                }
            }
        }
        
        if(allPerformanceRatingItem.size() > 0){
            insert allPerformanceRatingItem;
            //System.debug('allPerformanceRatingItem::'+allPerformanceRatingItem);
        }
        
    }    
    
    global void finish(Database.BatchableContext bc){
        List<Batch_Emails__mdt> Batchemails= [Select Addresses__c, Email__c from Batch_Emails__mdt];
        
        List<String> toMail = new List<String>();
        List<String> ccMail = new List<String>();
        
        for(Batch_Emails__mdt email : Batchemails){
            if(email.Addresses__c == 'To'){
                toMail.add(email.Email__c);
            }else if(email.Addresses__c == 'cc'){
                ccMail.add(email.Email__c);
            }
        }
        
        AsyncApexJob a = [Select Id, Status,ExtendedStatus,NumberOfErrors, JobItemsProcessed,TotalJobItems, CreatedBy.Email from AsyncApexJob where Id =:bc.getJobId()]; 
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(toMail);
        
        mail.setCcAddresses(ccMail);
        
        mail.setSubject('PMS Batch Status Mail. The result is ' + a.Status +'and Batch Id as follows '+ a.Id);
        
        mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
                              
                              ' batches with '+ a.NumberOfErrors + ' failures.');
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
}