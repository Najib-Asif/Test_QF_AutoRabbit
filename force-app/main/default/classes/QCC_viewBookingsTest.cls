/********
* Created By : Van Cabezas | ACN | Developer 
* Purpose : Test Class for QantasExtension
* REST API : No Rest API Needed

Modified Date   : 21/04/23 (DD/MM/YYYY)
Modified By     : Van Cabezas
Version         : 1.2 -Initial Development | van
*/
@isTest
private class QCC_viewBookingsTest {
	
    @testSetup
    static void createCaseData(){       
        List<Trigger_Status__c> onScreenCase = TestUtilityDataClassQantas.enableTriggers();
        List<Trigger_Status__c> statToUpdate = new List<Trigger_Status__c>();
        for(Trigger_Status__c triggerStat : onScreenCase){
            triggerStat.Active__c = false;
            statToUpdate.add(triggerStat);
        }
        update statToUpdate;
        Trigger_Status__c ts1 = new Trigger_Status__c(); 
        ts1.Name = 'QCC_SetNonFFContactOnCase'; 
        ts1.Active__c = false; insert ts1;
        
        Trigger_Status__c ts2 = new Trigger_Status__c(); 
        ts2.Name = 'CCCVoice_CaseTrigger_Switch'; 
        ts2.Active__c = false; 
        insert ts2;
        
    }
    
