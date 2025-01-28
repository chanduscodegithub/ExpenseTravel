@IsTest
public class saveTalentLoadingTest {
    @IsTest
    public static void testCreateTalentRecords() {
        // Test data setup
        Project__c project = new Project__c(Name = 'Test Project');
        project.TalentloadVersion__c = null;
        project.Talent_Frequency__c = 'Monthly';
        project.StartDate__c = Date.today();
        project.EndDate__c = Date.today().addDays(90);
        insert project;
        
        saveTalentLoading.talentload talent = new saveTalentLoading.talentload();
        talent.role = 'QA';
        talent.location = 'India';
        
        List<saveTalentLoading.talentload> talentLoadingList = new List<saveTalentLoading.talentload>();
        talentLoadingList.add(talent);
        
        saveTalentLoading.talentloadchild talentChild = new saveTalentLoading.talentloadchild();
        talentChild.indexes = 0;
        talentChild.months = 'Jun - 23';
        talentChild.hours = 10;
        
        List<saveTalentLoading.talentloadchild> talentLoadingLines = new List<saveTalentLoading.talentloadchild>();
        talentLoadingLines.add(talentChild);
       
        // Test the createTalentRecords method
        Test.startTest();
        
        saveTalentLoading.createTalentRecords(JSON.serialize(talentLoadingList), JSON.serialize(talentLoadingLines), project.Id, project.StartDate__c, project.EndDate__c);
        Test.stopTest();
        
        // Assertions and verifications
        project = [SELECT isTalentLoad__c, TalentloadVersion__c FROM Project__c WHERE Id = :project.Id];
        System.assertEquals(true, project.isTalentLoad__c);
        System.assertNotEquals(null, project.TalentloadVersion__c);
        
        List<Talent_Loading__c> talentLoadings = [SELECT id, Role__c, Location__c from Talent_Loading__c];

        // Verify the talentLoadings data
        System.assertEquals(1, talentLoadings.size());

        Talent_Loading__c talentLoading = talentLoadings[0];
        System.assertEquals('QA', talentLoading.Role__c);
        System.assertEquals('India', talentLoading.Location__c);
        
        List<Talent_Loading_Line__c> talentLoadingLine = [SELECT Id, Month__c, Hour__c, Talent_Loading__c from Talent_Loading_Line__c];

        // Verify the talentLoadingLines data
        System.assertEquals(1, talentLoadingLine.size());

        Talent_Loading_Line__c talentLoadingLin = talentLoadingLine[0];
        System.assertEquals('Jun - 23', talentLoadingLin.Month__c);
        System.assertEquals(10, talentLoadingLin.Hour__c);
    }
	 @IsTest
    public static void testGetTalentLoadings() {
        // Create test data
        Project__c project = new Project__c(Name = 'Test Project');
        project.TalentloadVersion__c = 1;
        project.isTalentLoad__c = true;
        project.Talent_Frequency__c = 'Monthly';
        project.StartDate__c = Date.today();
        project.EndDate__c = Date.today().addDays(90);
        insert project;
        
        Talent_Loading__c talentLoading = new Talent_Loading__c(
            Engagement__c = project.Id,
            Version__c = 1,
            Role__c = 'Developer',
            Location__c = 'India'
        );
        insert talentLoading;
        
        Talent_Loading_Line__c talentLine1 = new Talent_Loading_Line__c(
            Talent_Loading__c = talentLoading.Id,
            Month__c = 'Jun - 23',
            Hour__c = 40
        );
        Talent_Loading_Line__c talentLine2 = new Talent_Loading_Line__c(
            Talent_Loading__c = talentLoading.Id,
            Month__c = 'Jul - 23',
            Hour__c =  34
        );
        insert new List<Talent_Loading_Line__c>{ talentLine1, talentLine2 };
        
        // Call the method to be tested
        Test.startTest();
        List<Talent_Loading__c> result = saveTalentLoading.getTalentLoadings(project.Id);
        Test.stopTest();
        
        // Verify the results
        System.assertEquals(1, result.size());
        Talent_Loading__c talentRecord = result[0];
        System.assertEquals(1, talentRecord.Version__c);
        System.assertEquals('Developer', talentRecord.Role__c);
        System.assertEquals('India', talentRecord.Location__c);
        System.assertEquals(2, talentRecord.Talent_Loading_Lines__r.size());
        
        for (Talent_Loading_Line__c talentLine : talentRecord.Talent_Loading_Lines__r) {
            if (talentLine.Month__c == 'Jun - 23') {
                System.assertEquals(40, talentLine.Hour__c);
            } else if (talentLine.Month__c == 'Jul - 23') {
                System.assertEquals(34, talentLine.Hour__c);
            } else {
                // Unexpected talent line, fail the test
                System.assertEquals(true, false, 'Unexpected talent line');
            }
        }
    }

