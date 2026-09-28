/*----------------------------------------------------------------------------------------------------------------------
Author:        Benazir Amir/Praveen Sampath
Company:       Capgemini
Description:   Test Class for AssetTrigger Helper
Inputs:
Test Class:    Not Required
************************************************************************************************
History
************************************************************************************************
05-Feb-2018    Praveen Sampath   Initial Design
-----------------------------------------------------------------------------------------------------------------------*/
@isTest(seeAllData = false)
private class QCC_InvokeCAPAPITest {

    @testSetup
    static void createTestData(){
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;

        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('LoyaltyAPIValidationLevel','NUMBER'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('LoyaltyAPIPartnerID','DIAMD01'));
        insert lstConfigData;
        
        Trigger_Status__c triggerStatus = new Trigger_Status__c();
        triggerStatus.Name = 'UseNamedCred';
        triggerStatus.Active__c = false;
        insert triggerStatus;
    }

    static TestMethod void getCAPValidNewTokenTest(){
        Qantas_API__c qAPI = [select Id from Qantas_API__c where Name = 'QCC_CAPToken'];
        qAPI.Token__c = '';
        update qAPI;
        String Body = '{"token_type":"bearer","expires_in":172800,"access_token":"71c6f08c68fac962cf08b4667206043e79a66ef6"}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        String token = QCC_GenericUtils.getCAPValidToken('QCC_CAPToken');
        system.assert(String.isNotBlank(token), 'Token is not returned from CAP');
        String token1 = QCC_GenericUtils.getAPIGatewayValidToken('QCC_CAPToken');
        system.assert(String.isNotBlank(token1), 'Token1 is not returned from CAP');

        Test.stopTest();
    }

