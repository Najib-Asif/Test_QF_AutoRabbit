trigger QCC_QantasHostTrigger on QCC_First_Host__c (after insert, after update, before insert, before update) {
    //Get all the list in the Trigger Status custom setting
    Map<String, Trigger_Status__c> apexSwitch = Trigger_Status__c.getAll();
    TriggerHelper.Action triggerAction = null;

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            triggerAction = TriggerHelper.Action.BEFOREINSERT;
        }

        if (Trigger.isUpdate) {
            triggerAction = TriggerHelper.Action.BEFOREUPDATE;
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            triggerAction = TriggerHelper.Action.AFTERINSERT;
        }

        if (Trigger.isUpdate) {
            triggerAction = TriggerHelper.Action.AFTERUPDATE;
        }
    }

    //Check if the Apex Switch Field is True.
    //apexSwitch.get(<name of the object as entered on the custom setting>)
    if(apexSwitch.get('QCC_First_Host__c').Active__c && triggerAction != null) {
        TriggerHelper.Processor obj = new QCC_QantasHostTriggerHelper();
        obj.processTrigger(Trigger.new, Trigger.old, triggerAction);
    }
}