    @IsTest
    public static void testGetTeamAllocations() {
        // Create test data
         Project__c project = new Project__c(Name = 'Test Project');
        project.TalentloadVersion__c = 1;
        project.Talent_Frequency__c = 'Monthly';
        project.StartDate__c = Date.today();
        project.EndDate__c = Date.today().addDays(90);
        insert project;
		
		 Talent_Loading__c talentLoading = new Talent_Loading__c(
            Engagement__c = project.Id,
            Version__c = 1,
            Role__c = 'Developer',
            Location__c = 'India'
        );
        insert talentLoading;
        
        Talent_Loading_Line__c talentLine1 = new Talent_Loading_Line__c(
            Talent_Loading__c = talentLoading.Id,
            Month__c = 'Jun - 23',
            Hour__c = 40
        );
        Talent_Loading_Line__c talentLine2 = new Talent_Loading_Line__c(
            Talent_Loading__c = talentLoading.Id,
            Month__c = 'Jul - 23',
            Hour__c =  34
        );
        insert new List<Talent_Loading_Line__c>{ talentLine1, talentLine2 };
        
        
        TeamAllocation__c teamAllocation = new TeamAllocation__c(Talent_Loading__c = talentLoading.Id);
		teamAllocation.StartDate__c = Date.today();
		teamAllocation.EndDate__c = Date.today().addDays(30);
	    teamAllocation.Resource_Role__c = 'Developer';
		teamAllocation.Project__c = project.Id;
        insert teamAllocation;
		teamAllocation.AllocationHours__c = 10;
        update teamAllocation;
        Team_Timesheet__c timesheet = new Team_Timesheet__c();
        timesheet.Week_Start_Date__c = Date.today();
        insert timesheet;
        Delivery__c timesheetActivity = new Delivery__c();
        timesheetActivity.Team_Timesheet__c = timesheet.Id;
        timesheetActivity.Customer_Engagement__c = project.Id;
        
        // Call the method to be tested
        Test.startTest();
        List<TeamAllocation__c> result = saveTalentLoading.getTeamAllocations(project.Id);
        Test.stopTest();
        
        // Verify the results
        System.assertEquals(1, result.size());
        TeamAllocation__c teamAllocationResult = result[0];
        System.assertEquals(teamAllocation.Id, teamAllocationResult.Id);
    }
    
    @IsTest
    public static void testGetProject() {
        // Create test data
         Project__c project = new Project__c(Name = 'Test Project');
        project.TalentloadVersion__c = 1;
        project.Talent_Frequency__c = 'Monthly';
        project.StartDate__c = Date.today();
        project.EndDate__c = Date.today().addDays(90);
        insert project;
        
        // Call the method to be tested
        Test.startTest();
        Project__c result = saveTalentLoading.getProject(project.Id);
        Test.stopTest();
        
        // Verify the results
        System.assertEquals(project.Id, result.Id);
        System.assertEquals('Test Project', result.Name);
    }
    
    @IsTest
    public static void testGetProjectType() {
        // Create test data
         Project__c project = new Project__c(Name = 'Test Project');
        project.TalentloadVersion__c = 1;
        project.Talent_Frequency__c = 'Monthly';
        project.StartDate__c = Date.today();
        project.EndDate__c = Date.today().addDays(90);
        project.Type__c = 'Internal';
        insert project;
        
        // Call the method to be tested
        Test.startTest();
        String result = saveTalentLoading.getProjectType(project.Id);
        Test.stopTest();
        
        // Verify the results
        System.assertEquals('Internal', result);
    }
    
    @IsTest
    public static void testGetCustomSettingValue() {
        // Create test data
        TL_default_rows__c customSetting = new TL_default_rows__c(Name = 'rows', default_rows__c = 10);
        insert customSetting;
        
        // Call the method to be tested
        Test.startTest();
        Decimal result = saveTalentLoading.getCustomSettingValue();
        Test.stopTest();
        
        // Verify the results
        System.assertEquals(10, result.intValue());
    }
    
    @IsTest
    public static void testUpdateTalentFrequency() {
        // Create test data
         Project__c project = new Project__c(Name = 'Test Project');
        project.TalentloadVersion__c = 1;
        project.Talent_Frequency__c = 'Monthly';
        project.StartDate__c = Date.today();
        project.EndDate__c = Date.today().addDays(90);
        project.Type__c = 'Internal';
        insert project;
        
        // Call the method to be tested
        Test.startTest();
        saveTalentLoading.updateTalentFrequency(project.Id, 'Weekly');
        Test.stopTest();
        
        // Retrieve the updated project record
        Project__c updatedProject = [SELECT Talent_Frequency__c FROM Project__c WHERE Id = :project.Id];
        
        // Verify the results
        System.assertEquals('Weekly', updatedProject.Talent_Frequency__c);
    }
    
    @IsTest
    public static void testUpdateTalentFrequencyToZero() {
        // Create test data
        Project__c project = new Project__c(Name = 'Test Project');
        project.TalentloadVersion__c = 1;
        project.Talent_Frequency__c = 'Monthly';
        project.StartDate__c = Date.today();
        project.EndDate__c = Date.today().addDays(90);
        project.Type__c = 'Internal';
        insert project;
        
        
        // Call the method to be tested
        Test.startTest();
        saveTalentLoading.updateTalentFrequencyToZero(project.Id);
        Test.stopTest();
        
        // Retrieve the updated project record
        Project__c updatedProject = [SELECT Talent_Frequency__c FROM Project__c WHERE Id = :project.Id];
        
        // Verify the results
        System.assertEquals(null, updatedProject.Talent_Frequency__c);
    }
    
