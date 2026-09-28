trigger AttachmentTrigger on Attachment (before delete) {
	if(Trigger_Status__c.getValues('AttTriggerEligiblityCheckAttachmentDel').Active__c && Trigger.isBefore && Trigger.isDelete){
		AttachmentTriggerHelper.eligiblityCheckOnAttachmentDel(Trigger.old);
	}
}