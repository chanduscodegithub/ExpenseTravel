@IsTest
public class CareerDevelopmentAndEnablementTest {
  
    @IsTest
    public static void testGetCareerAndEnablementData() {
        // Create test data
        Employee__c emp = new Employee__c(Name = 'Test Employee');
        insert emp;
        Date assignedDate=Date.today();  
        Date actualDate=assignedDate+1;
        Date expCompDate=actualDate+1;
        Date actCompDate=expCompDate+1;



        
        // Create test Career_Goal_Line_Items__c records
        Career_Goal_Line_Items__c cdp1 = new Career_Goal_Line_Items__c(
            Proposed_Growth_Role__c = 'Test Role 1',
            Proposed_Proficiency_Level__c = 'Competent',
            Status__c = 'In Progress',
            Assigned_Date__c = assignedDate,
            Actual_Start_Date__c = actualDate,
            Expected_Completion_Date__c = expCompDate,
            Actual_Completion_Date__c = actCompDate,
            Coach__c = emp.Id
        );
        Career_Goal_Line_Items__c cdp2 = new Career_Goal_Line_Items__c(
            Proposed_Growth_Role__c = 'Test Role 2',
            Proposed_Proficiency_Level__c = 'Expert',
            Status__c = 'Completed',
            Assigned_Date__c = assignedDate,
            Actual_Start_Date__c = actualDate,
            Expected_Completion_Date__c = expCompDate,
            Actual_Completion_Date__c = actCompDate,
            Coach__c = emp.Id
        );
        //insert new List<Career_Goal_Line_Items__c>{cdp1,cdp2};
        insert cdp1;
        insert cdp2;
            
            // Create test Career_Goal_and_Training_Plan__c record
            Career_Goal_and_Training_Plan__c cgtp = new Career_Goal_and_Training_Plan__c(
                Employee_Name__c = emp.Id,
                Career_Goal_Manager_Comments__c = 'Test Manager Comments',
                Career_Goal_Reviewer_Comments__c = 'Test Reviewer Comments',
                Training_Program_Manager_Comments__c = 'Test Manager Comments',
                Training_Program_Reviewer_Comments__c = 'Test Reviewer Comments'
            );
        insert cgtp;
        
        // Create test Employee_Certificate__c record
        Employee_Certificate__c cert = new Employee_Certificate__c(
            Employee__c = emp.Id,
            //Certificate_Name__r.Name = 'Platform App Builder',
            Certificate_Name__c='a4tDV000002vUSZYA2',
           // Certificate_ID__c = 'a4tDV000002vUSZYA2',
            Certified_On__c = Date.today(),
            Expiry_date__c = Date.today(),
            Updated_in_partner_portal__c = true
        );
        insert cert;
        
        // Create test Training_Plan__c record
        Training_Plan__c training = new Training_Plan__c(
            Career_Goal_and_Training_Plan__c = cgtp.Id,
            Recommended_Certification_Name__c = 'Platform Developer 1',
            PlannedDate__c = Date.today(),
            Status__c = 'In Progress',
            Training_Name__c = 'Test Training',
            Soft_Skills__c = 'Test Soft Skills',
            Mentorship_Program__c = 'Test Mentorship'
        );
        insert training;
        
        // Create test Recommended_Certification__c record
        Recommended_Certification__c recoCert = new Recommended_Certification__c(
            Career_Goal_and_Training_Plan__c = cgtp.Id,
            Certificate_Name__c = 'Platform Developer 1',
            Target_Date__c = Date.today(),
            Status__c = 'In Progress'
        );
        insert recoCert;
        
        // Call the method to be tested
        Test.startTest();
        String result = careerDevelopmentAndEnablementController.getCareerAndEnablementData(emp.Id);
        Test.stopTest();
        
        // Deserialize the result
        careerDevelopmentAndEnablementController.allWrapper wrapper = (careerDevelopmentAndEnablementController.allWrapper) JSON.deserialize(result, careerDevelopmentAndEnablementController.allWrapper.class);
        
        // Assert the expected values
       /* System.assertEquals(emp.Id, wrapper.EmpDetails.Id);
        System.debug('The employee Id is'+wrapper.EmpDetails.Id);
        System.assertEquals(2, wrapper.cdpDetails.size());
        System.assertEquals('Test Role 1', wrapper.cdpDetails[0].proposedGrowth);
        System.assertEquals('Test Role 2', wrapper.cdpDetails[1].proposedGrowth);
        System.assertEquals(1, wrapper.cdepDetails.size());
        System.assertEquals('Test Manager Comments', wrapper.cdepDetails[0].careerManagerComments);
        System.assertEquals(1, wrapper.certificationDetails.size());
        System.assertEquals('Test Certificate', wrapper.certificationDetails[0].certificationName);
        System.assertEquals(1, wrapper.recoCertDetails.size());
        System.assertEquals('Test Certification', wrapper.recoCertDetails[0].certificateName);
        System.assertEquals(1, wrapper.addTrainDetails.size());
        System.assertEquals('Test Training', wrapper.addTrainDetails[0].processTraining); */
    }  
    
