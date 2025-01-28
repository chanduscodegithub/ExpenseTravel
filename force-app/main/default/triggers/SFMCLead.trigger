trigger SFMCLead on Lead (after insert, after update) {
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            List<Lead> allLeads = (List<Lead>)Trigger.new;
            List<Lead> eligibleLeads = new List<Lead>();
            for(Lead eachLead : allLeads){
                System.debug('__________IN_TRIGGER__DEBUG______________');
                System.debug(eachLead);
                if(eachLead.Status == 'Enquiry' && eachLead.Email != null && eachLead.Email != ''){
                     eligibleLeads.add(eachLead);
                }
            }
            if(eligibleLeads.size() > 0) SFMCLeadTriggerHelper.sendLeads(eligibleLeads);
        }else if(Trigger.isUpdate){
            List<Lead> allLeads = (List<Lead>)Trigger.new;
            Map<Id, Lead> oldMap = (Map<Id, Lead>)Trigger.oldMap;
            List<Lead> eligibleLeads = new List<Lead>();
            List<Lead> updateLeads = new List<Lead>();
            for(Lead eachLead : allLeads){
                if(eachLead.Status == 'Enquiry' && eachLead.Email != null && eachLead.Email != '' && oldMap.get(eachLead.Id).Status != eachLead.Status) eligibleLeads.add(eachLead);
                else if (eachLead.Status == 'SQL - Contacted' && eachLead.Email != null && eachLead.Email != '' && oldMap.get(eachLead.Id).Status != eachLead.Status) updateLeads.add(eachLead);
            }
            if(eligibleLeads.size() > 0) SFMCLeadTriggerHelper.sendLeads(eligibleLeads);
            if(updateLeads.size() > 0) SFMCLeadTriggerHelper.updateLeads(updateLeads);
        }
    }
}