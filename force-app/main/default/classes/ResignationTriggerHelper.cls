public class ResignationTriggerHelper {
    public static void beforeInsert(List<Resignation__c> res){
        /*for(Resignation__c eachRes : res){
            System.debug(eachRes);
        }*/
    }
    public static void beforeUpdate(List<Resignation__c> res){
        /*for(Resignation__c eachRes : res){
            
        }*/
    }
    public static void beforeUpdate(List<Resignation__c> res, Map<Id, Resignation__c> oldResMap){
        /*List<Approval.UnlockResult> urList = Approval.unlock(res);
        for(Approval.UnlockResult ur : urList) {
            if (ur.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully unlocked with ID: ' + ur.getId());
            }
            else {
                // Operation failed, so get all errors                
                for(Database.Error err : ur.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('Account fields that affected this error: ' + err.getFields());
                }
            }
        }*/
        for(Resignation__c eachRes : res){
            if(eachRes.Resignation_Status__c == 'Applied' && !oldResMap.get(eachRes.Id).Initally_Approved__c && eachRes.Initally_Approved__c && UserInfo.getUserId() == eachRes.CCM__c){
                System.debug('***Appr By CCM**');
                eachRes.Resignation_Status__c = 'Approved by CCM';
            }else if(eachRes.Resignation_Status__c == 'Applied' && !oldResMap.get(eachRes.Id).Initally_Approved__c && eachRes.Initally_Approved__c && UserInfo.getUserId() == eachRes.Reporting_Manager__c){
                System.debug('***Appr By Reporting Manager**');
                eachRes.Resignation_Status__c = 'Approved by Reporting Manager';
            }
            // Approval.lock(res);
            System.debug('____NEW VALUE___');
            System.debug(eachRes.Initally_Approved__c);
            System.debug(eachRes.Emp_Name__c);
            System.debug(eachRes.LastModifiedDate);
            System.debug(eachRes.Resignation_Status__c);
            System.debug('___OLD VALUE___');
            System.debug(oldResMap.get(eachRes.Id).Initally_Approved__c);
            System.debug(oldResMap.get(eachRes.Id).Emp_Name__c);
            System.debug(oldResMap.get(eachRes.Id).LastModifiedDate);
            System.debug(oldResMap.get(eachRes.Id).Resignation_Status__c);
        }
        // Email
        List<Messaging.SingleEmailMessage> allResigEmail = new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress owaData = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName = 'Sales++ Admin' LIMIT 1];
        for(Resignation__c eachRes : res){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            allResigEmail.add(email);
            // email.setHtmlBody(htmlBody);
            email.setSubject('Resignation Approved');
            String body = '';
            // 'Hi,\n'+eachRes.Resignation_Status__c+''
            body += 'Hi Team,\n';
            body += 'This is to inform that the resignation request raised by '+eachRes.Emp_Name__c+' has been approved';
            if(eachRes.Resignation_Status__c == 'Approved by Reporting Manager'){
                
            }else if (eachRes.Resignation_Status__c == 'Approved by CCM'){
                
            }
            
            email.setPlainTextBody(body);
            if(String.isNotBlank(owaData.Id)){
                email.setOrgWideEmailAddressId(owaData.Id);
            }else{
                
            }
            // List<String> emailAddress = new List<String>{empList[0].SF_User__r.Email };
            List<String> emailAddress = new List<String>{ 'tamanna.singh+pms@crmit.com', 'tamanna.singh+pmsemail@crmit.com'};
            email.setToAddresses(emailAddress);
        }
        if(!Test.isRunningTest()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(allResigEmail);
            if (results[0].success) {
                System.debug('The email is successfully sent');
            }
            else{
                System.debug('The email failed to send: '+ results[0].errors[0].message);
            }
        }
    }
}