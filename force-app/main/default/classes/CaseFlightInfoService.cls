public  without sharing class CaseFlightInfoService {
    
    @AuraEnabled
    public static List<FlightInfoWrapper> getFlightInfoForCase(Id caseId) {
        List<FlightInfoWrapper> flightInfoWrappers = new List<FlightInfoWrapper>();
        // List to store the response
        try{
            System.debug('caseId:::'+caseId);
            Set<String> airportCodesLst = new Set<String>();
            Map<String, QCC_PNRFlightInfoWrapper.Segments> flightInfoMap = new Map<String, QCC_PNRFlightInfoWrapper.Segments>();
            Map<String, List<FlightEventWrapper>> flightEventMap = new Map<String, List<FlightEventWrapper>>();
            Set<Id> flightEventIds = new Set<Id>(); 
            Map<Id, List<FlightFailureWrapper>> flightFailureMap = new Map<Id, List<FlightFailureWrapper>>();
            Map<String, FlightInfoWrapper> flightInfoWrapperMap = new Map<String, FlightInfoWrapper>();
            Map<String,String> airportCodesMap = new Map<String,String>();
            Map<String,String> airportCountryCodesMap = new Map<String,String>();
            
            // Retrieve Case Information
            Case caseRecord = [SELECT Id, Booking_PNR__c, ContactId, Last_Name__c, 
                               TECH_bookingCreationDate__c, TECH_bookingArchivalData__c,flight_number__C,event__c
                               FROM Case WHERE Id = :caseId LIMIT 1];
            System.debug('caseRecord:::'+caseRecord);
            String flightNumber = caseRecord.flight_number__c;
            String caseFlightEvent = caseRecord.event__c;
            // Validation: Check if PNR__c or Last_Name__c is blank
            if (String.isBlank(caseRecord.Booking_PNR__c)) {
                FlightInfoWrapper errorWrapper = new FlightInfoWrapper();
                errorWrapper.source = 'Error';
                errorWrapper.message = 'No PNR is linked to this case. Add a PNR to see flight details.';
                flightInfoWrappers.add(errorWrapper);
                return flightInfoWrappers;
            }
            
            String token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken');
            if(caseRecord.TECH_bookingArchivalData__c == null){
                caseRecord.TECH_bookingArchivalData__c = 'false';
            }
            
            // Call the External API 
            QCC_PNRFlightInfoWrapper flightApiResponse =  QCC_InvokeCAPAPI.invokePNRFlightInfoCAPAPI(
                caseRecord.Booking_PNR__c, caseRecord.last_name__c, token, caseRecord.TECH_bookingArchivalData__c
            );//new QCC_PNRFlightInfoWrapper(); */
            System.debug('flightApiResponse::::'+flightApiResponse);
            
            // If API response is null or empty
            if (flightApiResponse == null || flightApiResponse.booking == null) {
                FlightInfoWrapper errorWrapper = new FlightInfoWrapper();
                errorWrapper.source = 'Error';
                errorWrapper.message = 'No Flights found for '+ caseRecord.booking_pnr__c + ' . Please check that PNR is correct to see flight details.';
                flightInfoWrappers.add(errorWrapper);
                return flightInfoWrappers;
            }
             
            // Create the QCC_PNRFlightInfoWrapper Map
            
            if (flightApiResponse != null && flightApiResponse.booking != null){
                // Populate the map with API data
                for (QCC_PNRFlightInfoWrapper.Segments apiSegment : flightApiResponse.booking.segments) {
                    System.debug('Departure date :::'+apiSegment.departureLocalDate);
                    
                    String key = apiSegment.OperatingCarrierAlphaCode + apiSegment.operatingFlightNumber;
                    System.debug('Flight API Response :::'+key);
                    
                    // Add the flight segment to the map
                    flightInfoMap.put(key, apiSegment);
                }
            }
            System.debug('flightInfoMap:::'+flightInfoMap);
            // Query related Flight Events
            
            List<Event__c> flightEvents =[SELECT id,Name, FlightNumber__c, ScheduledDepDate__c,DelayFailureCode__c,Non_Delay_Failure_Code__c, DeparturePort__c, ArrivalPort__c,
                                          Scheduled_Departure__c,ActualArriDateTime__c,ActualDepaDateTime__c,ScheduledArrDateTime__c, EstimatedArrDateTime__c, EstimatedDepDateTime__c,
                                          DepartureDelayinHRSandMIN__c, ArrivalDelayinHRSandMIN__c,TechDepartureDelayDuration__c,TechArrivalDelayDuration__c,primary_root_cause__c,root_Cause__c,Disruption_Reason_Text__c,
                                          (SELECT Id, Flight_Event__c, Failure_Code__c FROM Failure_Details__r)
                                          FROM Event__c
                                          WHERE Id IN (SELECT Event__c FROM affected_Passenger__c WHERE PNR__c = :caseRecord.Booking_PNR__c AND LastName__c = :caseRecord.Last_Name__c)
                                          ORDER BY ScheduledDepDate__c ASC
                                          LIMIT 50];
            
            System.debug('flightEvents:::'+flightEvents);
            
            for(event__c event : flightEvents )
            {
                flightEventIds.add(event.id);
                airportCodesLst.add(event.DeparturePort__c);
                airportCodesLst.add(event.ArrivalPort__c);
                System.debug('Flight Event Id ::'+event.id);
                System.debug('Flight scheduled Dep date ::'+event.scheduledDepDate__c);
            }
            System.debug('flightEventIds:::'+flightEventIds);
            // Create a Map for Flight Events
            
            List<Airport_code__c> airportCodes = [SELECT Name, Freight_Station_Name__c, Freight_Airport_Country_Name__c,
                                                  Freight_Airport_Country_Code__c,Freight_Airport_State_Code__c FROM Airport_Code__c 
                                                  where name in :airportCodesLst and Freight_Station_Name__c!=null];
            
            for(Airport_code__c a : airportCodes)
            {
                airportCodesMap.put(a.name , a.Freight_Station_Name__c);
                airportCountryCodesMap.put(a.name , a.Freight_Airport_Country_Name__c);
            }
            map<string,boolean> isDelayMap = new map<string,boolean>();
            for (event__c flightEvent : flightEvents) {
                String formattedDate = null;
                String key = flightEvent.FlightNumber__c;
                FlightEventWrapper flightEventWrapper = new FlightEventWrapper();
                flightEventWrapper.source = 'Flight Event';
                flightEventWrapper.eventId = flightEvent.id;  
                flightEventWrapper.eventName = flightEvent.name; 
                flightEventWrapper.flightNumber = flightEvent.FlightNumber__c;
                flightEventWrapper.estArrDate = (flightEvent.EstimatedArrDateTime__c != null) ? getDateAndTime(flightEvent.EstimatedArrDateTime__c).get('date') : null;
                flightEventWrapper.estArrTime = (flightEvent.EstimatedArrDateTime__c != null) ? getDateAndTime(flightEvent.EstimatedArrDateTime__c).get('time') : null;
                flightEventWrapper.estDepDate = (flightEvent.EstimatedDepDateTime__c != null) ? getDateAndTime(flightEvent.EstimatedDepDateTime__c).get('date') : null;
                flightEventWrapper.estDepTime = (flightEvent.EstimatedDepDateTime__c != null) ? getDateAndTime(flightEvent.EstimatedDepDateTime__c).get('time') : null;
                flightEventWrapper.departureAirport = airportCodesMap.get(flightEvent.DeparturePort__c);
                flightEventWrapper.arrivalAirport = airportCodesMap.get(flightEvent.ArrivalPort__c);
                flightEventWrapper.departureCountryName = airportCountryCodesMap.get(flightEvent.DeparturePort__c);
                flightEventWrapper.arrivalCountryName = airportCountryCodesMap.get(flightEvent.ArrivalPort__c);
                
                if(flightEvent.DelayFailureCode__c!=null){
                    flightEventWrapper.delayFailurecode = CustomSettingsUtilities.getConfigDataMap(flightEvent.DelayFailureCode__c);
                }
                else {
                    flightEventWrapper.delayFailurecode = flightEvent.Non_Delay_Failure_Code__c;
                }

                if(String.isNotBlank(flightEvent.Disruption_Reason_Text__c)){
                    flightEventWrapper.disruptionCause = (flightEvent.root_cause__c ?? '') + '/' + (flightEvent.primary_root_cause__c ?? '');
                    flightEventWrapper.disruptionDetails = flightEvent.Disruption_Reason_Text__c;
                }
                flightEventWrapper.departureDelay = '';//flightEvent.DepartureDelayinHRSandMIN__c  ;
                if(flightEvent.TechDepartureDelayDuration__c != null &&  flightEvent.TechDepartureDelayDuration__c > 0){
                    Integer hours = Math.floor(flightEvent.TechDepartureDelayDuration__c * 24).intValue();
                    Integer minutes = Math.round(60 * ((flightEvent.TechDepartureDelayDuration__c * 24) - hours));
                    flightEventWrapper.departureDelay = ( hours > 0 ? hours+ ' hr ': '') + minutes + ' min late';
                }
                flightEventWrapper.arrivalDelay = '';//flightEvent.ArrivalDelayinHRSandMIN__c;
                if(flightEvent.TechArrivalDelayDuration__c != null && flightEvent.TechArrivalDelayDuration__c > 0){
                    Integer hours = Math.floor(flightEvent.TechArrivalDelayDuration__c * 24).intValue();
                    Integer minutes = Math.round(60 * ((flightEvent.TechArrivalDelayDuration__c * 24) - hours));                    
                    flightEventWrapper.arrivalDelay = ( hours > 0 ? hours+ ' hr ': '') + minutes + ' min late';
                }
                flightEventWrapper.departureAirportCode = flightEvent.DeparturePort__c;
                flightEventWrapper.arrivalAirportCode = flightEvent.ArrivalPort__c;
                flightEventWrapper.accordianTitle = flightEventWrapper.departureAirportCode + ' → ' + flightEventWrapper.arrivalAirportCode;
                System.debug('flightEvent.id:::'+flightEvent.id);
                System.debug('flightEvent.flightEvent.Scheduled_Departure__c:::'+flightEvent.Scheduled_Departure__c);
                //flightEventWrapper.flightDate = flightEvent.scheduledDepDate__c;
                flightEventWrapper.scheduledDepartureDate = (flightEvent.Scheduled_Departure__c != null) ? getDateAndTime(flightEvent.Scheduled_Departure__c).get('date') : null;
                flightEventWrapper.scheduledDepartureTime = (flightEvent.Scheduled_Departure__c != null) ? getDateAndTime(flightEvent.Scheduled_Departure__c).get('time') : 'N/A';
                //flightEventWrapper.scheduledDepDateTime = Date.valueOf(flightEvent.Scheduled_Departure__c);
                
                flightEventWrapper.scheduledArrivalDate = (flightEvent.ScheduledArrDateTime__c != null) ? getDateAndTime(flightEvent.ScheduledArrDateTime__c).get('date') : null;
                flightEventWrapper.scheduledArrivalTime = (flightEvent.ScheduledArrDateTime__c != null) ? getDateAndTime(flightEvent.ScheduledArrDateTime__c).get('time') : 'N/A';
                
                flightEventWrapper.actualArrivalDate = (flightEvent.ActualArriDateTime__c != null) ? getDateAndTime(flightEvent.ActualArriDateTime__c).get('date') : null;
                flightEventWrapper.actualArrivalTime = (flightEvent.ActualArriDateTime__c != null) ? getDateAndTime(flightEvent.ActualArriDateTime__c).get('time') : null;
                
                flightEventWrapper.actualDepartDate = (flightEvent.ActualDepaDateTime__c != null) ? getDateAndTime(flightEvent.ActualDepaDateTime__c).get('date') : null;
                flightEventWrapper.actualDepartTime = (flightEvent.ActualDepaDateTime__c != null) ? getDateAndTime(flightEvent.ActualDepaDateTime__c).get('time') : null;
                
                if(flightEventWrapper.eventId == caseFlightEvent || flightEventWrapper.flightNumber == flightNumber)
                {
                    flightEventWrapper.isDefaultRecord = 'true';
                }
                
                for (FlightFailure__c failure : flightEvent.Failure_Details__r) {
                    FlightFailureWrapper failureWrapper = new FlightFailureWrapper();
                    failureWrapper.failureCode = failure.Id;
                    failureWrapper.name = failure.Failure_Code__c;
                    if(failure.Failure_Code__c.contains('Delay')){
                       isDelayMap.put(failure.Flight_Event__c,true); 
                    }
                    if (!flightFailureMap.containsKey(failure.Flight_Event__c)) {
                        flightFailureMap.put(failure.Flight_Event__c, new List<FlightFailureWrapper>());
                    }
                    
                    // Add the failure to the corresponding Flight_Event__c in the map
                    flightFailureMap.get(failure.Flight_Event__c).add(failureWrapper);
                }
                flightEventWrapper.flightFailures = flightFailureMap.get(flightEventWrapper.eventId);
                flightEventWrapper.showDelay = (flightEvent.DelayFailureCode__c!=null ); //isDelayMap.containskey(flightEventWrapper.eventId)? isDelayMap.get(flightEventWrapper.eventId): false;
                flightEventWrapper.isflightFailuresPresent = !flightEventWrapper.flightFailures.isempty();
                if (!flightEventMap.containsKey(key)) {
                    flightEventMap.put(key, new List<FlightEventWrapper>());
                }
                
                // Add the failure to the corresponding Flight_Event__c in the map
                flightEventMap.get(key).add(flightEventWrapper);
                //flightEventMap.put(key, flightEventWrapper);
                
            }
            System.debug('flightEventMap:::'+flightEventMap);
            // Query related Flight Failures
            
            // Process the API Data - Add it to the flightInfoWrappers list
            // Initialize the flightInfoWrappers list
            for (String key : flightInfoMap.keySet()) {
                QCC_PNRFlightInfoWrapper.Segments apiSegment = flightInfoMap.get(key);
                FlightInfoWrapper flightInfoWrapper = new FlightInfoWrapper();
                flightInfoWrapper.source = 'API';
                
                flightInfoWrapper.flightNumber = apiSegment.operatingCarrierAlphaCode + apiSegment.operatingFlightNumber ;
                flightInfoWrapper.departureAirportCode = apiSegment.departureAirportCode;
                flightInfoWrapper.arrivalAirportCode = apiSegment.arrivalAirportCode;
                flightInfoWrapper.departureAirport = airportCodesMap.get(apiSegment.departureAirportCode);
                flightInfoWrapper.arrivalAirport = airportCodesMap.get(apiSegment.arrivalAirportCode);
                flightInfoWrapper.departureCountryName = airportCountryCodesMap.get(apiSegment.departureAirportCode);
                flightInfoWrapper.arrivalCountryName = airportCountryCodesMap.get(apiSegment.arrivalAirportCode);
                flightInfoWrapper.scheduledDepartureDate = apiSegment.departureLocalDate;
                flightInfoWrapper.scheduledDepartureTime = (apiSegment.departureLocalTime != null) ? getTimeinAMPM(apiSegment.departureLocalTime) : 'N/A';
                Date parsedDate = Date.parse(apiSegment.departureLocalDate); 
                String[] timeParts = apiSegment.departureLocalTime.split(':');
                Integer hours = Integer.valueOf(timeParts[0]);
                Integer minutes = Integer.valueOf(timeParts[1]);
                Integer seconds = Integer.valueOf(timeParts[2]);
                // Create a Time object using Time.newInstance()
                Time parsedTime = Time.newInstance(hours, minutes, seconds, 0); 
                flightInfoWrapper.scheduledDepDateTime =  DateTime.newInstance(parsedDate, parsedTime);
                flightInfoWrapper.scheduledArrivalDate = apiSegment.arrivalLocalDate;
                flightInfoWrapper.scheduledArrivalTime = (apiSegment.arrivalLocalTime != null && apiSegment.arrivalLocalDate != null) ? getTimeinAMPM(apiSegment.arrivalLocalTime) : 'N/A';
                flightInfoWrapper.actualDepartDate = apiSegment.actualDepartureLocalDate;
                flightInfoWrapper.actualDepartTime = (apiSegment.actualDepartureLocalTime != null && apiSegment.actualDepartureLocalDate != null) ? getTimeinAMPM(apiSegment.actualDepartureLocalTime) : null;
                flightInfoWrapper.actualArrivalDate = apiSegment.actualArrivalLocalDate;
                flightInfoWrapper.actualArrivalTime = (apiSegment.actualArrivalLocalTime != null && apiSegment.actualArrivalLocalDate != null) ? getTimeinAMPM(apiSegment.actualArrivalLocalTime) : null;
                
                System.debug('flightInfoWrapper:::'+flightInfoWrapper);
                System.debug('flightInfoWrapper.flightNumber:::'+flightInfoWrapper.flightNumber);
                System.debug('flightNumber:::'+flightNumber);
                flightInfoWrapper.flightEventWrapper = flightEventMap.get(flightInfoWrapper.flightNumber);
                flightInfoWrapperMap.put(key,flightInfoWrapper);
                
                // Add the FlightInfoWrapper to the flightInfoWrappers list
                flightInfoWrappers.add(flightInfoWrapper);
            }
            
        }catch (Exception e) {
            List<FlightInfoWrapper> flightInfoWrappersErr = new List<FlightInfoWrapper>();
            FlightInfoWrapper errorWrapper = new FlightInfoWrapper();
            errorWrapper.source = 'Error';
            errorWrapper.message = 'Something went wrong. Please contact your system administrator ' + e.getMessage() ;
            flightInfoWrappersErr.add(errorWrapper);
            return flightInfoWrappersErr;
        }
        
        System.debug('flightInfoWrappers::::'+flightInfoWrappers);
        flightInfoWrappers.sort();
        
        return flightInfoWrappers;
    }
    
    // Method to convert date-time string to a List with Date and AM/PM formatted time (no seconds)
    public static Map<String,String> getDateAndTime(String datetimeString) {
        // Initialize the list to return
        System.debug('datetimeString:::'+datetimeString);
        Map<String,String> result = new Map<String,String>();
        
        // Split the string into date and time
        List<String> parts = datetimeString.split(' ');
        
        if (parts.size() == 2) {
            // Date part
            String dateString = parts[0];  // '08/04/2022'
            
            // Time part
            String timeString = parts[1];  // '13:26:00'
            
            
            
            // Add date and formatted time to the result list
            result.put('date',dateString);
            result.put('time',getTimeinAMPM(timeString));
        }
        
        return result;
    }
    
    public static String getTimeinAMPM(String timeString)
    {
        List<String> timeParts = timeString.split(':');
        Integer hour = Integer.valueOf(timeParts[0]);
        Integer minute = Integer.valueOf(timeParts[1]);
        
        // Determine AM or PM
        String amPm = (hour >= 12) ? 'PM' : 'AM';
        
        // Adjust hour for 12-hour format
        if (hour > 12) {
            hour -= 12;
        } else if (hour == 0) {
            hour = 12;  // Handle midnight (00:00)
        }
        
        // Format the time in AM/PM format 
        String minuteFormatted = (minute < 10) ? '0' + String.valueOf(minute) : String.valueOf(minute);
        
        // Format the time in AM/PM format 
        String formattedTime = String.format('{0}:{1} {2}', 
                                             new List<Object>{String.valueOf(hour), minuteFormatted, amPm});
        
        return formattedTime;
    }
    
    // Make wrapper classes and fields @AuraEnabled
    public class FlightInfoWrapper implements Comparable {
        @AuraEnabled public String source;
        @AuraEnabled public String eventId;
        @AuraEnabled public String eventName;
        @AuraEnabled public String flightNumber;
        @AuraEnabled public String departureAirport;
        @AuraEnabled public String arrivalAirport;
        @AuraEnabled public DateTime scheduledDepDateTime;
        @AuraEnabled public String scheduledDepartureDate;
        @AuraEnabled public String isDefaultRecord;
        @AuraEnabled public String scheduledDepartureTime;
        @AuraEnabled public String scheduledArrivalDate;
        @AuraEnabled public String scheduledArrivalTime;
        @AuraEnabled public String actualArrivalDate;
        @AuraEnabled public String actualArrivalTime;
        @AuraEnabled public String actualDepartDate;
        @AuraEnabled public String actualDepartTime;
        @AuraEnabled public String estArrDate;
        @AuraEnabled public String estArrTime;
        @AuraEnabled public String estDepDate;
        @AuraEnabled public String estDepTime;
        @AuraEnabled public String message;
        @AuraEnabled public String delayFailurecode;
        @AuraEnabled public String departureDelay;
        @AuraEnabled public String arrivalDelay;
        @AuraEnabled public String departureAirportCode;
        @AuraEnabled public String arrivalAirportCode;
        @AuraEnabled public String departureCountryName;
        @AuraEnabled public String arrivalCountryName;
        
        
        @AuraEnabled public List<FlightEventWrapper> flightEventWrapper;
        
        public Integer compareTo(Object compareTo) {
            FlightInfoWrapper compareToEmp = (FlightInfoWrapper)compareTo;
            if (scheduledDepDateTime == compareToEmp.scheduledDepDateTime) return 0;
            if (scheduledDepDateTime > compareToEmp.scheduledDepDateTime) return 1;
            return -1;        
        }
    }
    
    
    
    public class FlightFailureWrapper {
        @AuraEnabled public String failureCode;
        @AuraEnabled public String flightEventStatus;
        @AuraEnabled public String name;
    }
    
    public class FlightEventWrapper
    {
        @AuraEnabled public String source;
        @AuraEnabled public String eventName;
        @AuraEnabled public String eventId;
        @AuraEnabled public String flightNumber;
        @AuraEnabled public String departureAirport;
        @AuraEnabled public String arrivalAirport;
        @AuraEnabled public DateTime scheduledDepDateTime;
        @AuraEnabled public String scheduledDepartureDate;
        @AuraEnabled public String isDefaultRecord;
        @AuraEnabled public String scheduledDepartureTime;
        @AuraEnabled public String scheduledArrivalDate;
        @AuraEnabled public String scheduledArrivalTime;
        @AuraEnabled public String actualArrivalDate;
        @AuraEnabled public String actualArrivalTime;
        @AuraEnabled public String actualDepartDate;
        @AuraEnabled public String actualDepartTime;
        @AuraEnabled public String estArrDate;
        @AuraEnabled public String estArrTime;
        @AuraEnabled public String estDepDate;
        @AuraEnabled public String estDepTime;
        @AuraEnabled public String message;
        @AuraEnabled public String delayFailurecode;
        @AuraEnabled public String departureDelay;
        @AuraEnabled public String arrivalDelay;
        @AuraEnabled public String departureAirportCode;
        @AuraEnabled public String arrivalAirportCode;
        @AuraEnabled public String departureCountryName;
        @AuraEnabled public String arrivalCountryName;
        @AuraEnabled public List<FlightFailureWrapper> flightFailures;
        @AuraEnabled public boolean isflightFailuresPresent;
        @AuraEnabled public boolean showDelay;
        @AuraEnabled public String accordianTitle;
        @AuraEnabled public String disruptionCause;
        @AuraEnabled public String disruptionDetails;
        @AuraEnabled public boolean empMessage;
    }
    
    
    
}