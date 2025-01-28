/**
* @description       : 
* @author            : Ibrahim
* @group             : 
* @last modified on  : 04-02-2024
* @last modified by  : Ibrahim
**/
public class importLeadController 
{
    @AuraEnabled
    public static resultWrapper saveLead(List<LeadWrapper> leadWrap) 
    {
        system.debug('leadWrap::'+leadWrap);

        resultWrapper resultWrap = new resultWrapper();
        List<successInsertWrapper> successInsertList = new List<successInsertWrapper>();
        List<successUpdateWrapper> successUpdateList = new List<successUpdateWrapper>();
        List<successWrapper> successWrapList = new List<successWrapper>();
        List<errrorWrapper> errorWrapperList = new List<errrorWrapper>();
        List<duplicateEmailWrapper> duplicateEmailList = new List<duplicateEmailWrapper>();

        try{
            Map<String,LeadWrapper> leadWrapperMap = new Map<String,LeadWrapper>();
            Map<String,List<LeadWrapper>> duplicateEmailMap = new Map<String,List<LeadWrapper>>();
            for(LeadWrapper eachLead : leadWrap)
            {
                leadWrapperMap.put(eachLead.EmailAddress, eachLead);

                if(duplicateEmailMap.containsKey(eachLead.EmailAddress)){
                    List<LeadWrapper> leadWrapperList = duplicateEmailMap.get(eachLead.EmailAddress);
                    leadWrapperList.add(eachLead);

                    duplicateEmailMap.put(eachLead.EmailAddress,leadWrapperList);
                }else{
                    List<LeadWrapper> leadWrapperList = new List<LeadWrapper>();
                    leadWrapperList.add(eachLead);

                    duplicateEmailMap.put(eachLead.EmailAddress,leadWrapperList);
                }
            }
            
            Integer successCountInt = 0;
            Integer errorCountInt = 0;
            Integer successInsertCountInt = 0;
            Integer successUpdateCountInt = 0;
            if(leadWrapperMap.size() > 0)
            {
                
                Map<String,RecordType> leadRecordTypeMap = new Map<String,RecordType>();
                Map<String,String> leadRegionMap = new Map<String,String>();
                for(RecordType leadRecordType : [Select id,Name from RecordType where sObjectType='Lead'])
                {
                    if(leadRecordType.Name == 'IND Region'){
                        leadRecordTypeMap.put('India',leadRecordType);

                        leadRegionMap.put('India', 'IND');
                    }else if(leadRecordType.Name == 'USA Region'){
                        leadRecordTypeMap.put('United States',leadRecordType);

                        leadRegionMap.put('United States', 'USA');
                    }else if(leadRecordType.Name == 'ANZ Region'){
                        leadRecordTypeMap.put('Australia',leadRecordType);
                        leadRecordTypeMap.put('New Zealand',leadRecordType);

                        leadRegionMap.put('Australia', 'ANZ');
                        leadRegionMap.put('New Zealand', 'ANZ');
                    }else{
                        leadRecordTypeMap.put('Rest of the world',leadRecordType);

                        leadRegionMap.put('Rest of the world', 'ROW');
                    }  
                }

                resultWrap.duplicateEmailsCount = 0;
                Integer duplicateCount = 0;
                if(duplicateEmailMap.size()>0){
                    Set<String> duplicateEmailSet = new Set<String>();
                    for(String dupicalteEmail : duplicateEmailMap.keySet()){
                        if(duplicateEmailMap.get(dupicalteEmail).size() > 1){
                            duplicateEmailSet.add(dupicalteEmail);
                            for(LeadWrapper eachLeadWrap : duplicateEmailMap.get(dupicalteEmail)){
                                duplicateCount ++ ;
                                duplicateEmailWrapper duplicateEmailWrap = new duplicateEmailWrapper();
                                duplicateEmailWrap.Name = eachLeadWrap.FirstName + ' '+ eachLeadWrap.LastName;
                                duplicateEmailWrap.LeadEmail = eachLeadWrap.EmailAddress;
                                duplicateEmailList.add(duplicateEmailWrap);
                            }
                        }
                    }

                    if(duplicateEmailSet.size()> 0){
                        leadWrapperMap.keySet().removeAll(duplicateEmailSet);
                    }

                    resultWrap.duplicateEmailsCount = duplicateCount;
                }
                
                // Get the Country Names and Code of it
                Map<String,String> countryNameAndCode = getCountryCode();
                
                Set<String> existingEmails = new Set<String>();
                List<Lead> updateLeadList = new List<Lead>();
                for(Lead ld : [Select id,FirstName,LastName,Email,Phone, Country,Status, LeadSource, Company, Title,Consolidated_Prospect__c from Lead Where Email IN : leadWrapperMap.keySet() and IsConverted = false])
                {
                    if(leadWrapperMap.containsKey(ld.Email))
                    {
                        existingEmails.add(ld.Email);
                        
                        Lead updateLeadObj = new Lead();
                        updateLeadObj.Id = ld.Id;
                        if(leadWrapperMap.get(ld.Email).LastName == ''){
                            updateLeadObj.LastName = leadWrapperMap.get(ld.Email).FirstName;
                            updateLeadObj.FirstName = '';
                        }else{
                            updateLeadObj.FirstName = leadWrapperMap.get(ld.Email).FirstName;
                            updateLeadObj.LastName = leadWrapperMap.get(ld.Email).LastName;
                        }
                        
                        updateLeadObj.Email = leadWrapperMap.get(ld.Email).EmailAddress;
                        updateLeadObj.Phone = leadWrapperMap.get(ld.Email).Phone;
                        // if(leadWrapperMap.get(ld.Email).Street != '' ){
                        //     updateLeadObj.Street = leadWrapperMap.get(ld.Email).Street;
                        // }
                        // if(leadWrapperMap.get(ld.Email).City != ''){
                        //     updateLeadObj.City = leadWrapperMap.get(ld.Email).City;
                        // }
                        // if(leadWrapperMap.get(ld.Email).State != ''){
                        //     updateLeadObj.State = leadWrapperMap.get(ld.Email).State;
                        // }
                        // if(leadWrapperMap.get(ld.Email).PostalCode != ''){
                        //     updateLeadObj.PostalCode = leadWrapperMap.get(ld.Email).PostalCode;
                        // }
                        if(countryNameAndCode.containsKey(leadWrapperMap.get(ld.Email).Country)){
                            updateLeadObj.CountryCode = countryNameAndCode.get(leadWrapperMap.get(ld.Email).Country);
                            // updateLeadObj.Country = 'IND';
                        }else if(leadWrapperMap.get(ld.Email).Country == ''){
                            updateLeadObj.CountryCode = '';
                        }else{
                            updateLeadObj.CountryCode = '';
                        }

                        if(leadWrapperMap.get(ld.Email).LeadStatus == ''){
                            updateLeadObj.Status = '';
                        }else{
                            updateLeadObj.Status = leadWrapperMap.get(ld.Email).LeadStatus;
                        }
                    
                        updateLeadObj.LeadSource = leadWrapperMap.get(ld.Email).LeadSource;
                        updateLeadObj.Company = leadWrapperMap.get(ld.Email).Company;
                        updateLeadObj.Title = leadWrapperMap.get(ld.Email).Title;
                        updateLeadObj.Consolidated_Prospect__c = 'Update';
                        if(leadRecordTypeMap.containsKey(leadWrapperMap.get(ld.Email).Country)){
                            updateLeadObj.RecordTypeId = leadRecordTypeMap.get(leadWrapperMap.get(ld.Email).Country).Id;
                        }else{
                            updateLeadObj.RecordTypeId = leadRecordTypeMap.get('Rest of the world').Id;
                        }

                        if(leadRegionMap.containsKey(leadWrapperMap.get(ld.Email).Country)){
                            updateLeadObj.Region__c =  leadRegionMap.get(leadWrapperMap.get(ld.Email).Country);
                        }else{
                            updateLeadObj.Region__c =  leadRegionMap.get('Rest of the world');
                        }

                        updateLeadList.add(updateLeadObj);
                    }
                }
                
                leadWrapperMap.keySet().removeAll(existingEmails);
                
                List<Lead> insertLeadList = new List<Lead>();
                for(LeadWrapper eachLeadWrap : leadWrapperMap.values())
                {
                    Lead insertLeadObj = new Lead();
                    
                    if(eachLeadWrap.LastName == ''){
                        insertLeadObj.LastName = eachLeadWrap.FirstName;
                    }else{
                        insertLeadObj.FirstName = eachLeadWrap.FirstName;
                        insertLeadObj.LastName = eachLeadWrap.LastName;
                    }
                    insertLeadObj.Email = eachLeadWrap.EmailAddress;
                    insertLeadObj.Phone = eachLeadWrap.Phone;
                    // insertLeadObj.Street = eachLeadWrap.Street;
                    // insertLeadObj.City = eachLeadWrap.City;
                    // insertLeadObj.State = eachLeadWrap.State;
                    if(countryNameAndCode.containsKey(eachLeadWrap.Country)){
                        insertLeadObj.CountryCode = countryNameAndCode.get(eachLeadWrap.Country);
                    }
                    // insertLeadObj.CountryCode = eachLeadWrap.Country;
                    // insertLeadObj.PostalCode = eachLeadWrap.PostalCode;
                    system.debug('eachLeadWrap.LeadStatus::'+eachLeadWrap.LeadStatus);
                    if(eachLeadWrap.LeadStatus == ''){
                        insertLeadObj.Status = '';
                    }else{
                        insertLeadObj.Status = eachLeadWrap.LeadStatus;
                    }
                    
                    insertLeadObj.LeadSource = eachLeadWrap.LeadSource;
                    insertLeadObj.Company = eachLeadWrap.Company;
                    insertLeadObj.Title = eachLeadWrap.Title;
                    if(leadRecordTypeMap.containsKey(eachLeadWrap.Country)){
                        insertLeadObj.RecordTypeId = leadRecordTypeMap.get(eachLeadWrap.Country).Id;
                    }else{
                        insertLeadObj.RecordTypeId = leadRecordTypeMap.get('Rest of the world').Id;
                    }

                    if(leadRegionMap.containsKey(eachLeadWrap.Country)){
                        insertLeadObj.Region__c =  leadRegionMap.get(eachLeadWrap.Country);
                    }else{
                        insertLeadObj.Region__c =  leadRegionMap.get('Rest of the world');
                    }

                    insertLeadObj.Consolidated_Prospect__c = 'Insert';
                    insertLeadList.add(insertLeadObj);
                }
                
                // Inserting the new lead records
                if(insertLeadList.size() > 0)
                {
                    Database.SaveResult[] saveLeadList = Database.insert(insertLeadList, false);
                    
                    List<Lead> leadList = new List<Lead>();
                    leadList.addAll(insertLeadList);
                    
                    for(Integer i=0; i<saveLeadList.size(); i++)
                    {
                        if(saveLeadList.get(i).isSuccess()){
                            successCountInt ++;

                            successInsertCountInt ++;

                            successInsertWrapper successInsertWrap = new successInsertWrapper();
                            successInsertWrap.leadId = saveLeadList.get(i).getId();
                            successInsertWrap.leadURL = '/'+saveLeadList.get(i).getId();
                            successInsertWrap.completedLeadURL = URL.getOrgDomainUrl().toExternalForm() + '/'+ saveLeadList.get(i).getId();
                            if(leadList.size() > 0){
                                String leadFirstName = (String) leadList[i].get('FirstName');
                                if(leadFirstName != '' && leadFirstName != null){
                                    successInsertWrap.Name = leadFirstName + ' '+ (String) leadList[i].get('LastName');
                                }else{
                                    successInsertWrap.Name =  (String) leadList[i].get('LastName');
                                }
                                
                            }
                            successInsertList.add(successInsertWrap);
                            
                            successWrapper successWrap = new successWrapper(); 
                            successWrap.leadId = saveLeadList.get(i).getId();
                            successWrap.leadURL = '/'+saveLeadList.get(i).getId();
                            successWrap.completedLeadURL = URL.getOrgDomainUrl().toExternalForm() + '/'+ saveLeadList.get(i).getId();
                            successWrap.IsUpdated = false;
                            if(leadList.size() > 0){
                                successWrap.Name = (String) leadList[i].get('FirstName') + ' '+ (String) leadList[i].get('LastName');
                            }
                            successWrapList.add(successWrap);
                            
                        }else if(!saveLeadList.get(i).isSuccess()){
                            errorCountInt ++;
                            
                            // Database.Error dbError = saveLeadList.get(i).getErrors().get(0);
                            errrorWrapper errorWrap = new errrorWrapper();
                            
                            if(leadList.size() > 0){
                                errorWrap.Name = (String) leadList[i].get('FirstName') + ' '+ (String) leadList[i].get('LastName');
                            }

                            String errorMessage ='';
                            for(Database.Error err : saveLeadList.get(i).getErrors()){
                                errorMessage += err.getMessage() + '\n'; 
                            }
                            String errMessage = errorMessage.removeEnd('\n');
                            errorWrap.message = errMessage;
                            errorWrapperList.add(errorWrap);
                        }
                    }
                }
                
                // Updating the existing lead records
                if(updateLeadList.size() > 0)
                {
                    Database.SaveResult[] saveUpdateLeadList = Database.update(updateLeadList, false);
                    
                    List<Lead> allLeadList = new List<Lead>();
                    allLeadList.addAll(updateLeadList);
                    
                    for(Integer i=0; i<saveUpdateLeadList.size(); i++)
                    {
                        if(saveUpdateLeadList.get(i).isSuccess()){
                            successCountInt ++;

                            successUpdateCountInt ++;

                            successUpdateWrapper successUpdateWrap = new successUpdateWrapper();
                            successUpdateWrap.leadId = saveUpdateLeadList.get(i).getId();
                            successUpdateWrap.leadURL = '/'+saveUpdateLeadList.get(i).getId();
                            successUpdateWrap.completedLeadURL = URL.getOrgDomainUrl().toExternalForm() + '/'+ saveUpdateLeadList.get(i).getId();
                            if(allLeadList.size() > 0){
                                String updateLeadFirstName = (String) allLeadList[i].get('FirstName');
                                if(updateLeadFirstName !='' && updateLeadFirstName != null){
                                    successUpdateWrap.Name = updateLeadFirstName + ' '+ (String) allLeadList[i].get('LastName');
                                }else{
                                    successUpdateWrap.Name =  (String) allLeadList[i].get('LastName');
                                }
                                
                            }
                            successUpdateList.add(successUpdateWrap);
                            
                            successWrapper successWrap = new successWrapper(); 
                            successWrap.leadId = saveUpdateLeadList.get(i).getId();
                            successWrap.leadURL = '/'+saveUpdateLeadList.get(i).getId();
                            successWrap.completedLeadURL = URL.getOrgDomainUrl().toExternalForm() + '/'+ saveUpdateLeadList.get(i).getId();
                            successWrap.IsUpdated = true;
                            
                            if(allLeadList.size() > 0){
                                successWrap.Name = (String) allLeadList[i].get('FirstName') + ' '+ (String) allLeadList[i].get('LastName');
                            }
                            successWrapList.add(successWrap);  
                        }else if(!saveUpdateLeadList.get(i).isSuccess()){
                            errorCountInt ++;
                            
                            // Database.Error dbError = saveUpdateLeadList.get(i).getErrors().get(0);
                            
                            errrorWrapper errorWrap = new errrorWrapper();
                            
                            if(allLeadList.size() > 0){
                                errorWrap.Name = (String) allLeadList[i].get('FirstName') + ' '+ (String) allLeadList[i].get('LastName');
                            }

                            String errorMessage ='';
                            for(Database.Error err : saveUpdateLeadList.get(i).getErrors()){
                                errorMessage += err.getMessage() + '\n'; 
                            }
                            String errMessage = errorMessage.removeEnd('\n');
                            errorWrap.message = errMessage;
                            errorWrapperList.add(errorWrap);
                        }
                    }
                }
            }
            
            resultWrap.status='Success';
            resultWrap.successCount = successCountInt;
            resultWrap.errorCount = errorCountInt;
            resultWrap.successResult = successWrapList;
            resultWrap.successInsertResult = successInsertList;
            resultWrap.successUpdateResult = successUpdateList;
            resultWrap.errorResult = errorWrapperList;
            resultWrap.duplicateEmails = duplicateEmailList;
            resultWrap.successInsertCount = successInsertCountInt;
            resultWrap.successUpdateCount = successUpdateCountInt;
            return resultWrap; 
            
        }catch(Exception ex){
            System.debug('ex:::'+ex.getMessage() +'Linenumber: '+ex.getLineNumber());
            resultWrap.status = 'Error';
            resultWrap.errorMessage = String.valueOf(ex.getMessage());
            return resultWrap;
        }
    }
    
