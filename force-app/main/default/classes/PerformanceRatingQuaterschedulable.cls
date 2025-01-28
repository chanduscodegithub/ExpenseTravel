global class PerformanceRatingQuaterschedulable {
    global void execute(SchedulableContext ctx) {
       PerformanceRatingQuaterLoadBatch sampleBatchObj=new PerformanceRatingQuaterLoadBatch();
        database.executebatch(sampleBatchObj);
    }
}