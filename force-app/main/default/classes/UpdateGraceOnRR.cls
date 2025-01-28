public class UpdateGraceOnRR {
    public static void updateenddate()
    {
        List<Position__c> updateDate= new  List<Position__c>();
        List<Position__c> getdates=[select id,Close_Date__c from Position__c where Close_Date__c=:System.Today() and Status__c!='position closed'];
        for(Position__c p:getdates)
        { 
            Position__c RR = new  Position__c();
            date d = p.Close_Date__c;
            RR.Close_Date__c=d.addDays(5);
            system.debug('Close_Date__c'+RR.Close_Date__c);
            RR.id=p.Id;
            updateDate.add(RR);
            system.debug('Date'+updateDate);
        }
        update updateDate;
        
    }

}