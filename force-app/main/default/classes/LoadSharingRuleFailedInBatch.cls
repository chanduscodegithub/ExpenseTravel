public class LoadSharingRuleFailedInBatch {
    public static void loadBatch(){
        List<Attendance__c> attendenceRecords = [SELECT id, Name,Employee__r.SF_User__c,Employee__r.ReportingTo__r.SF_User__c,Employee__r.Name,Date__c,Duration_In_Hour_and_Minutes__c,(SELECT Id,UserOrGroupId,UserOrGroup.Name FROM Shares) FROM Attendance__c Where (Date__c > 2024-01-04 and Date__c <= 2024-01-12) and Employee__r.SF_User__r.IsActive != false];
        
        List<Attendance__Share> allShare = new List<Attendance__Share>();
        
        String leaderCRMIT = [SELECT Id FROM Group WHERE Name = 'LeaderShip'][0]?.Id;
        String hrGroupId = [SELECT Id FROM Group WHERE Name = 'HR Team'][0]?.Id;
        
        for(Attendance__c sharingAtd : attendenceRecords){
            
            if(sharingAtd.Shares.size() == 1 && sharingAtd.Shares[0].UserOrGroup.Name == 'IT Team'){
                if(sharingAtd.Employee__r.ReportingTo__r.SF_User__c != null){
                    Attendance__Share atdShareRM = new Attendance__Share();
                    atdShareRM.ParentId = sharingAtd.id;
                    atdShareRM.UserOrGroupId = sharingAtd.Employee__r.ReportingTo__r.SF_User__c;
                    atdShareRM.AccessLevel = 'Read';
                    atdShareRM.RowCause = 'Manual';
                    allShare.add(atdShareRM);
                }
                
                Attendance__Share atdShareEmp = new Attendance__Share();
                atdShareEmp.ParentId = sharingAtd.id;
                atdShareEmp.UserOrGroupId = sharingAtd.Employee__r.SF_User__c;
                atdShareEmp.AccessLevel = 'Read';
                atdShareEmp.RowCause = 'Manual';
                allShare.add(atdShareEmp);
                
                Attendance__Share atdShareLeaders = new Attendance__Share();
                atdShareLeaders.ParentId = sharingAtd.id;
                atdShareLeaders.UserOrGroupId = leaderCRMIT;
                atdShareLeaders.AccessLevel = 'Read';
                atdShareLeaders.RowCause = 'Manual';
                allShare.add(atdShareLeaders);
                
                Attendance__Share atdShareHR = new Attendance__Share();
                atdShareHR.ParentId = sharingAtd.id;
                atdShareHR.UserOrGroupId = hrGroupId;
                atdShareHR.AccessLevel = 'Read';
                atdShareHR.RowCause = 'Manual';
                allShare.add(atdShareHR);
            }  
        }
        
        if(allShare.size() > 0){
            insert allShare;
            System.debug('allShare::::'+allShare);
        }
    }
}