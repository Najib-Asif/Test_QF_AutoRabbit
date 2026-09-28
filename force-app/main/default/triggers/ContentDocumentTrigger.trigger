trigger ContentDocumentTrigger on ContentDocument (before delete) {
	if(Trigger_Status__c.getValues('ContDocTriggerEligiblityCheckContDel').Active__c && Trigger.isBefore && Trigger.isDelete){
		ContentDocumentTriggerHelper.eligiblityCheckOnContentDocDel(trigger.oldMap);
	}
}