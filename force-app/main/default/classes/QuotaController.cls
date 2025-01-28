public without sharing class QuotaController {
    
    @AuraEnabled(cacheable=true)
    public static void getForeCastDetails(String Year,String Region) {
        Integer currentYear = Integer.valueOf(Year);
        Integer nextYear = currentYear+1;
        Date startDate = Date.newInstance(currentYear, 4, 1);
        Date endDate = Date.newInstance(nextYear, 4, 30);
        
        Map<String,List<Opportunity>> mappedOpportunity = new Map<String,List<Opportunity>>();
        Map<String,Revenue_Stream_Employee__c> quotaTargetMap = new Map<String,Revenue_Stream_Employee__c>();
        List<wrapOpportunityForecast> wrapForeCastData = new List<wrapOpportunityForecast>(); 
        //wrapOpportunityForecast wrap = new wrapOpportunityForecast();
        
        List<Opportunity> opportunityList = [select id,Name,Amount,Account.Name,Owner.Name,StageName,CurrencyIsoCode,Opportunity_Category__c,OwnerId,Forecast_Visibility__c from Opportunity where Forecast_Visibility__c IN ('Won','Secured','Warm / Active','Best Case','Stretch / Risk') and (CloseDate >=:startDate and CloseDate <=:endDate)];
        
        set<String> ownerIds = new set<String>();
        Decimal secured = 0;
        Decimal mostLikely = 0;
        Decimal bestCase = 0;
        Decimal openPipeline = 0;
        
        for(Opportunity opp : opportunityList){
            ownerIds.add(opp.OwnerId);
            
            if(mappedOpportunity.containsKey(opp.OwnerId)){
                mappedOpportunity.get(opp.OwnerId).add(opp);
            }else{
                mappedOpportunity.put(opp.OwnerId,new List<Opportunity>{opp});
            }
        }
        //quotaTargetMap.put(quoataTarget.Employees__c,quoataTarget);
        for(Revenue_Stream_Employee__c quoataTarget : [Select Id,Name,Role__r.Name,Employees__c,Employee__c,Employee__r.Name,Total_Booking_Target__c,Currency__c From Revenue_Stream_Employee__c where Finance_Year__c =:Year and Quota_Type__c = 'Individual' and Employees__c IN:ownerIds]){
            wrapOpportunityForecast wrapData = new wrapOpportunityForecast();
            wrapData.employeeName = quoataTarget.Employee__r.Name;
            wrapData.Role = quoataTarget.Role__r.Name;
            wrapData.currencyName = quoataTarget.Currency__c;
            wrapData.quota = quoataTarget.Yearly_Target__c;
            wrapData.actual = quoataTarget.Yearly_Opportunity_Actuals__c;
            wrapData.attainment = quoataTarget.Yearly_Opportunity_Attainment__c;
            wrapData.secured = quoataTarget.Yearly_Opportunity_Attainment__c;
            wrapData.mostLikely = quoataTarget.Yearly_Opportunity_Attainment__c;
            wrapData.bestCase = quoataTarget.Yearly_Opportunity_Attainment__c;
            wrapData.openPipeline = quoataTarget.Yearly_Opportunity_Attainment__c;
            wrapForeCastData.add(wrapData);
        }
        
        
        
    }
    
    @AuraEnabled(cacheable=true) //List<Opportunity>
    public static List<wrapOpportunity> getOpportunity(String empId,String yearOrQuaterInApex,String selectedYearInApex,String selectedQuaterInApex,String empCurrency){
        try{
            Integer currentYear = Integer.valueOf(selectedYearInApex);
            Integer nextYear = currentYear+1;
            
            Map<String, Decimal> conversionRates = new Map<String, Decimal>();
            Set<String> opportunityCurrencies = new Set<String>();
            
            if(yearOrQuaterInApex == 'Year'){
                Date startDate = Date.newInstance(currentYear, 4, 1);
                Date endDate = Date.newInstance(nextYear, 4, 30);
                
                if(empId != null){
                    List<Opportunity> oppList = [select id,Name,Amount,Account.Name,Owner.Name,StageName,CurrencyIsoCode,Opportunity_Category__c from Opportunity where OwnerId =: empId and StageName =: 'Opportunity Won' and (CloseDate >=:startDate and CloseDate <=:endDate)];
                    
                    for (Opportunity opp : oppList) {
                        opportunityCurrencies.add(opp.CurrencyIsoCode);
                    }
                    
                    for (DatedConversionRate rate : [
                        SELECT ConversionRate, IsoCode
                        FROM DatedConversionRate
                        WHERE StartDate <= TODAY AND IsoCode IN :opportunityCurrencies
                        ORDER BY IsoCode, StartDate ASC 
                    ]) {
                        conversionRates.put(rate.IsoCode, rate.ConversionRate);
                    }
                    
                    List<wrapOpportunity> oppRecords = new List<wrapOpportunity>();
                    
                    for(Opportunity opp : oppList){
                        wrapOpportunity oppData = new wrapOpportunity();
                        oppData.OpportunityId = opp.id;
                        oppData.Name = opp.Name;
                        oppData.accountName = opp.Account.Name;
                        oppData.ownerName = opp.Owner.Name;
                        oppData.CurrencyIsoCode = empCurrency;
                        oppData.OpportunityCategory = opp.Opportunity_Category__c;
                        if(opp.CurrencyIsoCode != empCurrency){
                            oppData.Amount = convertionAmt(opp.CurrencyIsoCode,empCurrency,opp.Amount,conversionRates);
                        }else{
                            oppData.Amount = opp.Amount;
                        }
                        oppRecords.add(oppData);
                    }
                    return oppRecords;
                }
            }else if(yearOrQuaterInApex == 'Quater'){
                Date startDate = (selectedQuaterInApex == 'Q1' ? Date.newInstance(currentYear, 4, 1) : (selectedQuaterInApex == 'Q2' ? Date.newInstance(currentYear, 7, 1) : (selectedQuaterInApex == 'Q3' ? Date.newInstance(currentYear, 10, 1) : Date.newInstance(nextYear, 1, 1))));
                Date endDate = (selectedQuaterInApex == 'Q1' ? Date.newInstance(currentYear, 6, 31) : (selectedQuaterInApex == 'Q2' ? Date.newInstance(currentYear, 9, 31) : (selectedQuaterInApex == 'Q3' ? Date.newInstance(currentYear, 12, 31) : Date.newInstance(nextYear, 1, 31))));
                
                List<Opportunity> oppList = [select id,Name,Amount,Account.Name,Owner.Name,StageName,CurrencyIsoCode,Opportunity_Category__c from Opportunity where OwnerId =: empId and StageName =: 'Opportunity Won' and (CloseDate >=:startDate and CloseDate <=:endDate)];
                
                for (Opportunity opp : oppList) {
                    opportunityCurrencies.add(opp.CurrencyIsoCode);
                }
                
                for (DatedConversionRate rate : [
                    SELECT ConversionRate, IsoCode
                    FROM DatedConversionRate
                    WHERE StartDate <= TODAY AND IsoCode IN :opportunityCurrencies
                    ORDER BY IsoCode, StartDate ASC 
                ]) {
                    conversionRates.put(rate.IsoCode, rate.ConversionRate);
                }
                
                List<wrapOpportunity> oppRecords = new List<wrapOpportunity>();
                
                for(Opportunity opp : oppList){
                    wrapOpportunity oppData = new wrapOpportunity();
                    oppData.OpportunityId = opp.id;
                    oppData.Name = opp.Name;
                    oppData.accountName = opp.Account.Name;
                    oppData.ownerName = opp.Owner.Name;
                    oppData.CurrencyIsoCode = empCurrency;
                    oppData.OpportunityCategory = opp.Opportunity_Category__c;
                    if(opp.CurrencyIsoCode != empCurrency){
                        oppData.Amount = convertionAmt(opp.CurrencyIsoCode,empCurrency,opp.Amount,conversionRates);
                    }else{
                        oppData.Amount = opp.Amount;
                    }
                    oppRecords.add(oppData);
                }
                return oppRecords;
            }
            return null;
        }catch(Exception exp){
            throw new AuraHandledException(exp.getMessage());
        }
    }
    
    public static Decimal convertionAmt(String fromCurrency,String toCurrency, Decimal milestoneAmount, Map<String, Decimal> conversionRates){
        Decimal conversionRateToUSD = 1;
        
        if(fromCurrency == 'INR' && toCurrency == 'USD'){
            conversionRateToUSD = conversionRates.get(fromCurrency);
            Decimal amountInUSD = milestoneAmount / conversionRateToUSD;
            return amountInUSD;
        }else if(fromCurrency == 'INR' && toCurrency == 'AUD'){
            conversionRateToUSD = conversionRates.get(fromCurrency);
            Decimal amountInUSD = milestoneAmount / conversionRateToUSD;
            Decimal amountInAUD = amountInUSD * (conversionRates.get(toCurrency));
            return amountInAUD;
        }else{
            return milestoneAmount;
        }
    }
    
    
    @AuraEnabled(cacheable=true) //List<Opportunity>
    public static List<wrapOpportunity> getInvoice(String empId,String yearOrQuaterInApex,String selectedYearInApex,String selectedQuaterInApex,String empCurrency){
        try{
            Integer currentYear = Integer.valueOf(selectedYearInApex);
            Integer nextYear = currentYear+1;
            
            Map<String, Decimal> conversionRates = new Map<String, Decimal>();
            Set<String> billingCurrencies = new Set<String>();
            
            if(yearOrQuaterInApex == 'Year'){
                Date startDate = Date.newInstance(currentYear, 4, 1);
                Date endDate = Date.newInstance(nextYear, 4, 30);
                
                if(empId != null){
                    List<Billing__c> billingList = [select id,Name,CurrencyIsoCode,Account__r.Name,OpportunityName__c,OpportunityName__r.Opportunity_Category__c,OpportunityName__r.Name,OpportunityName__r.Owner.Name,Invoice_Amount__c from Billing__c where OpportunityName__r.OwnerId =: empId and Invoice_Date__c != null and (Invoice_Date__c  >=:startDate and Invoice_Date__c  <=:endDate)];
                    
                    for (Billing__c bill : billingList) {
                        billingCurrencies.add(bill.CurrencyIsoCode);
                    }
                    
                    for (DatedConversionRate rate : [
                        SELECT ConversionRate, IsoCode
                        FROM DatedConversionRate
                        WHERE StartDate <= TODAY AND IsoCode IN :billingCurrencies
                        ORDER BY IsoCode, StartDate ASC 
                    ]) {
                        conversionRates.put(rate.IsoCode, rate.ConversionRate);
                    }
                    
                    List<wrapOpportunity> billRecords = new List<wrapOpportunity>();
                    
                    for(Billing__c bill : billingList){
                        wrapOpportunity billData = new wrapOpportunity();
                        //billData.id = bill.id;
                        //billData.Name = bill.Name;
                        billData.accountName = bill.Account__r.Name;
                        billData.opportunityName = bill.OpportunityName__r.Name;
                        billData.ownerName = bill.OpportunityName__r.Owner.Name;
                        billData.CurrencyIsoCode = empCurrency;
                        billData.OpportunityId = bill.OpportunityName__c;
                        billData.OpportunityCategory = bill.OpportunityName__r.Opportunity_Category__c;
                        if(bill.CurrencyIsoCode != empCurrency){
                            billData.Amount = convertionAmt(bill.CurrencyIsoCode,empCurrency,bill.Invoice_Amount__c,conversionRates);
                        }else{
                            billData.Amount = bill.Invoice_Amount__c;
                        }
                        billRecords.add(billData);
                    }
                    return billRecords;                
                }else{
                    return null; 
                }
                
            }else if(yearOrQuaterInApex == 'Quater'){
                Date startDate = (selectedQuaterInApex == 'Q1' ? Date.newInstance(currentYear, 4, 1) : (selectedQuaterInApex == 'Q2' ? Date.newInstance(currentYear, 7, 1) : (selectedQuaterInApex == 'Q3' ? Date.newInstance(currentYear, 10, 1) : Date.newInstance(nextYear, 1, 1))));
                Date endDate = (selectedQuaterInApex == 'Q1' ? Date.newInstance(currentYear, 6, 31) : (selectedQuaterInApex == 'Q2' ? Date.newInstance(currentYear, 9, 31) : (selectedQuaterInApex == 'Q3' ? Date.newInstance(currentYear, 12, 31) : Date.newInstance(nextYear, 1, 31))));
                
                if(empId != null){
                    List<Billing__c> billingList = [select id,Name,CurrencyIsoCode,Account__r.Name,OpportunityName__c,OpportunityName__r.Opportunity_Category__c,OpportunityName__r.Name,OpportunityName__r.Owner.Name,Invoice_Amount__c from Billing__c where OpportunityName__r.OwnerId =: empId and Invoice_Date__c != null and (Invoice_Date__c  >=:startDate and Invoice_Date__c  <=:endDate)];
                    
                    for (Billing__c bill : billingList) {
                        billingCurrencies.add(bill.CurrencyIsoCode);
                    }
                    
                    for (DatedConversionRate rate : [
                        SELECT ConversionRate, IsoCode
                        FROM DatedConversionRate
                        WHERE StartDate <= TODAY AND IsoCode IN :billingCurrencies
                        ORDER BY IsoCode, StartDate ASC 
                    ]) {
                        conversionRates.put(rate.IsoCode, rate.ConversionRate);
                    }
                    
                    List<wrapOpportunity> billRecords = new List<wrapOpportunity>();
                    
                    for(Billing__c bill : billingList){
                        wrapOpportunity billData = new wrapOpportunity();
                        //billData.id = bill.id;
                        //billData.Name = bill.Name;
                        billData.accountName = bill.Account__r.Name;
                        billData.opportunityName = bill.OpportunityName__r.Name;
                        billData.ownerName = bill.OpportunityName__r.Owner.Name;
                        billData.CurrencyIsoCode = empCurrency;
                        billData.OpportunityId = bill.OpportunityName__c;
                        billData.OpportunityCategory = bill.OpportunityName__r.Opportunity_Category__c;
                        if(bill.CurrencyIsoCode != empCurrency){
                            billData.Amount = convertionAmt(bill.CurrencyIsoCode,empCurrency,bill.Invoice_Amount__c,conversionRates);
                        }else{
                            billData.Amount = bill.Invoice_Amount__c;
                        }
                        billRecords.add(billData);
                    }
                    return billRecords;
                    
                }else{
                    return null; 
                }
            }
            return null;
        }catch(Exception exp){
            throw new AuraHandledException(exp.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getSalesFinancialYears() {
        Integer currentYear = Date.today().year();
        Integer startYear = 2024;
        List<String> years = new List<String>();
        
        for (Integer year = startYear; year <= currentYear; year++) {
            years.add(String.valueOf(year));
        }
        
        return years;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Financial_Planning__c> getSalesFinancialPlanningRecords(String year, String region) {
        List<Financial_Planning__c> records = new List<Financial_Planning__c>();
        
        try {
            year = String.escapeSingleQuotes(year); // Prevent SOQL injection
            
            // Check if the Quota_Attainment_Report__c is enabled for the logged-in user
            if (isQuotaAttainmentReportEnabled()) {
                // If enabled, retrieve records based on the year without considering region
                records = [SELECT Id,Plan_Type__c,Name, Total_Region_Amount__c, FP_Year__c
                           FROM Financial_Planning__c
                           WHERE FP_Year__c = :year
                           ORDER BY Plan_Type__c 
                          ];
            } else {
                // If Quota_Attainment_Report__c is not enabled, fetch records based on the year and region
                records = [SELECT Id,Plan_Type__c,Name, Total_Region_Amount__c, FP_Year__c
                           FROM Financial_Planning__c
                           WHERE FP_Year__c = :year
                           ORDER BY Plan_Type__c
                          ];
            }
            
        } catch (QuotaException ex) {
            // Rethrow the custom exception
            throw ex;
        } catch (Exception ex) {
            // Handle the exception or log the error
            System.debug('An error occurred: ' + ex.getMessage());
        }
        
        return records;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Revenue_Stream_Region__c> getSalesRevenueStreamRegions(String financialPlanningName) {
        List<Financial_Planning__c> financialPlanningRecords = [SELECT Id FROM Financial_Planning__c WHERE Name LIKE :financialPlanningName + '%'];
        
        if (financialPlanningRecords.isEmpty()) {
            return new List<Revenue_Stream_Region__c>();
        }
        
        Id financialPlanningId = financialPlanningRecords[0].Id;
        
        return [
            SELECT Id, Opportunity_Region__c, Q1_attainmnet_colour__c, Q2_attainmnet_colour__c, Q3_attainmnet_colour__c, Q4_attainmnet_colour__c, 
            Q1_Revenue_Attainment__c, Quarter_1_Target__c, Q2_Revenue_Attainment__c, Quarter_2_Target__c, Q2_Attainment__c, 
            Q3_Revenue_Attainment__c, Quarter_3_Target__c, Q3_Attainment__c, Q4_Revenue_Attainment__c, Quarter_4_Target__c, Q4_Attainmnet__c,
            Yearly_Actual__c, Yearly_Attainment__c, Yearly_Target__c, Yearly_attainment_color__c, Gross_Margin_Attainment__c, 
            Annual_Gross_Margin__c, Actual_Gross_Margin__c, Currency__c	
            FROM Revenue_Stream_Region__c
            WHERE Revenue_Stream_Forecasting__c = :financialPlanningId
        ];
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Revenue_Stream_Employee__c> getSalesRevenueStreamEmployeesForLoggedInUser(String financialPlanningName) {
        // Step 1: Get the logged-in user's Id
        Id loggedInUserId = UserInfo.getUserId();
        System.debug('Logged In User Id: ' + loggedInUserId);
        
        List<Financial_Planning__c> financialPlanningRecords = [SELECT Id FROM Financial_Planning__c WHERE Name LIKE :financialPlanningName + '%'];
        if (financialPlanningRecords.isEmpty()) {
            return new List<Revenue_Stream_Employee__c>();
        }
        
        Id financialPlanningId = financialPlanningRecords[0].Id;
        
        // Check if the Quota_Attainment_Report__c is enabled for the logged-in user
        if (isQuotaAttainmentReportEnabled()) {
            // If enabled, fetch all records irrespective of the user
            return getAllRevenueStreamEmployees(financialPlanningId);
        }
        
        // If Quota_Attainment_Report__c is not enabled, fetch records based on the logged-in user
        return getEmployeeAndChildRecords(loggedInUserId, financialPlanningId);
    }    
    private static List<Revenue_Stream_Employee__c> getAllRevenueStreamEmployees(Id financialPlanningId) {
        // Fetch all records irrespective of the user
        return [
            SELECT Id,Type__c,Employees__r.Name,Quota_Type__c, Q1_Opportunity_Actuals__c, Q1_Opportunity_Attainments__c, Q1_Target__c, Q1_Opp_Attainment_Colour__c, Q2_Opportunity_Attainments__c, 
            Q3_Opp_Attainment_Colour__c, Q4_Opp_Attainment_Colour__c, Q2_Opportunity_Actuals__c, Q2_Target__c, Q2_Opp_Attainment_Colour__c,
            Q3_Opportunity_Actuals__c, Q3_Target__c, Q3_Opportunity_Attainments__c, Q4_Opportunity_Actuals__c, Q4_Target__c, Q4_Opportunity_Attainments__c,
            Yearly_Opportunity_Actuals__c, Yearly_Opportunity_Attainment__c, Yearly_Target__c, Yearly_Opp_Attainment_Colour__c, Actual_Gross_Margin__c,Q1_Exs_Renewal__c, Q2_Exs_Renewal__c, Q3_Exs_Renewal__c, Q4_Exs_Renewal__c,
            Annual_Gross_Margin__c, Gross_Margin_Attainment__c, CurrencyIsoCode, Role__r.Name,Currency__c,Region__c,Q1_Exs_New_Business__c,Q2_Exs_New_Business__c,Q3_Exs_New_Business__c,Q4_Exs_New_Business__c,Q1_New_Cust_New_Business__c,
            Q2_New_Cust_New_Business__c,Q3_New_Cust_New_Business__c,Q4_New_Cust_New_Business__c,Q1ECNB__c,Q1ECRB__c,Q1NCNB__c,Q2ECNB__c,Q2ECRB__c,Q2NCNB__c,Q3ECNB__c,Q3ECRB__c,Q3NCNB__c,Q4ECNB__c,Q4ECRB__c,Q4NCNB__c,ECNB_total__c,ECRB_total__c,NCNB_total__c,ECRB_percent__c,ECNB_percent__c,NCNB_percent__c,
            Q1_Revenue_Attainment__c,Q2_Revenue_Attainment__c,Q3_Revenue_Attainment__c,Q4_Revenue_Attainment__c,Target_Type__c,Billing_Yearly_Actual__c, Q1_Billing_Target__c, Q2_Billing_Target__c, Q3_Billing_Target__c, Q4_Billing_Target__c,Total_Billing_Target__c,Yearly_Billing_Attainment__c,
            Q1_Aspiration_Goals__c,Q2_Aspiration_Goals__c,Q3_Aspiration_Goals__c,Q4_Aspiration_Goals__c,Yearly_Aspiration_Goals__c,Q1_Percent__c,Q2_Percentage__c,Q3_Attainment__c,Q4_Attainmnet__c,Q4_Attainment_color_del__c,Q1_Attainment_del__c,Yearly_Attainment_color__c,Q2_Attainment__c,Q3_attainment_color__c,Yearly_Aspiration_Attainment__c,Yearly_Aspiration_Attainment_color__c,
            Q1_Aspiration_Attainment__c	,Q1_Aspiration_Attainment_Colour__c,Q2_Aspiration_Attainment__c,Q2_Aspiration_Attainment_Colour__c,Q3_Aspiration_Attainment__c,Q3_Aspiration_Attainment_Colour__c,Q4_Aspiration_Attainment__c,Q4_Aspiration_Attainment_Colour__c
            FROM Revenue_Stream_Employee__c
            WHERE Revenue_Stream_Forecasting__c = :financialPlanningId AND Quota_Type__c!='Team' AND Quota_Type__c!='Team'
            ORDER BY Revenue_Stream_Forecasting__c
        ];
    }
    private static List<Revenue_Stream_Employee__c> getEmployeeAndChildRecords(Id loggedInUserId, Id financialPlanningId) {
        // Step 1: Collect all relevant Salesforce user Ids
        Set<Id> userIds = new Set<Id>();
        userIds.add(loggedInUserId);
        
        // Step 2: Query all employees including children
        List<Employee__c> allEmployees = [SELECT Id, Salesforce_SF_User__c, ReportingTo__c FROM Employee__c WHERE Salesforce_SF_User__c = :loggedInUserId];
        
        // Add the Salesforce user Ids of child employees to the set
        for(Employee__c emp : allEmployees) {
            userIds.add(emp.Id);
        }
        
        // Step 3: Query all relevant Revenue_Stream_Employee__c records
        List<Revenue_Stream_Employee__c> resultRecords = [
            SELECT Id,Type__c,Employees__r.Name,Quota_Type__c, Q1_Opportunity_Actuals__c, Q1_Opportunity_Attainments__c, Q1_Target__c, Q1_Opp_Attainment_Colour__c, Q2_Opportunity_Attainments__c, 
            Q3_Opp_Attainment_Colour__c, Q4_Opp_Attainment_Colour__c, Q2_Opportunity_Actuals__c, Q2_Target__c, Q2_Opp_Attainment_Colour__c, 
            Q3_Opportunity_Actuals__c, Q3_Target__c, Q3_Opportunity_Attainments__c, Q4_Opportunity_Actuals__c, Q4_Target__c, Q4_Opportunity_Attainments__c,
            Yearly_Opportunity_Actuals__c, Yearly_Opportunity_Attainment__c, Yearly_Target__c, Yearly_Opp_Attainment_Colour__c, Actual_Gross_Margin__c,Q1_Exs_Renewal__c, Q2_Exs_Renewal__c, Q3_Exs_Renewal__c, Q4_Exs_Renewal__c,
            Annual_Gross_Margin__c, Gross_Margin_Attainment__c, CurrencyIsoCode, Role__r.Name,Currency__c,Region__c,Q1_Exs_New_Business__c,Q2_Exs_New_Business__c,Q3_Exs_New_Business__c,Q4_Exs_New_Business__c,Q1_New_Cust_New_Business__c,
            Q2_New_Cust_New_Business__c,Q3_New_Cust_New_Business__c,Q4_New_Cust_New_Business__c,Q1ECNB__c,Q1ECRB__c,Q1NCNB__c,Q2ECNB__c,Q2ECRB__c,Q2NCNB__c,Q3ECNB__c,Q3ECRB__c,Q3NCNB__c,Q4ECNB__c,Q4ECRB__c,Q4NCNB__c,ECNB_total__c,ECRB_total__c,NCNB_total__c,ECRB_percent__c,ECNB_percent__c,NCNB_percent__c,
            Q1_Revenue_Attainment__c,Q2_Revenue_Attainment__c,Q3_Revenue_Attainment__c,Q4_Revenue_Attainment__c,Target_Type__c,Billing_Yearly_Actual__c,Q1_Billing_Target__c, Q2_Billing_Target__c, Q3_Billing_Target__c, Q4_Billing_Target__c,Total_Billing_Target__c,Yearly_Billing_Attainment__c,
            Q1_Aspiration_Goals__c,Q2_Aspiration_Goals__c,Q3_Aspiration_Goals__c,Q4_Aspiration_Goals__c,Yearly_Aspiration_Goals__c,Q1_Percent__c,Q2_Percentage__c,Q3_Attainment__c,Q4_Attainmnet__c,Q4_Attainment_color_del__c,Q1_Attainment_del__c,Yearly_Attainment_color__c,Q2_Attainment__c,Q3_attainment_color__c,Yearly_Aspiration_Attainment__c,Yearly_Aspiration_Attainment_color__c,
            Q1_Aspiration_Attainment__c	,Q1_Aspiration_Attainment_Colour__c,Q2_Aspiration_Attainment__c,Q2_Aspiration_Attainment_Colour__c,Q3_Aspiration_Attainment__c,Q3_Aspiration_Attainment_Colour__c,Q4_Aspiration_Attainment__c,Q4_Aspiration_Attainment_Colour__c
            FROM Revenue_Stream_Employee__c
            WHERE Employees__c IN :userIds AND Revenue_Stream_Forecasting__c = :financialPlanningId AND Quota_Type__c != 'Team'
            ORDER BY Revenue_Stream_Forecasting__c
        ];
        
        // Step 4: Recursively query child records
        for(Employee__c emp : allEmployees) {
            List<Revenue_Stream_Employee__c> childRecords = getChildRecords(emp.Id, financialPlanningId);
            resultRecords.addAll(childRecords);
        }
        
        return resultRecords;
    }
    
    private static List<Revenue_Stream_Employee__c> getChildRecords(Id parentId, Id financialPlanningId) {
        // Step 1: Query child employees
        List<Employee__c> childEmployees = [SELECT Id, Salesforce_SF_User__c FROM Employee__c WHERE ReportingTo__c = :parentId];
        
        // Step 2: Collect Salesforce user Ids of child employees
        Set<Id> userIds = new Set<Id>();
        for(Employee__c childEmployee : childEmployees) {
            userIds.add(childEmployee.Salesforce_SF_User__c);
        }
        
        // Step 3: Query Revenue_Stream_Employee__c records for child employees
        List<Revenue_Stream_Employee__c> childRecords = [
            SELECT Id,Type__c,Employees__r.Name,Quota_Type__c, Q1_Opportunity_Actuals__c, Q1_Opportunity_Attainments__c, Q1_Target__c, Q1_Opp_Attainment_Colour__c, Q2_Opportunity_Attainments__c, 
            Q3_Opp_Attainment_Colour__c, Q4_Opp_Attainment_Colour__c, Q2_Opportunity_Actuals__c, Q2_Target__c, Q2_Opp_Attainment_Colour__c, 
            Q3_Opportunity_Actuals__c, Q3_Target__c, Q3_Opportunity_Attainments__c, Q4_Opportunity_Actuals__c, Q4_Target__c, Q4_Opportunity_Attainments__c,
            Yearly_Opportunity_Actuals__c, Yearly_Opportunity_Attainment__c, Yearly_Target__c, Yearly_Opp_Attainment_Colour__c, Actual_Gross_Margin__c,Q1_Exs_Renewal__c, Q2_Exs_Renewal__c, Q3_Exs_Renewal__c, Q4_Exs_Renewal__c,
            Annual_Gross_Margin__c, Gross_Margin_Attainment__c, CurrencyIsoCode, Role__r.Name,Currency__c,Region__c,Q1_Exs_New_Business__c,Q2_Exs_New_Business__c,Q3_Exs_New_Business__c,Q4_Exs_New_Business__c,Q1_New_Cust_New_Business__c,
            Q2_New_Cust_New_Business__c,Q3_New_Cust_New_Business__c,Q4_New_Cust_New_Business__c,Q1ECNB__c,Q1ECRB__c,Q1NCNB__c,Q2ECNB__c,Q2ECRB__c,Q2NCNB__c,Q3ECNB__c,Q3ECRB__c,Q3NCNB__c,Q4ECNB__c,Q4ECRB__c,Q4NCNB__c,ECNB_total__c,ECRB_total__c,NCNB_total__c,ECRB_percent__c,ECNB_percent__c,NCNB_percent__c,
            Q1_Revenue_Attainment__c,Q2_Revenue_Attainment__c,Q3_Revenue_Attainment__c,Q4_Revenue_Attainment__c,Target_Type__c,Billing_Yearly_Actual__c,Q1_Billing_Target__c, Q2_Billing_Target__c, Q3_Billing_Target__c, Q4_Billing_Target__c,Total_Billing_Target__c,Yearly_Billing_Attainment__c,
            Q1_Aspiration_Goals__c,Q2_Aspiration_Goals__c,Q3_Aspiration_Goals__c,Q4_Aspiration_Goals__c,Yearly_Aspiration_Goals__c,Q1_Percent__c,Q2_Percentage__c,Q3_Attainment__c,Q4_Attainmnet__c,Q4_Attainment_color_del__c,Q1_Attainment_del__c,Yearly_Attainment_color__c,Q2_Attainment__c,Q3_attainment_color__c,Yearly_Aspiration_Attainment__c,Yearly_Aspiration_Attainment_color__c,
            Q1_Aspiration_Attainment__c	,Q1_Aspiration_Attainment_Colour__c,Q2_Aspiration_Attainment__c,Q2_Aspiration_Attainment_Colour__c,Q3_Aspiration_Attainment__c,Q3_Aspiration_Attainment_Colour__c,Q4_Aspiration_Attainment__c,Q4_Aspiration_Attainment_Colour__c
            FROM Revenue_Stream_Employee__c
            WHERE Employees__c IN :userIds AND Revenue_Stream_Forecasting__c = :financialPlanningId AND Quota_Type__c != 'Team'
            ORDER BY Revenue_Stream_Forecasting__c
        ];
        
        // Step 4: Recursively query child records for each child employee
        for(Employee__c childEmployee : childEmployees) {
            List<Revenue_Stream_Employee__c> grandChildRecords = getChildRecords(childEmployee.Id, financialPlanningId);
            childRecords.addAll(grandChildRecords);
        }
        
        return childRecords;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getSalesRegions() {
        List<String> regionsList = new List<String>();
        try {
            // Retrieve the logged-in user's Id using UserInfo
            Id loggedInUserId = UserInfo.getUserId();
            // Add "Global" option to the regionsList
            //regionsList.add('Global');
            // Query the Employee__c object to get the Quota_Attainment_Report__c field value
            List<Employee__c> employees = [SELECT Id, Quota_Attainment_Report__c FROM Employee__c WHERE Salesforce_SF_User__c= :loggedInUserId LIMIT 1];
            // Check if the Quota_Attainment_Report__c field is true for the logged-in employee
            Boolean isQuotaAttainmentReportEnabled = !employees.isEmpty() && employees[0].Quota_Attainment_Report__c;
            if (isQuotaAttainmentReportEnabled) {
                // Query distinct regions from your data model
                List<Revenue_Stream_Employee__c> regionRecords = [SELECT Region__c FROM Revenue_Stream_Employee__c];
                // Extract unique region names from the query results and add them to the list
                for (Revenue_Stream_Employee__c record : regionRecords) {
                    if (record.Region__c != null && !regionsList.contains(record.Region__c)) {
                        regionsList.add(record.Region__c);
                    }
                }
            } else {
                // Query regions associated with the logged-in employee only
                List<Revenue_Stream_Employee__c> regionRecords = [SELECT Region__c FROM Revenue_Stream_Employee__c WHERE Employees__c = :loggedInUserId];
                // Extract unique region names from the query results and add them to the list
                for (Revenue_Stream_Employee__c record : regionRecords) {
                    if (record.Region__c != null && !regionsList.contains(record.Region__c)) {
                        regionsList.add(record.Region__c);
                    }
                }
            }
        } catch (Exception ex) {
            // Handle the exception or log the error
            System.debug('An error occurred: ' + ex.getMessage());
            return regionsList;
        }
        return regionsList;
    }
    private static Boolean isRegionValid(String selectedRegion) {
        // Retrieve the logged-in user's region using UserInfo
        Id loggedInUserId = UserInfo.getUserId();
        List<Employee__c> employees = [SELECT Id, Salesforce_SF_User__c, Region__c FROM Employee__c WHERE Salesforce_SF_User__c = :loggedInUserId];
        // Loop through the employees to find a match
        for (Employee__c employee : employees) {
            if (selectedRegion == employee.Region__c) {
                return true; // Selected region matches an employee's region
            }
        }
        return false; // No match found
    }
    // New method to check the Quota_Attainment_Report__c field in Employee object
    private static Boolean isQuotaAttainmentReportEnabled() {
        // Retrieve the logged-in user's Id using UserInfo
        Id loggedInUserId = UserInfo.getUserId();
        // Query the Employee__c object to get the Quota_Attainment_Report__c field value
        List<Employee__c> employees = [SELECT Id, Quota_Attainment_Report__c FROM Employee__c WHERE Salesforce_SF_User__c = :loggedInUserId LIMIT 1];
        
        // Check if the Quota_Attainment_Report__c field is true
        return !employees.isEmpty() && employees[0].Quota_Attainment_Report__c;
    }
    
    public class QuotaException extends Exception {}
    @AuraEnabled(cacheable=true)
    public static Boolean isEligibleForQuota() {
        // Retrieve the logged-in user's Id using UserInfo
        Id loggedInUserId = UserInfo.getUserId();
        // Query the Employee__c object to get the Eligible_for_Quota__c field value
        List<Employee__c> employees = [SELECT Id, Eligible_for_Quota__c FROM Employee__c WHERE Salesforce_SF_User__c = :loggedInUserId LIMIT 1];
        //System.debug('employees'+employees);
        // System.debug('employees[0].Eligible_for_Quota__c'+employees[0].Eligible_for_Quota__c);
        //System.debug('employees.isEmpty()'+employees.isEmpty());
        // Check if the Eligible_for_Quota__c field is true
        return !employees.isEmpty() && employees[0].Eligible_for_Quota__c;
    }
    @AuraEnabled(cacheable=true)
    public static Boolean isRevenueReview() {
        // Retrieve the logged-in user's Id using UserInfo
        Id loggedInUserId = UserInfo.getUserId();
        // Query the Employee__c object to get the Eligible_for_Quota__c field value
        List<Employee__c> employees = [SELECT Id, Revenue_review__c FROM Employee__c WHERE Salesforce_SF_User__c = :loggedInUserId LIMIT 1];
        System.debug('employees'+employees);
        System.debug('employees[0].Revenue_review__c'+employees[0].Revenue_review__c);
        System.debug('employees.isEmpty()'+employees.isEmpty());
        // Check if the Eligible_for_Quota__c field is true
        return !employees.isEmpty() && employees[0].Revenue_review__c;
    }
    
    public class wrapOpportunity{
        @AuraEnabled
        public String OpportunityId;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String ownerName;
        @AuraEnabled
        public String CurrencyIsoCode;
        @AuraEnabled
        public Decimal Amount;
        @AuraEnabled
        public String accountName;
        @AuraEnabled
        public String opportunityName;
        @AuraEnabled
        public String OpportunityCategory;
    }
    
    public class wrapOpportunityForecast{
        @AuraEnabled
        public String employeeName;
        @AuraEnabled
        public String Role;
        @AuraEnabled
        public String currencyName;
        @AuraEnabled
        public Decimal quota;
        @AuraEnabled
        public Decimal actual;
        @AuraEnabled
        public Decimal attainment;
        @AuraEnabled
        public Decimal secured;
        @AuraEnabled
        public Decimal mostLikely;
        @AuraEnabled
        public Decimal bestCase;
        @AuraEnabled
        public Decimal openPipeline;
    }
}