public class SFMCLeadTriggerHelper {
    private static final String DE_KEY = '67926206-E4E0-49CB-8152-4C50A6E6E05A';
    private static String stripQuotesAndCommas(String input) {
        if (input == null) {
            return null;
        }
        String output = input.replace('"', '').replace(',', '');
        return output;
    }
    public static void sendLeads(List<Lead> allLeads){
        // Build JSON from the allLeads
        String body = '{"items":[';
        String eachObject = '';
        for(Lead eachLead : allLeads){
             	System.debug('__________IN_HELPER______________');
                System.debug(eachLead);
            eachObject = '{"Id":"'+eachLead.Id+'","FirstName":"'+stripQuotesAndCommas(eachLead.FirstName)+'","LastName":"'+stripQuotesAndCommas(eachLead.LastName)+'","Email":"'+eachLead.Email+'","Status":"'+eachLead.Status+'","LeadSource":"'+eachLead.LeadSource+'"},';
            body += eachObject;
        }
        body = body.substring(0, body.length() - 1);
        body += ']}';
        System.debug(body);
        makeInsertCalls(body);
    }
    public static void updateLeads(List<Lead> allLeads){
        String body = '[';
        String eachObject = '';
        for(Lead eachLead : allLeads){
            eachObject = '{"keys":{"Id":"'+eachLead.Id+'"},"values":{"FirstName":"'+stripQuotesAndCommas(eachLead.FirstName)+'","LastName":"'+stripQuotesAndCommas(eachLead.LastName)+'","Email":"'+eachLead.Email+'","Status":"'+eachLead.Status+'","LeadSource":"'+eachLead.LeadSource+'"}},';
            body += eachObject;
        }
        body = body.substring(0, body.length() - 1);
        body += ']';
        System.debug(body);
        makeUpdateCalls(body);
    }
    @future(callout=true)
    private static void makeInsertCalls(String body){
        sf_mc_org.CustomIntegration.makeRequest('/data/v1/async/dataextensions/key:'+DE_KEY+'/rows', 'POST', true, body, false);
    }
    @future(callout=true)
    private static void makeUpdateCalls(String body){
        sf_mc_org.CustomIntegration.makeRequest('/hub/v1/dataevents/key:'+DE_KEY+'/rowset', 'POST', true, body, false);
    }
}