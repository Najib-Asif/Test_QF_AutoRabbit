/*********************************************************************************
Name         : QCC_HeadsUpEventPassengerStatusTracker
Created By   : Leslie Padilla
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE-488
Created Date : 26 August 2019
Usages       : This class is used by lightning component to retrieve the Heads Up action done for each type of customer
*********************************************************************************/
public class QCC_HeadsUpEventActionReportController {

    @AuraEnabled
    public static List<PassengerHeadsUpActionObject> retrievePassengerHeadsUpActionsPerClass (Id headsUpEventId) {
        //Get the Flight Event record
        Event__c flightEventRecord;
        try {
            flightEventRecord = [SELECT Id, RecordTypeId FROM Event__c WHERE Id =: headsUpEventId];
        } catch(Exception ex) {
            flightEventRecord = null;
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Heads Up Event Retrieve Passengers', 'QCC_HeadsUpEventActionReportController', 'retrievePassengerHeadsUpActionsPerClass', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }

        List<PassengerHeadsUpActionObject> passengerHeadsUp_List = new List<PassengerHeadsUpActionObject>();

        Map<String,PassengerHeadsUpActionObject> passengerHeadsUpActionPerClass_Map = new Map<String,PassengerHeadsUpActionObject>();

        if (flightEventRecord != null) {
            try {
                //Set default count for every Heads Up action per Cabin Class
                List<String> passengerClasses = Label.QCC_Flight_Event_Heads_Up_Class.split(';');
                for(String className : passengerClasses) {
                    PassengerHeadsUpActionObject passengerHeadsUpActionRecord = new PassengerHeadsUpActionObject(className, null, null);
                    passengerHeadsUpActionPerClass_Map.put(className, passengerHeadsUpActionRecord);
                }

                //Get the count per Cabin Class and Heads Up action
                List<AggregateResult> affectedPassengers;
                Id globalHeadsUpRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Global Heads Up').getRecordTypeId();
                Id headsUpRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Heads Up').getRecordTypeId();
                if (flightEventRecord.RecordTypeId == globalHeadsUpRecordTypeId) {
                    affectedPassengers = [SELECT QCC_Heads_Up_Action__c, Cabin__c, COUNT(Id) FROM Affected_Passenger__c WHERE Event__r.GlobalEvent__c =: headsUpEventId AND Cabin__c != null GROUP BY QCC_Heads_Up_Action__c, Cabin__c];
                } else if (flightEventRecord.RecordTypeId == headsUpRecordTypeId) {
                    affectedPassengers = [SELECT QCC_Heads_Up_Action__c, Cabin__c, COUNT(Id) FROM Affected_Passenger__c WHERE Event__c =: headsUpEventId AND Cabin__c != null GROUP BY QCC_Heads_Up_Action__c, Cabin__c];
                } else {
                    affectedPassengers = new List<AggregateResult>();
                }

                //Generate the table that will be converted to table in cmp
                for(AggregateResult affectedPassenger : affectedPassengers) {
                    PassengerCountPerCabinWrapper passengerCountPerCabin = new PassengerCountPerCabinWrapper();
                    passengerCountPerCabin.cabinClass = String.valueOf(affectedPassenger.get('Cabin__c'));
                    passengerCountPerCabin.headsUpAction = String.valueOf(affectedPassenger.get('QCC_Heads_Up_Action__c'));
                    passengerCountPerCabin.passengerCount = Integer.valueOf(affectedPassenger.get('expr0'));

                    PassengerHeadsUpActionObject passengerHeadsUpActionRecord = new PassengerHeadsUpActionObject(null, passengerCountPerCabin, passengerHeadsUpActionPerClass_Map);
                    passengerHeadsUpActionPerClass_Map.put(passengerCountPerCabin.cabinClass, passengerHeadsUpActionRecord);
                }
            } catch(Exception ex) {
                Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Heads Up Event Retrieve Passengers', 'QCC_HeadsUpEventActionReportController', 'retrievePassengerHeadsUpActionsPerClass', '', '', false, '', ex, '');
                QCC_LogUtilityHelper.createLogRecord(logRecord);
            }
        }

        return passengerHeadsUpActionPerClass_Map.values();
    }

    public class PassengerCountPerCabinWrapper {
        public String cabinClass{get;set;}
        public String headsUpAction{get;set;}
        public Integer passengerCount{get;set;}
    }

    public class PassengerHeadsUpActionObject {
        @AuraEnabled public String cabinClass{get;set;}
        @AuraEnabled public Integer numOfPending {get;set;}
        @AuraEnabled public Integer numOfNoContactMade {get;set;}
        @AuraEnabled public Integer numOfStayingOnFlight {get;set;}
        @AuraEnabled public Integer numOfRebooked {get;set;}

        public PassengerHeadsUpActionObject (String cabinClassDefault, PassengerCountPerCabinWrapper passengerCountPerCabin, Map<String,PassengerHeadsUpActionObject> passengerHeadsUpActionPerClass_Map) {
            //Set the default value for each cabin class
            if (cabinClassDefault != NULL) {
                cabinClass = cabinClassDefault;
                numOfPending = 0;
                numOfNoContactMade = 0;
                numOfStayingOnFlight = 0;
                numOfRebooked = 0;
            } else if (passengerHeadsUpActionPerClass_Map.containsKey(passengerCountPerCabin.cabinClass)) {
                PassengerHeadsUpActionObject passengerHeadsUpActionRec = passengerHeadsUpActionPerClass_Map.get(passengerCountPerCabin.cabinClass);
                cabinClass = passengerHeadsUpActionRec.cabinClass;
                numOfPending = (passengerCountPerCabin.headsUpAction == 'Pending') ? passengerCountPerCabin.passengerCount : passengerHeadsUpActionRec.numOfPending;
                numOfNoContactMade = (passengerCountPerCabin.headsUpAction == 'No Contact Made') ? passengerCountPerCabin.passengerCount : passengerHeadsUpActionRec.numOfNoContactMade;
                numOfStayingOnFlight = (passengerCountPerCabin.headsUpAction == 'Staying On Flight') ? passengerCountPerCabin.passengerCount : passengerHeadsUpActionRec.numOfStayingOnFlight;
                numOfRebooked = (passengerCountPerCabin.headsUpAction == 'Re-booked') ? passengerCountPerCabin.passengerCount : passengerHeadsUpActionRec.numOfRebooked;
            }
        }
    }
}