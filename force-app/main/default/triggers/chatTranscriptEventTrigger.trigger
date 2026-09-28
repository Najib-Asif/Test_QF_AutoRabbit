trigger chatTranscriptEventTrigger on LiveChatTranscriptEvent (after insert) 
{
	if(Trigger.isAfter && Trigger.isInsert)
    {
        chatTranscriptEventTriggerHelper.autocloseFreightUnhandledCases(Trigger.new);
    }
}