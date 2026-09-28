//This trigger is to reassign the QAC NDC cases back to the queue when the user logs out as part of CRM-8910
trigger UserlogoutEventTrigger on LogoutEventStream (after insert) {
    
    if(Trigger.isAfter){
            userlogoutEventTriggerHelper.QACCaseReassignOwner(Trigger.new);
            
        }
}