public with sharing class ProcessAuthCodeController {
    public String authCode { get; set; }

    public ProcessAuthCodeController() {
        authCode = ApexPages.currentPage().getParameters().get('code');
    }
}