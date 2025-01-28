public class MyTestClass {
    public static List<Map<String, Object>> getReporteesOfCurrentUser() {
        Id userId = UserInfo.getUserId();
        String currentYear = String.valueOf(System.today().year());
        
        // Map to hold all employees indexed by their reporting manager's ID
        Map<Id, List<Employee__c>> reportingManagerMap = new Map<Id, List<Employee__c>>();
        
        // Query all employees under the current user's hierarchy
        Map<Id, Employee__c> empMap = new Map<Id, Employee__c>([Select Id, Name, ReportingTo__c, ReportingTo__r.Name, EmployeeID__c, ReportingTo__r.SF_User__c, (select Id, Name, Status__c from Goal_Settings__r where Appraisal_Cycle__r.QPR_Year__c =: currentYear limit 1) from Employee__c Where Type__c != 'Partner Resource' and Active__c = true]);
        
        // Populate the reportingManagerMap
        for (Employee__c emp : empMap.values()) {
            if (emp.ReportingTo__c != null) {
                if (!reportingManagerMap.containsKey(emp.ReportingTo__c)) {
                    reportingManagerMap.put(emp.ReportingTo__c, new List<Employee__c>());
                }
                reportingManagerMap.get(emp.ReportingTo__c).add(emp);
            }
        }
        
        // Prepare hierarchical data structure
        List<Map<String, Object>> hierarchy = new List<Map<String, Object>>();
        for (Id managerId : reportingManagerMap.keySet()) {
            Map<String, Object> managerNode = new Map<String, Object>{
                'name' => empMap.containsKey(managerId) ? empMap.get(managerId).Name : managerId,
                'reportees' => getReportees(reportingManagerMap, managerId, empMap)
            };
            hierarchy.add(managerNode);
        }
        
        return hierarchy;
    }
    
    // Method to build hierarchical data structure
    private static List<Map<String, Object>> getReportees(Map<Id, List<Employee__c>> reportingManagerMap, Id managerId, Map<Id, Employee__c> empMap) {
        List<Map<String, Object>> reportees = new List<Map<String, Object>>();
        
        if (managerId != null && reportingManagerMap.containsKey(managerId)) {
            List<Employee__c> reporteeList = reportingManagerMap.get(managerId);
            for (Employee__c reportee : reporteeList) {
                Map<String, Object> reporteeNode = new Map<String, Object>{
                    'name' => reportee.Name,
                    'reportees' => getReportees(reportingManagerMap, reportee.Id, empMap)
                };
                reportees.add(reporteeNode);
            }
        }
        
        return reportees;
    }
}