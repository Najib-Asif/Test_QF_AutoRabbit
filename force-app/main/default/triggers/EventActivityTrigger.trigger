/*

Created Date   : 21/10/19 (DD/MM/YYYY)
Created By     : Vinothkumar Balasubramanian
JIRA           : CRM-3945
Description    : Adding Validation not to create/update Activity against Inactive Accounts

*/

trigger EventActivityTrigger on Event (before insert, before update){

        if(Trigger_Status__c.getValues('EventTrigger') != null && Trigger_Status__c.getValues('EventTrigger').Active__c){
            if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate))
            { 

                EventHandler.checkInactiveAgencyAccounts(trigger.new);
            }
        
        }
}