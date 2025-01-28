/*------------------------------------------------------------------------------------
Author:        Paras Prajapati
Description:   CompareSkillController

History
Date            Author             Comments
--------------------------------------------------------------------------------------

------------------------------------------------------------------------------------*/
public with sharing class CompareSkillController {

    public class CertificationData{
        @AuraEnabled
        public List<Certifications> requiredCertificationList;
        @AuraEnabled
        public String  infoCertificationMessage;

        @AuraEnabled
        public List<Skills> requiredSkillsList;
        @AuraEnabled
        public String  infoSkillMessage;
        @AuraEnabled
        public String  infoTrailblazerRankMessage;
    }

    public class Certifications{
        @AuraEnabled 
        public String requiredValue;
        @AuraEnabled 
        public String requiredKey;
    }

    public class Skills{
        @AuraEnabled 
        public String requiredValue;
        @AuraEnabled 
        public String requiredKey;
    }
    @AuraEnabled(cacheable=true)
    public static CertificationData getUnMatchedEmployeeSkillSet(String employeeId){
        CertificationData certificationData = new CertificationData();
        SObjectAccessDecision securityDecision = Security.stripInaccessible(AccessType.READABLE,[SELECT Id, Certifications__c,Skill_Sets__c,TrailblazerRank__c,Designation__r.Name, 
        Designation__r.CertificationsRequired__c,Designation__r.SkillRequired__C,Designation__r.Trailblazer_Rank__c FROM Employee__c where  Id =:employeeid]);
        List<Employee__c> employeeRecords = securityDecision.getRecords();
        /*List<Employee__c> employeeRecords = [SELECT Id, Certifications__c,Skill_Sets__c,TrailblazerRank__c,Designation__r.Name, 
        Designation__r.CertificationsRequired__c,Designation__r.SkillRequired__C,Designation__r.Trailblazer_Rank__c FROM Employee__c where  Id =:employeeid];*/
        if(!employeeRecords.isEmpty()){
            Employee__c employeeRecord = employeeRecords.get(0);
            findRequiredCertificates(employeeRecord,certificationData);
            findRequiredSkills(employeeRecord,certificationData);
            findTrailblazerRank(employeeRecord,certificationData);
        }
        return certificationData;
        
    }

    public static void findRequiredCertificates(Employee__c employeeRecord, CertificationData certificationData){
        List<String> employeeCertifications = new List<String>();
        List<String> requiredConfguredRoleCertification = new List<String>();
        List<Certifications> requiredCertificationList = new List<Certifications>();
        if(employeeRecord.Certifications__c!=null && employeeRecord.Certifications__c!=''){
            employeeCertifications = (employeeRecord.Certifications__c).split(';');
        }
        if(employeeRecord.Designation__r.CertificationsRequired__c!=null && employeeRecord.Designation__r.CertificationsRequired__c!=''){
            requiredConfguredRoleCertification = (employeeRecord.Designation__r.CertificationsRequired__c).split(';');
        }
        if(requiredConfguredRoleCertification!=null && !requiredConfguredRoleCertification.isEmpty()){
           for(String requiredCertificates : requiredConfguredRoleCertification){
                if(!employeeCertifications.Contains(requiredCertificates)){
                    Certifications certification = new Certifications();
                    certification.requiredValue = requiredCertificates;
                    certification.requiredKey = requiredCertificates;
                    requiredCertificationList.add(certification);

                }
           }
           certificationData.infoCertificationMessage='Required Certification for your ' + employeeRecord.Designation__r.Name + ' Role';
           certificationData.requiredCertificationList = requiredCertificationList;
        }else{
            certificationData.infoCertificationMessage='Required Certificate are not configured for ' + employeeRecord.Designation__r.Name;
            certificationData.requiredCertificationList = requiredCertificationList;

        }
    }

    public static void findRequiredSkills(Employee__c employeeRecord, CertificationData certificationData){
        List<String> employeeSkills = new List<String>();
        List<String> requiredConfguredSkills = new List<String>();
        List<Skills> requiredSkillsList = new List<Skills>();
        if(employeeRecord.Skill_Sets__c!=null && employeeRecord.Skill_Sets__c!=''){
            employeeSkills = (employeeRecord.Skill_Sets__c).split(';');
        }
        if(employeeRecord.Designation__r.SkillRequired__C!=null && employeeRecord.Designation__r.SkillRequired__C!=''){
            requiredConfguredSkills = (employeeRecord.Designation__r.SkillRequired__C).split(';');
        }
        if(requiredConfguredSkills!=null && !requiredConfguredSkills.isEmpty()){
           for(String requiredSkills : requiredConfguredSkills){
                if(!employeeSkills.Contains(requiredSkills)){
                    Skills skills = new Skills();
                    skills.requiredValue = requiredSkills;
                    skills.requiredKey = requiredSkills;
                    requiredSkillsList.add(skills);

                }
           }
           certificationData.infoSkillMessage='Required Skills for your ' + employeeRecord.Designation__r.Name + ' Role';
           certificationData.requiredSkillsList = requiredSkillsList;
        }else{
            certificationData.infoSkillMessage='Required Skils are not configured for ' + employeeRecord.Designation__r.Name;
            certificationData.requiredSkillsList = requiredSkillsList;

        }
    }

    public static void findTrailblazerRank(Employee__c employeeRecord, CertificationData certificationData){
        String employeeTrailblazerRank;
        String requiedTrailblazerRank;
        if(employeeRecord.TrailblazerRank__c!=null && employeeRecord.TrailblazerRank__c!=''){
            employeeTrailblazerRank = (employeeRecord.TrailblazerRank__c);
        }
        if(employeeRecord.Designation__r.Trailblazer_Rank__c!=null && employeeRecord.Designation__r.Trailblazer_Rank__c !=''){
            requiedTrailblazerRank  = employeeRecord.Designation__r.Trailblazer_Rank__c;
        }
        if(requiedTrailblazerRank!=employeeTrailblazerRank){
        certificationData.infoTrailblazerRankMessage='Required Trailblazer Rank for your ' + employeeRecord.Designation__r.Name + ' Role is ' +  employeeRecord.Designation__r.Trailblazer_Rank__c;
        }

    }

    



}