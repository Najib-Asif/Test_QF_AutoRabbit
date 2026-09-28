/*--------------------------------------------------------------------------------------     
16-Dec-2025   Jonathan-Capgemini      CRM-10357 Code Security Remediation, PSV changes for System and User Mode for SOQL   
----------------------------------------------------------------------------------------*/ 
@IsTest
public class QCC_DisplayPAXControllerTest {
	@TestSetup
    static public void setupData(){
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.enableTriggers();
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Qantas_API__c> lstQAPI = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQAPI;
        TestUtilityDataClassQantas.insertQantasConfigData();
        lsttrgStatus = TestUtilityDataClassQantas.createEventTriggerSetting();
        for(Trigger_Status__c ts : lsttrgStatus){
            ts.Active__c = false;
        }
        insert lsttrgStatus;

        lsttrgStatus = TestUtilityDataClassQantas.createAffectedPassengerTriggerSetting();
        for(Trigger_Status__c ts : lsttrgStatus){
            ts.Active__c = false;
        }
        insert lsttrgStatus;

        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;

        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        // Replacing the Run as user profile with QCC Contact Center Agent profile and adding QCC Base,Contact Center and Genesys permission sets on the user as part of RBAC CRM-11628               
        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                           Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('QCC Contact Center Agent Manila').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                           TimeZoneSidKey = 'Australia/Sydney', City='Manila', Location__c = 'Manila'
                          );
        insert u1;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            List<Id> permissionSetIds = TestUtilityDataClassQantas.getPermissionSetIds('QCC_Base_User_Permissions,QCC_Contact_Center_Agent_Permissions,QCC_Genesys_User_Permissions');
            List<PermissionSetAssignment> psaList = TestUtilityDataClassQantas.createPermissionSetAssignments(u1.Id,permissionSetIds);
        }
        List<Contact> contacts = new List<Contact>();
        
        System.runAs(u1) {

            for(Integer i = 0; i < 2; i++) {
                Contact con = new Contact(LastName='Sample'+i, FirstName='User', Business_Types__c='Agency', Job_Role__c='Agency Manager', 
                                          Function__c='Advisory Services', Email='test@sample.com', MailingStreet = '15 hobart rd', 
                                          MailingCity = 'south launceston', MailingState = 'TAS', MailingPostalCode = '7249', 
                                          CountryName__c = 'Australia', Frequent_Flyer_tier__c   = 'Platinum', Frequent_Flyer_Number__c = '12345' + i);
                con.CAP_ID__c = '71000000001'+ (i+7);
                contacts.add(con);
            }
            insert contacts;
        }
        
        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            contacts = [SELECT Id, Name, firstname, lastname,Cap_ID__c FROM Contact];
            List<Case> cases = new List<Case>();
            for(Contact con: contacts) {
                Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
                cs.Origin = 'Qantas.com';
                cs.Booking_PNR__c = 'K5F5ZE';
                cs.Flight_Number__c = 'QF0401';
                cs.ContactId = con.Id;
                cs.Airline__c = 'Qantas';
                cs.Suburb__c = 'NSW';
                cs.Street__c = 'Jackson';
                cs.State__c = 'Mascot';
                cs.Post_Code__c = '20020';
                cs.Country__c = 'Australia';
                cs.Cabin_Class__c = 'Business';
                cs.TECH_bookingCreationDate__c = '05/11/2018';
                cs.TECH_bookingArchivalData__c = 'false';
                cs.TECH_BookingSegmentId__c = '9178306296255759';
                cases.add(cs);
            }
            insert cases;

            Affected_Passenger__c afp = new Affected_Passenger__c();
            afp.Name = contacts[0].FirstName +' ' +contacts[0].lastName;
            afp.Passenger__c = contacts[0].id;
            afp.firstName__c = contacts[0].firstName;
            afp.lastName__c = contacts[0].lastName;
            afp.PNR__c = cases[0].Booking_PNR__c;
            afp.case__c = cases[0].Id;
            afp.passengerId__c = '8956328947991887';
            afp.recordtypeId = GenericUtils.getObjectRecordTypeId('Affected_Passenger__c', 'Insurance Letter');

            insert afp;
        }
    }

    @IsTest
    public static void testInit(){
    	String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","currentPassengerQuantity":"2","lastUpdatedTimeStamp":"05/12/2017 04:28:00","passengers":[{"passengerId":"8956328947991887","passengerTattoo":"2","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"STEVE","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CC","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000017"},{"passengerId":"9018991125607359","passengerTattoo":"3","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"MARK","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CD","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000018"}]}}';
    	Map<String, String> mapHeader= new Map<String, String>();
		mapHeader.put('Content-Type', 'application/json');
    	Test.startTest();
    	Case cs = [select id from case limit 1];
		Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
		String result = QCC_DisplayPAXController.initialize(cs.id);
		
		system.assert(result != Null);
		Test.stopTest();
    }

    @IsTest
    public static void testDelete(){
    	Test.startTest();
    	Case cs = [select id from case limit 1];
		List<String> lstStr = new List<String>();
		lstStr.add('8956328947991887');
		List<String> result = QCC_DisplayPAXController.deleteAffectedPassenger(cs.id, lstStr);
		
		system.assert(result.size() > 0);
		Test.stopTest();
    }

    @IsTest
    public static void testInsert(){
    	Test.startTest();
	    	Case cs = [select id from case limit 1];	
			List<String> lstStr = new List<String>();
			lstStr.add('{"passengerId":"8956328947991887","passengerTattoo":"2","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"STEVE","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CC","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000017"}');
			lstStr.add('{"passengerId":"9018991125607359","passengerTattoo":"3","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"MARK","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CD","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000018"}');
			lstStr.add('{"passengerId":"9018991125607358","passengerTattoo":"3","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"MARK","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CD","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000019"}');
        	Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
			List<String> result = QCC_DisplayPAXController.createAffectedPassenger(cs.id, lstStr, null, false);
			
			system.assert(result.size() > 0);
		Test.stopTest();
    }
	//CRM-10357:Method added to support Code Security Remediation changes
     @IsTest
    public static void testInsertV2(){
    	Test.startTest();
	    	Case cs = [select id from case limit 1];	
			List<String> lstStr = new List<String>();
			lstStr.add('{"passengerId":"8956328947991887","passengerTattoo":"2","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"STEVE","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CC","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000017"}');
			lstStr.add('{"passengerId":"9018991125607359","passengerTattoo":"3","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"MARK","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CD","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000018"}');
			lstStr.add('{"passengerId":"9018991125607358","passengerTattoo":"3","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"MARK","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CD","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000019"}');
        	Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
			List<String> result = QCC_DisplayPAXController.createAffectedPassengerV2(cs.id, lstStr, null, false);				
		Test.stopTest();
    }
}