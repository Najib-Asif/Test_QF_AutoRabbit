/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   Event Communication trigger Helpers
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
24-Oct-2018      Praveen Sampath               Initial Design

-----------------------------------------------------------------------------------------------------------------------*/
public class EventCommunicationTriggerHelper {
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        linkPassengerWithComms
    Description:        Link Passenger to correct Email Comms Based on the Failure Code
    Parameter:          new List 
    --------------------------------------------------------------------------------------*/      
   public static void linkPassengerWithComms(List<EventCommunication__c> lstEvtComms){
        
        Map<Id, List<EventCommunication__c>> mapEvtComms = new Map<Id, List<EventCommunication__c>>();
        List<Affected_Passenger__c> lstUpdatePassenger = new List<Affected_Passenger__c>();

        //Check for any Valid Change happened on Events 
        for(EventCommunication__c objEvtComms: lstEvtComms){
            if(objEvtComms.IsGlobalEventComms__c != true){
                List<EventCommunication__c> lstEvt = mapEvtComms.containsKey(objEvtComms.FlightEvent__c)? mapEvtComms.get(objEvtComms.FlightEvent__c): new List<EventCommunication__c>();
                lstEvt.add(objEvtComms);
                mapEvtComms.put(objEvtComms.FlightEvent__c, lstEvt);
            }
        }

        system.debug('mapEvtComms$$$$'+mapEvtComms);

        //Fetch Passenger and link the Email Comms
        if(mapEvtComms.size() > 0){
            Map<Id, List<FlightFailure__c>> mapFlightFailure = QCC_EventGenericUtils.queryFlightFailures(mapEvtComms.keySet());
            Map<Id, List<Affected_Passenger__c>> mapEvtPassenger = new Map<Id, List<Affected_Passenger__c>>();
            
            //All Passenger related to the Event
            for(Affected_Passenger__c objPassenger: [select Id, Failure_Code__c, Event__c, EventCommunication__c, IsCommsRequired__c,   
                                                     TECH_PreFlight__c , TECH_PostFlight__c, HasPassengerTravelledonlyCurrentLeg__c, 
                                                     TravelledCabin__c, GlobalEvent__c, SeatNo__c, Affected__c from Affected_Passenger__c 
                                                     where Event__c IN: mapEvtComms.keyset() AND Affected__c =: true])
            {
                List<EventCommunication__c> lstEvt = mapEvtComms.get(objPassenger.Event__c);
                system.debug('objPassenger$$$$'+objPassenger);
                system.debug('lstEvt$$$$'+lstEvt);
                lstUpdatePassenger.add(QCC_EventGenericUtils.updatePassengerFailureCode(objPassenger, mapFlightFailure.get(objPassenger.Event__c), lstEvt));
            }

            //DML
            update lstUpdatePassenger;
        }

    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        linkPassengerWithComms
    Description:        Link Passenger to correct Email Comms Based on the Failure Code
    Parameter:          new List 
    --------------------------------------------------------------------------------------*/      
   public static void linkPassengerWithCommsForGlobal(List<EventCommunication__c> lstEvtComms){
        
        Map<Id, List<EventCommunication__c>> mapEvtComms = new Map<Id, List<EventCommunication__c>>();
        List<Affected_Passenger__c> lstUpdatePassenger = new List<Affected_Passenger__c>();

        //Check for any Valid Change happened on Events 
        for(EventCommunication__c objEvtComms: lstEvtComms){
            if(objEvtComms.IsGlobalEventComms__c == true){
                List<EventCommunication__c> lstEvt = mapEvtComms.containsKey(objEvtComms.FlightEvent__c)? mapEvtComms.get(objEvtComms.FlightEvent__c): new List<EventCommunication__c>();
                lstEvt.add(objEvtComms);
                mapEvtComms.put(objEvtComms.FlightEvent__c, lstEvt);
            }
        }

        system.debug('mapEvtComms$$$$'+mapEvtComms);

        //Fetch Passenger and link the Email Comms
        if(mapEvtComms.size() > 0){
           Map<Id, List<Affected_Passenger__c>> mapEvtPassenger = new Map<Id, List<Affected_Passenger__c>>();
            
            //All Passenger related to the Event
            for(Affected_Passenger__c objPassenger: [select Id, Failure_Code__c, Event__c, EventCommunication__c, IsCommsRequired__c, GlobalEvent__c,  
                                                     TECH_PreFlight__c , TECH_PostFlight__c, HasPassengerTravelledonlyCurrentLeg__c, 
                                                     TravelledCabin__c, Event__r.GlobalEvent__c from Affected_Passenger__c 
                                                     where Event__r.GlobalEvent__c IN: mapEvtComms.keyset() AND 
                                                     Affected__c =: true])
            {
                EventCommunication__c objEvtComms =  mapEvtComms.get(objPassenger.Event__r.GlobalEvent__c)[0];
                system.debug('objPassenger$$$$'+objPassenger);
                system.debug('lstEvt$$$$'+objEvtComms);
                String emailContent = String.isNotBlank(objEvtComms.ReasonParagraph__c) ? objEvtComms.ReasonParagraph__c +' \r\n\r\n' : ''; 
                emailContent += String.isNotBlank(objEvtComms.ApologyParagraph__c) ? objEvtComms.ApologyParagraph__c +' \r\n\r\n' : ''; 
                objPassenger.EventCommunication__c = objEvtComms.Id;
                objPassenger.EmailContent__c = emailContent;    
                objPassenger.EmailFooter__c = objEvtComms.FooterParagraph__c;
                lstUpdatePassenger.add(objPassenger);
            }

            //DML
            update lstUpdatePassenger;
        }

    }

     /*--------------------------------------------------------------------------------------      
    Method Name:        updateEmailContentOnPassenger
    Description:        Update Email Content on Passengers
    Parameter:          new Map and Old Map 
    --------------------------------------------------------------------------------------*/      
    public static void updateEmailContentOnPassenger(Map<Id, EventCommunication__c> mapNewEvtComms, Map<Id, EventCommunication__c> mapOldEvtComms){
        Set<Id> setEvntCommsIds = new Set<Id>();
        List<Affected_Passenger__c> lstUpdatePassenger = new List<Affected_Passenger__c>();

        //Check for any Valid Change happened on Events 
        for(EventCommunication__c objEvtComms: mapNewEvtComms.values()){
            EventCommunication__c oldEvtComms = mapOldEvtComms != Null? mapOldEvtComms.get(objEvtComms.Id): Null;

            if( objEvtComms.IntroParagraph__c != oldEvtComms.IntroParagraph__c ||
                objEvtComms.ApologyParagraph__c != oldEvtComms.ApologyParagraph__c ||
                objEvtComms.ReasonParagraph__c != oldEvtComms.ReasonParagraph__c ||
                objEvtComms.RecoveryParagraph__c != oldEvtComms.RecoveryParagraph__c)
            {
                setEvntCommsIds.add(objEvtComms.Id);
            }

        }

        system.debug('mapEvtComms$$$$'+setEvntCommsIds);

        //Fetch Passenger and link the Email Comms
        if(setEvntCommsIds.size() > 0){
            //All Passenger related to the Event
            for(Affected_Passenger__c objPassenger: [select Id, Failure_Code__c, Event__c, EventCommunication__c, IsCommsRequired__c,   
                                                     TECH_PreFlight__c , TECH_PostFlight__c, HasPassengerTravelledonlyCurrentLeg__c 
                                                     from Affected_Passenger__c where EventCommunication__c IN: setEvntCommsIds])
            {
                EventCommunication__c objEvtComms = mapNewEvtComms.get(objPassenger.EventCommunication__c);
                String emailContent = String.isNotBlank(objEvtComms.IntroParagraph__c) ? objEvtComms.IntroParagraph__c +' \r\n\r\n' : ''; 
                emailContent += String.isNotBlank(objEvtComms.ReasonParagraph__c) ? objEvtComms.ReasonParagraph__c +' \r\n\r\n' : ''; 
                emailContent += String.isNotBlank(objEvtComms.ApologyParagraph__c) ? objEvtComms.ApologyParagraph__c +' \r\n\r\n' : ''; 
                emailContent += String.isNotBlank(objEvtComms.RecoveryParagraph__c) ? objEvtComms.RecoveryParagraph__c +' \r\n\r\n' : ''; 
                objPassenger.EmailContent__c = emailContent;    
                lstUpdatePassenger.add(objPassenger);
                
            }

            //DML
            update lstUpdatePassenger;
        }
    }
}