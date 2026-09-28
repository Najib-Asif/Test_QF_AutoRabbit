/* 
* Created By : Abhijeet | TCS | Cloud Developer. 
* Modified By : Ajay | Purpose to include Local Search Test Part.
* Main Class : QAC_PNRSearch_Controller.
*/
@isTest
public class QAC_PNRSearch_Controller_Test 
{  
    @testSetup
    public static void setup() 
    {
        system.debug('inside test setup**');
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        
        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Integration Logs Rec Type',Config_Value__c = 'Integration Logs');
        insert qcd;
        
        QantasConfigData__c qcd2 = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd2;
        
        //Inserting Account
        Account acc1 = new Account(Name = 'Sample1', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                   RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                   Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '4364557');
        
        insert acc1;
        
        Account relatedAcc1 = new Account(Name = 'Sample2', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                          RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565366',
                                          Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '1000000', Qantas_Industry_Centre_ID__c = '1000000');
        
        insert relatedAcc1;
        
        
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        
        Qantas_API__c qantasAPI2 = new Qantas_API__c();
        qantasAPI2.Name = 'QAC_PointOfSales';
        qantasAPI2.EndPoint__c = 'https://api-stage.qantas.com/booking/capcre/v1/';
        qantasAPI2.Method__c = 'GET';
        lstQantas.add(qantasAPI2);
        
        insert lstQantas;
        
        String caseRTId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Service Request').getRecordTypeId();
        Case newCase = new Case(External_System_Reference_Id__c = 'C-002002002003',Origin = 'QAC Website',
                                Type = 'Service Request',Problem_Type__c = 'Schedule Change',Waiver_Sub_Type__c = 'Ticket Refund',Status = 'Open',RecordTypeId = caseRTId,
                                Subject = 'to be decided',Description = 'some desc',Justification__c = 'must give',Authority_Status__c = 'Approved',
                                AccountId = acc1.Id,Consultants_Name__c = 'abcd',Consultant_Email__c = 'test@test.com',Consultant_Phone__c = '28213812',
                                PNR_number__c = '454546',Old_PNR_Number__c = '1021512',Passenger_Name__c = 'TestUser',Regions__c = 'DOM');       
        
        insert newCase;
    }
    
