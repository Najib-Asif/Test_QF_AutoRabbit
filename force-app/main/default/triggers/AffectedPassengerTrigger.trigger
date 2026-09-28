/*----------------------------------------------------------------------------------------------------------------------

************************************************************************************************
History
************************************************************************************************
18-Jan-2020      Vinothkumar		      CRM-4162 : Method - paymentInitiation (To Create QAC Payment records when the Paid Service is enabled and Passenger records are created)
-----------------------------------------------------------------------------------------------------------------------*/

trigger AffectedPassengerTrigger on Affected_Passenger__c (before insert, before update, after insert, after update, after delete) {
    
    //if(CheckRecursive.runOnce()){
    if(Trigger.isBefore){
        if(Trigger_Status__c.getValues('isAffectedPassenger').Active__c && (Trigger.isInsert || Trigger.isUpdate)) {
            AffectedPassengerTriggerHelper.isAffectedPassenger(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isUpdate){
            AffectedPassengerTriggerHelper.updateFullEmailBody(Trigger.New, Trigger.oldMap);
        }
        //parse airport code to airpost name
        if(Trigger_Status__c.getValues('PassengerUpdateAirportName').Active__c && (Trigger.isInsert)){
            AffectedPassengerTriggerHelper.updateAirportName(Trigger.New);
        }
        
        if(Trigger_Status__c.getValues('PassengerTriggerCreateOffloadCase').Active__c && (Trigger.isUpdate)){
            AffectedPassengerTriggerHelper.populateContactOnOffload(Trigger.New, Trigger.oldMap);
        }
    }
    
    if(Trigger.isAfter){
        if(Trigger_Status__c.getValues('PassengerTriggerCreateOffloadCase').Active__c && Trigger.isUpdate){
            AffectedPassengerTriggerHelper.createOffloadCase(Trigger.New, Trigger.oldMap);
        }
        if(Trigger_Status__c.getValues('RollupPassengerBasedonTier').Active__c && (Trigger.isInsert || Trigger.isUpdate || Trigger.isDelete)){
            AffectedPassengerTriggerHelper.rollupPassengerBasedonTier(Trigger.New, Trigger.oldMap);
        }
        if(Trigger.isDelete){
            QAC_ChildTriggerHandler.doCaseUpdateonPaxDelete(Trigger.Old);
        }
        if(Trigger_Status__c.getValues('QACPassengerPayments') != null && Trigger_Status__c.getValues('QACPassengerPayments').Active__c){
            if(Trigger.isAfter && Trigger.isInsert)
            {
                QAC_Passengerpayments.paymentInitiation(Trigger.New);
            }
        }
        //GRAPHITE-119: Auto create case for Flight Event Active
        if(CheckRecursive.runOnce()) {
            //GRAPHITE-2221 Remove the isUpdate because it is creating another case record due to asynchronous run.
            if(Trigger_Status__c.getValues('PassengerTriggerCreateCase').Active__c && (Trigger.isInsert)){
                AffectedPassengerTriggerHelper.checkVIPPassenger(Trigger.New, Trigger.oldMap);
            }
        }
    }

    // }

}