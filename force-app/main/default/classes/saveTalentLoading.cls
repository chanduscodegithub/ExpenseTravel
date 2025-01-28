public class saveTalentLoading {
    /*Id recordId = 'a2YDX000000kdIF2AY';
//system.debug('object::'+recordId.getSObjectType());*/
    
    public class MyCustomException extends Exception {}
    
    @AuraEnabled(cacheable=true)
    public static Boolean getUserInfo(){
        
        List<Employee__c> empRec = [select id,Access_To_Talent_Loading__c from Employee__c where SF_User__c =: UserInfo.getUserId() and Status__c = 'Active' limit 1];
        
        /*Set<String> profileNameList = new Set<String>{'Partner Community Login User_Manager','FNA','System Administrator'};
            
        Id profileId=userinfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;*/
        
        if(empRec.size() > 0 && empRec[0].Access_To_Talent_Loading__c == true){
            return false;
        }
        
        return true;

    }
    
    @AuraEnabled(cacheable=true)
    public static String getRecordId(String recId){
        try{
            if(Id.valueOf(recId).getSObjectType().getDescribe().getName() == 'Opportunity'){
                List<Project__c> cusEngagement= [Select Id from Project__c where Opportunity__c =: recId limit 1];
                return cusEngagement.size() > 0 ? cusEngagement[0].Id : 'no record found';
            }
        }catch(Exception e){
            System.debug('exp::'+e);
        }
        return null;
    }
    
    @AuraEnabled
    public static void createTalentRecords(String talentLoadingRecords, String talentLoadingLineRecords, String engId, Date start, Date endd){
        
        if(Id.valueOf(engId).getSObjectType().getDescribe().getName() == 'Opportunity'){
            engId = [Select Id from Project__c where Opportunity__c =: engId limit 1].Id;
        }
        
        Project__c engagement = [Select Id,isTalentLoad__c,TalentloadVersion__c,Talent_Frequency__c from Project__c where Id =: engId];
        ////system.debug('talentLoading'+talentLoadingRecords);
        ////system.debug('talentLoadingLine'+talentLoadingLineRecords);
        ////system.debug('talentLoadingLine'+formdata);
        engagement.isTalentLoad__c = true;
        if(engagement.TalentloadVersion__c == null){
            engagement.TalentloadVersion__c = 0;
        }
        
        engagement.TalentloadVersion__c += 1;
        update engagement;
        List<talentload> talentLoadingList = (List<talentload>)System.JSON.deserialize(talentLoadingRecords,List<talentload>.class);
        ////system.debug('talentLoadingList'+talentLoadingList);
        List<talentloadchild> talentLoadingLines = (List<talentloadchild>)System.JSON.deserialize(talentLoadingLineRecords,List<talentloadchild>.class);
        ////system.debug('talentLoadingLineList'+talentLoadingLines);
        
        List<Talent_Loading__c> tlaodList=new List<Talent_Loading__c>();
        List<Talent_Loading_Line__c> tlaodlineList=new List<Talent_Loading_Line__c>();
        for(talentload tl:talentLoadingList){
            Talent_Loading__c tlo= new Talent_Loading__c();
            tlo.Engagement__c = engId;
            tlo.Role__c=tl.role;
            tlo.Location__c=tl.location;
            tlo.Version__c = engagement.TalentloadVersion__c;
            tlo.StartDate__c = start;
            tlo.EndDate__c = endd;
            tlaodList.add(tlo);
        }
        
        insert tlaodList;
        //system.debug('tlaodList>>'+tlaodList);
        
        
        for(integer i=0;i<tlaodList.size();i++){
            for(talentloadchild tchild:talentLoadingLines){
                if(i == tchild.indexes){
                    Talent_Loading_Line__c tlo= new Talent_Loading_Line__c();
                    tlo.Talent_Loading__c=tlaodList[i].Id;
                    if(engagement.Talent_Frequency__c == 'Monthly'){
                        tlo.Month__c=tchild.months;
                    }
                    else{
                        tlo.Week__c=tchild.months;
                    }
                    
                    tlo.Hour__c=tchild.hours;
                    tlaodlineList.add(tlo);
                }
            }
        }
        insert tlaodlineList;
        //system.debug('tlaodlineList>>'+tlaodlineList);
        
        
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Talent_Loading__c> getTalentLoadings(Id recId) {
        if(Id.valueOf(recId).getSObjectType().getDescribe().getName() == 'Opportunity'){
            recId = [Select Id from Project__c where Opportunity__c =: recId limit 1].Id;
        }
        
        Project__c proj = [SELECT Id, isTalentLoad__c, TalentloadVersion__c FROM Project__c WHERE Id = :recId];
        List<Talent_Loading__c> talentRecords = new List<Talent_Loading__c>();
        
        if (proj.isTalentLoad__c == true) {
            talentRecords = [
                SELECT Id, Version__c, Role__c, Location__c,
                (SELECT Id, Week__c, Month__c, Hour__c FROM Talent_Loading_Lines__r)
                FROM Talent_Loading__c
                WHERE Engagement__c = :recId AND Version__c = :proj.TalentloadVersion__c
            ];
            
            for (Talent_Loading__c talentRecord : talentRecords) {
                for (Talent_Loading_Line__c talentLine : talentRecord.Talent_Loading_Lines__r) {
                    if (talentLine.Hour__c == null) {
                        talentLine.Hour__c = 0;
                    }
                }
            }
        }
        
        return talentRecords;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<TeamAllocation__c> getTeamAllocations(Id projId) {
        // Retrieve and return the TeamAllocation records
        if(Id.valueOf(projId).getSObjectType().getDescribe().getName() == 'Opportunity'){
            projId = [Select Id from Project__c where Opportunity__c =: projId limit 1].Id;
        }
        
        
        List<TeamAllocation__c> record =  [SELECT Id, Talent_Loading__c, (SELECT Id FROM Delivery_Team_Timesheets__r) FROM TeamAllocation__c WHERE Project__c =: projId];
        return record;
    }
    @AuraEnabled(cacheable=true)
    public static Project__c getProject(Id recordId) {
        
        if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'Opportunity'){
            recordId = [Select Id from Project__c where Opportunity__c =: recordId limit 1].Id;
        }
        
        Project__c record = [SELECT Id, Name, isTalentLoad__c,Talent_Frequency__c,TalentloadVersion__c, StartDate__c, EndDate__c from Project__c where Id =: recordId];
        return record;
    }
    @AuraEnabled(cacheable=true)
    public static String getProjectType(Id recordId) {
        
        if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'Opportunity'){
            recordId = [Select Id from Project__c where Opportunity__c =: recordId limit 1].Id;
        }
        
        Project__c record = [SELECT Type__c FROM Project__c WHERE Id = :recordId];
        Schema.DescribeFieldResult fieldResult = Project__c.Type__c.getDescribe();
        List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry picklistEntry : picklistValues) {
            if (picklistEntry.getValue().equals(record.Type__c)) {
                return picklistEntry.getLabel();
            }
        }
        
        return null;
    }
    @AuraEnabled(cacheable=true)
    public static Decimal getCustomSettingValue() {
        TL_default_rows__c customSetting = TL_default_rows__c.getValues('rows');
        if (customSetting != null) {
            return customSetting.default_rows__c;
        }
        return null;
    }
    
    @AuraEnabled
    public static void updateTalentFrequency(String recordId, String talentFrequency) {
        
        if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'Opportunity'){
            recordId = [Select Id from Project__c where Opportunity__c =: recordId limit 1].Id;
        }
        
        Project__c project = [SELECT Id, Name,Talent_Frequency__c,TalentloadVersion__c,StartDate__c, EndDate__c from Project__c where Id =: recordId];
        project.Talent_Frequency__c = talentFrequency;
        update project;
        
    }
    
    @AuraEnabled
    public static void updateTalentFrequencyToZero(String recordId) {
        if(Id.valueOf(recordId).getSObjectType().getDescribe().getName() == 'Opportunity'){
            recordId = [Select Id from Project__c where Opportunity__c =: recordId limit 1].Id;
        }
        
        Project__c project = [SELECT Id, Name,Talent_Frequency__c,TalentloadVersion__c,StartDate__c, EndDate__c from Project__c where Id =: recordId];
        project.Talent_Frequency__c = null;
        update project;
        
    }
    @AuraEnabled
    public static void deleteTalentLoadings(Id projectId) {
        
        if(Id.valueOf(projectId).getSObjectType().getDescribe().getName() == 'Opportunity'){
            projectId = [Select Id from Project__c where Opportunity__c =: projectId limit 1].Id;
        }
        
        Project__c project = [SELECT Id,Talent_Frequency__c,TalentloadVersion__c, isTalentLoad__c from Project__c where Id =: projectId];
        
        List<Talent_Loading__c> talentLoadings = [SELECT Id FROM Talent_Loading__c WHERE Engagement__c = :projectId];
        
        if (!talentLoadings.isEmpty()) {
            delete talentLoadings;
        }
        project.TalentloadVersion__c = 0;
        project.isTalentLoad__c = false;
        project.Talent_Frequency__c = null;
        update project;
        
    }
    
    @AuraEnabled
    public static void deleteTalentLoadingsTeamAlloc(Id projectId) {
        
        if(Id.valueOf(projectId).getSObjectType().getDescribe().getName() == 'Opportunity'){
            projectId = [Select Id from Project__c where Opportunity__c =: projectId limit 1].Id;
        }
        
        Project__c project = [SELECT Id,Talent_Frequency__c,TalentloadVersion__c, isTalentLoad__c from Project__c where Id =: projectId];
        
        List<Talent_Loading__c> talentLoadings = [SELECT Id FROM Talent_Loading__c WHERE Engagement__c = :projectId];
        
        if (!talentLoadings.isEmpty()) {
            // Get the related Team Allocations
            List<TeamAllocation__c> teamAllocations = [SELECT Id FROM TeamAllocation__c WHERE Talent_Loading__c IN :talentLoadings];
            
            // Delete the Talent Loadings and the related Team Allocations
            delete talentLoadings;
            delete teamAllocations;
        }
        project.TalentloadVersion__c = 0;
        project.isTalentLoad__c = false;
        project.Talent_Frequency__c = null;
        update project;
        
    }
    
    
    public class talentload{
        @AuraEnabled public String role;
        @AuraEnabled public string location;
    }
    
    public class talentloadchild{
        @AuraEnabled public Integer indexes;
        @AuraEnabled public String months;
        @AuraEnabled public Decimal hours;
    }
    
    
}