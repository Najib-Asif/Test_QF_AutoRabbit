trigger FlightTrackerTrigger on Flight_Tracker__c (before insert, after insert, after update, before update) {
	if(Trigger_Status__c.getValues('FlightTrackerTriggerPopulateUTCFields').Active__c && Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)) {
		FlightTrackerTriggerHelper.populateUTCFields(Trigger.New, Trigger.oldMap);
	}
	
	if(Trigger_Status__c.getValues('validateFlightEventCreation').Active__c && Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
		FlightTrackerTriggerHelper.validateFlightEventCreation(Trigger.New, Trigger.oldMap);
	}
}