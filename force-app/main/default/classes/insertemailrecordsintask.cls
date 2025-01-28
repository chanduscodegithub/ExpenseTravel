public class insertemailrecordsintask {
    public static void insertresults(){
        List<et4ae5__IndividualEmailResult__c> inemail =[select id,Name,et4ae5__Contact__r.Id,et4ae5__SubjectLine__c,et4ae5__FromAddress__c,et4ae5__FromName__c,et4ae5__DateSent__c from et4ae5__IndividualEmailResult__c  where et4ae5__Contact__r.id != NULL  ];
        
        List<Task> newEmailActivities = new List<Task>();
        for (et4ae5__IndividualEmailResult__c sfmc :inemail ) {
        
    
        Task newEmailActivity = new Task();
        newEmailActivity.Subject= sfmc.et4ae5__SubjectLine__c;
        newEmailActivity.TaskSubtype = 'Email';
        newEmailActivity.WhoId = sfmc.et4ae5__Contact__r.Id;
        newEmailActivity.Status = 'Completed'; 
        newEmailActivity.Email_Name__c = sfmc.Name;
        newEmailActivity.From_Name__c= sfmc.et4ae5__FromName__c;
        newEmailActivity.From_Address__c= sfmc.et4ae5__FromAddress__c;
        newEmailActivity.ActivityDate = date.newinstance(sfmc.et4ae5__DateSent__c.year(), sfmc.et4ae5__DateSent__c.month(), sfmc.et4ae5__DateSent__c.day()); 
        
        newEmailActivities.add(newEmailActivity);
    }
    
    if (!newEmailActivities.isEmpty()) {
        insert newEmailActivities;
        // update emailcon;
    }

        
    }

}