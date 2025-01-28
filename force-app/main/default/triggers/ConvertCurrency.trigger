trigger ConvertCurrency on Revenue_Stream_Region__c (before insert, before update) {
    DatedConversionRateRetriever.convertCurrency(Trigger.new);
}