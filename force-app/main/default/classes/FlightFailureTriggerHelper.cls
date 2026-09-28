public class FlightFailureTriggerHelper {
    
    public static void beforeFlightFailureDeleteCheck(List<FlightFailure__c> lstOldFltFailure){
        String statusOpenEvent = CustomSettingsUtilities.getConfigDataMap('Event Open Status');
        String statusClosedEvent = CustomSettingsUtilities.getConfigDataMap('Event Closed Status');
        for(FlightFailure__c objFF: lstOldFltFailure){
            if(objFF.Tech_FlightEventStatus__c == statusClosedEvent){
                objFF.addError(Label.IOCFFdeleteCloseMSG);
            }else if(objFF.Tech_FlightEventStatus__c != statusOpenEvent){
                objFF.addError(Label.IOCFFdeleteMSG);
            }
        }
    }
    
    public static void addFailureCodetoPassengerandEvent(List<FlightFailure__c>lstFltFailure, Map<Id, FlightFailure__c>mapOldFltFailure)
    {
        Set<Id> setAffectedPassFF = new Set<Id>();
        Map<Id, List<FlightFailure__c>> mapff = new Map<Id, List<FlightFailure__c>>();
        List<Affected_Passenger__c> lstUpdatePassenger = new List<Affected_Passenger__c>();
        Boolean isVaidEventUpdate = false;
        Set<Id> setEventFF = new Set<Id>();
        for(FlightFailure__c objFF: lstFltFailure){
            FlightFailure__c oldFF = mapOldFltFailure != Null? mapOldFltFailure.get(objFF.Id): Null;
            if(oldFF == Null || oldFF.Affect_Sub_Section__c != objFF.Affect_Sub_Section__c ||
                oldFF.Failure_Code__c != objFF.Failure_Code__c || oldFF.Post_Flight__c != objFF.Post_Flight__c ||
                oldFF.Pre_Flight__c != objFF.Pre_Flight__c)
            {
                setAffectedPassFF.add(objFF.Flight_Event__c);
                
                //For Event Update
                if(oldFF == Null || oldFF.Failure_Code__c != objFF.Failure_Code__c){
                    setEventFF.add(objFF.Flight_Event__c);
                }
            }
        
        }
        if(setAffectedPassFF.size()>0){
             mapff = QCC_EventGenericUtils.queryFlightFailures(setAffectedPassFF);
        }
        //All Passenger Related Logic
        if(mapff.size()>0){
            Map<Id, List<Affected_Passenger__c>> mapEvtPassenger = new Map<Id, List<Affected_Passenger__c>>();
            
            //All Passenger related to the Event 
            for(Affected_Passenger__c objPassenger: [select Id, Failure_Code__c, Event__c, EventCommunication__c, IsCommsRequired__c, SeatNo__c, GlobalEvent__c,
                                                     TECH_PostFlight__c, TECH_PreFlight__c, Cabin__c , TravelledCabin__c from Affected_Passenger__c 
                                                     where Event__c IN: mapff.keyset() ])
            {
                List<FlightFailure__c> lstFF = mapff.get(objPassenger.Event__c);
                system.debug('lstFF###'+lstFF);
                lstUpdatePassenger.add(QCC_EventGenericUtils.updatePassengerFailureCode(objPassenger, lstFF, new List<EventCommunication__c>()));
                system.debug('lstUpdatePassenger####'+lstUpdatePassenger);
            }
            update lstUpdatePassenger;
        }

        // All Event Related Logic
        if(setEventFF.size()>0){
            Set<String> setDelayFailure = new Set<String>();
            List<Event__c> lstUpdateEvt = new List<Event__c>();
            for(QCC_ValidFlightEvent__mdt validFlightEvt: [SELECT Label,DeveloperName, CheckCriteria__c,
                                                           CreateEventRecord__c, Criteria__c, FailureCode__c,
                                                           PreFlight__c, PostFlight__c, Flight_Status__c, 
                                                           Priority__c FROM QCC_ValidFlightEvent__mdt])
            {
                
                setDelayFailure.add(validFlightEvt.FailureCode__c);
            }

            for(Id evtId: setEventFF){
                Event__c objEvent = new Event__c();
                objEvent.Id = evtId;
                String nonDelay = '';
                for(FlightFailure__c objFF: mapff.get(evtId)){
                    if(setDelayFailure.contains(objFF.Failure_Code__c)){
                        objEvent.DelayFailureCode__c = objFF.Failure_Code__c;
                    }else{
                        nonDelay += objFF.Failure_Code__c+';';
                    }
                    system.debug('nonDelay###'+nonDelay);
                }
                objEvent.Non_Delay_Failure_Code__c = nonDelay;
                lstUpdateEvt.add(objEvent);

            }
            update lstUpdateEvt;
        }
    }


    public static void updateEmailComs(List<FlightFailure__c>lstFltFailure, Map<Id, FlightFailure__c>mapOldFltFailure){
        Set<Id> setEventFF = new Set<Id>();
        for(FlightFailure__c objFF: lstFltFailure){
            FlightFailure__c oldFF = mapOldFltFailure != Null? mapOldFltFailure.get(objFF.Id): Null;
            if((objFF.OnlyLeg__c != oldFF.OnlyLeg__c) && objFF.EventStatus__c == 'Assigned')
            {
                setEventFF.add(objFF.Flight_Event__c);
            }
       }

       if(setEventFF.size()>0){
            QCC_EventGenericUtils.createEmailCommsForEvents(setEventFF);
       }
    }


    public static void checkFlightFailureDuplication(List<FlightFailure__c>lstFltFailure, Map<Id, FlightFailure__c>mapOldFltFailure){
        //populate the unique key field: event - failure code
        
         
          for(FlightFailure__c ff : lstFltFailure){ 
            if(ff.Flight_Event__c!=NULL){
            ff.Unique_Event_ErrorCode__c = ff.Flight_Event__c+'_'+ff.Failure_Code__c;
              }
              else{
            ff.Unique_Event_ErrorCode__c=ff.Operating_Carrier__c+'-'+ff.Flight_Number__c+'-'+string.valueof(ff.DepartureDateLocal__c)+ff.DepartureAirport__c+ff.ArrivalAirport__c+'-'+ff.failure_code__c;
              }
            //else{
            //ff.Unique_Event_ErrorCode__c=ff.Flight_Event__r.FlightNumber__c+'-'+ff.Flight_Event__r.Schedule_Departure_Date__c+ff.Flight_Event__r.DeparturePort__c+ff.Flight_Event__r.ArrivalPort__c+'-'+ff.Flight_Event__r.DelayFailureCode__c;
            //}
        }
    }
}