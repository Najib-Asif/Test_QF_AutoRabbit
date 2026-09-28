/*==================================================================================================================================
Author:         Praveen Sampath
Company:        Capgemini
Purpose:        Test Class for ProductRegistrationTrigger Trigger. All functionalities of ProductRegistrationTriggerHelper are covered.
Date:           28/04/2017          
History:

==================================================================================================================================

==================================================================================================================================*/

@isTest(SeeAllData = false)
private class QCC_DisplayBookingControllerTest {
    
    //Create all Test Data 
    @testSetup
    static void createTestData(){
        //Enable Account, Contact,Case Triggers
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        insert lsttrgStatus;

        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;

        TestUtilityDataClassQantas.insertQantasConfigData();

        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
        insert lstConfigData;

        //Create Account
        Account objAcc = TestUtilityDataClassQantas.createAccount();
        objAcc.Airline_Level__c = '1';
        objAcc.Active__c = true;
        insert objAcc;
        system.assert(objAcc != Null, 'Account is not inserted');

        //Create Contact
        Contact objContact = TestUtilityDataClassQantas.createContact(objAcc.Id);
        objContact.LastName='ContTest2';
        objContact.CAP_ID__c='710000000017';
        insert objContact;
        system.assert(objContact.Id != Null, 'Contact is not inserted');

        //Create Case
        List<Contact> lstContact = new List<Contact>();
        lstContact.add(objContact);
        String recordType = 'CCC Complaints';
        String type = 'Complaints';
        List<Case> lstCase = TestUtilityDataClassQantas.insertCases(lstContact, recordType, type, 'Qantas.com','','','');
        system.assert(lstCase.size()>0, 'Case List is Zero');
        system.assert(lstCase[0].Id != Null, 'Case is not inserted');
    }
    //Commenting this method as part of CRM-6052
/*
    static TestMethod void fetchCAPBooking_PositiveContactTest() {
        Contact objCon = [select Id from Contact limit 1];
        String Body = '{"bookings":[{"reloc":"MWYX4S","travelPlanId":"950121165952060","bookingId":"950121165952060","creationDate":"2017-12-22","currentPassengerQuantity":"3","segmentType":"AIR","departureTimeStamp":"01/03/2018 01:35:00","departurePort":"BNE","departureCity":"BNE","arrivalPort":"PER","arrivalCity":"PER","lastUpdatedTimeStamp":"15/01/2018 23:25:00","archivalData":"false"},{"reloc":"MWYG78","travelPlanId":"950121165930116","bookingId":"950121165930116","creationDate":"2017-12-22","currentPassengerQuantity":"3","segmentType":"AIR","departureTimeStamp":"15/02/2018 02:40:00","departurePort":"CBR","departureCity":"CBR","arrivalPort":"MEL","arrivalCity":"MEL","lastUpdatedTimeStamp":"15/01/2018 23:26:00","archivalData":"false"}],"activeCustomerId":"710000000060"}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_BookingSummaryWrapper booking = QCC_DisplayBookingController.fetchCAPBooking(objCon.Id, 1);
        system.assert(booking != Null, 'Contact Method Response is Blank');

        Test.stopTest();
    }

    static TestMethod void fetchCAPBooking_PositiveCaseTest() {
        Case objCase = [select Id from Case limit 1];
        String Body = '{"bookings":[{"reloc":"MWYX4S","travelPlanId":"950121165952060","bookingId":"950121165952060","creationDate":"2017-12-22","currentPassengerQuantity":"3","segmentType":"AIR","departureTimeStamp":"01/03/2018 01:35:00","departurePort":"BNE","departureCity":"BNE","arrivalPort":"PER","arrivalCity":"PER","lastUpdatedTimeStamp":"15/01/2018 23:25:00","archivalData":"false"},{"reloc":"MWYG78","travelPlanId":"950121165930116","bookingId":"950121165930116","creationDate":"2017-12-22","currentPassengerQuantity":"3","segmentType":"AIR","departureTimeStamp":"15/02/2018 02:40:00","departurePort":"CBR","departureCity":"CBR","arrivalPort":"MEL","arrivalCity":"MEL","lastUpdatedTimeStamp":"15/01/2018 23:26:00","archivalData":"false"}],"activeCustomerId":"710000000060"}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_BookingSummaryWrapper booking = QCC_DisplayBookingController.fetchCAPBooking(objCase.Id, 1);
        system.assert(booking != Null, 'Case Method Response is Blank');
        Test.stopTest();
    }

    static TestMethod void fetchCAPBooking_NegativeTest() {
        //Contact objCon = [select Id from Contact limit 1];
        String body ='{ "errorCode": 407, "errorDesc": "No customer or booking found for the given search criteria" }';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(400, 'Bad Request', body, mapHeader));
        QCC_BookingSummaryWrapper booking = QCC_DisplayBookingController.fetchCAPBooking('', 1);
        system.assert(booking == Null, 'Exception Response is not Blank');
        Test.stopTest();
    }
    */
    
