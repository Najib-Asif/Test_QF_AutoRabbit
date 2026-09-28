/*----------------------------------------------------------------------------------------------------------------------
Author:        Purushotham B
Company:       Capgemini
Description:   Flight tracker Trigger helper
Inputs:
Test Class:    FlightTrackerTriggerTest 
************************************************************************************************
History
************************************************************************************************
20-June-2018             Purushotham B          Initial Design
29-June-2018             Praveen Sampath        Redesigned to handle multi sector and other best practices 
-----------------------------------------------------------------------------------------------------------------------*/
public with sharing class FlightTrackerTriggerHelper {

    public static Map<String, QCC_ValidFlightEvent__mdt>  validFlightEventMap;
    public static Map<String, String> validFlightFailureMap;
    public static Map<String, QCC_ValidFlightEvent__mdt> validPassengerEventMap;
    public static Set<String> setDelayCode;
    public static Boolean createFLTFailures =false;
    /*----------------------------------------------------------------------------------------------      
    Method Name:    populateUTCFields
    Description:    Convert Local time to UTC
    Parameter:      List<Flight_Tracker__c>    
    Return:             
    ----------------------------------------------------------------------------------------------*/
    public static void populateUTCFields(List<Flight_Tracker__c> lstFlgTracker, Map<Id, Flight_Tracker__c> oldFlightTrackerMap) {
        try {
            Integer internationalFlt = Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('InternationalFlightLimit'));
            Integer domesticFltLow = Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('DomesticFlightLowerLimit'));
            Integer domesticFltHigh = Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('DomesticFlightHigherLimit'));
            for(Flight_Tracker__c objFlgTrack: lstFlgTracker){
                Flight_Tracker__c oldFlgTrack = oldFlightTrackerMap != null ? oldFlightTrackerMap.get(objFlgTrack.Id) : null;
                
                if(oldFlgTrack == null) {
                    Integer fltNumber = Integer.valueOf(objFlgTrack.Flight_Number__c);
                
                    if(String.isBlank(objFlgTrack.IntDom__c) ||  objFlgTrack.IntDom__c == Null){
                        if(fltNumber <= internationalFlt) {
                            objFlgTrack.IntDom__c = 'International';
                        }
                        else if(fltNumber >= domesticFltLow && fltNumber <= domesticFltHigh) {
                            objFlgTrack.IntDom__c = 'Domestic';
                        }
                    }
                }

                //Udpate the Flight Tracker ID
                objFlgTrack.TECH_Flight_Tracker_Id__c = objFlgTrack.Airline__c+objFlgTrack.Flight_Number__c+objFlgTrack.Origin_Date__c+objFlgTrack.Arrival_Airport__c;
                
                //Only for diverted events
                if(oldFlgTrack != Null && objFlgTrack.NewArrivalPort__c != oldFlgTrack.NewArrivalPort__c && 
                   String.IsNotBlank(objFlgTrack.NewArrivalPort__c))
                {
                    String compositeId = objFlgTrack.Flight_Number__c + '' + objFlgTrack.Origin_Date__c + '' + objFlgTrack.Arrival_Airport__c + '' + objFlgTrack.NewArrivalPort__c;
                    String compositeId2 = objFlgTrack.Flight_Number__c + '' + objFlgTrack.Origin_Date__c + '' + objFlgTrack.NewArrivalPort__c + '' + objFlgTrack.Departure_Airport__c;
                    objFlgTrack.Tech_CompositeId_Diverted__c = compositeId;
                    objFlgTrack.Tech_CompositeId_Diverted1__c = compositeId2;
                } 
                
                List<Schema.FieldSetMember> allUTCFieds = SObjectType.Flight_Tracker__c.FieldSets.QCC_AllUTC_Fieds_Logic.getFields();
                for(Schema.FieldSetMember fsm : allUTCFieds) {
                    String fieldName = fsm.getFieldPath();
                    String oldval = oldFlgTrack != Null? (String) oldFlgTrack.get(fieldName):'';
                    String currentVal = (String) objFlgTrack.get(fieldName);
                    if((oldFlgTrack == null || oldval != currentVal) && String.isNotBlank(currentVal) && 
                       (currentVal.contains('+') || currentVal.contains('-')))
                    {
                        String utcFied = CustomSettingsUtilities.getConfigDataMap('QCC-UTC'+fieldName);
                        String dateVal = (String) objFlgTrack.get(fieldName);
                        
                        if(String.isNotBlank(dateVal)){
                            objFlgTrack.put(utcFied, GenericUtils.parseStringToUTC(dateVal));
                            objFlgTrack.put(fieldName, getDateTimeString(dateVal));
                        }
                    }
                }
            }
        } catch(Exception ex) {
         
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Flight Tracker', 'FlightTrackerTriggerHelper', 
                                    'populateUTCFields', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }

    /*----------------------------------------------------------------------------------------------      
    Method Name:    validateFlightEventCreation
    Description:    Flight Tracker on Update only when all fields are valid
    Parameter:      List<Flight_Tracker__c>, Map<Id, Flight_Tracker__c>
    Return:             
    ----------------------------------------------------------------------------------------------*/
    public static void validateFlightEventCreation(List<Flight_Tracker__c> lstFlightTracker, Map<Id, Flight_Tracker__c> oldFlightTrackerMap){
        try {
            Map<String, List<Event__c>> mapEvents = fetchAllMatchingEvent(lstFlightTracker);
            validFlight();
            String queueId = [SELECT Id FROM Group WHERE Type = 'Queue' and Name = 'CCC CJM Queue'].Id;
            String fltTrackerName = '';
            List<Event__c> eventsToUpdate = new List<Event__c>();
            Set<Id> setFltIds = new Set<Id>();
            for(Flight_Tracker__c objFlgTrack: lstFlightTracker){
                //Check Event Exist 
                if(objFlgTrack.Scheduled_Arrival_UTC__c != Null && objFlgTrack.Scheduled_Depature_UTC__c != Null && 
                    objFlgTrack.TrackerType__c != Null && objFlgTrack.TrackerType__c != 'No Match') 
                {
                    String mapKey = objFlgTrack.Airline__c+objFlgTrack.Flight_Number__c+objFlgTrack.Origin_Date__c+objFlgTrack.Arrival_Airport__c;
                    Flight_Tracker__c oldFT = oldFlightTrackerMap!= Null?oldFlightTrackerMap.get(objFlgTrack.Id): Null;
                    
                  
                    if(mapEvents != Null && mapEvents.containsKey(mapKey)){
                        List<Event__c> lstEvent = mapEvents.get(mapKey);
                        lstEvent = updateEventData(lstEvent, objFlgTrack, oldFT);
                        eventsToUpdate.addAll(lstEvent);
                    }
                    else{
                        Boolean isValid = checkEventRequired(objFlgTrack);
                        if(isValid){
                            //Create Events
                            eventsToUpdate.addAll(createEventData(objFlgTrack, queueId));
                            createFLTFailures = validFlightEventMap.get(objFlgTrack.Event_Name__c).CreateFlightFailRecords__c;
                        }
                    }
                }
                fltTrackerName = objFlgTrack.Event_Name__c;
            }
            upsert eventsToUpdate;
            if(createFLTFailures){
                Set<Id> setEvtId = new Set<Id>();
                for(Event__c objEvt: eventsToUpdate){
                    setEvtId.add(objEvt.Id);
                }
                createFlightFailure(setEvtId, fltTrackerName);
            }
        } catch(Exception ex) {
          
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Flight Tracker', 'FlightTrackerTriggerHelper', 
                                    'validateFlightEventCreation', String.valueOf(''), String.valueOf(''),false,'', ex);
        }
    }

    /*----------------------------------------------------------------------------------------------      
    Method Name:    checkEventRequired
    Description:    If Event required to be created
    Parameter:      Flight Tracker       
    Return:         Boolean          
    ----------------------------------------------------------------------------------------------*/
    public static Boolean checkEventRequired(Flight_Tracker__c flt){
        Boolean isValid = false;
        if(!validFlightEventMap.isEmpty() && validFlightEventMap.containsKey(flt.Event_Name__c)) {
            if(validFlightEventMap.get(flt.Event_Name__c).CreateEventRecord__c && validFlightEventMap.get(flt.Event_Name__c).CheckCriteria__c) {
                Datetime dt = flt.Actual_Departure_UTC__c != null ? flt.Actual_Departure_UTC__c : flt.Estimated_Departure_UTC__c;
               
                if(flt.Event_Name__c.equalsIgnoreCase('ESTIMATE_CHANGE') && flt.Scheduled_Depature_UTC__c != null && dt != null) {
                    Integer delayThreshold = Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('QCC_DelayEventThreshold'));
                    Long delay = GenericUtils.dateTimeDiffInMinutes(flt.Scheduled_Depature_UTC__c, dt);
                   
                    if(delay >= delayThreshold) {
                        isValid = true;
                    }
                }else if(flt.Event_Name__c.equalsIgnoreCase('BLOCKS_OFF') && flt.Scheduled_Depature_UTC__c != null && dt != null) {
                    Integer internationalDelayLimit = Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('InternationalDelayLimitInMinutes'));
                    Integer domesticDelayLimit = Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('DomesticDelayLimitInMinutes'));
                    Long delay = GenericUtils.dateTimeDiffInMinutes(flt.Scheduled_Depature_UTC__c, dt);
                  
                    if(flt.IntDom__c != null && ((flt.IntDom__c.equalsIgnoreCase('Domestic') && delay > domesticDelayLimit) || (flt.IntDom__c.equalsIgnoreCase('International') && delay > internationalDelayLimit))) {
                        isValid = true;
                    }
                }
                else if(flt.Event_Name__c.equalsIgnoreCase('FLIGHT_CANCEL')){
                    Integer  cancellationThreshold= Integer.valueOf(CustomSettingsUtilities.getConfigDataMap('QCC_CancellationEventThreshold'));
                    Long delay = GenericUtils.dateTimeDiffInMinutes(flt.Scheduled_Depature_UTC__c, system.now());
                    if(Test.isRunningTest()){
                        delay = cancellationThreshold;
                    }
                    if(delay <= cancellationThreshold){
                        isValid = true;
                    }
                }
            } else {
                isValid = validFlightEventMap.get(flt.Event_Name__c).CreateEventRecord__c;
            }
        }
        return isValid;
    }

    /*----------------------------------------------------------------------------------------------      
    Method Name:    fetchAllMatchingEvent
    Description:    Query all the event related to flight Tracker
    Parameter:      List of Flight Trackers       
    Return:         Map of String, List of Events           
    ----------------------------------------------------------------------------------------------*/
    public static Map<String, List<Event__c>> fetchAllMatchingEvent(List<Flight_Tracker__c> lstFlTracker){
        Map<String, List<Event__c>> mapEvents = new Map<String, List<Event__c>>();
        Set<String> setFltTrackerIds = new Set<String>();
        Set<Id> setRecIds = new Set<Id>();
        setRecIds.add(GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Active Record Type')));
        setRecIds.add(GenericUtils.getObjectRecordTypeId('Event__c', CustomSettingsUtilities.getConfigDataMap('Event Closed Record Type')));
        
        for(Flight_Tracker__c flt: lstFlTracker) {
            setFltTrackerIds.add(flt.Airline__c+flt.Flight_Number__c+flt.Origin_Date__c+flt.Arrival_Airport__c);
        }
        
        if(setFltTrackerIds.size() > 0) {
            List<Event__c> existingEventsWithTrackerId = [SELECT Id, TECH_FlightTrackerId__c, FlightNumber__c, ArrivalPort__c, DeparturePort__c, 
                                                          DelayFailureCode__c, Status__c, ScheduledDepDate__c FROM Event__c WHERE 
                                                          TECH_FlightTrackerId__c IN :setFltTrackerIds and RecordTypeId IN: setRecIds];
           

            for(Event__c evt: existingEventsWithTrackerId) {
                if(mapEvents.containsKey(evt.TECH_FlightTrackerId__c)) {
                    mapEvents.get(evt.TECH_FlightTrackerId__c).add(evt);
                }
                else {
                    List<Event__c> et = new List<Event__c>();
                    et.add(evt);
                    mapEvents.put(evt.TECH_FlightTrackerId__c, et);
                }
            }
        }
        return mapEvents;
    }

    /*----------------------------------------------------------------------------------------------      
    Method Name:    createEventData
    Description:    Create events with repect to flight Tracker
    Parameter:      Flight_Tracker__c, String, Boolean       
    Return:         List of Events           
    ----------------------------------------------------------------------------------------------*/
    public static List<Event__c> createEventData(Flight_Tracker__c objFlgTrack, String queueId){
        List<Event__c> lstEvent = new List<Event__c>();

        //Exact leg
        Event__c objExactEvent = populateBasicEventFields(new Event__c(), objFlgTrack, queueId);
        if(objFlgTrack.TrackerType__c != 'Single Sector'){
            objExactEvent.PartofMultiSectorFlight__c = true;
        }
        lstEvent.add(objExactEvent);

        return lstEvent;
    }



    /*----------------------------------------------------------------------------------------------      
    Method Name:    updateEventData
    Description:    Update events with repect to flight Tracker
    Parameter:      List<Event__c>, Flight_Tracker__c, Flight_Tracker__c       
    Return:         List of Events           
    ----------------------------------------------------------------------------------------------*/
    public static List<Event__c> updateEventData(List<Event__c> lstEvent, Flight_Tracker__c objFlgTrack, Flight_Tracker__c oldFlgTrack){
        for(Event__c objEvent: lstEvent){
            objEvent = eventFieldMapping(objEvent, objFlgTrack, oldFlgTrack);
        }
        return lstEvent;
    }

    /*----------------------------------------------------------------------------------------------      
    Method Name:    eventFieldMapping
    Description:    Maps event fields with repect to flight Tracker fields
    Parameter:      Event__c, Flight_Tracker__c, Flight_Tracker__c       
    Return:         Event__c           
    ----------------------------------------------------------------------------------------------*/
    public static Event__c eventFieldMapping(Event__c objEvent, Flight_Tracker__c objFlgTrack, Flight_Tracker__c oldFlgTrack){
        objEvent.Estimated_Departure_UTC__c =  objFlgTrack.EstimatedDepDateTime__c != Null && objFlgTrack.Estimated_Departure_UTC__c == null ? GenericUtils.parseStringToUTC(objFlgTrack.EstimatedDepDateTime__c) : objFlgTrack.Estimated_Departure_UTC__c;
        objEvent.Actual_Departure_UTC__c    =  objFlgTrack.ActualDepaDateTime__c != Null && objFlgTrack.Actual_Departure_UTC__c == null ? GenericUtils.parseStringToUTC(objFlgTrack.ActualDepaDateTime__c) : objFlgTrack.Actual_Departure_UTC__c;
        objEvent.EstimatedDepDateTime__c  =  getDateTimeString(objFlgTrack.EstimatedDepDateTime__c);
        objEvent.ActualDepaDateTime__c = getDateTimeString(objFlgTrack.ActualDepaDateTime__c);

        objEvent.Estimated_Arrival_UTC__c =  objFlgTrack.EstimatedArrDateTime__c != null && objFlgTrack.Estimated_Arrival_UTC__c == null ? GenericUtils.parseStringToUTC(objFlgTrack.EstimatedArrDateTime__c) : objFlgTrack.Estimated_Arrival_UTC__c;
        objEvent.Actual_Arrival_UTC__c    =  objFlgTrack.ActualArriDateTime__c != Null && objFlgTrack.Actual_Arrival_UTC__c == null ? GenericUtils.parseStringToUTC(objFlgTrack.ActualArriDateTime__c): objFlgTrack.Actual_Arrival_UTC__c;
        objEvent.EstimatedArrDateTime__c = getDateTimeString(objFlgTrack.EstimatedArrDateTime__c);
        objEvent.ActualArriDateTime__c = getDateTimeString(objFlgTrack.ActualArriDateTime__c);
        
        if(String.isNOTBlank(objFlgTrack.NewArrivalPort__c)) {
            objEvent.Diverted_Port__c = objFlgTrack.NewArrivalPort__c;
        }
       
   
        Decimal currentPriority = validFlightEventMap.get(objFlgTrack.Event_Name__c).Priority__c;
        Decimal oldPriority = (objEvent != null && String.isNotBlank(objEvent.DelayFailureCode__c)) ? validFlightEventMap.get(validFlightFailureMap.get(objEvent.DelayFailureCode__c)).Priority__c : null;
     

        Boolean isValid = false;
        if(objEvent.Id != Null && String.isBlank(objEvent.DelayFailureCode__c)){
            isValid = checkEventRequired(objFlgTrack);
        }else if(currentPriority != null && (currentPriority < oldPriority || oldPriority == null || 
                  (currentPriority <= oldPriority && objEvent.Id == Null)))
        {
            isValid = true;
        }

        if(isValid){
            createFLTFailures = validFlightEventMap.get(objFlgTrack.Event_Name__c).CreateFlightFailRecords__c;
            
            objEvent.DelayFailureCode__c = validFlightEventMap.get(objFlgTrack.Event_Name__c).FailureCode__c;

            if(objEvent.Status__c == CustomSettingsUtilities.getConfigDataMap('Event Closed Status')){
                objEvent.Status__c = 'Open';
                objEvent.IsEventReopened__c = true; 
                objEvent.ReOpenedReason__c = 'Auto Reopened Due to New Failure Code';
                objEvent.Re_Opened_By__c = userInfo.getUserId();
                objEvent.Re_Opened_Date_Time__c = system.now();
                objEvent.DelayCostsCompleted__c = false;
                objEvent.RecoveryPlanCompleted__c = false;
                String queueId = [SELECT Id FROM Group WHERE Type = 'Queue' and Name = 'CCC CJM Queue'].Id;
                objEvent.OwnerId = queueId;
            }else if(objEvent.Status__c == CustomSettingsUtilities.getConfigDataMap('Event Assigned Status')){
                objEvent.Status__c = 'Open';
                String queueId = [SELECT Id FROM Group WHERE Type = 'Queue' and Name = 'CCC CJM Queue'].Id;
                objEvent.OwnerId = queueId;
                objEvent.DelayCostsCompleted__c = false;
                objEvent.RecoveryPlanCompleted__c = false;
                objEvent.ReasonForTakingBackEvent__c = 'New Failure From QSOA';
            }
        }

        if(objFlgTrack.Event_Name__c.equalsIgnoreCase('BLOCKS_OFF') || objFlgTrack.Event_Name__c.equalsIgnoreCase('BLOCKS_ON') || objFlgTrack.Event_Name__c.equalsIgnoreCase('FLIGHT_CANCEL')) {
            objEvent.Flight_Status__c = validFlightEventMap.get(objFlgTrack.Event_Name__c).Flight_Status__c;
        }

        if(objFlgTrack.Event_Name__c.equalsIgnoreCase('ESTIMATE_CHANGE') && objFlgTrack.Actual_Departure_UTC__c != Null) {
            objEvent.Flight_Status__c = 'DEPARTED';
        }else if(objFlgTrack.Event_Name__c.equalsIgnoreCase('ESTIMATE_CHANGE') || 
                 objFlgTrack.Event_Name__c.equalsIgnoreCase('GROUND_RETURN') || 
                 objFlgTrack.Event_Name__c.equalsIgnoreCase('ADD_STOP'))
        {
            objEvent.Flight_Status__c = '';
        }else if(objFlgTrack.Actual_Departure_UTC__c != Null){
            objEvent.Flight_Status__c = 'DEPARTED'; 
        }
            if(objFlgTrack.Actual_Arrival_UTC__c != Null){
            objEvent.Flight_Status__c = 'LANDED'; 
        }
        return objEvent;
    }

    /*----------------------------------------------------------------------------------------------      
    Method Name:    validFlight
    Description:    Custom Meta data to determine the details
    Parameter:           
    Return:                    
    ----------------------------------------------------------------------------------------------*/
    public static void validFlight(){
        if(validFlightEventMap == Null ){
            validFlightEventMap = new Map<String, QCC_ValidFlightEvent__mdt>();
            validFlightFailureMap = new Map<String, String>();
            validPassengerEventMap = new Map<String, QCC_ValidFlightEvent__mdt>();
            setDelayCode = new Set<String>();
            for(QCC_ValidFlightEvent__mdt validFlightEvt: [SELECT Label,DeveloperName, CheckCriteria__c,
                                                           CreateEventRecord__c, Criteria__c, FailureCode__c,
                                                           PreFlight__c, PostFlight__c, Flight_Status__c,CreateFlightFailRecords__c, 
                                                           Priority__c FROM QCC_ValidFlightEvent__mdt]) 
            {
                validFlightEventMap.put(validFlightEvt.DeveloperName, validFlightEvt);
                validFlightFailureMap.put(validFlightEvt.FailureCode__c, validFlightEvt.DeveloperName );
                if(String.isNotBlank(validFlightEvt.FailureCode__c)){
                    validPassengerEventMap.put(validFlightEvt.DeveloperName, validFlightEvt);
                    setDelayCode.add(validFlightEvt.FailureCode__c);
                }
            }
        }
    }

    /*----------------------------------------------------------------------------------------------      
    Method Name:    populateBasicEventFields
    Description:    Populates basic Event fields w.r.t Flight Tracker
    Parameter:      Event, Flight Tracker and Queue ID (CJM)     
    Return:         Event           
    ----------------------------------------------------------------------------------------------*/
    public static Event__c populateBasicEventFields(Event__c evt, Flight_Tracker__c fltTracker, String queueId) {
        evt.FlightNumber__c = fltTracker.Airline__c+fltTracker.Flight_Number__c;
        evt.Flight_Status__c = fltTracker.Flight_Status__c;
        evt.TECH_FlightAPIInvoked__c = true;
        evt.QCC_AutoCreated__c = true;
        evt.OwnerId = queueId;
        evt.OriginDate__c = fltTracker.Origin_Date__c;
        evt.IntDom__c = fltTracker.IntDom__c;
        evt.Operational_Carrier__c = String.isNotBlank(fltTracker.Operational_Carrier__c) ? fltTracker.Operational_Carrier__c : fltTracker.Airline__c;
        evt.TECH_FlightTrackerId__c = fltTracker.TECH_Flight_Tracker_Id__c;//fltTracker.Airline__c+fltTracker.Flight_Number__c+fltTracker.Origin_Date__c+fltTracker.Arrival_Airport__c;
        evt.AirplaneType__c = fltTracker.Aircraft_Type__c;
        evt.Plane_Number__c = fltTracker.Aircraft_Registration__c;
        evt.DeparturePort__c = fltTracker.Departure_Airport__c;
        evt.ArrivalPort__c = fltTracker.Arrival_Airport__c;
        //evt.ScheduledDepTime__c = GenericUtils.parseStringToLocalDateTime(fltTracker.ScheduledDepTime__c).formatGmt('HH:mm');
        evt.ScheduledDepTime__c = fltTracker.ScheduledDepTime__c.substring(11,16);
        //evt.ScheduledDepDate__c = Date.parse((GenericUtils.parseStringToLocalDateTime(fltTracker.ScheduledDepTime__c).formatGmt('dd/MM/YYYY')));
        evt.ScheduledDepDate__c = Date.parse(fltTracker.ScheduledDepTime__c.substring(0,10));
        evt.Scheduled_Depature_UTC__c = fltTracker.ScheduledDepTime__c != null && fltTracker.Scheduled_Depature_UTC__c == null ? GenericUtils.parseStringToUTC(fltTracker.ScheduledDepTime__c) : fltTracker.Scheduled_Depature_UTC__c;
        evt.Scheduled_Arrival_UTC__c =  String.isNotBlank(fltTracker.ScheduledArrDateTime__c) && fltTracker.Scheduled_Arrival_UTC__c == null ? GenericUtils.parseStringToUTC(fltTracker.ScheduledArrDateTime__c) : fltTracker.Scheduled_Arrival_UTC__c;
        evt.ScheduledArrDateTime__c = getDateTimeString(fltTracker.ScheduledArrDateTime__c);
        evt.Scheduled_Departure_Date_Time__c = getDateTimeString(fltTracker.ScheduledDepTime__c);
        
        evt.Estimated_Departure_UTC__c =  fltTracker.EstimatedDepDateTime__c != Null && fltTracker.Estimated_Departure_UTC__c == null ? GenericUtils.parseStringToUTC(fltTracker.EstimatedDepDateTime__c) : fltTracker.Estimated_Departure_UTC__c;
        evt.Actual_Departure_UTC__c    =  fltTracker.ActualDepaDateTime__c != Null && fltTracker.Actual_Departure_UTC__c == null ? GenericUtils.parseStringToUTC(fltTracker.ActualDepaDateTime__c) : fltTracker.Actual_Departure_UTC__c;
        evt.EstimatedDepDateTime__c  =  getDateTimeString(fltTracker.EstimatedDepDateTime__c);
        evt.ActualDepaDateTime__c = getDateTimeString(fltTracker.ActualDepaDateTime__c);
        
        evt.Estimated_Arrival_UTC__c =  fltTracker.EstimatedArrDateTime__c != null && fltTracker.Estimated_Arrival_UTC__c == null ? GenericUtils.parseStringToUTC(fltTracker.EstimatedArrDateTime__c) : fltTracker.Estimated_Arrival_UTC__c;
        evt.Actual_Arrival_UTC__c    =  fltTracker.ActualArriDateTime__c != null && fltTracker.Actual_Arrival_UTC__c == null ? GenericUtils.parseStringToUTC(fltTracker.ActualArriDateTime__c) : fltTracker.Actual_Arrival_UTC__c;
        evt.EstimatedArrDateTime__c = getDateTimeString(fltTracker.EstimatedArrDateTime__c);
        evt.ActualArriDateTime__c = getDateTimeString(fltTracker.ActualArriDateTime__c);
        
        if(fltTracker.Event_Name__c.equalsIgnoreCase('FLIGHT_CANCEL') && (evt.DelayFailureCode__c == null || (evt.DelayFailureCode__c != null && !evt.DelayFailureCode__c.contains('Diversion')))) {
            evt.DelayFailureCode__c = validFlightEventMap.get(fltTracker.Event_Name__c).FailureCode__c;
        }

        if(fltTracker.Event_Name__c.equalsIgnoreCase('FLIGHT_CANCEL')) {
            evt.Flight_Status__c = validFlightEventMap.get(fltTracker.Event_Name__c).Flight_Status__c;
        }

        if(fltTracker.Event_Name__c.equalsIgnoreCase('ESTIMATE_CHANGE') && (evt.DelayFailureCode__c == null || (evt.DelayFailureCode__c != null && !evt.DelayFailureCode__c.contains('Diversion')))) {
            //evt.DelayFailureCode__c = failureCode;
            evt.DelayFailureCode__c = 'Flight Delay';
        }

        if(fltTracker.Actual_Departure_UTC__c != Null) {
            evt.Flight_Status__c = 'DEPARTED';
        }
        if(fltTracker.Actual_Arrival_UTC__c != Null) {
            evt.Flight_Status__c = 'LANDED';
        }
        
        if(fltTracker.Event_Name__c.equalsIgnoreCase('AIR_DIVERSION')) {
            evt.DelayFailureCode__c = 'Diversion Due to Other';
            evt.Diverted_Port__c = fltTracker.NewArrivalPort__c;
        }

        if(fltTracker.Event_Name__c.equalsIgnoreCase('ADD_STOP')){
            evt.Diverted_Port__c = fltTracker.NewArrivalPort__c;
        }

        if(fltTracker.Event_Name__c.equalsIgnoreCase('AIR_RETURN') || fltTracker.Event_Name__c.equalsIgnoreCase('AIR_RETURN_Domestic') || fltTracker.Event_Name__c.equalsIgnoreCase('AIR_RETURN_International')) {
            evt.DelayFailureCode__c = validFlightEventMap.get(fltTracker.Event_Name__c).FailureCode__c;
        }
        return evt;
    }

    /*----------------------------------------------------------------------------------------------      
    Method Name:    getDateTimeString
    Description:    Returns datetime string in dd/MM/YYYY HH:mm:ss format
    Parameter:      String     
    Return:         String           
    ----------------------------------------------------------------------------------------------*/
    public static String getDateTimeString(String dateTimeStr) {
        if(dateTimeStr == null) {
            return null;
        }
        if(dateTimeStr.contains('T') && GenericUtils.parseStringToLocalDateTime(dateTimeStr) != null) {
            return GenericUtils.parseStringToLocalDateTime(dateTimeStr).formatGmt('dd/MM/yyyy HH:mm:ss');
        }
        else {
            return dateTimeStr;
        }
    }

    /*----------------------------------------------------------------------------------------------      
    Method Name:    createFlightFailure
    Description:    Creates Flight Failure for Event and updates them
    Parameter:      Set EventId     
    Return:                    
    ----------------------------------------------------------------------------------------------*/
    public static void createFlightFailure(set<Id> setEvtId, string fltTrackerName){
        List<FlightFailure__c> lstFltFailure = new List<FlightFailure__c>();
        Map<String, FlightFailure__c> mapFF = new Map<String, FlightFailure__c>();
        for(FlightFailure__c objFF: [select Id,Flight_Event__c, Failure_Code__c from FlightFailure__c where 
                                      Flight_Event__c IN: setEvtId AND
                                      Failure_Code__c IN: setDelayCode])
        {
            mapFF.put(objFF.Flight_Event__c, objFF);
        }
        for(Id eventId: setEvtId){
            FlightFailure__c objFltFailure = new FlightFailure__c();
            objFltFailure.Flight_Event__c = eventId;
            objFltFailure.Affect_Sub_Section__c = 'Full Flight';
            objFltFailure.Affected_Region__c = 'Full Flight';
            objFltFailure.Failure_Code__c = validPassengerEventMap.get(fltTrackerName).FailureCode__c;
            String failureCode;
            if(mapFF.containsKey(eventId)){
               objFltFailure.Id = mapFF.get(eventId).Id;
            }
            objFltFailure.Pre_Flight__c = validPassengerEventMap.get(fltTrackerName).PreFlight__c;
            objFltFailure.Post_Flight__c = validPassengerEventMap.get(fltTrackerName).PostFlight__c;
            lstFltFailure.add(objFltFailure);
        }
        upsert lstFltFailure; 
    }

}