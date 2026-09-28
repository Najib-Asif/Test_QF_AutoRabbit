/* Created By : Ajay Bharathan | TCS | Cloud Developer */
trigger QAC_PassengerTrigger on Affected_Passenger__c(after delete) 
{
    if(Trigger.isAfter && Trigger.isDelete)
    {
        // to ensure that delete trigger run only once
        if(CheckRecursive.runOnce())
            QAC_ChildTriggerHandler.doCaseUpdateonPaxDelete(Trigger.Old);
    }
}