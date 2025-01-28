/* Class Name: Career Development And Enablement Controller 
           Author: Sai Karthik C                                 */
    
    
    public without sharing class careerDevelopmentAndEnablementController {
               
                //String userEmail = UserInfo.getUserEmail();
                //String userEmail='sudhir.pl@crmit.com';
              
                        @AuraEnabled(cacheable=true)
        public static List<Role__c> searchDesignation(String designation){
            String designations='%'+designation+'%';
            return [Select Id, Name from Role__c Where Name LIKE :designations];
        }
               
                        @AuraEnabled(cacheable=true)
         public static list<Certificate__c> searchEmployeeCertificate(String certificate){
            
                  String certificateName='%'+certificate+'%';
                 system.debug('certificateName'+certificateName);
                 return [Select Id, Name from Certificate__c where Name LIKE :certificateName];
                 
            
               }
                       
                        
                        @AuraEnabled(cacheable=true)
                        public static List<Employee__c> searchCoachByName( String coachName ){
                            try {
                                coachName = '%' + coachName + '%';
                                return [ SELECT ID, Name FROM Employee__c WHERE Name LIKE :coachName ];
                            } catch (Exception e) {
                                throw new AuraHandledException(e.getMessage());
                            }
                        }
                        
                        @AuraEnabled(cacheable=true)
                        public static String getCareerAndEnablementData(string empid){
                            system.debug('empid'+empid);
                            if(empid == '' || empid == null){
                                return null; 
                            } 
                            try {
                                String userEmail='sudhir.pl@crmit.com';
                                
                                Employee__c Emp = [ 
                                    SELECT Id, Name, Email_ID__c, Designation__r.Name, Grade__c, Corporate_Band__c, EmployeeID__c, ReportingTo__r.Name, 
                                    BU_Head__r.Name, Country__c 
                                    FROM Employee__c 
                                    WHERE Id = :empid
                                ];
                                
                                list<Career_Goal_Line_Items__c> cdpItems = [
                                    SELECT Id, Proposed_Growth_Role__c, Proposed_Proficiency_Level__c, Coach__r.Name, Status__c, Assigned_Date__c, Actual_Start_Date__c,
                                    Actual_Completion_Date__c, Expected_Completion_Date__c 
                                    FROM Career_Goal_Line_Items__c 
                                    WHERE Career_Goal_and_Training_Plan__r.Employee_Name__c  =:empid
                                ];
                                
                                list<Career_Goal_and_Training_Plan__c> cgtpItem = [
                                    SELECT Id, Career_Goal_Manager_Comments__c, Career_Goal_Reviewer_Comments__c,
                                    Training_Program_Manager_Comments__c,Training_Program_Reviewer_Comments__c
                                    FROM Career_Goal_and_Training_Plan__c 
                                    WHERE Employee_Name__c  =:empid LIMIT 1
                                ];
                                
                                list<Employee_Certificate__c> certificationAll = [
                                  SELECT Id,Name,Certificate_Name__r.Name, Certificate_ID__c, Certified_On__c, Expiry_date__c, Updated_in_partner_portal__c 
                                    FROM Employee_Certificate__c 
                                    WHERE Employee__c =:empid
                                ];
                                
                                list<Training_Plan__c> enablementItem=[SELECT Id,Recommended_Certification_Name__c,PlannedDate__c,Status__c,
                                                                       Training_Name__c,Soft_Skills__c,Mentorship_Program__c
                                                                       FROM Training_Plan__c
                                                                       WHERE Career_Goal_and_Training_Plan__r.Employee_Name__c  =:empid
                                                                      ];
                                system.debug('enablementItem'+enablementItem);
                                list<Recommended_Certification__c> recoCertItem=[Select Id,Certificate_Name__c,Target_Date__c,	Status__c 
                                                                                 FROM Recommended_Certification__c 
                                                                                 Where Career_Goal_and_Training_Plan__r.Employee_Name__c  =:empid
                                                                                 ];
                                
                                list<allWrapper> allWrapperItems= new list<allWrapper>();
                                list<cdpWrapper> cdpWrapperItems= new list<cdpWrapper>();
                                list<certificationWrapper> certificationWrapperItems= new list<certificationWrapper>();
                                list<cdepWrapper> cdepWrapperItems= new list<cdepWrapper>();
                                list<recoCertWrapper> recoCertWrapperItems= new list<recoCertWrapper>();
                                list<addTrainWrapper> addTrainWrapperItems= new list<addTrainWrapper>();
                                
                                for( Integer i = 0; i < cdpItems.size(); i++ ){
                                    cdpWrapper wrapper = new cdpWrapper();
                                    Career_Goal_Line_Items__c cdp = cdpItems[i];
                                    
                                    wrapper.index = i;
                                    wrapper.Id=cdp.Id;
                                    wrapper.proposedGrowth = cdp.Proposed_Growth_Role__c;
                                    wrapper.proposedProficiency = cdp.Proposed_Proficiency_Level__c;
                                    wrapper.recommenedMentorId = cdp.Coach__r.Id;
                                    wrapper.recommenedMentorName = cdp.Coach__r.Name;
                                    wrapper.status = cdp.Status__c;
                                    wrapper.assignedDate = String.valueOf(cdp.Assigned_Date__c);
                                    wrapper.actualStartDate = String.valueOf(cdp.Actual_Start_Date__c);
                                    wrapper.expectedCompletionDate = String.valueOf(cdp.Expected_Completion_Date__c);
                                    wrapper.actualCompletionDate = String.valueOf(cdp.Actual_Completion_Date__c);
                                    cdpWrapperItems.add(wrapper);
                                    
                                }
                                System.debug('The cdp wrapper is'+cdpWrapperItems);
                                
                              
                              for(Integer i=0;i<recoCertItem.size();i++){
                                    recoCertWrapper wrapper= new recoCertWrapper();
                                    Recommended_Certification__c rcert= recoCertItem[i];
                                    wrapper.index=i;
                                    wrapper.Id = recoCertItem[i].Id;
                                    wrapper.certificateName=rcert.Certificate_Name__c;
                                    wrapper.targetDate=String.valueOf(rcert.Target_Date__c);
                                    wrapper.status=rcert.Status__c;
                                    recoCertWrapperItems.add(wrapper);
                                    
                                }             
                                
                                
                    
                                
                                for(Integer i=0;i<enablementItem.size();i++){
                                    addTrainWrapper wrapper= new addTrainWrapper();
                                    Training_Plan__c train= enablementItem[i];
                                    wrapper.index=i;
                                    wrapper.Id = enablementItem[i].Id;
                                    wrapper.mentorship=train.Mentorship_Program__c;
                                    wrapper.processTraining=train.Training_Name__c;
                                    wrapper.softSkills=train.Soft_Skills__c;
                                    addTrainWrapperItems.add(wrapper);
                                    
                                }
                                System.debug('The Training enablement wrapper'+addTrainWrapperItems);
                                
                                for(Career_Goal_and_Training_Plan__c cgtp: cgtpItem ){
                                    cdepWrapper wrapper= new cdepWrapper();
                                    wrapper.Id = cgtp.Id;
                                    wrapper.careerManagerComments = cgtp.Career_Goal_Manager_Comments__c;
                                    wrapper.careerReviewerComments = cgtp.Career_Goal_Reviewer_Comments__c;
                                    wrapper.trainingManagerComments = cgtp.Training_Program_Manager_Comments__c;
                                    wrapper.trainingReviewerComments = cgtp.Training_Program_Reviewer_Comments__c;
                                    cdepWrapperItems.add(wrapper);
                                    
                                }
                                System.debug('The Career goal and Training plan'+cdepWrapperItems);
                                
                                for(Employee_Certificate__c certificate:certificationAll){
                                    certificationWrapper wrapper= new certificationWrapper();
                                    wrapper.Id = certificate.Id;
                                    wrapper.certificationName = certificate.Certificate_Name__r.Name;
                                    wrapper.certificateNumber = certificate.Certificate_ID__c;
                                    wrapper.completionDate = String.valueOf(certificate.Certified_On__c);
                                    wrapper.expiryDate = String.valueOf(certificate.Expiry_date__c);
                                    wrapper.updatedInSf = String.valueOf(certificate.Updated_in_partner_portal__c);
                                    certificationWrapperItems.add(wrapper);
                                }  
                                System.debug('The certification list is'+certificationWrapperItems);
                                
                                allWrapper wrap = new allWrapper();
                                wrap.EmpDetails = Emp;
                                wrap.cdpDetails = cdpWrapperItems;
                                wrap.cdepDetails = cdepWrapperItems;
                                wrap.certificationDetails = certificationWrapperItems;
                                wrap.recoCertDetails=recoCertWrapperItems;
                                wrap.addTrainDetails=addTrainWrapperItems;
                                System.debug('The wrap details::'+wrap);
                                return JSON.serialize(wrap);
                                
                            }  catch (Exception e) {
                                throw new AuraHandledException(e.getMessage());
                            }
                        }
                        
                        
                        public class allWrapper{
                            @AuraEnabled 
                            public Employee__c EmpDetails;
                            @AuraEnabled 
                            public List<cdpWrapper> cdpDetails;
                            @AuraEnabled 
                            public List<certificationWrapper> certificationDetails;
                            @AuraEnabled 
                            public List<cdepWrapper> cdepDetails;
                            @AuraEnabled 
                            public List<recoCertWrapper> recoCertDetails;
                            @AuraEnabled 
                            public List<addTrainWrapper> addTrainDetails;
                        }
                        
                        public class cdpWrapper{
                            @AuraEnabled
                            public Integer index;
                            @AuraEnabled 
                            public String Id;
                            @AuraEnabled 
                            public String proposedGrowth;
                            @AuraEnabled 
                            public String proposedProficiency;
                            @AuraEnabled 
                            public String status;
                            @AuraEnabled 
                            public String assignedDate;
                            @AuraEnabled 
                            public String actualStartDate;
                            @AuraEnabled 
                            public String expectedCompletionDate;
                            @AuraEnabled 
                            public String actualCompletionDate;
                            @AuraEnabled 
                            public String recommenedMentorId;
                            @AuraEnabled 
                            public String recommenedMentorName;
                             @AuraEnabled 
                            public boolean acp=true;
                        }
                        
                        public class certificationWrapper {
                            @AuraEnabled
                            public String Id;
                            @AuraEnabled 
                            public String certificationName;
                            @AuraEnabled 
                            public String certificateNumber;
                            @AuraEnabled 
                            public String completionDate;
                            @AuraEnabled 
                            public String expiryDate;
                            @AuraEnabled 
                            public String updatedInSf;
                        }
                        
                        public class cdepWrapper { 
                            @AuraEnabled
                            public String Id;
                            @AuraEnabled 
                            public String careerManagerComments;
                            @AuraEnabled 
                            public String careerReviewerComments;
                            @AuraEnabled 
                            public String trainingManagerComments;
                            @AuraEnabled 
                            public String trainingReviewerComments;
                        }
                        public class recoCertWrapper{
                            @AuraEnabled 
                            public Integer index;
                            @AuraEnabled 
                            public String Id;
                            @AuraEnabled 
                            public String certificateName;
                            @AuraEnabled 
                            public String targetDate;
                            @AuraEnabled 
                            public String status;
                        }
                        public class addTrainWrapper{
                            @AuraEnabled 
                            public Integer index;
                            @AuraEnabled 
                            public String Id;
                            @AuraEnabled 
                            public String processTraining;
                            @AuraEnabled 
                            public String softSkills;
                            @AuraEnabled 
                            public String mentorship;
                        }
     //Method to Save Career and Development Data from Career development child component                    
                    @AuraEnabled
                    public Static void saveCareerDevelopmentData(String jsonststring){
                        Map<String,Object> jsonMap=(Map<String,Object>)JSON.deserializeUntyped(jsonststring);
                        Id empid=(Id)jsonMap.get('empId');
                        System.debug('JSON Object11'+jsonMap.get('empId'));
                        System.debug('JSON Object ::'+jsonMap);
                        Map<String,Object> cdepDataMap=new Map<String,Object>();
                       // List<Map<String, Object>> cdpList = new List<Map<String, Object>>();
                        cdepDataMap=(Map<String,Object>)jsonMap.get('cdepData');
                           List<Object> cdpList = (List<Object>) jsonMap.get('cdp');
                        //cdpList=(List<Map<String,Object>>)jsonMap.get('cdp');
                        List<Object> delcdpIdList= (List<Object>)jsonMap.get('toDeleteCDPIds');
                         
                
                        
                         Career_Goal_and_Training_Plan__c cgtp = new Career_Goal_and_Training_Plan__c ();
                          
                            if(cdepDataMap.get('Id') != null && cdepDataMap.get('Id') !=''){
                            
                            cgtp.Id = (Id)cdepDataMap.get('Id');
                                System.debug('The CGTP Id is ::'+cgtp.Id);
                            }
                            cgtp.Career_Goal_Manager_Comments__c=(String)cdepDataMap.get('managerComments');
                            cgtp.Career_Goal_Reviewer_Comments__c=(String)cdepDataMap.get('reviewerComments');
                        cgtp.Employee_Name__c=empid;
                       
                        System.debug('The manager comments are ::'+cgtp.Career_Goal_Manager_Comments__c);
                     
                            upsert cgtp;
                        
                        
                 list<Career_Goal_Line_Items__c> allcdpItems= new list<Career_Goal_Line_Items__c>();
                            
                            //for(mainWrap wrap:wrapdata){
                           //List<Map<String, Object>> cdpList = (List<Map<String, Object>>) cdpMap;
                           // for(Map<String,Object> cdpItem:cdpList){
                        if(cdpList !=null){
                            
                        
                        for(Object cdpItem:cdpList){
                           
                            Map<String,Object> cdpItemMap= (Map<String,Object>)cdpItem;
                                Career_Goal_Line_Items__c cgli= new Career_Goal_Line_Items__c();
                                if(cdpItemMap.get('Id') != null && cdpItemMap.get('Id') !=''){
                                    cgli.Id= (String)cdpItemMap.get('Id'); 
                                    System.debug('The Career_Goal_Line_Item Id is  ::'+cgli.Id);
                                }
                                
                                cgli.Proposed_Growth_Role__c  = (String)cdpItemMap.get('proposedGrowth') ;
                                String growth=cgli.Proposed_Growth_Role__c;
                                cgli.Proposed_Proficiency_Level__c  = (String)cdpItemMap.get('proposedProficiency') ;
                                String proficiency= cgli.Proposed_Proficiency_Level__c;
                            String coach;
                            if((String)cdpItemMap.get('recommenedMentorId')!=null && (String)cdpItemMap.get('recommenedMentorId')!='' ){
                                

                                cgli.Coach__c  = ((String)cdpItemMap.get('recommenedMentorId')!=null? (String)cdpItemMap.get('recommenedMentorId'):cgli.Coach__c);
                                 coach=cgli.Coach__c;
                            }
                                cgli.Status__c  = ((String)cdpItemMap.get('status')!=null?(String)cdpItemMap.get('status'):'' ) ;
                                String status=cgli.Status__c;
                                cgli.Assigned_Date__c =(string)cdpItemMap.get('assignedDate')!=null? Date.valueOf((string)cdpItemMap.get('assignedDate')):cgli.Assigned_Date__c;
                                Date assign=cgli.Assigned_Date__c;
                                cgli.Actual_Start_Date__c = ((String)cdpItemMap.get('actualStartDate')!=null?Date.valueOf((String)cdpItemMap.get('actualStartDate')):cgli.Actual_Start_Date__c);
                                 Date actual=cgli.Actual_Start_Date__c;
                                cgli.Expected_Completion_Date__c  = ((String)cdpItemMap.get('expectedCompletionDate')!=null?Date.valueOf((String)cdpItemMap.get('expectedCompletionDate')):null );
                                Date expected=cgli.Expected_Completion_Date__c;  
                                 Date actualComp=null;                 
                              if( (String)cdpItemMap.get('actualCompletionDate')!= '' && (String)cdpItemMap.get('actualCompletionDate')!=null){
                                  System.debug('Actual completion date is ::'+ (String)cdpItemMap.get('actualCompletionDate') );
                                  cgli.Actual_Completion_Date__c = Date.valueOf((String)cdpItemMap.get('actualCompletionDate'));
                                  actualComp=cgli.Actual_Completion_Date__c;
                              }
                                  
                              
                                cgli.Career_Goal_and_Training_Plan__c = cgtp.Id;
                            String Idc=cgli.Career_Goal_and_Training_Plan__c;
                            List<Career_Goal_Line_Items__c> allcdpItems1=[Select Id from Career_Goal_Line_Items__c WHERE Proposed_Growth_Role__c=:growth AND Proposed_Proficiency_Level__c=:proficiency AND
                                                                         Coach__c=:coach AND Status__c=:status AND Assigned_Date__c=:assign AND Actual_Start_Date__c=:actual AND
                                                                         Expected_Completion_Date__c=:expected AND Actual_Completion_Date__c=:actualComp AND Career_Goal_and_Training_Plan__c=:Idc];
                            if(allcdpItems1.isEmpty()){
                                 allcdpItems.add(cgli);
                            }    
                           
                            System.debug('The List of CGLI items :: '+allcdpItems);
                            }
                            upsert allcdpItems;
                               
                    }
                        if(delcdpIdList.size()>0){
                            List<Id> delcgtIdList= new List<Id>();
                        
                       for(object delCdpId:delcdpIdList){
                                    
                           // Career_Goal_Line_Items__c cgtpId= new Career_Goal_Line_Items__c();
                           //cgtpId.Id=(Id)delCdpId;
                           delcgtIdList.add((Id)delCdpId);
                          
                        }
                        list<Career_Goal_Line_Items__c> deletedlistNew = [select id from Career_Goal_Line_Items__c where id IN:delcgtIdList];
                        System.debug('deletedlist::b'+deletedlistNew);
                            delete deletedlistNew; 
                            System.debug('deletedlist::a'+deletedlistNew);
                            
                        }
                  
                        
                   }
       //Method to save training enablement data from training and enablement child class              
                    @AuraEnabled 
                public Static void saveTrainingEnablementData(String jsonstr){
           
                // Deserialize the JSON string using maps
                Map<String, Object> jsonDataMap = (Map<String, Object>)JSON.deserializeUntyped(jsonstr);
                System.debug('The JSON data map is::'+jsonDataMap);
                
                // Access the deserialized data using maps
                Map<String, Object> cdepDataMap = (Map<String, Object>)jsonDataMap.get('cdepData');
                List<Object> recommendedCertificationsList = (List<Object>)jsonDataMap.get('recommendedCertifications');
                List<Object> employeeEnablementPlansList = (List<Object>)jsonDataMap.get('employeeEnablementPlans');
                List<Object> toDeleteCertificationsPlanIdsList = (List<Object>)jsonDataMap.get('toDeleteCertificationsPlanIds');
                List<Object> toDeleteEnablementPlansIdsList = (List<Object>)jsonDataMap.get('toDeleteEnablementPlansIds');
                
                    
                    list<Career_Goal_and_Training_Plan__c> allcgtpItems= new list<Career_Goal_and_Training_Plan__c>();
                        System.debug('The cdepDataMap is'+cdepDataMap.get('Id'));
                        
                             Career_Goal_and_Training_Plan__c cgtp = new Career_Goal_and_Training_Plan__c ();
                            if(cdepDataMap.get('Id') != null && cdepDataMap.get('Id') != ''){
                           
                            cgtp.Id = (String)cdepDataMap.get('Id');
                                System.debug('The Career_Goal_and_Training_Plan__c is '+cgtp.Id);
                            }
                            cgtp.Training_Program_Manager_Comments__c=(String)cdepDataMap.get('managerComments')!=null?(String)cdepDataMap.get('managerComments'): cgtp.Training_Program_Manager_Comments__c;
                            cgtp.Training_Program_Reviewer_Comments__c=(String)cdepDataMap.get('reviewerComments')!=null?(String)cdepDataMap.get('reviewerComments'): cgtp.Training_Program_Reviewer_Comments__c;
                            System.debug('The manager comments are ::'+cgtp.Career_Goal_Manager_Comments__c);
                     
                            upsert cgtp;
                       
                        list<Recommended_Certification__c> tpList= new list<Recommended_Certification__c>();
                        System.debug('~~recommendedCertificationsList '+recommendedCertificationsList);
                        for(Object recoList:recommendedCertificationsList){
                            Map<String,Object> recoListMap=(Map<String,Object>)recoList;
                            System.debug('~~recoListMap'+recoListMap);
                            System.debug('~~recoListMap'+recoListMap.get('Id'));
                             Recommended_Certification__c tp= new Recommended_Certification__c();
                            if(recoListMap.get('Id') != null && recoListMap.get('Id') != ''){
                                System.debug('enter::Id');
                                tp.Id=(String) recoListMap.get('Id');
                            }
                            
                            tp.Certificate_Name__c=(String)recoListMap.get('certificateName') !=null?(String)recoListMap.get('certificateName'):tp.Certificate_Name__c;
                            String certificate=tp.Certificate_Name__c;
                            tp.Target_Date__c= (String)recoListMap.get('targetDate')!=null? Date.valueOf((String)recoListMap.get('targetDate')):tp.Target_Date__c ;
                            Date target=tp.Target_Date__c;
                            tp.Status__c= (String)recoListMap.get('status')!=null?(String)recoListMap.get('status'):tp.Status__c;
                            String status=tp.Status__c;
                            tp.Career_Goal_and_Training_Plan__c=cgtp.Id;
                            String Idc=tp.Career_Goal_and_Training_Plan__c;
                            List<Recommended_Certification__c> tpList1=[Select Id from Recommended_Certification__c Where Certificate_Name__c=:certificate AND Target_Date__c=:target AND
                                                                       Status__c=:status AND Career_Goal_and_Training_Plan__c=:Idc ];
                            if(tpList1.isEmpty()){
                            tpList.add(tp);  
                            }
    
                        }
                        upsert tpList;
                        System.debug('The inserted list is ::'+tpList);
                        
                  //Enablement plans save      
                        list<Training_Plan__c> tepList= new list<Training_Plan__c>();
                         system.debug('employeeEnablementPlansList'+employeeEnablementPlansList);
                        for(Object eplanList:employeeEnablementPlansList){
                           
                            Map<String,Object> eplanListMap=(Map<String,Object>)eplanList;
                            
                            Training_Plan__c tep= new Training_Plan__c();
                          
                            if(eplanListMap.get('Id')!= null && eplanListMap.get('Id')!=''){
                              
                                tep.Id=(String)eplanListMap.get('Id');
                            }
                            
                            
                            tep.Mentorship_Program__c=(String)eplanListMap.get('mentorship')!=null?(String)eplanListMap.get('mentorship'): tep.Mentorship_Program__c;
                            String mentorship=tep.Mentorship_Program__c;
                            tep.Training_Name__c=(String)eplanListMap.get('processTraining')!=null?(String)eplanListMap.get('processTraining'):tep.Training_Name__c;
                            String training=tep.Training_Name__c;
                            tep.Soft_Skills__c=(String)eplanListMap.get('softSkills')!=null?(String)eplanListMap.get('softSkills'):tep.Soft_Skills__c;
                            String soft= tep.Soft_Skills__c;
                            tep.Career_Goal_and_Training_Plan__c= cgtp.Id;
                            String Idu= tep.Career_Goal_and_Training_Plan__c;
                            //tep.unique__c= tep.Mentorship_Program__c +'-'+tep.Training_Name__c+'-'+ tep.Soft_Skills__c;
                            
                            List<Training_Plan__c> tepListd=[Select Id from Training_Plan__c where Mentorship_Program__c=:mentorship AND Training_Name__c=:training 
                                                           AND Soft_Skills__c=:soft AND Career_Goal_and_Training_Plan__c=:Idu ];
                            if(tepListd.isEmpty()){
                                   tepList.add(tep); 
                            }
                        
                     
                        }   system.debug('tepList'+tepList);
                        upsert tepList;
                       //database.upsert(tepList,Training_Plan__c.unique__c,false);
                        
                        if(toDeleteCertificationsPlanIdsList.size()>0){
                            List <Id> rcItemList= new List<Id>();
                            for(Object delCertObj:toDeleteCertificationsPlanIdsList){
                               // List<String> delList=(List<String>)delCertObj;
                                // for(String recoId:delList){
                                // Recommended_Certification__c recId= new Recommended_Certification__c();
                                   // recId.Id=recoId;
                                rcItemList.add((Id)delCertObj);
                            }
                            List<Recommended_Certification__c> rcList=[Select Id from Recommended_Certification__c Where 
                                                                           Id IN :rcItemList ];
                            
                             delete rcList;
                            }
                     
                        
                        if(toDeleteEnablementPlansIdsList.size()>0){
                        List<Id> tpdelList= new List<Id>();
                            for(Object delEnableItem:toDeleteEnablementPlansIdsList){
                             
                                   tpdelList.add((Id)delEnableItem) ;
                                }
                            List<Training_Plan__c> delList= [Select Id from Training_Plan__c Where 
                                                             Id IN :tpdelList];
                                delete delList;
                            }
                     
                    }  
                 }