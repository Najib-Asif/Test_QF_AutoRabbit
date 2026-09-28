/*********************************************************************************
Name         : QCC_DisruptionWarning
Created By   : Nicole Abesamis
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 28 August 2019
Usages       : This will handle the query of related passenger from Contact
*********************************************************************************/

public without sharing class QCC_DisruptionWarningController {

    //This method will return if related passenger is in disruption or not.
    @AuraEnabled
    public static DisruptionWarningWrapper getRelatedPassengerRec(String contactId) {
        System.debug('contactId: ' + contactId);
        Boolean hasRedDisruptionIcon = false;
        Boolean hasYellowDisruptionIcon = false;
        Boolean hasGreenDisruptionIcon = false;
        DisruptionWarningWrapper myWrapper = new DisruptionWarningWrapper();
        myWrapper.hasError = false;
        List<DisruptionEventWrapper> disruptionEventWrapperList = new List<DisruptionEventWrapper>();
        List<Affected_Passenger__c> passengerRecords;

       if(contactId!=null)
            passengerRecords = new List<Affected_Passenger__c>([
            SELECT Id, Passenger__c, Event__r.IntDom__c, Event__r.DelayFailureCode__c,  Event__r.FlightNumber__c, Event__r.RecordTypeId,
            Event__r.ScheduledDepDate__c, Event__r.ScheduledDepTime__c,  Event__r.Scheduled_Depature_UTC__c,
            Event__r.Schedule_Departure_Date__c,  Event__r.ScheduledArrDateTime__c, QCC_Disruption_Actioned__c, Event__r.Status__c,Event__r.Primary_Root_Cause__c,Event__r.Root_Cause__c,Event__r.Disruption_Reason_Text__c
            FROM Affected_Passenger__c
            WHERE Passenger__c =: contactId
            AND Event__r.ScheduledDepDate__c != null
            AND Event__r.ScheduledDepTime__c != null
            AND Event__r.Scheduled_Depature_UTC__c != null
            AND Event__r.Schedule_Departure_Date__c != null
            AND Event__r.ScheduledArrDateTime__c != null
        ]);

       
        Id headsUpRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Heads Up').getRecordTypeId();
        Id activeRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Flight Event - Active').getRecordTypeId();
        Id closedRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Flight Event - Closed').getRecordTypeId();
        Id offloadRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Flight Event - Offload').getRecordTypeId();

        System.debug('headsUpRecordTypeId: ' + headsUpRecordTypeId);
        System.debug('activeRecordTypeId: ' + activeRecordTypeId);
        System.debug('closedRecordTypeId: ' + closedRecordTypeId);
        System.debug('offloadRecordTypeId: ' + offloadRecordTypeId);

        try {
            system.debug('>>>passengerRecords: ' + passengerRecords);
            if(passengerRecords!=null && passengerRecords.size()>0)
            for(Affected_Passenger__c passengerRecord: passengerRecords){
                //Get datetime now
                DateTime systemNow = System.now();

                //Generate the departure date and time from string values
                Date scheduledDepartureDate = passengerRecord.Event__r.ScheduledDepDate__c;
                String scheduledDepartureTime = passengerRecord.Event__r.ScheduledDepTime__c;
                //Convert the combination of the departure date and time (which is a text) into a DateTime field
                DateTime finalDepDateTime = DateTime.valueOf(scheduledDepartureDate.year() + '-' + scheduledDepartureDate.month() + '-' + scheduledDepartureDate.day() + ' ' + scheduledDepartureTime + ':00');
                System.debug('finalDepDateTime: ' + finalDepDateTime);

                //Generate the arrival date and time from string values
                String scheduleArrivalDateTime = passengerRecord.Event__r.ScheduledArrDateTime__c;
                List<String> arrivalDateTimeSplitted = scheduleArrivalDateTime.split(' ');
                List<String> scheduleArrivalDate = arrivalDateTimeSplitted[0].split('/');
                DateTime finalArrDateTime = DateTime.valueOf(scheduleArrivalDate[2] + '-' + scheduleArrivalDate[1] + '-' + scheduleArrivalDate[0] + ' ' + arrivalDateTimeSplitted[1]);
                System.debug('finalArrDateTime: ' + finalArrDateTime);

                System.debug('passengerRecord.Event__r.IntDom__c: ' + passengerRecord.Event__r.IntDom__c);
                System.debug('passengerRecord.Event__r.DelayFailureCode__c: ' + passengerRecord.Event__r.DelayFailureCode__c);
                System.debug('passengerRecord.Event__r.RecordTypeId: ' + passengerRecord.Event__r.RecordTypeId);

                Boolean isIncluded = false;
                if (passengerRecord.Event__r.RecordTypeId == headsUpRecordTypeId) {
                    //Logic for yellow/green icon depending on QCC_Disruption_Actioned__c field
                    Boolean hasPermission = FeatureManagement.checkPermission('QCC_View_Flight_Heads_Up_Amber_Status');
                    if (systemNow < finalArrDateTime.addHours(Integer.valueOf(Label.QCC_DisruptionWarningYellow)) && hasPermission) {
                        if (!passengerRecord.QCC_Disruption_Actioned__c && passengerRecord.Event__r.Status__c != 'Closed') {
                            hasYellowDisruptionIcon = true;
                            isIncluded = true;
                        } else if (passengerRecord.QCC_Disruption_Actioned__c || passengerRecord.Event__r.Status__c == 'Closed') {
                            hasGreenDisruptionIcon = true;
                            isIncluded = true;
                        }
                    }
                } else if (passengerRecord.Event__r.RecordTypeId == activeRecordTypeId ||
                           passengerRecord.Event__r.RecordTypeId == closedRecordTypeId ||
                           passengerRecord.Event__r.RecordTypeId == offloadRecordTypeId)
                {
                    //Logic for red/green icon depending on QCC_Disruption_Actioned__c field
                    if ((passengerRecord.Event__r.DelayFailureCode__c == 'Flight Delay' && systemNow < finalArrDateTime.addHours(Integer.valueOf(Label.QCC_DisruptionWarningRedFlightDelay))) ||
                        (passengerRecord.Event__r.IntDom__c == 'Domestic' && systemNow < finalDepDateTime.addHours(Integer.valueOf(Label.QCC_DisruptionWarningRedDomestic))) ||
                        (passengerRecord.Event__r.IntDom__c == 'International' && systemNow < finalDepDateTime.addHours(Integer.valueOf(Label.QCC_DisruptionWarningRedInternational))))
                    {
                        if (!passengerRecord.QCC_Disruption_Actioned__c) {
                            hasRedDisruptionIcon = true;
                        } else {
                            hasGreenDisruptionIcon = true;
                        }
                        isIncluded = true;
                    }
                }

                System.debug('isIncluded: ' + isIncluded);

                //Add to Disruption Event List
                if (isIncluded) {
                    disruptionEventWrapperList.add(
                        new DisruptionEventWrapper(
                            passengerRecord.Event__r.DelayFailureCode__c,
                            passengerRecord.Event__r.FlightNumber__c,
                            finalDepDateTime.format('dd/MM/y HH:mm'),
                            passengerRecord.Event__r.Primary_Root_Cause__c,
                            passengerRecord.Event__r.Root_Cause__c,
                            passengerRecord.Event__r.Disruption_Reason_Text__c
                        )
                    );
                }
            }
        } catch (Exception ex) {
            myWrapper.hasError = true;
            myWrapper.errorMessage = ex.getMessage();
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Disruption Warning', 'QCC_DisruptionWarningController', 'getRelatedPassengerRec', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }

        if (hasRedDisruptionIcon) {
            myWrapper.iconToDisplay = 'redIcon';
        } else if (hasYellowDisruptionIcon) {
            myWrapper.iconToDisplay = 'yellowIcon';
        } else if (hasGreenDisruptionIcon) {
            myWrapper.iconToDisplay = 'greenIcon';
        } else {
            myWrapper.iconToDisplay = '';
        }

        myWrapper.disruptionEvents = disruptionEventWrapperList;

        return myWrapper;
    }

    public class DisruptionWarningWrapper {
        @AuraEnabled public Boolean hasError {get;set;}
        @AuraEnabled public String errorMessage {get;set;}
        @AuraEnabled public String iconToDisplay {get;set;}
        @AuraEnabled public List<DisruptionEventWrapper> disruptionEvents {get;set;}
    }

    public class DisruptionEventWrapper {
        @AuraEnabled public String delayFailureCode {get;set;}
        @AuraEnabled public String flightNumber {get;set;}
        @AuraEnabled public String scheduleDepartureDateTime {get;set;}
        @AuraEnabled public String primaryRootcause {get;set;}
        @AuraEnabled public String rootCause {get;set;}
        @AuraEnabled public String employeeMessage {get;set;}
        public DisruptionEventWrapper(String failureCode, String flightNo, String departureDateTime, String primarryrtCause, String rtCause, String empmessage) {
            delayFailureCode = failureCode;
            flightNumber = flightNo;
            scheduleDepartureDateTime = departureDateTime;
            primaryRootcause = primarryrtCause;
            rootCause = rtCause;
            employeeMessage = empmessage;
        }
    }
}