public with sharing class Covid19GoogleAuthPageController {
    
    public string assessmentURL {get;set;}
    public String signInMessage1 {get;set;}
    public String signInMessage2 {get;set;}
    public String signInMessage3 {get;set;}
    public String signInMessage4 {get;set;}
    public String clientId {get;set;}
    public Boolean isChecked {get;set;}
    public Boolean isEmployeeComingToOfficeToday {get;set;}
    
    public Covid19GoogleAuthPageController(){
        isChecked = false;
        
        //Fetch the URL of the Employee's Assessment form.
        Covid_19_Metadata__c covidMetadata = Covid_19_Metadata__c.getInstance();
        assessmentURL = covidMetadata.URL_for_Non_SF_Users_Assessment_Page__c;
        System.debug('assessmentURL - '+assessmentURL);
        
        //Fetch the Client Id along with Covid-19 note to show it on the Sign-In screen.
        Google_OAuth__c googleOauth = Google_OAuth__c.getInstance();
        clientId = googleOauth.Client_Id__c;
        signInMessage1 = googleOauth.Note_1__c;
        signInMessage2 = googleOauth.Note_2__c;
        signInMessage3 = googleOauth.Note_3__c;
        signInMessage4 = googleOauth.Note_4__c;
        System.debug('clientId - '+clientId);
        System.debug('signInMessage - '+signInMessage1+' '+signInMessage2);
    }
}