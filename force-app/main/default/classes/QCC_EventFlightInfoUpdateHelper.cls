public class QCC_EventFlightInfoUpdateHelper {
    /*--------------------------------------------------------------------------------------       
    Method Name:        updateMultiSectorFlightInfoforEvent
    Description:        Call to Flight Schedule API and Flight Status API for multi sector flights
    Parameter:          Event listIds
    --------------------------------------------------------------------------------------*/  
    public static String updateMultiSectorFlightInfoforEvent(List<Id> listIds){
        String output = '';
        Boolean isException = false;
        List<Event__c> events = [Select id, name, Flight_Number_Changed__c, ScheduledDepDate__c, DeparturePort__c, FlightNumber__c, AirplaneType__c, Plane_Number__c,
                            ScheduledArrDateTime__c,ActualDepaDateTime__c, ActualArriDateTime__c, Scheduled_Arrival_UTC__c, Estimated_Arrival_UTC__c,
                            Actual_Arrival_UTC__c, Scheduled_Depature_UTC__c, Estimated_Departure_UTC__c, Actual_Departure_UTC__c, DelayFailureCode__c,
                            Operating_Carrier__c, EstimatedDepDateTime__c, 
                            ArrivalPort__c, Operational_Carrier__c, ScheduledDepTime__c, Flight_Info_Update_Status__c,
                            IsEventReopened__c, TECH_FlightAPIInvoked__c, Diverted_Port__c
                            FROM Event__c 
                            WHERE Id IN :listIds];
        try{
    
            //create request for getting flight info
            flightRequest fr = new flightRequest();
            flightStatusRequest fsr = new flightStatusRequest();
			
            for(event__c ev:events){
                
                if(fr.departureDate== null || fr.departureDate== ''){
                    if(ev.ScheduledDepDate__c != null){
                        String formatStr = Datetime.newInstance(ev.ScheduledDepDate__c, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
                        fr.departureDate = formatStr;
                    }
                }
                if(fr.departurePort== null || fr.departurePort== ''){
                    if(!String.isBlank(ev.DeparturePort__c)){
                        fr.departurePort = ev.DeparturePort__c;
                    }
                }
                if(fr.flightNo== null || fr.flightNo== ''){
                    if(!String.isBlank(ev.FlightNumber__c)){
                        String fightNumber = ev.FlightNumber__c;
                        //remove the prefis if needed (Usually 2 characters QF)
                        while(!GenericUtils.checkisNumeric(fightNumber)){
                            fightNumber = fightNumber.substring(1);
                        }
    
                        fr.flightNo = fightNumber;
                    }
                } 
                if(fr.carrier== null || fr.carrier== ''){
                    if(!String.isBlank(ev.FlightNumber__c)){
                        String carrier = ev.FlightNumber__c;
                        fr.carrier = carrier.substring(0,2);
                    }
                }  


                if(fsr.flightNo== null || fsr.flightNo== ''){
                    if(!String.isBlank(ev.FlightNumber__c)){
                        String fightNumber = ev.FlightNumber__c;
                        //remove the prefis if needed (Usually 2 characters QF)
                        while(!GenericUtils.checkisNumeric(fightNumber)){
                            fightNumber = fightNumber.substring(1);
                        }
                        while(fightNumber.startsWith('0')){
                            fightNumber = fightNumber.substring(1);
                        }
    
                        fsr.flightNo = fightNumber;
                    }
                }   
                if(fsr.departureFrom== null || fsr.departureFrom== ''){
                    if(ev.ScheduledDepDate__c != null){
                        String formatStr = Datetime.newInstance(ev.ScheduledDepDate__c, Time.newInstance(0,0,0,0)).format('YYYYMMddHHmm');
                        fsr.departureFrom = formatStr;
                    }
                } 
                if(fsr.departureTo== null || fsr.departureTo== ''){
                    if(ev.ScheduledDepDate__c != null){
                        String formatStr = Datetime.newInstance(ev.ScheduledDepDate__c.addDays(1), Time.newInstance(23,59,0,0)).format('YYYYMMddHHmm');
                        //String formatStr = Datetime.newInstance(ev.ScheduledDepDate__c, Time.newInstance(23,59,0,0)).format('YYYYMMddHHmm');
                        fsr.departureTo = formatStr;
                    }
                }   
            }
            
            
            System.debug(fr);
            System.debug(fsr);
            //calling to Flight schedule api to get departure time
            if(!String.isBlank(fr.departureDate) && !String.isBlank(fr.departurePort) && !String.isBlank(fr.flightNo)){
                QCC_FlightInfoResponse fir = QCC_InvokeCAPAPI.invokeFlightInfoAPI(fr.departureDate, fr.departurePort, fr.flightNo, fr.arrivalPort, fr.carrier);
                System.debug(LoggingLevel.ERROR, fir);
                if(fir != null && fir.flights != null && fir.flights.size()>0){
                    for(QCC_FlightInfoResponse.flight singleFlight :  fir.flights){
                        for(event__c ev:events){
                            //update Flight Info for Event
                            
                            //delayDuration use for Primary delay root cause
                            Integer delayDuration = 0;
                            if(ev.FlightNumber__c.contains(singleFlight.marketingFlightNo)){
                                System.debug(LoggingLevel.ERROR, singleFlight);
                                ev.AirplaneType__c = (singleFlight.equipmentTypeCode != null ? singleFlight.equipmentTypeCode : '') + (singleFlight.equipmentSubTypeCode != null ? ('-' + singleFlight.equipmentSubTypeCode) : '');
                                ev.Plane_Number__c = singleFlight.equipmentTailNumber != null ? singleFlight.equipmentTailNumber : '';                
                                //ev.Flight_Status__c = singleFlight.flightStatus != null ? singleFlight.flightStatus : '';  
                                ev.Operational_Carrier__c = singleFlight.marketingCarrier != null ? singleFlight.marketingCarrier : ''; 
                                
                                ev.Scheduled_Depature_UTC__c = GenericUtils.parseStringToGMT(singleFlight.scheduledDepartureUTCTimeStamp);
                                ev.Estimated_Departure_UTC__c = GenericUtils.parseStringToGMT(singleFlight.estimatedDepartureUTCTimeStamp);
                                ev.Actual_Departure_UTC__c = GenericUtils.parseStringToGMT(singleFlight.actualDepartureUTCTimeStamp);
                                ev.ActualDepaDateTime__c = singleFlight.actualDepartureLocalTimeStamp;
                                ev.EstimatedDepDateTime__c = singleFlight.estimatedDepartureLocalTimeStamp;
                                if(!String.isBlank(singleFlight.scheduledDepartureLocalTimeStamp)){
                                    ev.ScheduledDepTime__c =  singleFlight.scheduledDepartureLocalTimeStamp.substring(11,16); 
                                }
                                //update Diverted Port
                                System.debug(LoggingLevel.ERROR, singleFlight.airDiversion);
                                if(singleFlight.airDiversion != null 
                                        && singleFlight.airDiversion.unScheduledArrivalAirport != null){
                                    ev.Diverted_Port__c = singleFlight.airDiversion.unScheduledArrivalAirport;
                                }
                                ev.Flight_Info_Update_Status__c = '';
                                //turn off isOpen in order to auto close
                                ev.IsEventReopened__c = false;

                                //assign root cause
                                if(singleFlight.delay != null && singleFlight.delay.size() > 0){
                                    for(QCC_FlightInfoResponse.Delay delayReason : singleFlight.delay){
                                        if(delayDuration <= QCC_GenericUtils.stringToInteger(delayReason.delayDuration)){
                                            delayDuration = QCC_GenericUtils.stringToInteger(delayReason.delayDuration);
                                            ev.Primary_Root_Cause__c = QCC_GenericUtils.getDelayReason(delayReason.reasonCode , delayReason.shortDescription);
                                        }
                                    }
                                }
                            }
                            //Add to stop invoking mutiple times and sequence the Passenger API invoke
                            ev.TECH_FlightAPIInvoked__c = true;
                        }
                    }
                    output = 'Success: flight info updated';
                }else if(fir != null && fir.errorMessage != null){
                    //Stop updating Flight Info if the Departure Info is not retrieved
                    system.debug('Flight not found 2nd call');        
                    output = 'Flight schedule is not found';
                    fsr = new flightStatusRequest();//cleaar out Flight Status Request to avoid next API call
                    for(event__c ev:events){
                        ev.Flight_Info_Update_Status__c = output;
                        //Add to stop invoking mutiple times and sequence the Passenger API invoke
                        ev.TECH_FlightAPIInvoked__c = true;
                    }
                }
            }
            
            //calling to Flight Status API to update Arrival Time
            if(!String.isBlank(fsr.departureFrom) && !String.isBlank(fsr.departureTo) && !String.isBlank(fsr.flightNo)){
                QCC_FlightStatusAPIResponse fir = QCC_InvokeCAPAPI.invokeFlightStatusAPI(fsr.departureFrom, fsr.departureTo, fsr.flightNo);
                System.debug(LoggingLevel.ERROR, fir);
                if(fir != null && fir.flights != null && fir.flights.size()>0){
                    
                    for(QCC_FlightStatusAPIResponse.flight singleFlight :  fir.flights){
                        system.debug('singleFlight#####'+singleFlight);
                        if(singleFlight != null && singleFlight.sectors != null & singleFlight.sectors.size() > 0){
                            String preLegStatus = '';
                            for(QCC_FlightStatusAPIResponse.sector sector : singleFlight.sectors){
                                for(event__c ev: events){
                                    if(String.valueOf(ev.ScheduledDepDate__c) == singleFlight.flightNumbers[0].originDate){
                                        //Flight Status update for full Length
                                        if( ev.DeparturePort__c.equalsIgnoreCase(sector.from_x))
                                        {
                                            String validlegOneStatus = CustomSettingsUtilities.getConfigDataMap('QCC_FristLegStatus');
                                            system.debug('validlegOneStatus$$$$$'+validlegOneStatus);
                                            system.debug('sector$$$$$'+sector.arrival.Status);
                                            if(validlegOneStatus.containsIgnoreCase(sector.arrival.Status)){
                                                ev.Flight_Status__c = sector.arrival.Status;
                                            }
                                            preLegStatus = sector.arrival.Status;   
                                        }
                                        system.debug('preLegStatus$$$'+preLegStatus);
                                        if(ev.ArrivalPort__c.equalsIgnoreCase(sector.to)){
                                            String validlegOneStatus = CustomSettingsUtilities.getConfigDataMap('QCC_FinalLegStatus');
                                            system.debug('validlegOneStatus$$$$$'+validlegOneStatus);
                                            system.debug('sector$$$$$'+sector.arrival.Status);
                                            if(validlegOneStatus.containsIgnoreCase(sector.arrival.Status)){
                                                ev.Flight_Status__c = sector.arrival.Status;
                                            }else if(preLegStatus == 'Landed'){
                                                ev.Flight_Status__c = 'DEPARTED';
                                            }
                                            
                                                if(ev.Actual_Arrival_UTC__c <> null){
                                                ev.Flight_Status__c = 'LANDED';
                                            }
                                        }

                                        if(ev.ArrivalPort__c.equalsIgnoreCase(sector.to)){
                                            System.debug(ev);
                                            ev.Scheduled_Arrival_UTC__c =  ev.Flight_Number_Changed__c != true?GenericUtils.parseStringToGMT2(sector.arrival.scheduled): ev.Scheduled_Arrival_UTC__c;
                                            ev.Estimated_Arrival_UTC__c =  GenericUtils.parseStringToGMT2(sector.arrival.estimated);
                                            ev.Actual_Arrival_UTC__c    =  GenericUtils.parseStringToGMT2(sector.arrival.actual);

                                            if(GenericUtils.parseStringToGMT2(sector.arrival.scheduled) != null &&   ev.Flight_Number_Changed__c != true){
                                                ev.ScheduledArrDateTime__c  =  GenericUtils.parseStringToGMT2(sector.arrival.scheduled).format('dd/MM/YYYY HH:mm:ss');
                                                System.debug(ev.ScheduledArrDateTime__c);
                                            }
                                            if(GenericUtils.parseStringToGMT2(sector.arrival.estimated) != null){
                                                ev.EstimatedArrDateTime__c  =  GenericUtils.parseStringToGMT2(sector.arrival.estimated).format('dd/MM/YYYY HH:mm:ss');
                                                System.debug(ev.EstimatedArrDateTime__c);
                                            }
                                            if(GenericUtils.parseStringToGMT2(sector.arrival.actual) != null){
                                                ev.ActualArriDateTime__c    =  GenericUtils.parseStringToGMT2(sector.arrival.actual).format('dd/MM/YYYY HH:mm:ss');
                                            }    
                                            
                                            
                                            ev.Flight_Info_Update_Status__c = '';
                                            //turn off isOpen in order to auto close
                                            ev.IsEventReopened__c = false;
                                        } 
                                        //Add to stop invoking mutiple times and sequence the Passenger API invoke
                                        ev.TECH_FlightAPIInvoked__c = true;  
                                    }
                                }
                            }
                        }
                        
                    }                    
                    output = 'Success: flight info updated';
                }
            }

            system.debug('events##########'+events);
            
            update events;

        }catch(exception ex){
            isException = true;
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());

            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Event', 'QCC_EventFlightInfoUpdateHelper', 
                                    'updateMultiSectorFlightInfoforEvent', String.valueOf(''), String.valueOf(''),false,'', ex);
            
            output = 'Error: '+ ex.getMessage();
        }finally{
            if(isException){
                for(Event__c ev: events){
                    if( ev.TECH_FlightAPIInvoked__c != true){
                        ev.TECH_FlightAPIInvoked__c = true;
                    }
                }
                update events;
            }
        }     
        
        return output;
    }
    
    /*--------------------------------------------------------------------------------------       
    Method Name:        updateforEvent
    Description:        Call to Flight Schedule API single sector flights
    Parameter:          Event listIds
    --------------------------------------------------------------------------------------*/  
   public static String updateforEvent(List<Id> listIds){
        String output = '';
        Boolean isException = false;
        List<Event__c> events = [Select id, name, ScheduledDepDate__c,Flight_Number_Changed__c, DeparturePort__c, FlightNumber__c, AirplaneType__c, Plane_Number__c,
                            ScheduledArrDateTime__c,ActualDepaDateTime__c, ActualArriDateTime__c, Scheduled_Arrival_UTC__c, Estimated_Arrival_UTC__c,
                            Actual_Arrival_UTC__c, Scheduled_Depature_UTC__c, Estimated_Departure_UTC__c, Actual_Departure_UTC__c, DelayFailureCode__c,
                            Operating_Carrier__c, EstimatedDepDateTime__c, 
                            ArrivalPort__c, Operational_Carrier__c, ScheduledDepTime__c, Flight_Info_Update_Status__c,
                            IsEventReopened__c, TECH_FlightAPIInvoked__c, Diverted_Port__c
                            FROM Event__c 
                            WHERE Id IN :listIds];
        try{
            //create request for getting flight info
            flightRequest fr = new flightRequest();
            List<String> lstAddStopIds = new List<String>();

            for(event__c ev:events){
                
                //adding logic for Add Stop flight
                if(ev.DelayFailureCode__c == 'Add Stop'){
                    lstAddStopIds.add(ev.id);
                    continue;
                }
                
                if(fr.departureDate== null || fr.departureDate== ''){
                    if(ev.ScheduledDepDate__c != null){
                        String formatStr = Datetime.newInstance(ev.ScheduledDepDate__c, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
                        fr.departureDate = formatStr;
                    }
                }
                if(fr.departurePort== null || fr.departurePort== ''){
                    if(!String.isBlank(ev.DeparturePort__c)){
                        fr.departurePort = ev.DeparturePort__c;
                    }
                }
                if(fr.arrivalPort== null || fr.arrivalPort== ''){
                    if(!String.isBlank(ev.ArrivalPort__c)){
                        fr.arrivalPort = ev.ArrivalPort__c;
                    }
                }
                if(fr.flightNo== null || fr.flightNo== ''){
                    if(!String.isBlank(ev.FlightNumber__c)){
                        String fightNumber = ev.FlightNumber__c;
                        //remove the prefix if needed (Usually 2 characters QF)
                        while(!GenericUtils.checkisNumeric(fightNumber)){
                            fightNumber = fightNumber.substring(1);
                        }
    
                        fr.flightNo = fightNumber;
                    }
                } 
                if(fr.carrier== null || fr.carrier== ''){
                    if(!String.isBlank(ev.FlightNumber__c)){
                        String carrier = ev.FlightNumber__c;  
                        fr.carrier = carrier.substring(0,2);
                    }
                }       
            }
            
            //adding logic for Add Stop flight
            if(lstAddStopIds.size() > 0){
                //switch to Multi Sector Flight flow
                system.debug('invoke multi Secotr Flight: ');        
                QCC_MultiSectorFlightUpdateQueuable getMultiSectorFlightDetailJob = new QCC_MultiSectorFlightUpdateQueuable(lstAddStopIds);
                ID jobID = System.enqueueJob(getMultiSectorFlightDetailJob);
            }

            //calling to Flight schedule api to get departure time and arrival time
            if(!String.isBlank(fr.departureDate) && !String.isBlank(fr.departurePort) && !String.isBlank(fr.flightNo)){
                QCC_FlightInfoResponse fir = QCC_InvokeCAPAPI.invokeFlightInfoAPI(fr.departureDate, fr.departurePort, fr.flightNo, fr.arrivalPort, fr.carrier);
                System.debug(LoggingLevel.ERROR, fir);
                if(fir != null && fir.flights != null && fir.flights.size()>0){
                    for(QCC_FlightInfoResponse.flight singleFlight :  fir.flights){
                        for(event__c ev:events){
                            //update Flight Info for Event
                            
                            //delayDuration use for Primary root delay cause
                            Integer delayDuration = 0;
                            if(ev.FlightNumber__c.contains(singleFlight.marketingFlightNo)){
                                System.debug(LoggingLevel.ERROR, singleFlight);
                                ev.AirplaneType__c = (singleFlight.equipmentTypeCode != null ? singleFlight.equipmentTypeCode : '') + (singleFlight.equipmentSubTypeCode != null ? ('-' + singleFlight.equipmentSubTypeCode) : '');
                                ev.Plane_Number__c = singleFlight.equipmentTailNumber != null ? singleFlight.equipmentTailNumber : '';                
                                ev.Flight_Status__c = singleFlight.flightStatus != null ? singleFlight.flightStatus : '';  
                                ev.Operational_Carrier__c = singleFlight.marketingCarrier != null ? singleFlight.marketingCarrier : ''; 

                                ev.Scheduled_Arrival_UTC__c = ev.Flight_Number_Changed__c != true?GenericUtils.parseStringToGMT(singleFlight.scheduledArrivalUTCTimeStamp):ev.Scheduled_Arrival_UTC__c;
                                ev.Estimated_Arrival_UTC__c = GenericUtils.parseStringToGMT(singleFlight.estimatedArrivalUTCTimeStamp);
                                ev.Actual_Arrival_UTC__c = GenericUtils.parseStringToGMT(singleFlight.actualArrivalUTCTimeStamp);
                                ev.Scheduled_Depature_UTC__c = GenericUtils.parseStringToGMT(singleFlight.scheduledDepartureUTCTimeStamp);
                                ev.Estimated_Departure_UTC__c = GenericUtils.parseStringToGMT(singleFlight.estimatedDepartureUTCTimeStamp);
                                ev.Actual_Departure_UTC__c = GenericUtils.parseStringToGMT(singleFlight.actualDepartureUTCTimeStamp);

                                ev.ScheduledArrDateTime__c = ev.Flight_Number_Changed__c != true?singleFlight.scheduledArrivalLocalTimeStamp:ev.ScheduledArrDateTime__c;
                                ev.ActualDepaDateTime__c = singleFlight.actualDepartureLocalTimeStamp;
                                ev.ActualArriDateTime__c = singleFlight.actualArrivalLocalTimeStamp;
                                ev.EstimatedArrDateTime__c = singleFlight.estimatedArrivalLocalTimeStamp;
                                ev.EstimatedDepDateTime__c = singleFlight.estimatedDepartureLocalTimeStamp;
                                if(!String.isBlank(singleFlight.scheduledDepartureLocalTimeStamp)){
                                    ev.ScheduledDepTime__c =  singleFlight.scheduledDepartureLocalTimeStamp.substring(11,16); 
                                }

                                //update Diverted Port
                                System.debug(LoggingLevel.ERROR, singleFlight.airDiversion);
                                if(singleFlight.airDiversion != null 
                                        && singleFlight.airDiversion.unScheduledArrivalAirport != null){
                                    ev.Diverted_Port__c = singleFlight.airDiversion.unScheduledArrivalAirport;
                                }

                                ev.Flight_Info_Update_Status__c = '';
                                //turn off isOpen in order to auto close
                                ev.IsEventReopened__c = false;

                                //assign root cause
                                if(singleFlight.delay != null && singleFlight.delay.size() > 0){
                                    for(QCC_FlightInfoResponse.Delay delayReason : singleFlight.delay){
                                        if(delayDuration <= QCC_GenericUtils.stringToInteger(delayReason.delayDuration)){
                                            delayDuration = QCC_GenericUtils.stringToInteger(delayReason.delayDuration);
                                            ev.Primary_Root_Cause__c = QCC_GenericUtils.getDelayReason(delayReason.reasonCode , delayReason.shortDescription);
                                        }
                                    }
                                }
                            }
                            //Add to stop invoking mutiple times and sequence the Passenger API invoke
                            ev.TECH_FlightAPIInvoked__c = true;
                        }
                    }
                    system.debug('events##########'+events);                         
                    update events;
                    
                    output = 'Success: flight info updated';
                }else if(fir != null && fir.errorMessage != null && fir.errorMessage.equals('404-=-Not Found')){
                    //switch to Multi Sector Flight flow
                    system.debug('invoke multi Secotr Flight: ');        
                    QCC_MultiSectorFlightUpdateQueuable getMultiSectorFlightDetailJob = new QCC_MultiSectorFlightUpdateQueuable(listIds);
                    ID jobID = System.enqueueJob(getMultiSectorFlightDetailJob);
                }else if(fir != null && fir.errorMessage != null){
                    //Stop updating Flight Info if the Departure Info is not retrieved      
                    output = 'Flight schedule is not found';
                    for(event__c ev:events){
                        ev.Flight_Info_Update_Status__c = output;
                        //Add to stop invoking mutiple times and sequence the Passenger API invoke
                        ev.TECH_FlightAPIInvoked__c = true;
                    }
                    
                    update events;
                }
            }

        }catch(exception ex){
            isException = true;
            System.debug(LoggingLevel.ERROR, ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
            
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Event', 'QCC_UpdateEventFlightInfoController', 
                                    'updateforEvent', String.valueOf(''), String.valueOf(''),false,'', ex);

            output = 'Error: '+ ex.getMessage();
        }finally{
            if(isException){
                for(Event__c ev: events){
                    if( ev.TECH_FlightAPIInvoked__c != true){
                        ev.TECH_FlightAPIInvoked__c = true;
                    }
                }
                for (Event__c eve : events) {
                        system.debug('####### - '+eve.Id);
                    }
                update events;
            }
        }       
        
        return output;
    }

    public class flightRequest{
        public String departureDate{get;set;}
        public String departurePort{get;set;}
        public String arrivalPort{get;set;}
        public String flightNo{get;set;}
        public String carrier{get;set;}
        public flightRequest(){
            departurePort = '';
            departureDate = '';
            arrivalPort = '';
            flightNo = '';
            carrier = '';
        }
    }

    public class flightStatusRequest{
        public String departureFrom{get;set;}
        public String departureTo{get;set;}
        public String flightNo{get;set;}
        public flightStatusRequest(){
            departureFrom = '';
            departureTo = '';
            flightNo = '';
        }
    }
}