    public static testMethod void passengerAPITest(){
        
        String Body ='{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","currentPassengerQuantity":"2","lastUpdatedTimeStamp":"05/12/2017 04:28:00","passengers":[{"passengerId":"8956328947991887","passengerTattoo":"2","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"STEVE","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CC","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000017"},{"passengerId":"9018991125607359","passengerTattoo":"3","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"MARK","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CD","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000018"}],"contacts":{"address":[{"addressId":"1601601601600001","otherTattooReference":"11","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"B","line1":"322","line2":"level 20","line3":" Indooroopilly mall","line4":"moggill rd","postBoxName":null,"cityName":" Indooroopilly","stateName":"qld","countryName":"AU","postalCode":"4000","addressText":"TEST ADDR1","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"addressId":"1601601601600002","otherTattooReference":"12","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"H","line1":"10","line2":null,"line3":null,"line4":"king st","postBoxName":null,"cityName":"perth","stateName":"tas","countryName":"AU","postalCode":"7300","addressText":"TEST ADDR2","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"addressId":"1601601601600003","otherTattooReference":"14","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"B","line1":"647","line2":null,"line3":"london court","line4":"hay st","postBoxName":null,"cityName":"perth","stateName":"wa","countryName":"AU","postalCode":"6000","addressText":"TEST ADDR3","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]},{"addressId":"1601601601600004","otherTattooReference":"15","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"H","line1":"15","line2":null,"line3":null,"line4":"hobart rd","postBoxName":null,"cityName":"south launceston","stateName":"tas","countryName":"AU","postalCode":"7249","addressText":"TEST ADDR4","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]}],"email":[{"emailId":"1621621621620001","otherTattooReference":"44","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"B","emailText":"steve.waugh@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"emailId":"1621621621620002","otherTattooReference":"45","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"H","emailText":"steve.waugh1@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"emailId":"1621621621620003","otherTattooReference":"46","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"B","emailText":"mark.waugh@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]},{"emailId":"1621621621620004","otherTattooReference":"47","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"H","emailText":"mark.waugh1@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]}],"phone":[{"phoneId":"1244444265675389","otherTattooReference":"7","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":"07","phoneNumber":"98765448","typeCode":"B","phoneText":"98765448 B","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"phoneId":"1641641641640002","otherTattooReference":"8","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":null,"phoneNumber":"410467890","typeCode":"H","phoneText":"410467890 H","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"phoneId":"1641641641640003","otherTattooReference":"9","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":"08","phoneNumber":"98124567","typeCode":"B","phoneText":"98124567 B","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]},{"phoneId":"1641641641640004","otherTattooReference":"10","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":null,"phoneNumber":"410678909","typeCode":"H","phoneText":"410678909 H","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]}]},"segments":[{"segmentId":"2","segmentTattoo":"1","marketingCarrierAlphaCode":"QF","marketingFlightNumber":"0063","marketingFlightSuffix":"","departureAirportCode":"SYD","arrivalAirportCode":"JNB","operatingCarrierAlphaCode":"QF","operatingFlightNumber":"63","operatingFlightSuffix":"","departureCityCode":"SYD","arrivalCityCode":"JNB","departureLocalDate":"02/06/2018","departureLocalTime":"00:00:01","actualDepartureLocalDate":null,"actualDepartureLocalTime":null,"departureTerminalCode":"","arrivalLocalDate":"30/06/2018","arrivalLocalTime":"00:00:01","actualArrivalLocalDate":null,"actualArrivalLocalTime":null,"arrivalTerminalCode":"","departureUTCDate":"30/06/2018","departureUTCTime":"00:19:30","arrivalUTCDate":"30/06/2018","arrivalUTCTime":"00:20:50","departureDow":null,"dateVar":"0","flightTypeCode":"","aircraftTypeCode":null,"codeShareFlightTypeCode":"","codeShareAgreementTypeCode":"","disrupts":[{"type":"CANCELLED","legDepartureAirportCode":"SYD","legArrivalAirportCode":"JNB","unScheduledArrivalAirport":null,"details":[{"reasonCode":"122","shortDescription":"TECH","longDescription":"AIRCRAFT DEFECTS","delayDuration":"0"}]}]}],"passengerFlightStatus":[{"passengerSegmentId":"773984470592206","segmentId":"9178306296255759","passengerId":"9018991125607359","passengerTattoo":"3","segmentTattoo":"1","travellerProductId":"2301CA3500008BE1","reservationStatusCode":"HK","bookedCabinClass":"Y","bookedReservationClass":"Y","leg":[{"legId":"8961376721667362","originAirportCode":"SYD","destinationAirportCode":"MEL","otherTattoo":"27","bagPoolId":"0","hoPoolIndicator":"N","legSequenceNumber":"1","seatNumber":null,"seatPreferenceCode":null,"onLoadStatusCode":null,"forcedAcceptanceIndicator":null,"freezeAcceptanceIndicator":null,"boardingPassPrintStatusCode":"NPT","baggageStatusCode":"NBG","acceptance":{"statusCode":"CNA","originTypeCode":null,"channelTypeCode":null,"cancelReasonCode":null},"boardingStatusCode":"NBD","customerRecordStatusCode":"REC","waitListStatusCode":"NCW","transferStatusCode":"NFL","regrade":{"statusCode":"NRG","authorizer":null,"reasonCode":null,"targetCabinClass":null},"checkinCarrierCode":null,"involuntaryCompensationIndicator":null,"compensationStatusCode":null,"compensationReasonText":null}]}],"serviceRequest":[{"passengerId":"9018991125607359","segmentId":"9178306296255759","segmentTattoo":"1","passengerTattoo":"3","seat":[{"seatRequestId":"1521521521520001","serviceKeywordCode":"RQST","serviceSourceCode":"SSR","otherTattooReferenceNumber":"21","passengerSegmentRelationTypeCode":"B","departureCityCode":"SYD","arrivalCityCode":"MEL","requestStatusCode":"HK","airlineCarrierAlphaCode":"QF","requestSeatNumber":"5A","specialAssistancePassengerTypeCode":null,"chargeableIndicator":null,"serviceTotalFareAmount":"0.000","fareCurrencyCode":null,"serviceGroupCode":"A","serviceGroupSubCode":"0B5","gaugeChangeLocalDate":null,"partialSegmentIndicator":null,"additionalText":"TEST SEAT1","characteristics":[{"typecode":"A","code":"N"},{"typecode":"A","code":null},{"typecode":"B","code":null},{"typecode":"B","code":null}]}],"loyalty":[{"loyaltyRequestId":"1501501501500001","serviceKeywordCode":"FQTV","serviceSourceCode":"SSR","otherTattooReferenceNumber":"72","passengerSegmentRelationTypeCode":"B","requestStatusCode":"HK","requestCarrierCode":"QF","schemeOperatorCode":"QF","ffCardNumber":"0006142104","revenueClass":null,"upgradeClass":null,"ffUpgradeCertificate":null,"allianceCarrierCode":"*O","customerValue":null,"airlinePriorityCode":"2","airineTierLevelCode":"FFBR","airlineTierDescription":null,"alliancePriorityCode":null,"allianceTierLevelCode":null,"allianceTierDescription":null,"validFFIndicator":"Y","serviceActionCode":"F","additionalText":"TEST TEXT1"}],"meal":[{"mealRequestId":"1511511511510001","serviceKeywordCode":"VGML","serviceSourceCode":"SSR","otherTattooReferenceNumber":"15","passengerSegmentRelationTypeCode":"B","airlineCarrierAlphaCode":"QF","requestStatusCode":"HK","chargeableIndicator":null,"serviceTotalFareAmount":"0.000","fareCurrencyCode":null,"serviceGroupCode":null,"serviceGroupSubCode":null,"additionalText":"TEST MEAL REQ1"}],"bag":[{"bagRequestId":"1531531531530001","serviceKeywordCode":"BAGW","serviceSourceCode":"SSR","otherTattooReferenceNumber":"41","passengerSegmentRelationTypeCode":"B","departureCityCode":null,"arrivalCityCode":null,"requestStatusCode":"HK","chargeableIndicator":null,"serviceTotalFareAmount":"0.000","fareCurrencyCode":null,"airlineCarrierAlphaCode":"QF","serviceGroupCode":null,"serviceGroupSubCode":null,"serviceLocalDate":null,"serviceConsumedIndicator":null,"additionalText":"TEST BAG1"}],"other":[{"otherRequestId":"1561561561560001","serviceKeywordCode":"CFDC","serviceSourceCode":"SSR","otherTattooReferenceNumber":"51","passengerSegmentRelationTypeCode":"B","departureCityCode":null,"arrivalCityCode":null,"requestStatusCode":null,"requestPassengerQuantity":null,"chargeableIndicator":null,"serviceTotalFareAmount":"0.000","fareCurrencyCode":null,"requestCarrierCode":null,"serviceGroupCode":null,"serviceGroupSubCode":null,"serviceLocalDate":null,"serviceConsumedIndicator":null,"additionalText":"TEST OTHER1"}],"document":[{"docRequestId":"1541541541540001","serviceKeywordCode":"DOCS","serviceSourceCode":"SSR","otherTattooReferenceNumber":"31","issuingCountryCode":"AU","passengerSegmentRelationTypeCode":"B","airlineCarrierAlphaCode":"QF","requestStatusCode":"HK","docNumber":"TEST1234","docTypeCode":"P","firstName":null,"midName":null,"lastName":null,"genderTypeCode":null,"infantIndicator":null,"birthDate":null,"issueDate":"01/01/2016","expiryDate":"31/12/2036","issuePlaceText":null,"nationality":null,"additionalText":null}]}]},"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","lastUpdatedTimeStamp":"05/12/2017 04:28:00","insurance":[{"insuranceId":"1401401401400001","insuranceTattoo":"88","policyCode":"USE","policyName":"TWO AUSTRALIAN CANCELLATION TRAVEL PLAN","insuranceConfirmationNumber":"QQU01014558-0","segmentStatusCode":"HK","insuranceStartLocalDate":"05/12/2017","insuranceEndLocalDate":"31/12/2018","providerCompanyCode":"OIU","providerCompanyName":null,"providerCountryCode":"AU","tripTypeCode":"FLT","totalTripAmount":"200.000","totalPremiumAmount":"250.000","currencyCode":"AUD"}],"accommodation":[{"accommodationSegmentId":"1431431431430001","segmentTattooReferenceNumber":"1","segmentSourceCode":"HHL","accommodationBookingReferenceNumber":"TEST1","bookingConfirmationNumber":"CONF143","travelProductSupplyCode":"XY","checkinLocalDate":"06/12/2017","checkoutLocalDate":"07/12/2017","locatedCityCode":"MEL","accommodationChainCode":"YX","accommodationChainName":"SYNXIS","accommodationPropertyCode":"MSM","accommodationPropertyName":"MERITON SUITES MASCOT CENTRAL","roomsDeliveredQuantity":"1","segmentStatusCode":"HK"},{"accommodationSegmentId":"1431431431430002","segmentTattooReferenceNumber":"2","segmentSourceCode":"HHL","accommodationBookingReferenceNumber":"TEST2","bookingConfirmationNumber":"CONF143","travelProductSupplyCode":"YZ","checkinLocalDate":"06/12/2017","checkoutLocalDate":"07/12/2017","locatedCityCode":"MEL","accommodationChainCode":"YX","accommodationChainName":"SYNXIS","accommodationPropertyCode":"MSM","accommodationPropertyName":"MERITON SUITES MASCOT CENTRAL","roomsDeliveredQuantity":"1","segmentStatusCode":"HK"}],"vehicle":[{"vehicleSegmentId":"1441441441440001","segmentTattooReferenceNumber":"1","segmentSourceCode":"CCR","bookingConfirmationNumber":"CONF1440001","travelProductSupplyCode":"ZT","vehicleCompanyCode":"ZT","vehicleCompanyName":"THRIFTY","vehicleGradeCode":"ECAR","segmentStatusCode":"HK","vehicleHire":{"pickUpLocalTimestamp":"05/12/2017 11:00:00","pickUpUTCTimestamp":"05/12/2017 00:00:00","dropOffLocalTimestamp":"05/12/2017 14:00:00","dropOffUTCTimestamp":"06/12/2017 01:00:00"},"vehicleHireLocation":{"pickUp":{"cityCode":"MEL","airportCode":"MEL","locationName":null},"dropOff":{"cityCode":"MEL","airportCode":null,"locationName":null}}},{"vehicleSegmentId":"1441441441440002","segmentTattooReferenceNumber":"2","segmentSourceCode":"CCR","bookingConfirmationNumber":"CONF1440001","travelProductSupplyCode":"ZT","vehicleCompanyCode":"ZT","vehicleCompanyName":"THRIFTY","vehicleGradeCode":"ECAR","segmentStatusCode":"HK","vehicleHire":{"pickUpLocalTimestamp":"05/12/2017 11:00:00","pickUpUTCTimestamp":"05/12/2017 00:00:00","dropOffLocalTimestamp":"05/12/2017 14:00:00","dropOffUTCTimestamp":"06/12/2017 01:00:00"},"vehicleHireLocation":{"pickUp":{"cityCode":"MEL","airportCode":"MEL","locationName":null},"dropOff":{"cityCode":"MEL","airportCode":null,"locationName":null}}}],"other":[{"otherTattooReferenceNumber":"52","segmentId":"9208109317857456","serviceKeywordCode":"CFDD","serviceSourceCode":"SSR","passengerSegmentRelationTypeCode":"B","departureCityCode":null,"arrivalCityCode":null,"requestStatusCode":null,"requestPassengerQuantity":null,"chargeableIndicator":null,"requestCarrierCode":null,"serviceGroupCode":null,"serviceGroupSubCode":null,"serviceLocalDate":null,"serviceConsumedIndicator":null,"additionalText":"TEST OTHER2"},{"otherTattooReferenceNumber":"53","segmentId":"9208109317857456","serviceKeywordCode":"STPC","serviceSourceCode":"SSR","passengerSegmentRelationTypeCode":"B","departureCityCode":null,"arrivalCityCode":null,"requestStatusCode":null,"requestPassengerQuantity":null,"chargeableIndicator":null,"requestCarrierCode":null,"serviceGroupCode":null,"serviceGroupSubCode":null,"serviceLocalDate":null,"serviceConsumedIndicator":null,"additionalText":"TEST OTHER3"}]}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        List<QAC_PNRDetailsWrapper.PassengerDetailsWrapper> wrap = QAC_PNRSearch_Controller.getPassengerDetails('K5F5ZE', 'FREQUENTFLYER', 'XXXX');
        
        system.assert(wrap != Null, 'invokeTokenCapAPI returns Null'); 
        
        for(QAC_PNRDetailsWrapper.PassengerDetailsWrapper eachRec : wrap){
            eachRec.selectedFlight = TRUE;
        }
        
        String wrapBody = JSON.serialize(wrap);
        
        Case insertedCase = [SELECT Id FROM Case LIMIT 1];
        list<Affected_Passenger__c> passengers = QAC_PNRSearch_Controller.preparePassengerData( insertedCase.Id, wrap);
        
        QAC_PNRSearch_Controller.createCase(wrapBody, '', '', insertedCase.Id);
        
        Test.stopTest();
    }
    
