/* Created By : Ajay Bharathan | TCS | Cloud Developer */
trigger QAC_CaseCommentTrigger on CaseComment (after delete) 
{
    if(Trigger.isAfter && Trigger.isDelete)
    {
        // to ensure that delete trigger run only once
        if(CheckRecursive.runOnce())
            QAC_ChildTriggerHandler.doCaseUpdateonCaseCommentDelete(Trigger.Old);
    }
}