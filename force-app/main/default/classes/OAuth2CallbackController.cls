public with sharing class OAuth2CallbackController {
    public String authCode { get; set; }

    public OAuth2CallbackController() {
        authCode = ApexPages.currentPage().getParameters().get('code');
    }
}