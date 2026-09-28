/*
 * Created By : Abhijeet | TCS | Cloud Developer. 
 * Purpose : Search Booking Application's Controller.
 * Modified by : Ajay | Purpose : To include local PNR Search.
 * Referred in Ltng Component: QAC_SearchForm, QAC_PNRSearch_Tab.
*/

public with sharing class QAC_PNRSearch_Controller
{
    @AuraEnabled
    public static Map<String,String> fieldMap(List<String> fieldAPINames)
    {
        system.debug('incoming field map**'+fieldAPINames);
        Map<String, Schema.SObjectField> thefieldMap = Schema.SObjectType.Case.fields.getMap();
        Map<String,String> myFieldMap = new Map<String,String>();
        
        for(String eachAPIName: fieldAPINames){
            myFieldMap.put(eachAPIName,thefieldMap.get(eachAPIName).getDescribe().getLabel());
        }
        system.debug('my field map**'+myFieldMap);
        return myFieldMap;
    }

    @AuraEnabled
    public static list<Case> getLocalSearchCases(String pnrNum){
        if(String.isNotBlank(pnrNum)){
            return QAC_localPNRCases.getAllPNRCases(pnrNum,NULL);
        }
        return null;
    }

    @AuraEnabled 
    public static QAC_PNRDetailsWrapper invokeCallout(String pnrNumber, String lastName){
        
        lastName = EncodingUtil.urlEncode(lastName, 'UTF-8').replaceAll('\\+','%20');
        
        // To retrieve Authentication token
        String token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken');
        // To update authentication token
        QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
        
        // Complete information to be returned to Component
        QAC_PNRDetailsWrapper pnrInfo = new QAC_PNRDetailsWrapper();
        
        // Retrieving Flight Details
        pnrInfo.flightDetailsWrapper = getFlightDetails(pnrNumber, lastName, token);
        
        // Retrieving Passenger Details
        pnrInfo.passengerDetailsWrapper = getPassengerDetails(pnrNumber, lastName, token);
        
        // Retrieving Point of Sales Information
        pnrInfo.pointSales = getPointOfSales(pnrNumber, lastName, token);
        
        // Retrieving Case Details
        pnrInfo.caseFields = getCaseDetails(pnrNumber, pnrInfo);
        
        
    
        return pnrInfo;
    }
    
    // Returning Point of Sales from Booking API
    public Static QAC_PNRDetailsWrapper.PointOfSalesWrapper getPointOfSales(String pnrNumber, String lastName, String token)
    {
        QAC_PNRDetailsWrapper.PointOfSalesWrapper returnPointOfSales;
        
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QAC_PointOfSales');
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = '/'+pnrNumber+'/point-of-sale?lastName=' + lastName;
        String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        
        req.setEndpoint(endpointURL);
        req.setMethod(qantasAPI.Method__c); 
        req.setHeader('System', 'CAPCRE_CC');
        req.setHeader('Authorization', token);
        req.setTimeout(120000);
        HTTPResponse response = http.send(req);
        
        QAC_PointOfSalesParser pnrPassenger;
        //Jira CRM-6218: Token refresh when there is a mismatch
        if (response.getStatusCode() == 401)
        {
            token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken', true);
            QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
            req.setHeader('Authorization', token);
            response = http.send(req);
        }
        
        if(response.getStatusCode() == 200){
            system.debug('Point of Sales response Body#########' + response.getBody());
            pnrPassenger = QAC_PointOfSalesParser.parse(response.getBody());
            system.debug('QCC_PNRBookingRetrieveCAPWrapper#########'+pnrPassenger);
        }
        
        if(pnrPassenger != null){
            returnPointOfSales = new QAC_PNRDetailsWrapper.PointOfSalesWrapper(pnrPassenger.Booking.pointofSale);
        }
        system.debug('QCC_PNRBookingRetrieveCAPWrapper#########'+returnPointOfSales);
        return returnPointOfSales;
    }
    
    // Invoking Passenger API, to retrieve Passenger details from CAP CRE
    // Returning list Passenger details wrapper
    public Static List<QAC_PNRDetailsWrapper.PassengerDetailsWrapper> getPassengerDetails(String pnrNumber, String lastName, String token){
        
        List<QAC_PNRDetailsWrapper.PassengerDetailsWrapper> returnPassengerDetails = new List<QAC_PNRDetailsWrapper.PassengerDetailsWrapper>();
        
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_CAPPNRRetrieve');
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = '/'+pnrNumber+'/passengers?lastName=' + lastName;
        String endpointURL = qantasAPI.EndPoint__c+''+dynamicURL;
        req.setEndpoint(endpointURL);
        req.setMethod(qantasAPI.Method__c); 
        req.setHeader('System', 'CAPCRE_CC');
        req.setHeader('Authorization', token);
        req.setTimeout(120000);
        HTTPResponse response = http.send(req);
        
        QCC_PNRPassengerInfoWrapper pnrPassenger = new QCC_PNRPassengerInfoWrapper();
        //Jira CRM-6218: Token refresh when there is a mismatch
        if (response.getStatusCode() == 401)
        {
            token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken', true);
             QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
            req.setHeader('Authorization', token);
            response = http.send(req);
        }
       
        if(response.getStatusCode() == 200){
            system.debug('response Body#########' + response.getBody());
            pnrPassenger = (QCC_PNRPassengerInfoWrapper)JSON.deserialize(response.getBody(), QCC_PNRPassengerInfoWrapper.class);
            system.debug('QCC_PNRBookingRetrieveCAPWrapper#########'+pnrPassenger);
        }
        
        if(pnrPassenger != null && pnrPassenger.Booking != null && pnrPassenger.Booking.passengers != null)
        {
            for( QCC_PNRPassengerInfoWrapper.Passengers eachRec : pnrPassenger.Booking.passengers ){
                returnPassengerDetails.add(new QAC_PNRDetailsWrapper.PassengerDetailsWrapper(eachRec, False));
            }    
        }
        system.debug('QCC_PNRBookingRetrieveCAPWrapper#########'+returnPassengerDetails);
        
        return returnPassengerDetails;
    }
    
    // Invoking Flight API, to retrieve Flight details from CAP CRE
    // Returning list Flight details wrapper
    public Static List<QAC_PNRDetailsWrapper.FlightDetailsWrapper> getFlightDetails(String pnrNumber, String lastName, String token)
    {
        List<QAC_PNRDetailsWrapper.FlightDetailsWrapper> returnFlightDetails = new List<QAC_PNRDetailsWrapper.FlightDetailsWrapper>();
        
        Qantas_API__c qantasAPI = CustomSettingsUtilities.getQantasCAPAPI('QCC_CAPPNRRetrieve');
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        String dynamicURL = '/'+pnrNumber+'/flights?lastName='+lastName;
        String endpointURL = qantasAPI.EndPoint__c + '' + dynamicURL;
        req.setEndpoint(endpointURL);
        req.setMethod(qantasAPI.Method__c); 
        req.setHeader('System', 'CAPCRE_CC');
        req.setHeader('Authorization', token);
        req.setTimeout(120000);
        HTTPResponse response = http.send(req);
        
        QCC_PNRFlightInfoWrapper pnrBooking = new QCC_PNRFlightInfoWrapper();
        
        //Jira CRM-6218: Token refresh when there is a mismatch
        if (response.getStatusCode() == 401)
        {
            token = QCC_GenericUtils.getCAPValidToken('QCC_BookingToken', true);
            QCC_GenericUtils.updateToken(token, 'QCC_BookingToken');
            req.setHeader('Authorization', token);
            response = http.send(req);
        }

        
        if(response.getStatusCode() == 200){
            system.debug('response Body#########'+response.getBody());
            pnrBooking = (QCC_PNRFlightInfoWrapper)JSON.deserialize(response.getBody(), QCC_PNRFlightInfoWrapper.class);
            system.debug('QCC_PNRFlightInfoWrapper#########'+pnrBooking);
        }
        
        if(pnrBooking != null && pnrBooking.Booking != null && pnrBooking.Booking.Segments != null)
        {
            for(QCC_PNRFlightInfoWrapper.Segments eachRec : pnrBooking.Booking.Segments){
                returnFlightDetails.add(new QAC_PNRDetailsWrapper.FlightDetailsWrapper(eachRec, False));
            }    
        }
        
        for(QAC_PNRDetailsWrapper.FlightDetailsWrapper eachVar : returnFlightDetails){
            eachVar.flightDetails.arrivalLocalTime = eachVar.flightDetails.arrivalLocalTime.left(5);
            eachVar.flightDetails.departureLocalTime = eachVar.flightDetails.departureLocalTime.left(5);
        }
        
        system.debug(' Reture Data '+returnFlightDetails);
        return returnFlightDetails;
    }
    
    // To return list of Affected_Passenger__c to be inserted 
    public static list<Affected_Passenger__c> preparePassengerData(String caseId, list<QAC_PNRDetailsWrapper.PassengerDetailsWrapper> passengersList){
        
        list<Affected_Passenger__c> toReturnPassengersList = new List<Affected_Passenger__c>();
        String recTypeId = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        for(QAC_PNRDetailsWrapper.PassengerDetailsWrapper eachRec : passengersList)
        {
            if(eachRec.selectedFlight)
            {
                System.debug('@@ eachRec @@ ' + eachRec);
                toReturnPassengersList.add(new Affected_Passenger__c (Case__c               = caseId,
                                                                      FirstName__c           = eachRec.passengerDetails.firstName,
                                                                      FrequentFlyerNumber__c = eachRec.passengerDetails.qantasFFNo,
                                                                      LastName__c            = eachRec.passengerDetails.lastName,
                                                                      Name                   = eachRec.passengerDetails.firstName + ' ' + eachRec.passengerDetails.lastName,
                                                                      RecordTypeId           = recTypeId,
                                                                      Passenger_Sequence__c  = String.isNotBlank(eachRec.passengerDetails.passengerTattoo) ? Decimal.valueOf(eachRec.passengerDetails.passengerTattoo): null,
                                                                      Passenger_Tattoo_Number__c = String.isNotBlank(eachRec.passengerDetails.passengerTattoo) ? Decimal.valueOf(eachRec.passengerDetails.passengerTattoo): null,
                                                                      Passenger_Type__c      = QAC_CaseMappingUtility.fetchPassengerType(eachRec.passengerDetails.typeCode)
                                                                     ));
            }
        }
        
        return toReturnPassengersList;
    }
    
    // To return list of Flights to be inserted 
    public static list<Flight__c> prepareFlightData(String caseId, list<QAC_PNRDetailsWrapper.FlightDetailsWrapper> flightList){
        
        list<Flight__c> toReturnFlightList = new List<Flight__c>();
        list<String> dataParamters = new list<String>();
        Date departureDate;
        Integer arrivalDays = 0;
        for(QAC_PNRDetailsWrapper.FlightDetailsWrapper eachRec : flightList)
        {
            if(eachRec.selectedFlight){
                System.debug('@@ eachRec @@ ' + eachRec.flightDetails.departureLocalTime);
                dataParamters = eachRec.flightDetails.departureLocalDate.split('/');
                departureDate = Date.newInstance(Integer.valueOf(dataParamters[2]),Integer.valueOf(dataParamters[1]),Integer.valueOf(dataParamters[0]));
                dataParamters = new list<String>(); 
                dataParamters = eachRec.flightDetails.arrivalLocalDate.split('/');
                arrivalDays = departureDate.daysBetween(Date.newInstance(Integer.valueOf(dataParamters[2]),Integer.valueOf(dataParamters[1]),Integer.valueOf(dataParamters[0])));
                
                toReturnFlightList.add(new Flight__c    (Case__c                    = caseId,
                                                         Arrival_Airport__c         = eachRec.flightDetails.arrivalAirportCode,
                                                         Departure_Airport__c       = eachRec.flightDetails.departureAirportCode,
                                                         Flight_Number__c           = eachRec.flightDetails.marketingCarrierAlphaCode + eachRec.flightDetails.marketingFlightNumber,
                                                         Flight_Date__c             = departureDate,
                                                         Arrival_Time__c            = (arrivalDays > 0) ? eachRec.flightDetails.arrivalLocalTime + ' +' + String.valueOf(arrivalDays) : eachRec.flightDetails.arrivalLocalTime,
                                                         Departure_Time__c          = eachRec.flightDetails.departureLocalTime,
                                                         // Cabin_Class__c              = eachRec.flightDetails.departureLocalTime,
                                                         Cabin_Class__c             = eachRec.flightDetails.bookedReservationClass));
            }
        }
        
        return toReturnFlightList;
    }
    
    @AuraEnabled
    public static String getRecordTypeId(){
        String rtId = (String)QAC_PaymentsProcess.fetchRecordTypeId('Case','Service Request');
        return rtId;
    } 
    
    public static QAC_PNRDetailsWrapper.CaseDefaultValues getCaseDetails(String pnrNumber, QAC_PNRDetailsWrapper pnrInfo)
    {
        String travelAgentCode;
        String qciCode;
        String abnNumber;
        String passengerName;

        // added by Ajay for calc First Flight Date & First Flight Number
        list<String> dataParameters = new list<String>();
        list<String> timeParameters = new list<String>();
        Datetime departureDT;
        Date firstFLDate;
        String firstFLNumber;
        List<Datetime> DateDiff = new List<Datetime>();
        map<Datetime,String> FFDt_FFNo_map = new map<Datetime,String>();
        // ended
        
        Integer count = 0;
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
        list<Account> agencies = new list<Account>();
        Account agencyRef = new Account();
        String gdsValue;
        if(pnrInfo != NULL && pnrInfo.pointSales != null && pnrInfo.pointSales.pointOfSales.creatorDetails.companyId != NULL){
            gdsValue = QAC_CaseMappingUtility.fetchGDSValues(pnrInfo.pointSales.pointOfSales.creatorDetails.companyId);
        }
        system.debug('@@ gdsValue @@ ' + gdsValue);
        
        if(pnrInfo != NULL)
        {
            for(QAC_PNRDetailsWrapper.PassengerDetailsWrapper eachRec : pnrInfo.passengerDetailsWrapper){
                qciCode = eachRec.passengerDetails.corpId;
                abnNumber = eachRec.passengerDetails.smeId;
                passengerName = eachRec.passengerDetails.firstName + ' ' + eachRec.passengerDetails.lastName;
                count ++ ;
            }
            
            // added by Ajay to calculate first flight Date
            for(QAC_PNRDetailsWrapper.FlightDetailsWrapper eachFRec : pnrInfo.flightDetailsWrapper){
                dataParameters = eachFRec.flightDetails.departureLocalDate.split('/');
                timeParameters = eachFRec.flightDetails.departureLocalTime.split(':');
                
                departureDT = datetime.newInstance(
                                        Integer.valueOf(dataParameters[2]),
                                        Integer.valueOf(dataParameters[1]),
                                        Integer.valueOf(dataParameters[0]),
                                        Integer.valueOf(timeParameters[0]),
                                        Integer.valueOf(timeParameters[1]),
                                        0                    
                                    );
                
                if(departureDT >= System.now()){
                    DateDiff.add(departureDT);
                    String FFNo = eachFRec.flightDetails.marketingCarrierAlphaCode + eachFRec.flightDetails.marketingFlightNumber;
                    FFDt_FFNo_map.put(departureDT,FFNo);
                }
            }
            system.debug('date diff*'+DateDiff+' |date Flight Map'+FFDt_FFNo_map);
            if(!DateDiff.isEmpty()){
                DateDiff.sort();
                firstFLDate = DateDiff[0].date();
                firstFLNumber = FFDt_FFNo_map.get(DateDiff[0]);
            }
            // ended
            
            if(pnrInfo.pointSales != null){
                if(pnrInfo.pointSales.pointOfSales.creatorDetails.travelAgentId != NULL ) {
                    travelAgentCode = pnrInfo.pointSales.pointOfSales.creatorDetails.travelAgentId.left(7);
                    for(Account myAcc : [SELECT Id, Name FROM Account WHERE Qantas_Industry_Centre_ID__c =: travelAgentCode AND RecordTypeId =: agencyRecordTypeId LIMIT 1])
                    {
                        if(myAcc != null) agencyRef = myAcc;    
                    }
                    //agencies = [SELECT Id, Name FROM Account WHERE Qantas_Industry_Centre_ID__c =: travelAgentCode AND RecordTypeId =: agencyRecordTypeId LIMIT 1];
                }
            }
            
            system.debug('@@ Agency Name @@ ' + agencyRef);
        }
        return (new QAC_PNRDetailsWrapper.CaseDefaultValues(agencyRef,'Open','Phone',pnrNumber,abnNumber,qciCode,passengerName, String.valueOf(count), travelAgentCode, firstFLNumber, firstFLDate, gdsValue));
    }    
    
    @AuraEnabled 
    public static User fetchUser(){
        // query current user information  
        return [Select Id, Name FROM User Where id =: userInfo.getUserId()];
    }
    
    @AuraEnabled
    public static String createCase(String passengers, String flights, String caseFields, String caseId)
    {
        try{
            if(!string.isBlank(flights)){
                list<QAC_PNRDetailsWrapper.FlightDetailsWrapper> flightWrapperList = (list<QAC_PNRDetailsWrapper.FlightDetailsWrapper>)System.JSON.deserialize(flights,list<QAC_PNRDetailsWrapper.FlightDetailsWrapper>.class);
                list<Flight__c> toInsertFlights = prepareFlightData(caseId, flightWrapperList);
                insert toInsertFlights;
            }
            
            if(!string.isBlank(passengers)){
                list<QAC_PNRDetailsWrapper.PassengerDetailsWrapper> passengerWrapperList = (list<QAC_PNRDetailsWrapper.PassengerDetailsWrapper>)System.JSON.deserialize(passengers,list<QAC_PNRDetailsWrapper.PassengerDetailsWrapper>.class);
                list<Affected_Passenger__c> toInsertPassengers = preparePassengerData(caseId, passengerWrapperList);
                insert toInsertPassengers;
            }
            
            if(!string.isBlank(caseFields)){
                QAC_PNRDetailsWrapper.CaseDefaultValues caseValues = (QAC_PNRDetailsWrapper.CaseDefaultValues)System.JSON.deserialize(caseFields,QAC_PNRDetailsWrapper.CaseDefaultValues.class);
                Case toUpdateCase = new Case (Id = caseId, GDS_DI__c = caseValues.gdsValue);
                update toUpdateCase;
            }
        }
        catch(Exception ex){}
        return caseId;
    }
}