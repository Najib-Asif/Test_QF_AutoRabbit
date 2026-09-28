/* Created By : Ajay Bharathan | TCS | Cloud Developer */
trigger QAC_SPTrigger on Service_Payment__c (after delete) 
{
	if(Trigger.isAfter && Trigger.isDelete)
    {
        // to ensure that delete trigger run only once
        if(CheckRecursive.runOnce())
            QAC_ChildTriggerHandler.doCaseUpdateonSPayDelete(Trigger.Old);
    }
}