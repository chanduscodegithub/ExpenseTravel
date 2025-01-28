public class AddmultipleTimeSheetController {

    Timesheet__c timeSheet = new Timesheet__c();
	public list<Timesheet__c> listTimeSheet{ get; set; }
	

    public AddmultipleTimeSheetController(ApexPages.StandardController stdController)
    {
        listTimeSheet=new list<Timesheet__c>();
        listTimeSheet.add(timeSheet);
          
    }

    Public void addTimeSheet()
    {
        Timesheet__c ts = new Timesheet__c();
        listTimeSheet.add(ts);
    }
    
    public PageReference saveTieSheet() {
        
        for(Integer i=0; i<listTimeSheet.size(); i++)
        {
            insert listTimeSheet[i];
        }
            return Page.AllTimeSheetssaved;
        }
}