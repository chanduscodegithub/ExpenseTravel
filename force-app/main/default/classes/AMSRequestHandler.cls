/*------------------------------------------------------------
Author       :  Maaz Rahman
Company      :  CRMIT Pvt. Ltd.
Description  :  _
Inputs       :  Mentioned before each methods. No constructor for the CalloutObjects class.
Test Class   :  _

History
<Date>         <Authors Name>        <Brief Description of Change>
------------------------------------------------------------------*/
/**
 * A REST resource class for handling AMS requests.
 * @RestResource(urlMapping='/ams/addon/*')
 * @author Maaz
 * @since 2023-06-13
 */
@RestResource(urlMapping='/ams/addon/*')
global with sharing class AMSRequestHandler {
    /**
     * Handles the GET requests for the AMS resource.
     * @HttpGet
     * @global
     * @param {RestRequest} req - The request object containing the query parameters.
     * @param {RestResponse} res - The response object to be sent back to the client.
     * @author Maaz
     * @since 2023-06-13
     */
    @HttpGet
    global static void getHandler() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            CalloutObjects.BuildBodyPrefix bodyData = new CalloutObjects.BuildBodyPrefix(req, res);
            Integer sizeMinus1 = req.requestURI.split('/').size() - 1;
            String attributeParam = req.requestURI.split('/')[sizeMinus1];
            if(attributeParam == 'userdata' && sizeMinus1 == 3){
                //AMSRequestHelper.getUserData(req, res, bodyData);
            }else{
                bodyData.setMessage('Error: sorry, this resource/path/method is not allowed as of now, please refer the schema file.');
                bodyData.setCode(404);
            }

            // Generating Response
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serializePretty(bodyData.bodyObj));
            res.statusCode = bodyData.getCode();
        } catch (Exception e) {
            res.responseBody = Blob.valueOf(e.getMessage());
            res.statusCode = 500;
        }
    }
    /**
     * Handles the POST requests for the AMS resource.
     * @HttpPost
     * @global
     * @param {RestRequest} req - The request object containing the query parameters and body.
     * @param {RestResponse} res - The response object to be sent back to the client.
     * @author Maaz
     * @since 2023-06-13
     */
    @HttpPost
    global static void postHandler(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try {
            CalloutObjects.BuildBodyPrefix bodyData = new CalloutObjects.BuildBodyPrefix(req, res);
            Integer sizeMinus1 = req.requestURI.split('/').size() - 1;
            String attributeParam = req.requestURI.split('/')[sizeMinus1];
            if(attributeParam == 'loguser' && sizeMinus1 == 3){
                //AMSRequestHelper.logUser(req, res, bodyData);
            }else{
                bodyData.setMessage('Error: sorry, this resource/path/method is not allowed as of now, please refer the schema file.');
                bodyData.setCode(404);
            }

            // Generating Response
            res.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.valueOf(JSON.serializePretty(bodyData.bodyObj));
            res.statusCode = bodyData.getCode();
        } catch (Exception e) {
            res.responseBody = Blob.valueOf(e.getMessage());
            res.statusCode = 500;
        }
    }
}