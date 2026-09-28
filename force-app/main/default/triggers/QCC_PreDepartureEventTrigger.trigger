trigger QCC_PreDepartureEventTrigger on QCC_Pre_Departure_Event__e (after insert) {
    //Get all the list in the Trigger Status custom setting
    Map<String, Trigger_Status__c> apexSwitch = Trigger_Status__c.getAll();
    TriggerHelper.Action triggerAction = null;
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            triggerAction = TriggerHelper.Action.AFTERINSERT;
        }
    }
    
    //Check if the Apex Switch Field is True. 
    //apexSwitch.get(<name of the object as entered on the custom setting>)
    if(apexSwitch.get('QCC_Pre_Departure_Event__e').Active__c && triggerAction != null) {
        TriggerHelper.Processor obj = new QCC_PreDepartureEventTriggerHelper();
        obj.processTrigger(Trigger.new, Trigger.old, triggerAction);
    }
}