    static TestMethod void invokeTokenCapAPITest() {
        String Body = '{"token_type":"bearer","expires_in":172800,"access_token":"71c6f08c68fac962cf08b4667206043e79a66ef6"}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Qantas_API__c objQantas = [ Select Name, ClientId__c, ClientSecret__c, EndPoint__c, GrantType__c,
                                    Method__c, Token__c, LastModifiedDate from Qantas_API__c where Name =: 'QCC_BookingToken'];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_CAPTokenWrapper wrap = QCC_InvokeCAPAPI.invokeTokenCapAPI(objQantas);
        system.assert(wrap != Null, 'invokeTokenCapAPI returns Null');
        Test.stopTest();
    }
    
	static TestMethod void testInvokeFeeWaiverAPIWithQantasAPI() {   
        
         Qantas_API__c qantasAPI = [select Id, Name,EndPoint__c,ClientId__c, ClientSecret__c from Qantas_API__c where Name ='QCC_FeeWaiverAPI'];
        
        String Body = '{"token_type":"bearer","expires_in":172800,"access_token":"71c6f08c68fac962cf08b4667206043e79a66ef6"}';
		Map<String, String> mapHeader= new Map<String, String>();
         mapHeader.put('System', 'CAPCRE_CC');
         mapHeader.put('client_id', 'qantasAPI.ClientId__c');
         mapHeader.put('client_secret', 'qantasAPI.ClientSecret__c');
         mapHeader.put('grant_type', 'qantasAPI.GrantType__c');
		mapHeader.put('Content-Type', 'application/json');
        
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
		QCC_FeeWaiverWrapper.FeeWaiverWrapper wrap = QCC_InvokeCAPAPI.invokeFeeWaiverAPI('1', '6142208');
		Test.stopTest();
        
        System.assertNotEquals(null, wrap);
	}
    
    static TestMethod void testInvokeFeeWaiverAPIWithNamedCredential() {
        
Trigger_Status__c triggerStatus = [select Id, Name, Active__c from Trigger_Status__c where Name = 'UseNamedCred'];
        triggerStatus.Active__c = true;
        update triggerStatus;

        String body = '{"your":"mocked response"}';
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', body, mapHeader));
        QCC_FeeWaiverWrapper.FeeWaiverWrapper wrap = QCC_InvokeCAPAPI.invokeFeeWaiverAPI('1', '6142208');    
        Test.stopTest();
        
        // Validate the results
        System.assertNotEquals(null, wrap);
  
    }
       
    static TestMethod void invokeLivePersonSendSMSAPITest() {
		String Body = '{"token_type":"bearer","expires_in":172800,"access_token":"71c6f08c68fac962cf08b4667206043e79a66ef6"}';
		Map<String, String> mapHeader= new Map<String, String>();
		mapHeader.put('Content-Type', 'application/json');
		Qantas_API__c objQantas = [ Select Name, ClientId__c, ClientSecret__c, EndPoint__c, GrantType__c,
                                    Method__c, Token__c, LastModifiedDate from Qantas_API__c where Name =: 'QCC_BookingToken'];
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
		Boolean wrap = QCC_InvokeCAPAPI.invokeLivePersonSendSMSAPI(objQantas, Body,'71c6f08c68fac962cf08b4667206043e79a66ef6');
		Test.stopTest();
	}
    static TestMethod void invokeCaseStreamUpdateAPITest() {
		String Body = '{"token_type":"bearer","expires_in":172800,"access_token":"71c6f08c68fac962cf08b4667206043e79a66ef6"}';
		Map<String, String> mapHeader= new Map<String, String>();
		mapHeader.put('Content-Type', 'application/json');
		Qantas_API__c objQantas = [ Select Name, ClientId__c, ClientSecret__c, EndPoint__c, GrantType__c,
                                    Method__c, Token__c, LastModifiedDate from Qantas_API__c where Name =: 'QCC_BookingToken'];
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
		QCC_InvokeCAPAPI.CaseStreamWrapper wrap = QCC_InvokeCAPAPI.invokeCaseStreamUpdateAPI(objQantas,'71c6f08c68fac962cf08b4667206043e79a66ef6', Body);
		Test.stopTest();
	}
    static TestMethod void invokeTokenLoyaltyAPITest() {
        String Body = '{"token_type":"bearer","expires_in":172800,"access_token":"71c6f08c68fac962cf08b4667206043e79a66ef6"}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Qantas_API__c objQantas = [ Select Name, ClientId__c, ClientSecret__c, EndPoint__c, GrantType__c,
                                    Method__c, Token__c, LastModifiedDate from Qantas_API__c where Name =: 'QCC_BookingToken'];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_CAPTokenWrapper wrap = QCC_InvokeCAPAPI.invokeTokenLoyaltyAPI(objQantas);
        system.assert(wrap != Null, 'invokeTokenLoyalty returns Null');
        Test.stopTest();
    }

    static TestMethod void testinvokeCustomerDetailCAPAPIwithQantasAPI(){
        
        Qantas_API__c qantasAPI = [select Id,Name,EndPoint__c,ClientId__c, ClientSecret__c from Qantas_API__c where Name ='QCC_CAPDetailsAPI']; 
        String endpoint = qantasAPI.EndPoint__c; 
        String Body = '{"customers":[{"customer":{"qantasUniqueId":"710000000018","customerMatchScore":175,"name":{"firstName":"MARK","middleName":"","lastName":"WAUGH","prefix":"mr","salutation":"Dear Mr.","birthDate":"15/11/1990","genderCode":"M"},"loyaltyDetails":[{"schemeOperatorCode":"QF","loyaltyId":"0006142104","airlineTierCode":"FFBR","startDate":"01/01/1900"}],"phone":[{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"08","phoneLineNumber":"98124567","phoneExtension":""},{"typeCode":"H","phoneCountryCode":"61","phoneAreaCode":"","phoneLineNumber":"410678909","phoneExtension":""}],"email":[{"typeCode":"B","emailId":"mark.waugh@mailinator.com"},{"typeCode":"H","emailId":"mark.waugh1@mailinator.com"}],"address":[{"typeCode":"B","line1":"647","line2":"","line3":"london court","line4":"hay st","suburb":"perth","postCode":"6000","state":"wa","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"H","line1":"15","line2":"","line3":"","line4":"hobart rd","suburb":"south launceston","postCode":"7249","state":"tas","country":"AU","countryName":"AUSTRALIA"}],"travelDoc":[{"typeCode":"P","id":"AB123462","issueCountry":"AU"}],"others":{"companyName":"Unilever","comments":"Summary Comment Text18"}}}],"totalMatchedRecords":1}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('client_id', 'qantasAPI.ClientId__c');
        mapHeader.put('client_secret', 'qantasAPI.ClientSecret__c');
        mapHeader.put('grant_type', 'qantasAPI.GrantType__c');
		mapHeader.put('Content-Type', 'application/json');
        mapHeader.put('Content-Type', 'application/json');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_CustomerDetailsRequest requestBody = new QCC_CustomerDetailsRequest();
        requestBody.firstName  = 'Praveen';
        requestBody.lastName  = 'Sampath';
        requestBody.qantasUniqueId  = '710000000018';
        requestBody.system_z = 'CAPCRE_CC';
        
        QCC_CustomerDetailsResponse.Response wrap = QCC_InvokeCAPAPI.invokeCustomerDetailCAPAPI(requestBody);
        system.assert(wrap != Null, 'invokeCustomerDetailCAP returns Null');
        Test.stopTest();
    }
    
    static TestMethod void testinvokeCustomerDetailCAPAPINamedCredential() {
        
Trigger_Status__c triggerStatus = [select Id, Name, Active__c from Trigger_Status__c where Name = 'UseNamedCred'];
        triggerStatus.Active__c = true;
        update triggerStatus;

        String body = '{"your":"mocked response"}';
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', body, mapHeader));
        QCC_CustomerDetailsRequest requestBody = new QCC_CustomerDetailsRequest();
        requestBody.firstName  = 'Praveen';
        requestBody.lastName  = 'Sampath';
        requestBody.qantasUniqueId  = '710000000018';
        requestBody.system_z = 'CAPCRE_CC';
        QCC_CustomerDetailsResponse.Response wrap = QCC_InvokeCAPAPI.invokeCustomerDetailCAPAPI(requestBody);
        Test.stopTest();
        
        // Validate the results
        System.assertNotEquals(null, wrap);
  
    }


    static TestMethod void testinvokeTransactionCAPAPIWithQantasAPI() {

        Qantas_API__c qantasAPI = [select Id, Name,EndPoint__c,ClientId__c, ClientSecret__c from Qantas_API__c where Name ='QCC_CAPCustomerTransAPI'];
        String Body = '{"airlineCustomerValue":"9879","otherAirlineSchemeCount":0,"qantasFFNo":"900000000000013",'+
                        '"qfMemberAirlinePriorityLevel":null,"qfMemberTierClubCode":"FFGD","complaintCount":3,'+
                        '"serviceFailureCount":21,"surpriseDelightCount":1,"mishandledBagCount":39,"flightCancellationCount":26,'+
                        '"flightDelayDomesticCount":13,"flightDelayInternationalCount":6,"flightUpgradeDomesticCount":0,'+
                        '"flightUpgradeInternationalCount":12,"flightDowngradeDomesticCount":22,"flightDowngradeInternationalCount":13,'+
                        '"flightSegmentCount":31,"qantasUniqueID":"900000000013","majorityQCI":"ANZ","majorCorpCountryCode":"AU",'+
                        '"majorCorpBCI":"BCI","majorCorpACI":"ACI","majorCorpOCI":"OCI","majorCorpName":"ANZ Bank",'+
                        '"majorCorpAltName":"Australia New Zealand Banking Corp"}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_CAPTransactionWrapper.CAPTransactionRequest requestInfo = new QCC_CAPTransactionWrapper.CAPTransactionRequest();
        requestInfo.system_x = 'CAPCRE_CC';
        requestInfo.firstName = 'Praveen';
        requestInfo.surName = 'Sampath';
        requestInfo.qantasFFNo = '0006142104';
        requestInfo.version = '1.0';
        
        QCC_CAPTransactionWrapper.CAPTransactionResponse wrap = QCC_InvokeCAPAPI.invokeTransactionCAPAPI(requestInfo);
        system.assert(wrap != Null, ' invokeTransactionCAPAPI returns Null');
        Test.stopTest();
    }
    
    static TestMethod void testinvokeTransactionCAPAPIWithNamedCredential() {
   
        Trigger_Status__c triggerStatus = [select Id, Name, Active__c from Trigger_Status__c where Name = 'UseNamedCred'];
        triggerStatus.Active__c = true;
        update triggerStatus;
        
        String Body = '{"airlineCustomerValue":"9879","otherAirlineSchemeCount":0,"qantasFFNo":"900000000000013",'+
                        '"qfMemberAirlinePriorityLevel":null,"qfMemberTierClubCode":"FFGD","complaintCount":3,'+
                        '"serviceFailureCount":21,"surpriseDelightCount":1,"mishandledBagCount":39,"flightCancellationCount":26,'+
                        '"flightDelayDomesticCount":13,"flightDelayInternationalCount":6,"flightUpgradeDomesticCount":0,'+
                        '"flightUpgradeInternationalCount":12,"flightDowngradeDomesticCount":22,"flightDowngradeInternationalCount":13,'+
                        '"flightSegmentCount":31,"qantasUniqueID":"900000000013","majorityQCI":"ANZ","majorCorpCountryCode":"AU",'+
                        '"majorCorpBCI":"BCI","majorCorpACI":"ACI","majorCorpOCI":"OCI","majorCorpName":"ANZ Bank",'+
                        '"majorCorpAltName":"Australia New Zealand Banking Corp"}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_CAPTransactionWrapper.CAPTransactionRequest requestInfo = new QCC_CAPTransactionWrapper.CAPTransactionRequest();
        requestInfo.system_x = 'CAPCRE_CC';
        requestInfo.firstName = 'Praveen';
        requestInfo.surName = 'Sampath';
        requestInfo.qantasFFNo = '0006142104';
        requestInfo.version = '1.0';
        
        QCC_CAPTransactionWrapper.CAPTransactionResponse wrap = QCC_InvokeCAPAPI.invokeTransactionCAPAPI(requestInfo);
        system.assert(wrap != Null, ' invokeTransactionCAPAPI returns Null');
        Test.stopTest();
    }
    

    static TestMethod void invokeLoyaltyAPITest() {
        String Body = '{"memberId":"0006142104","firstName":"W","lastName":"FYSH","mailingName":"MR W FYSH","salutation":"Dear Mr Fysh","title":"MR","dateOfJoining":"1996-05-13","gender":"MALE","dateOfBirth":"1996-11-07","email":"ibstestonlinesalesqueries@qantas.com.au","emailType":"BUSINESS","countryOfResidency":"AU","taxResidency":"AU","membershipStatus":"ACTIVE","preferredAddress":"HOME","pointBalance":11326,"company":{"name":"DO NOT CHANGE ANYTHING - PH JAMIE X62542","positionInCompany":"TEST PROFILE - DIGITAL DIRECT"},"phoneDetails":[{"type":"BUSINESS","number":"96912542","areaCode":"02","idd":"+61","status":"V"}],"addresses":[{"type":"HOME","lineOne":"10 BOURKE ROAD","suburb":"SYDNEY","postCode":"3000","state":"VIC","countryCode":"AU","status":"I"}],"preferences":{"ffsAirlines":[{"id":1,"number":"SK198253","airline":"CO"}],"leisureInterests":["BALL","CLMU","JAZZ"],"sportInterests":["BABL","BSBL","CYCL","SQSH","ARFB"]},"programDetails":[{"programCode":"QCASH","programName":"Qantas Cash","enrollmentDate":"2015-04-28","accountStatus":"ACTIVE","qcachSendMarketing":false,"qcashProgramIdentifier":"AU","activationFlag":"N"},{"programCode":"QC","programName":"Qantas Club","enrollmentDate":"2017-08-02","expiryDate":"2018-07-31","accountStatus":"PAYMENT_DUE","qcEnrolType":0},{"programCode":"QFF","programName":"Qantas Frequent Flyer","enrollmentDate":"1996-05-13","accountStatus":"ACTIVE","tierCode":"FFPL","tierFromDate":"2017-08-02"},{"programCode":"CL","programName":"Chairmans Lounge","enrollmentDate":"2017-08-02","expiryDate":"2019-08-31","accountStatus":"ACTIVE","clMemberType":"PRIME"}],"webLoginDisabled":false,"statusCredits":{"expiryDate":"2018-07-31","lifetime":430,"total":430,"loyaltyBonus":0},"tier":{"name":"Chairmans Lounge","code":"FFPL","startDate":"2017-08-02","effectiveTier":"CLQF"}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        //QCC_LoyaltyResponseWrapper wrap = QCC_InvokeCAPAPI.invokeLoyaltyAPI('0006142104');
        QCC_LoyaltyResponseWrapper.QantasFrequentFlyerProfile wrap = QCC_InvokeCAPAPI.invokeLoyaltyProfileAPI('0006142104');
        QCC_LoyaltyResponseWrapper.QantasFrequentFlyerContact wrap1 = QCC_InvokeCAPAPI.invokeLoyaltyContactAPI('0006142104');
        QCC_LoyaltyResponseWrapper.QantasFrequentFlyerAccount wrap2 = QCC_InvokeCAPAPI.invokeLoyaltyAccountAPI('0006142104');
        QCC_LoyaltyResponseWrapper.Programs wrap3 = QCC_InvokeCAPAPI.invokeLoyaltyProgramAPI('0006142104');
        QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier wrap4 = QCC_InvokeCAPAPI.invokeLoyaltyTierAPI('0006142104');
        system.assert(wrap != Null, 'invokeLoyaltyProfileAPI returns Null');
        system.assert(wrap1 != Null, 'invokeLoyaltyContactAPI returns Null');
        system.assert(wrap2 != Null, 'invokeLoyaltyAccountAPI returns Null');
        system.assert(wrap3 != Null, 'invokeLoyaltyProgramAPI returns Null');
        system.assert(wrap4 != Null, 'invokeLoyaltyTierAPI returns Null');
        Test.stopTest();
    }

    static TestMethod void invokeLoyaltyPostAPITest() {
        String Body = '{ "success": true, "message": "Point Accrual information successfully updated", "member": {'+
                      '"memberid": 1900007871, "pointsbalance": 2 }, "othermemberdetails": { "emailid": "kevinliu@qantas.com.au"'+
                      '}, "reference": { "identifier": 787987122 }, "outcome": { "status": "SUCCESS", "reason": 0, "reasoncode": 0'+
                      '}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));

         LoyaltyRequestWrapper loyaltyReq = new LoyaltyRequestWrapper();
            String todayString = String.valueOf(system.today());
            List<String> lsttoday = todayString.split('-');
            String activityDate = lsttoday[2]+''+lsttoday[1]+''+lsttoday[0];
            loyaltyReq.activityDate = activityDate;
            loyaltyReq.validationLevel = CustomSettingsUtilities.getConfigDataMap('LoyaltyAPIValidationLevel');
            loyaltyReq.partnerID = CustomSettingsUtilities.getConfigDataMap('LoyaltyAPIPartnerID');
            
            LoyaltyRequestWrapper.Member member = new LoyaltyRequestWrapper.Member();
            member.surname = 'Sampath';
            
            LoyaltyRequestWrapper.Payment payment = new LoyaltyRequestWrapper.Payment();
            
            payment.transactionReference = '1234';
            payment.basePointsSign = '+';
            payment.numberOfBasePoints = 10000;
            
            loyaltyReq.payment = payment;
            loyaltyReq.member = member;


        HttpResponse response = QCC_InvokeCAPAPI.invokeLoyaltyPostAPI('0006142104', loyaltyReq);
        Boolean wrap = (response.getStatusCode() == 200) ;
        system.assert(wrap == true, 'invokeLoyaltyPostAPI returns Null');
        Test.stopTest();
    }

    static TestMethod void invokePNRFlightInfoCAPAPITestWithQantasAPI() {
        
        Qantas_API__c qantasAPI = [select Id,Name,EndPoint__c,ClientId__c, ClientSecret__c from Qantas_API__c where Name ='QCC_CAPPNRRetrieve'];
        qantasAPI.EndPoint__c = qantasAPI.EndPoint__c;
        
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","lastUpdatedTimeStamp":"05/12/2017 04:28:00","segments":[{"segmentId":"9178306296255759","segmentTattoo":"1","marketingCarrierAlphaCode":"QF","marketingFlightNumber":"0401","marketingFlightSuffix":null,"departureAirportCode":"SYD","arrivalAirportCode":"MEL","operatingCarrierAlphaCode":"QF","operatingFlightNumber":"0401","operatingFlightSuffix":null,"departureCityCode":"SYD","arrivalCityCode":"MEL","departureLocalDate":"06/12/2017","departureLocalTime":"06:00:00","actualDepartureLocalDate":null,"actualDepartureLocalTime":null,"departureTerminalCode":"3","arrivalLocalDate":"06/12/2017","arrivalLocalTime":"07:35:00","actualArrivalLocalDate":null,"actualArrivalLocalTime":null,"arrivalTerminalCode":"1","departureUTCDate":"05/12/2017","departureUTCTime":"19:00:00","arrivalUTCDate":"05/12/2017","arrivalUTCTime":"20:35:00","departureDow":"3","dateVar":"0","flightTypeCode":"D","aircraftTypeCode":"73H","codeShareFlightTypeCode":null,"codeShareAgreementTypeCode":null,"disrupts":[{"type":"AS SCHEDULED","legDepartureAirportCode":"SYD","legArrivalAirportCode":"MEL","unScheduledArrivalAirport":null,"details":[{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null},{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null},{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null}]}]},{"segmentId":"9208109317857456","segmentTattoo":"2","marketingCarrierAlphaCode":"QF","marketingFlightNumber":"0400","marketingFlightSuffix":null,"departureAirportCode":"MEL","arrivalAirportCode":"SYD","operatingCarrierAlphaCode":"QF","operatingFlightNumber":"0400","operatingFlightSuffix":null,"departureCityCode":"MEL","arrivalCityCode":"SYD","departureLocalDate":"07/12/2017","departureLocalTime":"06:00:00","actualDepartureLocalDate":null,"actualDepartureLocalTime":null,"departureTerminalCode":"1","arrivalLocalDate":"07/12/2017","arrivalLocalTime":"07:25:00","actualArrivalLocalDate":null,"actualArrivalLocalTime":null,"arrivalTerminalCode":"3","departureUTCDate":"06/12/2017","departureUTCTime":"19:00:00","arrivalUTCDate":"06/12/2017","arrivalUTCTime":"20:25:00","departureDow":"4","dateVar":"0","flightTypeCode":"D","aircraftTypeCode":"332","codeShareFlightTypeCode":null,"codeShareAgreementTypeCode":null,"disrupts":[{"type":"AS SCHEDULED","legDepartureAirportCode":"MEL","legArrivalAirportCode":"SYD","unScheduledArrivalAirport":null,"details":[{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null},{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null},{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null}]}]}]}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_PNRFlightInfoWrapper wrap = QCC_InvokeCAPAPI.invokePNRFlightInfoCAPAPI('K5F5ZE', '05/12/2017','123456778556', false, 'false');
        system.assert(wrap != Null, 'invokePNRFlightInfoCAPAPI returns Null');
        Test.stopTest();
    }
    
     static TestMethod void invokePNRFlightInfoCAPAPITestWithNC() {
        
  Trigger_Status__c triggerStatus = [select Id, Name, Active__c from Trigger_Status__c where Name = 'UseNamedCred'];
        triggerStatus.Active__c = true;
        update triggerStatus;
         
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","lastUpdatedTimeStamp":"05/12/2017 04:28:00","segments":[{"segmentId":"9178306296255759","segmentTattoo":"1","marketingCarrierAlphaCode":"QF","marketingFlightNumber":"0401","marketingFlightSuffix":null,"departureAirportCode":"SYD","arrivalAirportCode":"MEL","operatingCarrierAlphaCode":"QF","operatingFlightNumber":"0401","operatingFlightSuffix":null,"departureCityCode":"SYD","arrivalCityCode":"MEL","departureLocalDate":"06/12/2017","departureLocalTime":"06:00:00","actualDepartureLocalDate":null,"actualDepartureLocalTime":null,"departureTerminalCode":"3","arrivalLocalDate":"06/12/2017","arrivalLocalTime":"07:35:00","actualArrivalLocalDate":null,"actualArrivalLocalTime":null,"arrivalTerminalCode":"1","departureUTCDate":"05/12/2017","departureUTCTime":"19:00:00","arrivalUTCDate":"05/12/2017","arrivalUTCTime":"20:35:00","departureDow":"3","dateVar":"0","flightTypeCode":"D","aircraftTypeCode":"73H","codeShareFlightTypeCode":null,"codeShareAgreementTypeCode":null,"disrupts":[{"type":"AS SCHEDULED","legDepartureAirportCode":"SYD","legArrivalAirportCode":"MEL","unScheduledArrivalAirport":null,"details":[{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null},{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null},{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null}]}]},{"segmentId":"9208109317857456","segmentTattoo":"2","marketingCarrierAlphaCode":"QF","marketingFlightNumber":"0400","marketingFlightSuffix":null,"departureAirportCode":"MEL","arrivalAirportCode":"SYD","operatingCarrierAlphaCode":"QF","operatingFlightNumber":"0400","operatingFlightSuffix":null,"departureCityCode":"MEL","arrivalCityCode":"SYD","departureLocalDate":"07/12/2017","departureLocalTime":"06:00:00","actualDepartureLocalDate":null,"actualDepartureLocalTime":null,"departureTerminalCode":"1","arrivalLocalDate":"07/12/2017","arrivalLocalTime":"07:25:00","actualArrivalLocalDate":null,"actualArrivalLocalTime":null,"arrivalTerminalCode":"3","departureUTCDate":"06/12/2017","departureUTCTime":"19:00:00","arrivalUTCDate":"06/12/2017","arrivalUTCTime":"20:25:00","departureDow":"4","dateVar":"0","flightTypeCode":"D","aircraftTypeCode":"332","codeShareFlightTypeCode":null,"codeShareAgreementTypeCode":null,"disrupts":[{"type":"AS SCHEDULED","legDepartureAirportCode":"MEL","legArrivalAirportCode":"SYD","unScheduledArrivalAirport":null,"details":[{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null},{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null},{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null}]}]}]}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_PNRFlightInfoWrapper wrap = QCC_InvokeCAPAPI.invokePNRFlightInfoCAPAPI('K5F5ZE', '05/12/2017','123456778556', false, 'false');
        system.assert(wrap != Null, 'invokePNRFlightInfoCAPAPI returns Null');
        Test.stopTest();
    }

    
    static TestMethod void invokePNRFlightInfoCAPAPITest2QAPI() {
        
        Qantas_API__c qantasAPI = [select Id,Name,EndPoint__c,ClientId__c, ClientSecret__c from Qantas_API__c where Name ='QCC_CAPPNRRetrieve'];
        qantasAPI.EndPoint__c = qantasAPI.EndPoint__c;
        
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","lastUpdatedTimeStamp":"05/12/2017 04:28:00","segments":[{"segmentId":"9178306296255759","segmentTattoo":"1","marketingCarrierAlphaCode":"QF","marketingFlightNumber":"0401","marketingFlightSuffix":null,"departureAirportCode":"SYD","arrivalAirportCode":"MEL","operatingCarrierAlphaCode":"QF","operatingFlightNumber":"0401","operatingFlightSuffix":null,"departureCityCode":"SYD","arrivalCityCode":"MEL","departureLocalDate":"06/12/2017","departureLocalTime":"06:00:00","actualDepartureLocalDate":null,"actualDepartureLocalTime":null,"departureTerminalCode":"3","arrivalLocalDate":"06/12/2017","arrivalLocalTime":"07:35:00","actualArrivalLocalDate":null,"actualArrivalLocalTime":null,"arrivalTerminalCode":"1","departureUTCDate":"05/12/2017","departureUTCTime":"19:00:00","arrivalUTCDate":"05/12/2017","arrivalUTCTime":"20:35:00","departureDow":"3","dateVar":"0","flightTypeCode":"D","aircraftTypeCode":"73H","codeShareFlightTypeCode":null,"codeShareAgreementTypeCode":null,"disrupts":[{"type":"AS SCHEDULED","legDepartureAirportCode":"SYD","legArrivalAirportCode":"MEL","unScheduledArrivalAirport":null,"details":[{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null},{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null},{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null}]}]},{"segmentId":"9208109317857456","segmentTattoo":"2","marketingCarrierAlphaCode":"QF","marketingFlightNumber":"0400","marketingFlightSuffix":null,"departureAirportCode":"MEL","arrivalAirportCode":"SYD","operatingCarrierAlphaCode":"QF","operatingFlightNumber":"0400","operatingFlightSuffix":null,"departureCityCode":"MEL","arrivalCityCode":"SYD","departureLocalDate":"07/12/2017","departureLocalTime":"06:00:00","actualDepartureLocalDate":null,"actualDepartureLocalTime":null,"departureTerminalCode":"1","arrivalLocalDate":"07/12/2017","arrivalLocalTime":"07:25:00","actualArrivalLocalDate":null,"actualArrivalLocalTime":null,"arrivalTerminalCode":"3","departureUTCDate":"06/12/2017","departureUTCTime":"19:00:00","arrivalUTCDate":"06/12/2017","arrivalUTCTime":"20:25:00","departureDow":"4","dateVar":"0","flightTypeCode":"D","aircraftTypeCode":"332","codeShareFlightTypeCode":null,"codeShareAgreementTypeCode":null,"disrupts":[{"type":"AS SCHEDULED","legDepartureAirportCode":"MEL","legArrivalAirportCode":"SYD","unScheduledArrivalAirport":null,"details":[{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null},{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null},{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null}]}]}]}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_PNRFlightInfoWrapper wrap = QCC_InvokeCAPAPI.invokePNRFlightInfoCAPAPI('K5F5ZE', '05/12/2017','123456778556', 'false');
        system.assert(wrap != Null, 'invokePNRFlightInfoCAPAPI returns Null');
        Test.stopTest();
    }

    
    static TestMethod void invokePNRFlightInfoCAPAPITest2NC() {
    Trigger_Status__c triggerStatus = [select Id, Name, Active__c from Trigger_Status__c where Name = 'UseNamedCred'];
        triggerStatus.Active__c = true;
        update triggerStatus;
        
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","lastUpdatedTimeStamp":"05/12/2017 04:28:00","segments":[{"segmentId":"9178306296255759","segmentTattoo":"1","marketingCarrierAlphaCode":"QF","marketingFlightNumber":"0401","marketingFlightSuffix":null,"departureAirportCode":"SYD","arrivalAirportCode":"MEL","operatingCarrierAlphaCode":"QF","operatingFlightNumber":"0401","operatingFlightSuffix":null,"departureCityCode":"SYD","arrivalCityCode":"MEL","departureLocalDate":"06/12/2017","departureLocalTime":"06:00:00","actualDepartureLocalDate":null,"actualDepartureLocalTime":null,"departureTerminalCode":"3","arrivalLocalDate":"06/12/2017","arrivalLocalTime":"07:35:00","actualArrivalLocalDate":null,"actualArrivalLocalTime":null,"arrivalTerminalCode":"1","departureUTCDate":"05/12/2017","departureUTCTime":"19:00:00","arrivalUTCDate":"05/12/2017","arrivalUTCTime":"20:35:00","departureDow":"3","dateVar":"0","flightTypeCode":"D","aircraftTypeCode":"73H","codeShareFlightTypeCode":null,"codeShareAgreementTypeCode":null,"disrupts":[{"type":"AS SCHEDULED","legDepartureAirportCode":"SYD","legArrivalAirportCode":"MEL","unScheduledArrivalAirport":null,"details":[{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null},{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null},{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null}]}]},{"segmentId":"9208109317857456","segmentTattoo":"2","marketingCarrierAlphaCode":"QF","marketingFlightNumber":"0400","marketingFlightSuffix":null,"departureAirportCode":"MEL","arrivalAirportCode":"SYD","operatingCarrierAlphaCode":"QF","operatingFlightNumber":"0400","operatingFlightSuffix":null,"departureCityCode":"MEL","arrivalCityCode":"SYD","departureLocalDate":"07/12/2017","departureLocalTime":"06:00:00","actualDepartureLocalDate":null,"actualDepartureLocalTime":null,"departureTerminalCode":"1","arrivalLocalDate":"07/12/2017","arrivalLocalTime":"07:25:00","actualArrivalLocalDate":null,"actualArrivalLocalTime":null,"arrivalTerminalCode":"3","departureUTCDate":"06/12/2017","departureUTCTime":"19:00:00","arrivalUTCDate":"06/12/2017","arrivalUTCTime":"20:25:00","departureDow":"4","dateVar":"0","flightTypeCode":"D","aircraftTypeCode":"332","codeShareFlightTypeCode":null,"codeShareAgreementTypeCode":null,"disrupts":[{"type":"AS SCHEDULED","legDepartureAirportCode":"MEL","legArrivalAirportCode":"SYD","unScheduledArrivalAirport":null,"details":[{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null},{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null},{"reasonCode":null,"shortDescription":null,"longDescription":null,"delayDuration":null}]}]}]}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_PNRFlightInfoWrapper wrap = QCC_InvokeCAPAPI.invokePNRFlightInfoCAPAPI('K5F5ZE', '05/12/2017','123456778556', 'false');
        system.assert(wrap != Null, 'invokePNRFlightInfoCAPAPI returns Null');
        Test.stopTest();
    }

    static TestMethod void invokePNRPassengerInfoCAPAPITestWithQantasAPI() {
 
        Qantas_API__c qantasAPI = [select Id,Name,EndPoint__c,ClientId__c, ClientSecret__c from Qantas_API__c where Name ='QCC_CAPPNRRetrieve'];
         qantasAPI.EndPoint__c = qantasAPI.EndPoint__c;
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","currentPassengerQuantity":"2","lastUpdatedTimeStamp":"05/12/2017 04:28:00","passengers":[{"passengerId":"8956328947991887","passengerTattoo":"2","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"STEVE","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CC","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000017"},{"passengerId":"9018991125607359","passengerTattoo":"3","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"MARK","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CD","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000018"}]}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_PNRPassengerInfoWrapper wrap = QCC_InvokeCAPAPI.invokePNRPassengerInfoCAPAPI('K5F5ZE', '05/12/2017', '123456778556', 'false');
        system.assert(wrap != Null, 'invokePNRPassengerInfoCAPAPI returns Null');
        Test.stopTest();
    }
    
    
    static TestMethod void invokePNRPassengerInfoCAPAPITestWithNC() {
        Trigger_Status__c triggerStatus = [select Id, Name, Active__c from Trigger_Status__c where Name = 'UseNamedCred'];
        triggerStatus.Active__c = true;
        update triggerStatus;
  
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","currentPassengerQuantity":"2","lastUpdatedTimeStamp":"05/12/2017 04:28:00","passengers":[{"passengerId":"8956328947991887","passengerTattoo":"2","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"STEVE","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CC","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000017"},{"passengerId":"9018991125607359","passengerTattoo":"3","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"MARK","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CD","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000018"}]}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_PNRPassengerInfoWrapper wrap = QCC_InvokeCAPAPI.invokePNRPassengerInfoCAPAPI('K5F5ZE', '05/12/2017', '123456778556', 'false');
        system.assert(wrap != Null, 'invokePNRPassengerInfoCAPAPI returns Null');
        Test.stopTest();
    }

    
    static TestMethod void invokePNRPassengerInfoCAPAPITest2QAPI() {
        Qantas_API__c qantasAPI = [select Id,Name,EndPoint__c,ClientId__c, ClientSecret__c from Qantas_API__c where Name ='QCC_CAPPNRRetrieve'];
         qantasAPI.EndPoint__c = qantasAPI.EndPoint__c;
        
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","currentPassengerQuantity":"2","lastUpdatedTimeStamp":"05/12/2017 04:28:00","passengers":[{"passengerId":"8956328947991887","passengerTattoo":"2","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"STEVE","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CC","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000017"},{"passengerId":"9018991125607359","passengerTattoo":"3","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"MARK","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CD","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000018"}]}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_PNRPassengerInfoWrapper wrap = QCC_InvokeCAPAPI.invokePNRPassengerInfoCAPAPI('K5F5ZE', '05/12/2017', 'WAUGH');
        system.assert(wrap != Null, 'invokePNRPassengerInfoCAPAPI returns Null');
        Test.stopTest();
    }

      
    static TestMethod void invokePNRPassengerInfoCAPAPITest2NC() {
        
   Trigger_Status__c triggerStatus = [select Id, Name, Active__c from Trigger_Status__c where Name = 'UseNamedCred'];
        triggerStatus.Active__c = true;
        update triggerStatus;
        
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","currentPassengerQuantity":"2","lastUpdatedTimeStamp":"05/12/2017 04:28:00","passengers":[{"passengerId":"8956328947991887","passengerTattoo":"2","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"STEVE","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CC","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000017"},{"passengerId":"9018991125607359","passengerTattoo":"3","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"MARK","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CD","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000018"}]}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_PNRPassengerInfoWrapper wrap = QCC_InvokeCAPAPI.invokePNRPassengerInfoCAPAPI('K5F5ZE', '05/12/2017', 'WAUGH');
        system.assert(wrap != Null, 'invokePNRPassengerInfoCAPAPI returns Null');
        Test.stopTest();
    }

    static TestMethod void invokePNRContactInfoCAPAPIwithQantasAPI() {

        Qantas_API__c qantasAPI = [select Id,Name,EndPoint__c,ClientId__c, ClientSecret__c from Qantas_API__c where Name ='QCC_CAPPNRRetrieve'];
         qantasAPI.EndPoint__c = qantasAPI.EndPoint__c;
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","lastUpdatedTimeStamp":"05/12/2017 04:28:00","contacts":{"address":[{"addressId":"1601601601600001","otherTattooReference":"11","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"B","line1":"322","line2":"level 20","line3":" Indooroopilly mall","line4":"moggill rd","postBoxName":null,"cityName":" Indooroopilly","stateName":"qld","countryName":"AU","postalCode":"4000","addressText":"TEST ADDR1","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"addressId":"1601601601600002","otherTattooReference":"12","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"H","line1":"10","line2":null,"line3":null,"line4":"king st","postBoxName":null,"cityName":"perth","stateName":"tas","countryName":"AU","postalCode":"7300","addressText":"TEST ADDR2","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"addressId":"1601601601600003","otherTattooReference":"14","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"B","line1":"647","line2":null,"line3":"london court","line4":"hay st","postBoxName":null,"cityName":"perth","stateName":"wa","countryName":"AU","postalCode":"6000","addressText":"TEST ADDR3","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]},{"addressId":"1601601601600004","otherTattooReference":"15","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"H","line1":"15","line2":null,"line3":null,"line4":"hobart rd","postBoxName":null,"cityName":"south launceston","stateName":"tas","countryName":"AU","postalCode":"7249","addressText":"TEST ADDR4","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]}],"email":[{"emailId":"1621621621620001","otherTattooReference":"44","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"B","emailText":"steve.waugh@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"emailId":"1621621621620002","otherTattooReference":"45","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"H","emailText":"steve.waugh1@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"emailId":"1621621621620003","otherTattooReference":"46","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"B","emailText":"mark.waugh@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]},{"emailId":"1621621621620004","otherTattooReference":"47","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"H","emailText":"mark.waugh1@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]}],"phone":[{"phoneId":"1244444265675389","otherTattooReference":"7","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":"07","phoneNumber":"98765448","typeCode":"B","phoneText":"98765448 B","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"phoneId":"1641641641640002","otherTattooReference":"8","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":null,"phoneNumber":"410467890","typeCode":"H","phoneText":"410467890 H","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"phoneId":"1641641641640003","otherTattooReference":"9","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":"08","phoneNumber":"98124567","typeCode":"B","phoneText":"98124567 B","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]},{"phoneId":"1641641641640004","otherTattooReference":"10","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":null,"phoneNumber":"410678909","typeCode":"H","phoneText":"410678909 H","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]}]}}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_PNRContactInfoWrapper wrap = QCC_InvokeCAPAPI.invokePNRContactInfoCAPAPI('K5F5ZE', '05/12/2017', '123456778556', 'false');
        system.assert(wrap != Null, 'invokePNRContactInfoCAPAPI returns Null');
        Test.stopTest();
    }
	
    static TestMethod void testinvokePNRContactInfoCAPAPIwithNC() {
      Trigger_Status__c triggerStatus = [select Id, Name, Active__c from Trigger_Status__c where Name = 'UseNamedCred'];
        triggerStatus.Active__c = true;
        update triggerStatus;
        
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","lastUpdatedTimeStamp":"05/12/2017 04:28:00","contacts":{"address":[{"addressId":"1601601601600001","otherTattooReference":"11","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"B","line1":"322","line2":"level 20","line3":" Indooroopilly mall","line4":"moggill rd","postBoxName":null,"cityName":" Indooroopilly","stateName":"qld","countryName":"AU","postalCode":"4000","addressText":"TEST ADDR1","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"addressId":"1601601601600002","otherTattooReference":"12","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"H","line1":"10","line2":null,"line3":null,"line4":"king st","postBoxName":null,"cityName":"perth","stateName":"tas","countryName":"AU","postalCode":"7300","addressText":"TEST ADDR2","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"addressId":"1601601601600003","otherTattooReference":"14","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"B","line1":"647","line2":null,"line3":"london court","line4":"hay st","postBoxName":null,"cityName":"perth","stateName":"wa","countryName":"AU","postalCode":"6000","addressText":"TEST ADDR3","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]},{"addressId":"1601601601600004","otherTattooReference":"15","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"H","line1":"15","line2":null,"line3":null,"line4":"hobart rd","postBoxName":null,"cityName":"south launceston","stateName":"tas","countryName":"AU","postalCode":"7249","addressText":"TEST ADDR4","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]}],"email":[{"emailId":"1621621621620001","otherTattooReference":"44","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"B","emailText":"steve.waugh@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"emailId":"1621621621620002","otherTattooReference":"45","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"H","emailText":"steve.waugh1@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"emailId":"1621621621620003","otherTattooReference":"46","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"B","emailText":"mark.waugh@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]},{"emailId":"1621621621620004","otherTattooReference":"47","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"H","emailText":"mark.waugh1@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]}],"phone":[{"phoneId":"1244444265675389","otherTattooReference":"7","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":"07","phoneNumber":"98765448","typeCode":"B","phoneText":"98765448 B","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"phoneId":"1641641641640002","otherTattooReference":"8","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":null,"phoneNumber":"410467890","typeCode":"H","phoneText":"410467890 H","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"phoneId":"1641641641640003","otherTattooReference":"9","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":"08","phoneNumber":"98124567","typeCode":"B","phoneText":"98124567 B","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]},{"phoneId":"1641641641640004","otherTattooReference":"10","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":null,"phoneNumber":"410678909","typeCode":"H","phoneText":"410678909 H","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]}]}}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_PNRContactInfoWrapper wrap = QCC_InvokeCAPAPI.invokePNRContactInfoCAPAPI('K5F5ZE', '05/12/2017', '123456778556', 'false');
        system.assert(wrap != Null, 'invokePNRContactInfoCAPAPI returns Null');
        Test.stopTest();
    }
    
    static TestMethod void testinvokePNRContactInfoCAPAPITest2() {
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","lastUpdatedTimeStamp":"05/12/2017 04:28:00","contacts":{"address":[{"addressId":"1601601601600001","otherTattooReference":"11","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"B","line1":"322","line2":"level 20","line3":" Indooroopilly mall","line4":"moggill rd","postBoxName":null,"cityName":" Indooroopilly","stateName":"qld","countryName":"AU","postalCode":"4000","addressText":"TEST ADDR1","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"addressId":"1601601601600002","otherTattooReference":"12","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"H","line1":"10","line2":null,"line3":null,"line4":"king st","postBoxName":null,"cityName":"perth","stateName":"tas","countryName":"AU","postalCode":"7300","addressText":"TEST ADDR2","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"addressId":"1601601601600003","otherTattooReference":"14","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"B","line1":"647","line2":null,"line3":"london court","line4":"hay st","postBoxName":null,"cityName":"perth","stateName":"wa","countryName":"AU","postalCode":"6000","addressText":"TEST ADDR3","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]},{"addressId":"1601601601600004","otherTattooReference":"15","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"H","line1":"15","line2":null,"line3":null,"line4":"hobart rd","postBoxName":null,"cityName":"south launceston","stateName":"tas","countryName":"AU","postalCode":"7249","addressText":"TEST ADDR4","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]}],"email":[{"emailId":"1621621621620001","otherTattooReference":"44","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"B","emailText":"steve.waugh@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"emailId":"1621621621620002","otherTattooReference":"45","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"H","emailText":"steve.waugh1@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"emailId":"1621621621620003","otherTattooReference":"46","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"B","emailText":"mark.waugh@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]},{"emailId":"1621621621620004","otherTattooReference":"47","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"H","emailText":"mark.waugh1@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]}],"phone":[{"phoneId":"1244444265675389","otherTattooReference":"7","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":"07","phoneNumber":"98765448","typeCode":"B","phoneText":"98765448 B","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"phoneId":"1641641641640002","otherTattooReference":"8","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":null,"phoneNumber":"410467890","typeCode":"H","phoneText":"410467890 H","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"phoneId":"1641641641640003","otherTattooReference":"9","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":"08","phoneNumber":"98124567","typeCode":"B","phoneText":"98124567 B","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]},{"phoneId":"1641641641640004","otherTattooReference":"10","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":null,"phoneNumber":"410678909","typeCode":"H","phoneText":"410678909 H","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]}]}}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_PNRContactInfoWrapper wrap = QCC_InvokeCAPAPI.invokePNRContactInfoCAPAPI('K5F5ZE', '05/12/2017', 'WAUGH');
        system.assert(wrap != Null, 'invokePNRContactInfoCAPAPI returns Null');
        Test.stopTest();
    }


    static TestMethod void invokePNRAncillaryInfoCAPAPITestwithQantasAPI() {      
         Qantas_API__c qantasAPI = [select Id,Name,EndPoint__c,ClientId__c, ClientSecret__c from Qantas_API__c where Name ='QCC_BookingSummaryAPI'];
         qantasAPI.EndPoint__c = qantasAPI.EndPoint__c;
        
        String Body = '{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","lastUpdatedTimeStamp":"05/12/2017 04:28:00","insurance":[{"insuranceId":"1401401401400001","insuranceTattoo":"88","policyCode":"USE","policyName":"TWO AUSTRALIAN CANCELLATION TRAVEL PLAN","insuranceConfirmationNumber":"QQU01014558-0","segmentStatusCode":"HK","insuranceStartLocalDate":"05/12/2017","insuranceEndLocalDate":"31/12/2018","providerCompanyCode":"OIU","providerCompanyName":null,"providerCountryCode":"AU","tripTypeCode":"FLT","totalTripAmount":"200.000","totalPremiumAmount":"250.000","currencyCode":"AUD"}],"accommodation":[{"accommodationSegmentId":"1431431431430001","segmentTattooReferenceNumber":"1","segmentSourceCode":"HHL","accommodationBookingReferenceNumber":"TEST1","bookingConfirmationNumber":"CONF143","travelProductSupplyCode":"XY","checkinLocalDate":"06/12/2017","checkoutLocalDate":"07/12/2017","locatedCityCode":"MEL","accommodationChainCode":"YX","accommodationChainName":"SYNXIS","accommodationPropertyCode":"MSM","accommodationPropertyName":"MERITON SUITES MASCOT CENTRAL","roomsDeliveredQuantity":"1","segmentStatusCode":"HK"},{"accommodationSegmentId":"1431431431430002","segmentTattooReferenceNumber":"2","segmentSourceCode":"HHL","accommodationBookingReferenceNumber":"TEST2","bookingConfirmationNumber":"CONF143","travelProductSupplyCode":"YZ","checkinLocalDate":"06/12/2017","checkoutLocalDate":"07/12/2017","locatedCityCode":"MEL","accommodationChainCode":"YX","accommodationChainName":"SYNXIS","accommodationPropertyCode":"MSM","accommodationPropertyName":"MERITON SUITES MASCOT CENTRAL","roomsDeliveredQuantity":"1","segmentStatusCode":"HK"}],"vehicle":[{"vehicleSegmentId":"1441441441440001","segmentTattooReferenceNumber":"1","segmentSourceCode":"CCR","bookingConfirmationNumber":"CONF1440001","travelProductSupplyCode":"ZT","vehicleCompanyCode":"ZT","vehicleCompanyName":"THRIFTY","vehicleGradeCode":"ECAR","segmentStatusCode":"HK","vehicleHire":{"pickUpLocalTimestamp":"05/12/2017 11:00:00","pickUpUTCTimestamp":"05/12/2017 00:00:00","dropOffLocalTimestamp":"05/12/2017 14:00:00","dropOffUTCTimestamp":"06/12/2017 01:00:00"},"vehicleHireLocation":{"pickUp":{"cityCode":"MEL","airportCode":"MEL","locationName":null},"dropOff":{"cityCode":"MEL","airportCode":null,"locationName":null}}},{"vehicleSegmentId":"1441441441440002","segmentTattooReferenceNumber":"2","segmentSourceCode":"CCR","bookingConfirmationNumber":"CONF1440001","travelProductSupplyCode":"ZT","vehicleCompanyCode":"ZT","vehicleCompanyName":"THRIFTY","vehicleGradeCode":"ECAR","segmentStatusCode":"HK","vehicleHire":{"pickUpLocalTimestamp":"05/12/2017 11:00:00","pickUpUTCTimestamp":"05/12/2017 00:00:00","dropOffLocalTimestamp":"05/12/2017 14:00:00","dropOffUTCTimestamp":"06/12/2017 01:00:00"},"vehicleHireLocation":{"pickUp":{"cityCode":"MEL","airportCode":"MEL","locationName":null},"dropOff":{"cityCode":"MEL","airportCode":null,"locationName":null}}}],"other":[{"otherTattooReferenceNumber":"52","segmentId":"9208109317857456","serviceKeywordCode":"CFDD","serviceSourceCode":"SSR","passengerSegmentRelationTypeCode":"B","departureCityCode":null,"arrivalCityCode":null,"requestStatusCode":null,"requestPassengerQuantity":null,"chargeableIndicator":null,"requestCarrierCode":null,"serviceGroupCode":null,"serviceGroupSubCode":null,"serviceLocalDate":null,"serviceConsumedIndicator":null,"additionalText":"TEST OTHER2"},{"otherTattooReferenceNumber":"53","segmentId":"9208109317857456","serviceKeywordCode":"STPC","serviceSourceCode":"SSR","passengerSegmentRelationTypeCode":"B","departureCityCode":null,"arrivalCityCode":null,"requestStatusCode":null,"requestPassengerQuantity":null,"chargeableIndicator":null,"requestCarrierCode":null,"serviceGroupCode":null,"serviceGroupSubCode":null,"serviceLocalDate":null,"serviceConsumedIndicator":null,"additionalText":"TEST OTHER3"}]}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_PNRAncillaryInfoWrapper wrap = QCC_InvokeCAPAPI.invokePNRAncillaryInfoCAPAPI('K5F5ZE', '05/12/2017', '123456778556', 'false');
        system.assert(wrap != Null, 'invokePNRAncillaryInfoCAPAPI returns Null');
        Test.stopTest();
    }
    
    static TestMethod void invokePNRAncillaryInfoCAPAPITestwithNC() {
        Trigger_Status__c triggerStatus = [select Id, Name, Active__c from Trigger_Status__c where Name = 'UseNamedCred'];
        triggerStatus.Active__c = true;
        update triggerStatus;
        
        String Body = '{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","lastUpdatedTimeStamp":"05/12/2017 04:28:00","insurance":[{"insuranceId":"1401401401400001","insuranceTattoo":"88","policyCode":"USE","policyName":"TWO AUSTRALIAN CANCELLATION TRAVEL PLAN","insuranceConfirmationNumber":"QQU01014558-0","segmentStatusCode":"HK","insuranceStartLocalDate":"05/12/2017","insuranceEndLocalDate":"31/12/2018","providerCompanyCode":"OIU","providerCompanyName":null,"providerCountryCode":"AU","tripTypeCode":"FLT","totalTripAmount":"200.000","totalPremiumAmount":"250.000","currencyCode":"AUD"}],"accommodation":[{"accommodationSegmentId":"1431431431430001","segmentTattooReferenceNumber":"1","segmentSourceCode":"HHL","accommodationBookingReferenceNumber":"TEST1","bookingConfirmationNumber":"CONF143","travelProductSupplyCode":"XY","checkinLocalDate":"06/12/2017","checkoutLocalDate":"07/12/2017","locatedCityCode":"MEL","accommodationChainCode":"YX","accommodationChainName":"SYNXIS","accommodationPropertyCode":"MSM","accommodationPropertyName":"MERITON SUITES MASCOT CENTRAL","roomsDeliveredQuantity":"1","segmentStatusCode":"HK"},{"accommodationSegmentId":"1431431431430002","segmentTattooReferenceNumber":"2","segmentSourceCode":"HHL","accommodationBookingReferenceNumber":"TEST2","bookingConfirmationNumber":"CONF143","travelProductSupplyCode":"YZ","checkinLocalDate":"06/12/2017","checkoutLocalDate":"07/12/2017","locatedCityCode":"MEL","accommodationChainCode":"YX","accommodationChainName":"SYNXIS","accommodationPropertyCode":"MSM","accommodationPropertyName":"MERITON SUITES MASCOT CENTRAL","roomsDeliveredQuantity":"1","segmentStatusCode":"HK"}],"vehicle":[{"vehicleSegmentId":"1441441441440001","segmentTattooReferenceNumber":"1","segmentSourceCode":"CCR","bookingConfirmationNumber":"CONF1440001","travelProductSupplyCode":"ZT","vehicleCompanyCode":"ZT","vehicleCompanyName":"THRIFTY","vehicleGradeCode":"ECAR","segmentStatusCode":"HK","vehicleHire":{"pickUpLocalTimestamp":"05/12/2017 11:00:00","pickUpUTCTimestamp":"05/12/2017 00:00:00","dropOffLocalTimestamp":"05/12/2017 14:00:00","dropOffUTCTimestamp":"06/12/2017 01:00:00"},"vehicleHireLocation":{"pickUp":{"cityCode":"MEL","airportCode":"MEL","locationName":null},"dropOff":{"cityCode":"MEL","airportCode":null,"locationName":null}}},{"vehicleSegmentId":"1441441441440002","segmentTattooReferenceNumber":"2","segmentSourceCode":"CCR","bookingConfirmationNumber":"CONF1440001","travelProductSupplyCode":"ZT","vehicleCompanyCode":"ZT","vehicleCompanyName":"THRIFTY","vehicleGradeCode":"ECAR","segmentStatusCode":"HK","vehicleHire":{"pickUpLocalTimestamp":"05/12/2017 11:00:00","pickUpUTCTimestamp":"05/12/2017 00:00:00","dropOffLocalTimestamp":"05/12/2017 14:00:00","dropOffUTCTimestamp":"06/12/2017 01:00:00"},"vehicleHireLocation":{"pickUp":{"cityCode":"MEL","airportCode":"MEL","locationName":null},"dropOff":{"cityCode":"MEL","airportCode":null,"locationName":null}}}],"other":[{"otherTattooReferenceNumber":"52","segmentId":"9208109317857456","serviceKeywordCode":"CFDD","serviceSourceCode":"SSR","passengerSegmentRelationTypeCode":"B","departureCityCode":null,"arrivalCityCode":null,"requestStatusCode":null,"requestPassengerQuantity":null,"chargeableIndicator":null,"requestCarrierCode":null,"serviceGroupCode":null,"serviceGroupSubCode":null,"serviceLocalDate":null,"serviceConsumedIndicator":null,"additionalText":"TEST OTHER2"},{"otherTattooReferenceNumber":"53","segmentId":"9208109317857456","serviceKeywordCode":"STPC","serviceSourceCode":"SSR","passengerSegmentRelationTypeCode":"B","departureCityCode":null,"arrivalCityCode":null,"requestStatusCode":null,"requestPassengerQuantity":null,"chargeableIndicator":null,"requestCarrierCode":null,"serviceGroupCode":null,"serviceGroupSubCode":null,"serviceLocalDate":null,"serviceConsumedIndicator":null,"additionalText":"TEST OTHER3"}]}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_PNRAncillaryInfoWrapper wrap = QCC_InvokeCAPAPI.invokePNRAncillaryInfoCAPAPI('K5F5ZE', '05/12/2017', '123456778556', 'false');
        system.assert(wrap != Null, 'invokePNRAncillaryInfoCAPAPI returns Null');
        Test.stopTest();
    }

    static TestMethod void invokePNRLegStatusInfoCAPAPITestWithQantasAPI() {
        Qantas_API__c qantasAPI = [select Id,Name,EndPoint__c,ClientId__c, ClientSecret__c from Qantas_API__c where Name ='QCC_CAPPNRRetrieve'];
         qantasAPI.EndPoint__c = qantasAPI.EndPoint__c;
        
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","lastUpdatedTimeStamp":"05/12/2017 04:28:00","passengerFlightStatus":[{"passengerSegmentId":"773984470592206","segmentId":"9178306296255759","passengerId":"9018991125607359","passengerTattoo":"3","segmentTattoo":"1","travellerProductId":"2301CA3500008BE1","reservationStatusCode":"HK","bookedCabinClass":"Y","bookedReservationClass":"Y","leg":[{"legId":"8961376721667362","originAirportCode":"SYD","destinationAirportCode":"MEL","otherTattoo":"27","bagPoolId":"0","hoPoolIndicator":"N","legSequenceNumber":"1","seatNumber":null,"seatPreferenceCode":null,"onLoadStatusCode":null,"forcedAcceptanceIndicator":null,"freezeAcceptanceIndicator":null,"boardingPassPrintStatusCode":"NPT","baggageStatusCode":"NBG","acceptance":{"statusCode":"CNA","originTypeCode":null,"channelTypeCode":null,"cancelReasonCode":null},"boardingStatusCode":"NBD","customerRecordStatusCode":"REC","waitListStatusCode":"NCW","transferStatusCode":"NFL","regrade":{"statusCode":"NRG","authorizer":null,"reasonCode":null,"targetCabinClass":null},"checkinCarrierCode":null,"involuntaryCompensationIndicator":null,"compensationStatusCode":null,"compensationReasonText":null}]}]}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_PNRLegStatusInfoWrapper wrap = QCC_InvokeCAPAPI.invokePNRLegStatusInfoCAPAPI('K5F5ZE', '05/12/2017', '9018991125607359','9178306296255759','123456778556', false,'false');
        system.assert(wrap != Null, 'invokePNRLegStatusInfoCAPAPI returns Null');
        Test.stopTest();
    }
    static TestMethod void invokePNRLegStatusInfoCAPAPITestWithNC() {
      Trigger_Status__c triggerStatus = [select Id, Name, Active__c from Trigger_Status__c where Name = 'UseNamedCred'];
        triggerStatus.Active__c = true;
        update triggerStatus;
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","lastUpdatedTimeStamp":"05/12/2017 04:28:00","passengerFlightStatus":[{"passengerSegmentId":"773984470592206","segmentId":"9178306296255759","passengerId":"9018991125607359","passengerTattoo":"3","segmentTattoo":"1","travellerProductId":"2301CA3500008BE1","reservationStatusCode":"HK","bookedCabinClass":"Y","bookedReservationClass":"Y","leg":[{"legId":"8961376721667362","originAirportCode":"SYD","destinationAirportCode":"MEL","otherTattoo":"27","bagPoolId":"0","hoPoolIndicator":"N","legSequenceNumber":"1","seatNumber":null,"seatPreferenceCode":null,"onLoadStatusCode":null,"forcedAcceptanceIndicator":null,"freezeAcceptanceIndicator":null,"boardingPassPrintStatusCode":"NPT","baggageStatusCode":"NBG","acceptance":{"statusCode":"CNA","originTypeCode":null,"channelTypeCode":null,"cancelReasonCode":null},"boardingStatusCode":"NBD","customerRecordStatusCode":"REC","waitListStatusCode":"NCW","transferStatusCode":"NFL","regrade":{"statusCode":"NRG","authorizer":null,"reasonCode":null,"targetCabinClass":null},"checkinCarrierCode":null,"involuntaryCompensationIndicator":null,"compensationStatusCode":null,"compensationReasonText":null}]}]}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_PNRLegStatusInfoWrapper wrap = QCC_InvokeCAPAPI.invokePNRLegStatusInfoCAPAPI('K5F5ZE', '05/12/2017', '9018991125607359','9178306296255759','123456778556', false,'false');
        system.assert(wrap != Null, 'invokePNRLegStatusInfoCAPAPI returns Null');
        Test.stopTest();
    }


    static TestMethod void invokePNRSSRInfoCAPAPIITestwithQantasAPI() {

         Qantas_API__c qantasAPI = [select Id,Name,EndPoint__c,ClientId__c, ClientSecret__c from Qantas_API__c where Name ='QCC_CAPPNRRetrieve'];
         qantasAPI.EndPoint__c = qantasAPI.EndPoint__c;
        
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","lastUpdatedTimeStamp":"05/12/2017 04:28:00","serviceRequest":[{"passengerId":"9018991125607359","segmentId":"9178306296255759","segmentTattoo":"1","passengerTattoo":"3","seat":[{"seatRequestId":"1521521521520001","serviceKeywordCode":"RQST","serviceSourceCode":"SSR","otherTattooReferenceNumber":"21","passengerSegmentRelationTypeCode":"B","departureCityCode":"SYD","arrivalCityCode":"MEL","requestStatusCode":"HK","airlineCarrierAlphaCode":"QF","requestSeatNumber":"5A","specialAssistancePassengerTypeCode":null,"chargeableIndicator":null,"serviceTotalFareAmount":"0.000","fareCurrencyCode":null,"serviceGroupCode":"A","serviceGroupSubCode":"0B5","gaugeChangeLocalDate":null,"partialSegmentIndicator":null,"additionalText":"TEST SEAT1","characteristics":[{"typecode":"A","code":"N"},{"typecode":"A","code":null},{"typecode":"B","code":null},{"typecode":"B","code":null}]}],"loyalty":[{"loyaltyRequestId":"1501501501500001","serviceKeywordCode":"FQTV","serviceSourceCode":"SSR","otherTattooReferenceNumber":"72","passengerSegmentRelationTypeCode":"B","requestStatusCode":"HK","requestCarrierCode":"QF","schemeOperatorCode":"QF","ffCardNumber":"0006142104","revenueClass":null,"upgradeClass":null,"ffUpgradeCertificate":null,"allianceCarrierCode":"*O","customerValue":null,"airlinePriorityCode":"2","airineTierLevelCode":"FFBR","airlineTierDescription":null,"alliancePriorityCode":null,"allianceTierLevelCode":null,"allianceTierDescription":null,"validFFIndicator":"Y","serviceActionCode":"F","additionalText":"TEST TEXT1"}],"meal":[{"mealRequestId":"1511511511510001","serviceKeywordCode":"VGML","serviceSourceCode":"SSR","otherTattooReferenceNumber":"15","passengerSegmentRelationTypeCode":"B","airlineCarrierAlphaCode":"QF","requestStatusCode":"HK","chargeableIndicator":null,"serviceTotalFareAmount":"0.000","fareCurrencyCode":null,"serviceGroupCode":null,"serviceGroupSubCode":null,"additionalText":"TEST MEAL REQ1"}],"bag":[{"bagRequestId":"1531531531530001","serviceKeywordCode":"BAGW","serviceSourceCode":"SSR","otherTattooReferenceNumber":"41","passengerSegmentRelationTypeCode":"B","departureCityCode":null,"arrivalCityCode":null,"requestStatusCode":"HK","chargeableIndicator":null,"serviceTotalFareAmount":"0.000","fareCurrencyCode":null,"airlineCarrierAlphaCode":"QF","serviceGroupCode":null,"serviceGroupSubCode":null,"serviceLocalDate":null,"serviceConsumedIndicator":null,"additionalText":"TEST BAG1"}],"other":[{"otherRequestId":"1561561561560001","serviceKeywordCode":"CFDC","serviceSourceCode":"SSR","otherTattooReferenceNumber":"51","passengerSegmentRelationTypeCode":"B","departureCityCode":null,"arrivalCityCode":null,"requestStatusCode":null,"requestPassengerQuantity":null,"chargeableIndicator":null,"serviceTotalFareAmount":"0.000","fareCurrencyCode":null,"requestCarrierCode":null,"serviceGroupCode":null,"serviceGroupSubCode":null,"serviceLocalDate":null,"serviceConsumedIndicator":null,"additionalText":"TEST OTHER1"}],"document":[{"docRequestId":"1541541541540001","serviceKeywordCode":"DOCS","serviceSourceCode":"SSR","otherTattooReferenceNumber":"31","issuingCountryCode":"AU","passengerSegmentRelationTypeCode":"B","airlineCarrierAlphaCode":"QF","requestStatusCode":"HK","docNumber":"TEST1234","docTypeCode":"P","firstName":null,"midName":null,"lastName":null,"genderTypeCode":null,"infantIndicator":null,"birthDate":null,"issueDate":"01/01/2016","expiryDate":"31/12/2036","issuePlaceText":null,"nationality":null,"additionalText":null}]}]}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_PNRSSRInfoWrapper wrap = QCC_InvokeCAPAPI.invokePNRSSRInfoCAPAPI('K5F5ZE', '05/12/2017', '9018991125607359','9178306296255759','123456778556', false, 'false');
        system.assert(wrap != Null, 'invokePNRSSRInfoCAPAPI returns Null');
        Test.stopTest();
    }

    
    static TestMethod void invokePNRSSRInfoCAPAPIITestwithNC() {
        Trigger_Status__c triggerStatus = [select Id, Name, Active__c from Trigger_Status__c where Name = 'UseNamedCred'];
        triggerStatus.Active__c = true;
        update triggerStatus;
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","lastUpdatedTimeStamp":"05/12/2017 04:28:00","serviceRequest":[{"passengerId":"9018991125607359","segmentId":"9178306296255759","segmentTattoo":"1","passengerTattoo":"3","seat":[{"seatRequestId":"1521521521520001","serviceKeywordCode":"RQST","serviceSourceCode":"SSR","otherTattooReferenceNumber":"21","passengerSegmentRelationTypeCode":"B","departureCityCode":"SYD","arrivalCityCode":"MEL","requestStatusCode":"HK","airlineCarrierAlphaCode":"QF","requestSeatNumber":"5A","specialAssistancePassengerTypeCode":null,"chargeableIndicator":null,"serviceTotalFareAmount":"0.000","fareCurrencyCode":null,"serviceGroupCode":"A","serviceGroupSubCode":"0B5","gaugeChangeLocalDate":null,"partialSegmentIndicator":null,"additionalText":"TEST SEAT1","characteristics":[{"typecode":"A","code":"N"},{"typecode":"A","code":null},{"typecode":"B","code":null},{"typecode":"B","code":null}]}],"loyalty":[{"loyaltyRequestId":"1501501501500001","serviceKeywordCode":"FQTV","serviceSourceCode":"SSR","otherTattooReferenceNumber":"72","passengerSegmentRelationTypeCode":"B","requestStatusCode":"HK","requestCarrierCode":"QF","schemeOperatorCode":"QF","ffCardNumber":"0006142104","revenueClass":null,"upgradeClass":null,"ffUpgradeCertificate":null,"allianceCarrierCode":"*O","customerValue":null,"airlinePriorityCode":"2","airineTierLevelCode":"FFBR","airlineTierDescription":null,"alliancePriorityCode":null,"allianceTierLevelCode":null,"allianceTierDescription":null,"validFFIndicator":"Y","serviceActionCode":"F","additionalText":"TEST TEXT1"}],"meal":[{"mealRequestId":"1511511511510001","serviceKeywordCode":"VGML","serviceSourceCode":"SSR","otherTattooReferenceNumber":"15","passengerSegmentRelationTypeCode":"B","airlineCarrierAlphaCode":"QF","requestStatusCode":"HK","chargeableIndicator":null,"serviceTotalFareAmount":"0.000","fareCurrencyCode":null,"serviceGroupCode":null,"serviceGroupSubCode":null,"additionalText":"TEST MEAL REQ1"}],"bag":[{"bagRequestId":"1531531531530001","serviceKeywordCode":"BAGW","serviceSourceCode":"SSR","otherTattooReferenceNumber":"41","passengerSegmentRelationTypeCode":"B","departureCityCode":null,"arrivalCityCode":null,"requestStatusCode":"HK","chargeableIndicator":null,"serviceTotalFareAmount":"0.000","fareCurrencyCode":null,"airlineCarrierAlphaCode":"QF","serviceGroupCode":null,"serviceGroupSubCode":null,"serviceLocalDate":null,"serviceConsumedIndicator":null,"additionalText":"TEST BAG1"}],"other":[{"otherRequestId":"1561561561560001","serviceKeywordCode":"CFDC","serviceSourceCode":"SSR","otherTattooReferenceNumber":"51","passengerSegmentRelationTypeCode":"B","departureCityCode":null,"arrivalCityCode":null,"requestStatusCode":null,"requestPassengerQuantity":null,"chargeableIndicator":null,"serviceTotalFareAmount":"0.000","fareCurrencyCode":null,"requestCarrierCode":null,"serviceGroupCode":null,"serviceGroupSubCode":null,"serviceLocalDate":null,"serviceConsumedIndicator":null,"additionalText":"TEST OTHER1"}],"document":[{"docRequestId":"1541541541540001","serviceKeywordCode":"DOCS","serviceSourceCode":"SSR","otherTattooReferenceNumber":"31","issuingCountryCode":"AU","passengerSegmentRelationTypeCode":"B","airlineCarrierAlphaCode":"QF","requestStatusCode":"HK","docNumber":"TEST1234","docTypeCode":"P","firstName":null,"midName":null,"lastName":null,"genderTypeCode":null,"infantIndicator":null,"birthDate":null,"issueDate":"01/01/2016","expiryDate":"31/12/2036","issuePlaceText":null,"nationality":null,"additionalText":null}]}]}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_PNRSSRInfoWrapper wrap = QCC_InvokeCAPAPI.invokePNRSSRInfoCAPAPI('K5F5ZE', '05/12/2017', '9018991125607359','9178306296255759','123456778556', false, 'false');
        system.assert(wrap != Null, 'invokePNRSSRInfoCAPAPI returns Null');
        Test.stopTest();
    }
    
    static TestMethod void testinvokeBookingCAPAPIWithQantasAPI() {

         Qantas_API__c qantasAPI = [select Id,Name,EndPoint__c,ClientId__c, ClientSecret__c from Qantas_API__c where Name ='QCC_BookingSummaryAPI'];
         qantasAPI.EndPoint__c = qantasAPI.EndPoint__c;
        
        String Body = '{"bookings":[{"reloc":"MWYX4S","travelPlanId":"950121165952060","bookingId":"950121165952060","creationDate":"2017-12-22","currentPassengerQuantity":"3","segmentType":"AIR","departureTimeStamp":"01/03/2018 01:35:00","departurePort":"BNE","departureCity":"BNE","arrivalPort":"PER","arrivalCity":"PER","lastUpdatedTimeStamp":"15/01/2018 23:25:00","archivalData":"false"},{"reloc":"MWYG78","travelPlanId":"950121165930116","bookingId":"950121165930116","creationDate":"2017-12-22","currentPassengerQuantity":"3","segmentType":"AIR","departureTimeStamp":"15/02/2018 02:40:00","departurePort":"CBR","departureCity":"CBR","arrivalPort":"MEL","arrivalCity":"MEL","lastUpdatedTimeStamp":"15/01/2018 23:26:00","archivalData":"false"}],"activeCustomerId":"710000000060"}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        mapHeader.put('System', 'CAPCRE_CC');
        mapHeader.put('client_id', 'qantasAPI.ClientId__c');
        mapHeader.put('client_secret', 'qantasAPI.ClientSecret__c');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_BookingSummaryWrapper wrap = QCC_InvokeCAPAPI.invokeBookingCAPAPI('1234565', '10', 2);
        system.assert(wrap != Null, 'invokeBookingCAPAPI returns Null');
        Test.stopTest();
    }
    
    static TestMethod void testinvokeBookingCAPAPIWithNamedCred() {
        
		Trigger_Status__c triggerStatus = [select Id, Name, Active__c from Trigger_Status__c where Name = 'UseNamedCred'];
        triggerStatus.Active__c = true;
        update triggerStatus;

        String body = '{"your":"mocked response"}';
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', body, mapHeader));
		QCC_BookingSummaryWrapper wrap = QCC_InvokeCAPAPI.invokeBookingCAPAPI('1234565', '10', 2);        
        Test.stopTest();
        
        // Validate the results
        System.assertNotEquals(null, wrap);
  
    }
	
    
    static TestMethod void invokePNRFlightHistInfoCAPAPIITest3QAPI() {
        
         Qantas_API__c qantasAPI = [select Id,Name,EndPoint__c,ClientId__c, ClientSecret__c from Qantas_API__c where Name ='QCC_BookingSummaryAPI'];
         qantasAPI.EndPoint__c = qantasAPI.EndPoint__c;
        
        String Body = '{"booking":{"reloc":"MXDG8G","travelPlanId":"1111100000","bookingId":"1","creationDate":"22/12/2017","lastUpdatedTimeStamp":null,"segments":[{"segmentId":"2","segmentTattoo":"1","marketingCarrierAlphaCode":"QF","marketingFlightNumber":"0063","marketingFlightSuffix":"","departureAirportCode":"SYD","arrivalAirportCode":"JNB","operatingCarrierAlphaCode":"QF","operatingFlightNumber":"63","operatingFlightSuffix":"","departureCityCode":"SYD","arrivalCityCode":"JNB","departureLocalDate":"02/06/2018","departureLocalTime":"00:00:01","actualDepartureLocalDate":null,"actualDepartureLocalTime":null,"departureTerminalCode":"","arrivalLocalDate":"30/06/2018","arrivalLocalTime":"00:00:01","actualArrivalLocalDate":null,"actualArrivalLocalTime":null,"arrivalTerminalCode":"","departureUTCDate":"30/06/2018","departureUTCTime":"00:19:30","arrivalUTCDate":"30/06/2018","arrivalUTCTime":"00:20:50","departureDow":null,"dateVar":"0","flightTypeCode":"","aircraftTypeCode":null,"codeShareFlightTypeCode":"","codeShareAgreementTypeCode":"","disrupts":[{"type":"CANCELLED","legDepartureAirportCode":"SYD","legArrivalAirportCode":"JNB","unScheduledArrivalAirport":null,"details":[{"reasonCode":"122","shortDescription":"TECH","longDescription":"AIRCRAFT DEFECTS","delayDuration":"0"}]}]}]}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_PNRFlightInfoWrapper wrap = QCC_InvokeCAPAPI.invokePNRFlightInfoCAPAPI('K5F5ZE', '05/12/2017','123456778556', true, 'true');
        system.assert(wrap != Null, 'invokePNRFlightHistInfoCAPAPI returns Null');
        system.debug('Json serialize'+ JSON.serialize(wrap));
        Test.stopTest();
    }
    
    
    static TestMethod void invokePNRFlightHistInfoCAPAPIITest3NC() {
        
        Trigger_Status__c triggerStatus = [select Id, Name, Active__c from Trigger_Status__c where Name = 'UseNamedCred'];
        triggerStatus.Active__c = true;
        update triggerStatus;        
        
        String Body = '{"booking":{"reloc":"MXDG8G","travelPlanId":"1111100000","bookingId":"1","creationDate":"22/12/2017","lastUpdatedTimeStamp":null,"segments":[{"segmentId":"2","segmentTattoo":"1","marketingCarrierAlphaCode":"QF","marketingFlightNumber":"0063","marketingFlightSuffix":"","departureAirportCode":"SYD","arrivalAirportCode":"JNB","operatingCarrierAlphaCode":"QF","operatingFlightNumber":"63","operatingFlightSuffix":"","departureCityCode":"SYD","arrivalCityCode":"JNB","departureLocalDate":"02/06/2018","departureLocalTime":"00:00:01","actualDepartureLocalDate":null,"actualDepartureLocalTime":null,"departureTerminalCode":"","arrivalLocalDate":"30/06/2018","arrivalLocalTime":"00:00:01","actualArrivalLocalDate":null,"actualArrivalLocalTime":null,"arrivalTerminalCode":"","departureUTCDate":"30/06/2018","departureUTCTime":"00:19:30","arrivalUTCDate":"30/06/2018","arrivalUTCTime":"00:20:50","departureDow":null,"dateVar":"0","flightTypeCode":"","aircraftTypeCode":null,"codeShareFlightTypeCode":"","codeShareAgreementTypeCode":"","disrupts":[{"type":"CANCELLED","legDepartureAirportCode":"SYD","legArrivalAirportCode":"JNB","unScheduledArrivalAirport":null,"details":[{"reasonCode":"122","shortDescription":"TECH","longDescription":"AIRCRAFT DEFECTS","delayDuration":"0"}]}]}]}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_PNRFlightInfoWrapper wrap = QCC_InvokeCAPAPI.invokePNRFlightInfoCAPAPI('K5F5ZE', '05/12/2017','123456778556', true, 'true');
        system.assert(wrap != Null, 'invokePNRFlightHistInfoCAPAPI returns Null');
        system.debug('Json serialize'+ JSON.serialize(wrap));
        Test.stopTest();
    }


    /*
    static TestMethod void invokePNRLegStatusHistInfoCAPAPITest() {
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","lastUpdatedTimeStamp":"05/12/2017 04:28:00","passengerFlightStatus":[{"passengerSegmentId":"773984470592206","segmentId":"9178306296255759","passengerId":"9018991125607359","passengerTattoo":"3","segmentTattoo":"1","travellerProductId":"2301CA3500008BE1","reservationStatusCode":"HK","bookedCabinClass":"Y","bookedReservationClass":"Y","leg":[{"legId":"8961376721667362","originAirportCode":"SYD","destinationAirportCode":"MEL","otherTattoo":"27","bagPoolId":"0","hoPoolIndicator":"N","legSequenceNumber":"1","seatNumber":null,"seatPreferenceCode":null,"onLoadStatusCode":null,"forcedAcceptanceIndicator":null,"freezeAcceptanceIndicator":null,"boardingPassPrintStatusCode":"NPT","baggageStatusCode":"NBG","acceptance":{"statusCode":"CNA","originTypeCode":null,"channelTypeCode":null,"cancelReasonCode":null},"boardingStatusCode":"NBD","customerRecordStatusCode":"REC","waitListStatusCode":"NCW","transferStatusCode":"NFL","regrade":{"statusCode":"NRG","authorizer":null,"reasonCode":null,"targetCabinClass":null},"checkinCarrierCode":null,"involuntaryCompensationIndicator":null,"compensationStatusCode":null,"compensationReasonText":null}]}]}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_PNRLegStatusInfoWrapper wrap = QCC_InvokeCAPAPI.invokePNRLegStatusInfoCAPAPI('K5F5ZE', '05/12/2017', '9018991125607359','9178306296255759','123456778556', true, 'true');
        system.assert(wrap != Null, 'invokePNRLegStatusInfoCAPAPI returns Null');
        Test.stopTest();
    }
*/
 /*
    static TestMethod void invokePNRSSRHistInfoCAPAPIITest() {
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","lastUpdatedTimeStamp":"05/12/2017 04:28:00","serviceRequest":[{"passengerId":"9018991125607359","segmentId":"9178306296255759","segmentTattoo":"1","passengerTattoo":"3","seat":[{"seatRequestId":"1521521521520001","serviceKeywordCode":"RQST","serviceSourceCode":"SSR","otherTattooReferenceNumber":"21","passengerSegmentRelationTypeCode":"B","departureCityCode":"SYD","arrivalCityCode":"MEL","requestStatusCode":"HK","airlineCarrierAlphaCode":"QF","requestSeatNumber":"5A","specialAssistancePassengerTypeCode":null,"chargeableIndicator":null,"serviceTotalFareAmount":"0.000","fareCurrencyCode":null,"serviceGroupCode":"A","serviceGroupSubCode":"0B5","gaugeChangeLocalDate":null,"partialSegmentIndicator":null,"additionalText":"TEST SEAT1","characteristics":[{"typecode":"A","code":"N"},{"typecode":"A","code":null},{"typecode":"B","code":null},{"typecode":"B","code":null}]}],"loyalty":[{"loyaltyRequestId":"1501501501500001","serviceKeywordCode":"FQTV","serviceSourceCode":"SSR","otherTattooReferenceNumber":"72","passengerSegmentRelationTypeCode":"B","requestStatusCode":"HK","requestCarrierCode":"QF","schemeOperatorCode":"QF","ffCardNumber":"0006142104","revenueClass":null,"upgradeClass":null,"ffUpgradeCertificate":null,"allianceCarrierCode":"*O","customerValue":null,"airlinePriorityCode":"2","airineTierLevelCode":"FFBR","airlineTierDescription":null,"alliancePriorityCode":null,"allianceTierLevelCode":null,"allianceTierDescription":null,"validFFIndicator":"Y","serviceActionCode":"F","additionalText":"TEST TEXT1"}],"meal":[{"mealRequestId":"1511511511510001","serviceKeywordCode":"VGML","serviceSourceCode":"SSR","otherTattooReferenceNumber":"15","passengerSegmentRelationTypeCode":"B","airlineCarrierAlphaCode":"QF","requestStatusCode":"HK","chargeableIndicator":null,"serviceTotalFareAmount":"0.000","fareCurrencyCode":null,"serviceGroupCode":null,"serviceGroupSubCode":null,"additionalText":"TEST MEAL REQ1"}],"bag":[{"bagRequestId":"1531531531530001","serviceKeywordCode":"BAGW","serviceSourceCode":"SSR","otherTattooReferenceNumber":"41","passengerSegmentRelationTypeCode":"B","departureCityCode":null,"arrivalCityCode":null,"requestStatusCode":"HK","chargeableIndicator":null,"serviceTotalFareAmount":"0.000","fareCurrencyCode":null,"airlineCarrierAlphaCode":"QF","serviceGroupCode":null,"serviceGroupSubCode":null,"serviceLocalDate":null,"serviceConsumedIndicator":null,"additionalText":"TEST BAG1"}],"other":[{"otherRequestId":"1561561561560001","serviceKeywordCode":"CFDC","serviceSourceCode":"SSR","otherTattooReferenceNumber":"51","passengerSegmentRelationTypeCode":"B","departureCityCode":null,"arrivalCityCode":null,"requestStatusCode":null,"requestPassengerQuantity":null,"chargeableIndicator":null,"serviceTotalFareAmount":"0.000","fareCurrencyCode":null,"requestCarrierCode":null,"serviceGroupCode":null,"serviceGroupSubCode":null,"serviceLocalDate":null,"serviceConsumedIndicator":null,"additionalText":"TEST OTHER1"}],"document":[{"docRequestId":"1541541541540001","serviceKeywordCode":"DOCS","serviceSourceCode":"SSR","otherTattooReferenceNumber":"31","issuingCountryCode":"AU","passengerSegmentRelationTypeCode":"B","airlineCarrierAlphaCode":"QF","requestStatusCode":"HK","docNumber":"TEST1234","docTypeCode":"P","firstName":null,"midName":null,"lastName":null,"genderTypeCode":null,"infantIndicator":null,"birthDate":null,"issueDate":"01/01/2016","expiryDate":"31/12/2036","issuePlaceText":null,"nationality":null,"additionalText":null}]}]}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_PNRSSRInfoWrapper wrap = QCC_InvokeCAPAPI.invokePNRSSRInfoCAPAPI('K5F5ZE', '05/12/2017', '9018991125607359','9178306296255759','123456778556', true, 'true');
        system.assert(wrap != Null, 'invokePNRSSRInfoCAPAPI returns Null');
        Test.stopTest();
    }
*/

    static TestMethod void invokeFlightStatusAPITest() {
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
            String body = '{'+
        '   "flights":['+
        '       {'+
        '           "flightNumbers":['+
        '               {'+
        '                   "airline":"QF",'+
        '                   "code":1,'+
        '                   "primary":true,'+
        '                   "originDate":"2018-05-22",'+
        '                   "threeLetterAirline":"QFA",'+
        '                   "registrationNumber":"VHOQD"'+
        '               }'+
        '           ],'+
        '           "sectors":['+
        '               {'+
        '                   "sectorId":"QF1_SYD_SIN_22052018",'+
        '                   "from_x":"SYD",'+
        '                   "to":"SIN",'+
        '                   "departure":'+
        '                   {'+
        '                       "estimated":"2018-05-22T15:55:00+10:00",'+
        '                       "actual":"",'+
        '                       "scheduled":"2018-05-22T15:55:00+10:00",'+
        '                       "status":"Estimated",'+
        '                       "terminal":"T1",'+
        '                       "gate":"8",'+
        '                       "boardingStatus":"",'+
        '                       "eligibleForSubscription":true'+
        '                   },'+
        '                   "arrival":'+
        '                   {'+
        '                       "estimated":"2018-05-22T22:15:00+08:00",'+
        '                       "actual":"",'+
        '                       "scheduled":"2018-05-22T22:15:00+08:00",'+
        '                       "status":"Estimated",'+
        '                       "terminal":"",'+
        '                       "gate":"",'+
        '                       "eligibleForSubscription":true'+
        '                   },'+
        '                   "sectorDiversion":"PLANNED"'+
        '               },'+
        '               {'+
        '                   "sectorId":"QF1_SIN_LHR_22052018",'+
        '                   "from_x":"SIN",'+
        '                   "to":"LHR",'+
        '                   "departure":'+
        '                   {'+
        '                       "estimated":"2018-05-22T23:55:00+08:00",'+
        '                       "actual":"",'+
        '                       "scheduled":"2018-05-22T23:55:00+08:00",'+
        '                       "status":"Estimated",'+
        '                       "terminal":"",'+
        '                       "gate":"",'+
        '                       "boardingStatus":"",'+
        '                       "eligibleForSubscription":true'+
        '                   },'+
        '                   "arrival":'+
        '                   {'+
        '                       "estimated":"2018-05-23T06:55:00+01:00",'+
        '                       "actual":"",'+
        '                       "scheduled":"2018-05-23T06:55:00+01:00",'+
        '                       "status":"Estimated",'+
        '                       "terminal":"",'+
        '                       "gate":"",'+
        '                       "eligibleForSubscription":true'+
        '                   },'+
        '                   "sectorDiversion":"PLANNED"'+
        '               }'+
        '           ]'+
        '       }'+
        '   ]'+
        '   ,"lastUpdatedDateTime":"2018-05-22T00:12:35.686Z"'+
        '}';
            Test.setMock(HttpCalloutMock.class, new QCC_CAPFlightInfoMock(200, 'Success', Body, mapHeader));
        QCC_FlightStatusAPIResponse wrap = QCC_InvokeCAPAPI.invokeFlightStatusAPI('05/12/2017', '05/12/2017','QF0001');
        system.assert(wrap != Null, 'invokeFlightStatusAPI returns Null');
        Test.stopTest();
    }

    static TestMethod void invokeFlightInfoAPITest2() {
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        String body = '{  '
            +'   "flights":[  '
            +'		  {  '
            +'			 "marketingCarrier":"QF",'
            +'			 "marketingFlightNo":"0516",'
            +'			 "suffix":"",'
            +'			 "departureAirportCode":"LHR",'
            +'			 "departureAirportName":"BRISBANE",'
            +'			 "arrivalAirportCode":"SYD",'
            +'			 "arrivalAirportName":"KINGSFORD SMITH",'
            +'			 "departureTerminal":"",'
            +'			 "departureGate":"",'
            +'			 "arrivalTerminal":"",'
            +'			 "arrivalGate":"",'
            +'			 "equipmentTailNumber":null,'
            +'			 "equipmentTypeCode":"146",'
            +'			 "equipmentSubTypeCode":"14Z",'
            +'			 "flightStatus":"",'
            +'			 "flightDuration":"90",'
            +'			 "delayDuration":null,'
            +'			 "scheduledDepartureUTCTimeStamp":"28/03/2018 14:05:00",'
            +'			 "estimatedDepartureUTCTimeStamp":null,'
            +'			 "actualDepartureUTCTimeStamp":null,'
            +'			 "scheduledArrivalUTCTimeStamp":"28/03/2018 15:35:00",'
            +'			 "estimatedArrivalUTCTimeStamp":null,'
            +'			 "actualArrivalUTCTimeStamp":null,'
            +'			 "scheduledDepartureLocalTimeStamp":"29/03/2018 00:05:00",'
            +'			 "estimatedDepartureLocalTimeStamp":null,'
            +'			 "actualDepartureLocalTimeStamp":null,'
            +'			 "scheduledArrivalLocalTimeStamp":"29/03/2018 02:35:00",'
            +'			 "estimatedArrivalLocalTimeStamp":null,'
            +'			 "actualArrivalLocalTimeStamp":null,'
            +'			 "primaryBaggageCarousel":"",'
            +'			 "secondaryBaggageCarousel":""'
            +'           ,"delay": [{'
            +'           "reasonCode": "580",'
            +'           "shortDescription": "IT",'
            +'           "longDescription": "max 200 chars",'
            +'           "delayDuration": "100"'
            +'           }]'
            +' 			,"airDiversion": {'
            +'            "unScheduledArrivalAirport": "SYD"'
            +'        		}'
            +'		  }'
            +'   ]'
            +'}';
        Test.setMock(HttpCalloutMock.class, new QCC_CAPFlightInfoMock(200, 'Success', Body, mapHeader));
        QCC_FlightInfoResponse  wrap = QCC_InvokeCAPAPI.invokeFlightInfoAPI('05/12/2017', '05/12/2017','QF0001', 'SYD', 'QF');
        system.assert(wrap != Null, 'invokeFlightInfoAPI returns Null');
        Test.stopTest();
    }

    static TestMethod void invokeFlightInfoAPITest() {
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        String body = '{  '
            +'   "flights":[  '
            +'		  {  '
            +'			 "marketingCarrier":"QF",'
            +'			 "marketingFlightNo":"0516",'
            +'			 "suffix":"",'
            +'			 "departureAirportCode":"LHR",'
            +'			 "departureAirportName":"BRISBANE",'
            +'			 "arrivalAirportCode":"SYD",'
            +'			 "arrivalAirportName":"KINGSFORD SMITH",'
            +'			 "departureTerminal":"",'
            +'			 "departureGate":"",'
            +'			 "arrivalTerminal":"",'
            +'			 "arrivalGate":"",'
            +'			 "equipmentTailNumber":null,'
            +'			 "equipmentTypeCode":"146",'
            +'			 "equipmentSubTypeCode":"14Z",'
            +'			 "flightStatus":"",'
            +'			 "flightDuration":"90",'
            +'			 "delayDuration":null,'
            +'			 "scheduledDepartureUTCTimeStamp":"28/03/2018 14:05:00",'
            +'			 "estimatedDepartureUTCTimeStamp":null,'
            +'			 "actualDepartureUTCTimeStamp":null,'
            +'			 "scheduledArrivalUTCTimeStamp":"28/03/2018 15:35:00",'
            +'			 "estimatedArrivalUTCTimeStamp":null,'
            +'			 "actualArrivalUTCTimeStamp":null,'
            +'			 "scheduledDepartureLocalTimeStamp":"29/03/2018 00:05:00",'
            +'			 "estimatedDepartureLocalTimeStamp":null,'
            +'			 "actualDepartureLocalTimeStamp":null,'
            +'			 "scheduledArrivalLocalTimeStamp":"29/03/2018 02:35:00",'
            +'			 "estimatedArrivalLocalTimeStamp":null,'
            +'			 "actualArrivalLocalTimeStamp":null,'
            +'			 "primaryBaggageCarousel":"",'
            +'			 "secondaryBaggageCarousel":""'
            +'           ,"delay": [{'
            +'           "reasonCode": "580",'
            +'           "shortDescription": "IT",'
            +'           "longDescription": "max 200 chars",'
            +'           "delayDuration": "100"'
            +'           }]'
            +' 			,"airDiversion": {'
            +'            "unScheduledArrivalAirport": "SYD"'
            +'        		}'
            +'		  }'
            +'   ]'
            +'}';
        Test.setMock(HttpCalloutMock.class, new QCC_CAPFlightInfoMock(200, 'Success', Body, mapHeader));
        QCC_FlightInfoResponse  wrap = QCC_InvokeCAPAPI.invokeFlightInfoAPI('05/12/2017', '05/12/2017','QF0001', 'SYD');
        system.assert(wrap != Null, 'invokeFlightInfoAPI returns Null');
        Test.stopTest();
    }

    static TestMethod void invokeFlightPassengerAPITest() {
        Test.startTest();
        QCC_FlightPassengersResponse temp = new QCC_FlightPassengersResponse();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        QCC_FlightPassengersResponse  wrap = QCC_InvokeCAPAPI.invokeFlightPassengerAPI('QF0001', System.today(),'SYD', 'MEL', 1);
        system.assert(wrap != Null, 'invokeFlightPassengerAPI returns Null');
        Test.stopTest();
    }

    
	static TestMethod void invokePassengerServiceDetailsTest() {
		Test.startTest();
		QCC_FlightPassengersResponse temp = new QCC_FlightPassengersResponse();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
		QCC_PassengerServiceDetailsResponse  wrap = QCC_InvokeCAPAPI.invokePassengerServiceDetails('qantas','QF0001', '12/01/2023','SYD', 'MEL', 1);
		system.assert(wrap != Null, 'invokePassengerServiceDetails returns Null');
		Test.stopTest();
	}

    static TestMethod void invokeFlightStatusDepsAPITest() {
		Test.startTest();
		QCC_FlightPassengersResponse temp = new QCC_FlightPassengersResponse();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
		QCC_FlightStatusDepsAPIResponse  wrap = QCC_InvokeCAPAPI.invokeFlightStatusDepsAPI('SYD','sydney', 'Melbourne');
		system.assert(wrap != Null, 'invokeFlightStatusDepsAPI returns Null');
		Test.stopTest();
	}
    
    
    static TestMethod void invokeBookingTicketCAPAPITestWithQantasAPI() {

        Qantas_API__c qantasAPI = [select Id,Name,EndPoint__c,ClientId__c, ClientSecret__c from Qantas_API__c where Name ='QCC_CAPPNRRetrieve'];
         qantasAPI.EndPoint__c = qantasAPI.EndPoint__c;
		Test.startTest();
		QCC_FlightPassengersResponse temp = new QCC_FlightPassengersResponse();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
		boolean wrap = QCC_InvokeCAPAPI.invokeBookingTicketCAPAPI('6547', 'Bearer 123456');
		Test.stopTest();
	}
    
     static TestMethod void invokeBookingTicketCAPAPITestWithNC() {
         Trigger_Status__c triggerStatus = [select Id, Name, Active__c from Trigger_Status__c where Name = 'UseNamedCred'];
        triggerStatus.Active__c = true;
        update triggerStatus;
         
  		Test.startTest();
		QCC_FlightPassengersResponse temp = new QCC_FlightPassengersResponse();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
		boolean wrap = QCC_InvokeCAPAPI.invokeBookingTicketCAPAPI('6547', 'Bearer 123456');
		Test.stopTest();
	}
    
    static TestMethod void invokeProductFlightCAPAPITest() {
		Test.startTest();
		QCC_FlightPassengersResponse temp = new QCC_FlightPassengersResponse();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
		String wrap = QCC_InvokeCAPAPI.invokeProductFlightCAPAPI('6142208', 'Bearer 123456',12345678,12345678 ,1);
		Test.stopTest();
	}

   /*--------------------------------------------------------------------------------------      
    Method Name:        invokeProductFlightsCAPAPITest
    Description:        Test method for invokeProductFlightsCAPAPI. //Jira CRM-6052
    Parameter:          RecordId,Integer
    --------------------------------------------------------------------------------------*/ 
    static TestMethod void invokeProductFlightsCAPAPITestwithQantasAPI() {
        
        Trigger_Status__c triggerStatus = new Trigger_Status__c();
        triggerStatus.Name = 'UseNamedCred';
        triggerStatus.Active__c = false;
        insert triggerStatus;
        
         Qantas_API__c qantasAPI = [select Id,Name,EndPoint__c,ClientId__c, ClientSecret__c from Qantas_API__c where Name ='QCC_BookingSummaryAPI'];
         qantasAPI.EndPoint__c = qantasAPI.EndPoint__c;
        
		Test.startTest();
		QCC_FlightPassengersResponse temp = new QCC_FlightPassengersResponse();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
		QCC_CustomerFlightsWrapper.CustomerFlightsWrapper wrap = QCC_InvokeCAPAPI.invokeProductFlightsCAPAPI('6142208', 'Bearer 123456',12345678,12345678 ,1, false);
		Test.stopTest();
	}
    
      static TestMethod void invokeProductFlightsCAPAPITestwithNC() {
        
   Trigger_Status__c triggerStatus = [select Id, Name, Active__c from Trigger_Status__c where Name = 'UseNamedCred'];
        triggerStatus.Active__c = true;
        update triggerStatus;
          
		Test.startTest();
		QCC_FlightPassengersResponse temp = new QCC_FlightPassengersResponse();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
		QCC_CustomerFlightsWrapper.CustomerFlightsWrapper wrap = QCC_InvokeCAPAPI.invokeProductFlightsCAPAPI('6142208', 'Bearer 123456',12345678,12345678 ,1, false);
		Test.stopTest();
	}

    
    static TestMethod void testWrapperClassCoverage(){
        QCC_FlightPassengersResponse fpr = new QCC_FlightPassengersResponse();
        QCC_FlightPassengersResponse.Address  add  = new QCC_FlightPassengersResponse.Address();
        add.passengerAssociationIndicator  = '1';
        add.contactSourceCode  = '1';
        add.line1  = '1';
        add.line2  = '1';
        add.line3  = '1';
        add.line4  = '1';
        add.state  = '1';
        add.country  = '1';
        add.postBoxName  = '1';
        add.postalCode  = '1';

        QCC_FlightPassengersResponse.Tier   tier  = new QCC_FlightPassengersResponse.Tier();
        tier.old   = '1';
        tier.new_Z   = '1';
        tier.changeDate   = '1';

        QCC_FlightPassengersResponse.Meal   meal  = new QCC_FlightPassengersResponse.Meal();
        meal.code    = '1';
        meal.description    = '1';

        QCC_FlightPassengersResponse.Email mail = new QCC_FlightPassengersResponse.Email();
        mail.contactKeyWordCode = '1';

        QCC_FlightPassengersResponse.ConnectingFlight  ConnectingFlight = new QCC_FlightPassengersResponse.ConnectingFlight();
        ConnectingFlight.flightTypeCode = '1';
        ConnectingFlight.carrierCode = '1';
        ConnectingFlight.flightNo = '1';
        ConnectingFlight.departurePort = '1';
        ConnectingFlight.arrivalPort = '1';
        ConnectingFlight.departureLocalDateTime = '1';

        QCC_FlightPassengersResponse.Leg  Leg = new QCC_FlightPassengersResponse.Leg();
        Leg.sequenceNumber  = '1';
        Leg.checkinStatus  = '1';
        Leg.seatNo  = '1';
        Leg.regrade  = null;

        QCC_FlightPassengersResponse.DomesticTravelPreference DomesticTravelPreference = new QCC_FlightPassengersResponse.DomesticTravelPreference();
        DomesticTravelPreference.meal = null;
        DomesticTravelPreference.seat = null;

        QCC_FlightPassengersResponse.ContactDetails ContactDetails = new QCC_FlightPassengersResponse.ContactDetails();
        ContactDetails.address  = null;

        QCC_FlightPassengersResponse.OccurrenceCount  OccurrenceCount = new QCC_FlightPassengersResponse.OccurrenceCount();
        OccurrenceCount.complaint  = '1';
        OccurrenceCount.supriseDelight   = '1';
        OccurrenceCount.serviceFailure   = '1';
        OccurrenceCount.mbag   = '1';
        OccurrenceCount.flightCancellation   = '1';
        OccurrenceCount.delay   = '1';
        OccurrenceCount.delayDomestic   = '1';
        OccurrenceCount.delayInternational   = '1';
        OccurrenceCount.upgrade   = '1';
        OccurrenceCount.upgradeDomestic   = '1';
        OccurrenceCount.upgradeInternational   = '1';
        OccurrenceCount.downgrade   = '1';
        OccurrenceCount.downgradeDomestic   = '1';
        OccurrenceCount.downgradeInternational   = '1';

        QCC_FlightPassengersResponse.Passengers pass = new QCC_FlightPassengersResponse.Passengers();
        pass.passengerId='1'; 
        pass.customerId='1'; 
        pass.firstName='1'; 
        pass.lastName='1'; 
        pass.namePrefix='1'; 
        pass.genderTypecode='1'; 
        pass.paxTypeCode='1'; 
        pass.dateOfBirth='1'; 
        pass.qfFrequentFlyerNumber='1'; 
        pass.qfTierCode='1'; 
        pass.bookingReference='1'; 
        pass.bookingCreationDate='1'; 
        pass.bookingId='1'; 
        pass.segmentId='1'; 
        pass.segmentTattoo='1'; 
        pass.passengerSegId='1'; 
        pass.offPoint='1'; 
        pass.boardPoint='1'; 
        pass.marketingCarrier='1'; 
        pass.marketingFlightNumber='1'; 
        pass.bookedCabinClass='1'; 
        pass.bookedReservationClass='1'; 
        pass.reservationStatusCode='1'; 
        pass.leg=null; 
        pass.contactDetails=null; 
        pass.connectingFlight=null; 
        pass.otherLoyaltyDetails=null; 
        pass.transactionSummary=null;

        QCC_FlightPassengersResponse.TransactionSummary TransactionSummary = new QCC_FlightPassengersResponse.TransactionSummary();
        TransactionSummary.monthStartDate='1';
        TransactionSummary.airlineCustomerValue='1';
        TransactionSummary.customerValueRank='1';
        TransactionSummary.schemeOperatorCode='1';
        TransactionSummary.tierPriorityNumber='1';
        TransactionSummary.qfTierCode='1';
        TransactionSummary.qfTierName='1';
        TransactionSummary.corporateName='1';
        TransactionSummary.ccoyName='1';
        TransactionSummary.positionName='1';
        TransactionSummary.qci='1';
        TransactionSummary.mcaNumber='1';
        TransactionSummary.corporateRank='1';
        TransactionSummary.occurrenceCount=null; 
        TransactionSummary.cvrCommentText='1';
        TransactionSummary.acvCommentText='1';

        QCC_FlightPassengersResponse.Phone Phone = new QCC_FlightPassengersResponse.Phone();
        Phone.passengerAssociationIndicator='1';
        Phone.contactSourceCode='1';
        Phone.contactKeyWordCode='1';
        Phone.phoneNumber='1';
        Phone.contactPhoneText='1';

        QCC_FlightPassengersResponse.Regrade Regrade = new QCC_FlightPassengersResponse.Regrade();
        Regrade.statusCode='1';
        Regrade.authorizer='1';
        Regrade.reasonCode='1';
        Regrade.cabinCode='1';

            
            
        QCC_FlightPassengersResponse.OtherLoyaltyDetails OtherLoyaltyDetails = new QCC_FlightPassengersResponse.OtherLoyaltyDetails();
        OtherLoyaltyDetails.homeCity=null;
        OtherLoyaltyDetails.tier=null;
        OtherLoyaltyDetails.domesticTravelPreference=null;
        OtherLoyaltyDetails.internationalTravelPreference=null;
        OtherLoyaltyDetails.epLinkedIndicator=null;
            

        QCC_FlightInfoResponse.flight fir = new QCC_FlightInfoResponse.flight();
        fir.suffix = '1';
        fir.departureAirportCode = '1';
        fir.departureAirportName = '1';
        fir.arrivalAirportCode = '1';
        fir.arrivalAirportName = '1';
        fir.departureTerminal = '1';
        fir.departureGate = '1';
        fir.arrivalTerminal = '1';
        fir.arrivalGate = '1';
        fir.flightDuration = '1';
        fir.delayDuration = '1';
        fir.primaryBaggageCarousel = '1';
        fir.secondaryBaggageCarousel = '1';
        QCC_PassengerServiceDetailsResponse psr = new QCC_PassengerServiceDetailsResponse();
        psr.errorMessage = 'nothing';
    }
    
    /*--------------------------------------------------------------------------------------      
    Method Name:        invokeProductFlightAPITest, invokeBookingTicketAPITest, invokeLoyaltyRawProfileAPITest
    Description:        Test Classes
    Parameter:
    Comments :          ADT-92 ADT-90 
    --------------------------------------------------------------------------------------*/ 
    
    static TestMethod void invokeProductFlightAPITest() {
        String Body = '{"flights": [{"reloc": "K5F5ZE","departureAirportCode": "SYD","arrivalAirportCode": "LHR","departureLocalDate": "15/03/2023","departureLocalTime": "17:05:00","reservationStatusCode": "HK","creationDate": "14/03/2023"}]}';
        Map<String, String> mapHeader= new Map<String, String>();
        Datetime today = system.today();
        Datetime timestamp = today.addDays(365);
        Long timestampStr = timestamp.getTime();
        Datetime timestampMinusYear = today.addDays(-365);
        Long timestampMinusYearStr = timestampMinusYear.getTime();
        Integer pageNumber = 1;
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        //QCC_LoyaltyResponseWrapper wrap = QCC_InvokeCAPAPI.invokeLoyaltyAPI('0006142104');
        String wrap =  QCC_InvokeCAPAPI.invokeProductFlightCAPAPI('0006142104', '123456778556', timestampStr, timestampMinusYearStr, pageNumber);
        system.assert(wrap != null, 'invokeBookingTicketCAPAPI returns True');
        Test.stopTest();
    }
     /*
    static TestMethod void invokeBookingTicketAPITest() {
        String Body = '{"reloc": "K5F5ZE","bkgRtid": "91234567890123","currPaxQty": "1","Ticket": [{"airCarrNumCode": "001","airCarrAlphaCode": "QF","electrTktgIndc": "ET","acctblDocNumber": "2987654321","paxId": "909876543212345"}]}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        //QCC_LoyaltyResponseWrapper wrap = QCC_InvokeCAPAPI.invokeLoyaltyAPI('0006142104');
        Boolean wrap =  QCC_InvokeCAPAPI.invokeBookingTicketCAPAPI('K5F5ZE','123456778556');
        system.assert(wrap != false, 'invokeBookingTicketCAPAPI returns True');
        Test.stopTest();
    }*/
    
    static TestMethod void invokeLoyaltyRawProfileAPITest() {
        String Body = '{"memberId":"0006142104","firstName":"W","lastName":"FYSH","mailingName":"MR W FYSH","salutation":"Dear Mr Fysh","title":"MR","dateOfJoining":"1996-05-13","gender":"MALE","dateOfBirth":"1996-11-07","email":"ibstestonlinesalesqueries@qantas.com.au","emailType":"BUSINESS","countryOfResidency":"AU","taxResidency":"AU","membershipStatus":"ACTIVE","preferredAddress":"HOME","pointBalance":11326,"company":{"name":"DO NOT CHANGE ANYTHING - PH JAMIE X62542","positionInCompany":"TEST PROFILE - DIGITAL DIRECT"},"phoneDetails":[{"type":"BUSINESS","number":"96912542","areaCode":"02","idd":"+61","status":"V"}],"addresses":[{"type":"HOME","lineOne":"10 BOURKE ROAD","suburb":"SYDNEY","postCode":"3000","state":"VIC","countryCode":"AU","status":"I"}],"preferences":{"ffsAirlines":[{"id":1,"number":"SK198253","airline":"CO"}],"leisureInterests":["BALL","CLMU","JAZZ"],"sportInterests":["BABL","BSBL","CYCL","SQSH","ARFB"]},"programDetails":[{"programCode":"QCASH","programName":"Qantas Cash","enrollmentDate":"2015-04-28","accountStatus":"ACTIVE","qcachSendMarketing":false,"qcashProgramIdentifier":"AU","activationFlag":"N"},{"programCode":"QC","programName":"Qantas Club","enrollmentDate":"2017-08-02","expiryDate":"2018-07-31","accountStatus":"PAYMENT_DUE","qcEnrolType":0},{"programCode":"QFF","programName":"Qantas Frequent Flyer","enrollmentDate":"1996-05-13","accountStatus":"ACTIVE","tierCode":"FFPL","tierFromDate":"2017-08-02"},{"programCode":"CL","programName":"Chairmans Lounge","enrollmentDate":"2017-08-02","expiryDate":"2019-08-31","accountStatus":"ACTIVE","clMemberType":"PRIME"}],"webLoginDisabled":false,"statusCredits":{"expiryDate":"2018-07-31","lifetime":430,"total":430,"loyaltyBonus":0},"tier":{"name":"Chairmans Lounge","code":"FFPL","startDate":"2017-08-02","effectiveTier":"CLQF"}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        //QCC_LoyaltyResponseWrapper wrap = QCC_InvokeCAPAPI.invokeLoyaltyAPI('0006142104');
        String wrap =  QCC_InvokeCAPAPI.invokeLoyaltyRawProfileAPI('0006142104');
        system.assert(wrap != Null, 'invokeLoyaltyProfileAPI returns Null');
        Test.stopTest();
    }

    static TestMethod void invokeLoyaltyRawContactTest(){
        String body = '{"addresses":[{"country":"AU","countryName":"Australia","lineOne":"TESTBusADDRESSLINE1","lineTwo":"TESTBusADDRESSLINE2","postCode":"2020","preferred":false,"state":"NSW","status":"VALID","suburb":"Mascot","type":"BUSINESS"},{"country":"AU","countryName":"Australia","lineOne":"TESTADDRESSLINE1","lineTwo":"TESTADDRESSLINE2","postCode":"2390","preferred":true,"state":"NSW","status":"VALID","suburb":"Ultimo","type":"HOME"}],"emails":[{"emailAddress":"qa.emailtesting@qantasloyalty.com","preferred":true,"status":"VALID","type":"HOME"}],"phones":[{"countryCode":61,"e164Format":"+61022366749","internationalFormat":"+61022366749","nationalFormat":"022366749","nationalNumber":22366749,"number":"2366749","preferred":false,"regionCodes":["AU","CC","CX"],"status":"VALID","type":"BUSINESS"},{"countryCode":61,"e164Format":"+6114371592","internationalFormat":"+6114371592","nationalFormat":"14371592","nationalNumber":14371592,"number":"14371592","preferred":true,"regionCodes":["AU","CC","CX"],"status":"VALID","type":"MOBILE"}],"preferredAddressType":"HOME","preferredEmailType":"HOME","preferredPhoneType":"MOBILE"}';

        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        //QCC_LoyaltyResponseWrapper wrap = QCC_InvokeCAPAPI.invokeLoyaltyAPI('0006142104');
        String wrap =  QCC_InvokeCAPAPI.invokeLoyaltyRawContact('2002918361');
        system.assert(wrap != Null, 'invokeLoyaltyRawContact returns Null');
        Test.stopTest();
    }

    static TestMethod void invokeQCCLoyaltyAPITest() {
        String Body = '{"memberId":"0006142104","firstName":"W","lastName":"FYSH","mailingName":"MR W FYSH","salutation":"Dear Mr Fysh","title":"MR","dateOfJoining":"1996-05-13","gender":"MALE","dateOfBirth":"1996-11-07","email":"ibstestonlinesalesqueries@qantas.com.au","emailType":"BUSINESS","countryOfResidency":"AU","taxResidency":"AU","membershipStatus":"ACTIVE","preferredAddress":"HOME","pointBalance":11326,"company":{"name":"DO NOT CHANGE ANYTHING - PH JAMIE X62542","positionInCompany":"TEST PROFILE - DIGITAL DIRECT"},"phoneDetails":[{"type":"BUSINESS","number":"96912542","areaCode":"02","idd":"+61","status":"V"}],"addresses":[{"type":"HOME","lineOne":"10 BOURKE ROAD","suburb":"SYDNEY","postCode":"3000","state":"VIC","countryCode":"AU","status":"I"}],"preferences":{"ffsAirlines":[{"id":1,"number":"SK198253","airline":"CO"}],"leisureInterests":["BALL","CLMU","JAZZ"],"sportInterests":["BABL","BSBL","CYCL","SQSH","ARFB"]},"programDetails":[{"programCode":"QCASH","programName":"Qantas Cash","enrollmentDate":"2015-04-28","accountStatus":"ACTIVE","qcachSendMarketing":false,"qcashProgramIdentifier":"AU","activationFlag":"N"},{"programCode":"QC","programName":"Qantas Club","enrollmentDate":"2017-08-02","expiryDate":"2018-07-31","accountStatus":"PAYMENT_DUE","qcEnrolType":0},{"programCode":"QFF","programName":"Qantas Frequent Flyer","enrollmentDate":"1996-05-13","accountStatus":"ACTIVE","tierCode":"FFPL","tierFromDate":"2017-08-02"},{"programCode":"CL","programName":"Chairmans Lounge","enrollmentDate":"2017-08-02","expiryDate":"2019-08-31","accountStatus":"ACTIVE","clMemberType":"PRIME"}],"webLoginDisabled":false,"statusCredits":{"expiryDate":"2018-07-31","lifetime":430,"total":430,"loyaltyBonus":0},"tier":{"name":"Chairmans Lounge","code":"FFPL","startDate":"2017-08-02","effectiveTier":"CLQF"}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        //QCC_LoyaltyResponseWrapper wrap = QCC_InvokeCAPAPI.invokeLoyaltyAPI('0006142104');
        QCC_LoyaltyResponseWrapper.QantasFrequentFlyerAccount wrap2 = QCC_InvokeCAPAPI.invokeQCCAccountAPI('0006142104');
        QCC_LoyaltyResponseWrapper.Programs wrap3 = QCC_InvokeCAPAPI.invokeQCCProgramAPI('0006142104');
        QCC_LoyaltyResponseWrapper.QantasFrequentFlyerTier wrap4 = QCC_InvokeCAPAPI.invokeQCCTierAPI('0006142104');
        system.assert(wrap2 != Null, 'invokeLoyaltyAccountAPI returns Null');
        system.assert(wrap3 != Null, 'invokeLoyaltyProgramAPI returns Null');
        system.assert(wrap4 != Null, 'invokeLoyaltyTierAPI returns Null');
        Test.stopTest();
    }

}