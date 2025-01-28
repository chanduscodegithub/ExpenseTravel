@RestResource(urlMapping='/api/asvpsurvey/*')
global with sharing class ListenerForm {
    private class CustomException extends Exception {
    }
    @HttpPost
    global static void handlePost() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            if (String.isNotBlank(req.requestBody.toString())) {
                String mcq1Q;
                String mcq1A;
                String mcq2Q;
                String mcq2A;
                String mcq3Q;
                String mcq3A;
                Id recId;
                JSONParser parser = JSON.createParser(req.requestBody.toString());
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                        switch on parser.getText().toLowerCase() {
                            when 'mcq1q' {
                                parser.nextToken();
                                mcq1Q = parser.getText();
                            }
                            when 'mcq1a' {
                                parser.nextToken();
                                mcq1A = parser.getText();
                            }
                            when 'mcq2q' {
                                parser.nextToken();
                                mcq2Q = parser.getText();
                            }
                            when 'mcq2a' {
                                parser.nextToken();
                                mcq2A = parser.getText();
                            }
                            when 'mcq3q' {
                                parser.nextToken();
                                mcq3Q = parser.getText();
                            }
                            when 'mcq3a' {
                                parser.nextToken();
                                mcq3A = parser.getText();
                            }
                            when 'recordid'{
                                parser.nextToken();
                                recId = (Id)parser.getText();
                            }
                        }
                    }
                }
                if (String.isNotBlank(mcq1Q) && String.isNotBlank(mcq1A) && String.isNotBlank(mcq2Q) && String.isNotBlank(mcq2A) && String.isNotBlank(mcq3Q) && String.isNotBlank(mcq3A) && String.isNotBlank(recId)) {
                    Task newTask = new Task(Subject = 'ASVP Form Filled', WhoId = recId, Description = 'Survey Info:\n'+mcq1Q+'\n'+mcq1A+'\n\n'+mcq2Q+'\n'+mcq2A+'\n\n'+mcq3Q+'\n'+mcq3A);
                    insert newTask;
                    res.responseBody = Blob.valueOf(JSON.serialize(newTask));
                } else {
                    res.statusCode = 403;
                    throw new CustomException('MCQ/A and ID are required field, please refer schema.');
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