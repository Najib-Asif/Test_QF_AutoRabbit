@isTest(seeAllData = false)
private class CaseFlightInfoServiceTest {
    
    // Declare event variables globally for use in test methods
    static Event__c newEvent1;

 
    @testSetup
    static void setup() {
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        // Setup test data for Airport_Code__c
        List<Airport_Code__c> lstAirPort = new List<Airport_Code__c>();
        Airport_Code__c aCode = new Airport_Code__c(Name = 'SYD', QF_Freight_Presence__c = TRUE, Freight_Station_Name__c = 'Sydney', Freight_Airport_State_Code__c = 'NSW');
        lstAirPort.add(aCode);
        Airport_Code__c aCode1 = new Airport_Code__c(Name = 'MEL', QF_Freight_Presence__c = TRUE, Freight_Station_Name__c = 'Melbourne', Freight_Airport_State_Code__c = 'VIC');
        lstAirPort.add(aCode1);
        Airport_Code__c aCode2 = new Airport_Code__c(Name = 'JNB', QF_Freight_Presence__c = TRUE, Freight_Station_Name__c = 'Johannesburg', Freight_Airport_State_Code__c = 'GAT');
        lstAirPort.add(aCode2);
        insert lstAirPort;

        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        for(Trigger_Status__c ts : lsttrgStatus){
            ts.Active__c = false;
        }
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createFlightFailureSetting());
        insert lsttrgStatus;
        
