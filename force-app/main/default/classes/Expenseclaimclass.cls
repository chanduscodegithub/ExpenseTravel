/**
* @File Name : Expenseclaimclass.cls
* @Description :
* @Author :yuvathi Lakkaraju
* @Last Modified By :
* @Last Modified On : January 7, 2025
* @Modification Log :
*==============================================================================
* Ver | Date | Author | Modification
*==============================================================================
* 1.0 | January 7, 2025 |   | Initial Version
**/

public with sharing class Expenseclaimclass {

@AuraEnabled(cacheable=true)
  public static List<Expense_Claim__c> getexpenseclaimdata() {
      String empid =[SELECT Id, Name, Email_ID__c,Department__c, Country__c
                      FROM Employee__c where Email_ID__c =:UserInfo.getUserEmail()].Id;
                      system.debug('UserInfo.getUserEmail()'+UserInfo.getUserEmail());
                      system.debug('empid'+empid);
      return [SELECT Id, Employee_ID__r.Name, Department__c,Currency__c,Expense_Category__c,Expense_Requesting_Date__c,Bill_Amount__c,Employee_Comments__c,Status__c  FROM Expense_Claim__c where Employee_ID__c=:empid];
  }
  @AuraEnabled(cacheable=true)
  public static Employee__c getloggindata() {
      
      return [SELECT Id, Name, Email_ID__c,Department__c, Country__c,ReportingTo__r.SF_User__c, BU_Head__r.SF_User__c
                      FROM Employee__c where Email_ID__c =:UserInfo.getUserEmail()];
  }
  @AuraEnabled
  public static void deleterecords(String records) {
List<Object> recordsList = (List<Object>)System.JSON.deserializeUntyped(records);
  List<Id> expbills= new List<Id>();
  for (object record : recordsList) {
          Map<String, Object> m = (Map<String, Object>)record;
          
          
          if(m.containsKey('fileid'))
          {
                String fileId=(String)m.get('fileid');
                if(fileId!=null)
                {
              GoogleDriveIntegrationNew.deleteFileFromDrive(fileId);
                }
          }
          if(m.containsKey('recId'))
          {
              String Id=(String)m.get('recId');
              expbills.add(Id);
          }
  }
      if(expbills.size()>0)
      {
    List<Expense_Bill__c> bills=[select id from Expense_Bill__c where Id IN:expbills];
    delete bills;
      }
  }
  
    @AuraEnabled
  public static void createrecords(String records,string parentid,String status,String rm ,String ccm ) {
        system.debug('records'+records);
        //Expense_Claim__c ex= new Expense_Claim__c();
       
        //List<Map<String, Object>> recordsList = (List<Map<String, Object>>)System.JSON.deserializeUntyped(records);
        List<Object> recordsList = (List<Object>)System.JSON.deserializeUntyped(records);
        if(recordsList.size()>0)
        {
        //Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(records);
        system.debug('records'+recordsList);
        //Map<String, Object> m = (Map<String, Object>)obj;

          ///system.debug('parsed'+parsed);
          List<Expense_Bill__c> expbills= new List<Expense_Bill__c>();
          
        for (object record : recordsList) {
          Map<String, Object> m = (Map<String, Object>)record;
          
          Expense_Bill__c bills = new Expense_Bill__c();
          if(m.containsKey('file'))
          {

              String filename=(String)m.get('filename');
              String filedata=(String)m.get('file');
              system.debug('filename'+filename);
                system.debug('filedata'+filedata);
                if(filedata!=null)
                {
              try{
                  GoogleDriveIntegrationNew.GoogleDriveFile gdrive = GoogleDriveIntegrationNew.uploadFile(filename, filedata, '1tUWCdaAASOB9ERMd0IvfZXXUvHrcCLyu', getAccessToken());
                  bills.Name = gdrive.fileUrl;
                  bills.fileId__c = gdrive.fileId;
                  bills.Bills__c=gdrive.filename;

              /*GoogleDriveFile gdrive=GoogleDriveIntegrationNew.uploadFile(filename,filedata,'1tUWCdaAASOB9ERMd0IvfZXXUvHrcCLyu',getAccessToken() );
              bills.Name=gdrive.fileUrl;
              bills.fileId__c=gdrive.fileId;
              }*/
              }
              catch (Exception e) {
          if (e.getMessage().contains('401')) { 
              String newToken=GoogleDriveIntegrationNew.refreshAccessToken();
              GoogleDriveIntegrationNew.GoogleDriveFile gdrive =GoogleDriveIntegrationNew.uploadFile(filename,filedata,'1tUWCdaAASOB9ERMd0IvfZXXUvHrcCLyu',newToken);
                bills.Name = gdrive.fileUrl;
                bills.fileId__c = gdrive.fileId;
                  bills.Bills__c=gdrive.filename;
          } else {
              throw new AuraHandledException('err: ' + e.getMessage());
          }
              }
          
          
              }
              bills.Comments__c=(String)m.get('comments');
              bills.Amount_Spent_date__c=Date.valueOf((String)m.get('amtsptdate'));
              bills.Bill_Amount__c=Integer.valueOf((String)m.get('billamount'));
              bills.Expense_Claim__c=parentid;
              bills.Bill_Number__c=(String)m.get('billnumber');
            
              expbills.add(bills);
          }
          
          }
          Database.insert(expbills, true);
          
          //insert expbills;
          
        }
         if(status=='Draft')
        {
        update 	new Expense_Claim__c(id = parentid,Status__c=status,Reporting_To__c=rm,Cost_center_manager__c=ccm);
        }
        if(status=='Waiting For Approval')
        {
          update 	new Expense_Claim__c(id = parentid,Status__c=status,Reporting_To__c=rm,Cost_center_manager__c=ccm);
           Expense_Claim__c ec=[select id,Expense_Category__c,Country__c from Expense_Claim__c where id=:parentid ];
          Approval.ProcessSubmitRequest req1 =  new Approval.ProcessSubmitRequest();
          req1.setComments('Submitting request for approval.');
          req1.setObjectId(parentid);
           String loggedUserId = UserInfo.getUserId();
            req1.setSubmitterId(loggedUserId);
          if(ec.Expense_Category__c=='EWB request' && ec.Country__c=='India'){
          req1.setProcessDefinitionNameOrId('EWB_Approval_Process');
          }
          else if(ec.Expense_Category__c=='EWB request' && ec.Country__c=='Australia'){
          req1.setProcessDefinitionNameOrId('EWB_Approval_Process_ANZ');
          }
           else if(ec.Expense_Category__c=='EWB request' && ec.Country__c=='USA'){
                      req1.setProcessDefinitionNameOrId('EWB_Approval_Process_USA');
          }
           else if(ec.Expense_Category__c=='Certification fee' && ec.Country__c=='India'){
                      req1.setProcessDefinitionNameOrId('Certification_Approval_Process_India');
          }
           else if(ec.Expense_Category__c=='Certification fee' && ec.Country__c=='Australia'){
                      req1.setProcessDefinitionNameOrId('Certification_Approval_Process_ANZ');

          }
           else if(ec.Expense_Category__c=='Certification fee' && ec.Country__c=='USA'){
                      req1.setProcessDefinitionNameOrId('Certification_Approval_Process_USA');

          }
           else if(ec.Expense_Category__c!='EWB request' && ec.Country__c=='India' && ec.Expense_Category__c!='Certification fee'){
                      req1.setProcessDefinitionNameOrId('Other_Approval_Process_India');

          }
           else if(ec.Expense_Category__c!='EWB request' && ec.Country__c=='Australia' && ec.Expense_Category__c!='Certification fee'){
                      req1.setProcessDefinitionNameOrId('Other_Approval_Process_ANZ');

          }
           else if(ec.Expense_Category__c!='EWB request' && ec.Country__c=='USA' && ec.Expense_Category__c!='Certification fee'){
                      req1.setProcessDefinitionNameOrId('Other_Approval_Process_USA');

          }
          req1.setSkipEntryCriteria(true);
      
      // Submit the approval request for the account
        try {
      Approval.ProcessResult result = Approval.process(req1);
       if (result.isSuccess()) {
                    System.debug('Travel request submitted for approval successfully.');
                } else {
                        System.debug('Error in submission: ' + result.getErrors());

                }
        }
          catch (Exception e) {
            System.debug('Error submitting for approval: ' + e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
        }
      
      
      

  }
  @AuraEnabled(cacheable=true)
public static Boolean isbillUnique(Integer bnumber , String recordId){
  if(recordId!=null)
    {
    List<Expense_Claim__c > accReq = [SELECT Id FROM Expense_Claim__c  WHERE Bill_Number__c =:bnumber AND Id !=: recordId ];  
    return accReq.isEmpty();
    }else{
    List<Expense_Claim__c > accReq = [SELECT Id FROM Expense_Claim__c  WHERE Bill_Number__c =:bnumber]; 
    return accReq.isEmpty(); 
    }

}
  private static String getAccessToken() {
      GoogleDriveTokens__c googleTokenSettings = GoogleDriveTokens__c.getInstance('GoogleTokenRecord');
      return googleTokenSettings.AccessToken__c;
  }
  @AuraEnabled(cacheable=true)
  public static List<billsWrapper> getbillsdata(Id recordId)

{
  List<billsWrapper> billsdata= new List<billsWrapper>();
  List<Expense_Bill__c> data=[select id,Amount_Spent_date__c, Name,Bills__c, Bill_Amount__c,Bill_Number__c,Comments__c,Expense_Claim__c,Expense_Claim__r.Status__c  from Expense_Bill__c where Expense_Claim__c=:recordId];
  system.debug('data'+data);
  Integer i=-1;
  for(Expense_Bill__c bill:data){
      i=i+1;
        billsWrapper bw= new billsWrapper();
        bw.filename=bill.Bills__c;
        bw.amtsptdate=bill.Amount_Spent_date__c;
        bw.comments=bill.Comments__c;
        bw.recId=bill.Id;
        bw.billamount=bill.Bill_Amount__c;
        bw.billnumber=bill.Bill_Number__c;
        bw.parentId=bill.Expense_Claim__c;
        bw.url=bill.Name;
        if(bill.Expense_Claim__r.Status__c=='Draft')
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
              WHERE ActorId = :UserInfo.getUserId() AND ProcessInstance.TargetObject.Type ='Expense_Claim__c'];
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
    
      Map<Id, Expense_Claim__c> expenseClaimMap = new Map<Id, Expense_Claim__c>(
          [SELECT Id, Employee_ID__r.Name, Department__c,Currency__c,Expense_Category__c,Expense_Requesting_Date__c,Bill_Amount__c,Employee_Comments__c,Status__c from Expense_Claim__c WHERE Id IN :targetObjectIds.keyset()]
      );
      for (Expense_Claim__c workItem : expenseClaimMap.values()) {
        approveWrapper wrap = new approveWrapper();
        wrap.Employee_Name=workItem.Employee_ID__r.Name;
        wrap.expdate=workItem.Expense_Requesting_Date__c;
        wrap.comments=workItem.Employee_Comments__c;
        wrap.Id=workItem.Id;
        if(status=='getPendingApprovals'){
        wrap.workitemid=targetObjectIds.get(workItem.Id);
        }
        wrap.category=workItem.Expense_Category__c;
        wrap.department=workItem.Department__c;
        wrap.billamount=workItem.Bill_Amount__c;
        wrap.curr=workItem.Currency__c;
        appwrap.add(wrap);
      }
      return appwrap;
  }

  @AuraEnabled
  public static void approveRecord(String workItemId,String comments) {
      Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
      req.setAction('Approve');
      req.setComments(comments);
      req.setWorkitemId(workItemId);
      Approval.ProcessResult result = Approval.process(req);
      if (!result.isSuccess()) {
          throw new AuraHandledException('Approval failed: ' + result.getErrors()[0].getMessage());
      }
  }

  @AuraEnabled
  public static void rejectRecord(String workItemId,String comments) {
      Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
      req.setAction('Reject');
      req.setComments(comments);
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
                          public String empname;
                          @AuraEnabled 
                          public date amtsptdate;
                          @AuraEnabled 
                          public String comments;
                            @AuraEnabled 
                          public String recId;
                            @AuraEnabled 
                          public Decimal billamount;
                            @AuraEnabled 
                          public String fileid;
                          @AuraEnabled 
                          public String parentId;
                            @AuraEnabled 
                          public string billnumber;
                            @AuraEnabled 
                          public Integer id;
                            @AuraEnabled 
                          public Boolean status;
                          @AuraEnabled 
                          public string url;
                      }
                        public class approveWrapper{
                          @AuraEnabled 
                          public String category;
                            @AuraEnabled 
                          public String department;
                            @AuraEnabled 
                          public String status;
                          @AuraEnabled 
                          public String Employee_Name;
                          @AuraEnabled 
                          public date expdate;
                          @AuraEnabled 
                          public String comments;
                          @AuraEnabled 
                          public String Id;
                          @AuraEnabled 
                          public Decimal billamount;
                            @AuraEnabled 
                          public String workitemid;
                            @AuraEnabled 
                          public String curr;
                        
                          
                      }
}