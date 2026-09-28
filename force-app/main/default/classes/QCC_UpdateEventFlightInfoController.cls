public class QCC_UpdateEventFlightInfoController {
	@AuraEnabled
    public static String submitUpdateforEvent(String eventId){
        List<id> listIds = new List<Id>();
        listIds.add(eventId);
        return QCC_EventFlightInfoUpdateHelper.updateforEvent(listIds);
    }

    @AuraEnabled
    public static String updatePassengerforEvent(String eventId){
        system.debug('eventId$$$$$'+eventId);
        Event__c objEvent = [Select Id, Name, ScheduledDepDate__c, DeparturePort__c, FlightNumber__c, AirplaneType__c, Plane_Number__c,
                             ScheduledArrDateTime__c,ActualDepaDateTime__c, ActualArriDateTime__c, Scheduled_Arrival_UTC__c, Estimated_Arrival_UTC__c,
                             Actual_Arrival_UTC__c, Scheduled_Depature_UTC__c, Estimated_Departure_UTC__c, Actual_Departure_UTC__c, DelayFailureCode__c,
                             Operating_Carrier__c,  EstimatedDepDateTime__c,TechPassenger_API_Invoked__c,
                             ArrivalPort__c, Operational_Carrier__c, Flight_Status__c, QCC_AutoCreated__c, recordtypeId, IsRecoveryApproved__c
                             FROM Event__c 
                             WHERE Id = :eventId];
        system.debug('objEvent$$$$'+objEvent);
        if(objEvent.Operational_Carrier__c != Null && objEvent.FlightNumber__c != Null &&  objEvent.ScheduledDepDate__c != Null && 
           objEvent.DeparturePort__c != Null && objEvent.ArrivalPort__c != Null && objEvent.TechPassenger_API_Invoked__c != true)
        {
            System.enqueueJob(new QCC_CreatePassengerForEvents(objEvent, null));
            objEvent.TechPassenger_API_Invoked__c = true;
            objEvent.IsRecoveryApproved__c=false;
            update objEvent;
            return CustomSettingsUtilities.getConfigDataMap('QCC_PassengerAPIInvokeMSG');
        }else if(objEvent.TechPassenger_API_Invoked__c){
             return CustomSettingsUtilities.getConfigDataMap('QCC_PassengerAPIinProgressMSG');
        }
        throw new AuraHandledException('Required Field to fetch Passenger is missing');
    }
}