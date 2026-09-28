/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   Invokes Flight status API and Flight API  when Flight Tracker is created.
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
03-July-2018             Praveen Sampath        Initial Design

Test Classes: FlightTrackerTriggerTest 90%
-----------------------------------------------------------------------------------------------------------------------*/
public class QCC_FlightTrackerInformationAPI {
    
    /*----------------------------------------------------------------------------------------------      
    Method Name:    invokeFlightAPI
    Description:    Invoke Flight API in CAP and Map respective fields on Flight Tracker
    Parameter:      Flight Tracker       
    Return:         Flight_Tracker__c          
    ----------------------------------------------------------------------------------------------*/
    public static Flight_Tracker__c invokeFlightAPI(Flight_Tracker__c fltTracker) {
        QCC_FlightInfoResponse fir;
        try{
            String departureDate;
            String departurePort;
            String arrivalPort;
            String carrier;
            String flightNo;
            
            if(fltTracker.LocalScheduleDate__c != null){
                String formatStr = Datetime.newInstance(fltTracker.LocalScheduleDate__c, Time.newInstance(0,0,0,0)).format('yyyy-MM-dd');
                departureDate = formatStr;
            }
            
            if(!String.isBlank(fltTracker.Departure_Airport__c)){
                departurePort = fltTracker.Departure_Airport__c;
            }
            
            if(!String.isBlank(fltTracker.Arrival_Airport__c)){
                arrivalPort = fltTracker.Arrival_Airport__c;
            }
            
            if(!String.isBlank(fltTracker.Flight_Number__c)){
                flightNo = fltTracker.Flight_Number__c;
                carrier = fltTracker.Airline__c;
            }
            
            if(!String.isBlank(departureDate) && !String.isBlank(departurePort) && !String.isBlank(flightNo)){
                fir = QCC_InvokeCAPAPI.invokeFlightInfoAPI(departureDate, departurePort, flightNo, arrivalPort, carrier);
                System.debug(LoggingLevel.ERROR, fir);
                
                if(fir != null && fir.flights != null && fir.flights.size()>0){
                    for(QCC_FlightInfoResponse.flight singleFlight :  fir.flights){
                        if(fltTracker.Flight_Number__c.contains(singleFlight.marketingFlightNo)){
                            System.debug(LoggingLevel.ERROR, singleFlight);
                            fltTracker.Aircraft_Type__c = (singleFlight.equipmentTypeCode != null ? singleFlight.equipmentTypeCode : '') + (singleFlight.equipmentSubTypeCode != null ? ('-' + singleFlight.equipmentSubTypeCode) : '');
                            fltTracker.Aircraft_Registration__c = singleFlight.equipmentTailNumber != null ? singleFlight.equipmentTailNumber : '';
                            fltTracker.Operational_Carrier__c = singleFlight.marketingCarrier != null ? singleFlight.marketingCarrier : '';
                            fltTracker.Flight_Status__c = singleFlight.flightStatus != null ? singleFlight.flightStatus : '';  
                            fltTracker.Scheduled_Arrival_UTC__c = GenericUtils.parseStringToGMT(singleFlight.scheduledArrivalUTCTimeStamp);
                            fltTracker.Estimated_Arrival_UTC__c = fltTracker.Estimated_Arrival_UTC__c == null ? GenericUtils.parseStringToGMT(singleFlight.estimatedArrivalUTCTimeStamp) : fltTracker.Estimated_Arrival_UTC__c;
                            fltTracker.Actual_Arrival_UTC__c = fltTracker.Actual_Arrival_UTC__c == null ? GenericUtils.parseStringToGMT(singleFlight.actualArrivalUTCTimeStamp) : fltTracker.Actual_Arrival_UTC__c;
                            fltTracker.Scheduled_Depature_UTC__c = GenericUtils.parseStringToGMT(singleFlight.scheduledDepartureUTCTimeStamp);
                            fltTracker.Estimated_Departure_UTC__c = fltTracker.Estimated_Departure_UTC__c == null ? GenericUtils.parseStringToGMT(singleFlight.estimatedDepartureUTCTimeStamp) : fltTracker.Estimated_Departure_UTC__c;
                            fltTracker.Actual_Departure_UTC__c = GenericUtils.parseStringToGMT(singleFlight.actualDepartureUTCTimeStamp);
                            fltTracker.ScheduledArrDateTime__c = singleFlight.scheduledArrivalLocalTimeStamp;
                            fltTracker.ActualDepaDateTime__c = String.isBlank(fltTracker.ActualDepaDateTime__c) ? singleFlight.actualDepartureLocalTimeStamp : fltTracker.ActualDepaDateTime__c;
                            fltTracker.ActualArriDateTime__c = String.isBlank(fltTracker.ActualArriDateTime__c) ? singleFlight.actualArrivalLocalTimeStamp : fltTracker.ActualArriDateTime__c;
                            fltTracker.EstimatedArrDateTime__c = String.isBlank(fltTracker.EstimatedArrDateTime__c) ? singleFlight.estimatedArrivalLocalTimeStamp : fltTracker.EstimatedArrDateTime__c;
                            fltTracker.EstimatedDepDateTime__c = String.isBlank(fltTracker.EstimatedDepDateTime__c) ? singleFlight.estimatedDepartureLocalTimeStamp : fltTracker.EstimatedDepDateTime__c;
                            fltTracker.ScheduledDepTime__c =  String.isBlank(fltTracker.ScheduledDepTime__c) ? singleFlight.scheduledDepartureLocalTimeStamp : fltTracker.ScheduledDepTime__c;
                        }
                    }
                }
            }
        }catch(Exception ex){
            system.debug('Exception###'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Flight Movement API', 'QCC_FlightTrackerInformationAPI', 
                                     'invokeFlightAPI', String.valueOf(fir), String.valueOf(''), true,'', ex);
        }
        return fltTracker;
    }