    /*--------------------------------------------------------------------------------------      
	Author: 			Mallikarjuna    
	Method Name:        fetchCAPBookingViaFFNumber_PositiveCaseTest
    Description:        Test method for QCC_DisplayBookingController.fetchCAPBookingViaFFNumber. Jira: CRM-6052
    --------------------------------------------------------------------------------------*/ 
    static TestMethod void fetchCAPBookingViaFFNumber_PositiveCaseTest() {
        Case objCase = [select Id from Case limit 1];
        String Body = '{"flights":[{"travelPlanId": "649489636678300","bookingId": "649489636678300","reloc": "6EJ924","creationDate": "15/12/2021","currentPassengerQuantity": 1,"segmentId": "9831123330267547","segmentTattoo": 2,"marketingCarrierAlphaCode": "QF","marketingFlightNumber": "0401","marketingFlightSuffix": null,"departureLocalDate": "30/01/2022","departureLocalTime": "06:00:00","departureUTCTimestamp": "29/01/2022 20:00:00","estimateDepartureLocalDate": null,"estimateDepartureLocalTime": null,"actualDepartureLocalDate": null,"actualDepartureLocalTime": null,"arrivalLocalDate": "30/01/2022","arrivalLocalTime": "07:35:00","estimateArrivalLocalDate": null,"estimateArrivalLocalTime": null,"actualArrivalLocalDate": null,"actualArrivalLocalTime": null,"informationalSegment": false,"dateVariance": 0,"departureAirportCode": "SYD","departureCityCode": "SYD","departureCityName": "SYDNEY","arrivalAirportCode": "MEL","arrivalCityCode": "MEL","arrivalCityName": "MELBOURNE","reservationStatusCode": "HK","operatingCarrierAlphaCode": "QF","operatingFlightNumber": "0401","operatingFlightSuffix": null,"classOfService": "U","cabin": "J},{"travelPlanId": "649489636678300","bookingId": "649489636678300","reloc": "6EJ924","creationDate": "15/12/2021","currentPassengerQuantity": 1,"segmentId": "9831123330267547","segmentTattoo": 2,"marketingCarrierAlphaCode": "QF","marketingFlightNumber": "0401","marketingFlightSuffix": null,"departureLocalDate": "30/01/2022","departureLocalTime": "06:00:00","departureUTCTimestamp": "29/01/2022 20:00:00","estimateDepartureLocalDate": null,"estimateDepartureLocalTime": null,"actualDepartureLocalDate": null,"actualDepartureLocalTime": null,"arrivalLocalDate": "30/01/2022","arrivalLocalTime": "07:35:00","estimateArrivalLocalDate": null,"estimateArrivalLocalTime": null,"actualArrivalLocalDate": null,"actualArrivalLocalTime": null,"informationalSegment": false,"dateVariance": 0,"departureAirportCode": "SYD","departureCityCode": "SYD","departureCityName": "SYDNEY","arrivalAirportCode": "MEL","arrivalCityCode": "MEL","arrivalCityName": "MELBOURNE","reservationStatusCode": "HK","operatingCarrierAlphaCode": "QF","operatingFlightNumber": "0401","operatingFlightSuffix": null,"classOfService": "U","cabin": "J}],"activeCustomerId":"710000000060"}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_CustomerFlightsWrapper.CustomerFlightsWrapper booking = QCC_DisplayBookingController.fetchCAPBookingViaFFNumber(objCase.Id, 1);
        system.assert(booking == Null, 'Case Method Response is Blank');
        Test.stopTest();
    }
}