public class ManualSharingExistingLeaves {
    /*
     * Description: Method to share leaves added through Data Loader and not shared with their respective manager.
     * 
     * 
     */
    public static void shareLeaves(){
        // List of IDs of the Leaves that are not shared with their reporting manager.
        List<String> unsharedLeaves = new List<String>();
        unsharedLeaves.add('a5k1K000000LP91QAG');
        unsharedLeaves.add('a5k1K000000LP92QAG');
        unsharedLeaves.add('a5k1K000000LP93QAG');
        unsharedLeaves.add('a5k1K000000LP94QAG');
        unsharedLeaves.add('a5k1K000000LP95QAG');
        unsharedLeaves.add('a5k1K000000LP96QAG');
        unsharedLeaves.add('a5k1K000000LP97QAG');
        unsharedLeaves.add('a5k1K000000LP98QAG');
        unsharedLeaves.add('a5k1K000000LP99QAG');
        unsharedLeaves.add('a5k1K000000LP9AQAW');
        unsharedLeaves.add('a5k1K000000LP9BQAW');
        unsharedLeaves.add('a5k1K000000LP9CQAW');
        unsharedLeaves.add('a5k1K000000LP9DQAW');
        unsharedLeaves.add('a5k1K000000LP9EQAW');
        unsharedLeaves.add('a5k1K000000LP9FQAW');
        unsharedLeaves.add('a5k1K000000LP9GQAW');
        unsharedLeaves.add('a5k1K000000LP9HQAW');
        unsharedLeaves.add('a5k1K000000LP9IQAW');
        unsharedLeaves.add('a5k1K000000LP9JQAW');
        unsharedLeaves.add('a5k1K000000LP9KQAW');
        unsharedLeaves.add('a5k1K000000LP9LQAW');
        unsharedLeaves.add('a5k1K000000LP9MQAW');
        unsharedLeaves.add('a5k1K000000LP9NQAW');
        unsharedLeaves.add('a5k1K000000LP9OQAW');
        unsharedLeaves.add('a5k1K000000LP9PQAW');
        unsharedLeaves.add('a5k1K000000LP9QQAW');
        unsharedLeaves.add('a5k1K000000LP9RQAW');
        unsharedLeaves.add('a5k1K000000LP9SQAW');
        unsharedLeaves.add('a5k1K000000LP9TQAW');
        unsharedLeaves.add('a5k1K000000LP9UQAW');
        unsharedLeaves.add('a5k1K000000LP9VQAW');
        unsharedLeaves.add('a5k1K000000LP9WQAW');
        unsharedLeaves.add('a5k1K000000LP9XQAW');
        unsharedLeaves.add('a5k1K000000LP9YQAW');
        unsharedLeaves.add('a5k1K000000LP9ZQAW');
        unsharedLeaves.add('a5k1K000000LP9aQAG');
        unsharedLeaves.add('a5k1K000000LP9bQAG');
        unsharedLeaves.add('a5k1K000000LP9cQAG');
        unsharedLeaves.add('a5k1K000000LP9dQAG');
        unsharedLeaves.add('a5k1K000000LP9eQAG');
        unsharedLeaves.add('a5k1K000000LP9fQAG');
        unsharedLeaves.add('a5k1K000000LP9gQAG');
        unsharedLeaves.add('a5k1K000000LP9hQAG');
        unsharedLeaves.add('a5k1K000000LP9iQAG');        
        
        // Get All Leaves' Data
        List<Employee_Leave__c> allLeaves = [SELECT Id, Employee__r.SF_User__c, Reporting_Manager__c FROM Employee_Leave__c WHERE ID IN :unsharedLeaves];
        // Processing Leave List
        List<Employee_Leave__Share> empLeaveShareList = new List<Employee_Leave__Share>();
        for(Employee_Leave__c eachLeaves : allLeaves){
            Employee_Leave__Share addEmpLeaveShare = new Employee_Leave__Share();
            addEmpLeaveShare.ParentId = eachLeaves.id;
            addEmpLeaveShare.UserOrGroupId = eachLeaves.Employee__r.SF_User__c;
            addEmpLeaveShare.AccessLevel = 'Edit';
            addEmpLeaveShare.RowCause = 'Manual';
            empLeaveShareList.add(addEmpLeaveShare);
        }
        for(Employee_Leave__c eachLeaves : allLeaves){
            Employee_Leave__Share addEmpLeaveShare = new Employee_Leave__Share();
            addEmpLeaveShare.ParentId = eachLeaves.id;
            addEmpLeaveShare.UserOrGroupId = eachLeaves.Reporting_Manager__c;
            addEmpLeaveShare.AccessLevel = 'Edit';
            addEmpLeaveShare.RowCause = 'Manual';
            empLeaveShareList.add(addEmpLeaveShare);
        }
        if(empLeaveShareList.size() > 0){
            upsert as system empLeaveShareList;
        }
    }
}