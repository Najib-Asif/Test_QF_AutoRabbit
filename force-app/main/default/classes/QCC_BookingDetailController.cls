public class QCC_BookingDetailController {
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        fetAllDetailonBooking
    Description:        Fetch Customer address Information from CAP system
    Parameter:          ID
    --------------------------------------------------------------------------------------*/ 
    @AuraEnabled
    public static QCC_BookingDetailWrapper fetchAllDetailonBooking(String pnr, String creationDate, String archivalData){
        try{
            Map<String, Airport_Code__c> airportCodesMap = new Map<String, Airport_Code__c>();
            
            for(Airport_Code__c codes: [SELECT Name, Freight_Station_Name__c, Freight_Airport_Country_Name__c FROM Airport_Code__c]) {
                airportCodesMap.put(codes.Name, codes);
            }
            
            String token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken');
            QCC_BookingSummaryWrapper.Bookings booking = new QCC_BookingSummaryWrapper.Bookings();
            booking.reloc = pnr;
            booking.creationDate = creationDate;
            booking.archivalData = archivalData;
            QCC_BookingDetailWrapper bookingInfo = new QCC_BookingDetailWrapper();
            QCC_PNRPassengerInfoWrapper passenger = QCC_InvokeCAPAPI.invokePNRPassengerInfoCAPAPI(booking.reloc, booking.creationDate, token, booking.archivalData);
            bookingInfo.pnrPassengerInfo = passenger;
            bookingInfo.pnrContactInfo = QCC_InvokeCAPAPI.invokePNRContactInfoCAPAPI(booking.reloc, booking.creationDate, token, booking.archivalData);
            bookingInfo.pnrFlightInfo = QCC_InvokeCAPAPI.invokePNRFlightInfoCAPAPI(booking.reloc, booking.creationDate, token, false, booking.archivalData);
                       
            Map<String, BookingDetailSingle> mapPNRBooking = new Map<String, BookingDetailSingle>();
            Map<String, List<FlightDisrupts>> mapPNRDisrupt = new Map<String, List<FlightDisrupts>>();
            bookingInfo.mapPNRDisrupt = mapPNRDisrupt;
            bookingInfo.mapPNRBooking  = mapPNRBooking;
            system.debug('bookingInfo.pnrFlightInfo$$$$$'+bookingInfo.pnrFlightInfo);
            if(bookingInfo.pnrFlightInfo != null) {
                String firstSegment = bookingInfo.pnrFlightInfo.booking.segments[0].segmentId;
                
                if(passenger != null) {
                    String firstPassenger = passenger.booking.passengers[0].passengerId;
                    String fName = passenger.booking.passengers[0].firstName;
                    String lName = passenger.booking.passengers[0].lastName;

                    bookingInfo.lstFlightPassenger = flightPassengerDetails(booking,fName, lName,firstPassenger, firstSegment, token, false);
                    bookingInfo.lstPassengerSSR = passengerSSRDetails(booking.reloc, booking.creationDate,fName,lName,firstPassenger, firstSegment, token, false, booking.archivalData);
                }
                
               createDisrupAndBookingMap(pnr, creationDate, bookingInfo, passenger, false);
            } else {
                BookingDetailSingle bookingDetail = new BookingDetailSingle();
                bookingDetail.PNR = pnr;
                if(passenger != null) {
                    bookingDetail.passengerCount = String.valueOf(passenger.booking.passengers.size());
                }
                
                bookingDetail.bookingDate = creationDate;
                bookingInfo.mapPNRBooking.put('NoFlights', bookingDetail);
                System.debug('@@@@@@'+bookingDetail);
            }

            bookingInfo.lstPassengerAncillary = ancillaryDetails(pnr, creationDate, token, archivalData);
            
            QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
            system.debug('bookingInfo1111111111'+bookingInfo);
            return bookingInfo;
        }catch(Exception ex){
            system.debug('Exception###'+ex); 
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - CAP Booking', 'QCC_BookingDetailController', 
                                    'fetchAllDetailonBooking', '', '', false,'', ex);
            
        }
        return null;    
    }

    @AuraEnabled
    public static QCC_BookingDetailWrapper fetchBookingHistory(String bookingInfoStr, String pnr, String creationDate){
        try{
            QCC_BookingDetailWrapper bookingInfo = (QCC_BookingDetailWrapper) Json.deserialize(bookingInfoStr, QCC_BookingDetailWrapper.class);
            system.debug('bookingInfo1111111111'+bookingInfo);
            Map<String, Airport_Code__c> airportCodesMap = new Map<String, Airport_Code__c>();
            List<Airport_Code__c> airportCodes = [SELECT Name, Freight_Station_Name__c, Freight_Airport_Country_Name__c FROM Airport_Code__c];
            
            for(Airport_Code__c codes: airportCodes) {
                airportCodesMap.put(codes.Name, codes);
            }

            String token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken');
            
            // Added by Purushotham to retrieve History
            bookingInfo.pnrFlightHistInfo = QCC_InvokeCAPAPI.invokePNRFlightInfoCAPAPI(pnr, creationDate, token, true, 'true');
            system.debug('History = '+bookingInfo.pnrFlightHistInfo);
            
            
            if(bookingInfo.pnrFlightHistInfo != null) {
                 system.debug('bookingInfo = '+bookingInfo);
                createDisrupAndBookingMap(pnr, creationDate, bookingInfo, bookingInfo.pnrPassengerInfo, true);
            }
        
            system.debug('bookingInfo###########'+bookingInfo);
            QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
            
            return bookingInfo;
        }catch(Exception ex){
            system.debug('Exception###'+ex); 
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - CAP Booking', 'QCC_BookingDetailController', 
                                    'fetchBookingHistory', '', '', false,'', ex);
            
        }
        return null;
    }


    /*--------------------------------------------------------------------------------------      
    Method Name:        showDynamicBooking
    Description:        Fetch Customer address Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/ 
    @AuraEnabled
    public static QCC_BookingDetailWrapper showDynamicBooking(String pnr, String creationDate, String passengerId, String segmentId, String firstName, String lastName, Boolean isHistory, String archivalData){   
        try{
            String token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken');
            QCC_BookingSummaryWrapper.Bookings booking = new QCC_BookingSummaryWrapper.Bookings();
            booking.reloc = pnr;
            booking.creationDate = creationDate;
            booking.archivalData = archivalData;
            
            system.debug('firstName####'+firstName);
            system.debug('lastName#####'+lastName);
            QCC_BookingDetailWrapper bookingInfo = new QCC_BookingDetailWrapper();
            if(passengerId != null) {
                bookingInfo.lstPassengerSSR = passengerSSRDetails(booking.reloc, booking.creationDate,firstName,lastName,passengerId, segmentId, token,isHistory, booking.archivalData);
                bookingInfo.lstFlightPassenger = flightPassengerDetails(booking,firstName,lastName,passengerId, segmentId, token, isHistory);
            }
            
            QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
            return bookingInfo;
        }catch(Exception ex){
            system.debug('Exception###'+ex); 
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - CAP Booking', 'QCC_BookingDetailController', 
                                    'showDynamicBooking', '', '', false,'', ex);
            
        }
        return null;
    }


    /*--------------------------------------------------------------------------------------      
    Method Name:        addValueToCase
    Description:        Fetch Customer address Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String addValueToCase(String caseId, String pnr, String createdDate, String archivalData, String segment,  String passenger, String ssr, String legStatus){
        
        
        try{
            List<Case> cs = [SELECT Id, OwnerId FROM Case WHERE Id =: caseId LIMIT 1];
            if(cs != null && String.valueOf(cs[0].OwnerId).startsWith('00G')) {
                return 'InQueue';
            }
            system.debug('Segment#######'+segment);
            system.debug('passenger#######'+passenger);
            system.debug('ssr########'+ssr);
            system.debug('legStatus###########'+legStatus);
            Map<String, Airport_Code__c> airportCodesMap = new Map<String, Airport_Code__c>();
           
            for(Airport_Code__c codes: [SELECT Name, Freight_Station_Name__c, Freight_Airport_Country_Name__c FROM Airport_Code__c]) {
                airportCodesMap.put(codes.Name, codes);
            }
            
            QCC_PNRFlightInfoWrapper.Segments segmentWrap = (QCC_PNRFlightInfoWrapper.Segments) Json.deserialize(segment, QCC_PNRFlightInfoWrapper.Segments.class);
            
            
            
            Case objCase = new Case();
            objCase.Id = caseId;
            objCase.Booking_PNR__c = pnr;
            objCase.TECH_bookingCreationDate__c = createdDate;
            objCase.TECH_bookingArchivalData__c = archivalData;
            objCase.TECH_BookingSegmentId__c = segmentWrap.segmentId;
            objCase.TECH_BookingSegmentTattoo__c = segmentWrap.segmentTattoo;
            String airlines = CustomSettingsUtilities.getAirlineCarrierCodes(segmentWrap.operatingCarrierAlphaCode);
            objCase.Airline__c = airlines != null ? airlines : 'Non partner Airline';
            objCase.Flight_Number__c = segmentWrap.operatingFlightNumber;
            objCase.Flight_Number_With_Code__c = segmentWrap.operatingCarrierAlphaCode + segmentWrap.operatingFlightNumber.replaceFirst('^0+','');
            objCase.Departure_Airport_Code__c = segmentWrap.departureAirportCode;
            objCase.Arrival_Airport_Code__c = segmentWrap.arrivalAirportCode;
            if(airportCodesMap != null) {
                if(airportCodesMap.containsKey(segmentWrap.departureAirportCode)) {
                    objCase.Departure_Airport__c = airportCodesMap.get(segmentWrap.departureAirportCode).Freight_Station_Name__c;
                    objCase.Departure_City__c = airportCodesMap.get(segmentWrap.departureAirportCode).Freight_Station_Name__c;
                    objCase.Departure_Country__c = airportCodesMap.get(segmentWrap.departureAirportCode).Freight_Airport_Country_Name__c;
                }
                
                if(airportCodesMap.containsKey(segmentWrap.arrivalAirportCode)) {
                    objCase.Arrival_Airport__c = airportCodesMap.get(segmentWrap.arrivalAirportCode).Freight_Station_Name__c;
                    objCase.Arrival_City__c = airportCodesMap.get(segmentWrap.arrivalAirportCode).Freight_Station_Name__c;
                    objCase.Arrival_Country__c = airportCodesMap.get(segmentWrap.arrivalAirportCode).Freight_Airport_Country_Name__c;
                }
            }
            
            if(String.isNotBlank(segmentWrap.departureLocalDate) && String.isNotBlank(segmentWrap.departureLocalTime)) {
                objCase.Departure_Date_Time__c         = segmentWrap.departureLocalDate+' '+segmentWrap.departureLocalTime;
            }
            
            objCase.Departure_UTC_Date_Time__c     = QCC_GenericUtils.convertStringtoDateTime(segmentWrap.departureUTCDate,segmentWrap.departureUTCTime);
            
            if(String.isNotBlank(segmentWrap.actualDepartureLocalDate) && String.isNotBlank(segmentWrap.actualDepartureLocalTime)) {
                objCase.Actual_Departure_Date_Time__c  = segmentWrap.actualDepartureLocalDate+' '+segmentWrap.actualDepartureLocalTime;
            }

            if(String.isNotBlank(segmentWrap.arrivalLocalDate) && String.isNotBlank(segmentWrap.arrivalLocalTime)) {
                objCase.Arrival_Date_Time__c           = segmentWrap.arrivalLocalDate+' '+segmentWrap.arrivalLocalTime;
            }
            
            objCase.Arrival_UTC_Date_Time__c       = QCC_GenericUtils.convertStringtoDateTime(segmentWrap.arrivalUTCDate,segmentWrap.arrivalUTCTime);
            
            if(String.isNotBlank(segmentWrap.actualArrivalLocalDate) && String.isNotBlank(segmentWrap.actualArrivalLocalTime)) {
                objCase.Actual_Arrival_Date_Time__c    = segmentWrap.actualArrivalLocalDate+ ' ' + segmentWrap.actualArrivalLocalTime;
            }

            objCase.Sector__c                      = segmentWrap.departureAirportCode + ' ' + segmentWrap.arrivalAirportCode;
            objCase.Flight_Type_Code__c            = CustomSettingsUtilities.getConfigDataMap('QCC_'+segmentWrap.flightTypeCode);
            objCase.Aircraft_Type_Code__c          = segmentWrap.aircraftTypeCode;
            objCase.Segment_Id__c                  = segmentWrap.segmentId;
            
            String flightSegmentsTable = '<html><table border="1" width="100%">';
            flightSegmentsTable = flightSegmentsTable + '<thead><tr><th>Flight Number</th><th>Departure Date</th><th>Departure Port</th><th>Arrival Port</th></tr></thead>';
            flightSegmentsTable = flightSegmentsTable + '<tbody><tr><td>'+segmentWrap.operatingCarrierAlphaCode+segmentWrap.operatingFlightNumber.replaceFirst('^0+','')+'</td>';
            flightSegmentsTable = flightSegmentsTable + '<td>'+segmentWrap.departureLocalDate+'</td>';
            flightSegmentsTable = flightSegmentsTable + '<td>'+segmentWrap.departureAirportCode+'</td>';
            flightSegmentsTable = flightSegmentsTable + '<td>'+segmentWrap.arrivalAirportCode+'</td></tr></tbody></table></html>';
            objCase.Flight_Segments__c = flightSegmentsTable;
            objCase.Delay_Reason__c = '';
            if(segmentWrap.disrupts != null && segmentWrap.disrupts.size() > 0) {
                for(QCC_PNRFlightInfoWrapper.Disrupts disrupt: segmentWrap.disrupts) {
                    
                    if(disrupt.type.equalsIgnoreCase('DELAY') && disrupt.details.size() > 0) {
                        objCase.Flight_Delay__c = true;
                        for(QCC_PNRFlightInfoWrapper.Detail detail: disrupt.details) {
                            if(detail.shortDescription != 'WEATHER' && detail.shortDescription != 'WEA') {
                                objCase.Delay_Reason__c = 'Operational';
                                break;
                            } else {
                                objCase.Delay_Reason__c = 'Weather';
                            }
                        }
                    }
                    else if(disrupt.type.equalsIgnoreCase('CANCELLED')) {
                        objCase.Flight_Cancellation__c = true;
                    }
                }
            }
            //'Delay_Reason__c': 
            System.debug('passenger = '+passenger);
            if(passenger != null && passenger != 'null') {
                QCC_PNRPassengerInfoWrapper.Passengers passengerWrap = (QCC_PNRPassengerInfoWrapper.Passengers) Json.deserialize(passenger, QCC_PNRPassengerInfoWrapper.Passengers.class);
                objCase.Passenger_Id__c = passengerWrap.passengerId;
                objCase.Passenger_First_Name__c = passengerWrap.firstName;
                objCase.Passenger_Last_Name__c = passengerWrap.lastName;
                objCase.ABN_Number__c = passengerWrap.smeId;
                objCase.Qantas_Corporate_Identifier__c = passengerWrap.corpId;
            }
            
            if(ssr != null && ssr != 'null') {
                System.debug('ssr = '+ssr);
                //SelectedSSR ssrWrap = (SelectedSSR) json.deserialize(ssr.substringBetween('[',']') , SelectedSSR.class);
                //MyClass[] lstFilters = (List<MyClass>)System.JSON.deserializeStrict(strFilters, List<MyClass>.Class);
                PassengerSSR[] ssrWrap = (List<PassengerSSR>)System.JSON.deserializeStrict(ssr , List<PassengerSSR>.class);
                System.debug('ssrWrap = '+ssrWrap);
                for(PassengerSSR pSSR: ssrWrap) {
                    if(objCase.Specific_Needs__c != null)
                        objCase.Specific_Needs__c += ';'+pSSR.description;
                    else
                        objCase.Specific_Needs__c = pSSR.description;
                    
                }
                //objCase.Specific_Needs__c = ssrWrap.description;
            }
            
            if(legStatus != null && legStatus != 'null') {
                passengerFlightDetail legWrap = (passengerFlightDetail) json.deserialize(legStatus, passengerFlightDetail.class);
                objCase.Cabin_Class__c = legWrap.cabinClass;
                objCase.Passenger_Segment_Id__c = legWrap.passengerSegmentId;
                objCase.Seat_Number__c = legWrap.seatNumber;
                String flightLegFlownTable = '<html><table border="1" width="100%">';
                flightLegFlownTable = flightLegFlownTable + '<thead><tr><th>Departure Airport</th><th>Arrival Airport</th><th>Status</th></tr></thead><tbody>';
                
                flightLegFlownTable = flightLegFlownTable + '<tr><td>'+legWrap.depaturePort+'</td>';
                flightLegFlownTable = flightLegFlownTable + '<td>'+legWrap.arrivalPort+'</td>';
                
                if(legWrap.boardingStatus == 'Not Boarded') {
                    flightLegFlownTable = flightLegFlownTable + '<td>Not Flown</td></tr>';
                    objCase.Check_In_Status__c = 'Not Boarded';
                } else if(legWrap.boardingStatus == 'Boarded') {
                    flightLegFlownTable = flightLegFlownTable + '<td>Flown</td></tr>';
                    objCase.Check_In_Status__c = 'Boarded';
                }
                
                flightLegFlownTable = flightLegFlownTable + '</tbody></table></html>';
                objCase.Flight_Leg_Flown_Statuses__c = flightLegFlownTable;
            }
            
            update objCase;
            return 'true';
        }catch(Exception ex){
            system.debug('Exception###'+ex); 
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'QCC - CAP Booking', 'QCC_BookingDetailController', 
                                    'addValueToCase', '', '', false,'', ex);
            // Added by Purushotham for Remediation hotfix on 18 SEP 2018-- START
            if(ex.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                ex.setMessage(ex.getMessage().substringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,').removeEnd(': []').unescapeHtml4());
            }
            AuraHandledException ltEX = new AuraHandledException(ex.getMessage());
            throw ltEX;
            // Added by Purushotham for Remediation hotfix on 18 SEP 2018 -- END
           // return 'false';
        }
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        flightPassengerDetails
    Description:        Fetch Customer address Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public static List<PassengerFlightDetail> flightPassengerDetails(QCC_BookingSummaryWrapper.Bookings booking,
                                                                     String fName, String lName,
                                                                     String firstPassenger, String firstSegment, String token, 
                                                                     Boolean isHistory)
    {
        
        QCC_PNRLegStatusInfoWrapper legStatus = QCC_InvokeCAPAPI.invokePNRLegStatusInfoCAPAPI(booking.reloc, booking.creationDate, firstPassenger, firstSegment, token, isHistory, booking.archivalData);
        List<PassengerFlightDetail> lstFlightPassenger = new List<PassengerFlightDetail>();
        if(legStatus != null && legStatus.booking != null && legStatus.booking.passengerFlightStatus != null) {
            List<QCC_PNRLegStatusInfoWrapper.PassengerFlightStatus> lstPassengerFlight = legStatus.booking.passengerFlightStatus;
            for(QCC_PNRLegStatusInfoWrapper.PassengerFlightStatus passengerFlight: lstPassengerFlight){
                List<QCC_PNRLegStatusInfoWrapper.Leg> lstLeg = passengerFlight.leg;
                if(lstLeg != Null){
                    for(QCC_PNRLegStatusInfoWrapper.Leg leg: lstLeg){
                        PassengerFlightDetail pasFlight = new PassengerFlightDetail();
                        pasFlight.firstName = fName;
                        pasFlight.lastName = lName;
                        pasFlight.depaturePort = leg.originAirportCode;
                        pasFlight.arrivalPort = leg.destinationAirportCode;
                        pasFlight.passengerSegmentId = passengerFlight.passengerSegmentId;
                        
                        // Purushotham -- Start
                        if(passengerFlight.bookedCabinClass == 'P' || passengerFlight.bookedCabinClass == 'p') {
                            pasFlight.cabinClass = 'First';
                        } else if(passengerFlight.bookedCabinClass == 'J' || passengerFlight.bookedCabinClass == 'j') {
                            pasFlight.cabinClass = 'Business';
                        } else if(passengerFlight.bookedCabinClass == 'W' || passengerFlight.bookedCabinClass == 'w') {
                            pasFlight.cabinClass = 'Premium Economy';
                        } else if(passengerFlight.bookedCabinClass == 'Y' || passengerFlight.bookedCabinClass == 'y') {
                            pasFlight.cabinClass = 'Economy';
                        }
                        
                        if(leg.boardingStatusCode == 'BDD') {
                            pasFlight.boardingStatus = 'Boarded';
                        } else if(leg.boardingStatusCode == 'NBD') {
                            pasFlight.boardingStatus = 'Not Boarded';
                        }
                        // Purushotham -- End
                        
                        pasFlight.seatNumber = leg.seatNumber;
                        pasFlight.checkinBaggage = leg.checkinBag == Null?0:leg.checkinBag.size();
                        pasFlight.legId = leg.legId;
                        lstFlightPassenger.add(pasFlight);
                    }
                }
            }
        }
        return lstFlightPassenger;
    }
    
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        passengerSSRDetails
    Description:        Fetch Customer address Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public static List<PassengerSSR> passengerSSRDetails(String pnr,String creationDate,String fName ,String lName ,String passengerId,String segmentId,String token, Boolean isHistory, String archivalData){
        QCC_PNRSSRInfoWrapper pnrSSR;
        pnrSSR = QCC_InvokeCAPAPI.invokePNRSSRInfoCAPAPI(pnr, creationDate, passengerId, segmentId, token, isHistory, archivalData);        

        List<PassengerSSR> lstPassengerSSR = new List<PassengerSSR>();
        if(pnrSSR != null && pnrSSR.booking != null && pnrSSR.booking.ServiceRequest != null) {
            
            for(QCC_PNRSSRInfoWrapper.ServiceRequest serviceReq: pnrSSR.booking.ServiceRequest){
                if(serviceReq.loyalty != null) {
                    for(QCC_PNRSSRInfoWrapper.Loyalty loyalty: serviceReq.loyalty){
                        String codeReq = CustomSettingsUtilities.getBookingCodeMapping(loyalty.requestStatusCode);
                        lstPassengerSSR.add(createSSR(fName,lName,'Loyalty',loyalty.serviceKeywordCode,codeReq,
                                                      'Y',loyalty.loyaltyRequestId));
                        
                    }
                }
                
                if(serviceReq.meal != null) {
                    for(QCC_PNRSSRInfoWrapper.Meal meal: serviceReq.meal){
                        String codeReq = CustomSettingsUtilities.getBookingCodeMapping(meal.requestStatusCode);
                        lstPassengerSSR.add(createSSR(fName,lName,'Meal',meal.serviceKeywordCode,codeReq,
                                                      'Y',meal.mealRequestId));
                    }
                }
                
                if(serviceReq.seat != null) {
                    for(QCC_PNRSSRInfoWrapper.Seat seat: serviceReq.seat){
                        String codeReq = CustomSettingsUtilities.getBookingCodeMapping(seat.requestStatusCode);
                        PassengerSSR pasFlight = createSSR(fName,lName,'Seat',seat.serviceKeywordCode,codeReq,
                                                           'Y',seat.seatRequestId);
                        if(seat.specialAssistancePassengerTypeCode == 'I') {
                            pasFlight.characteristics = 'Infant';
                        }else{
                            pasFlight.characteristics = seat.specialAssistancePassengerTypeCode;
                        }
                        lstPassengerSSR.add(pasFlight);
                        
                    }
                }
                
                if(serviceReq.bag != null) {
                    for(QCC_PNRSSRInfoWrapper.Bag bag: serviceReq.bag){
                        
                        String codeReq = CustomSettingsUtilities.getBookingCodeMapping(bag.requestStatusCode);
                        lstPassengerSSR.add(createSSR(fName,lName,'Bag',bag.serviceKeywordCode,codeReq,
                                                      'Y',bag.bagRequestId));
                        
                    }
                }
                
                if(serviceReq.document != null) {
                    for(QCC_PNRSSRInfoWrapper.Document document: serviceReq.document){
                        system.debug('document#########'+document);
                        system.debug('CustomSettingsUtilities.getBookingCodeMapping(document.requestStatusCode)############'+CustomSettingsUtilities.getBookingCodeMapping(document.requestStatusCode));
                        String codeReq = CustomSettingsUtilities.getBookingCodeMapping(document.requestStatusCode);
                        lstPassengerSSR.add(createSSR(fName,lName,'Document',document.serviceKeywordCode,codeReq,
                                                      'Y',document.docRequestId));
                    }
                }
                
                if(serviceReq.other != null) {
                    for(QCC_PNRSSRInfoWrapper.Other other: serviceReq.other){
                        String codeReq = CustomSettingsUtilities.getBookingCodeMapping(other.requestStatusCode);
                        lstPassengerSSR.add(createSSR(fName,lName,'Other',other.serviceKeywordCode,codeReq,
                                                      other.chargeableIndicator,other.otherRequestId));
                    }
                }
            }
        }
        
        
        return lstPassengerSSR; 
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        createMap
    Description:        Add Custom Map
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public static QCC_BookingDetailWrapper createDisrupAndBookingMap(String pnr,String creationDate, QCC_BookingDetailWrapper bookingInfo, QCC_PNRPassengerInfoWrapper passenger, Boolean isHistory){

        Map<String, BookingDetailSingle> mapPNRBooking = new Map<String, BookingDetailSingle>();
        Map<String, List<FlightDisrupts>> mapPNRDisrupt = new Map<String, List<FlightDisrupts>>();
        Map<String, Airport_Code__c> airportCodesMap = new Map<String, Airport_Code__c>();
           
        for(Airport_Code__c codes: [SELECT Name, Freight_Station_Name__c, Freight_Airport_Country_Name__c FROM Airport_Code__c]) {
            airportCodesMap.put(codes.Name, codes);
        }
        List<QCC_PNRFlightInfoWrapper.Segments> segments = new List<QCC_PNRFlightInfoWrapper.Segments>();
        if(isHistory) {
            segments = bookingInfo.pnrFlightHistInfo.booking.segments;
        } else{
            segments = bookingInfo.pnrFlightInfo.booking.segments;
        }
        for(QCC_PNRFlightInfoWrapper.Segments segment: segments){
            BookingDetailSingle bookingDetail = new BookingDetailSingle();
            bookingDetail.PNR = pnr;
            //bookingDetail.passengerCount = '40';
            if(passenger != null) {
                bookingDetail.passengerCount = String.valueOf(passenger.booking.passengers.size());
            }
            
            bookingDetail.bookingDate = creationDate;
            String airlines = String.isNotBlank(segment.operatingCarrierAlphaCode) ? CustomSettingsUtilities.getAirlineCarrierCodes(segment.operatingCarrierAlphaCode) : '';
            bookingDetail.airLine = airlines != null ? airlines : 'Non partner Airline';
            segment.airline = bookingDetail.airLine;
            String airlinesMarket = String.isNotBlank(segment.marketingCarrierAlphaCode) ? CustomSettingsUtilities.getAirlineCarrierCodes(segment.marketingCarrierAlphaCode) : '';
            bookingDetail.airLineMarket = airlinesMarket != null ? airlinesMarket : 'Non partner Airline';
            segment.marketingAirline = bookingDetail.airLineMarket;
            bookingDetail.flightNumber = segment.operatingFlightNumber;
            bookingDetail.flightNumberMarket = segment.marketingFlightNumber;
            bookingDetail.depaturePort = segment.departureAirportCode;
            bookingDetail.arrivalPort = segment.arrivalAirportCode;
            
            if(airportCodesMap != null) {
                if(airportCodesMap.containsKey(segment.departureAirportCode)) {
                    segment.departureAirport = airportCodesMap.get(segment.departureAirportCode).Freight_Station_Name__c;
                    System.debug('Dep Airport = '+segment.departureAirport);
                    segment.departureCity = airportCodesMap.get(segment.departureAirportCode).Freight_Station_Name__c;
                    segment.departureCountry = airportCodesMap.get(segment.departureAirportCode).Freight_Airport_Country_Name__c;
                }
                
                if(airportCodesMap.containsKey(segment.arrivalAirportCode)) {
                    segment.arrivalAirport = airportCodesMap.get(segment.arrivalAirportCode).Freight_Station_Name__c;
                    segment.arrivalCity = airportCodesMap.get(segment.arrivalAirportCode).Freight_Station_Name__c;
                    segment.arrivalCountry = airportCodesMap.get(segment.arrivalAirportCode).Freight_Airport_Country_Name__c;
                }
            }
            
            if(String.isNotBlank(segment.departureLocalDate) && String.isNotBlank(segment.departureLocalTime)) {
                bookingDetail.depatureDateTime = segment.departureLocalDate+' '+segment.departureLocalTime;
            }
            if(String.isNotBlank(segment.arrivalLocalDate) && String.isNotBlank(segment.arrivalLocalTime)) {
                bookingDetail.arrivalDateTime = segment.arrivalLocalDate +' '+segment.arrivalLocalTime;
            }                
            if(String.isNotBlank(segment.actualDepartureLocalDate) && String.isNotBlank(segment.actualDepartureLocalTime)) {
                bookingDetail.actualDepatureDateTime = segment.actualDepartureLocalDate +' '+segment.actualDepartureLocalTime;
            }
            if(String.isNotBlank(segment.actualArrivalLocalDate) && String.isNotBlank(segment.actualArrivalLocalTime)) {
                bookingDetail.actualArrivalDateTime = segment.actualArrivalLocalDate +' '+segment.actualArrivalLocalTime;
            }
            if(String.isNotBlank(segment.departureUTCDate) && String.isNotBlank(segment.departureUTCTime)) {
                bookingDetail.departureUTCDateTime = segment.departureUTCDate +' '+segment.departureUTCTime;
            }
            if(String.isNotBlank(segment.arrivalUTCDate) && String.isNotBlank(segment.arrivalUTCTime)) {
                bookingDetail.arrivalUTCDateTime = segment.arrivalUTCDate +' '+segment.arrivalUTCTime;
            }
            
            if(String.isNotBlank(segment.departureLocalDate) && String.isNotBlank(segment.departureLocalTime)) {
                segment.departureDateTime         = segment.departureLocalDate+' '+segment.departureLocalTime;
            }
            
            segment.departureUTCDateTime      = QCC_GenericUtils.convertStringtoDateTime(segment.departureUTCDate,segment.departureUTCTime);

            if(String.isNotBlank(segment.actualDepartureLocalDate) && String.isNotBlank(segment.actualDepartureLocalTime)) {
                segment.actualDepartureDateTime   = segment.actualDepartureLocalDate+' '+segment.actualDepartureLocalTime;
            }

            if(String.isNotBlank(segment.arrivalLocalDate) && String.isNotBlank(segment.arrivalLocalTime)) {
                segment.arrivalDateTime           = segment.arrivalLocalDate+' '+segment.arrivalLocalTime;
            }
            
            segment.arrivalUTCDateTime        = QCC_GenericUtils.convertStringtoDateTime(segment.arrivalUTCDate,segment.arrivalUTCTime);
            
            if(String.isNotBlank(segment.actualArrivalLocalDate) && String.isNotBlank(segment.actualArrivalLocalTime)) {
                segment.actualArrivalDateTime     = segment.actualArrivalLocalDate+' '+segment.actualArrivalLocalTime;
            }
            
            String key = isHistory? segment.segmentTattoo: segment.segmentId;
            bookingInfo.mapPNRBooking.put(key, bookingDetail);
            List<FlightDisrupts> lstFlightDisrupts = new List<FlightDisrupts>();
            if(segment.disrupts != null) {
                for(QCC_PNRFlightInfoWrapper.Disrupts disrupt: segment.disrupts){
                   if(disrupt.details == null) {
                        FlightDisrupts flightDisrupt = new FlightDisrupts();
                        flightDisrupt.departureLocalDate = segment.departureLocalDate;
                        flightDisrupt.depaturePort = disrupt.legDepartureAirportCode;
                        if(String.isNotBlank(disrupt.unScheduledArrivalAirport)) {
                            flightDisrupt.arrivalPort = disrupt.unScheduledArrivalAirport;
                        }
                        else{
                            flightDisrupt.arrivalPort = disrupt.legArrivalAirportCode;
                        }
                        flightDisrupt.type = disrupt.type;
                        lstFlightDisrupts.add(flightDisrupt);
                    }
                    if(disrupt.details != null) {
                        for(QCC_PNRFlightInfoWrapper.Detail detail: disrupt.details){
                            FlightDisrupts flightDisrupt = new FlightDisrupts();
                            flightDisrupt.departureLocalDate = segment.departureLocalDate;
                            flightDisrupt.depaturePort = disrupt.legDepartureAirportCode;
                            if(String.isNotBlank(disrupt.unScheduledArrivalAirport)) {
                                flightDisrupt.arrivalPort = disrupt.unScheduledArrivalAirport;
                            }
                            else{
                                flightDisrupt.arrivalPort = disrupt.legArrivalAirportCode;
                            }
                            flightDisrupt.type = disrupt.type;
                            flightDisrupt.reason = detail.shortDescription;
                            flightDisrupt.duration = detail.delayDuration;
                            flightDisrupt.key = disrupt.type+''+detail.reasonCode;
                            lstFlightDisrupts.add(flightDisrupt);
                        }
                    }
                }
            }
            
           bookingInfo.mapPNRDisrupt.put(key, lstFlightDisrupts);
        }

        system.debug('bookingInfo##########'+bookingInfo);
        return bookingInfo;
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        createSSR
    Description:        Fetch Customer address Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public static List<passengerAncillary> ancillaryDetails(String pnr, String creationDate, String token, String archivalData){
        List<passengerAncillary> lstPassengerAncillary = new List<passengerAncillary>();
        QCC_PNRAncillaryInfoWrapper ancillary = QCC_InvokeCAPAPI.invokePNRAncillaryInfoCAPAPI(pnr, creationDate, token, archivalData);
        System.debug('ancillary = '+ancillary);
        if(ancillary != null) {
            
            if(ancillary.insurance != Null){
                for(QCC_PNRAncillaryInfoWrapper.Insurance insurance: ancillary.insurance){
                    String status = CustomSettingsUtilities.getBookingCodeMapping(insurance.segmentStatusCode);
                    lstPassengerAncillary.add(createpassengerAncillary('Insurance', insurance.policyCode, status, 'Y', 
                                                                        insurance.totalPremiumAmount, 
                                                                        insurance.insuranceConfirmationNumber));
                }
            }
            
            if(ancillary.accommodation != Null){
                for(QCC_PNRAncillaryInfoWrapper.Accommodation accommodation: ancillary.accommodation){
                    
                    String status = CustomSettingsUtilities.getBookingCodeMapping(accommodation.segmentStatusCode);
                    passengerAncillary passAnc = createpassengerAncillary('Accommodation', accommodation.segmentSourceCode, 
                                                                           status, 'Y', '',  accommodation.bookingConfirmationNumber);
                    if(accommodation.tariff != Null){
                        for(QCC_PNRAncillaryInfoWrapper.Tariff tariff: accommodation.tariff){
                            if(tariff.ratePlanCode  == 'DY')
                                passAnc.Amount = tariff.rateAmount+' '+tariff.ccyCode;
                        }
                    }
                    lstPassengerAncillary.add(passAnc);
                }
            }
            
            if(ancillary.vehicle != Null){
                for(QCC_PNRAncillaryInfoWrapper.Vehicle vehicle: ancillary.vehicle){
                    
                    String status = CustomSettingsUtilities.getBookingCodeMapping(vehicle.segmentStatusCode);
                    passengerAncillary passAnc = createpassengerAncillary('Car Hire', vehicle.segmentSourceCode, status, 'Y', '',  
                                                                          vehicle.bookingConfirmationNumber);
                   
                    if(vehicle.tariff != Null){
                        for(QCC_PNRAncillaryInfoWrapper.Tariff tariff: vehicle.tariff){
                            passAnc.Amount = tariff.rateAmount+' '+tariff.ccyCode;
                        }
                    }
                    lstPassengerAncillary.add(passAnc);
                }
            } 
            
            if(ancillary.other != Null){
                for(QCC_PNRAncillaryInfoWrapper.Other other: ancillary.other){
                    String status;
                    if(String.isNotBlank(other.requestStatusCode)) {
                        status = CustomSettingsUtilities.getBookingCodeMapping(other.requestStatusCode);    
                    }
                    String type = 'Other';
                    if(other.serviceKeywordCode == 'STPC') {
                        type = 'Dubai Connect';
                    } else if(other.serviceKeywordCode == 'CFDA' || other.serviceKeywordCode == 'CFDD') {
                        type = 'Chauffeur Drive';
                    }
                    
                    lstPassengerAncillary.add(createpassengerAncillary(type, other.serviceSourceCode, status, 
                                                                        other.chargeableIndicator, '', other.additionalText));
                }
            }
        }
        return lstPassengerAncillary;
    }

    /*--------------------------------------------------------------------------------------      
    Method Name:        createpassengerAncillary
    Description:        
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public static passengerAncillary createpassengerAncillary(String type, String description, String status, 
                                                              String chargeable, String amount, String ref)
    {
        passengerAncillary passAnc = new passengerAncillary();
        passAnc.type = type;
        passAnc.description = description;
        passAnc.status = status;
        passAnc.Chargeable = chargeable;
        passAnc.Amount = amount;
        passAnc.ref = ref;
        return passAnc;
    }


    /*--------------------------------------------------------------------------------------      
    Method Name:        createSSR
    Description:        Fetch Customer address Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public static PassengerSSR createSSR(String fName, String lName, String type, String description, String requestCode,
                                         String chargeable, String keyID)
    {
        
        PassengerSSR pasFlight = new PassengerSSR();
        pasFlight.firstName   = fName;
        pasFlight.lastName    = lName;
        pasFlight.type        = type;
        pasFlight.description = description;
        pasFlight.status      = requestCode;
        pasFlight.chargeable  = chargeable;
        pasFlight.keyID       = keyID;
        return pasFlight;
        
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        lookupCustomer
    Description:        Fetch Customer Information from CAP system
    Parameter:          String
    --------------------------------------------------------------------------------------*/
    @AuraEnabled
    public static String lookupCustomer(String capId) {
        return QCC_LookupFrequentFlyerController.lookupCustomer('', '', capId);
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        QCC_BookingDetailWrapper
    Description:        Fetch Customer address Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public class QCC_BookingDetailWrapper{
        @AuraEnabled public QCC_PNRContactInfoWrapper pnrContactInfo;
        @AuraEnabled public QCC_PNRPassengerInfoWrapper pnrPassengerInfo;
        @AuraEnabled public QCC_PNRFlightInfoWrapper pnrFlightInfo;
        @AuraEnabled public Map<String, BookingDetailSingle> mapPNRBooking;
        @AuraEnabled public BookingAncillary pnrAncillaryInfo;
        @AuraEnabled public Map<String, List<FlightDisrupts>> mapPNRDisrupt;
        @AuraEnabled public List<passengerFlightDetail> lstFlightPassenger;
        @AuraEnabled public List<PassengerSSR> lstPassengerSSR;
        @AuraEnabled public List<passengerAncillary> lstPassengerAncillary;
        @AuraEnabled public QCC_PNRFlightInfoWrapper pnrFlightHistInfo;
    }
    /*--------------------------------------------------------------------------------------      
    Method Name:        BookingDetailSingle
    Description:        Fetch Customer address Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public class BookingDetailSingle{
        @AuraEnabled public String PNR;
        @AuraEnabled public String passengerCount;
        @AuraEnabled public String bookingDate;
        @AuraEnabled public String airLine;
        @AuraEnabled public String airLineMarket;
        @AuraEnabled public String flightNumber;
        @AuraEnabled public String flightNumberMarket;
        @AuraEnabled public String depaturePort;
        @AuraEnabled public String arrivalPort;
        @AuraEnabled public String depatureDateTime;
        @AuraEnabled public String arrivalDateTime;
        @AuraEnabled public String actualDepatureDateTime;
        @AuraEnabled public String actualArrivalDateTime;
        
        //Added by purushotham for prepopulation
        @AuraEnabled public String departureUTCDateTime;
        @AuraEnabled public String arrivalUTCDateTime;
        
    }
    /*--------------------------------------------------------------------------------------      
    Method Name:        BookingAncillary
    Description:        Fetch Customer address Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public class BookingAncillary{
        @AuraEnabled public String type;
        @AuraEnabled public String description;
        @AuraEnabled public String status;
        @AuraEnabled public String chargeable;
        @AuraEnabled public String amount;
        @AuraEnabled public String ancillarRef;
    }
    /*--------------------------------------------------------------------------------------      
    Method Name:        FlightDisrupts
    Description:        Fetch Customer address Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public class FlightDisrupts{
        @AuraEnabled public String departureLocalDate;
        @AuraEnabled public String depaturePort;
        @AuraEnabled public String arrivalPort;
        @AuraEnabled public String type;
        @AuraEnabled public String reason;
        @AuraEnabled public String duration;
        @AuraEnabled public String key;
    }
    /*--------------------------------------------------------------------------------------      
    Method Name:        PassengerFlightDetail
    Description:        Fetch Customer address Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public class PassengerFlightDetail{
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String depaturePort;
        @AuraEnabled public String arrivalPort;
        @AuraEnabled public String cabinClass;
        @AuraEnabled public String boardingStatus;
        @AuraEnabled public String seatNumber;
        @AuraEnabled public Integer checkinBaggage;
        @AuraEnabled public String legId;
        //Added by Purushotham
        @AuraEnabled public String passengerSegmentId;
    }
    /*--------------------------------------------------------------------------------------      
    Method Name:        SelectedSSR
    Description:        Fetch Customer address Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public class SelectedSSR {
        public List<PassengerSSR> ssr;
    }
    /*--------------------------------------------------------------------------------------      
    Method Name:        PassengerSSR
    Description:        Fetch Customer address Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public class PassengerSSR{
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String type;
        @AuraEnabled public String description;
        @AuraEnabled public String status;
        @AuraEnabled public String chargeable;
        @AuraEnabled public String amount;
        @AuraEnabled public String keyID;
        @AuraEnabled public String characteristics;
    }
    /*--------------------------------------------------------------------------------------      
    Method Name:        passengerAncillary
    Description:        Fetch Customer address Information from CAP system
    Parameter:          
    --------------------------------------------------------------------------------------*/
    public class passengerAncillary{
        @AuraEnabled public String type;
        @AuraEnabled public String description;
        @AuraEnabled public String status;
        @AuraEnabled public String chargeable;
        @AuraEnabled public String amount;
        @AuraEnabled public String ref;
    }
    
      @AuraEnabled
    public static Boolean getProfileToHideForPNR(){
        Boolean check = false;
        Id pflId = UserInfo.getProfileId();
         Profile partnerProfile = [Select Id, Name From Profile Where id =:pflId Limit 1];        
        if(partnerProfile != null){
            String pfls = System.Label.QCC_ProfileHide; 
            List<String> prflsNameList = pfls.split(',');
           check = prflsNameList.contains(partnerProfile.name); 
        }

        return check;
    }
}