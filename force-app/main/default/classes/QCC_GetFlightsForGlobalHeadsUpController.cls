/*********************************************************************************
Name         : QCC_GetFlightsForGlobalHeadsUpController
Created By   : Leslie Padilla
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 21 September 2019
Usages       : This class is used to retrieve flights affected by the Global Event based on the Departure and Arrival Ports and Dates
*********************************************************************************/
public class QCC_GetFlightsForGlobalHeadsUpController {
	@AuraEnabled
    public static GetFlightsWrapper getAllFlights(String headsUpEventId) {
        GetFlightsWrapper myWrapper = new GetFlightsWrapper();
        
        try {
            List<Event__c> globalHeadsUpEvents = new List<Event__c>([SELECT Id, Name, QCC_TECH_Flight_Counter__c, RecordTypeId, TECH_FlightAPIInvoked__c, Affected_Ports__c, Start_Date__c, QCC_Local_Start_Time__c, End_Date__c, QCC_Local_End_Time__c FROM Event__c WHERE Id =: headsUpEventId]);
            List<Event__c> flightEventsToCreate = new List<Event__c>();
            
            Integer freightLowRange = String.IsNotBlank(CustomSettingsUtilities.getConfigDataMap('QCC_FreightLowRange'))?Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('QCC_FreightLowRange')):3000;
            Integer freightHighRange = String.IsNotBlank(CustomSettingsUtilities.getConfigDataMap('QCC_FreightHighRange'))?Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('QCC_FreightHighRange')):10000;
            Integer flightSet = 0; //the number of flights set returned by the API response
                        
