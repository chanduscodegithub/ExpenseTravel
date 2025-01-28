public class LeadTriggerHelper extends TriggerHandler{
    public override void beforeInsert(){
        Boolean isContactUpdate = false;
        List<String> emailsASVP = new List<String>();
        List<String> existingWithDownloadLeadIds = new List<String>();
        List<String> existingWithoutDownloadLeadIds = new List<String>();
        List<Task> tasks = new List<Task>();
        List<Lead> bulkLeads = (List<Lead>)Trigger.new;
        for(Lead eachLead : bulkLeads){
            System.debug(eachLead);
            if(String.isNotBlank(eachLead.Email) && eachLead.LeadSource == 'ASVP'){
                emailsASVP.add(eachLead.Email);
            }
        }
        List<Lead> existingLeads = [SELECT Id, Name, Email FROM Lead WHERE Email IN :emailsASVP];
        List<Contact> allContacts = [SELECT Id, ASVP_datasheet_downloaded__c, Email FROM Contact WHERE Email IN :emailsASVP];
        emailsASVP.clear();
        Map<String, Lead> existingLeadMap = new Map<String, Lead>();
        List<String> conDuplicateLeads = new List<String>();
        for(Contact existingCon: allContacts){
            isContactUpdate = true;
            tasks.add(new Task(Subject = 'Downloaded ASVP Datasheet', WhoId = existingCon.Id, Description = 'This task was created when contact downloaded the datasheet for ASVP. This indicates that the contact is interested in learning more about the product and may be ready to speak with a sales representative.'));
            existingCon.ASVP_datasheet_downloaded__c = true;
            conDuplicateLeads.add(existingCon.Email);
        }
        for(Lead each : existingLeads){
             existingLeadMap.put(each.Email, each);
        }
        existingLeads.clear();
        for(Lead eachLead : bulkLeads){
            if(existingLeadMap.containsKey(eachLead.Email)){
                Lead existing = existingLeadMap.get(eachLead.Email);
                if(eachLead.ASVP_datasheet_downloaded__c){
                    tasks.add(new Task(Subject = 'Downloaded ASVP Datasheet', WhoId = existing.Id, Description = 'This task was created when lead downloaded the datasheet for ASVP. This indicates that the lead is interested in learning more about the product and may be ready to speak with a sales representative.'));
                	existingWithDownloadLeadIds.add(existing.Id);
                }else{
                    existingWithoutDownloadLeadIds.add(existing.Id);
                }
            }else{
                // System.debug('NOT EXISTING: '+eachLead.Email+' DOWNLOAD? -> '+eachLead.ASVP_datasheet_downloaded__c);
            }
        }
        if(isContactUpdate){
            update allContacts;
        }
        insert tasks;
        if(existingWithDownloadLeadIds.size() > 0 || existingWithoutDownloadLeadIds.size() > 0){
            markASVPDownload(existingWithDownloadLeadIds, existingWithoutDownloadLeadIds);
        }
        if(conDuplicateLeads.size() > 0){
            redundantLeads(conDuplicateLeads);
        }
    }
    public override void afterInsert(){
        List<Task> tasks = new List<Task>();
        List<Lead> bulkLeads = (List<Lead>)Trigger.new;
        for(Lead each : bulkLeads){
            if(each.ASVP_datasheet_downloaded__c && each.LeadSource == 'ASVP'){
                tasks.add(new Task(Subject = 'Downloaded ASVP Datasheet', WhoId = each.Id, Description = 'This task was created when lead downloaded the datasheet for ASVP. This indicates that the lead is interested in learning more about the product and may be ready to speak with a sales representative.'));
            }
        }
        insert tasks;
    }
    @future
    public static void markASVPDownload(List<String> existingWithDownloadLeadIds, List<String> existingWithoutDownloadLeadIds){
        List<String> emails = new List<String>();
        List<String> allExistingLeadIds = new List<String>();
        allExistingLeadIds.addAll(existingWithDownloadLeadIds);
        allExistingLeadIds.addAll(existingWithoutDownloadLeadIds);
        if(existingWithDownloadLeadIds.size() > 0){
            List<Lead> existingLeads = [SELECT ASVP_datasheet_downloaded__c, Email, Name FROM Lead WHERE Id IN :existingWithDownloadLeadIds];
            for(Lead each : existingLeads){
                each.ASVP_datasheet_downloaded__c = true;
                emails.add(each.Email);
            }
			update existingLeads;
        }
        if(existingWithoutDownloadLeadIds.size() > 0){
            List<Lead> existingLeads = [SELECT Email, Name FROM Lead WHERE Id IN :existingWithoutDownloadLeadIds];
            for(Lead each : existingLeads){
                emails.add(each.Email);
            }
        }
        List<Lead> toBeDeleted = [SELECT Id FROM Lead WHERE Email IN :emails AND Id NOT IN :allExistingLeadIds];
        delete toBeDeleted;
    }
    @future
    public static void redundantLeads(List<String> conDuplicateLeads){
        List<Lead> toBeDeleted = [SELECT Id FROM Lead WHERE Id IN :conDuplicateLeads];
        delete toBeDeleted;
    }
}