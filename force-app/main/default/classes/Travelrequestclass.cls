public with sharing class Travelrequestclass {
    @AuraEnabled(cacheable=true)
    public static List<Travel_Request__c> gettravelrequestdata() {
       String empid =[SELECT Id, Name, Email_ID__c,Department__c,Country__c
                       FROM Employee__c where Email_ID__c =:UserInfo.getUserEmail()].Id;
        return [SELECT Id,Name, Employee__r.Name, Destination__c,Description__c,Date_of_Departure__c	,Date_of_Return__c	,Purpose_of_Visit1__c	,Billed_to_Customer__c	,Project__c,Mode_of_Transport__c,CurrencyIsoCode,CCM__c,Do_you_have_an_existing_Travel_Card__c,Travel_Card_Number__c FROM Travel_Request__c where Employee__c=:empid];
    }
    @AuraEnabled(cacheable=true)
    public static Employee__c getloggindata() {
       
        return [SELECT Id, Name, Email_ID__c,Department__c, Country__c,ReportingTo__r.SF_User__c, BU_Head__r.SF_User__c
                       FROM Employee__c where Email_ID__c =:UserInfo.getUserEmail()];
    }

@AuraEnabled
public static void createrecords(String records, String parentid, String status, String rm, String ccm) {
    system.debug('record-->' + records);
    system.debug('parentId-->' + parentid);
    system.debug('records---->' + records);

    Travel_Request__c tr = new Travel_Request__c();
    List<Travel_Request__c> travelRequestsToUpdate = new List<Travel_Request__c>(); // Collect records for update
    List<Travel_bill__c> travelBillsToInsert = new List<Travel_bill__c>(); // Collect records for insert
    List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>(); // Collect approval requests

    if (status == 'Draft' || status == 'Waiting For Approval') {
        // Prepare Travel_Request__c record to update
        Travel_Request__c trToUpdate = new Travel_Request__c(
            Id = parentid,
            Status__c = status,
            Reporting_Manager__c = rm,
            Cost_Centre_manager__c = ccm
        );
        travelRequestsToUpdate.add(trToUpdate);

        if (status == 'Waiting For Approval') {
            // Fetch Country and determine approval process
            Travel_Request__c tr1 = [SELECT id, Country__c FROM Travel_Request__c WHERE id = :parentid];
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
            req1.setComments('Submitting request for approval.');
            req1.setObjectId(parentid);
             String loggedUserId = UserInfo.getUserId();
            req1.setSubmitterId(loggedUserId);
            if (tr1.Country__c == 'India') {
                req1.setProcessDefinitionNameOrId('Travel_Request_approval_process_India');
            } else if (tr1.Country__c == 'USA') {
                req1.setProcessDefinitionNameOrId('Travel_request_approval_process_USA');
            } else if (tr1.Country__c == 'Australia') {
                req1.setProcessDefinitionNameOrId('Travel_request_approval_process_ANZ');
            }
            req1.setSkipEntryCriteria(true);

            // Collect approval requests
            approvalRequests.add(req1);
        }
    }

    // Deserialize the JSON records to List of Objects
    List<Object> recordsList = (List<Object>) System.JSON.deserializeUntyped(records);
    system.debug('records--->' + recordsList);

    for (Object record : recordsList) {
        Map<String, Object> m = (Map<String, Object>) record;
        Travel_bill__c bills = new Travel_bill__c();

        if (m.containsKey('file')) {
            String filename = (String) m.get('filename');
            String filedata = (String) m.get('file');
            system.debug('filename--->' + filename);
            system.debug('filedata--->' + filedata);

            try {
                GoogleDriveIntegrationNew.GoogleDriveFile gdrive = GoogleDriveIntegrationNew.uploadFile(
                    filename, filedata, '1UOErZhZ1SxjZsHvIaHTXMqoIipyssGuL', getAccessToken()
                );
                bills.Name = gdrive.fileUrl;
                bills.field__c = gdrive.fileId;
                bills.Travel_Bills__c = gdrive.filename;

            } catch (Exception e) {
                if (e.getMessage().contains('401')) {
                    String newToken = GoogleDriveIntegrationNew.refreshAccessToken();
                    GoogleDriveIntegrationNew.GoogleDriveFile gdrive = GoogleDriveIntegrationNew.uploadFile(
                        filename, filedata, '1UOErZhZ1SxjZsHvIaHTXMqoIipyssGuL', newToken
                    );
                    bills.Name = gdrive.fileUrl;
                    bills.field__c = gdrive.fileId;
                    bills.Travel_Bills__c = gdrive.filename;
                } else {
                    throw new AuraHandledException('err: ' + e.getMessage());
                }
            }

            bills.Travel_Request__c = parentid;
            travelBillsToInsert.add(bills); // Add the Travel_bill__c record to the list
        }
    }

    // Perform DML operations outside loops, breaking into smaller batches
    system.debug('About to perform DML on travelRequestsToUpdate');
    if (!travelRequestsToUpdate.isEmpty()) {
        update travelRequestsToUpdate; // Update all records at once
    }

    if (!travelBillsToInsert.isEmpty()) {
        insert travelBillsToInsert; // Insert all records at once
    }

    // Submit approval after DML operations
    system.debug('About to submit approval requests');
    if (!approvalRequests.isEmpty()) {
        try {
            Approval.ProcessResult[] results = Approval.process(approvalRequests);
            for (Approval.ProcessResult result : results) {
                if (result.isSuccess()) {
                    System.debug('Travel request submitted for approval successfully.');
                } else {
                    System.debug('Error in submission: ' + result.getErrors());
                }
            }
        } catch (Exception e) {
            System.debug('Error submitting for approval: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
}


       
    private static String getAccessToken() {
        GoogleDriveTokens__c googleTokenSettings = GoogleDriveTokens__c.getInstance('GoogleTokenRecord');
        system.debug('googleTokenSettings.AccessToken__c--->'+googleTokenSettings.AccessToken__c);
        return googleTokenSettings.AccessToken__c;
    }
    @AuraEnabled(cacheable=true)
    public static List<billsWrapper> getbillsdata(Id recordId)

{
    List<billsWrapper> billsdata= new List<billsWrapper>();
    List<Travel_bill__c> data=[select id,Travel_Bills__c,Name,Travel_Request__r.Status__c from Travel_bill__c where Travel_Request__c=:recordId];
    system.debug('data'+data);
    Integer i=-1;
    for(Travel_bill__c bill:data){
        i=i+1;
        billsWrapper bw= new billsWrapper();
        bw.filename=bill.Travel_Bills__c;
        bw.recId=bill.Id;
        bw.parentId=bill.Travel_Request__c;
        bw.url=bill.Name;
        if(bill.Travel_Request__r.Status__c=='Draft')
        {
            bw.status=true;
        }
        
        bw.id=i;
        billsdata.add(bw);
  }
           system.debug('billsdata'+billsdata);
  return billsdata;
    }
     @AuraEnabled(cacheable=true)
  public static List<approveWrapper> getPendingApprovals( String status) {
    system.debug('status'+status);
    List<approveWrapper> appwrap = new  List<approveWrapper>();
      Map<Id,Id> targetObjectIds = new  Map<Id,Id>();
    if(status=='Pending for Approval')
    {
        List<ProcessInstanceWorkitem> workItems = [SELECT Id, ProcessInstance.TargetObjectId, ProcessInstanceId, OriginalActorId, ActorId, CreatedDate,Actor.name
              FROM ProcessInstanceWorkitem
              WHERE ActorId = :UserInfo.getUserId() AND ProcessInstance.TargetObject.Type ='Travel_Request__c'];
              //Map<Id,Id> targetObjectIds = new  Map<Id,Id>();
                for (ProcessInstanceWorkitem workItem : workItems) {
          targetObjectIds.put(workItem.ProcessInstance.TargetObjectId,workItem.Id);
      }
    }
    else{
      List<ProcessInstanceStep> approvedrecords=[SELECT Id, StepStatus,ProcessInstance.TargetObjectId, CreatedDate,Actor.Name, Comments FROM ProcessInstanceStep where StepStatus='Approved'  and ProcessInstance.TargetObject.Type='Expense_Claim__c' and ActorId= :UserInfo.getUserId()];
        for (ProcessInstanceStep workItem : approvedrecords) {
          targetObjectIds.put(workItem.ProcessInstance.TargetObjectId,workItem.Id);
      }
    }
     Map<Id, Travel_Request__c> travelrequestmap = new Map<Id, Travel_Request__c>(
          [SELECT Id, Employee__r.Name, Destination__c,Description__c,Date_of_Departure__c	,Date_of_Return__c	,Purpose_of_Visit1__c	,Billed_to_Customer__c	,Project__c,Mode_of_Transport__c,CurrencyIsoCode,Do_you_have_an_existing_Travel_Card__c,Travel_Card_Number__c,Status__c FROM Travel_Request__c WHERE Id IN :targetObjectIds.keyset()]
      );
      for (Travel_Request__c workItem : travelrequestmap.values()) {
        approveWrapper wrap = new approveWrapper();
        wrap.Employee_Name=workItem.Employee__r.Name;
        wrap.des=workItem.Destination__c;
        wrap.descrip=workItem.Description__c;
        wrap.Id=workItem.Id;
        if(status=='getPendingApprovals'){
        wrap.workitemid=targetObjectIds.get(workItem.Id);
        }
        wrap.datedep=workItem.Date_of_Departure__c;
        wrap.dateret=workItem.Date_of_Return__c;
        wrap.purpose=workItem.Purpose_of_Visit1__c;
        wrap.mode=workItem.Mode_of_Transport__c;
        appwrap.add(wrap);
      }
      return appwrap;
  }
   @AuraEnabled
  public static void approveRecord(String workItemId) {
      Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
      req.setAction('Approve');
      req.setWorkitemId(workItemId);
      Approval.ProcessResult result = Approval.process(req);
      if (!result.isSuccess()) {
          throw new AuraHandledException('Approval failed: ' + result.getErrors()[0].getMessage());
      }
  }
   @AuraEnabled
  public static void rejectRecord(String workItemId) {
      Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
      req.setAction('Reject');
      req.setWorkitemId(workItemId);
      Approval.ProcessResult result = Approval.process(req);
      if (!result.isSuccess()) {
          throw new AuraHandledException('Rejection failed: ' + result.getErrors()[0].getMessage());
      }
  }
    
   public class billsWrapper{
                            @AuraEnabled 
                            public String filename;
                            @AuraEnabled 
                            public String travelcardno;
                            @AuraEnabled 
                            public String recId;
                              @AuraEnabled 
                            public Boolean existingtravelcard;
                             @AuraEnabled 
                            public String fileid;
                             @AuraEnabled 
                          public Integer id;
                            @AuraEnabled 
                            public String parentId;
                            @AuraEnabled 
                            public Boolean status;
                             @AuraEnabled 
                          public string url;
                        }
                         public class approveWrapper{
                          @AuraEnabled 
                          public String des;
                            @AuraEnabled 
                          public String descrip;
                            @AuraEnabled 
                          public String status;
                          @AuraEnabled 
                          public String Employee_Name;
                          @AuraEnabled 
                          public date datedep;
                          @AuraEnabled 
                          public date dateret;
                          @AuraEnabled 
                          public String Id;
                          @AuraEnabled 
                          public String purpose;
                          @AuraEnabled 
                          public String mode;
                            @AuraEnabled 
                          public String workitemid;
                           
}
}