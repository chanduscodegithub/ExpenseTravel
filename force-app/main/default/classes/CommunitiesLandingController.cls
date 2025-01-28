/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        return Network.communitiesLanding();
    }

    @AuraEnabled(cacheable=true)
    public static List<Employee> getBirthdayAnniversaryList() {

        // List<Employee__c> fetchRecords = [SELECT Id, Name, EmployeeID__c, Employee_Classification__c, Department__c,
        //                                   Country__c, MobileNo__c FROM Employee__c ];

        Date todayDate = Date.today();  // January 8, 2025
        Date pastDate = todayDate.addDays(-8);  // December 31, 2024

        List<Employee__c> fetchRecords = [
            SELECT Id, Name, EmployeeID__c, Employee_Classification__c, Department__c,
                Country__c, MobileNo__c, DateofJoin__c
            FROM Employee__c
            ORDER BY DateofJoin__c
        ];


        System.debug('fetchRecords'+fetchRecords);

        List<Employee> empListWrapper = new List<Employee>();
        for(Employee__c emp:fetchRecords){
            // if(Date_of_Birth__c == date.Today() && Geo_Date_of_Joining__c == date.Today()){                    
                Employee empWrap = new Employee(); 
                empWrap.Id = emp.Id;
                empWrap.EmployeeID = emp.EmployeeID__c;
                empWrap.Name = emp.Name;
                empWrap.Role = emp.Employee_Classification__c;
                empWrap.Department = emp.Department__c;
                empWrap.Country = emp.Country__c;
                empWrap.MobileNo = emp.MobileNo__c;
                empWrap.dob=emp.Date_of_Birth__c;
                empWrap.doj=emp.DateofJoin__c;

                empListWrapper.add(empWrap);
            // }
        }
        return empListWrapper;
    }

    public class Employee {
        @AuraEnabled public string Id {get; set;}
        @AuraEnabled public String EmployeeID{get; set;}
        @AuraEnabled public String Name{get; set;}
        @AuraEnabled public String Role{get; set;}
        @AuraEnabled public String Department{get; set;}
        @AuraEnabled public String Country{get; set;}
        @AuraEnabled public String MobileNo{get; set;}
        @AuraEnabled public String ImageUrl {get; set;} 
        @AuraEnabled public Date dob {get; set;} 
         @AuraEnabled public Date doj {get; set;} 
    }

    public CommunitiesLandingController() {}
}