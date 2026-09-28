/*********************************************************************************
Name         : QCC_FlightEventCloseHeadsUpBatch
Created By   : Raymart Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 04 October 2019
Usages       : This class is used to auto close the Heads Up Flight Event records
*********************************************************************************/
global class QCC_FlightEventCloseHeadsUpBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        Id headsUpRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Heads Up').getRecordTypeId();
        String queryString = 'SELECT Id, Status__c, ScheduledArrDateTime__c FROM Event__c WHERE RecordTypeId =:headsUpRecordTypeId AND Status__c != \'Closed\' AND ScheduledArrDateTime__c != \'\'';
        System.debug('queryString: ' + queryString);
        return Database.getQueryLocator(queryString);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('QCC_FlightEventCloseHeadsUpBatch.execute');
        try{
            List<Event__c> flightEventRecords = (List<Event__c>)scope;
            System.debug('flightEventRecords: ' + flightEventRecords);
            
            List<Event__c> recordsToUpdate = new List<Event__c>();
            for(Event__c flightEventRecord : flightEventRecords) {
                //Generate the arrival date and time from string values
                String scheduleArrivalDateTime = flightEventRecord.ScheduledArrDateTime__c;
                List<String> arrivalDateTimeSplitted = scheduleArrivalDateTime.split(' ');
                List<String> scheduleArrivalDate = arrivalDateTimeSplitted[0].split('/');
                DateTime finalArrDateTime = DateTime.valueOf(scheduleArrivalDate[2] + '-' + scheduleArrivalDate[1] + '-' + scheduleArrivalDate[0] + ' ' + arrivalDateTimeSplitted[1]);
                System.debug('finalArrDateTime: ' + finalArrDateTime);
                
                //Get the current date time
                DateTime currentDateTime = System.now();
                System.debug('currentDateTime: ' + currentDateTime);
                
                //Check if Scheduled Arrival Date + 5hours is already past date.
                if (currentDateTime >= finalArrDateTime.addHours(Integer.valueOf(Label.QCC_Flight_Event_Auto_Close_Hours))) {
                    flightEventRecord.Status__c = 'Closed';
                    recordsToUpdate.add(flightEventRecord);
                }
            }
            System.debug('recordsToUpdate: ' + recordsToUpdate);
            
            if (!recordsToUpdate.isEmpty()) {
                update recordsToUpdate;
            }
        } catch (Exception ex) {
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Flight Event Auto Close Heads Up Batch', 'QCC_FlightEventCloseHeadsUpBatch', 'execute', '', '', false, '', ex, '');
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        }
    } 
    
    global void finish(Database.BatchableContext BC){
    }
}