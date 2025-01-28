@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    private Integer statusCode;
    

    public MockHttpResponseGenerator(Integer statusCode) {
        this.statusCode = statusCode;
        
    }

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"example":"test"}');
        res.setStatusCode(statusCode);
        return res;

    
    }
}