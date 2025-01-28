public without sharing class ListViewLwcClass {

    @AuraEnabled
    public static void approvalStep(String reqAction, String reqComments,String recordId){
        try {
          ProcessInstanceWorkitem tsApproval = [SELECT id from ProcessInstanceWorkitem where ProcessInstance.TargetObjectId  = :recordId
        ];
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments(reqComments);
            req.setAction(reqAction);
            req.setWorkitemId(tsApproval.Id);
            Approval.ProcessResult result = Approval.process(req);
        } catch (Exception e) {
            System.debug('Exception occurred>>'+e.getMessage() + ' at ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    
      public static String fetchUserSessionId(){
        String sessionId = '';
        // Refer to the Page
        PageReference reportPage = Page.GetSessionIdVF;
        // Get the content of the VF page
        String vfContent = reportPage.getContent().toString();
        System.debug('vfContent '+vfContent);
        // Find the position of Start_Of_Session_Id and End_Of_Session_Id
        Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
        endP = vfContent.indexOf('End_Of_Session_Id');
        // Get the Session Id
        sessionId = vfContent.substring(startP, endP);
        System.debug('sessionId '+sessionId);
        // Return Session Id
        return sessionId;
        }
      
          @AuraEnabled
          public static List<Timesheet_Approval__c> getTimeSheetApproval(String objType, String listView, String fieldName, String sortDirection) {
            String res = filterCriteria(objType, listView);
           String resSubString = res.substringBefore('ORDER BY');
    
            String query = 'SELECT Id, Name,Week_Start_Date__c,LastModifiedDate,	Total_Hours__c, Approval_Status__c, Employee__r.Name, Customer_Engagement__r.Name, Approver__r.Name,Approver__c, Timesheet__r.Name FROM Timesheet_Approval__c' + (resSubString == '' ? '' : ' WHERE ' + resSubString) +' ORDER BY '+fieldName+' '+sortDirection;
    
            System.debug('Res'+res);
            System.debug('query'+query);
            List<Timesheet_Approval__c> ta = Database.query(query);
            System.debug('Ta'+ta);
            return ta;
          } 
    
         
          @AuraEnabled
            public static List<Timesheet_Approval__c> getRecentlyViewedTSA(String fieldName, String sortDirection) {
                String query = 'SELECT Id, Name,Week_Start_Date__c,LastModifiedDate, Approval_Status__c,	Total_Hours__c, Employee__r.Name, Customer_Engagement__r.Name, Approver__r.Name, Timesheet__r.Name,LastViewedDate FROM Timesheet_Approval__c WHERE LastViewedDate != null ORDER BY '+fieldName+' '+ sortDirection+ ' limit 50';
                List<Timesheet_Approval__c> ta = Database.query(query);
                System.debug('Ta'+ta);
                return ta;
            }
            
    
          @AuraEnabled
          public static List<Delivery__c> getTimeSheetActivity(String approvalId){
            List<Delivery__c> timeshact = [Select Id,Employee_Name__r.Name,Timesheet_Approval__r.Approval_Status__c, Date__c,Category__c,Sub_Category__c,Description__c,Time_in_Hours__c,Team_Allocation__r.Name,CreatedDate,Team_Timesheet__r.Current_Work_Item_ID__c FROM Delivery__c WHERE Timesheet_Approval__c=:approvalId];
            return  timeshact;
          }
          
              //For getting the file after passing the Timesheet Approval Id
        @AuraEnabled
        public static Map<ID, String> getTSApprovalFile(Id tsapproId) {
            System.debug('tsapproId>>'+tsapproId);
        
            // Get record file IDs        
            List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: tsapproId];
            System.debug('files>>' + files);
            List<ID> fileIDs = new List<ID>();
            for (ContentDocumentLink docLink : files) {
                fileIDs.add(docLink.ContentDocumentId);
            }
            System.debug('FileIds>>'+fileIDs);
            
            
            List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
                                        FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
            System.debug('Docs>> '+docs);
            Map<ID, String> mapIdTitle = new Map<ID, String>();
            for (ContentVersion docLink : docs) {
                mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
            }
            System.debug('mapIdTitle>> '+mapIdTitle);
            return mapIdTitle;
        }
        //Check Debug logs
        @AuraEnabled
        public static void deleteAttachment(Id contentDocId){
            
            List<ContentDocument> ConDoc = [SELECT Id, CreatedBy.name, ContentSize, ParentId FROM ContentDocument where Id =: contentDocId] ;
            delete ConDoc; 
        }

            @AuraEnabled(cacheable=true)
            public static String getTimeSinceLastUpdate() {
                Datetime lastUpdate = [SELECT LastModifiedDate FROM Timesheet_Approval__c ORDER BY LastModifiedDate DESC LIMIT 1].LastModifiedDate;
                Long timeDiffInSeconds = (Datetime.now().getTime() - lastUpdate.getTime()) / 1000;
                
                if (timeDiffInSeconds < 60) {
                    return 'just now';
                } else if (timeDiffInSeconds < 3600) {
                    Integer minutes = (Integer) (timeDiffInSeconds / 60);
                    return minutes + ' minute' + (minutes == 1 ? '' : 's') + ' ago';
                } else if (timeDiffInSeconds < 86400) {
                    Integer hours = (Integer) (timeDiffInSeconds / 3600);
                    return hours + ' hour' + (hours == 1 ? '' : 's') + ' ago';
                } else {
                    Integer days = (Integer) (timeDiffInSeconds / 86400);
                    return days + ' day' + (days == 1 ? '' : 's') + ' ago';
                }
                }
                
                @AuraEnabled(cacheable=true)
            public static List<ListView> getListViews(String objectApiName) {
                return [SELECT Id, Name, DeveloperName FROM ListView WHERE SObjectType = :objectApiName];
            }
        
        
            
            @AuraEnabled
            public static String filterCriteria(String objType, String listView){
            String sessionId = fetchUserSessionId();
                system.debug('ObjType: '+objType+'-- listView: '+listView);
            
                Id listViewId = [SELECT id FROM ListView WHERE developerName = :listView AND sObjectType=:objType].id;
                String ep = System.URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/v43.0/sobjects/'+objType+'/listviews/'+listViewId+'/describe';
                HttpRequest req = new HttpRequest();
                req.setMethod('GET');
                req.setHeader('Authorization','Bearer '+sessionId);
                req.setEndpoint(ep);
                HttpResponse res = new Http().send(req);
                system.debug('Res body: '+res.getBody());
                queryWrapper qw = (queryWrapper)json.deserialize(res.getBody(), queryWrapper.class);
            system.debug('query@@'+qw.query);
            return (qw.query.containsIgnoreCase('WHERE')?qw.query.substringAfter('WHERE'):'');
            }
            
            
            public class queryWrapper{
                String query{get;set;}
            
            }
            
        }