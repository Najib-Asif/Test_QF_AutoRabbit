/**
 * @description       : 
 * @author            : Praveen Sampath
 * @group             : 
 * @last modified on  : 02-19-2024
 * @last modified by  : Praveen Sampath
**/
trigger CaseTriggerV2 on Case (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
        Trigger_Status__c cTStatus = Trigger_Status__c.getValues('CaseTriggerV2');
        if (cTStatus != null && cTStatus.Active__c) {
            new CaseTriggerHandler().run();
        }
    
}