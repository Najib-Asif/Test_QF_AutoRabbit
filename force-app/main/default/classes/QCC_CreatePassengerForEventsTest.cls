/**
* @author huangxy
*/
@isTest
private class QCC_CreatePassengerForEventsTest {


    @testSetup
    static void createData() {
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createEventTriggerSetting();
        TestUtilityDataClassQantas.insertQantasConfigData();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting());
        insert lsttrgStatus;
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        // Replacing the Run as user profile with QCC Contact Center Agent profile and adding QCC Base,Contact Center and Genesys permission sets on the user as part of RBAC CRM-11628               
        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
             Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Contact Center Agent Hobart').Id,
             EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
             TimeZoneSidKey = 'Australia/Sydney', Location__c='Hobart'
             );
        insert u1;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(u1.Id,permissionSetIds);
        }

        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;

        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusApproved','Approved'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_FligjtCode Domestic','Domestic'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeDomestic','Emergency Expense - Domestic Stage'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_FligjtCode International','International'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeInternational','   Emergency Expense - International Stage'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeNotEligible','Not Eligible for Emergency Expenses'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseStatusClosed','Closed'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_QSOAUserName','sampleuser1username@sample.com'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_ValidPassengerResCode','DK;HK;IS;KK;KL;LK;NK;OK;OX;RR;SS;TK'));
        insert lstConfigData;
    }


    /**
     * This is a test method for test_execute_0
     */
    static testMethod void test_execute_0() {

        //   to run in the test.
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        
        List<Contact> contactList = new List<Contact>();
        // Create new contact - Update existing record
        Contact contact1 = new Contact(Firstname='Triton',Lastname='CHAIRMANSLOUNGE' , Frequent_Flyer_Number__c = '0006142202' , CAP_ID__c = '710000000023');
        // Create new contact - Update existing record
        Contact contact2 = new Contact(Firstname='David',Lastname='Boon' , Frequent_Flyer_Number__c = '00061422028' , CAP_ID__c ='710000000006' );
        // Create new contact - Update existing record
        Contact contact3 = new Contact(Firstname='Gold',Lastname='FrequentFlyer' , Frequent_Flyer_Number__c = '00061422023' , CAP_ID__c ='710000000025' );

        contactList.add(contact1);
        contactList.add(contact2);
        contactList.add(contact3);
        insert contactList;
        
        Event__c objEvent = new Event__c();
        objEvent.FlightNumber__c  = 'QF0516' ;
        objEvent.ScheduledDepDate__c = Date.newInstance(2018, 03, 02);
        objEvent.DeparturePort__c  = 'SYD';
        objEvent.ArrivalPort__c = 'SYD';
        objEvent.Flight_Status__c = 'Departed';
        objEvent.Operational_Carrier__c = 'QF';
        objEvent.TechPassenger_API_Invoked__c = false;
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];


            Test.startTest();   
            insert objEvent;
            //System.enqueueJob(new QCC_CreatePassengerForEvents(objEvent , 1));
            QCC_UpdateEventFlightInfoController.updatePassengerforEvent(objEvent.Id);
            Test.stopTest();

        
        // Queueable class method.
        List<Affected_Passenger__c> afp = [SELECT Id FROM Affected_Passenger__c WHERE Passenger__c = :objEvent.Id LIMIT 1];
        System.assertNotEquals(null, afp);
    }

    static testMethod void test_execute_1() {

        //   to run in the test.
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        
        Event__c objEvent = new Event__c();
        objEvent.FlightNumber__c  = 'QF0516' ;
        objEvent.ScheduledDepDate__c = Date.newInstance(2018, 03, 02);
        objEvent.DeparturePort__c  = 'SYD';
        objEvent.ArrivalPort__c = 'SYD';
        objEvent.Flight_Status__c = 'Boarding';
        objEvent.Operational_Carrier__c = 'QF';
        objEvent.TechPassenger_API_Invoked__c = false;
        insert objEvent;
        Test.startTest();   
        //System.enqueueJob(new QCC_CreatePassengerForEvents(objEvent , 1));
        QCC_UpdateEventFlightInfoController.updatePassengerforEvent(objEvent.Id);
        Test.stopTest();
        
        // Queueable class method.
        List<Affected_Passenger__c> afp = [SELECT Id FROM Affected_Passenger__c WHERE Passenger__C = :objEvent.Id LIMIT 1];
        System.assertNotEquals(null, afp);
    }

    //existing contact
    static testMethod void test_execute_3() {

        //   to run in the test.
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
         
        // Create new contact - Update existing record
        Contact contact1 = new Contact(Firstname='Triton',Lastname='CHAIRMANSLOUNGE' , Frequent_Flyer_Number__c = '0006142202');
        insert contact1;
        // Create new contact - Update existing record
        Contact contact2 = new Contact(Firstname='Triton',Lastname='CHAIRMANSLOUNGE' , Frequent_Flyer_Number__c = '00061422023');
        insert contact2;

        Event__c objEvent = new Event__c();
        objEvent.FlightNumber__c  = 'QF0516' ;
        objEvent.ScheduledDepDate__c = Date.newInstance(2018, 03, 02);
        objEvent.DeparturePort__c  = 'SYD';
        objEvent.ArrivalPort__c = 'SYD';
        objEvent.Flight_Status__c = 'Boarding';
        objEvent.Operational_Carrier__c = 'QF';
        objEvent.TechPassenger_API_Invoked__c = false;
        insert objEvent;

        //add passenger in response
        Affected_Passenger__c afp = new Affected_Passenger__c(PassengerId__c = '1544523921002621', Passenger__c =contact1.Id, TECH_PreFlight__c = true,Event__c = objEvent.Id, counter__c=1);
        insert afp;
        //add passenger not in passenger response
        Affected_Passenger__c afp2 = new Affected_Passenger__c(PassengerId__c = '1544523921002623', Passenger__c =contact2.Id, TECH_PreFlight__c = true,Event__c = objEvent.Id, counter__c=2);
        insert afp2;
        Test.startTest();  
        //System.enqueueJob(new QCC_CreatePassengerForEvents(objEvent , 1));
        QCC_UpdateEventFlightInfoController.updatePassengerforEvent(objEvent.Id);
        Test.stopTest();
        
        // Queueable class method.
    }

    //existing contact
    static testMethod void createAffPassengerWithFFN() {

        //   to run in the test.
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        
        // Create new contact - Update existing record
        Contact contact1 = new Contact(Firstname='Triton',Lastname='CHAIRMANSLOUNGE' , Frequent_Flyer_Number__c = '0006142202');
        insert contact1;

        Event__c objEvent = new Event__c();
        objEvent.FlightNumber__c  = 'QF0516' ;
        objEvent.ScheduledDepDate__c = Date.newInstance(2018, 03, 02);
        objEvent.DeparturePort__c  = 'SYD';
        objEvent.ArrivalPort__c = 'SYD';
        objEvent.Flight_Status__c = 'Boarding';
        objEvent.Operational_Carrier__c = 'QF';
        objEvent.TechPassenger_API_Invoked__c = false;
        insert objEvent;
        String passengerJson = '{"passengerId":"1544523921002621","customerId":"23827374724","firstName":"TRITON","lastName":"CHAIRMANSLOUNGE","namePrefix":"MRS","genderTypecode":"F","paxTypeCode":null,"dateOfBirth":null,"qfFrequentFlyerNumber":"","qfTierCode":"CLQF","bookingReference":"TYDSN6","bookingCreationDate":"2018-02-02","bookingId":"86837460060226","segmentId":"10209019122211170","segmentTattoo":4,"passengerSegId":"943174852311001","offPoint":"BNE","marketingCarrier":"QF","marketingFlightNumber":"0516","bookedCabinClass":"Y","bookedReservationClass":"Q","reservationStatusCode":"HK","leg":[{"sequenceNumber":1,"originPort":"SYD","destinationPort":"BNE","checkinStatus":"CRJ","boardStatus":"NBD","seatNo":null}],"customerContactDetails":{"address":[{"passengerAssociationIndicator":"H","typeCode":"H","line1":"2/22","line2":"","line3":"","line4":"allenst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"O","line1":"3/50","line2":"","line3":"","line4":"harrisst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"B","line1":"10","line2":"shop1","line3":"","line4":"wigramst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"}],"Email":[{"passengerAssociationIndicator":"Y","contactSourceCode":"AP","contactKeyWordCode":"98789654","Id":"email@email.com"}],"phone":[{"passengerAssociationIndicator":"Y","contactSourceCode":"AP","contactKeyWordCode":"98789654","Id":"02928938383"},{"typeCode":"O","phoneCountryCode":"61","phoneAreaCode":"02","phoneLineNumber":"78906543","phoneExtension":""},{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"02","phoneLineNumber":"78965479","phoneExtension":""}]},"otherLoyaltyDetails":{"homeCity":null,"tier":{"old":null,"new":null,"changeDate":null},"domesticTravelPreference":{"meal":{"code":null,"description":null},"seat":{"code":null,"description":null}},"internationalTravelPreference":{"meal":{"code":null,"description":null},"seat":{"code":null,"description":null}},"epLinkedIndicator":null}}';
        QCC_FlightPassengersResponse.passengers psg = (QCC_FlightPassengersResponse.passengers) System.JSON.deserialize(passengerJson, QCC_FlightPassengersResponse.passengers.class);
        QCC_FlightPassengersResponse.parse(passengerJson);
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        QCC_CreatePassengerForEvents.ContactWrapper conWrap = new QCC_CreatePassengerForEvents.ContactWrapper();
        conWrap.contactId = contact1.Id;
        conWrap.ffNumber = contact1.Frequent_Flyer_Number__c;
        conWrap.preferredEmail = 'test@testemail.com';
        conWrap.preferredPhone = '49941788788';
        Set<String> travelAgentEmailDomains = new Set<String>();
        Affected_Passenger__c afp = QCC_CreatePassengerForEvents.createAffPassenger(conWrap , objEvent , psg , 'PostFlight',u1.Id, null, travelAgentEmailDomains);
        afp.counter__c = 2;
        System.assert(afp != null);
        insert afp;
        System.assert(afp.Id != null);
        Test.startTest();   
        QCC_UpdateEventFlightInfoController.updatePassengerforEvent(objEvent.Id);
        Test.stopTest();
        
    }

    static testMethod void createAffPassengerWithoutFFN() {

        //   to run in the test.
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        
        // Create new contact - Update existing record
        Contact contact1 = new Contact(Firstname='Triton',Lastname='CHAIRMANSLOUNGE');
        insert contact1;

        Event__c objEvent = new Event__c();
        objEvent.FlightNumber__c  = 'QF0516' ;
        objEvent.ScheduledDepDate__c = Date.newInstance(2018, 03, 02);
        objEvent.DeparturePort__c  = 'SYD';
        objEvent.ArrivalPort__c = 'SYD';
        objEvent.Flight_Status__c = 'Boarding';
        objEvent.Operational_Carrier__c = 'QF';
        objEvent.TechPassenger_API_Invoked__c = false;
        insert objEvent;
        String passengerJson = '{"passengerId":"1544523921002621","customerId":"23827374724","firstName":"TRITON","lastName":"CHAIRMANSLOUNGE","namePrefix":"MRS","genderTypecode":"F","paxTypeCode":null,"dateOfBirth":null,"qfFrequentFlyerNumber":"","qfTierCode":"CLQF","bookingReference":"TYDSN6","bookingCreationDate":"2018-02-02","bookingId":"86837460060226","segmentId":"10209019122211170","segmentTattoo":4,"passengerSegId":"943174852311001","offPoint":"BNE","marketingCarrier":"QF","marketingFlightNumber":"0516","bookedCabinClass":"Y","bookedReservationClass":"Q","reservationStatusCode":"HK","leg":[{"sequenceNumber":1,"originPort":"SYD","destinationPort":"BNE","checkinStatus":"CRJ","boardStatus":"NBD","seatNo":null}],"ContactDetails":{"address":[{"typeCode":"H","line1":"2/22","line2":"","line3":"","line4":"allenst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"O","line1":"3/50","line2":"","line3":"","line4":"harrisst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"B","line1":"10","line2":"shop1","line3":"","line4":"wigramst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"}],"Email":[{"passengerAssociationIndicator":"Y","contactSourceCode":"AP","contactKeyWordCode":"98789654","Id":"email@email.com"}],"phone":[{"passengerAssociationIndicator":"Y","contactSourceCode":"AP","contactKeyWordCode":"98789654","Id":"02928938383"},{"typeCode":"O","phoneCountryCode":"61","phoneAreaCode":"02","phoneLineNumber":"78906543","phoneExtension":""},{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"02","phoneLineNumber":"78965479","phoneExtension":""}]},"otherLoyaltyDetails":{"homeCity":null,"tier":{"old":null,"new":null,"changeDate":null},"domesticTravelPreference":{"meal":{"code":null,"description":null},"seat":{"code":null,"description":null}},"internationalTravelPreference":{"meal":{"code":null,"description":null},"seat":{"code":null,"description":null}},"epLinkedIndicator":null}}';
        QCC_FlightPassengersResponse.passengers psg = (QCC_FlightPassengersResponse.passengers) System.JSON.deserialize(passengerJson, QCC_FlightPassengersResponse.passengers.class);

        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        QCC_CreatePassengerForEvents.ContactWrapper conWrap = new QCC_CreatePassengerForEvents.ContactWrapper();
        conWrap.contactId = contact1.Id;
        conWrap.ffNumber = contact1.Frequent_Flyer_Number__c;
        conWrap.preferredEmail = 'test@testemail.com';
        conWrap.preferredPhone = '49941788788';
        Set<String> travelAgentEmailDomains = new Set<String>();
        Affected_Passenger__c afp = QCC_CreatePassengerForEvents.createAffPassenger(conWrap , objEvent , psg , 'PostFlight', u1.Id, null, travelAgentEmailDomains);
        afp.counter__c = 2;
        System.assert(afp != null);
        insert afp;
        System.assert(afp.Id != null);

        Test.startTest();   
        QCC_UpdateEventFlightInfoController.updatePassengerforEvent(objEvent.Id);
        Test.stopTest();
        
    }
    
    
    static testMethod void createAffPassengerWithKeyFieldsNonFFN() {

        //   to run in the test.
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        
        // Create new contact - Update existing record
        Contact contact1 = new Contact(Firstname='Triton',Lastname='CHAIRMANSLOUNGE', Email = 'test@test.com', Phone='0123455678');
        insert contact1;

        Event__c objEvent = new Event__c();
        objEvent.FlightNumber__c  = 'QF0516' ;
        objEvent.ScheduledDepDate__c = Date.newInstance(2018, 03, 02);
        objEvent.DeparturePort__c  = 'SYD';
        objEvent.ArrivalPort__c = 'SYD';
        objEvent.Flight_Status__c = 'Boarding';
        objEvent.Operational_Carrier__c = 'QF';
        objEvent.TechPassenger_API_Invoked__c = false;
        insert objEvent;
        String passengerJson = '{"passengerId":"1544523921002621","customerId":"23827374724","firstName":"TRITON","lastName":"CHAIRMANSLOUNGE","namePrefix":"MRS","genderTypecode":"F","paxTypeCode":null,"dateOfBirth":null,"qfFrequentFlyerNumber":"","qfTierCode":"CLQF","bookingReference":"TYDSN6","bookingCreationDate":"2018-02-02","bookingId":"86837460060226","segmentId":"10209019122211170","segmentTattoo":4,"passengerSegId":"943174852311001","offPoint":"BNE","marketingCarrier":"QF","marketingFlightNumber":"0516","bookedCabinClass":"Y","bookedReservationClass":"Q","reservationStatusCode":"HK","leg":[{"sequenceNumber":1,"originPort":"SYD","destinationPort":"BNE","checkinStatus":"CRJ","boardStatus":"NBD","seatNo":null}],"ContactDetails":{"address":[{"typeCode":"H","line1":"2/22","line2":"","line3":"","line4":"allenst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"O","line1":"3/50","line2":"","line3":"","line4":"harrisst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"B","line1":"10","line2":"shop1","line3":"","line4":"wigramst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"}],"Email":[{"passengerAssociationIndicator":"Y","contactSourceCode":"AP","contactKeyWordCode":"98789654","Id":"test@test.com"}],"phone":[{"passengerAssociationIndicator":"Y","contactSourceCode":"AP","contactKeyWordCode":"98789654","Id":"02928938383","phoneNumber":"0123455678"},{"typeCode":"O","phoneCountryCode":"61","phoneAreaCode":"02","phoneNumber":"0123455678","phoneLineNumber":"78906543","phoneExtension":""},{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"02","phoneLineNumber":"78965479","phoneNumber":"0123455678","phoneExtension":""}]},"otherLoyaltyDetails":{"homeCity":null,"tier":{"old":null,"new":null,"changeDate":null},"domesticTravelPreference":{"meal":{"code":null,"description":null},"seat":{"code":null,"description":null}},"internationalTravelPreference":{"meal":{"code":null,"description":null},"seat":{"code":null,"description":null}},"epLinkedIndicator":null}}';
        QCC_FlightPassengersResponse.passengers psg = (QCC_FlightPassengersResponse.passengers) System.JSON.deserialize(passengerJson, QCC_FlightPassengersResponse.passengers.class);

        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        QCC_CreatePassengerForEvents.ContactWrapper conWrap = new QCC_CreatePassengerForEvents.ContactWrapper();
        conWrap.contactId = contact1.Id;
        conWrap.ffNumber = contact1.Frequent_Flyer_Number__c;
        conWrap.preferredEmail = 'test@testemail.com';
        conWrap.preferredPhone = '49941788788';

     
        QCC_ContactWrapper payload = new QCC_ContactWrapper();

        payload.ffNumber = '';
        payload.lastName = 'CHAIRMANSLOUNGE';
        payload.firstName = 'TRITON';
        payload.email = 'test@test.com';
        payload.phone = '0123455678';
        payload.capId = '';
        payload.isFF = false;

        String contact = JSON.serialize(payload);
        List<String> contactDetails = new List<String>();
        contactDetails.add(contact);

        String contactMappingSource = 'ContactWrapper_Field__c';
        System.debug('contactDetails======> '+ JSON.serialize(contactDetails));
        Map<String,Contact> allContactsMap = QCC_GenericUtils.getNonFFContactForAffectedPassengers(contactDetails, contactMappingSource);
        Set<String> travelAgentEmailDomains = new Set<String>();
        Affected_Passenger__c afp = QCC_CreatePassengerForEvents.createAffPassenger(null , objEvent , psg , 'PostFlight', u1.Id, allContactsMap, travelAgentEmailDomains);
        afp.counter__c = 2;
        System.assert(afp != null);
        insert afp;
        System.assert(afp.Id != null);

        Test.startTest();   
        QCC_UpdateEventFlightInfoController.updatePassengerforEvent(objEvent.Id);
        Test.stopTest();
        
    }
    
    
    static testMethod void passengerServiceDetail() {

        //   to run in the test.
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        
        // Create new contact - Update existing record
        Contact contact1 = new Contact(Firstname='Triton',Lastname='CHAIRMANSLOUNGE' , Frequent_Flyer_Number__c = '0006142202');
        insert contact1;

        Event__c objEvent = new Event__c();
        objEvent.FlightNumber__c  = 'QF0516' ;
        objEvent.ScheduledDepDate__c = Date.newInstance(2018, 03, 02);
        objEvent.DeparturePort__c  = 'SYD';
        objEvent.ArrivalPort__c = 'MEL';
        objEvent.Flight_Status__c = 'Boarding';
        objEvent.Operational_Carrier__c = 'QF';
        objEvent.TechPassenger_API_Invoked__c = false;
        insert objEvent;
        String passengerJson = '{"passengerId":"1544523921002621","customerId":"23827374724","firstName":"TRITON","lastName":"CHAIRMANSLOUNGE","namePrefix":"MRS","genderTypecode":"F","paxTypeCode":null,"dateOfBirth":null,"qfFrequentFlyerNumber":"","qfTierCode":"CLQF","bookingReference":"TYDSN6","bookingCreationDate":"2018-02-02","bookingId":"86837460060226","segmentId":"10209019122211170","segmentTattoo":4,"passengerSegId":"943174852311001","offPoint":"BNE","marketingCarrier":"QF","marketingFlightNumber":"0516","bookedCabinClass":"Y","bookedReservationClass":"Q","reservationStatusCode":"HK","leg":[{"sequenceNumber":1,"originPort":"SYD","destinationPort":"BNE","checkinStatus":"CRJ","boardStatus":"NBD","seatNo":null}],"customerContactDetails":{"address":[{"passengerAssociationIndicator":"H","typeCode":"H","line1":"2/22","line2":"","line3":"","line4":"allenst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"O","line1":"3/50","line2":"","line3":"","line4":"harrisst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"B","line1":"10","line2":"shop1","line3":"","line4":"wigramst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"}],"Email":[{"passengerAssociationIndicator":"Y","contactSourceCode":"AP","contactKeyWordCode":"98789654","Id":"email@email.com"}],"phone":[{"passengerAssociationIndicator":"Y","contactSourceCode":"AP","contactKeyWordCode":"98789654","Id":"02928938383"},{"typeCode":"O","phoneCountryCode":"61","phoneAreaCode":"02","phoneLineNumber":"78906543","phoneExtension":""},{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"02","phoneLineNumber":"78965479","phoneExtension":""}]},"otherLoyaltyDetails":{"homeCity":null,"tier":{"old":null,"new":null,"changeDate":null},"domesticTravelPreference":{"meal":{"code":null,"description":null},"seat":{"code":null,"description":null}},"internationalTravelPreference":{"meal":{"code":null,"description":null},"seat":{"code":null,"description":null}},"epLinkedIndicator":null}}';
        QCC_FlightPassengersResponse.passengers psg = (QCC_FlightPassengersResponse.passengers) System.JSON.deserialize(passengerJson, QCC_FlightPassengersResponse.passengers.class);
        QCC_FlightPassengersResponse.parse(passengerJson);
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        QCC_CreatePassengerForEvents.ContactWrapper conWrap = new QCC_CreatePassengerForEvents.ContactWrapper();
        conWrap.contactId = contact1.Id;
        conWrap.ffNumber = contact1.Frequent_Flyer_Number__c;
        conWrap.preferredEmail = 'test@testemail.com';
        conWrap.preferredPhone = '49941788788';
        Set<String> travelAgentEmailDomains = new Set<String>();
        Affected_Passenger__c afp = QCC_CreatePassengerForEvents.createAffPassenger(conWrap , objEvent , psg , 'PostFlight',u1.Id, null, travelAgentEmailDomains);
        afp.counter__c = 2;
        afp.PassengerId__c = '9003443419938028';
        System.assert(afp != null);
        insert afp;
        System.assert(afp.Id != null);
        Test.startTest();   
        System.enqueueJob(new QCC_PassengerServiceDetailQueueable(objEvent, 1, 2));
        Test.stopTest();
        
    }
    
    static testMethod void deletePassengerforEvent1() {

        //   to run in the test.
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        
        // Create new contact - Update existing record
        Contact contact1 = new Contact(Firstname='Triton',Lastname='CHAIRMANSLOUNGE' , Frequent_Flyer_Number__c = '0006142202');
        insert contact1;

        Event__c objEvent = new Event__c();
        objEvent.FlightNumber__c  = 'QF0516' ;
        objEvent.ScheduledDepDate__c = Date.newInstance(2018, 03, 02);
        objEvent.DeparturePort__c  = 'SYD';
        objEvent.ArrivalPort__c = 'MEL';
        objEvent.Flight_Status__c = 'Boarding';
        objEvent.Operational_Carrier__c = 'QF';
        objEvent.TechPassenger_API_Invoked__c = false;
        insert objEvent;
        String passengerJson = '{"passengerId":"1544523921002621","customerId":"23827374724","firstName":"TRITON","lastName":"CHAIRMANSLOUNGE","namePrefix":"MRS","genderTypecode":"F","paxTypeCode":null,"dateOfBirth":null,"qfFrequentFlyerNumber":"","qfTierCode":"CLQF","bookingReference":"TYDSN6","bookingCreationDate":"2018-02-02","bookingId":"86837460060226","segmentId":"10209019122211170","segmentTattoo":4,"passengerSegId":"943174852311001","offPoint":"BNE","marketingCarrier":"QF","marketingFlightNumber":"0516","bookedCabinClass":"Y","bookedReservationClass":"Q","reservationStatusCode":"HK","leg":[{"sequenceNumber":1,"originPort":"SYD","destinationPort":"BNE","checkinStatus":"CRJ","boardStatus":"NBD","seatNo":null}],"customerContactDetails":{"address":[{"passengerAssociationIndicator":"H","typeCode":"H","line1":"2/22","line2":"","line3":"","line4":"allenst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"O","line1":"3/50","line2":"","line3":"","line4":"harrisst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"B","line1":"10","line2":"shop1","line3":"","line4":"wigramst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"}],"Email":[{"passengerAssociationIndicator":"Y","contactSourceCode":"AP","contactKeyWordCode":"98789654","Id":"email@email.com"}],"phone":[{"passengerAssociationIndicator":"Y","contactSourceCode":"AP","contactKeyWordCode":"98789654","Id":"02928938383"},{"typeCode":"O","phoneCountryCode":"61","phoneAreaCode":"02","phoneLineNumber":"78906543","phoneExtension":""},{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"02","phoneLineNumber":"78965479","phoneExtension":""}]},"otherLoyaltyDetails":{"homeCity":null,"tier":{"old":null,"new":null,"changeDate":null},"domesticTravelPreference":{"meal":{"code":null,"description":null},"seat":{"code":null,"description":null}},"internationalTravelPreference":{"meal":{"code":null,"description":null},"seat":{"code":null,"description":null}},"epLinkedIndicator":null}}';
        QCC_FlightPassengersResponse.passengers psg = (QCC_FlightPassengersResponse.passengers) System.JSON.deserialize(passengerJson, QCC_FlightPassengersResponse.passengers.class);
        QCC_FlightPassengersResponse.parse(passengerJson);
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        QCC_CreatePassengerForEvents.ContactWrapper conWrap = new QCC_CreatePassengerForEvents.ContactWrapper();
        conWrap.contactId = contact1.Id;
        conWrap.ffNumber = contact1.Frequent_Flyer_Number__c;
        conWrap.preferredEmail = 'test@testemail.com';
        conWrap.preferredPhone = '49941788788';
        Set<String> travelAgentEmailDomains = new Set<String>();
        Affected_Passenger__c afp = QCC_CreatePassengerForEvents.createAffPassenger(conWrap , objEvent , psg , 'PostFlight',u1.Id, null, travelAgentEmailDomains);
        afp.counter__c = 2;
        afp.PassengerId__c = '9003443419938028';
        System.assert(afp != null);
        insert afp;
        Affected_Passenger__c afp1 = QCC_CreatePassengerForEvents.createAffPassenger(conWrap , objEvent , psg , 'PreFlight',u1.Id, null, travelAgentEmailDomains);
        afp1.counter__c = 2;
        afp1.PassengerId__c = '9003443419938029';
        System.assert(afp1 != null);
        insert afp1;
        System.assert(afp1.Id != null);
        Test.startTest();   
        System.enqueueJob(new QCC_DeletePassengerForEvents(objEvent, 2));
        Test.stopTest();
        
    }
    
    static testMethod void deletePassengerforEvent2() {

        //   to run in the test.
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        
        // Create new contact - Update existing record
        Contact contact1 = new Contact(Firstname='Triton',Lastname='CHAIRMANSLOUNGE' , Frequent_Flyer_Number__c = '0006142202');
        insert contact1;

        Event__c objEvent = new Event__c();
        objEvent.FlightNumber__c  = 'QF0516' ;
        objEvent.ScheduledDepDate__c = Date.newInstance(2018, 03, 02);
        objEvent.DeparturePort__c  = 'SYD';
        objEvent.ArrivalPort__c = 'MEL';
        objEvent.Flight_Status__c = 'DEPARTED';
        objEvent.Operational_Carrier__c = 'QF';
        objEvent.TechPassenger_API_Invoked__c = false;
        insert objEvent;
        String passengerJson = '{"passengerId":"1544523921002621","customerId":"23827374724","firstName":"TRITON","lastName":"CHAIRMANSLOUNGE","namePrefix":"MRS","genderTypecode":"F","paxTypeCode":null,"dateOfBirth":null,"qfFrequentFlyerNumber":"","qfTierCode":"CLQF","bookingReference":"TYDSN6","bookingCreationDate":"2018-02-02","bookingId":"86837460060226","segmentId":"10209019122211170","segmentTattoo":4,"passengerSegId":"943174852311001","offPoint":"BNE","marketingCarrier":"QF","marketingFlightNumber":"0516","bookedCabinClass":"Y","bookedReservationClass":"Q","reservationStatusCode":"HK","leg":[{"sequenceNumber":1,"originPort":"SYD","destinationPort":"BNE","checkinStatus":"CRJ","boardStatus":"NBD","seatNo":null}],"customerContactDetails":{"address":[{"passengerAssociationIndicator":"H","typeCode":"H","line1":"2/22","line2":"","line3":"","line4":"allenst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"O","line1":"3/50","line2":"","line3":"","line4":"harrisst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"B","line1":"10","line2":"shop1","line3":"","line4":"wigramst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"}],"Email":[{"passengerAssociationIndicator":"Y","contactSourceCode":"AP","contactKeyWordCode":"98789654","Id":"email@email.com"}],"phone":[{"passengerAssociationIndicator":"Y","contactSourceCode":"AP","contactKeyWordCode":"98789654","Id":"02928938383"},{"typeCode":"O","phoneCountryCode":"61","phoneAreaCode":"02","phoneLineNumber":"78906543","phoneExtension":""},{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"02","phoneLineNumber":"78965479","phoneExtension":""}]},"otherLoyaltyDetails":{"homeCity":null,"tier":{"old":null,"new":null,"changeDate":null},"domesticTravelPreference":{"meal":{"code":null,"description":null},"seat":{"code":null,"description":null}},"internationalTravelPreference":{"meal":{"code":null,"description":null},"seat":{"code":null,"description":null}},"epLinkedIndicator":null}}';
        QCC_FlightPassengersResponse.passengers psg = (QCC_FlightPassengersResponse.passengers) System.JSON.deserialize(passengerJson, QCC_FlightPassengersResponse.passengers.class);
        QCC_FlightPassengersResponse.parse(passengerJson);
        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        QCC_CreatePassengerForEvents.ContactWrapper conWrap = new QCC_CreatePassengerForEvents.ContactWrapper();
        conWrap.contactId = contact1.Id;
        conWrap.ffNumber = contact1.Frequent_Flyer_Number__c;
        conWrap.preferredEmail = 'test@testemail.com';
        conWrap.preferredPhone = '49941788788';
        Set<String> travelAgentEmailDomains = new Set<String>();
        Affected_Passenger__c afp = QCC_CreatePassengerForEvents.createAffPassenger(conWrap , objEvent , psg , 'PostFlight',u1.Id, null, travelAgentEmailDomains);
        afp.counter__c = 2;
        afp.PassengerId__c = '9003443419938028';
        System.assert(afp != null);
        insert afp;
        Affected_Passenger__c afp1 = QCC_CreatePassengerForEvents.createAffPassenger(conWrap , objEvent , psg , 'PreFlight',u1.Id, null, travelAgentEmailDomains);
        afp1.counter__c = 2;
        afp1.PassengerId__c = '9003443419938029';
        System.assert(afp1 != null);
        insert afp1;
        System.assert(afp1.Id != null);
        Test.startTest();   
        System.enqueueJob(new QCC_DeletePassengerForEvents(objEvent, 2));
        Test.stopTest();
        
    }
    
    //Jira: CRM-5590: Fligth Event - Missing Emails
    static testMethod void createAffPassengerWithFFNPassAssIndN() {

        //   to run in the test.
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        
        // Create new contact - Update existing record
        Contact contact1 = new Contact(Firstname='Triton',Lastname='CHAIRMANSLOUNGE');
        insert contact1;

        Event__c objEvent = new Event__c();
        objEvent.FlightNumber__c  = 'QF0516' ;
        objEvent.ScheduledDepDate__c = Date.newInstance(2018, 03, 02);
        objEvent.DeparturePort__c  = 'SYD';
        objEvent.ArrivalPort__c = 'SYD';
        objEvent.Flight_Status__c = 'Boarding';
        objEvent.Operational_Carrier__c = 'QF';
        objEvent.TechPassenger_API_Invoked__c = false;
        insert objEvent;
        String passengerJson = '{"passengerId":"1544523921002621","customerId":"23827374724","firstName":"TRITON","lastName":"CHAIRMANSLOUNGE","namePrefix":"MRS","genderTypecode":"F","paxTypeCode":null,"dateOfBirth":null,"qfFrequentFlyerNumber":"","qfTierCode":"CLQF","bookingReference":"TYDSN6","bookingCreationDate":"2018-02-02","bookingId":"86837460060226","segmentId":"10209019122211170","segmentTattoo":4,"passengerSegId":"943174852311001","offPoint":"BNE","marketingCarrier":"QF","marketingFlightNumber":"0516","bookedCabinClass":"Y","bookedReservationClass":"Q","reservationStatusCode":"HK","leg":[{"sequenceNumber":1,"originPort":"SYD","destinationPort":"BNE","checkinStatus":"CRJ","boardStatus":"NBD","seatNo":null}],"ContactDetails":{"address":[{"typeCode":"H","line1":"2/22","line2":"","line3":"","line4":"allenst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"O","line1":"3/50","line2":"","line3":"","line4":"harrisst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"B","line1":"10","line2":"shop1","line3":"","line4":"wigramst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"}],"Email":[{"passengerAssociationIndicator":"N","contactSourceCode":"SSR","contactKeyWordCode":"98789654","Id":"email@email.com"}],"phone":[{"passengerAssociationIndicator":"Y","contactSourceCode":"AP","contactKeyWordCode":"98789654","Id":"02928938383"},{"typeCode":"O","phoneCountryCode":"61","phoneAreaCode":"02","phoneLineNumber":"78906543","phoneExtension":""},{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"02","phoneLineNumber":"78965479","phoneExtension":""}]},"otherLoyaltyDetails":{"homeCity":null,"tier":{"old":null,"new":null,"changeDate":null},"domesticTravelPreference":{"meal":{"code":null,"description":null},"seat":{"code":null,"description":null}},"internationalTravelPreference":{"meal":{"code":null,"description":null},"seat":{"code":null,"description":null}},"epLinkedIndicator":null}}';
        QCC_FlightPassengersResponse.passengers psg = (QCC_FlightPassengersResponse.passengers) System.JSON.deserialize(passengerJson, QCC_FlightPassengersResponse.passengers.class);

        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        QCC_CreatePassengerForEvents.ContactWrapper conWrap = new QCC_CreatePassengerForEvents.ContactWrapper();
        conWrap.contactId = contact1.Id;
        conWrap.ffNumber = contact1.Frequent_Flyer_Number__c;
        conWrap.preferredEmail = 'test@testemail.com';
        conWrap.preferredPhone = '49941788788';
        Set<String> travelAgentEmailDomains = new Set<String>();
        Affected_Passenger__c afp = QCC_CreatePassengerForEvents.createAffPassenger(conWrap , objEvent , psg , 'PostFlight', u1.Id, null, travelAgentEmailDomains);
        afp.counter__c = 2;
        System.assert(afp != null);
        insert afp;
        System.assert(afp.Id != null);

        Test.startTest();   
        QCC_UpdateEventFlightInfoController.updatePassengerforEvent(objEvent.Id);
        Test.stopTest();
        
    }


    //Jira: CRM-5590: Fligth Event - Missing Emails
    static testMethod void createAffPassengerWithFFNPassAssIndNToPhone() {

        //   to run in the test.
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        
        // Create new contact - Update existing record
        Contact contact1 = new Contact(Firstname='Triton',Lastname='CHAIRMANSLOUNGE');
        insert contact1;

        Event__c objEvent = new Event__c();
        objEvent.FlightNumber__c  = 'QF0516' ;
        objEvent.ScheduledDepDate__c = Date.newInstance(2018, 03, 02);
        objEvent.DeparturePort__c  = 'SYD';
        objEvent.ArrivalPort__c = 'SYD';
        objEvent.Flight_Status__c = 'Boarding';
        objEvent.Operational_Carrier__c = 'QF';
        objEvent.TechPassenger_API_Invoked__c = false;
        insert objEvent;
        String passengerJson = '{"passengerId":"1544523921002621","customerId":"23827374724","firstName":"TRITON","lastName":"CHAIRMANSLOUNGE","namePrefix":"MRS","genderTypecode":"F","paxTypeCode":null,"dateOfBirth":null,"qfFrequentFlyerNumber":"","qfTierCode":"CLQF","bookingReference":"TYDSN6","bookingCreationDate":"2018-02-02","bookingId":"86837460060226","segmentId":"10209019122211170","segmentTattoo":4,"passengerSegId":"943174852311001","offPoint":"BNE","marketingCarrier":"QF","marketingFlightNumber":"0516","bookedCabinClass":"Y","bookedReservationClass":"Q","reservationStatusCode":"HK","leg":[{"sequenceNumber":1,"originPort":"SYD","destinationPort":"BNE","checkinStatus":"CRJ","boardStatus":"NBD","seatNo":null}],"ContactDetails":{"address":[{"typeCode":"H","line1":"2/22","line2":"","line3":"","line4":"allenst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"O","line1":"3/50","line2":"","line3":"","line4":"harrisst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"B","line1":"10","line2":"shop1","line3":"","line4":"wigramst","suburb":"Harrispark","postCode":"2150","state":"nsw","country":"AU","countryName":"AUSTRALIA"}],"Email":[{"passengerAssociationIndicator":"N","contactSourceCode":"OS","contactKeyWordCode":"98789654","Id":"email@email.com"}],"phone":[{"passengerAssociationIndicator":"Y","contactSourceCode":"SSR","contactKeyWordCode":"98789654","Id":"02928938383"},{"typeCode":"O","phoneCountryCode":"61","phoneAreaCode":"02","phoneLineNumber":"78906543","phoneExtension":""},{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"02","phoneLineNumber":"78965479","phoneExtension":""}]},"otherLoyaltyDetails":{"homeCity":null,"tier":{"old":null,"new":null,"changeDate":null},"domesticTravelPreference":{"meal":{"code":null,"description":null},"seat":{"code":null,"description":null}},"internationalTravelPreference":{"meal":{"code":null,"description":null},"seat":{"code":null,"description":null}},"epLinkedIndicator":null}}';
        QCC_FlightPassengersResponse.passengers psg = (QCC_FlightPassengersResponse.passengers) System.JSON.deserialize(passengerJson, QCC_FlightPassengersResponse.passengers.class);

        User u1 = [SELECT Id FROM User WHERE Username = 'sampleuser1username@sample.com'];
        QCC_CreatePassengerForEvents.ContactWrapper conWrap = new QCC_CreatePassengerForEvents.ContactWrapper();
        conWrap.contactId = contact1.Id;
        conWrap.ffNumber = contact1.Frequent_Flyer_Number__c;
        conWrap.preferredEmail = 'test@testemail.com';
        conWrap.preferredPhone = '49941788788';
        Set<String> travelAgentEmailDomains = new Set<String>();
        Affected_Passenger__c afp = QCC_CreatePassengerForEvents.createAffPassenger(conWrap , objEvent , psg , 'PostFlight', u1.Id, null, travelAgentEmailDomains);
        afp.counter__c = 2;
        System.assert(afp != null);
        insert afp;
        System.assert(afp.Id != null);

        Test.startTest();   
        QCC_UpdateEventFlightInfoController.updatePassengerforEvent(objEvent.Id);
        Test.stopTest();
        
    }
    
}