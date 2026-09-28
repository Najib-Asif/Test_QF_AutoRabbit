/**
 * @description       : 
 * @author            : Gandla Mallikarjuna
 * @group             : 
 * @last modified on  : 03-01-2024
 * @last modified by  : Gandla Mallikarjuna
**/
trigger EmailMessageTriggerV2 on EmailMessage (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    Trigger_Status__c eMTStatus = Trigger_Status__c.getValues('EmailMessageTriggerV2');
        if (eMTStatus != null && eMTStatus.Active__c) {
            new EmailMessageTriggerHandler().run();
        }
}