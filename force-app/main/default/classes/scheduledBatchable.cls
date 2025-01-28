global with sharing class scheduledBatchable implements Schedulable {
 global void execute(SchedulableContext sc) {
    UpdateTABatchClass b = new UpdateTABatchClass(); 
   database.executebatch(b);
}
 }