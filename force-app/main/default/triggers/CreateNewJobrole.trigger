trigger CreateNewJobrole on Job_Role__c (before insert) {
    Schema.SObjectType s = Schema.getGlobalDescribe().get('Position__c') ;
    Schema.DescribeSObjectResult r = s.getDescribe() ;
    Map<String,String> picklistValues= new Map<String,String>();
    Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
    Schema.DescribeFieldResult fieldResult = fields.get('Position_Title__c').getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
    for( Schema.PicklistEntry pickListVal : ple){
        picklistValues.put(pickListVal.getValue(),pickListVal.getLabel());
        //System.debug(pickListVal.getLabel() +' '+pickListVal.getValue());
    } 
    for(Job_Role__c J:Trigger.New)
    {
        if(!picklistValues.containsKey(J.Name))
        {
            J.Name.addError('Please select Job Name same as Position Title');
        }
    }
    
}