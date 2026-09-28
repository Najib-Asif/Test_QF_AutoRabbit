/*********************************************************************************
Name         : QCC_AffectedPassengerUpdateCountInvocable
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 16 September 2019
Usages       : This class is used to update the count of VIPs, SSUs, etc. in the Event__c record
*********************************************************************************/
public class QCC_PassengerUpdateCountInvocable {
    //@Purpose: This method is used to update the count of VIPs, SSUs and other number fields of the related Event__c record
    //@input parameters:
    //	1. passengerRecords - The Affected_Passenger__c record that will come from the Process Builder.
    //@return type: None
    @InvocableMethod
    public static void processData(List<Affected_Passenger__c> passengerRecords) {
        try {
            Set<Id> eventIds = new Set<Id>();
            
            //Get all Event Ids
            for(Affected_Passenger__c passengerRecord : passengerRecords) {
                eventIds.add(passengerRecord.Event__c);
            }
            
            //GRAPHITE-2452 Include the tier without apostrophe in counting all the VIPs.
            List<String> vipTierList = QCC_UtilityHelper.getListFromString(Label.QCC_Passenger_Count_VIP_Tier_List, ';');

            //Count all VIP contact grouped by Event Id
            Map<String, Integer> vipPassengerMap = new Map<String, Integer>();
            List<AggregateResult> vipPassengers = [
                SELECT Event__c, COUNT(Id) 
                FROM Affected_Passenger__c 
                WHERE Event__c IN: eventIds
                AND (FrequentFlyerTier__c IN: vipTierList OR Passenger__r.SSU__c = true)
                GROUP BY Event__c
            ];
            for (AggregateResult vipPassenger : vipPassengers) {
                vipPassengerMap.put(String.valueOf(vipPassenger.get('Event__c')), Integer.valueOf(vipPassenger.get('expr0')));
            }
            
            //Count all SSU contact grouped by Event Id
            Map<String, Integer> ssuPassengerMap = new Map<String, Integer>();
            List<AggregateResult> ssuPassengers = [
                SELECT Event__c, COUNT(Id) 
                FROM Affected_Passenger__c 
                WHERE Event__c IN: eventIds
                AND Passenger__r.SSU__c = true
                GROUP BY Event__c
            ];
            for (AggregateResult ssuPassenger : ssuPassengers) {
                ssuPassengerMap.put(String.valueOf(ssuPassenger.get('Event__c')), Integer.valueOf(ssuPassenger.get('expr0')));
            }
            
            //Count all Passenger with connecting flight grouped by Event Id
            Map<String, AggregateResult> vipWithConnectingFlightMap = new Map<String, AggregateResult>();
            List<AggregateResult> vipWithConnectingFlightPassengers = [
                SELECT Event__c, COUNT(QCC_DOM_IN_CONX__c), COUNT(QCC_DOM_OUT_CONX__c), COUNT(QCC_INTL_IN_CONX__c), COUNT(QCC_INTL_OUT_CONX__c) 
                FROM Affected_Passenger__c WHERE Event__c IN: eventIds GROUP BY Event__c
            ];
            for (AggregateResult vipWithConnectingFlightPassenger : vipWithConnectingFlightPassengers) {
                vipWithConnectingFlightMap.put(String.valueOf(vipWithConnectingFlightPassenger.get('Event__c')), vipWithConnectingFlightPassenger);
            }
            
            //Get all the Event record related to the list of passengers
            Map<Id, Event__c> flightEventMap = new Map<Id, Event__c>([
                SELECT Id, QCC_Number_of_VIPs__c, QCC_Number_of_SSUs__c, 
                QCC_Number_of_VIP_with_DOM_IN_CONX__c, QCC_Number_of_VIP_with_DOM_OUT_CONX__c, 
                QCC_Number_of_VIP_with_INTL_IN_CONX__c, QCC_Number_of_VIP_with_INTL_OUT_CONX__c
                FROM Event__c WHERE Id IN: eventIds
            ]);
            
            //Set the value for the number fields
            List<Event__c> flightEventRecordsToUpdate = new List<Event__c>();
            for(Id eventId : eventIds) {
                if (flightEventMap.containsKey(eventId)) {
                    Event__c flightEventRecord = flightEventMap.get(eventId);
                    
                    //Set the value for QCC_Number_of_VIPs__c field
                    if (vipPassengerMap.containsKey(eventId)) {
                        flightEventRecord.QCC_Number_of_VIPs__c = vipPassengerMap.get(eventId);
                    }
                    
                    //Set the value for QCC_Number_of_SSUs__c field
                    if (ssuPassengerMap.containsKey(eventId)) {
                        flightEventRecord.QCC_Number_of_SSUs__c = ssuPassengerMap.get(eventId);
                    }
                    
                    //Set the value for QCC_Number_of_VIP_with_DOM_IN_CONX__c, QCC_Number_of_VIP_with_DOM_OUT_CONX__c, QCC_Number_of_VIP_with_INTL_IN_CONX__c and QCC_Number_of_VIP_with_INTL_OUT_CONX__c field
                    if (vipWithConnectingFlightMap.containsKey(eventId)) {
                        AggregateResult vipWithConnectingFlight = vipWithConnectingFlightMap.get(eventId);
                        flightEventRecord.QCC_Number_of_VIP_with_DOM_IN_CONX__c = Integer.valueOf(vipWithConnectingFlight.get('expr0'));
                        flightEventRecord.QCC_Number_of_VIP_with_DOM_OUT_CONX__c = Integer.valueOf(vipWithConnectingFlight.get('expr1'));
                        flightEventRecord.QCC_Number_of_VIP_with_INTL_IN_CONX__c = Integer.valueOf(vipWithConnectingFlight.get('expr2'));
                        flightEventRecord.QCC_Number_of_VIP_with_INTL_OUT_CONX__c = Integer.valueOf(vipWithConnectingFlight.get('expr3'));
                    }
                    
                    flightEventRecordsToUpdate.add(flightEventRecord);
                }
            }
            
            //Update the Event records with the final count
            if (!flightEventRecordsToUpdate.isEmpty()) {
                update flightEventRecordsToUpdate;
            }
        } catch(Exception ex) {
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Passenger Update Count', 'QCC_PassengerUpdateCountInvocable', 'processData', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
    }
}