    /*----------------------------------------------------------------------------------------------      
    Method Name:    invokeFlightStatus
    Description:    Invoke Flight Status API in CAP and Map respective fields on Flight Tracker
    Parameter:      Flight Tracker       
    Return:         Flight_Tracker__c          
    ----------------------------------------------------------------------------------------------*/
    public static Flight_Tracker__c invokeFlightStatus(Flight_Tracker__c objFt){
        QCC_FlightStatusAPIResponse flightInfo;
        try{
            String departureFrom;
            String departureTo;
            String originDate;
            if(objFt.Origin_Date__c != null){
                objFt.LocalScheduleDate__c = objFt.Origin_Date__c;
                String fillVal = '0';
                originDate = objFt.Origin_Date__c.Year()+'-'+String.valueOf(objFt.Origin_Date__c.Month()).leftPad(2,fillVal)+'-'+String.valueOf(objFt.Origin_Date__c.Day()).leftPad(2,fillVal);
                departureFrom = Datetime.newInstance(objFt.Origin_Date__c.addDays(-1), Time.newInstance(0,0,0,0)).format('yyyyMMddHHmm');
                departureTo = Datetime.newInstance(objFt.Origin_Date__c.addDays(1), Time.newInstance(23,59,0,0)).format('yyyyMMddHHmm');
                system.debug(departureFrom);
            }

            if(!String.isBlank(departureFrom) && !String.isBlank(departureTo) && !String.isBlank(objFt.Flight_Number__c)) 
            {
                //Invoking Flight status API
                flightInfo = QCC_InvokeCAPAPI.invokeFlightStatusAPI(departureFrom, departureTo, objFt.Flight_Number__c);
                if(flightInfo != Null){
                    if(flightInfo.flights != null && flightInfo.flights.size()>0){
                        Boolean isFlightFound = false;

                        //Looping all the flights from the response 
                        for(QCC_FlightStatusAPIResponse.flight flight :  flightInfo.flights){
                            
                            system.debug('flight$$$$$$'+flight);
                            system.debug('originDate$$$$$$'+originDate);
                            
                            String FlightNumberOriginDate;
                            //Find the correct flight CRM-9600 looping to find the primary flight
                            for (QCC_FlightStatusAPIResponse.FlightNumbers flightNumber : flight.flightNumbers) {
                                if (flightNumber.primary) {
                                    FlightNumberOriginDate = flightNumber.originDate;
                                    break;
                                }
                            }
                           
                            system.debug('FlightNumberOriginDate$$$$$$' + FlightNumberOriginDate);
                            
                            //When Origin Date matches, get all leg information
                            if(FlightNumberOriginDate == originDate){
                                isFlightFound = true;

                                //Loop the sector Information
                                List<QCC_FlightStatusAPIResponse.Sector> lstSector = flight.sectors;
                                //Single Leg
                                if(lstSector != Null && lstSector.size() == 1){
                                    //No logic update it as Single Sector
                                    objFt.TrackerType__c = 'Single Sector';
                                }
                                else if(lstSector != Null){ //Multi Leg
                                    for(QCC_FlightStatusAPIResponse.Sector sector: lstSector){
                                        if(sector.from_x == objFt.Departure_Airport__c && sector.to == objFt.Arrival_Airport__c){
                                            objFt.TrackerType__c = 'Multi Sector - First Leg';
                                        }
                                        else{
                                            //First Leg Information
                                            objFt.TrackerType__c = 'Multi Sector - Not First Leg';
                                        }
                                        break;
                                    }
                                    for(QCC_FlightStatusAPIResponse.Sector sector: lstSector){
                                        if(sector.from_x == objFt.Departure_Airport__c && sector.to == objFt.Arrival_Airport__c){
                                            String localDate = (sector.departure.scheduled).split('T')[0]+' 00:00:00';
                                            objFt.LocalScheduleDate__c = Date.valueOf(localDate);
                                        }
                                    }
                                }
                            }else{
                                objFt.TrackerType__c = 'No Match';
                            }
                            system.debug('isFlightFound$$$$$'+isFlightFound);
                            if(isFlightFound){
                                break;
                            }
                        }
                    }
                }

            }
        }catch(Exception ex){
            system.debug('Exception###'+ex);
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - Flight Movement API', 'QCC_FlightTrackerInformationAPI', 
                                     'invokeFlightStatus', String.valueOf(flightInfo), String.valueOf(''), true,'', ex);
        }
        return objFt;
    }
}