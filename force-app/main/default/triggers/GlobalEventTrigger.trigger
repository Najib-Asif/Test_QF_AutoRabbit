/*--------------------------------------------------------------------------------------------------------------------------
Author:        Rekha Raparthi
Company:       Capgemini
Description:   Global Event trigger
Inputs:
Test Class:    GlobalEventTriggerTest 
************************************************************************************************
History
************************************************************************************************
11-Jul-2018     Rekha Raparthi         	      Added before insert or update to set audit fields
-----------------------------------------------------------------------------------------------------------------------------*/

trigger GlobalEventTrigger on Global_Event__c (before insert, before update) {
    if(Trigger.isBefore) {
        if(Trigger.isUpdate || Trigger.isInsert) {
            // update audit fields if trigger status is active
            if(Trigger_Status__c.getValues('GlobalEventTriggerUpdateAuditFields').Active__c){
                GlobalEventTriggerHelper.updateAuditFields(Trigger.New, Trigger.oldMap);
            }
        }
    }
}