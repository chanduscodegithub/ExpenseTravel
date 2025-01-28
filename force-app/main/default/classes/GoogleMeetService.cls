public class GoogleMeetService {
    private static final String NAMED_CREDENTIAL = 'GMeetAPI';

    public static void createOrUpdateCalendarEvent(String interviewId, List<String> emails, String candidateName, DateTime interviewDateTime) {
        String calendarId = 'vineet.kishore@crmit.com';
        String endpoint = 'callout:' + NAMED_CREDENTIAL + '/calendar/v3/calendars/' + calendarId + '/events'+ '?sendUpdates=all';

        Map<String, Object> existingEvent = new Map<String, Object>();
        List<Map<String, Object>> existingAttendees = new List<Map<String, Object>>();

        Map<String, Object> event = new Map<String, Object>();
        event.put('summary', candidateName);
        event.put('description', 'Interview for ' + candidateName);

        Datetime startIST = interviewDateTime.addHours(-5).addMinutes(-30);
        Map<String, Object> start = new Map<String, Object>();
        start.put('dateTime', startIST.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        start.put('timeZone', 'Asia/Kolkata');
        event.put('start', start);
    
        Datetime endIST = interviewDateTime.addHours(-4).addMinutes(-30);
        Map<String, Object> en = new Map<String, Object>();
        en.put('dateTime', endIST.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        en.put('timeZone', 'Asia/Kolkata');
        event.put('end', en);

        Set<String> processedEmails = new Set<String>();
        for (Map<String, Object> attendee : existingAttendees) {
            if (attendee.containsKey('email')) {
                processedEmails.add((String) attendee.get('email'));
            }
        }
        for (String email : emails) {
            if (email.contains('@') && !processedEmails.contains(email.trim())) {
                Map<String, Object> attendee = new Map<String, Object>();
                attendee.put('email', email.trim());
                existingAttendees.add(attendee);
            }
        }
        event.put('attendees', existingAttendees);

        Map<String, Object> conferenceData = new Map<String, Object>();
        Map<String, Object> createRequest = new Map<String, Object>();
        createRequest.put('requestId', String.valueOf(Math.random()));
        Map<String, Object> conferenceSolutionKey = new Map<String, Object>();
        conferenceSolutionKey.put('type', 'hangoutsMeet');
        createRequest.put('conferenceSolutionKey', conferenceSolutionKey);
        conferenceData.put('createRequest', createRequest);
        event.put('conferenceData', conferenceData);

        Integer minutesBeforeEvent = 240; // 4 hours
        Integer minutesToStart = Integer.valueOf((startIST.getTime() - DateTime.now().getTime()) / 60000); // Time in minutes to start

        if (minutesToStart < 480) {
            minutesBeforeEvent = 120; // Set reminder to just before the event starts
        }

        Map<String, Object> reminder = new Map<String, Object>();
        reminder.put('method', 'email');
        reminder.put('minutes', minutesBeforeEvent);

        Map<String, Object> reminders = new Map<String, Object>();
        reminders.put('useDefault', false);
        reminders.put('overrides', new List<Map<String, Object>> { reminder });
        event.put('reminders', reminders);

        String requestBody = JSON.serialize(event);
        System.debug('Event details are: ' + requestBody);

        // Make the callout
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(requestBody);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200 && res.getStatusCode() != 201) {
            throw new CalloutException('Failed to create or update calendar event: ' + res.getBody());
        }

        // Parse the response to get the event ID and Meet URL
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        String newEventId = (String) responseMap.get('id');
        String hangoutLink = (String) responseMap.get('hangoutLink');

        // Store event ID and Meet URL in the interview object
        Review__c interview = [SELECT Id, Meet_URL__c, Event_Id__c FROM Review__c WHERE Id = :interviewId LIMIT 1];
        if (String.isNotBlank(hangoutLink)) {
            interview.Meet_URL__c = hangoutLink;
        }
        interview.Event_Id__c = newEventId;
        update interview;
        System.debug('Event created or updated with ID: ' + newEventId + ' and Meet URL: ' + hangoutLink);
    }

    public static void cancelCalendarEvent(String interviewId, String eventId) {
        if (eventId == null) {
            throw new CalloutException('Event ID is required to cancel an event.');
        }

        String calendarId = 'vineet.kishore@crmit.com';
        String endpoint = 'callout:' + NAMED_CREDENTIAL + '/calendar/v3/calendars/' + calendarId + '/events/' + eventId + '?sendUpdates=all';

        // Make the callout
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('DELETE');
        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 204) {
            throw new CalloutException('Failed to cancel calendar event: ' + res.getBody());
        }

        Review__c interview = [SELECT Id, Meet_URL__c, Event_Id__c FROM Review__c WHERE Id = :interviewId LIMIT 1];
        interview.Meet_URL__c = null;
        interview.Event_Id__c = null;
        update interview;
        System.debug('Event cancelled with ID: ' + eventId);
    }

    public static void updateEvent(String eventId, DateTime startTime, DateTime endTime) {
        if (eventId == null) {
            throw new CalloutException('Event ID is required to update an event.');
        }

        String calendarId = 'vineet.kishore@crmit.com';
        String endpoint = 'callout:' + NAMED_CREDENTIAL + '/calendar/v3/calendars/' + calendarId + '/events/' + eventId + '?sendUpdates=all';

        Map<String, Object> eventDetails = new Map<String, Object>();
        DateTime startIST = startTime.addHours(-5).addMinutes(-30);
        Map<String, Object> start = new Map<String, Object>();
        start.put('dateTime', startIST.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        start.put('timeZone', 'Asia/Kolkata');
        eventDetails.put('start', start);

        DateTime endIST = endTime.addHours(-5).addMinutes(-30);
        Map<String, Object> en = new Map<String, Object>();
        en.put('dateTime', endIST.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        en.put('timeZone', 'Asia/Kolkata');
        eventDetails.put('end', en);

        String requestBody = JSON.serialize(eventDetails);
        System.debug('Update Event details are: ' + requestBody);

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('PATCH');
        req.setHeader('Content-Type', 'application/json');
        req.setBody(requestBody);

        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200 && res.getStatusCode() != 204) {
            throw new CalloutException('Failed to update Google Calendar event: ' + res.getBody());
        }

        System.debug('Event updated with ID: ' + eventId);
    }
}