    @isTest
    static void testViewBookings(){
        TestUtilityDataClassQantas.insertQantasConfigData();
        
        List<Qantas_API__c> lstQantasASPI = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantasASPI;
        
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_ContactEmail', 'test@mailinator.com'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_NoReplyContactLastName', 'QCC_NoReplyContactLastName'));
        
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('LoyaltyAPIValidationLevel','NUMBER'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('LoyaltyAPIPartnerID','DIAMD01'));
        insert lstConfigData;
        List<String> ffNumberList = new List<String>();
        ffNumberList.add('2002915284');
        string testDataFlightProd = '{"flights":[{"travelPlanId":"1289877844076994","bookingId":"1289877844076994","reloc":"6AQQBM","creationDate":"30/03/2023","currentPassengerQuantity":1,"segmentId":"572564557998906","segmentTattoo":5,"marketingCarrierAlphaCode":"QF","marketingFlightNumber":"0128","marketingFlightSuffix":null,"departureLocalDate":"18/04/2023","departureLocalTime":"19:30:00","departureUTCTimestamp":"18/04/202311:30:00","estimateDepartureLocalDate":"18/04/2023","estimateDepartureLocalTime":"19:40:00","actualDepartureLocalDate":"18/04/2023","actualDepartureLocalTime":"19:47:00","arrivalLocalDate":"19/04/2023","arrivalLocalTime":"06:55:00","estimateArrivalLocalDate":"19/04/2023","estimateArrivalLocalTime":"06:45:00","actualArrivalLocalDate":"19/04/2023","actualArrivalLocalTime":"06:51:00","informationalSegment":false,"dateVariance":1,"departureAirportCode":"HKG","departureCityCode":"HKG","departureCityName":"HONGKONG","arrivalAirportCode":"SYD","arrivalCityCode":"SYD","arrivalCityName":"SYDNEY","reservationStatusCode":"HK","operatingCarrierAlphaCode":"QF","operatingFlightNumber":"0128","operatingFlightSuffix":null,"classOfService":"J","cabin":"J"},{"travelPlanId":"1289877843683293","bookingId":"1289877843683293","reloc":"6AIAJH","creationDate":"30/03/2023","currentPassengerQuantity":2,"segmentId":"8812510763250135","segmentTattoo":1,"marketingCarrierAlphaCode":"QF","marketingFlightNumber":"0127","marketingFlightSuffix":null,"departureLocalDate":"12/04/2023","departureLocalTime":"10:15:00","departureUTCTimestamp":"12/04/202300:15:00","estimateDepartureLocalDate":"12/04/2023","estimateDepartureLocalTime":"13:15:00","actualDepartureLocalDate":"12/04/2023","actualDepartureLocalTime":"13:10:00","arrivalLocalDate":"12/04/2023","arrivalLocalTime":"17:55:00","estimateArrivalLocalDate":"12/04/2023","estimateArrivalLocalTime":"20:30:00","actualArrivalLocalDate":"12/04/2023","actualArrivalLocalTime":"19:55:00","informationalSegment":false,"dateVariance":0,"departureAirportCode":"SYD","departureCityCode":"SYD","departureCityName":"SYDNEY","arrivalAirportCode":"HKG","arrivalCityCode":"HKG","arrivalCityName":"HONGKONG","reservationStatusCode":"HK","operatingCarrierAlphaCode":"QF","operatingFlightNumber":"0127","operatingFlightSuffix":null,"classOfService":"C","cabin":"J"}],"nextPage":2},{"reloc":"6AIAJH","bkgRtid":"1289877843683293","currPaxQty":2,"Ticket":[{"airCarrNumCode":"081","airCarrAlphaCode":"QF","electrTktgIndc":"ET","acctblDocNumber":"2334178136","paxId":"470680090010943"},{"airCarrNumCode":"081","airCarrAlphaCode":"QF","electrTktgIndc":"ET","acctblDocNumber":"2334178136","paxId":"470680090010943"},{"airCarrNumCode":"081","airCarrAlphaCode":"QF","electrTktgIndc":"ET","acctblDocNumber":"2334178137","paxId":"10228117558198096"},{"airCarrNumCode":"081","airCarrAlphaCode":"QF","electrTktgIndc":"ET","acctblDocNumber":"2334178137","paxId":"10228117558198096"}]}';
        
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        List<QCC_viewBookingWrapper> listOfBookings = new List<QCC_viewBookingWrapper>();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', testDataFlightProd, mapHeader));
        listOfBookings = QCC_viewBookings.getBookingsDetails(ffNumberList,1);
        system.debug('debug here >>>>>>>>>>>' + listOfBookings);
        Test.stopTest();
        System.assertEquals('6AQQBM', listOfBookings[0].pnr);
        System.assertEquals('HKG', listOfBookings[0].departureAirportCode);
        System.assertEquals('SYD', listOfBookings[0].arrivalAirportCode);
        System.assertEquals('18/04/2023 19:30:00', listOfBookings[0].departureLocalDate);
        System.assertEquals('', listOfBookings[0].reservationStatusCode);
        System.assertEquals('', listOfBookings[0].ticketStatus);
        System.assertEquals(false, listOfBookings[0].lastPage);
        System.assertEquals('2023-03-30', listOfBookings[0].creationDate);
        System.assertEquals(null, listOfBookings[0].errMsg);
    }
    @isTest
    static void getContactForBookingDetailsTest(){
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Map<String, StaticResource> resourceMap = new Map<String, StaticResource>();
        for(StaticResource sr : [SELECT Id, Name, Body FROM StaticResource WHERE Name LIKE 'QCCTestData%']) {
            resourceMap.put(sr.Name, sr);
        }
        String contactJSON = resourceMap.get('QCCTestData_ADT_Contact').Body.toString();
        contactJSON = contactJSON.replaceAll('RecordTypeIdValue', contactRecordTypeId);
        List<sObject> contactRecord = (List<sObject>) JSON.deserialize(contactJSON, List<sObject>.class);
        insert contactRecord;
        Contact insertedContact = [SELECT Frequent_Flyer_Number__c FROM Contact Where id =: contactRecord[0].id];
        test.startTest();
        List<Contact> getContact = QCC_viewBookings.getContactForBookingDetails(contactRecord[0].id);
        test.stopTest();
        
        System.assertEquals(insertedContact.Frequent_Flyer_Number__c, getContact[0].Frequent_Flyer_Number__c);
        
    }
}