    public static testMethod void flightAPITest(){
        
        string body = '{"booking":{"reloc":"ULMZAH","travelPlanId":"258636190959913","bookingId":"258636190959913","creationDate":"06/02/2018","lastUpdatedTimeStamp":"19/02/2018 07:59:00","segments":[{"segmentId":"9718453921822338","segmentTattoo":"3","marketingCarrierAlphaCode":"QF","marketingFlightNumber":"1511","marketingFlightSuffix":null,"departureAirportCode":"SYD","arrivalAirportCode":"CBR","operatingCarrierAlphaCode":"QF","operatingFlightNumber":"1511","operatingFlightSuffix":null,"departureCityCode":"SYD","arrivalCityCode":"CBR","departureLocalDate":"08/02/2018","departureLocalTime":"06:20:00","actualDepartureLocalDate":null,"actualDepartureLocalTime":"00:00:00","departureTerminalCode":"T3","arrivalLocalDate":"08/02/2018","arrivalLocalTime":"07:20:00","actualArrivalLocalDate":null,"actualArrivalLocalTime":"00:00:00","arrivalTerminalCode":null,"departureUTCDate":"07/02/2018","departureUTCTime":"19:20:00","arrivalUTCDate":"07/02/2018","arrivalUTCTime":"20:20:00","departureDow":"4","dateVar":"0","flightTypeCode":"D","aircraftTypeCode":"717","codeShareFlightTypeCode":null,"codeShareAgreementTypeCode":null,"bookedCabinClass":"Y","bookedReservationClass":"Y","disrupts":[{"type":"CANCELLED","legDepartureAirportCode":"SYD","legArrivalAirportCode":"CBR","unScheduledArrivalAirport":""}]},{"segmentId":"10047862642331570","segmentTattoo":"7","marketingCarrierAlphaCode":"QF","marketingFlightNumber":"0117","marketingFlightSuffix":null,"departureAirportCode":"SYD","arrivalAirportCode":"HKG","operatingCarrierAlphaCode":"QF","operatingFlightNumber":"0117","operatingFlightSuffix":null,"departureCityCode":"SYD","arrivalCityCode":"HKG","departureLocalDate":"09/02/2018","departureLocalTime":"13:05:00","actualDepartureLocalDate":"09/02/2018","actualDepartureLocalTime":"13:02:00","departureTerminalCode":"T1","arrivalLocalDate":"09/02/2018","arrivalLocalTime":"19:15:00","actualArrivalLocalDate":"09/02/2018","actualArrivalLocalTime":"18:55:00","arrivalTerminalCode":"1","departureUTCDate":"09/02/2018","departureUTCTime":"02:05:00","arrivalUTCDate":"09/02/2018","arrivalUTCTime":"11:15:00","departureDow":"5","dateVar":"0","flightTypeCode":"I","aircraftTypeCode":"388","codeShareFlightTypeCode":null,"codeShareAgreementTypeCode":null,"bookedCabinClass":"Y","bookedReservationClass":"Q","disrupts":[{"type":"AS SCHEDULED","legDepartureAirportCode":"SYD","legArrivalAirportCode":"HKG","unScheduledArrivalAirport":""}]},{"segmentId":"1133282995615560","segmentTattoo":"10","marketingCarrierAlphaCode":"QF","marketingFlightNumber":"0118","marketingFlightSuffix":null,"departureAirportCode":"HKG","arrivalAirportCode":"SYD","operatingCarrierAlphaCode":"QF","operatingFlightNumber":"0118","operatingFlightSuffix":null,"departureCityCode":"HKG","arrivalCityCode":"SYD","departureLocalDate":"20/02/2018","departureLocalTime":"21:15:00","actualDepartureLocalDate":"21/02/2018","actualDepartureLocalTime":"08:55:00","departureTerminalCode":"1","arrivalLocalDate":"21/02/2018","arrivalLocalTime":"09:45:00","actualArrivalLocalDate":"21/02/2018","actualArrivalLocalTime":"20:54:00","arrivalTerminalCode":"T1","departureUTCDate":"20/02/2018","departureUTCTime":"13:15:00","arrivalUTCDate":"20/02/2018","arrivalUTCTime":"22:45:00","departureDow":"2","dateVar":"1","flightTypeCode":"I","aircraftTypeCode":"388","codeShareFlightTypeCode":null,"codeShareAgreementTypeCode":null,"bookedCabinClass":"Y","bookedReservationClass":"M","disrupts":[{"type":"AS SCHEDULED","legDepartureAirportCode":"HKG","legArrivalAirportCode":"SYD","unScheduledArrivalAirport":""}]}]}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        List<QAC_PNRDetailsWrapper.FlightDetailsWrapper> wrap = QAC_PNRSearch_Controller.getFlightDetails('ULMZAH', 'FREQUENTFLYER', 'XXXX');
        
        for(QAC_PNRDetailsWrapper.FlightDetailsWrapper eachRec : wrap){
            eachRec.selectedFlight = TRUE;
        }
        
        String wrapBody = JSON.serialize(wrap);
        system.debug('wrapBody###########'+wrapBody);
        system.assert(wrap != Null, 'invokeTokenCapAPI returns Null'); 
        
        Case insertedCase = [SELECT Id FROM Case LIMIT 1];
        list<Flight__c> passengers = QAC_PNRSearch_Controller.prepareFlightData( insertedCase.Id, wrap);
        QAC_PNRSearch_Controller.fetchUser();
        QAC_PNRSearch_Controller.getRecordTypeId();
        QAC_PNRSearch_Controller.createCase('',wrapBody, '', insertedCase.Id);
        
        Test.stopTest();
    }
    
