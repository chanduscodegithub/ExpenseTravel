@RestResource(urlMapping='/api/asvpevents/*')
global class Listener {
    private class CustomException extends Exception {
    }
    @HttpPost
    global static void handlePost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            if (String.isNotBlank(req.requestBody.toString())) {
                String email;
                String firstName;
                String lastName;
                String region;
                String managerName;
                String managerEmail;
                String action;
                JSONParser parser = JSON.createParser(req.requestBody.toString());
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                        switch on parser.getText().toLowerCase() {
                            when 'email' {
                                parser.nextToken();
                                email = parser.getText();
                            }
                            when 'firstname' {
                                parser.nextToken();
                                firstName = parser.getText();
                            }
                            when 'lastname' {
                                parser.nextToken();
                                lastName = parser.getText();
                            }
                            when 'region' {
                                parser.nextToken();
                                region = parser.getText();
                            }
                            when 'manageremail'{
                                parser.nextToken();
                                managerEmail = parser.getText();
                            }
                            when 'managername'{
                                parser.nextToken();
                                managerName = parser.getText();
                            }
                            when 'action'{
                                parser.nextToken();
                                action = parser.getText().toLowerCase();
                            }
                        }
                    }
                }
                if (String.isNotBlank(email) && String.isNotBlank(firstName) && String.isNotBlank(lastName)) {
                    email = email.toLowerCase();
                    List<Contact> conList = [SELECT Id, Name FROM Contact WHERE Email = :email WITH SYSTEM_MODE];
                    List<Lead> leadList = [SELECT Id, Name FROM Lead WHERE Email = :email WITH SYSTEM_MODE];
                    if(conList.size() > 0 || leadList.size() > 0){
                        if(conList.size() > 0 && action == 'meeting'){
                            Task meetTask = new Task(Subject = 'Booked Meeting', WhoId = conList[0].Id, Description = 'This task was created when propects opts for meeting ASVP. This indicates that the propects is interested in learning more about the product and may be ready to speak with a sales representative.\n\nDetails of the assigned regional manager:\n    Manager Name: '+managerName+'.\n    Manager Email: '+managerEmail);
                            insert as system meetTask;
                            ListenerHelper.sendEmail(managerName, managerEmail, conList[0].Id);
                            res.responseBody = Blob.valueOf(ListenerHelper.buildResponse(false, 'Created Task for the existing contact.', conList[0].Id));
                        }else if(conList.size() > 0 && action == 'download'){
                            Task meetTask = new Task(Subject = 'Datasheet Downloaded', WhoId = conList[0].Id, Description = 'This task was created when propects downloads ASVP Datasheet. This indicates that the propects is interested in learning more about the product.\n');
                            insert as system meetTask;
                            conList[0].ASVP_datasheet_downloaded__c = true;
                            upsert as system conList[0];
                            res.responseBody = Blob.valueOf(ListenerHelper.buildResponse(false, 'Created Task for the existing contact.', conList[0].Id));
                        }else if(leadList.size() > 0 && action == 'download'){
                            Task meetTask = new Task(Subject = 'Datasheet Downloaded', WhoId = leadList[0].Id, Description = 'This task was created when lead downloads ASVP Datasheet. This indicates that the propects is interested in learning more about the product.\n');
                            insert as system meetTask;
                            leadList[0].ASVP_datasheet_downloaded__c = true;
                            upsert as system leadList[0];
                            res.responseBody = Blob.valueOf(ListenerHelper.buildResponse(false, 'Created Task for the existing contact.', leadList[0].Id));
                        }else if(leadList.size() > 0 && action == 'meeting'){
                            Task meetTask = new Task(Subject = 'Booked Meeting', WhoId = leadList[0].Id, Description = 'This task was created when lead opts for meeting ASVP. This indicates that the propects is interested in learning more about the product and may be ready to speak with a sales representative.\n\nDetails of the assigned regional manager:\n    Manager Name: '+managerName+'.\n    Manager Email: '+managerEmail);
                            insert as system meetTask;
                            ListenerHelper.sendEmail(managerName, managerEmail, leadList[0].Id);
                            res.responseBody = Blob.valueOf(ListenerHelper.buildResponse(false, 'Created Task for the existing lead.', leadList[0].Id));
                        }
                        res.statusCode = 201;
                    }else if(action == 'meeting'){
                        Lead newLead = new Lead(FirstName=firstName, LastName=lastName, Email=email, Company='Not Received', ctry__c=region, LeadSource='ASVP', Source_URL__c='https://www.crmit.com/');
                        insert as system newLead;
                        Task meetTask = new Task(Subject = 'Booked Meeting', WhoId = newLead.Id, Description = 'This task was created when lead opts for meeting ASVP. This indicates that the lead is interested in learning more about the product and may be ready to speak with a sales representative.\n\nDetails of the assigned regional manager:\n    Manager Name: '+managerName+'.\n    Manager Email: '+managerEmail);
                        insert as system meetTask;
                        ListenerHelper.sendEmail(managerName, managerEmail, newLead.Id);
                        ListenerHelper.sendLeadEmail(newLead.Id);
                        res.responseBody = Blob.valueOf(ListenerHelper.buildResponse(false, 'Created Task with new Lead.', newLead.Id));
                        res.statusCode = 201;
                    }else{
                        Lead newLead = new Lead(FirstName=firstName, LastName=lastName, Email=email, Company='Not Received', ctry__c=region, LeadSource='ASVP', ASVP_datasheet_downloaded__c=true, Source_URL__c='https://www.crmit.com/');
                        insert as system newLead;
                        Task meetTask = new Task(Subject = 'Datasheet Downloaded', WhoId = newLead.Id, Description = 'This task was created when lead downloads ASVP Datasheet. This indicates that the propects is interested in learning more about the product.\n');
                        insert as system meetTask;
                        ListenerHelper.sendLeadEmail(newLead.Id);
                        res.responseBody = Blob.valueOf(ListenerHelper.buildResponse(false, 'Created Task with new Lead.', newLead.Id));
                        res.statusCode = 201;
                    }
                } else {
                    res.statusCode = 403;
                    throw new CustomException('Email, FirstName, LastName are a required field, please refer schema.');
                }
            } else {
                res.statusCode = 400;
                throw new CustomException('Expecting Body');
            }
        } catch (Exception e) {
            Blob respInBlob = Blob.valueOf(ListenerHelper.buildResponse(true, e.getMessage(), String.valueOf(e.getLineNumber())));
            res.responseBody = respInBlob;
            if (res.statusCode == null) {
                res.statusCode = 417;
            }
        } finally {
            res.headers.put('Content-Type', 'application/json');
        }
    }
}