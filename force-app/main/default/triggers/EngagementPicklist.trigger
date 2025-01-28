trigger EngagementPicklist on Lead (before insert, before update, after insert) {
    System.debug('testttt');
    for(Lead ld : Trigger.new) {
        System.debug('1');
        System.debug('ld.Last_Engagement_in_Days__c--'+ld.Last_Engagement_in_Days__c);
        if(ld.Last_Engagement_in_Days__c <= 15) {
            ld.Last_Engagement__c = '<15 days';
        } else if(ld.Last_Engagement_in_Days__c >= 16 && ld.Last_Engagement_in_Days__c <= 30) {
            ld.Last_Engagement__c = '16-30 days';
        } else if(ld.Last_Engagement_in_Days__c >= 31) {
            ld.Last_Engagement__c = '>30 days';
        } else {
            ld.Last_Engagement__c = 'No Activities';
        }
    }
}