    public static testMethod void pointOfSalesAPITest(){
        
        string body = '{"booking":{"reloc":"ULMZAH","travelPlanId":"258636190959913","bookingId":"258636190959913","creationDate":"06/02/2018","currentPassengerQuantity":3,"lastUpdatedTimeStamp":"19/02/2018 07:59:00","pointofSale":{"creatorDetails":{"travelAgentId":"02394980","inHouseIdentification":"SYDQF0980","agentType":"A","companyId":"QF","locationId":"SYD","countryCode":"AU"},"ownerDetails":{"travelAgentId":"02394980","inHouseIdentification":"SYDQF0980","agentType":"A","companyId":"QF","locationId":"SYD","countryCode":"AU"}},"externalBookingReferences":[{"airlineCode":"QF","reloc":"ULMZAH","type":"A"}]}}';
        
        String[] apiNames = new String[]{'Type','Problem_Type__c','Reason_for_Waiver__c','Condition_Met__c','Cost_of_Sale__c','First_Flight_Date__c','flight_itinerary__c'};
        
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QAC_PNRDetailsWrapper.PointOfSalesWrapper wrap = QAC_PNRSearch_Controller.getPointOfSales('ULMZAH', 'FREQUENTFLYER', 'XXXX');
        String wrapBody = JSON.serialize(wrap);
        system.debug('wrapBody###########'+wrapBody);
        system.assert(wrap != Null, 'invokeTokenCapAPI returns Null'); 
        
        // Case insertedCase = [SELECT Id FROM Case LIMIT 1];
        // list<Flight__c> passengers = QAC_PNRSerach_Tab_Extesnion.prepareFlightData( insertedCase.Id, wrap);
        QAC_PNRSearch_Controller.fetchUser();
        QAC_PNRSearch_Controller.getRecordTypeId();
        QAC_PNRSearch_Controller.fieldMap(apiNames);
        //Jira CRM-6218: We are calling external callouts in the below method and we have uncommite data in this place. So we are commenting below call. It wont impact Code coverage. 
        //QAC_PNRDetailsWrapper pnrInfo = QAC_PNRSearch_Controller.invokeCallout('ULMZAH', 'FREQUENTFLYER');
        QAC_PNRDetailsWrapper pnrInfo;
        QAC_PNRSearch_Controller.getCaseDetails('ULMZAH', pnrInfo);
        QAC_PNRSearch_Controller.getLocalSearchCases('ULMZAH');
        
        Test.stopTest();
    }
    