    @IsTest
    public static void testDeleteTalentLoadings() {
        // Create test data
        Project__c project = new Project__c(Name = 'Test Project');
        project.TalentloadVersion__c = 1;
        project.Talent_Frequency__c = 'Monthly';
        project.StartDate__c = Date.today();
        project.EndDate__c = Date.today().addDays(90);
        project.Type__c = 'Internal';
        project.isTalentLoad__c = true;
        insert project;
        
        
        Talent_Loading__c talentLoading = new Talent_Loading__c(
            Engagement__c = project.Id,
            Version__c = 1,
            Role__c = 'Developer',
            Location__c = 'India'
        );
        insert talentLoading;
        
        Talent_Loading_Line__c talentLine1 = new Talent_Loading_Line__c(
            Talent_Loading__c = talentLoading.Id,
            Month__c = 'Jun - 23',
            Hour__c = 40
        );
        Talent_Loading_Line__c talentLine2 = new Talent_Loading_Line__c(
            Talent_Loading__c = talentLoading.Id,
            Month__c = 'Jul - 23',
            Hour__c =  34
        );
        insert new List<Talent_Loading_Line__c>{ talentLine1, talentLine2 };
        
        // Call the method to be tested
        Test.startTest();
        saveTalentLoading.deleteTalentLoadings(project.Id);
        Test.stopTest();
        
        // Retrieve the updated project record
        Project__c updatedProject = [SELECT TalentloadVersion__c, isTalentLoad__c FROM Project__c WHERE Id = :project.Id];
        
        // Verify the results
        System.assertEquals(0, updatedProject.TalentloadVersion__c);
        System.assertEquals(false, updatedProject.isTalentLoad__c);
        
        // Verify that the Talent Loadings were deleted
        List<Talent_Loading__c> deletedTalentLoadings = [SELECT Id FROM Talent_Loading__c WHERE Engagement__c = :project.Id];
        System.assertEquals(0, deletedTalentLoadings.size());
    }
    
    @IsTest
    public static void testDeleteTalentLoadingsTeamAlloc() {
        // Create test data
         Project__c project = new Project__c(Name = 'Test Project');
        project.TalentloadVersion__c = 1;
        project.Talent_Frequency__c = 'Monthly';
        project.StartDate__c = Date.today();
        project.EndDate__c = Date.today().addDays(90);
        project.Type__c = 'Internal';
        insert project;
        
        
        Talent_Loading__c talentLoading = new Talent_Loading__c(
            Engagement__c = project.Id,
            Version__c = 1,
            Role__c = 'Developer',
            Location__c = 'India'
        );
        insert talentLoading;
        
        Talent_Loading_Line__c talentLine1 = new Talent_Loading_Line__c(
            Talent_Loading__c = talentLoading.Id,
            Month__c = 'Jun - 23',
            Hour__c = 40
        );
        Talent_Loading_Line__c talentLine2 = new Talent_Loading_Line__c(
            Talent_Loading__c = talentLoading.Id,
            Month__c = 'Jul - 23',
            Hour__c =  34
        );
        insert new List<Talent_Loading_Line__c>{ talentLine1, talentLine2 };
        
        TeamAllocation__c teamAllocation = new TeamAllocation__c(Talent_Loading__c = talentLoading.Id);
		teamAllocation.StartDate__c = Date.today();
		teamAllocation.EndDate__c = Date.today().addDays(30);
	    teamAllocation.Resource_Role__c = 'Developer';
		teamAllocation.Project__c = project.Id;
        insert teamAllocation;
        teamAllocation.AllocationHours__c = 15;
        update teamAllocation;
        // Call the method to be tested
        Test.startTest();
        saveTalentLoading.deleteTalentLoadingsTeamAlloc(project.Id);
        Test.stopTest();
        
        // Retrieve the updated project record
        Project__c updatedProject = [SELECT TalentloadVersion__c, isTalentLoad__c FROM Project__c WHERE Id = :project.Id];
        
        // Verify the results
        System.assertEquals(0, updatedProject.TalentloadVersion__c);
        System.assertEquals(false, updatedProject.isTalentLoad__c);
        
        // Verify that the Talent Loadings and Team Allocations were deleted
        List<Talent_Loading__c> deletedTalentLoadings = [SELECT Id FROM Talent_Loading__c WHERE Engagement__c = :project.Id];
        List<TeamAllocation__c> deletedTeamAllocations = [SELECT Id FROM TeamAllocation__c WHERE Talent_Loading__c = :talentLoading.Id];
        
        System.assertEquals(0, deletedTalentLoadings.size());
        System.assertEquals(0, deletedTeamAllocations.size());
    }


}