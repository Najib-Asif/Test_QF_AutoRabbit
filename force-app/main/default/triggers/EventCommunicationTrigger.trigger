/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   Event Communication trigger
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
24-Oct-2018      Praveen Sampath               Initial Design

-----------------------------------------------------------------------------------------------------------------------*/
trigger EventCommunicationTrigger on EventCommunication__c (before insert, after insert, after update) {
	if(Trigger_Status__c.getValues('EvtCommsTrgLinkPassengerWithComms').Active__c && 
		trigger.isAfter && trigger.isInsert)
	{
		EventCommunicationTriggerHelper.linkPassengerWithComms(trigger.new);
    }
    
    if(Trigger_Status__c.getValues('EvtCommsTrgLinkPassengerWithComms').Active__c && 
		trigger.isAfter && trigger.isInsert)
	{
		EventCommunicationTriggerHelper.linkPassengerWithCommsForGlobal(trigger.new);
	}

	if(Trigger_Status__c.getValues('EvtCommsTrgLinkPassengerWithComms').Active__c && 
		trigger.isAfter && trigger.isUpdate)
	{
		EventCommunicationTriggerHelper.updateEmailContentOnPassenger(trigger.newMap, trigger.oldMap);
	}
}