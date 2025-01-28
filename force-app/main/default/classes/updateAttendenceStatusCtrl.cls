public without sharing class updateAttendenceStatusCtrl implements Queueable {
    
    private List<Employee_Leave__c> empList;
    private Map<Id,Employee_Leave__c> empLeaveMap;
    public updateAttendenceStatusCtrl(List<Employee_Leave__c> empListFromTrigger,Map<Id,Employee_Leave__c> empLeaveMapFromTrigger){
        empList = new List<Employee_Leave__c>(empListFromTrigger);
        empLeaveMap = new Map<Id,Employee_Leave__c>(empLeaveMapFromTrigger);
    }
    
    public void execute(QueueableContext context){
        try{
            Date todayDate = System.today();
            
            List<Attendance__c> updateAttendence = new List<Attendance__c>();
            
            Map<Id,List<Attendance__c>> employeeRelatedAttendence = new Map<Id,List<Attendance__c>>();
            
            List<Employee_Leave__c> selectedEmployeeLeave = new List<Employee_Leave__c>();
            Set<Id> empIds = new Set<Id>();
            
            Map<Id,List<Employee_Leave__c>> empLeavesMap = new Map<Id,List<Employee_Leave__c>>();
            //System.debug('empList123:::'+empList);
            for(Employee_Leave__c emp : empList){
                if(emp.End_Date__c < todayDate && emp.Leave_Type__c != 'Work from Home(WFH)'){
                    empIds.add(emp.Employee__c);
                    selectedEmployeeLeave.add(emp);
                }
            }
            
            if(selectedEmployeeLeave.size() > 0){
                for(Employee_Leave__c leave : selectedEmployeeLeave){
                    if(empLeavesMap.containskey(leave.Employee__c)){
                        empLeavesMap.get(leave.Employee__c).add(leave);
                    }else{
                        empLeavesMap.put(leave.Employee__c,new List<Employee_Leave__c>{leave});
                    }
                }
                
                Map<Id,Attendance__c> allAttendence = new Map<Id,Attendance__c>([Select Id,Date__c,Name,Employee__c,Holiday_Status__c from Attendance__c where Employee__c IN:empIds]);
                
                for(Attendance__c atd : allAttendence.values()){
                    if(employeeRelatedAttendence.containsKey(atd.Employee__c)){
                        employeeRelatedAttendence.get(atd.Employee__c).add(atd);
                    }else{
                        employeeRelatedAttendence.put(atd.Employee__c,new List<Attendance__c>{atd});
                    }
                }                
                
                for(Employee_Leave__c empLeave : empLeaveMap.values()){
                    List<Attendance__c> allAtd = getAttendence(empLeave,employeeRelatedAttendence.get(empLeave.Employee__c));
                    updateAttendence.addAll(allAtd);
                }
                
                if(updateAttendence.size() > 0){
                    update updateAttendence;
                }
            }
        }catch(Exception e){
            Log__c log = new Log__c(Method_Name__c='updateAttendenceStatusCtrl', Class_Name__c='updateAttendenceStatusCtrl', Line_Number__c=e.getLineNumber(), Reason__c=e.getMessage());
            insert log;
        }
    }
    
    private static List<Attendance__c> getAttendence(Employee_Leave__c empLeave,List<Attendance__c> attendenceList){
        List<Attendance__c> rangeRecordDetials = new List<Attendance__c>();
        
        for(Attendance__c atd : attendenceList){
            if((atd.Date__c >= empLeave.Start_Date__c && atd.Date__c <= empLeave.End_Date__c) && atd.Employee__c == empLeave.Employee__c){
                Attendance__c updateAtd = new Attendance__c();
                updateAtd.Id = atd.Id;
                updateAtd.Holiday_Status__c = empLeave.Status__c == 'Rejected' ? null : 'On Leave';
                rangeRecordDetials.add(updateAtd);
            }
        }
        return rangeRecordDetials;
    }
}