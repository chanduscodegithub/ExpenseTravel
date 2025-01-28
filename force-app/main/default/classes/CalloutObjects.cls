/*------------------------------------------------------------
Author       :  Maaz Rahman
Company      :  CRMIT Pvt. Ltd.
Description  :  Framework for REST Resource
Inputs       :  Mentioned before each methods. No constructor for the CalloutObjects class.
Test Class   :  _

History
<Date>         <Authors Name>        <Brief Description of Change>
------------------------------------------------------------------*/
/**
 * A class that defines various helper classes and methods for making callouts to external services/responing to callouts to the rest resource.
 * @author Maaz
 * @since 12 Jun 2023
 */
public with sharing class CalloutObjects {
    /**
     * A class that holds the details of a REST request, such as the URI, parameters and body.
     */
    public class ResourceDetails{
        public String requestURI;
        public Map<String, String> params { get; set; }
        public Map<String, Object> reqBody = new Map<String, Object>();
        /**
         * A constructor that initializes the fields of the ResourceDetails class from a given RestRequest object.
         * @param {RestRequest} req - The RestRequest object to extract the details from.
         */
        public ResourceDetails(RestRequest req){
            this.requestURI = req.requestURI;
            this.params = req.params;
            if(req.requestBody.size() > 0){
                Blob body = req.requestBody;
                String bodyString = body.toString();
                this.reqBody = (Map<String, Object>)JSON.deserializeUntyped(bodyString);
            }
        }
    }
    /**
     * A class that holds the status of a REST response, such as the message, code, resource details and payload.
     */
    public class BodyStatus {
        public String message;
        public Integer statusCode;
        public ResourceDetails resourceObj { get; set; }
        public sObject payload { get; set; }
        public String lastAction;
        public Decimal currentTime;
        /**
         * A constructor that initializes the resourceObj field of the BodyStatus class from a given ResourceDetails object.
         * @param {ResourceDetails} resourceObj - The ResourceDetails object to assign to the resourceObj field.
         */
        public BodyStatus(ResourceDetails resourceObj) {
            this.resourceObj = resourceObj;
        }
    }
    /**
     * A class that provides methods to build and modify a BodyStatus object for a REST response.
     */
    public class BuildBodyPrefix{
        public BodyStatus bodyObj { get; set; }
        public void setMessage(String value){
            this.bodyObj.message = value;
        }
        public void setCode(Integer value) {
            this.bodyObj.statusCode = value;
        }
        public Integer getCode() {
            return this.bodyObj.statusCode;
        }
        public void setPayload(sObject value) {
            this.bodyObj.payload = value;
        }
        public void setLastAction(String value) {
            this.bodyObj.lastAction = value;
        }
        public void setCurrentTime(Decimal value) {
            this.bodyObj.currentTime = value;
        }
        /**
         * A constructor that initializes the bodyObj field of the BuildBodyPrefix class from a given RestRequest and RestResponse objects.
         * @param {RestRequest} req - The RestRequest object to create a ResourceDetails object from.
         * @param {RestResponse} res - The RestResponse object to assign to the bodyObj field.
         */
        public BuildBodyPrefix(RestRequest req, RestResponse res){
            ResourceDetails resDetailsObj = new ResourceDetails(req);
            this.bodyObj = new BodyStatus(resDetailsObj);
        }
    }
}