    public static Map<String,String> getCountryCode()
    {
        // Get the global describe map
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
        
        // Get the DescribeSObjectResult for the Lead object
        Schema.DescribeSObjectResult describeResult = gd.get('Lead').getDescribe();
        
        // Get the State and Country/Territory picklist values
        Schema.PicklistEntry[] countryPicklistValues = describeResult.fields.getMap().get('CountryCode').getDescribe().getPicklistValues();
        
        Map<String,String> countryCodeMap = new Map<String,String>();
        // Iterate over the picklist values
        for(Schema.PicklistEntry entry : countryPicklistValues) 
        {
            String CountryName = String.valueOf(entry.getLabel());
            String CountryCode = String.valueOf(entry.getValue());
            countryCodeMap.put(CountryName,CountryCode);
            system.debug('entry::'+entry.getLabel());
            System.debug(entry.getValue());
        }
        return countryCodeMap;
    }
    
    @AuraEnabled 
    public static resultWrapper sendEmail(String successsInsertCount, String successUpdateCount, List<successInsertWrapper> successsInsertResult, List<successUpdateWrapper> successUpdateResult, String errorCount, List<errrorWrapper> errorResult, String duplicateEmailCount, List<duplicateEmailWrapper> duplicateEmailResult)
    {
        resultWrapper resultWrap = new resultWrapper();
        try
        {
            String[] toAddresses = new String[] {UserInfo.getUserEmail()};
                // String[] toAddresses = new String[] {'ibrahim.shirur@crmit.com'};
                
                String emailBody = 'Count of Lead records successfully Inserted is : <strong>' + successsInsertCount +'</strong><br/><br/> ';
            if(successsInsertResult.size() > 0){
                emailBody += 'Below are the Lead records <br/><br/> ';
                emailBody += '<table border="1" width="100%" cellspacing="0">';
                emailBody +=  '<thead><tr><th>Lead Id</th>';
                emailBody +=  '<th>Lead Name</th></tr></thead>';
                emailBody +=  '<tbody>';
                for(successInsertWrapper eachSuccessInsert : successsInsertResult)
                {
                    emailBody +=  '<tr><td><a href='+eachSuccessInsert.completedLeadURL+'>'+eachSuccessInsert.leadId+'</a></td>';
                    emailBody +=  '<td>'+eachSuccessInsert.Name+'</td></tr>';
                }
                emailBody +=  '</tbody></table> <br/><br/>'; 
            }

            emailBody += 'Count of Lead records successfully Updated is : <strong>' + successUpdateCount +'</strong><br/><br/> ';
            if(successUpdateResult.size() > 0){
                emailBody += 'Below are the Lead records <br/><br/> ';
                emailBody += '<table border="1" width="100%" cellspacing="0">';
                emailBody +=  '<thead><tr><th>Lead Id</th>';
                emailBody +=  '<th>Lead Name</th></tr></thead>';
                emailBody +=  '<tbody>';
                for(successUpdateWrapper eachSuccessUpdate : successUpdateResult)
                {
                    emailBody +=  '<tr><td><a href='+eachSuccessUpdate.completedLeadURL+'>'+eachSuccessUpdate.leadId+'</a></td>';
                    emailBody +=  '<td>'+eachSuccessUpdate.Name+'</td></tr>';
                }
                emailBody +=  '</tbody></table> <br/><br/>';
                
                try{
                    sendToRespectiveLeadOwner(successUpdateResult);
                }catch(Exception ex){
                    System.debug('ex:::'+ex.getMessage() +'Linenumber: '+ex.getLineNumber());
                }   
            }
            
            emailBody +=  'Count of Lead records which is not inserted and updated is : <strong>' + errorCount +'</strong><br/><br/> ';
            
            if(errorResult.size() > 0){
                emailBody += 'Below are the Lead Names <br/><br/> ';
                emailBody += '<table border="1" width="100%" cellspacing="0">';
                emailBody +=  '<thead><tr><th>Lead Name</th>';
                emailBody +=  '<th>Error Message</th></tr></thead>';
                emailBody +=  '<tbody>';
                for(errrorWrapper eachError : errorResult)
                {
                    emailBody +=  '<tr><td>'+eachError.Name+'</td>';
                    emailBody +=  '<td>'+eachError.message+'</td></tr>';
                }
                emailBody +=  '</tbody></table> <br/><br/>';
            }

            emailBody +=  'Count of Lead records which is having duplicate emails in csv files is : <strong>' + duplicateEmailCount +'</strong><br/><br/> ';
            if(duplicateEmailResult.size() > 0){
                emailBody += 'Below are the Lead Names and emails <br/><br/> ';
                emailBody += '<table border="1" width="100%" cellspacing="0">';
                emailBody +=  '<thead><tr><th>Lead Name</th>';
                emailBody +=  '<th>Email</th></tr></thead>';
                emailBody +=  '<tbody>';
                for(duplicateEmailWrapper eachDuplicate : duplicateEmailResult)
                {
                    emailBody +=  '<tr><td>'+eachDuplicate.Name+'</td>';
                    emailBody +=  '<td>'+eachDuplicate.LeadEmail+'</td></tr>';
                }
                emailBody +=  '</tbody></table> <br/><br/>';
            }
            
            system.debug('emailBody::'+emailBody);
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setHtmlBody(emailBody);
            mail.setToAddresses(toAddresses);
            mail.setSubject('Lead record Inserted/Updated successfully');
            mail.setSaveAsActivity(false);
            if(!Test.isRunningTest())	//to exclude from test class
            {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail});
                if (results[0].success) 
                {
                    resultWrap.status = 'Success';
                    System.debug('The email was sent successfully.');
                } 
                else
                {
                    resultWrap.status = 'Error';
                    resultWrap.errorMessage = String.valueOf(results[0].errors[0].message);
                    System.debug('The email failed to send:'+results[0].errors[0].message);
                }
            }
            return resultWrap;
        }catch(Exception ex)
        {
            System.debug('ex:::'+ex.getMessage() +'Linenumber: '+ex.getLineNumber());
            resultWrap.status = 'Error';
            resultWrap.errorMessage = String.valueOf(ex.getMessage());
            return resultWrap;
        }
    }
    
    public static void sendToRespectiveLeadOwner(List<successUpdateWrapper> successUpdateResult){
        try{
            
            Map<Id,successUpdateWrapper> leadIdSuccessWrapMap = new Map<Id,successUpdateWrapper>();
            for(successUpdateWrapper eachSuccessWrap : successUpdateResult){
                leadIdSuccessWrapMap.put(eachSuccessWrap.leadId, eachSuccessWrap);
            }
            
            Map<String,List<Lead>> leadMap = new Map<String,List<Lead>>();
            Map<String,String> leadLastModifiedByMap = new Map<String,String>();
            if(leadIdSuccessWrapMap.size() > 0){
                for(Lead eachLead : [Select id,FirstName,LastName,Email,Phone, Country,Status, LeadSource, Company, Title,Owner.Email,LastModifiedBy.Name from Lead Where Id IN: leadIdSuccessWrapMap.keySet()])
                {
                    leadLastModifiedByMap.put(eachLead.Owner.Email,eachLead.LastModifiedBy.Name);
                    if(leadMap.containsKey(eachLead.Owner.Email))
                    {
                        List<Lead> leadList = leadMap.get(eachLead.Owner.Email);
                        leadList.add(eachLead);
                        
                        leadMap.put(eachLead.Owner.Email, leadList);
                    }else{
                        List<Lead> leadList = new List<Lead>();
                        leadList.add(eachLead);
                        
                        leadMap.put(eachLead.Owner.Email, leadList);
                    }
                }
                
                if(leadMap.size() > 0){
                    List<messaging.SingleEmailMessage> emailList = new List<messaging.SingleEmailMessage>();
                    for(String ownerEmail : leadMap.keySet()){
                        // String emailBody = 'Count of lead record successfully updated is : <strong>' + leadMap.values().size() +'</strong><br/><br/> ';
                        String emailBody = 'Below are the Lead records updated by : <strong>'+ leadLastModifiedByMap.get(ownerEmail)+'</strong> <br/><br/> ';
                        emailBody += '<table border="1" width="100%" cellspacing="0">';
                        emailBody +=  '<thead><tr><th>Lead Id</th>';
                        emailBody +=  '<th>Lead Name</th></tr></thead>';
                        emailBody +=  '<tbody>';
                        
                        for(Lead eachLeadRecord : leadMap.get(ownerEmail))
                        {
                            emailBody +=  '<tr><td><a href='+ leadIdSuccessWrapMap.get(eachLeadRecord.id).completedLeadURL+'>'+eachLeadRecord.id+'</a></td>';
                            emailBody +=  '<td>'+eachLeadRecord.FirstName +' '+eachLeadRecord.LastName+'</td></tr>';
                        }
                        emailBody +=  '</tbody></table> <br/><br/>';
                        
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                        mail.setHtmlBody(emailBody);
                        
                        string[] toAdd=new string[]{ownerEmail};
                            mail.setToAddresses(toAdd);
                        
                        mail.setSubject('Lead records updated successfully');
                        mail.setSaveAsActivity(false);
                        
                        emailList.add(mail);
                    }
                    
                    if(emailList.size() > 0){
                        if(!Test.isRunningTest()){
                            try{
                                messaging.sendEmail(emailList);
                            }catch(Exception ex){
                                System.debug('ex:::'+ex.getMessage() +'Linenumber: '+ex.getLineNumber());
                            } 
                        }  
                    }
                }
                
            }
            
        }catch(Exception ex)
        {
            System.debug('Exception in mxnSpecialistMappingController :'+ex);
            System.debug('Exception in mxnSpecialistMappingController line :'+ex.getLineNumber());
        }
    }
    
    public class LeadWrapper{
        @AuraEnabled 
        public String FirstName {get;set;}
        @AuraEnabled 
        public String LastName {get;set;}
        @AuraEnabled 
        public String EmailAddress {get;set;}
        @AuraEnabled 
        public String Phone {get;set;}
        // @AuraEnabled 
        // public String Street {get;set;}
        // @AuraEnabled 
        // public String City {get;set;}
        // @AuraEnabled 
        // public String State {get;set;}
        @AuraEnabled 
        public String Country {get;set;}
        // @AuraEnabled 
        // public String PostalCode {get;set;}
        @AuraEnabled 
        public String LeadStatus {get;set;}
        @AuraEnabled 
        public String LeadSource {get;set;}
        @AuraEnabled 
        public String Company {get;set;}
        @AuraEnabled 
        public String Title {get;set;}
    }
    
    public class resultWrapper
    {
        @AuraEnabled
        public String status {get;set;}
        @AuraEnabled
        public String errorMessage {get;set;}
        @AuraEnabled 
        public Integer successCount {get;set;}
        @AuraEnabled 
        public Integer errorCount {get;set;}
        @AuraEnabled 
        public Integer duplicateEmailsCount {get;set;}
        @AuraEnabled 
        public Integer successInsertCount {get;set;}
        @AuraEnabled 
        public Integer successUpdateCount {get;set;}
        @AuraEnabled 
        public List<successInsertWrapper> successInsertResult {get;set;}
        @AuraEnabled 
        public List<successUpdateWrapper> successUpdateResult {get;set;}
        @AuraEnabled 
        public List<successWrapper> successResult {get;set;}
        @AuraEnabled 
        public List<errrorWrapper> errorResult {get;set;}
        @AuraEnabled 
        public List<duplicateEmailWrapper> duplicateEmails {get;set;}
    }

    public class successInsertWrapper
    {
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public Id leadId {get;set;}
        @AuraEnabled
        public String leadURL {get;set;}
        @AuraEnabled
        public String completedLeadURL {get;set;}
    }

    public class successUpdateWrapper
    {
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public Id leadId {get;set;}
        @AuraEnabled
        public String leadURL {get;set;}
        @AuraEnabled
        public String completedLeadURL {get;set;}
    }
    
    public class successWrapper
    {
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public Id leadId {get;set;}
        @AuraEnabled
        public String leadURL {get;set;}
        @AuraEnabled 
        public Boolean IsUpdated {get;set;}
        @AuraEnabled
        public String completedLeadURL {get;set;}
    }
    
    public class errrorWrapper
    {
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String message {get;set;}
    }

    public class duplicateEmailWrapper
    {
        @AuraEnabled 
        public String Name {get;set;}
        @AuraEnabled 
        public String LeadEmail {get;set;}
    }
}