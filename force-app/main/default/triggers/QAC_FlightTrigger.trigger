/* Created By : Ajay Bharathan | TCS | Cloud Developer 

Modified Date   : 13/03/2020 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : CRM-4287
Version         : V2.0 - First Flight Number auto populate for QAC Online Cases

*/

trigger QAC_FlightTrigger on Flight__c (after delete, after insert) 
{
    if(Trigger.isAfter && Trigger.isDelete)
    {
        // to ensure that delete trigger run only once
        if(CheckRecursive.runOnce())
            QAC_ChildTriggerHandler.doCaseUpdateonFlightDelete(Trigger.Old);
    }
    
    // Changes Starts for CRM-4287
    if(Trigger_Status__c.getValues('QACFlightAfterInsert') != null && Trigger_Status__c.getValues('QACFlightAfterInsert').Active__c){
        
        if(Trigger.isAfter && Trigger.isInsert)
            
        {
            QAC_ChildTriggerHandler.doCaseUpdateonFlightInsert(Trigger.new);
        }
    }
    // Changes End for CRM-4287
}