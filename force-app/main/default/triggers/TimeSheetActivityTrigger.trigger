trigger TimeSheetActivityTrigger on Delivery__c (before insert, before update, after insert, after update) {
	new TimeSheetActivityTriggerHelper().run();
}