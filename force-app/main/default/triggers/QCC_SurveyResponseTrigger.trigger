/*********************************************************************************
Name         : QCC_SurveyResponseTrigger
Created By   : Rafael Escuadra
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 26 November 2019
*********************************************************************************/
trigger QCC_SurveyResponseTrigger on Survey_Response__c (before insert, after insert) {
    //Get all the list in the Trigger Status custom setting
    Map<String, Trigger_Status__c> apexSwitch = Trigger_Status__c.getAll();
    TriggerHelper.Action triggerAction = null;
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            triggerAction = TriggerHelper.Action.AFTERINSERT;
        }
    }
    
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            triggerAction = TriggerHelper.Action.BEFOREINSERT;
        }
    }
    
    //Check if the Apex Switch Field is True. 
    //apexSwitch.get(<name of the object as entered on the custom setting>)
    if(apexSwitch.get('Survey_Response__c').Active__c && triggerAction != null) {
        TriggerHelper.Processor obj = new QCC_SurveyResponseTriggerHelper();
        obj.processTrigger(Trigger.new, Trigger.old, triggerAction);
    }
}