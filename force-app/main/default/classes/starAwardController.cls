public without sharing class starAwardController {
    public static String getUserRecords(){
        List<User> lstOfUser = new List<User>();
        String currentUser = UserInfo.getuserid();
        String allowedProfile = Label.Star_PartnerCommunityProfile;
        String userQuery ='SELECT Id, Name, Email, Profile.Name, isActive FROM User ' +
                        ' WHERE isActive=true and Id!= \''+currentUser +'\''+
            			' and Profile.Name in ('+ allowedProfile +') order by Name';
        lstOfUser=Database.query(userQuery);
        return JSON.serialize(lstOfUser);        
    }

    public static String getEmailGroupRecords(){
        List<Star_EmailGroups__mdt> lstOfUser = new List<Star_EmailGroups__mdt>();
        String allowedProfile = Label.Star_PartnerCommunityProfile;
        String userQuery ='SELECT Id, Name__c, Email__c FROM Star_EmailGroups__mdt ' ;
        lstOfUser=Database.query(userQuery);
        return JSON.serialize(lstOfUser);        
    }

    @AuraEnabled
    public static String getInformSuggestionsDetails() {
        // Get the current user's ID
        String currentUser = UserInfo.getUserId();

        try {
            // Query to get StarAwardsInformToSuggestions__c
            Employee__c employeeRecord = [
                SELECT StarAwardsInformToSuggestions__c
                FROM Employee__c
                WHERE SF_User__c = :currentUser
                LIMIT 1
            ];

            System.debug('employeeRecord'+employeeRecord);

            List<String> idsOfInformUserAndGroups = new List<String>();
            if (String.isNotBlank(employeeRecord.StarAwardsInformToSuggestions__c)) {
                idsOfInformUserAndGroups = employeeRecord.StarAwardsInformToSuggestions__c.split(',');
            }

            // If no IDs, return an empty list
            if (idsOfInformUserAndGroups.isEmpty()) {
                return JSON.serialize(new List<Object>());
            }

            // Query Users
            List<Employee__c> userRecords = [
                SELECT Id, Name, Email_ID__c
                FROM Employee__c
                WHERE Id IN :idsOfInformUserAndGroups
            ];
            
            System.debug('userRecords'+userRecords);
            // Query Email Groups
            List<Star_EmailGroups__mdt> emailGroupRecords = [
                SELECT Id, Name__c, Email__c
                FROM Star_EmailGroups__mdt
                WHERE Id IN :idsOfInformUserAndGroups
            ];

            // Combine results into a unified structure
            List<Map<String, Object>> combinedResults = new List<Map<String, Object>>();

            // Add Users to the results
            for (Employee__c user : userRecords) {
                Map<String, Object> userMap = new Map<String, Object>();
                userMap.put('id', user.Id);
                userMap.put('name', user.Name);
                userMap.put('email', user.Email_ID__c);
                combinedResults.add(userMap);
            }

            // Add Email Groups to the results
            for (Star_EmailGroups__mdt emailGroup : emailGroupRecords) {
                Map<String, Object> emailGroupMap = new Map<String, Object>();
                emailGroupMap.put('id', emailGroup.Id);
                emailGroupMap.put('name', emailGroup.Name__c);
                emailGroupMap.put('email', emailGroup.Email__c);
                combinedResults.add(emailGroupMap);
            }

            // Return combined results as JSON
            return JSON.serialize(combinedResults);

        } catch (Exception ex) {
            // Log the error and return an empty list
            System.debug('Error in getInformSuggestionsDetails: ' + ex.getMessage());
            return JSON.serialize(new List<Object>());
        }
    }


    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getAllEmployees() {
        List<Map<String, Object>> allEmployees = new List<Map<String, Object>>();

        // Fetch the current user's associated Employee record
        Employee__c currentEmployee = [
            SELECT Id, StarAwardsInformToSuggestions__c
            FROM Employee__c
            WHERE SF_User__c = :UserInfo.getUserId()
            LIMIT 1
        ];

        // Get the StarAwardsInformToSuggestions__c field value
        String emailSuggestions = currentEmployee.StarAwardsInformToSuggestions__c;

        // Proceed only if the field is not empty
        if (String.isNotBlank(emailSuggestions)) {
            // Split the emails into a list
            List<String> emailList = emailSuggestions.split(';');
            
            // Query Employee records matching the emails, limit to 5
            List<Employee__c> employees = [
                SELECT Id, Name, Email_ID__c
                FROM Employee__c
                WHERE Email_ID__c IN :emailList
                LIMIT 5
            ];

            // Prepare the allEmployees list
            for (Employee__c emp : employees) {
                allEmployees.add(new Map<String, Object>{
                    'id' => emp.Id,
                    'name' => emp.Name,
                    'email' => emp.Email_ID__c
                });
            }
        }

        return allEmployees;
    }

    //Method to Insert Star records and send mails for each "To" user
    //return: string
    public static string insertAwardRecord(String awardRecordJsonString){
        //Deserialize json string to Apex Wrapper
        List<starAwardController.StarRecordWrapper> lstOfStarRecordWrapper = (List<starAwardController.StarRecordWrapper>)JSON.deserialize(awardRecordJsonString, List<starAwardController.StarRecordWrapper>.class);
        System.debug('lstOfStarRecordWrapper'+lstOfStarRecordWrapper);
        List<Star_Awarded__c> lstOfStarRecord = new List<Star_Awarded__c>();
        Set<Id> setOfUserId= new Set<Id>();
        String comment;
        String bcc;
        String starType;
        String informToId;

        if (!lstOfStarRecordWrapper.isEmpty()) {
            // Retrieve the common InformToId from the first record
            informToId = lstOfStarRecordWrapper[0].InformToId;
        }

        Employee__c currentEmployee = [
            SELECT Id, StarAwardsInformToSuggestions__c
            FROM Employee__c
            WHERE SF_User__c = :UserInfo.getUserId()
            LIMIT 1
        ];

        if (currentEmployee != null) {
            // Retrieve and split the existing suggestions into a List
            List<String> suggestionList = new List<String>();
            if (String.isNotBlank(currentEmployee.StarAwardsInformToSuggestions__c)) {
                suggestionList = currentEmployee.StarAwardsInformToSuggestions__c.split(',');
            }

            // Split the informToId (semicolon-separated) into a List
            List<String> informToIdList = new List<String>();
            if (String.isNotBlank(informToId)) {
                informToIdList = informToId.split(';');
            }

            // Process each informToId
            Boolean isUpdated = false;
            for (String id : informToIdList) {
                if (!suggestionList.contains(id)) {
                    if (suggestionList.size() >= 5) {
                        // Remove the oldest entry (first in the list) if there are already 5
                        suggestionList.remove(0);
                    }
                    // Add the new unique ID
                    suggestionList.add(id);
                    isUpdated = true; // Flag to indicate a change
                }
            }

            // If the list was updated, join and save it back to the field
            if (isUpdated) {
                currentEmployee.StarAwardsInformToSuggestions__c = String.join(suggestionList, ',');
                update currentEmployee;
            }
        }


        //Iterate list of Wrapper and populate "lstOfStarRecord" to insert.
        for(starAwardController.StarRecordWrapper eachWrapperRecord: lstOfStarRecordWrapper){
            lstOfStarRecord.add(new Star_Awarded__c(Comment__c=eachWrapperRecord.Comment,To__c=eachWrapperRecord.To,Inform_To__c=eachWrapperRecord.InformTo, Star_Type__c=eachWrapperRecord.StarType));
            setOfUserId.add(eachWrapperRecord.To);
            if(comment==null){
                //use these variables to send email
                comment=eachWrapperRecord.Comment;
                bcc=eachWrapperRecord.InformTo;
                starType=eachWrapperRecord.StarType;
            }
        }        
        if(lstOfStarRecord.size()>0){
            insert lstOfStarRecord; 
            System.debug('lstOfStarRecord'+lstOfStarRecord);
            //getting list of "To" details
            List<User> lstOfUser=[  SELECT Id,Name,Email FROM User
                                    WHERE Id IN :setOfUserId
                                    ];
            
            for(User eachUser:lstOfUser){
                //sending mail to each To user
                sendEMail(eachUser,comment,bcc,starType);
            }
        }
        return JSON.serialize(lstOfStarRecord);
    }

    //method to send email
    //Params: User, String, String, String
    private static void sendEMail(User toUser, String comment, String bcc, String starType){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String STAR_TYPE=starType;
        String SUBJECT='*** ' + UserInfo.getName() + ' Awarded a '+STAR_TYPE+' Star To '+toCamelCase(toUser.Name)+'***';
        String STAR_IMAGE=getStarUrl(starType);
        OrgWideEmailAddress orgWideEmails = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address='hrteam@crmit.com'];
        
        String[] toAddress = new String[] {toUser.Email, UserInfo.getUserEmail()};
           
        if(bcc!=null && bcc !=''){
            String[] ccAddress= bcc.split(';');
            System.debug('ccAddress'+ccAddress);
            if(ccAddress!=null && ccAddress.size()>0)
                mail.setCcAddresses(ccAddress);
        }
        
        mail.setToAddresses(toAddress);
        mail.setOrgWideEmailAddressId(orgWideEmails.Id);
        

        mail.setSubject(SUBJECT);
        
        //mail.setPlainTextBody('The Batch Apex job processed '+ a.TotalJobItems+' batches with '+a.NumberOfErrors+' failures'+'\n'+'Number of Records Processed are ' +recordsProcessed);      
        String htmlBody =   '<table><tr><td><b><font face=Verdana, Arial, Helvetica, sans-serif size=2px color=orange>Hello,</font></b></td></tr><tr><td height=5px></td></tr><tr><td><font face=Verdana, Arial, Helvetica, sans-serif size=2px color=black> '+ UserInfo.getName() + 
                            ' awarded a </font> ' + STAR_TYPE +' <font face=Verdana, Arial, Helvetica, sans-serif size=2px color=black>'+
                            'STAR </font><font face=Verdana, Arial, Helvetica, sans-serif size=2px color=black> to '+ toCamelCase(toUser.Name) +
                            '.</font></td></tr></table><table border=1 style=border:thin;border-color:black;><tr><td><table><tr><td><b><font face=Verdana, Arial, Helvetica, sans-serif size=2px color=orange>Congratulations '+ toCamelCase(toUser.Name) +
                            ' </font></b></td></tr><tr><td height=5px></td></tr><tr><td><font face=Verdana, Arial, Helvetica, sans-serif size=2px color=black>You received a </font><b> '+ STAR_TYPE +
                            ' STAR</b></font><font face=Verdana, Arial, Helvetica, sans-serif size=2px color=black> from <b> '+UserInfo.getName()+
                            ' </b>.</td></tr><tr><td><font face=Verdana, Arial, Helvetica, sans-serif size=2px color=orange><b>Comments:</b></font></td></tr> '+ 
                            comment+' <tr><td><font face=Verdana, Arial, Helvetica, sans-serif size=2px color=black></font></td></tr>'+
                            '</table></td><td><img src="'+ STAR_IMAGE + '"></img></td></tr></table><table><tr><td height=5px></td></tr><tr><td><font face=Verdana, Arial, Helvetica, sans-serif size=2px color=black><i>We want you to do the best and also enjoy your work.</i></font></td></tr>'+
                            '<tr><td><font face=Verdana, Arial, Helvetica, sans-serif size=2px color=orange><b>Best Regards,<b></font></td></tr><tr><td><font face=Verdana, Arial, Helvetica, sans-serif size=2px color=orange><b>Stars Team, CRMIT<b></font></td></tr></table>';
        
        mail.setHtmlBody(htmlBody);      
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
    }

    //method to get List of last 30 days Awared Records, based on Current user
    public static String getAwardedStars(){
        List<Star_Awarded__c> lstOfAward = [   SELECT CreatedDate, To__r.Name, Comment__c ,Star_Type__c
                                            FROM Star_Awarded__c 
                                            WHERE Owner.Id=:UserInfo.getUserId() AND CreatedDate=LAST_N_DAYS:30 
                                            Order By CreatedDate Desc];
        
        List<AwardWrapper> awards = new List<AwardWrapper>();
        for(Star_Awarded__c eachStarRecord:lstOfAward){
            AwardWrapper tempStar = new AwardWrapper();
            tempStar.CreatedDate = eachStarRecord.CreatedDate;
            tempStar.Awarded = eachStarRecord.To__r.Name;
            tempStar.Comment = eachStarRecord.Comment__c;
            tempStar.Star = eachStarRecord.Star_Type__c;
            awards.add(tempStar);
        }
        return JSON.serialize(awards);
    }
    public static String toCamelCase(String phrase){
       // System.debug('phrase>>>'+phrase);
        List<String> splitCamelCaseStr=phrase.split('\\.');
        String tempStr = '';
        //system.debug('splitCamelCaseStr'+splitCamelCaseStr);
        for(string eachOne:splitCamelCaseStr){
            String tempstr1 =eachOne.substring(0, 1).toUpperCase() + eachOne.substring(1);
            if(tempStr!=''){
                tempStr=tempStr+'.'+tempstr1;
            }else{
                tempStr=tempstr1;
            }
            
        }
        return tempStr;
    }
    //getting Image URL from Custom labels
    private static String getStarUrl(String starType){
        if(starType=='Gold'){
            return System.Label.Gold_URL;
        }else if(starType=='Silver'){
            return System.Label.Silver_URL;
        }else if(starType=='Bronze'){
            return System.Label.Bronze_URL;
        }else{
            return '';
        } 
    }

   public class StarRecordWrapper{        
       public String To;
       public  String Mail;
       public  String Comment;
       public  String InformTo;
        public  String InformToId;
       public  String StarType;
    }  
    
    public class AwardWrapper{
        @AuraEnabled
        public Datetime CreatedDate { get; set;}
        @AuraEnabled
        public String Awarded { get; set;}
        @AuraEnabled
        public String Comment { get; set;}
        @AuraEnabled
        public String Star { get; set;}
        
    }
}