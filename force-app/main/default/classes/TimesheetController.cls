public without sharing class TimesheetController{
    public class emp_msg_wrapper{
        @AuraEnabled
        public Employee__c empUser {get;set;}
        @AuraEnabled
        public String msgBelow40;
        @AuraEnabled
        public String msgAbove48;
        @AuraEnabled
        public String msgOnTime;
        @AuraEnabled
        public String staticLeaveAddress;
        @AuraEnabled
        public String loadReportButton;
        @AuraEnabled
        public String loadCarouselBanner;
    }
    /**
    * @author       Maaz
    * @date         2022-04-26
    * @description  Get the employee details with messages and warning from the custom metadatatype.
    * @param        empID - Employee Id.
    * @return       emp_msg_wrapper.
    */
    @AuraEnabled(cacheable=true)
    public static emp_msg_wrapper getEmployee(String empID){
        emp_msg_wrapper emp_msg = new emp_msg_wrapper();
        emp_msg_wrapper blankObj = new emp_msg_wrapper();
        try {
            if(empID==null || empID==''){
                emp_msg.empUser = [SELECT Id, Name, Email_ID__c, Employee_Type__c, ReportingTo__r.SF_User__c FROM Employee__c WHERE SF_User__c=:UserInfo.getUserId()  AND Active__c = true];
            }else{
                emp_msg.empUser = [SELECT Id, Name, Email_ID__c, Employee_Type__c, ReportingTo__r.SF_User__c FROM Employee__c WHERE Id=:empID];
            }
            emp_msg.msgBelow40 = Timesheet_Message__mdt.getInstance('Message_For_less_than_40hrs')?.Message__c;
            emp_msg.msgAbove48 = Timesheet_Message__mdt.getInstance('Message_for_more_than_48hrs')?.Message__c;
            emp_msg.msgOnTime = Timesheet_Message__mdt.getInstance('Message_for_on_time')?.Message__c;
            emp_msg.loadCarouselBanner = Load_Timesheet_Component__mdt.getInstance('LoadCarousel')?.Load__c;
            emp_msg.loadReportButton = Load_Timesheet_Component__mdt.getInstance('LoadReportButton')?.Load__c;
        } catch (Exception e) {
            System.debug('Exception occurred>>'+e.getMessage() + ' at ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        /*if(emp_msg.empUser.Name == 'Maaz Rahman'||emp_msg.empUser.Name == 'Mayukh Mukherji' || emp_msg.empUser.Name =='Ramachandran S' || emp_msg.empUser.Name =='Mavulate Veerendra Veerendra Varma' || emp_msg.empUser.Name =='Saravanakumar Subramanian' || emp_msg.empUser.Name == 'Nikhila Narapareddy' || emp_msg.empUser.Name == 'Rashmi Nemiraj' || emp_msg.empUser.Name == 'Sanjay Kumar H'){
            return emp_msg;
        }else{
            return blankObj;
        }*/
        return emp_msg;
    }
    public class TeamAlloc_TimeSheet_Wrapper{
        @AuraEnabled
        public List<Delivery__c> allTS {get;set;}
        @AuraEnabled
        public List<TeamAllocation__c> TeamAllocList {get;set;}
        @AuraEnabled
        public Boolean submitted;
        @AuraEnabled
        public String parentTS;
        @AuraEnabled
        public Map<String,String> allFiles; 
    }
    
     public class fileDetails{
        public String fileName;
        public String fileData;
    }
    
    /**
    * @author       Maaz
    * @date         2022-04-26
    * @description  Get the employee details with messages and warning from the custom metadatatype.
    * @param        empId - Employee Id.
    * @param        startString - From Date in String.
    * @param        endString - End Date in String.
    * @return       TeamAlloc_TimeSheet_Wrapper.
    */
    @AuraEnabled
    public static TeamAlloc_TimeSheet_Wrapper getTeam_Sheet(String empId, String startString, String endString){
        Date startDate = Date.valueOf(startString);
        Date endDate = Date.valueOf(endString);
        TeamAlloc_TimeSheet_Wrapper TATS = new TeamAlloc_TimeSheet_Wrapper();
        TATS.submitted = false;
        try {
            TATS.allTS = [SELECT Name, Date__c ,Time_in_Hours__c, Customer_Engagement__c, Team_Allocation__c, Category__c, Sub_Category__c, Description__c,Timesheet_Approval__r.Approval_Status__c FROM Delivery__c WHERE Employee_Name__c=:empId AND Date__c >= :startDate AND Date__c <= :endDate];
            TATS.TeamAllocList = [SELECT Id, Project__r.Name, ReportingTo__r.Name, Region__c, EndDate__c, StartDate__c, Billing_Status__c, AllocationPercentage__c FROM TeamAllocation__c WHERE EmployeeName__c=:empId AND ((StartDate__c>= :startDate AND EndDate__c>= :endDate AND StartDate__c<= :endDate) OR (StartDate__c<= :startDate AND EndDate__c>= :endDate)OR(StartDate__c<= :startDate AND EndDate__c<= :endDate AND EndDate__c>= :startDate)OR(StartDate__c>= :startDate AND EndDate__c<= :endDate) )];
            Team_Timesheet__c tempTTS = [SELECT Id, Status__c FROM Team_Timesheet__c WHERE Employee_Name__c=:empId AND Week_Start_Date__c=:startDate];
            TATS.parentTS = tempTTS?.Id;
            if(tempTTS?.Status__c=='Submitted'||tempTTS?.Status__c=='Approved' || tempTTS?.Status__c=='Partially Approved'){
                TATS.submitted = true;
            }else{
                TATS.submitted = false;
            }
        } catch (Exception e) {
            System.debug('Exception occurred>>'+e.getMessage() + ' at ' + e.getLineNumber());
            //throw new AuraHandledException(e.getMessage());
        }
        return TATS;
    }
    /**
    * @author       Maaz
    * @date         2022-04-26
    * @description  Save the details submitted by the user.
    * @param        stringifiedObj - Stringified object of all inputs from the User.
    * @param        save - Boolean for the Submit/Draft status.
    * @param        empId - Employee Id.
    * @param        startStr - Week Start Date in String
    * @param        reportingManagerId - Reporting Manager Id to populate User lookup field in Team Timesheet Object
    * @param        parentTS - If existing, Team Timesheet Id which is parent object.
    * @return       null
    */
    @AuraEnabled
    public static void saveTS(String stringifiedObj, Boolean save, String empID, String startStr, String reportingManagerId, String parentTS,String fileData){
        List<Object> generatedArray = (List<Object>)JSON.deserializeUntyped(stringifiedObj);
        Map<String,fileDetails> projectFileMap = new Map<String,fileDetails>();
        List<Delivery__c> toSaveTS = new List<Delivery__c>();
        List<Delivery__c> toUpdateTS = new List<Delivery__c>();
        List<String> existingTSId = new List<String>();
        Employee__c empInfo = [SELECT Id, SF_User__c FROM Employee__c WHERE Id=:empID];
        Team_Timesheet__c TTS;
        
        try {
            if(parentTS==null){
                Date d1 = Date.valueOf(startStr);
                TTS = new Team_Timesheet__c(Employee_Name__c=empID, Week_Start_Date__c=d1, Reporting_Manager__c=reportingManagerId);
                if(!Test.isRunningTest())
                insert TTS;
            }else{
                TTS = [SELECT Id, Total_Hours__c,Total_Mins__c,Name,CRMIT_Holiday_Hours__c FROM Team_Timesheet__c WHERE Id=:parentTS];
            }
            if(save){
                TTS.Status__c = 'Submitted';
            }else{
                TTS.Status__c = 'Draft';
            }
            for(Object eachProject: generatedArray){
                Map<String,Object> eachProjectMap = (Map<String, Object>)eachProject;
                if(save){
                    
                    fileDetails file1 = new fileDetails();
                    file1.fileName = (String) eachProjectMap.get('fileName');
                    file1.fileData = (String) eachProjectMap.get('filedata');
                    String projName = (String) eachProjectMap.get('projectName');
                    if(projName != 'Others' && file1.fileName != null && file1.fileName != ''){
                        projectFileMap.put((String) eachProjectMap.get('projectName'),file1);
                    }
                    
                }
                List<Object> TSList = (List<Object>)eachProjectMap.get('eachProject');
                for(Object eachTS: TSList){
                    Map<String,Object> eachTSMap = (Map<String, Object>)eachTS;
                    Map<String, Object> eachDate = (Map<String, Object>)eachTSMap.get('eachDate');
                    if((Boolean)eachDate.get('existing')){
                        existingTSId.add((String)eachDate.get('tsId'));
                    }
                }
            }
            Map<Id, Delivery__c> existingTSMap = new Map<Id, Delivery__c>([SELECT Name, Date__c ,Time_in_Hours__c, Customer_Engagement__c, Team_Allocation__c, Category__c, Sub_Category__c, Description__c FROM Delivery__c WHERE Employee_Name__c=:empID AND Id=:existingTSId]);
            for(Object eachProject: generatedArray){
                Map<String,Object> eachProjectMap = (Map<String, Object>)eachProject;
                List<Object> TSList = (List<Object>)eachProjectMap.get('eachProject');
                for(Object eachTS: TSList){
                    Delivery__c newTS = new Delivery__c();
                    Map<String,Object> eachTSMap = (Map<String, Object>)eachTS;
                    Map<String, Object> eachDate = (Map<String, Object>)eachTSMap.get('eachDate');
                    if(!((Boolean)eachDate.get('existing'))){
                        if(String.isNotBlank((String)eachDate.get('category')) && String.isNotBlank((String)eachDate.get('sub_category')) && String.isNotBlank(String.valueOf(eachDate.get('work_hour'))) && String.isNotBlank((String)eachDate.get('description'))){
                            newTS.Customer_Engagement__c = (String)eachDate.get('projectId');
                            newTS.Team_Allocation__c = (String)eachDate.get('projectAllocId');
                            newTS.Date__c = Date.valueOf((String)eachDate.get('date'));
                            newTS.Category__c = (String)eachDate.get('category');
                            newTS.Sub_Category__c = (String)eachDate.get('sub_category');
                            newTS.Time_in_Hours__c = Double.valueOf(eachDate.get('work_hour'));
                            newTS.Description__c = (String)eachDate.get('description');
                            newTS.Employee_Name__c = empID;
                            newTS.Team_Timesheet__c = TTS.Id;
                            toSaveTS.add(newTS);
                        }
                    }else{
                        if(String.isNotBlank((String)eachDate.get('category')) && String.isNotBlank((String)eachDate.get('sub_category')) && Double.valueOf(eachDate.get('work_hour'))!=null && String.isNotBlank((String)eachDate.get('description'))){
                            Delivery__c eachExistingTS = existingTSMap.get((String)eachDate.get('tsId'));
                            eachExistingTS.Date__c = Date.valueOf((String)eachDate.get('date'));
                            eachExistingTS.Category__c = (String)eachDate.get('category');
                            eachExistingTS.Sub_Category__c = (String)eachDate.get('sub_category');
                            eachExistingTS.Time_in_Hours__c = Double.valueOf(eachDate.get('work_hour'));
                            eachExistingTS.Description__c = (String)eachDate.get('description');
                            toUpdateTS.add(eachExistingTS);
                        }
                    }
                }
            }
            insert toSaveTS;
            update toUpdateTS;
            decimal crmitholhrs=0;
            decimal totalhours=0;
            decimal totalmins=0;
            
            map<string, map<id,decimal>> projmap=new map<string, map<id,decimal>>();
            List<Delivery__c> delListforupdate=[select Id,Name,Time_in_Hours__c,Time_in_Mins__c,Category__c,Sub_Category__c,Customer_Engagement__c,Billing_Status__c from Delivery__c where Team_Timesheet__c=:TTS.id];
            system.debug('delListforupdate>'+delListforupdate);
            
            for(Delivery__c del:delListforupdate){
                Decimal billableHrs = 0.00;
                Decimal nonBillableHrs = 0.00;
                Decimal leaveHrs = 0.00;
                if(del.Category__c=='CRMIT Holiday'){
                    crmitholhrs +=del.Time_in_Hours__c;
                    TTS.CRMIT_Holiday_Hours__c=crmitholhrs;}
                totalhours +=del.Time_in_Hours__c;
                TTS.Total_Hours__c=totalhours;
                totalmins +=del.Time_in_Mins__c;
                TTS.Total_Mins__c=totalmins;
                if(del.Category__c=='Leave' || del.Billing_Status__c=='Long Leave'){
                    if(projmap.containsKey('Leave')) {
                       if(projmap.get('Leave').containsKey(del.Customer_Engagement__c)){
                        decimal leavehr=projmap.get('Leave').get(del.Customer_Engagement__c);
                        leaveHrs = leavehr + del.Time_in_Hours__c;
                        Map<Id,Decimal> projtimemap = new Map<Id,Decimal>{del.Customer_Engagement__c =>leaveHrs };
                            projmap.get('Leave').put(del.Customer_Engagement__c,leaveHrs);
                    }
                        else{
                            leaveHrs += del.Time_in_Hours__c;
                        Map<Id,Decimal> projtimemap = new Map<Id,Decimal>{del.Customer_Engagement__c =>leaveHrs };
                            //projmap.put('Leave',projtimemap);
                            projmap.get('Leave').put(del.Customer_Engagement__c,leaveHrs); 
                        }
                    }
                    else{
                        leaveHrs += del.Time_in_Hours__c;
                        Map<Id,Decimal> projtimemap = new Map<Id,Decimal>{del.Customer_Engagement__c =>leaveHrs };
                            projmap.put('Leave',projtimemap);
                    }
                }else if(del.Billing_Status__c == 'Billable'){
                    if(projmap.containsKey('Billable')){ 
                       if(projmap.get('Billable').containsKey(del.Customer_Engagement__c)){
                        decimal billHrs=projmap.get('Billable').get(del.Customer_Engagement__c);
                        billableHrs = billHrs + del.Time_in_Hours__c;
                        //Map<Id,Decimal> projtimemap = new Map<Id,Decimal>{del.Customer_Engagement__c =>billableHrs };
                            projmap.get('Billable').put(del.Customer_Engagement__c,billableHrs);
                           system.debug('219>>>>'+projmap);
                       }
                        else{
                             billableHrs += del.Time_in_Hours__c;
                        //Map<Id,Decimal> projtimemap = new Map<Id,Decimal>{del.Customer_Engagement__c =>billableHrs };
                           // projmap.put('Billable',projmap.get('Billable')projtimemap);
                           projmap.get('Billable').put(del.Customer_Engagement__c,billableHrs);
                             system.debug('226>>>>'+projmap);
                        }
                    }
                    else{
                        billableHrs += del.Time_in_Hours__c;
                        Map<Id,Decimal> projtimemap = new Map<Id,Decimal>{del.Customer_Engagement__c =>billableHrs };
                            projmap.put('Billable',projtimemap);
                        system.debug('233>>>>'+projmap);
                    }
                }else{
                    if(projmap.containsKey('NonBillable')) {
                        if(projmap.get('NonBillable').containsKey(del.Customer_Engagement__c)){
                        decimal nonbillHrs=projmap.get('NonBillable').get(del.Customer_Engagement__c);
                        nonBillableHrs = nonbillHrs + del.Time_in_Hours__c;
                        Map<Id,Decimal> projtimemap = new Map<Id,Decimal>{del.Customer_Engagement__c =>nonBillableHrs };
                            projmap.get('NonBillable').put(del.Customer_Engagement__c,nonBillableHrs);
                            system.debug('242>>>>'+projmap);
                    }
                        else{
							nonBillableHrs += del.Time_in_Hours__c;
                           Map<Id,Decimal> projtimemap = new Map<Id,Decimal>{del.Customer_Engagement__c =>nonBillableHrs };
                            //projmap.put('NonBillable',projtimemap);   
                            projmap.get('NonBillable').put(del.Customer_Engagement__c,nonBillableHrs);   
                            system.debug('249>>>>'+projmap);
                        }
                    }
                    else{
                        nonBillableHrs += del.Time_in_Hours__c;
                        Map<Id,Decimal> projtimemap = new Map<Id,Decimal>{del.Customer_Engagement__c =>nonBillableHrs };
                            projmap.put('NonBillable',projtimemap);
                        system.debug('256>>>>'+projmap);
                    }
                }
            }
           if(!Test.isRunningTest())
            update TTS;
			
			/* @author 	   : Harish 
			   Date    	   : 13-12-2022
			   Description : New Code to handle Approval based on Project Manager 
			*/
			
		     		Set<Id>TSId = new Set<Id>();
				Map<String,Timesheet_Approval__c> TSApprovalMap = new Map<String,Timesheet_Approval__c>(); //Store TimeSheet,Project,ProjectManagerId as a key followed by record as value
				//List<Timesheet_Approval__c>TSAppUpsert = new List<Timesheet_Approval__c>();
				//List<Timesheet_Approval__c>TSAppUpdate = new List<Timesheet_Approval__c>();
				for(Timesheet_Approval__c TSA : [Select Id,Approver__c,Customer_Engagement__c,Employee__c,Timesheet__c,Approval_Status__c,Total_Billable_Hours__c,Total_Non_Billable_hours__c,Total_Leave_Hours__c from Timesheet_Approval__c where Timesheet__c=:TTS.Id and Employee__c =:empID])
				{
					TSApprovalMap.put(String.valueof(TSA.Timesheet__c) + String.valueof(TSA.Customer_Engagement__c),TSA);
				}
				
				
				if(toSaveTS.size()>0){
					for(Delivery__c TS : toSaveTS)
						TSId.add(TS.Id);
				}
				if(toUpdateTS.size()>0)
				{
					for(Delivery__c TS : toUpdateTS)
						TSId.add(TS.Id);
				}
			
				for(Delivery__c TS : [Select Id,Customer_Engagement__c,Customer_Engagement__r.Name,Customer_Engagement__r.ProjectManager__c,Customer_Engagement__r.Timesheet_Approved_by_RM__c,Employee_Name__c,Team_Timesheet__c,Team_Timesheet__r.Status__c,Team_Timesheet__r.Reporting_Manager__c,Timesheet_Approval__c,Billing_Status__c,Category__c,Time_in_Hours__c from Delivery__c where Id=:TSId])
				{
                    
					if(!TSApprovalMap.Containskey(String.valueof(TS.Team_Timesheet__c)+String.valueof(TS.Customer_Engagement__c)))
					{
						Timesheet_Approval__c TSA = new Timesheet_Approval__c();
						TSA.Approval_Status__c = TS.Team_Timesheet__r.Status__c;
						if(TS.Customer_Engagement__r.Timesheet_Approved_by_RM__c ==false && UserInfo.getUserId() != TS.Customer_Engagement__r.ProjectManager__c)
						TSA.Approver__c = TS.Customer_Engagement__r.ProjectManager__c;
						else
                            TSA.Approver__c = TS.Team_Timesheet__r.Reporting_Manager__c;
                        TSA.Customer_Engagement__c = TS.Customer_Engagement__c;
                        TSA.Employee__c = TS.Employee_Name__c;
                        TSA.Timesheet__c = TS.Team_Timesheet__c;
                        if(projmap.containsKey('Billable')){
                            TSA.Total_Billable_Hours__c = projmap.get('Billable').get(TS.Customer_Engagement__c)!=null ? projmap.get('Billable').get(TS.Customer_Engagement__c) : 0.00;
                        }else{
                                TSA.Total_Billable_Hours__c=0.00;
                            }
                        if(projmap.containsKey('NonBillable')){
                        TSA.Total_Non_Billable_hours__c = projmap.get('NonBillable').get(TS.Customer_Engagement__c)!=null ? projmap.get('NonBillable').get(TS.Customer_Engagement__c) : 0.00 ;
                        }
                        else{
                            TSA.Total_Non_Billable_hours__c=0.00;
                        }
                        if(projmap.containsKey('Leave')){
                        TSA.Total_Leave_Hours__c = projmap.get('Leave').get(TS.Customer_Engagement__c)!=null ? projmap.get('Leave').get(TS.Customer_Engagement__c) : 0.00;}
                        else{
                            TSA.Total_Leave_Hours__c=0.00;
                        }
                        
                        TSA.Total_Hours__c =TSA.Total_Billable_Hours__c+TSA.Total_Non_Billable_hours__c+TSA.Total_Leave_Hours__c;
                        
						TSApprovalMap.put(String.valueof(TSA.Timesheet__c)+String.valueof(TSA.Customer_Engagement__c),TSA);
						//TSAppUpsert.add(TSA);
						
					}
					else if(TSApprovalMap.Containskey(String.valueof(TS.Team_Timesheet__c)+String.valueof(TS.Customer_Engagement__c)))
					{
                        if(TSApprovalMap.get(String.valueof(TS.Team_Timesheet__c)+String.valueof(TS.Customer_Engagement__c)) !=null)
                        {
                            
                            Timesheet_Approval__c TSA = TSApprovalMap.get(String.valueof(TS.Team_Timesheet__c)+String.valueof(TS.Customer_Engagement__c));
                            if(projmap.containsKey('Billable')){
                            TSA.Total_Billable_Hours__c = projmap.get('Billable').get(TS.Customer_Engagement__c)!=null ? projmap.get('Billable').get(TS.Customer_Engagement__c) : 0.00;}else{
                                TSA.Total_Billable_Hours__c=0.00;
                            }
                        if(projmap.containsKey('NonBillable')){
                        TSA.Total_Non_Billable_hours__c = projmap.get('NonBillable').get(TS.Customer_Engagement__c)!=null ? projmap.get('NonBillable').get(TS.Customer_Engagement__c) : 0.00;}
                        else{
                            TSA.Total_Non_Billable_hours__c=0.00;
                        }
                        if(projmap.containsKey('Leave')){
                        TSA.Total_Leave_Hours__c = projmap.get('Leave').get(TS.Customer_Engagement__c)!=null ? projmap.get('Leave').get(TS.Customer_Engagement__c) : 0.00;}
                        else{
                            TSA.Total_Leave_Hours__c=0.00;
                        }
                        
                        TSA.Total_Hours__c =TSA.Total_Billable_Hours__c+TSA.Total_Non_Billable_hours__c+TSA.Total_Leave_Hours__c;
                            if(TSA.Approval_Status__c !='Approved' && TSA.Approval_Status__c !='Submitted')
                                TSA.Approval_Status__c = TS.Team_Timesheet__r.Status__c;
                            TSApprovalMap.put(String.valueof(TSA.Timesheet__c)+String.valueof(TSA.Customer_Engagement__c),TSA);
                        }
                        
                    }
				}
				
				Map<String,Id>TSAppIdMap = new Map<String,Id>();
				system.debug('TSApprovalMap@@'+TSApprovalMap);
				if(TSApprovalMap.size()>0)
				{
					Upsert TSApprovalMap.values();
                    List<String> AllTimeSheetApprovalId = new List<String>();
                    for(Timesheet_Approval__c timeappro : TSApprovalMap.values()){
                        AllTimeSheetApprovalId.add(timeappro.Id);
                    }
                    
                    List<ContentVersion> conver = new List<ContentVersion>();
                    List<ContentDocumentLink> conDocLink = new List<ContentDocumentLink>();
                    for(Timesheet_Approval__c timeApproval : [Select Id,Name,Customer_Engagement__c,Customer_Engagement__r.Name from Timesheet_Approval__c where Id in:AllTimeSheetApprovalId]){
                        if(timeApproval.Customer_Engagement__r.Name != 'Others'){
                            fileDetails file = projectFileMap.get(timeApproval.Customer_Engagement__r.Name);
                            System.debug('file::'+file);
                            if(file != null){
                            ContentVersion cv = new ContentVersion();
                            cv.VersionData = EncodingUtil.base64Decode(file.fileData);  
                            cv.Title = file.fileName;
                            cv.PathOnClient = file.fileName;
                            cv.TimeSheetApprovalId__c = timeApproval.Id;
                            conver.add(cv);
                            }
                           
                        }
                    }
                    if(conver.size() > 0){
                        insert conver;
                        System.debug('conver::'+conver);
                        List<Id> converids = new List<Id>();
                        for(ContentVersion ver : conver){
                            converids.add(ver.Id);
                        }
                        
                        for(ContentVersion con : [Select Id,ContentDocumentId,TimeSheetApprovalId__c from ContentVersion where Id IN:converids]){
                           ContentDocumentLink cdl = new ContentDocumentLink();
                            cdl.ContentDocumentId = con.ContentDocumentId;
                            cdl.LinkedEntityId = con.TimeSheetApprovalId__c;
                            cdl.ShareType = 'V';
                            conDocLink.add(cdl);
                        }
                        
                        if(conDocLink.size() > 0){
                            insert conDocLink;
                        }
                        System.debug('conDocLink::'+conDocLink);
                    }
					for(String  TSA : TSApprovalMap.keyset())
						//TSAppIdMap.put(String.valueof(TSA.Timesheet__c)+String.valueof(TSA.Customer_Engagement__c),TSA.Id);
						TSAppIdMap.put(String.valueof(TSApprovalMap.get(TSA).Timesheet__c)+String.valueof(TSApprovalMap.get(TSA).Customer_Engagement__c),TSApprovalMap.get(TSA).Id);
                    }
            	system.debug('TSAppIdMap@@'+TSAppIdMap);
				List<Delivery__c>TSNewList = new List<Delivery__c>();
				if(toSaveTS.size()>0)
				{
					for(Delivery__c TS : toSaveTS)
					{
                        
						if(TSAppIdMap.containskey(String.valueof(TS.Team_Timesheet__c)+String.valueof(TS.Customer_Engagement__c)))
						TS.Timesheet_Approval__c = TSAppIdMap.get(String.valueof(TS.Team_Timesheet__c)+String.valueof(TS.Customer_Engagement__c));
						TSNewList.add(TS);
					}
					Update TSNewList;
					
				} 
				//Logic Ends
			
			
			
			
            Boolean deleteFlag = true;
            if(toUpdateTS?.size() == 0 && toSaveTS?.size() == 0){
                delete TTS;
                deleteFlag = false;
            }
            if(save && deleteFlag){
               
                Team_Timesheet__Share TSShare = new Team_Timesheet__Share();
                TSShare.ParentId = TTS.id;
                TSShare.UserOrGroupId = reportingManagerId;
                TSShare.AccessLevel = 'Edit';
                TSShare.RowCause = 'Manual';
               if(!test.isRunningTest())
                upsert TSShare;
                
                //Share Record Access to Project Manager
                List<Timesheet_Approval__Share>TSAppList = new List<Timesheet_Approval__Share>();
				for(String  TSA : TSApprovalMap.keyset())
                {
                    Timesheet_Approval__Share TSAppShare = new Timesheet_Approval__Share();
                    TSAppShare.ParentId = TSApprovalMap.get(TSA).Id;
                    TSAppShare.UserOrGroupId = TSApprovalMap.get(TSA).Approver__c;
                    TSAppShare.AccessLevel = 'Edit';
                    TSAppShare.RowCause = 'Manual';
                    TSAppList.add(TSAppShare);


                    Timesheet_Approval__Share TSAppShareRM = new Timesheet_Approval__Share();
                    TSAppShareRM.ParentId = TSApprovalMap.get(TSA).Id;
                    TSAppShareRM.UserOrGroupId = reportingManagerId;
                    TSAppShareRM.AccessLevel = 'Read';
                    TSAppShareRM.RowCause = 'Manual';        
                    TSAppList.add(TSAppShareRM);

                }
                 if(!test.isRunningTest())
                Upsert TSAppList;
                system.debug('TSAppList@@'+TSAppList);
				
				//Share TimeSheet Activity Record Access to Project Manager
				/*List<Delivery__Share>DelList = new List<Delivery__Share>();
				for(Delivery__c TA : [Select Id,Timesheet_Approval__c,Timesheet_Approval__r.Approver__c,Team_Timesheet__c,Team_Timesheet__r.Reporting_Manager__c from Delivery__c where Id=:TSId])
				{
					Delivery__Share TAShare = new Delivery__Share();
                    TAShare.ParentId = TA.Id;
                    TAShare.UserOrGroupId = TA.Timesheet_Approval__r.Approver__c;
                    TAShare.AccessLevel = 'Edit';
                    TAShare.RowCause = 'Manual';
                    
                    Delivery__Share TAShare1 = new Delivery__Share();
                    TAShare1.ParentId = TA.Id;
                    TAShare1.UserOrGroupId = TA.Team_Timesheet__r.Reporting_Manager__c;
                    TAShare1.AccessLevel = 'Edit';
                    TAShare1.RowCause = 'Manual';
                    
                    DelList.add(TAShare);
                    DelList.add(TAShare1);
				}
				Upsert DelList;  */
                
                
                
                
                if(!Test.isRunningTest()){
				
             /*       Approval.ProcessSubmitRequest apprReq = new Approval.ProcessSubmitRequest();
                    apprReq.setComments('Timesheet Submitted');
                    apprReq.setObjectId(TTS.id);
                    apprReq.setSubmitterId(empInfo.SF_User__c);
                    apprReq.setProcessDefinitionNameOrId('TimeSheetApproval');
                    apprReq.setSkipEntryCriteria(true);
                    Approval.ProcessResult result = Approval.process(apprReq);
                    List<Id> newWorkItemIds = result.getNewWorkitemIds();
                    System.debug(newWorkItemIds);
                    TTS.Current_Work_Item_ID__c = newWorkItemIds.get(0);
                    upsert TTS;  */
					//for testing
					for(Timesheet_Approval__c  TSA : [Select Id,Approval_Status__c,(select id, StepStatus from ProcessSteps ORDER BY CreatedDate Desc LIMIT 1) from Timesheet_Approval__c where Timesheet__c =:TTS.id and (Approval_Status__c = 'Submitted' or Approval_Status__c='Rejected')]){
						system.debug('Id@@'+TSA);
                        system.debug('tsa child size'+TSA.ProcessSteps.size());
                         
                        if(TSA.ProcessSteps.size() == 0 ||  (TSA.ProcessSteps.size() > 0 && (TSA.ProcessSteps[0].StepStatus != 'Pending' && TSA.ProcessSteps[0].StepStatus != 'Started'))){
                            //system.debug('tsa child size'+TSA.ProcessSteps[0].StepStatus);
						Approval.ProcessSubmitRequest apprReq = new Approval.ProcessSubmitRequest();
						apprReq.setComments('Timesheet Submitted');
						apprReq.setObjectId(TSA.Id);
						apprReq.setSubmitterId(empInfo.SF_User__c);
						apprReq.setProcessDefinitionNameOrId('Time_Sheet_Approval_Process');
						apprReq.setSkipEntryCriteria(true);
						Approval.ProcessResult result = Approval.process(apprReq);
						List<Id> newWorkItemIds = result.getNewWorkitemIds();
						System.debug(newWorkItemIds);
					}  
						
					
                }
                
            }
        }
        }
        catch (Exception e) {
            System.debug('Exception occurred>>'+e.getMessage() + ' at ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    } 
    /**
    * @author       Maaz
    * @date         2022-04-26
    * @description  Delete the existing draft records in Delivery Timesheet.
    * @param        TSId - Delivery Timesheet record Id.
    * @return       Delete the parent record (TTS).
    */
    @AuraEnabled
    public static Boolean deleteExisting(String TSId){
        Boolean TTSDeleted = false;
        try {
            Delivery__c existingDTS = [SELECT Id, Category__c,Time_in_Hours__c,Time_in_Mins__c,Team_Timesheet__c, Customer_Engagement__c  FROM Delivery__c WHERE Id=:TSId];
            
            Id ProId = existingDTS.Customer_Engagement__c;
			Id TSAId = existingDTS.Team_Timesheet__c;
			Team_Timesheet__c existingTTS = [SELECT Id,CRMIT_Holiday_Hours__c,Total_Hours__c,Total_Mins__c FROM Team_Timesheet__c WHERE Id=:existingDTS.Team_Timesheet__c];
            List<Delivery__c> allOtherDTS = [SELECT Id,Time_in_Hours__c,Category__c,Time_in_Mins__c FROM Delivery__c WHERE Team_Timesheet__c=:existingTTS.Id];
             
            if(existingDTS.Category__c=='CRMIT Holiday'){
            if(existingTTS.CRMIT_Holiday_Hours__c==null){existingTTS.CRMIT_Holiday_Hours__c=0;}
            existingTTS.CRMIT_Holiday_Hours__c-=existingDTS.Time_in_Hours__c;
                    }
            if(existingTTS.Total_Hours__c==null){existingTTS.Total_Hours__c=0;}
            existingTTS.Total_Hours__c-=existingDTS.Time_in_Hours__c;
            if(existingTTS.Total_Mins__c==null){existingTTS.Total_Mins__c=0;}
            existingTTS.Total_Mins__c-=existingDTS.Time_in_Mins__c;
            
            update existingTTS;
            delete existingDTS;
			
           
            
			Timesheet_Approval__c TSApp = [Select Id,(Select Id from Timesheet_Activity__r) from Timesheet_Approval__c where Customer_Engagement__c=:ProId and Timesheet__c=:TSAId] ;
			
			If(TSApp.Timesheet_Activity__r.size()==0)
				Delete TSApp;
			
            if(allOtherDTS?.size()==1){
                delete existingTTS;
                TTSDeleted = true;
            }
        } catch (Exception e) {
            System.debug('Exception occurred>>'+e.getMessage() + ' at ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return TTSDeleted;
    }
    public class existingTS_wrapper{
        @AuraEnabled
        public Team_Timesheet__c currTS {get;set;}
        @AuraEnabled
        public Boolean managerView;
    }
    /**
    * @author       Maaz
    * @date         2022-05-18
    * @description  Getting TS details for loading the component directly.
    * @param        currRecId - Delivery Timesheet record Id.
    * @return       existingTS_wrapper
    */
    @AuraEnabled
    public static existingTS_wrapper prevRec(String currRecId){
        existingTS_wrapper eTSDetails = new existingTS_wrapper();
        try {
            eTSDetails.currTS = [SELECT Id, Week_Start_Date__c,Employee_Name__c, Current_Work_Item_ID__c, Status__c, Reporting_Manager__c FROM Team_Timesheet__c WHERE Id=:currRecId];
            Employee__c currImp= [SELECT Id, Name, Email_ID__c, SF_User__c FROM Employee__c WHERE SF_User__c=:UserInfo.getUserId()];
            eTSDetails.managerView = currImp.SF_User__c == eTSDetails.currTS.Reporting_Manager__c ? true : false;
        } catch (Exception e) {
            System.debug('Exception occurred>>'+e.getMessage() + ' at ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return eTSDetails;
    }
    /**
    * @author       Maaz
    * @date         2022-05-25
    * @description  Approving or Rejecting timesheet submitted to Manager.
    * @param        reqAction - Approve or Reject
    * @param        reqComments - Comment by Manager
    * @param        workItemId - ProcessInstanceWorkitem Work Item Id.
    * @return       null
    */
    @AuraEnabled
    public static void approvalStep(String reqAction, String reqComments, String workItemId){
        try {
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setComments(reqComments);
            req.setAction(reqAction);
            req.setWorkitemId(workItemId);
            Approval.ProcessResult result = Approval.process(req);
        } catch (Exception e) {
            System.debug('Exception occurred>>'+e.getMessage() + ' at ' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }

     /**
    * @author       Jayati
    * @date         2022-11-14
    * @description  Getting Timesheet_Restriction_Bypass__c Field from user to allow the fill the timesheet.
    */
    @AuraEnabled(cacheable=true)
    public static User userData (String Ids){
        try {
            return [select id,Timesheet_Restriction_Bypass__c from user where Id =:Ids];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

     // File Upload Wrapper Class
    public class FileUploadWrapper {
        @AuraEnabled
        public String base64;
        @AuraEnabled
        public String filename;
       
    }
    
     @AuraEnabled(cacheable=true)
    public static MaxFileSize__c getCustomSettingData() {
        return MaxFileSize__c.getOrgDefaults();
    }

      @AuraEnabled(cacheable=true)
    public static AcceptedFileFormats__c getAccFileSettingData(){
        return AcceptedFileFormats__c.getOrgDefaults();
    }
}