trigger FlightFailureTrigger on FlightFailure__c (after insert, after update, before insert, before update, before delete) {
    if(Trigger_Status__c.getValues('FltFlrTrgCheckDuplicateFF').Active__c && Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        FlightFailureTriggerHelper.checkFlightFailureDuplication(Trigger.new, Trigger.oldMap);
    }

    if(Trigger_Status__c.getValues('FltFlrTrgAddFailureCodePassEvt').Active__c && Trigger.isAfter && Trigger.isUpdate){
        FlightFailureTriggerHelper.addFailureCodetoPassengerandEvent(Trigger.new, Trigger.oldMap);
    }

    if(Trigger_Status__c.getValues('FltFlrTrgUpdateEmailCom').Active__c && Trigger.isAfter && Trigger.isUpdate){
        FlightFailureTriggerHelper.updateEmailComs(Trigger.new, Trigger.oldMap);
    }
    
    if(Trigger_Status__c.getValues('FltFlrTrgFlightFailureDeleteCheck').Active__c && Trigger.isBefore && Trigger.isDelete){
        FlightFailureTriggerHelper.beforeFlightFailureDeleteCheck(Trigger.old);
    }
}