    public static testMethod void caseDetailsTest(){
        
        string body ='{"booking":{"reloc":"ULMZAH","travelPlanId":"258636190959913","bookingId":"258636190959913","creationDate":"06/02/2018","lastUpdatedTimeStamp":"19/02/2018 07:59:00","pointofSale":{"creatorDetails":{"travelAgentId":"02394980","inHouseIdentification":"SYDQF0980","agentType":"A","companyId":"QF","locationId":"SYD","countryCode":"AU"},"ownerDetails":{"travelAgentId":"02394980","inHouseIdentification":"SYDQF0980","agentType":"A","companyId":"QF","locationId":"SYD","countryCode":"AU"}},"externalBookingReferences":[{"airlineCode":"QF","reloc":"ULMZAH","type":"A"}],"passengers":[{"passengerId":"8956328947991887","passengerTattoo":"2","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"STEVE","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CC","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000017"},{"passengerId":"9018991125607359","passengerTattoo":"3","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"MARK","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CD","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000018"}],"segments":[{"segmentId":"2","segmentTattoo":"1","marketingCarrierAlphaCode":"QF","marketingFlightNumber":"0063","marketingFlightSuffix":"","departureAirportCode":"SYD","arrivalAirportCode":"JNB","operatingCarrierAlphaCode":"QF","operatingFlightNumber":"63","operatingFlightSuffix":"","departureCityCode":"SYD","arrivalCityCode":"JNB","departureLocalDate":"02/06/2020","departureLocalTime":"00:00:01","actualDepartureLocalDate":null,"actualDepartureLocalTime":null,"departureTerminalCode":"","arrivalLocalDate":"30/06/2018","arrivalLocalTime":"00:00:01","actualArrivalLocalDate":null,"actualArrivalLocalTime":null,"arrivalTerminalCode":"","departureUTCDate":"30/11/2018","departureUTCTime":"00:19:30","arrivalUTCDate":"30/06/2018","arrivalUTCTime":"00:20:50","departureDow":null,"dateVar":"0","flightTypeCode":"","aircraftTypeCode":null,"codeShareFlightTypeCode":"","codeShareAgreementTypeCode":"","disrupts":[{"type":"CANCELLED","legDepartureAirportCode":"SYD","legArrivalAirportCode":"JNB","unScheduledArrivalAirport":null,"details":[{"reasonCode":"122","shortDescription":"TECH","longDescription":"AIRCRAFT DEFECTS","delayDuration":"0"}]}]}]},"caseFields":{"caseOrigin":"Phone","caseStatus":"Open","gdsValue":"1G","iataAccount":{},"passengerCount":"2","passengerName":"STEVE WAUGH","pnrNumber":"ULMZAH"}}';
        
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QAC_PNRDetailsWrapper pnrInfo = QAC_PNRSearch_Controller.invokeCallout('ULMZAH', 'WAUGH');
        
        system.assert(pnrInfo != Null, 'invokeTokenCapAPI returns Null'); 

        Case insertedCase = [SELECT Id FROM Case LIMIT 1];
        String wrapBody = JSON.serialize(pnrInfo.caseFields);        
        
        QAC_PNRSearch_Controller.getCaseDetails('ULMZAH', pnrInfo);
        QAC_PNRSearch_Controller.createCase('','', wrapBody, insertedCase.Id);
        Test.stopTest();
    }   
}