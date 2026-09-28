trigger FeedItemTrigger on FeedItem (before delete,  after insert) {
    if(Trigger_Status__c.getValues('FeedItemTrgPreventChatterDeletion').Active__c && Trigger.isDelete && Trigger.isBefore ){
        FeedItemTriggerHelper.preventChatterDeletion(trigger.old);
    }
    if(Trigger_Status__c.getValues('FeedItemTrgUpdateEscalationTickBox').Active__c && Trigger.isInsert && trigger.isAfter) {
        FeedItemTriggerHelper.updateEscalationTickBoxInCase(trigger.new);
        
    }
}