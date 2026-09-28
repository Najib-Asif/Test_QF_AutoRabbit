/*********************************************************************************
Name         : QCC_OtherWaiverTrigger
Created By   : Rafael Escuadra
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 18 Feb 2020
*********************************************************************************/
trigger QCC_OtherWaiverTrigger on QCC_Other_Waiver__c (before delete) {
// QCCOtherWaiverDelete
	//Get all the list in the Trigger Status custom setting
    Map<String, Trigger_Status__c> apexSwitch = Trigger_Status__c.getAll();
    TriggerHelper.Action triggerAction = null;
    
    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            System.debug('>>>set triggerAction');
            triggerAction = TriggerHelper.Action.BEFOREDELETE;
        }
    }
    
    //Check if the Apex Switch Field is True. 
    //apexSwitch.get(<name of the object as entered on the custom setting>)
    if(apexSwitch.get('QCC_Other_Waiver__c').Active__c && triggerAction != null) {
        TriggerHelper.Processor obj = new QCC_OtherWaiverTriggerHelper();
        obj.processTrigger(Trigger.new, Trigger.old, triggerAction);
    }//
}