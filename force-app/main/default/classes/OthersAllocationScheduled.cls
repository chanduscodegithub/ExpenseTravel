global class OthersAllocationScheduled implements Schedulable{
	global void execute(SchedulableContext ctx){
      OthersAllocationBatch batch = new OthersAllocationBatch();
      Database.executebatch(batch, 200);
    }
}