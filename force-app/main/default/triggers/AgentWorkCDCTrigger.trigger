trigger AgentWorkCDCTrigger on AgentWorkChangeEvent (after insert) {
    
    AgentWorkCDCHandler.handleAfterInsert(trigger.new);
}