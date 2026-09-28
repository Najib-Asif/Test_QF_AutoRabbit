/*********************************************************************************
Name         : QCC_PassengerConnectingFlightInvocable
Created By   : Francis Bagtas
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 16 September 2019
Usages       : This class is used initiate callout to pudate passenger record for their other flight details.
*********************************************************************************/
public class QCC_PassengerConnectingFlightInvocable {
    
    @InvocableMethod
    public static void retrieveCustomerFlight(List<Event__c> eventList){
        List<Id> eventIds = new List<Id>();
        for(Event__c event : eventList){
        	eventIds.add(event.Id);
        }   

        //Get All Passenger ID from Flight Event
        List<Id> passengerIds = new List<Id>();
        for(Affected_Passenger__c passenger : [SELECT Id FROM Affected_Passenger__c WHERE Event__c IN: eventIds]){
            passengerIds.add(passenger.Id);
        }
        Id batchJobId = Database.executeBatch(new QCC_PassengerConnectingFlightBatch(passengerIds), 1);
    }
}