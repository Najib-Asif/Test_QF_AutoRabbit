/*----------------------------------------------------------------------------------------------------------------------
Author:        Judy
Company:       Capgemini
Description:   QCC Case Processing
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
02-May-2018     Judy Tran          	      Initial Design
02-May-2018     Cyrille Jeufo             Method - getEventPassengers
-----------------------------------------------------------------------------------------------------------------------*/
trigger EventTrigger on Event__c (before insert,before update,after insert,after update) {

    // Moved this to top -- QDCUSCON-4481 
    //QDCUSCON-3250
    if(Trigger_Status__c.getValues('EventTriggerGetFlightInfo').Active__c && Trigger.isAfter && (Trigger.isUpdate|| Trigger.isInsert) ){
        EventTriggerHelper.updateEventFightInfo(Trigger.New, Trigger.oldMap);
    }
    //end QDCUSCON-3250

    if(Trigger_Status__c.getValues('EventTriggerGetPassengers').Active__c && Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)) {
        EventTriggerHelper.invokePaggengerAPI(Trigger.New, Trigger.oldMap);
    }

    if(Trigger_Status__c.getValues('EventTriggerValidateEvent').Active__c && Trigger.isBefore && Trigger.isUpdate){
        EventTriggerHelper.validateEventBeforeAssigningToCC(Trigger.New, Trigger.oldMap);
    }

    if(Trigger_Status__c.getValues('EventTriggerUpdateEventFields').Active__c && Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
		
    	EventTriggerHelper.updateEventFields(Trigger.New, Trigger.oldMap);
    }

    //QDCUSCON-3394
    if(Trigger_Status__c.getValues('EventTriggerArrivingAtDestination').Active__c && Trigger.isBefore && Trigger.isUpdate){
        EventTriggerHelper.updateEventArrivingAtDestination(Trigger.New, Trigger.oldMap);
    }
    //end QDCUSCON-3394

    if(Trigger_Status__c.getValues('EventTriggerCreateRecovery').Active__c && Trigger.isBefore && Trigger.isUpdate){
        EventTriggerHelper.createRecovery(Trigger.New, Trigger.oldMap);
    }

    if(Trigger_Status__c.getValues('EventTriggerUpdateAffectedPassenger').Active__c && Trigger.isAfter && Trigger.isUpdate) {
        //EventTriggerHelper.updateAffectedPassenger(Trigger.New, Trigger.oldMap);
    }
    
    if(Trigger_Status__c.getValues('EventTriggerCreateTaskforEvent').Active__c && Trigger.isAfter &&(Trigger.isInsert || Trigger.isUpdate)){
        EventTriggerHelper.createTaskforEvent(Trigger.New, Trigger.oldMap);
    }

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        //EventTriggerHelper.updateOverNightFlight(Trigger.oldMap, Trigger.new);
    }

    if(Trigger_Status__c.getValues('EventTriggerCreateEventComms').Active__c && Trigger.isAfter && Trigger.isUpdate){
        EventTriggerHelper.createEventComms(Trigger.New, Trigger.oldMap);
    }

    if(Trigger_Status__c.getValues('EventTriggerSendCommsOnEventClosure').Active__c && Trigger.isAfter && Trigger.isUpdate){
        EventTriggerHelper.sendCommsOnEventClosure(Trigger.New, Trigger.oldMap);
    }

    if(Trigger_Status__c.getValues('EventTriggerAutoCloseEvent').Active__c && Trigger.isBefore && Trigger.isUpdate){
        EventTriggerHelper.autoCloseEvent(Trigger.New, Trigger.oldMap);
    }

    if(Trigger_Status__c.getValues('EventTriggerAutoCloseEvent').Active__c && Trigger.isAfter && Trigger.isInsert){
        EventTriggerHelper.createChildRecord(Trigger.New, Trigger.oldMap); 
    }

    //process for closed Events
    if(Trigger_Status__c.getValues('EventTriggerPostEventClosedAction').Active__c && Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){
        EventTriggerHelper.postEventClosedAction(Trigger.newMap, Trigger.oldMap);
    }

    if(Trigger_Status__c.getValues('EventTriggerConvertRecordtype').Active__c && Trigger.isBefore && Trigger.isUpdate){
        EventTriggerHelper.convertRecordtype(Trigger.New);
    }

    //calculate cost if RecoveryIsCreated == true
    if(Trigger_Status__c.getValues('EventTriggerUpdateEventCost').Active__c && Trigger.isAfter && Trigger.isUpdate){
        EventTriggerHelper.updateEventCost(Trigger.New, trigger.oldMap);
    }

    if(Trigger_Status__c.getValues('EventTriggerManualAddStop').Active__c && Trigger.isAfter && Trigger.isUpdate){
        EventTriggerHelper.manualAddStop(Trigger.New, trigger.oldMap);
    }
}