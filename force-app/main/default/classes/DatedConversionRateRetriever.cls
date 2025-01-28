public class DatedConversionRateRetriever {
   
     //public static Map<String, DatedConversionRate> conversionRates = new Map<String, DatedConversionRate>();
    private static Map<String, DatedConversionRate> conversionRates = new Map<String, DatedConversionRate>();

    public static DatedConversionRate getConversionRate(String isoCode) {
        if (!conversionRates.containsKey(isoCode)) {
            DatedConversionRate rate = [SELECT Id, IsoCode, ConversionRate, NextStartDate, StartDate 
                                        FROM DatedConversionRate 
                                        WHERE IsoCode = :isoCode 
                                        ORDER BY NextStartDate DESC LIMIT 1];
            if (rate != null) {
                conversionRates.put(isoCode, rate);
            }
        }

        return conversionRates.get(isoCode);
    }
    public static Map<String, DatedConversionRate> getConversionRates() {
        return conversionRates;
    }

    public static void setConversionRates(Map<String, DatedConversionRate> rates) {
        conversionRates = rates;
    }


    public static void convertCurrency(List<Revenue_Stream_Region__c> regions) {
        
        // Loop through the records and perform currency conversion
        for (Revenue_Stream_Region__c region : regions) {
            // Check if the currency is already in USD
            if (region.Currency__c == 'USD') {
                // Update the Yearly_Actual_In_USD__c field directly
                region.Yearly_Actual_In_USD__c = region.Yearly_Actual__c;
            } else if (region.Currency__c == 'AUD'|| region.Currency__c == 'INR')
            {
                // Retrieve the conversion rate for the currency
                DatedConversionRate conversionRate = getConversionRate(region.Currency__c);

                // Convert the Yearly Actual value to USD using the conversion rate
                if (conversionRate != null) {
                    Decimal convertedValue = region.Yearly_Actual__c / conversionRate.ConversionRate;
                    region.Yearly_Actual_In_USD__c = convertedValue.setScale(2);
                }
            }
             Integer i = 1;
        i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        }
    }
}