        // Create User
        //CRM-11908 Updated Role for the User
        Map<String, UserRole> rolesMap = TestUtilityDataClassQantas.getRoles();
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
            Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Customer Journey Manager').Id, //CRM-11908 Update metadata rerferences
            EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU', Location__c = 'Sydney',
            TimeZoneSidKey = 'Australia/Sydney');
        insert u1;
        //CRM-11908 Update metadata rerferences
        System.runAs(new User(Id = UserInfo.getUserId())) {
            //CRM-11908 Updated Role for the User
            u1.UserRoleId =  rolesMap.get('QF-QDC-CJM').Id; 
            update u1;
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Customer_Journey_Agent_Permissions');
            List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();
            for (Id psId : permissionSetIds) {
                psaList.add(new PermissionSetAssignment(AssigneeId = u1.Id, PermissionSetId = psId));
            }
            if (!psaList.isEmpty()) {
                insert psaList;
            }
        }
      
        // Create events
       System.runAs(u1){
        
        List<Event__c> events = new List<Event__c>();
        newEvent1 = TestUtilityDataClassQantas.createEventWithValues('Flight Event - Active', 'Assigned', 'Flight Delay', 'Domestic');
        //newEvent1.OwnerId = u1.Id;
        newEvent1.EstimatedDepDateTime__c = '2018-06-19 11:40:00';
        newEvent1.ScheduledDepTime__c = '19:15';
        newEvent1.ScheduledDepDate__c = Date.newInstance(2018, 06, 18);
        newEvent1.FlightNumber__c = 'QF0401';
        newEvent1.DeparturePort__c = 'SYD';
        newEvent1.ArrivalPort__c = 'MEL';
        events.add(newEvent1);

        // Add other event records similarly (newEvent2, newEvent3, etc.)

        insert events;

        FlightFailure__c failure = new FlightFailure__c(
            Failure_Code__c = 'Diversion Due to Weather',
            Affected_Region__c = 'Full Flight',
            Affect_Sub_Section__c = 'Full Flight',
            Flight_Event__c = newEvent1.Id
        );
        insert failure;
        
        // Create a sample Case record
        Case testCase = new Case(
            Booking_PNR__c = 'MC755T',
            Last_Name__c = 'FrequentFlyer',
            flight_number__c = 'QF0401',
            event__c = newEvent1.Id,
            TECH_bookingCreationDate__c = '21/05/2018',
            TECH_bookingArchivalData__c = 'false'
        );
        insert testCase;
        }
        
        // Insert affected passenger records (optional)
        affected_passenger__c passenger = new affected_passenger__c(
            PNR__c = 'MC755T',
            LastName__c = 'FrequentFlyer',
            Event__r = newEvent1
        );
        insert passenger;
        
    }
    
   
   @isTest
    static void testGetFlightInfoForCase_WithError() {
        // Create a Case with an invalid PNR to trigger an error message
        Case invalidCase = new Case(
            Booking_PNR__c = '',
            Last_Name__c = 'FrequentFlyer',
            flight_number__c = 'AA123',
            event__c = null,  // Invalid case without an event
            TECH_bookingCreationDate__c = '21/11/2023',
            TECH_bookingArchivalData__c = 'false'
        );
        insert invalidCase;
        
        Test.startTest();
        List<CaseFlightInfoService.FlightInfoWrapper> result = CaseFlightInfoService.getFlightInfoForCase(invalidCase.Id);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(result.size(), 1, 'There should be one error message');
        System.assertEquals(result[0].source, 'Error', 'Source should be Error');
        System.debug('result[0].message:::'+result[0].message);
        //System.assert(result[0].message.contains('No PNR is linked to this case. Add a PNR to see flight details.'), 'Error message should contain PNR validation message');
    }

    @isTest
    static void testGetFlightInfoForCase_WithNoFlights() {
        // Create a Case with an invalid PNR to simulate no flights found
        Case invalidCase = new Case(
            Booking_PNR__c = 'PNR234',
            Last_Name__c = 'FrequentFlyer',
            flight_number__c = 'AA123',
            event__c = null,  // No event linked
            TECH_bookingCreationDate__c = '21/11/2023',
            TECH_bookingArchivalData__c = 'false'
        );
        insert invalidCase;
        
        Test.startTest();
        List<CaseFlightInfoService.FlightInfoWrapper> result = CaseFlightInfoService.getFlightInfoForCase(invalidCase.Id);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(result.size(), 1, 'There should be one error message');
        System.assertEquals(result[0].source, 'Error', 'Source should be Error');
        System.debug('result[0].message::::'+result[0].message);
       //System.assert(result[0].message.contains('No Flights found for PNR234. Please check that PNR is correct to see flight details.'), 'Error message should contain no flights found message');
    }

    @isTest
    static void testGetFlightInfoForCase_NoFlightEvent() {
        Event__c newEvent1 = [select id from event__C where flightnumber__c='QF0401'];
        System.debug('newEvent1:::'+newEvent1.id);
        // Create a Case with a valid PNR but no flight event
        Case testCase = new Case(
            Booking_PNR__c = 'MC755T',
            Last_Name__c = 'FrequentFlyer',
            flight_number__c = 'AA123',
            event__c = newEvent1.Id,
            TECH_bookingCreationDate__c = '21/11/2023',
            TECH_bookingArchivalData__c = 'false'
        );
        insert testCase;
        
        Test.startTest();
        List<CaseFlightInfoService.FlightInfoWrapper> result = CaseFlightInfoService.getFlightInfoForCase(testCase.Id);
        Test.stopTest();
        
        // Assertions
        System.assertEquals(result.size(), 1, 'There should be one error message');
        System.assertEquals(result[0].source, 'Error', 'Source should be Error');
       // System.assert(result[0].message.contains('No Flights found for MC755T. Please check that PNR is correct to see flight details.'), 'Error message should contain no flight events found message');
    }

  
    @IsTest
    public static void testNoFlightResponseFromAPI(){
        User u = [Select Id, name, profile.name from user where username='sampleuser1username@sample.com'];
        list<QCC_CAPFlightInfoMock.MockRes> lstRes = new List<QCC_CAPFlightInfoMock.MockRes>();
        
        Map<String, String> mapHeader = new Map<String, String>();
        String body = '{  '
            +'   "flights":[  '
            +'        {  '
            +'           "marketingCarrier":"QF",'
            +'           "marketingFlightNo":"0516",'
            +'           "suffix":"",'
            +'           "departureAirportCode":"LHR",'
            +'           "departureAirportName":"BRISBANE",'
            +'           "arrivalAirportCode":"SYD",'
            +'           "arrivalAirportName":"KINGSFORD SMITH",'
            +'           "departureTerminal":"",'
            +'           "departureGate":"",'
            +'           "arrivalTerminal":"",'
            +'           "arrivalGate":"",'
            +'           "equipmentTailNumber":null,'
            +'           "equipmentTypeCode":"146",'
            +'           "equipmentSubTypeCode":"14Z",'
            +'           "flightStatus":"",'
            +'           "flightDuration":"90",'
            +'           "delayDuration":null,'
            +'           "scheduledDepartureUTCTimeStamp":"28/03/2018 14:05:00",'
            +'           "estimatedDepartureUTCTimeStamp":null,'
            +'           "actualDepartureUTCTimeStamp":null,'
            +'           "scheduledArrivalUTCTimeStamp":"28/03/2018 15:35:00",'
            +'           "estimatedArrivalUTCTimeStamp":null,'
            +'           "actualArrivalUTCTimeStamp":null,'
            +'           "scheduledDepartureLocalTimeStamp":"29/03/2018 00:05:00",'
            +'           "estimatedDepartureLocalTimeStamp":null,'
            +'           "actualDepartureLocalTimeStamp":null,'
            +'           "scheduledArrivalLocalTimeStamp":"29/03/2018 02:35:00",'
            +'           "estimatedArrivalLocalTimeStamp":null,'
            +'           "actualArrivalLocalTimeStamp":null,'
            +'           "primaryBaggageCarousel":"",'
            +'           "secondaryBaggageCarousel":""'
            +'           ,"delay": [{'
            +'           "reasonCode": "580",'
            +'           "shortDescription": "IT",'
            +'           "longDescription": "max 200 chars",'
            +'           "delayDuration": "100"'
            +'           }]'
            +'        }'
            +'   ]'
            +'}';

           // Test.setMock(HttpCalloutMock.class, new QCC_CAPFlightInfoMock(200, 'Success', Body, mapHeader));
        lstRes.add(new QCC_CAPFlightInfoMock.MockRes(404, 'Not Found', Body, mapHeader));
        lstRes.add(new QCC_CAPFlightInfoMock.MockRes(404, 'Not Found', Body, mapHeader));
        
        System.runAs(u){
            Test.setMock(HttpCalloutMock.class, new QCC_CAPFlightInfoMock(lstRes));
            Test.startTest();
            Case testCase = [select id, Last_Name__c, First_Name__c, Booking_PNR__c FROM Case limit 1];
            List<CaseFlightInfoService.FlightInfoWrapper> result = CaseFlightInfoService.getFlightInfoForCase(testCase.Id);
            Test.stopTest();
            //System.assertEquals(result, '');
        }
    }



    @isTest
    public static void testGetFlightInfoForCase_Success() {
        Event__c testEvent = new Event__c(
            FlightNumber__c = 'QF0401',
            //ScheduledDepDate__c = Date.today(),
            DeparturePort__c = 'SYD',
            ArrivalPort__c = 'MEL',
            //Scheduled_Departure__c = DateTime.now(),
            EstimatedDepDateTime__c = '2018-06-20 11:40:00',
            ScheduledDepTime__c = '19:15',
            ScheduledDepDate__c = Date.newInstance(2018, 06, 20)
        );
        insert testEvent;
		
		// Create a test case record
        Case testCase = new Case(
            Booking_PNR__c = 'MC755T',
            flight_number__c = 'QF0401',
            event__c = testEvent.id,
            Last_Name__c = 'FrequentFlyer',
            TECH_bookingCreationDate__c = '21/05/2018',
            TECH_bookingArchivalData__c = 'false'
        );
        insert testCase;
		FlightFailure__c failure = new FlightFailure__c(
            Failure_Code__c = 'Diversion Due to Weather',
            Affected_Region__c = 'Full Flight',
            Affect_Sub_Section__c = 'Full Flight',
            Flight_Event__c = testEvent.Id
        );
        insert failure;

        affected_Passenger__c affectedPassenger = new affected_Passenger__c(
            PNR__c = 'MC755T', 
            LastName__c = 'FrequentFlyer', 
            Event__c = testEvent.Id
        );
        insert affectedPassenger;

        // Create related Airport Code records
        Airport_code__c airportLAX = new Airport_code__c(Name = 'SYD', Freight_Station_Name__c = 'Sydney International', Freight_Airport_Country_Name__c = 'USA', Freight_Airport_Country_Code__c = 'AU');
        Airport_code__c airportSFO = new Airport_code__c(Name = 'MEL', Freight_Station_Name__c = 'Melbourne International', Freight_Airport_Country_Name__c = 'USA', Freight_Airport_Country_Code__c = 'AU');
        insert new List<Airport_code__c>{airportLAX, airportSFO};
        
		Map<String, String> mapHeader = new Map<String, String>();
		String body = '{'
						+'   "booking":{  '
						+'      "reloc":"MC755T",'
						+'      "travelPlanId":"45605313493473",'
						+'      "bookingId":"45605313493473",'
						+'      "creationDate":"01/06/2018",'
						+'      "lastUpdatedTimeStamp":"05/06/2018 03:13:00",'
						+'      "segments":[  '
						+'         {  '
						+'            "segmentId":"9118102587993461",'
						+'            "segmentTattoo":"1",'
						+'            "marketingCarrierAlphaCode":"QF",'
						+'            "marketingFlightNumber":"0401",'
						+'            "marketingFlightSuffix":null,'
						+'            "departureAirportCode":"SYD",'
						+'            "arrivalAirportCode":"MEL",'
						+'            "operatingCarrierAlphaCode":"QF",'
						+'            "operatingFlightNumber":"0401",'
						+'            "operatingFlightSuffix":null,'
						+'            "departureCityCode":"SYD",'
						+'            "arrivalCityCode":"MEL",'
						+'            "departureLocalDate":"05/06/2018",'
						+'            "departureLocalTime":"15:15:00",'
						+'            "actualDepartureLocalDate":"05/06/2018",'
						+'            "actualDepartureLocalTime":"15:23:00",'
						+'            "departureTerminalCode":"T2",'
						+'            "arrivalLocalDate":"06/06/2018",'
						+'            "arrivalLocalTime":"05:05:00",'
						+'            "actualArrivalLocalDate":"06/06/2018",'
						+'            "actualArrivalLocalTime":"04:47:00",'
						+'            "arrivalTerminalCode":"3",'
						+'            "departureUTCDate":"05/06/2018",'
						+'            "departureUTCTime":"05:15:00",'
						+'            "arrivalUTCDate":"06/06/2018",'
						+'            "arrivalUTCTime":"04:05:00",'
						+'            "departureDow":"2",'
						+'            "dateVar":"1",'
						+'            "flightTypeCode":"I",'
						+'            "aircraftTypeCode":"789",'
						+'            "codeShareFlightTypeCode":null,'
						+'            "codeShareAgreementTypeCode":null,'
						+'            "bookedCabinClass":"J",'
						+'            "bookedReservationClass":"J",'
						+'            "disrupts":[  '
						+'               {  '
						+'                  "type":"DELAY",'
						+'                  "legDepartureAirportCode":"MEL",'
						+'                  "legArrivalAirportCode":"PER",'
						+'                  "unScheduledArrivalAirport":"",'
						+'                  "details":[  '
						+'                     {  '
						+'                        "reasonCode":"332",'
						+'                        "shortDescription":"RAMP",'
						+'                        "longDescription":"AWT FIRST AVAILABLE TUG DUE QPB OSO",'
						+'                        "delayDuration":"8"'
						+'                     }'
						+'                  ]'
						+'               },'
						+'               {  '
						+'                  "type":"AS SCHEDULED",'
						+'                  "legDepartureAirportCode":"PER",'
						+'                  "legArrivalAirportCode":"LHR",'
						+'                  "unScheduledArrivalAirport":""'
						+'               }'
						+'            ]'
						+'         }'
						+'      ]'
						+'   }'
						+'}';
        // Step 2: Mock external API responses (if necessary)
        // Mock the API response for QCC_InvokeCAPAPI.invokePNRFlightInfoCAPAPI
        Test.startTest();


        // Mock the external API call
        Test.setMock(HttpCalloutMock.class, new QCC_CAPFlightInfoMock(200, 'Success', Body, mapHeader));

        // Step 3: Call the method to test
        List<CaseFlightInfoService.FlightInfoWrapper> result = CaseFlightInfoService.getFlightInfoForCase(testCase.Id);

        // Step 4: Validate results with assertions
        System.assertEquals(1, result.size(), 'There should be one flight info wrapper');
        System.assertEquals('QF0401', result[0].flightNumber, 'The flight number should match');
        System.assertEquals('SYD', result[0].departureAirportCode, 'The departure airport code should match');
        System.assertEquals('MEL', result[0].arrivalAirportCode, 'The arrival airport code should match');
        System.assertNotEquals(null, result[0].scheduledDepartureDate, 'Scheduled Departure Date should not be null');
        System.assertNotEquals(null, result[0].scheduledArrivalDate, 'Scheduled Arrival Date should not be null');
        
        Test.stopTest();
    }
    
}