            //Start: Loop through the Global Event record
            for(Event__c globalHeadsUpRecord : globalHeadsUpEvents){
                system.debug('>>>Event Record: ' + globalHeadsUpRecord.TECH_FlightAPIInvoked__c + '-' + globalHeadsUpRecord.Affected_Ports__c + '-' + globalHeadsUpRecord.Start_Date__c + '-' + globalHeadsUpRecord.End_Date__c); 
                Integer flightSet_CounterStartAt = (globalHeadsUpRecord.QCC_TECH_Flight_Counter__c == NULL) ? 0 : Integer.valueOf(globalHeadsUpRecord.QCC_TECH_Flight_Counter__c);
                Integer flightSet_Counter = 0;
                //Check the record type and the required fields needed to invoke the invokeFlightStatusDepsAPI callout
                if(globalHeadsUpRecord.RecordTypeId == GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('QCC Flight Event Global Heads Up'))){
                    if( !globalHeadsUpRecord.TECH_FlightAPIInvoked__c && String.isNotBlank(globalHeadsUpRecord.Affected_Ports__c) && globalHeadsUpRecord.Start_Date__c != Null && globalHeadsUpRecord.End_Date__c != Null){
                        String startTime = String.valueOf(globalHeadsUpRecord.QCC_Local_Start_Time__c).left(5);
                        String endTime = String.valueOf(globalHeadsUpRecord.QCC_Local_End_Time__c).left(5);
                        
                        //String departureFrom = String.valueOf(globalHeadsUpRecord.Start_Date__c).replace('-','') + '0000';
                        //String departureTo = String.valueOf(globalHeadsUpRecord.End_Date__c).replace('-','') + '0000';
                        
                        String departureFrom = String.valueOf(globalHeadsUpRecord.Start_Date__c).replace('-','') + startTime.replace(':','');
                        String departureTo = String.valueOf(globalHeadsUpRecord.End_Date__c).replace('-','') + endTime.replace(':','');
                        
                        system.debug('>>>invokeFlightStatusDepsAPI inputs: ' + globalHeadsUpRecord.Affected_Ports__c + '-' + departureFrom + '-' + departureTo);
                        QCC_FlightStatusDepsAPIResponse response = QCC_InvokeCAPAPI.invokeFlightStatusDepsAPI(globalHeadsUpRecord.Affected_Ports__c, departureFrom, departureTo);
                        flightSet = response.flights.size(); //TO-DO: If custom setting is not set then get the size
                        //flightSet = 80;
                        system.debug('>>>response: ' + response);
                        system.debug('>>>flightSet: ' + flightSet + '>>>response.flights.size(): ' + response.flights.size());
                        
                        //Create the Heads Up flight event record
                        String recordTypeId = GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('QCC Flight Event Heads Up'));
                        List<String> airlineCodes = Label.QCC_Global_Heads_Up_Event_Airline_Code.split(';');
                        
                        //This number setting is used to set the number of flights to consider and serves as a control in case the number of response size limit is reached
                        Integer maxNumberOfFlights = Integer.valueOf(Label.QCC_Heads_Up_Max_Flights);
                        
                        //Start: Loop through the list of flights from the API response
                        for (QCC_FlightStatusDepsAPIResponse.Flights flights : response.flights) {
                        //for (flightSet_Counter = flightSet_CounterStartAt; flightSet_Counter < flightSet; flightSet_Counter++) {
                            system.debug('>>>flightSet_Counter: ' + flightSet_Counter);
                            //QCC_FlightStatusDepsAPIResponse.Flights flights = response.flights.get(flightSet_Counter);
                            system.debug('>>>flights: ' + flights);
                            //Start: Loop through the flight numbers. Will only consider the carrier specified on the custom label QCC_Global_Heads_Up_Event_Airline_Code
                            for (QCC_FlightStatusDepsAPIResponse.FlightNumbers flightNum : flights.flightNumbers) {
                                //Instantiate the flight event record
                                Event__c flightEvent = new Event__c();
                                flightEvent.RecordTypeId = recordTypeId;
                                
                                String operationalCarrier = flightNum.airline;
                                String flightNumber = flightNum.airline + String.valueOf(flightNum.code).leftPad(4,'0');
                                if (airlineCodes.contains(flightNum.airline)) {
                                    String IntDom = '';
                                    if (flightNum.code <= 399 || flightNum.code == 3000) { //TO-DO: Need to save this in a configurable way
                                        IntDom = 'International'; //will not include the Freight Flights between 30001 to 9999
                                    } else if (flightNum.code >= 400 && flightNum.code <= 2999) { //TO-DO: Need to save this in a configurable way
                                        IntDom = 'Domestic';
                                    }
                                    
                                    //If the flight has not been classified as either International or Domestic then don't proceed with creation of flight event
                                    if (IntDom != '') {
                                        flightEvent.IntDom__c = IntDom;
                                        flightEvent.FlightNumber__c = flightNumber;
                                        flightEvent.Operational_Carrier__c = operationalCarrier;
                                        
                                        //Get the sector departure details
                                        //TO-DO: Check what's the scenario where there will be multiple sectors
                                        for (QCC_FlightStatusDepsAPIResponse.Sectors sector : flights.sectors) {
                                            String departurePort = sector.from_Z;
                                            system.debug('>>>sector: ' + sector);
                                            String arrivalPort = sector.to;
                                            flightEvent.DeparturePort__c = departurePort;
                                            flightEvent.Affected_Ports__c = departurePort;
                                            flightEvent.ArrivalPort__c = arrivalPort;
                                            
                                            Date ScheduledDepDate = Date.valueOf(sector.departure.scheduled);
                                            flightEvent.ScheduledDepDate__c = ScheduledDepDate;
                                            
                                            flightEvent.Name = 'HEADS UP ' + sector.sectorId;
                                        }
                                        
                                        //Set this field so the record will be considered by the Duplicate Rule (Event Duplicate Rule)
                                        flightEvent.DelayFailureCode__c = 'Heads Up';
                                        flightEvent.TECH_RecordType_Duplication__c = 'Heads Up';
                                        system.debug('>>>flightEvent: ' + flightEvent);
                                        flightEventsToCreate.add(flightEvent);
                                    }
                                }
                            }//End: Loop through the flight numbers. Will only consider the carrier specified on the custom label QCC_Global_Heads_Up_Event_Airline_Code
                            //flightSet_Counter++;
                            system.debug('>>>flightSet_Counter: ' + flightSet_Counter);
                        }//End: Loop through the list of flights from the API response
                    }
                }
                
                system.debug('>>>flightSet=' + flightSet + '; flightSet_Counter=' + flightSet_Counter);
                globalHeadsUpRecord.QCC_TECH_Flight_Counter__c = flightSet_Counter;
                
            }//End: Loop through the Global Event record
            
            system.debug('>>>flightEventsToCreate.size(): ' + flightEventsToCreate.size());
            system.debug('>>>flightEventsToCreate: ' + flightEventsToCreate);
            
            List<Database.SaveResult> saveResultList = new List<Database.SaveResult>();
            Map<String, List<String>> resultMap = new Map<String, List<String>>(); 
            if (!flightEventsToCreate.isEmpty()) {
                saveResultList = Database.insert (flightEventsToCreate,false);
                system.debug('>>>saveResultList: ' + saveResultList);
            }
            
            //Generate the save result so that we can create a Log record later.
            Integer recordCounter = 0;
            for(Database.SaveResult saveResult : saveResultList) {
                String recordId = flightEventsToCreate[recordCounter].Id;
                List<String> resultMessageList = new List<String>();
                if (!saveResult.isSuccess()) {            
                    for(Database.Error err : saveResult.getErrors()) {
                        resultMessageList.add(err.getStatusCode() + ': ' + err.getMessage());
                    }
                    resultMap.put(recordId, resultMessageList);
                }
                recordCounter++;
            }
            System.debug('>>>resultMap: ' + resultMap);
            
            //Create the log record for those save result that fails
            List<Log__c> logRecords = new List<Log__c>();
            for(String recordId: resultMap.keyset()){
                for(String resultMessage : resultMap.get(recordId)) {
                    //If records went into error due to the Duplicate Rule, then no need to log as it's valid not to create the record.
                    if (!resultMessage.contains('DUPLICATES_DETECTED')) {
                        logRecords.add(QCC_LogUtilityHelper.generateLogRecord('QCC - Get Flights for Global Heads Up Event', 'QCC_GetFlightsForGlobalHeadsUpController', 'getAllFlights', '', '', false, recordId, null, resultMessage));
                    }
                }
            }
            if (!logRecords.isEmpty()) {
                QCC_LogUtilityHelper.createLogRecords(logRecords);
            }
            
            
            //Collect the Event Ids saved successfully to be passed on to the job QCC_UpdateFlightsForHeadsUpQueuable
            List<Id> listIds = new List<Id>();
            for (Event__c flightEvent : flightEventsToCreate) {
                if (flightEvent.Id != NULL) {
                	listIds.add(flightEvent.Id);
                }
            }
            system.debug('>>>listIds: ' + listIds);
            
            //Call the batch that will retrieve the info of the flight event
            Database.executeBatch(new QCC_UpdateFlightsForHeadsUpBatch(listIds), 1);
            
            //Enqueue the job that updates the Flight event info
            /*for (Id eventId : listIds) {
                System.enqueueJob(new QCC_UpdateFlightsForHeadsUpQueuable(new List<Id>{eventId},NULL,0));
            }*/
                        
            update globalHeadsUpEvents;
            
        } catch (Exception ex) {
            Log__c logRecord = QCC_LogUtilityHelper.generateLogRecord('QCC - Get Flights for Global Heads Up Event', 'QCC_GetFlightsForGlobalHeadsUpController', 'getAllFlights', '', '', false, '', ex, '');
            system.debug('>>>logRecord: ' + logRecord);
            QCC_LogUtilityHelper.createLogRecord(logRecord);
        } 
        
        return myWrapper;
    }
    
    public class GetFlightsWrapper {
        @AuraEnabled public Boolean hasError {get;set;}
        @AuraEnabled public Boolean errorMessage {get;set;}
    }
}