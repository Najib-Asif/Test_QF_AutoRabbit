@Istest
public with sharing class QCC_CasePNRSearchFlowControllerTest {

	@TestSetUp
	public static void TestSetUp(){
		TestUtilityDataClassQantas.insertQantasConfigData();
        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        for(Trigger_Status__c ts : lsttrgStatus){
            ts.Active__c = false;
        }
        insert lsttrgStatus; 
        List<Qantas_API__c> listQantasAPI = TestUtilityDataClassQantas.createQantasAPI();
        insert listQantasAPI;

        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        // Replacing the Run as user profile with QCC Contact Center Agent profile and adding QCC Base,Contact Center and Genesys permission sets on the user as part of RBAC CRM-11628               
        User user1_Consultant = new User(FirstName = 'User1',
                                         LastName = 'Consultant',
                                         Email = 'user1Consultant@yopmail.com',
                                         CompanyName = 'test.com',
                                         Title = 'User1 Consultant',
                                         Username = 'user1Consultant@yopmail.com',
                                         Alias = 'user1',
                                         ProfileId = profMap.get('QCC Contact Center Agent Manila').Id,
                                         Location__c = 'Manila',
                                         EmailEncodingKey = 'UTF-8',
                                         LanguageLocaleKey = 'en_US',
                                         LocaleSidKey = 'en_AU',
                                         TimeZoneSidKey = 'Australia/Sydney'
                                        );
        insert user1_Consultant;
        System.runAs(new User(Id = UserInfo.getUserId())) {
     		List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(user1_Consultant.Id,permissionSetIds);
        }
        
        list<queuesObject> listQO = [select id, QueueId from QueuesObject where SobjectType ='Case'];
        Group g = [select id, name from Group where id = :listQO[0].QueueId and Type='Queue' order by Name limit 1];        
        
        List<Contact> contacts = new List<Contact>();
        
        System.runAs(user1_Consultant) {
            
            for(Integer i = 0; i < 1; i++) {
                Contact con = new Contact(LastName='Sample'+i, FirstName='User', Business_Types__c='Agency', Job_Role__c='Agency Manager', 
                                          Function__c='Advisory Services', Email='test@sample.com', MailingStreet = '15 hobart rd', 
                                          MailingCity = 'south launceston', MailingState = 'TAS', MailingPostalCode = '7249', 
                                          CountryName__c = 'Australia', Frequent_Flyer_tier__c   = 'Silver', Frequent_Flyer_Number__c = '12345');
                con.CAP_ID__c = '71000000001'+ (i+7);
                contacts.add(con);
            }
            insert contacts;
        }
        
        System.runAs(user1_Consultant) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            contacts = [SELECT Id FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = 'MC755T';
                cs.Flight_Number__c = 'QF0401';
                cs.ContactId = con.Id;
                cs.Airline__c = 'Qantas';
                cs.Suburb__c = 'NSW';
                cs.Street__c = 'Jackson';
                cs.State__c = 'Mascot';
                cs.Post_Code__c = '20020';
                cs.Country__c = 'Australia';
                cs.Last_Name__c ='FrequentFlyer';
                cs.First_Name__c ='Gold';
                cs.Last_Queue_Owner__c = g.id;
                cs.Last_Queue_Owner_Name__c = g.Name;
                cs.Frequent_Flyer_Number__c = '12345';
                cases.add(cs);
            }
            insert cases;
        }
	}

	@IsTest
	public static void testFetchCAPBooking(){
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
						+'            "marketingFlightNumber":"0009",'
						+'            "marketingFlightSuffix":null,'
						+'            "departureAirportCode":"MEL",'
						+'            "arrivalAirportCode":"LHR",'
						+'            "operatingCarrierAlphaCode":"QF",'
						+'            "operatingFlightNumber":"0009",'
						+'            "operatingFlightSuffix":null,'
						+'            "departureCityCode":"MEL",'
						+'            "arrivalCityCode":"LON",'
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
            Test.setMock(HttpCalloutMock.class, new QCC_CAPFlightInfoMock(200, 'Success', Body, mapHeader));
            Test.startTest();
            Case cs = [select id, Last_Name__c, First_Name__c, Booking_PNR__c FROM Case limit 1];
            QCC_BookingSummaryWrapper bookingInfo = QCC_CasePNRSearchFlowController.fetchCAPBooking(cs.id, cs.Booking_PNR__c, false);
            Test.stopTest();
            System.assertEquals(bookingInfo.bookings[0].reloc, 'MC755T');
	}

	@IsTest
	public static void testFetchCAPBooking_null(){
		Map<String, String> mapHeader = new Map<String, String>();
            String body = '';
            Test.setMock(HttpCalloutMock.class, new QCC_CAPFlightInfoMock(200, 'Success', Body, mapHeader));
            Test.startTest();
            Case cs = [select id, Last_Name__c, First_Name__c, Booking_PNR__c FROM Case limit 1];
            QCC_BookingSummaryWrapper bookingInfo = QCC_CasePNRSearchFlowController.fetchCAPBooking(cs.id, cs.Booking_PNR__c, false);
            Test.stopTest();
            System.assertEquals(bookingInfo, null);
	}
}