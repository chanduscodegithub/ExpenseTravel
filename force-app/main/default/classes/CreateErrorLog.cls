public class CreateErrorLog {
    
    public static void createLog( String Req,String Res,Integer ResCode,String Resstatus){
        Error_Logs__c el=new Error_Logs__c();
        el.Request_Body__c=Req;
        el.Response_Body__c=Res;
        el.Response_Code__c=ResCode;
        el.Response_Status__c=Resstatus;
        el.User__c=UserInfo.getUserId();
        insert el;
    }

}