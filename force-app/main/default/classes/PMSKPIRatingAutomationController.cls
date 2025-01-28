public class PMSKPIRatingAutomationController {
    @AuraEnabled
    public static void KPIAutomationMethod(){
        PMSKPIRatingAutomationBatch batch = new PMSKPIRatingAutomationBatch();
        Database.executeBatch(batch);
    }
    

}