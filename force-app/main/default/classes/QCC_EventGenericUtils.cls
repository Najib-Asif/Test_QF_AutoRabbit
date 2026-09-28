/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath 
Company:       Capgemini
Description:   Class All Event Related Generic functions
Inputs:        
Test Class:    QCC_EventGenericUtilsTest. 
************************************************************************************************
History
************************************************************************************************

-----------------------------------------------------------------------------------------------------------------------*/
public without sharing class QCC_EventGenericUtils {
    
    /*--------------------------------------------------------------------------------------      
    Method Name:      updatePassengerFailureCode
    Description:      Link Event Commuication and Add Failure Code
    Parameter:        Passenger, List of Flight Failures and List of Event Comms
    --------------------------------------------------------------------------------------*/      
    public static Affected_Passenger__c updatePassengerFailureCode( Affected_Passenger__c objPassenger, List<FlightFailure__c> lstFltFailures,
                                                                   List<EventCommunication__c> lstEvtComms )
    {
        Set<String> setPasFailure = new Set<String>();
        Set<String> setOnlLegFailure = new Set<String>();
        
        if(lstFltFailures != Null && lstFltFailures.size()>0){
            String failureCode = '';
            for(FlightFailure__c objFF: lstFltFailures){
                //Only Leg Failures
                if(objFF.OnlyLeg__c){
                    setOnlLegFailure.add(objFF.Failure_Code__c);
                }
                
                if((objFF.Pre_Flight__c == true && objFF.Post_Flight__c == true && 
                    objFF.Pre_Flight__c == objPassenger.TECH_PreFlight__c &&
                    objFF.Post_Flight__c == objPassenger.TECH_PostFlight__c) ||
                   (objFF.Pre_Flight__c == true  && objFF.Post_Flight__c != true && 
                    objFF.Pre_Flight__c == objPassenger.TECH_PreFlight__c) ||
                   (objFF.Pre_Flight__c != true  && objFF.Post_Flight__c == true && 
                    objFF.Post_Flight__c == objPassenger.TECH_PostFlight__c))
                {
                    system.debug('objFF###'+objFF);
                    if(objFF.Affect_Sub_Section__c == 'Full Flight'){
                        failureCode += objFF.Failure_Code__c+';';
                        setPasFailure.add(failureCode);
                    }else if(objFF.Affected_Region__c == 'Cabin'){
                        List<String> lstString = objFF.Affect_Sub_Section__c.split(';');
                        for(String fCode: lstString){
                            if(fCode == objPassenger.TravelledCabin__c){
                        		failureCode += objFF.Failure_Code__c+';';
                                break;
                            }
                        }
                        setPasFailure.add(failureCode);
                    }else if(objFF.Affected_Region__c == 'Zone'){
                       List<String> lstString = objFF.Affect_Sub_Section__c.split(';');
                        for(String fCode: lstString){
                            system.debug('fcode$$$$'+fcode);
                            system.debug('objPassenger.SeatNo__c$$$$'+objPassenger.SeatNo__c);
                            String rowNo = String.isNotBlank(fcode)?QCC_GenericUtils.getIntegerFromString(fcode): '';
                            String seatNo = String.isNotBlank(objPassenger.SeatNo__c)?QCC_GenericUtils.getIntegerFromString(objPassenger.SeatNo__c): '';
                            system.debug('rowNo$$$$'+rowNo);
                            system.debug('seatNo$$$$'+seatNo);
                            SeatNo = String.isNotBlank(seatNo)?SeatNo.replaceFirst('^0+',''):'';
                            system.debug('seatNo22$$$$'+seatNo);
                            if(seatNo == rowNo && String.isNotBlank(seatNo) && String.isNotBlank(rowNo)){                        		
                                failureCode += objFF.Failure_Code__c+';';
                                break;
                            }
                        }
                        setPasFailure.add(failureCode);
                    }	
                }
            }
            
            if(String.isNotBlank(failureCode)){
                objPassenger.Failure_Code__c = failureCode;
                objPassenger.Affected__c = true;
            }else{
                objPassenger.Failure_Code__c = '';
                objPassenger.Affected__c= false;
                objPassenger.EventCommunication__c = Null;
                objPassenger.EmailContent__c = '';
            }
        }
        if(objPassenger.Affected__c){
            if(lstEvtComms != Null && lstEvtComms.size()>0){
                EventCommunication__c objEvtComms = Null;
                Map<Boolean, Map<String, EventCommunication__c>> mapEvtComms = new Map<Boolean, Map<String, EventCommunication__c>>();
                Map<String, EventCommunication__c> mapObjEvt = new Map<String, EventCommunication__c>();
                
                if(String.isNotBlank(objPassenger.GlobalEvent__c)){
                    objEvtComms = lstEvtComms[0];
                }
                else{
                    for(EventCommunication__c objEvtComm: lstEvtComms){
                        if(objEvtComm.OnlyLeg__c && objPassenger.Affected__c){
                            Map<String, EventCommunication__c> mapObjEvtCom = mapEvtComms.containsKey(true)?mapEvtComms.get(true):new Map<String, EventCommunication__c>();
                            mapObjEvtCom.put(objEvtComm.FailureCode__c, objEvtComm);
                            mapEvtComms.put(true, mapObjEvtCom);
                        }
                        else if(objPassenger.Affected__c){
                            Map<String, EventCommunication__c> mapObjEvtCom = mapEvtComms.containsKey(false)?mapEvtComms.get(false):new Map<String, EventCommunication__c>();
                            mapObjEvtCom.put(objEvtComm.FailureCode__c, objEvtComm);
                            mapEvtComms.put(false, mapObjEvtCom);
                        }
                    }
                    
                    objPassenger.EventCommunication__c = Null;
                    objPassenger.EmailContent__c = '';
                    
                    List<String>  lstPassCommsFailure = objPassenger.Failure_Code__c.split(';');
                    Set<String> setFailures = new Set<String>();
                    setFailures.addall(lstPassCommsFailure);
                    system.debug('setFailures####'+setFailures);
                    
                    String key = '';
                    Set<String> setkey = new Set<String>();
                    
                    for(String s: setFailures){
                        key += s+';';
                        setkey.add(s);
                    }
                    
                    if(mapEvtComms != Null && mapEvtComms.containskey(false) ){
                        mapObjEvt = mapEvtComms.get(false);
                    }
                    
                    if(mapEvtComms.containsKey(true)){
                        system.debug('Inside True');
                        
                        if(!objPassenger.HasPassengerTravelledonlyCurrentLeg__c){
                            system.debug('Inside Full Leg passenger');
                            system.debug('setOnlLegFailure@@@@'+setOnlLegFailure);
                            
                            setFailures.removeAll(setOnlLegFailure);
                            key = '';
                            for(String s: setFailures){
                                key += s+';';
                                setkey.add(s);
                            }
                        }else{
                            if(mapEvtComms != Null && mapEvtComms.containsKey(true) && mapEvtComms.get(true) != Null){
                                mapObjEvt.putAll(mapEvtComms.get(true));
                            }
                        }
                    }
                    key = key.removeEnd(';');
                    system.debug('key####'+key);
                    system.debug('mapObjEvt####'+mapObjEvt);
                    system.debug('mapEvtComms####'+mapEvtComms);
                    
                    objEvtComms = (String.isNotBlank(key) && mapObjEvt.containsKey(key))?mapObjEvt.get(key):Null;
                    if(objEvtComms == Null){
                        if(mapObjEvt != Null){
                            for(EventCommunication__c objEvtComm : mapObjEvt.values()){
                                system.debug('setkey####'+setkey);
                                system.debug('objEvtComm.FailureCode__c.split(;)####'+objEvtComm.FailureCode__c.split(';'));
                                List<String> lstfc = objEvtComm.FailureCode__c.split(';');
                                Set<String> setFC = new Set<String>();
                                setFC.addAll(lstfc);
                                if(setFC.containsAll(setkey)){
                                    objEvtComms = objEvtComm;
                                    break;
                                }
                            }
                        }
                    }
                }
                
                if(objEvtComms != Null){
                    //Convert Multi Pick to Set of String
                    
                    system.debug('objEvtComms####'+objEvtComms);
                    system.debug('objPassenger####'+objPassenger);
                    
                    String emailContent = String.isNotBlank(objEvtComms.ReasonParagraph__c) ? objEvtComms.ReasonParagraph__c +' \r\n\r\n' : ''; 
                    emailContent +=  String.isNotBlank(objEvtComms.ApologyParagraph__c) ? objEvtComms.ApologyParagraph__c : ''; 
                    objPassenger.EventCommunication__c = objEvtComms.Id;
                    objPassenger.EmailContent__c = emailContent;	
                    objPassenger.EmailFooter__c = objEvtComms.FooterParagraph__c;
                } 
            }
        }
        return objPassenger;
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:      queryEvtComms
    Description:      Query all Event Communications related to event 
    Parameter:        Set Event Id
    --------------------------------------------------------------------------------------*/      
    public static  Map<Id, List<EventCommunication__c>> queryEvtComms(Set<Id> setEvnId){
        Map<Id, List<EventCommunication__c>> mapEvtComms = new Map<Id, List<EventCommunication__c>>();
        for(EventCommunication__c objEvtComms: [select Id, ApologyParagraph__c, Comms_Type__c, FailureCode__c, FlightEvent__c, 
                                                OnlyLeg__c, IsGenericContent__c, IntroParagraph__c, ReasonParagraph__c, FooterParagraph__c, 
                                                RecoveryParagraph__c from EventCommunication__c
                                                where FlightEvent__c IN: setEvnId])
        {
            List<EventCommunication__c> lstEvtComms = mapEvtComms.containsKey(objEvtComms.FlightEvent__c)?mapEvtComms.get(objEvtComms.FlightEvent__c): new List<EventCommunication__c>();
            lstEvtComms.add(objEvtComms);
            mapEvtComms.put(objEvtComms.FlightEvent__c, lstEvtComms);
        }
        return mapEvtComms;
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:      queryFlightFailures
    Description:      Query all Failure Code related to event 
    Parameter:        Set Event Id
    --------------------------------------------------------------------------------------*/      
    public static  Map<Id, List<FlightFailure__c>> queryFlightFailures(Set<Id> setEvnId){
        Map<Id, List<FlightFailure__c>> mapFltFailure = new Map<Id, List<FlightFailure__c>>();
        for(FlightFailure__c objFltFailure: [Select Id, Flight_Event__c, Affect_Sub_Section__c, Affected_Region__c,OnlyLeg__c, 
                                             Failure_Code__c, Post_Flight__c, Pre_Flight__c from FlightFailure__c
                                             where Flight_Event__c IN: setEvnId])
        {
            List<FlightFailure__c> lstFltFailure = mapFltFailure.containsKey(objFltFailure.Flight_Event__c)?mapFltFailure.get(objFltFailure.Flight_Event__c): new List<FlightFailure__c>();
            lstFltFailure.add(objFltFailure);
            mapFltFailure.put(objFltFailure.Flight_Event__c, lstFltFailure);
        }
        return mapFltFailure;
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:      createEmailCommsForEvents
    Description:      Create Email Comms required, when Event is Assigned or when Flight Failure only leg is 
    updated
    Parameter:        Set Event Id
    --------------------------------------------------------------------------------------*/  
    @future    
    public static void createEmailCommsForEvents(Set<Id> setEventIds){
        deleteOldEventComms(setEventIds);
        Map<Id, List<FlightFailure__c>> mapFltFailure = queryFlightFailures(setEventIds);
        List<EventCommunication__c> lstEvtComms = new List<EventCommunication__c>();
        Set<String> setDelayFailure = new Set<String>();
        Map<String, String> mapEmailReason = new Map<String, String>();
        for(QCC_ValidFlightEvent__mdt validFlightEvt: [SELECT FailureCode__c FROM QCC_ValidFlightEvent__mdt
                                                       where FailureCode__c != '' AND FailureCode__c != Null])
        {
            
            setDelayFailure.add(validFlightEvt.FailureCode__c);
        }
        
        for(QCC_EmailContent__mdt emailContent: [SELECT FailureCode__c , ReasonParagraph__c  from QCC_EmailContent__mdt]){
            mapEmailReason.put(emailContent.FailureCode__c, emailContent.ReasonParagraph__c);
        }
        
        system.debug('mapFltFailure###'+mapFltFailure);
        for(Id evntId: mapFltFailure.keySet()){
            Boolean isDelayonlLeg= false;
            Map<String, String> mapFailureCode = new Map<String, String>();
            
            for(FlightFailure__c objFltFailure: mapFltFailure.get(evntId)){
                system.debug('objFltFailure####'+objFltFailure);
                
                if(setDelayFailure.contains(objFltFailure.Failure_Code__c)){
                    mapFailureCode.put('DelayCode', objFltFailure.Failure_Code__c);
                    if(objFltFailure.OnlyLeg__c){
                        isDelayonlLeg = true;
                        String nonDelayOnlyLeg = mapFailureCode.containsKey('onlLegFailure')? mapFailureCode.get('onlLegFailure'): ''; 
                        nonDelayOnlyLeg = objFltFailure.Failure_Code__c+';'+nonDelayOnlyLeg;
                        mapFailureCode.put('onlLegFailure', nonDelayOnlyLeg);
                    }
                    else{
                        String nonDelayFull = mapFailureCode.containsKey('fullFailure')? mapFailureCode.get('fullFailure'): '';
                        nonDelayFull = objFltFailure.Failure_Code__c+';'+nonDelayFull;
                        
                        String nonDelayOnlyLeg = mapFailureCode.containsKey('onlLegFailure')? mapFailureCode.get('onlLegFailure'): ''; 
                        nonDelayOnlyLeg = objFltFailure.Failure_Code__c+';'+nonDelayOnlyLeg;
                        
                        mapFailureCode.put('onlLegFailure', nonDelayOnlyLeg);
                        mapFailureCode.put('fullFailure', nonDelayFull);
                    }
                }else{
                    if(!objFltFailure.OnlyLeg__c){
                        String nonDelayFull = mapFailureCode.containsKey('fullFailure')? mapFailureCode.get('fullFailure'): '';
                        nonDelayFull += objFltFailure.Failure_Code__c+';';
                        mapFailureCode.put('fullFailure', nonDelayFull);
                    }
                    String nonDelayOnlyLeg = mapFailureCode.containsKey('onlLegFailure')? mapFailureCode.get('onlLegFailure'): '';
                    nonDelayOnlyLeg += objFltFailure.Failure_Code__c+';';
                    mapFailureCode.put('onlLegFailure', nonDelayOnlyLeg);
                }
            }
            
            if(mapFailureCode.containsKey('fullFailure') && mapFailureCode.containsKey('onlLegFailure')){
                if(mapFailureCode.get('fullFailure') == mapFailureCode.get('onlLegFailure')){
                    mapFailureCode.remove('onlLegFailure');
                }
            }
            
            if(mapFailureCode.size()>0){
                Boolean isInsideDelay = false;
                system.debug('mapFailureCode####'+mapFailureCode);
                if(mapFailureCode.containsKey('DelayCode')){
                    isInsideDelay = true;
                    lstEvtComms.add(eventCommsMapping(evntId, mapFailureCode.get('DelayCode'), isDelayonlLeg, false, false, mapEmailReason, setDelayFailure));
                }
                if(mapFailureCode.containsKey('onlLegFailure')){
                    Integer count = mapFailureCode.get('onlLegFailure').split(';').size();
                    String failures = mapFailureCode.get('onlLegFailure');
                    lstEvtComms.addAll(createEventComms(evntId, count, failures, true, isInsideDelay, mapEmailReason, setDelayFailure));
                }
                if(mapFailureCode.containsKey('fullFailure')){
                    Integer count = mapFailureCode.get('fullFailure').split(';').size();
                    String failures = mapFailureCode.get('fullFailure');
                    Boolean hasDelayCode = (isInsideDelay == true && isDelayonlLeg == false)?true: false;
                    lstEvtComms.addAll(createEventComms(evntId, count, failures, false, hasDelayCode, mapEmailReason, setDelayFailure));
                }
            }
        }
        system.debug('lstEvtComms$$$$'+lstEvtComms);
        insert lstEvtComms;
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:      createEventComms
    Description:      Create Email Comms required for event and retuns list of Event Comms
    Parameter:        evntId, count, failures, isLeg, isInsideDelay
    --------------------------------------------------------------------------------------*/      
    public Static List<EventCommunication__c> createEventComms(String evntId, Integer count, String failures, 
                                                               Boolean isLeg, Boolean isInsideDelay, 
                                                               Map<String, String> mapEmailReason, Set<String> setDelayFailure)
    {
        List<EventCommunication__c> lstEvtComms = new List<EventCommunication__c>();
        if( count <=2){
            if(isInsideDelay && count>1){
                lstEvtComms.add(eventCommsMapping(evntId, failures, isLeg, false, false, mapEmailReason, setDelayFailure));
            }else if(!isInsideDelay && count > 1){
                lstEvtComms.add(eventCommsMapping(evntId, failures, isLeg, false, false, mapEmailReason, setDelayFailure));
                for(String faiure: failures.split(';')){
                    lstEvtComms.add(eventCommsMapping(evntId, faiure, isLeg, false, false, mapEmailReason, setDelayFailure));
                }
            }else if(!isInsideDelay && count == 1){
                lstEvtComms.add(eventCommsMapping(evntId, failures, isLeg, false, false, mapEmailReason, setDelayFailure));
            }
        }else{
            lstEvtComms.add(eventCommsMapping(evntId, failures, isLeg, true, false, mapEmailReason, setDelayFailure));
        }
        return lstEvtComms;
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:      eventCommsMapping
    Description:      Map Fields
    Parameter:        evntId, count, failures, isLeg, isInsideDelay
    --------------------------------------------------------------------------------------*/      
    public static EventCommunication__c eventCommsMapping(Id eventId, String failureCode, Boolean isOnlyLeg, 
                                                          Boolean isGeneric, Boolean isGlobal, 
                                                          Map<String, String> mapEmailReason, Set<String> setDelayFailure)
    {
        EventCommunication__c objEvtComms = new EventCommunication__c();
        objEvtComms.FlightEvent__c = eventId;
        objEvtComms.FailureCode__c = failureCode;
        //objEvtComms.IntroParagraph__c = ' Thank you for choosing Qantas ';
        objEvtComms.ApologyParagraph__c = Label.QCC_ApologyParagraph;
        objEvtComms.FooterParagraph__c	 = Label.QCC_FooterParagraph;
        objEvtComms.OnlyLeg__c = isOnlyLeg;
        objEvtComms.IsGlobalEventComms__c = isGlobal;
        objEvtComms.IsGenericContent__c = isGeneric;
        objEvtComms.Comms_Type__c = 'Email';
        
        if(isGlobal){
             objEvtComms.ReasonParagraph__c = mapEmailReason.get('Global'); 
        }else{
            system.debug('failureCode####'+failureCode);
            system.debug('mapEmailReason####'+mapEmailReason);
            List<String> lstFailureCode = failureCode.split(';');
            if(lstFailureCode.size() == 1){
                 failureCode = failureCode.endsWith(';')? failureCode.removeEnd(';'): failureCode;
                objEvtComms.ReasonParagraph__c = mapEmailReason.get(failureCode);
            }
            else{
                Boolean hasDelayCode = false;
                String DelayCode = '';
                for(String failure: lstFailureCode){
                    if(setDelayFailure.contains(failure)){
                        hasDelayCode = true;
                        DelayCode = failure;
                        break;
                    }
                }
                String key;
                if(hasDelayCode){
                    if(lstFailureCode.size() == 2){
                        key = failureCode.endsWith(';')? failureCode.removeEnd(';'): failureCode;
                    }else if(lstFailureCode.size() > 2){
                        key = DelayCode+';'+'Any';
                    }              
                }else{
                    key = 'Any';   
                }
                system.debug('key####'+key);
                system.debug('map get####'+mapEmailReason.get(key));
                objEvtComms.ReasonParagraph__c = mapEmailReason.get(key); 
            }
        }
        return objEvtComms;   
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:      deleteOldEventComms
    Description:      Delete all old Event Communication
    Parameter:        Set Event Id
    --------------------------------------------------------------------------------------*/      
    public static void deleteOldEventComms(Set<Id> eventId){
        List<EventCommunication__c> lstEvtComms = [select Id from EventCommunication__c where FlightEvent__c IN: eventId 
                                                   AND Comms_Type__c = 'Email'];
        delete lstEvtComms;
        
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:      createCommsForGlobalEvent
    Description:      Create Comms for Global Event
    Parameter:        Set Event Id
    --------------------------------------------------------------------------------------*/  
    @future    
    public static void createCommsForGlobalEvent(Set<Id> setEventIds){
        deleteOldEventComms(setEventIds);
        Set<String> setDelayFailure = new Set<String>();
        Map<String, String> mapEmailReason = new Map<String, String>();
        for(QCC_ValidFlightEvent__mdt validFlightEvt: [SELECT FailureCode__c FROM QCC_ValidFlightEvent__mdt
                                                       where FailureCode__c != '' AND FailureCode__c != Null])
        {
            
            setDelayFailure.add(validFlightEvt.FailureCode__c);
        }for(QCC_EmailContent__mdt emailContent: [SELECT FailureCode__c , ReasonParagraph__c  from QCC_EmailContent__mdt]){
            mapEmailReason.put(emailContent.FailureCode__c, emailContent.ReasonParagraph__c);
        }
        
        List<EventCommunication__c> lstEvtComms = new List<EventCommunication__c>();
        for(Id eventId: setEventIds){
            lstEvtComms.add(eventCommsMapping(eventId, '', false, false, true, mapEmailReason, setDelayFailure));
        }
        insert lstEvtComms;
    }
    /*--------------------------------------------------------------------------------------      
    Method Name:      checkEmail
    Description:      Validate Email in Salesforce
    Parameter:        String Email Address
    --------------------------------------------------------------------------------------*/      
    public static Boolean checkEmail(String semail) {
        String InputString = String.isNotBlank(semail)?semail.trim(): '';
        string startreg = 'a-zA-z0-9';
        if(String.isNotBlank(InputString)){
            String fChar = InputString.substring(0, 1);
            if(fChar.isAlphanumeric()){
                String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
                Pattern MyPattern = Pattern.compile(emailRegex);
                
                // Then instantiate a new Matcher object "MyMatcher"
                Matcher MyMatcher = MyPattern.matcher(InputString);
                
                if (!MyMatcher.matches()) {
                    return FALSE;
                }
                else {
                    return TRUE;
                }
            }
            return false;
        }
        return false;
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:      generateEventName
    Description:      Add Event Name logic 
    Parameter:        Flight Event Object
    --------------------------------------------------------------------------------------*/      
    public static Event__c generateEventName(Event__c objEvt){
        objEvt.Name = objEvt.FlightNumber__c+' '+String.ValueOf(objEvt.ScheduledDepDate__c.Day()).leftPad(2,'0')+''+String.ValueOf(objEvt.ScheduledDepDate__c.Month()).leftPad(2,'0')+''+String.ValueOf(objEvt.ScheduledDepDate__c.Year()).right(2)+''+objEvt.DeparturePort__c
                +''+objEvt.ArrivalPort__c;
        return objEvt;
    }
}