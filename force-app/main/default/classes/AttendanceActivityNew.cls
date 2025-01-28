public class AttendanceActivityNew {
    public static Map<Id, List<Attendance_Activity__c>> getActivity(String employeeId) {
        Map<Id, List<Attendance_Activity__c>> attendanceActivitiesMap = new Map<Id, List<Attendance_Activity__c>>();
        List<Attendance__c> attendanceList = [
            SELECT Id 
            FROM Attendance__c 
            WHERE Employee__c = :employeeId
        ];
        
        for (Attendance__c attendance : attendanceList) {
            Attendance_Activity__c firstCheckIn;
            try {
                firstCheckIn = [
                    SELECT Id, Name, Attendance__c, Action_Type__c, Action_Date_and_Time__c
                    FROM Attendance_Activity__c
                    WHERE Attendance__c = :attendance.Id AND Action_Type__c = 'Check In'
                    ORDER BY Action_Date_and_Time__c ASC
                    LIMIT 1
                ];
            } catch (Exception e) {
                firstCheckIn = null;
            }

            Attendance_Activity__c lastCheckOut;
            try {
                lastCheckOut = [
                    SELECT Id, Name, Attendance__c, Action_Type__c, Action_Date_and_Time__c
                    FROM Attendance_Activity__c
                    WHERE Attendance__c = :attendance.Id AND Action_Type__c = 'Check Out'
                    ORDER BY Action_Date_and_Time__c DESC
                    LIMIT 1
                ];
            } catch (Exception e) {
                lastCheckOut = null;
            }
            
            List<Attendance_Activity__c> activities = new List<Attendance_Activity__c>();
            if (firstCheckIn != null) {
                activities.add(firstCheckIn);
            } 
            if (lastCheckOut != null) {
                activities.add(lastCheckOut);
            }
            attendanceActivitiesMap.put(attendance.Id, activities);
        }
        return attendanceActivitiesMap;
    }
}