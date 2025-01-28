trigger leadAfterInsert on Lead (before insert, after insert) {
    new LeadTriggerHelper().run();
}