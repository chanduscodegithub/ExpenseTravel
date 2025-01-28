@IsTest
public class DatedConversionRateRetrieverTest {
    @IsTest
    static void ConvertCurrency() {
        // Create test data
        DatedConversionRate mockConversionRate = new DatedConversionRate();
        mockConversionRate.IsoCode = 'EUR';
        mockConversionRate.ConversionRate = 1.2;

        // Set up the test data
        Map<String, DatedConversionRate> mockData = new Map<String, DatedConversionRate>{
            'EUR' => mockConversionRate
        };

        // Use the test utility class to retrieve the mock data
        // TestConversionRateUtility.setMockData(mockData);

        // Create opportunity and employee records
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.Amount = 1000;
        opp.CloseDate = Date.today();
        opp.CurrencyIsoCode = 'USD';
        opp.StageName='	Opportunity Identified';
        insert opp;

        Employee__c emp = new Employee__c();
        emp.Name = 'Test Employee';
        emp.CurrencyIsoCode = 'USD';
        insert emp;

        // Create revenue stream region records
        List<Revenue_Stream_Region__c> regions = new List<Revenue_Stream_Region__c>();

        Revenue_Stream_Region__c reg1=new Revenue_Stream_Region__c();
        reg1.CurrencyIsoCode = 'USD';
        // reg1.CurrencyIsoCode = 'EUR';
        reg1.Name = 'Region 1';
        reg1.Yearly_Actual_In_USD__c = 1000;
        regions.add(reg1);
        
        
        DatedConversionRateRetriever.convertCurrency(regions);

       /* Revenue_Stream_Region__c region2 = new Revenue_Stream_Region__c();
        region2.CurrencyIsoCode = 'AUD';
        region2.Name = 'Region 2';
        region2.Yearly_Actual_In_USD__c = 2000;
        regions.add(region2);

        Revenue_Stream_Region__c region3 = new Revenue_Stream_Region__c();
        region3.CurrencyIsoCode = 'EUR';
        region3.Name = 'Region 3';
        region3.Yearly_Actual_In_USD__c = 3000;
        regions.add(region3);*/

        // Set the conversion rate for each currency
        Map<String, DatedConversionRate> conversionRates = new Map<String, DatedConversionRate>();
        conversionRates.put('AUD', new DatedConversionRate(IsoCode='AUD', ConversionRate=0.7));
        conversionRates.put('EUR', new DatedConversionRate(IsoCode='EUR', ConversionRate=0.8));
        conversionRates.put('GBP', new DatedConversionRate(IsoCode='GBP', ConversionRate=0.9));
        conversionRates.put('INR', new DatedConversionRate(IsoCode='INR', ConversionRate=0.01));
        conversionRates.put('MYR', new DatedConversionRate(IsoCode='MYR', ConversionRate=0.2));

        // Set the conversion rates in the DatedConversionRateRetriever class
        DatedConversionRateRetriever.setConversionRates(conversionRates);
        Map<String, DatedConversionRate> rates = DatedConversionRateRetriever.getConversionRates();
        DatedConversionRate rate1 = DatedConversionRateRetriever.getConversionRate('EUR');
        DatedConversionRate rate2 = DatedConversionRateRetriever.getConversionRate('GBP');
        DatedConversionRate rate3 = DatedConversionRateRetriever.getConversionRate('USD');
        System.assertEquals(conversionRates, rates, 'Conversion rates were not set correctly');

        // Call the method under test
        
    
       
        // Verify the results
        //System.assertEquals(1000, reg1.Yearly_Actual_In_USD__c, 'USD currency should remain unchanged');
        //System.assertEquals(2857.14, region2.Yearly_Actual_In_USD__c, 'AUD currency should be converted to USD');
        //System.assertEquals(3750, region3.Yearly_Actual_In_USD__c, 'EUR currency should be converted to USD');
    }
}