trigger chatTranscriptTrigger on LiveChatTranscript (after update) 
{
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        chatTranscriptTriggerHelper.onAfterUpdate(Trigger.new);
    }
    
}