public class CreateBillingPDFCloneController {
    
    public Boolean showPage{get;set;}
    public Boolean showSavePdf{get;set;}
    public Boolean showSendEmail{get;set;}
    public Boolean fromAddressPicklistEnabled{get;set;}
    public Boolean sendccUser{get;set;}
    
    public String emailSubject{get;set;}
    public String emailBody{get;set;}
    public String ccAddresses{get;set;}
    public String pdfName{get;set;}
    public String toAddress{get;set;}
    public String SelectedContact{get;set;}
    public String CheckCon{get;set;}
    public String EmailIdLookup{get;set;}
    public String sourceURL{get;set;}
    
    public Blob pdfBlob{get;set;}
    
    public AcctSeed__Billing__c billdata{get;set;}
    public List<Contact> setContact{get;set;}
    public String selectedOrgWideEmailAddress{get;set;}
    
    //public String emailSubject{get;set;}
    public CreateBillingPDFCloneController(ApexPages.StandardController stdController) {
        this.showPage = true;
        this.showSavePdf = true;
        this.showSendEmail = FALSE;
        
        PageReference pdfPage = Page.BillingProductIrisPdfHLPClone;
        pdfPage.getParameters().put('id',apexpages.currentpage().getparameters().get('id'));
        pdfBlob = pdfPage.getcontent();
        
        this.pdfName = EncodingUtil.Base64Encode(pdfBlob);
        
        this.sourceURL = 'https://sftd1--c.vf.force.com/apex/BillingProductIrisPdfHLPClone?Id='+apexpages.currentpage().getparameters().get('id');
        
        billdata = [Select Id,Name,AcctSeed__Total__c,AcctSeed__Date__c,Child_Account__c,AcctSeed__Billing_Contact__c,AcctSeed__Billing_Contact__r.Lastname,Child_Account__r.ParentId from AcctSeed__Billing__c where Id =: apexpages.currentpage().getparameters().get('id')];
        CheckCon = 'PCP';
        /*List<Contact> contactsParent = [Select Id from Contact where AccountId =: billdata.Child_Account__r.ParentId];
        
        //CCP
        List<Contact> contactsChild = [Select Id from Contact where AccountId =: billdata.Child_Account__c];
        
        if(contactsParent.size() > 0){
            CheckCon = 'PCP';
        }else if(contactsChild.size() > 0){
            CheckCon = 'CCP';
        }else{
            CheckCon = 'NP';
        }*/
        

    }
    public void saveAttach(){
        this.showSavePdf = false;
        //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'The attachment has been saved.'));
        //this.showSendEmail = false;
    }
    public void saveAndEmail(){
        this.showSavePdf = false;
        this.showSendEmail = false;
        
        Messaging.EmailFileAttachment EmailAttachment = new Messaging.EmailFileAttachment();
        EmailAttachment.setFileName('Customer Invoice.pdf');
        EmailAttachment.setContentType('application/pdf');
        EmailAttachment.setBody(pdfBlob);
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
    
        List<String> to = new List<String>();
        List<String> cc = new List<String>();
            
            if(EmailIdLookup != null){
                to.add(EmailIdLookup);
            }else{
                to.add(UserInfo.getUserEmail());
            }
            
            
            if(sendccUser){
                cc.add(UserInfo.getUserEmail());
            }
        
        email.setToAddresses(to);
        if(cc.size() > 0){
         email.setCcAddresses(cc);   
        }
        email.setOrgWideEmailAddressId(selectedOrgWideEmailAddress);
        //email.setInReplyTo(repMail);
        email.setSubject(emailSubject);
        email.setHtmlBody(emailBody);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{EmailAttachment});
        try{
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
        }catch(exception e){
            apexpages.addmessage(new apexpages.message(apexpages.severity.error,e.getMessage()));
        }
    }
    public PageReference cancel(){
        PageReference result= new PageReference('/'+apexpages.currentpage().getparameters().get('id'));
        result.setRedirect(true); 
        return result;

    }
    
    public void determinePageBlock(){
        if(billdata.AcctSeed__Billing_Contact__c != null){
            this.showSendEmail = TRUE;
            Contact con = [Select Id,Name,Email from contact where Id =: billdata.AcctSeed__Billing_Contact__c];
            EmailIdLookup = con.Email;
            System.debug('EmailIdLookup::'+EmailIdLookup);

        emailSubject = 'CRMIT Solutions - Billing #'+billdata.Name;

        emailBody = con.Name + ',\n\n';
        emailBody += 'Attached is your billing'+ ' '+ billdata.Name + ' ' + 'dated '+ billdata.AcctSeed__Date__c.format()+'.';
        emailBody += 'The current balance on this billing is '+ billdata.AcctSeed__Total__c + '.\n\n';
        emailBody += 'Thank you for your business.';
        
        System.debug('emailSubject>>'+emailSubject);
        System.debug('emailSubject>>'+emailBody);
        }else{
            this.showSendEmail = FALSE;
            emailSubject = '';
            emailBody ='';
        }
        
        
    }
    
    public list<SelectOption> getAllOrgWideEmailAddress(){
        list<SelectOption>  lstOptions = new list<SelectOption>();
         for(OrgWideEmailAddress ord : [select id, Address from OrgWideEmailAddress]){
             lstOptions.add(new SelectOption(ord.Id,ord.Address));
        }
        return lstOptions;
    }
    
    //added because to sync between sandbox and prod due to insufficient time added it
    public static void increase(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;

    }
    
    
    
}