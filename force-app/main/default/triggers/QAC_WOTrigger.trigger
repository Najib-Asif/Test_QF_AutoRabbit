/* Created By : Ajay Bharathan | TCS | Cloud Developer */
trigger QAC_WOTrigger on WorkOrder (after delete) 
{
	if(Trigger.isAfter && Trigger.isDelete)
    {
        // to ensure that delete trigger run only once
        if(CheckRecursive.runOnce())
            QAC_ChildTriggerHandler.doCaseUpdateonWODelete(Trigger.Old);
    }

}