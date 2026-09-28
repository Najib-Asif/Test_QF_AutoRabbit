trigger UserServicePresenceCDCTrigger on UserServicePresenceChangeEvent (after insert) {
    
    UserServicePresenceCDCHandler.handleAfterInsert(trigger.new);
}