    @IsTest
    public static void testSaveCareerDevelopmentData() {
        // Create test data
        Employee__c emp = new Employee__c(Name = 'Test Employee');
        insert emp;
        Date assignedDate=Date.today();  
        Date actualDate=assignedDate+1;
        Date expCompDate=actualDate+1;
        Date actCompDate=expCompDate+1;
        
        // Create test Career_Goal_and_Training_Plan__c record
        Career_Goal_and_Training_Plan__c cgtp = new Career_Goal_and_Training_Plan__c(
            Employee_Name__c = emp.Id
        );
        insert cgtp;
        
        // Create test Career_Goal_Line_Items__c records
        Career_Goal_Line_Items__c cdp1 = new Career_Goal_Line_Items__c(
            Proposed_Growth_Role__c = 'Test Role 1',
            Proposed_Proficiency_Level__c = 'Expert',
            Status__c = 'In Progress',
           Assigned_Date__c = assignedDate,
            Actual_Start_Date__c = actualDate,
            Expected_Completion_Date__c = expCompDate,
            Actual_Completion_Date__c = actCompDate,
            Career_Goal_and_Training_Plan__c = cgtp.Id
        );
        Career_Goal_Line_Items__c cdp2 = new Career_Goal_Line_Items__c(
            Proposed_Growth_Role__c = 'Test Role 2',
            Proposed_Proficiency_Level__c = 'Expert',
            Status__c = 'In Progress',
            Assigned_Date__c = assignedDate,
            Actual_Start_Date__c = actualDate,
            Expected_Completion_Date__c = expCompDate,
            //Actual_Completion_Date__c = actCompDate,
            Career_Goal_and_Training_Plan__c = cgtp.Id
        );
        insert new List<Career_Goal_Line_Items__c>{cdp1, cdp2};
            
            // Create JSON string payload
            Map<String, Object> jsonMap = new Map<String, Object>();
        jsonMap.put('empId', emp.Id);
        
        Map<String, Object> cdepDataMap = new Map<String, Object>();
        cdepDataMap.put('Id', cgtp.Id);
        cdepDataMap.put('managerComments', 'Test Manager Comments');
        cdepDataMap.put('reviewerComments', 'Test Reviewer Comments');
        jsonMap.put('cdepData', cdepDataMap);
        
        List<Object> cdpList = new List<Object>();
        Map<String, Object> cdpItem1 = new Map<String, Object>();
        cdpItem1.put('Id', cdp1.Id);
        cdpItem1.put('proposedGrowth', 'Test Role 1');
        cdpItem1.put('proposedProficiency', 'Expert');
        cdpItem1.put('status', 'Completed');
        cdpItem1.put('assignedDate',assignedDate);
        cdpItem1.put('actualStartDate', actualDate);
        cdpItem1.put('expectedComple',expCompDate);
        //cdpItem1.put('actualCompletionDate', Date.today().format());
        cdpItem1.put('recommenedMentorId', null);
        cdpList.add(cdpItem1);
        
        jsonMap.put('cdp', cdpList);
        jsonMap.put('toDeleteCDPIds', new List<Object>());
        
        String jsonString = JSON.serialize(jsonMap);
        
        // Call the method to be tested
        Test.startTest();
        careerDevelopmentAndEnablementController.saveCareerDevelopmentData(jsonString);
        Test.stopTest();
        
        // Retrieve updated Career_Goal_Line_Items__c records
        List<Career_Goal_Line_Items__c> updatedCdpList = [SELECT Id, Status__c FROM Career_Goal_Line_Items__c WHERE Career_Goal_and_Training_Plan__c = :cgtp.Id];
        
        // Assert the expected values
        System.assertEquals(2, updatedCdpList.size());
        System.assertEquals('Completed', updatedCdpList[0].Status__c);
    } 
@isTest        
public static void testSaveTrainingEnablementDate(){
    // Create test data
        Employee__c emp = new Employee__c(Name = 'Test Employee');
        insert emp;
        Date assignedDate=Date.today();  
        Date actualDate=assignedDate+1;
        Date expCompDate=actualDate+1;
        Date actCompDate=expCompDate+1;
        
        // Create test Career_Goal_and_Training_Plan__c record
        Career_Goal_and_Training_Plan__c cgtp = new Career_Goal_and_Training_Plan__c(
            Employee_Name__c = emp.Id
        );
        insert cgtp;
    Recommended_Certification__c tp= new Recommended_Certification__c(
                                      Certificate_Name__c='Platform Developer 1',
                                           Target_Date__c= assignedDate,
                                                Status__c='Yet To Start',
                                      Career_Goal_and_Training_Plan__c=cgtp.Id);
    insert tp;
    Training_Plan__c tep= new Training_Plan__c(
                          Mentorship_Program__c='Test Mentorship Program',
                          Training_Name__c='Test Training Name',
                          Soft_Skills__c='Test Soft Skills',
                          Career_Goal_and_Training_Plan__c=cgtp.Id);
    insert tep;
    
    //Create a sample JSON map
    Map<String,Object> jsonMap= new Map<String,Object>();
    jsonMap.put('empId',emp.Id);
    Map<String,Object> cdepData= new Map<String,Object>();
    cdepData.put('Id',cgtp.Id);
    cdepData.put('managerComments','Test manager Comments');
    cdepData.put('reviewerComments','Test reviewer Comments');
    jsonMap.put('cdepData',cdepData);

    Map<String,Object> tep1= new Map<String,Object>();
    tep1.put('Id',tep.Id);
    tep1.put('processTraining','Test Training Name');
    tep1.put('softSkills','Test Soft Skills');
    tep1.put('mentorship','Test Mentorship Program');

    list<Object> tepList= new list<Object>();
    tepList.add(tep1);
    jsonMap.put('employeeEnablementPlans',tepList);
   
    Map<String,Object> tp1= new Map<String,Object>();
    tp1.put('Id',tp.Id);
    tp1.put('certificateName','Platform Developer 1');
    tp1.put('targetDate', expCompDate);
    tp1.put('status','Yet To Start');

    List<Object> tpList= new List<Object>();
    tpList.add(tp1);
    jsonMap.put('recommendedCertifications',tpList);
    jsonMap.put('toDeleteCertificationsPlanIds',new List<Object>());
    jsonMap.put('toDeleteEnablementPlansIds',new List<Object>());
    
    String jsonString=JSON.serialize(jsonMap);

    // Call the method to be tested
    Test.startTest();
    careerDevelopmentAndEnablementController.saveTrainingEnablementData(jsonString);
    Test.stopTest();

}    
    
}