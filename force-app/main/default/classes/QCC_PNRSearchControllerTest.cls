/*----------------------------------------------------------------------------------------------------------------------
Author:         Praveen Sampath
Company:       Capgemini
Description:   Test Class for QCC_PNRSearchController
Inputs:
Test Class:    Not Required
************************************************************************************************
History
************************************************************************************************
03-AUG-2018    Praveen Sampath   InitialDesign
19-Apr-2023    Jamie Wang        add invokePNRSearchWithoutLastName test method
-----------------------------------------------------------------------------------------------------------------------*/
@isTest(seeAllData = false)
private class QCC_PNRSearchControllerTest {
    @testSetup
    static void createTestData(){ 
        
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        insert lsttrgStatus;
        

        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_PlaceHolderAcc','PlaceHolder Acc 1'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_PlaceHolderAccRectype','Placeholder'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_GenericConDescription','Testtstst jhgdsfkh lsdfh'));
        upsert lstConfigData;

        String recordtypeId = GenericUtils.getObjectRecordTypeId('Account', 'Placeholder');
        Account objAcc = new Account();
        objAcc.RecordtypeId = recordtypeId;
        objAcc.Name = 'PlaceHolder Acc 1';
        insert objAcc;

        Contact objCon = new Contact(LastName='Sample', FirstName='User', Business_Types__c='Agency', Job_Role__c='Agency Manager', Function__c='Advisory Services');
        objCon.Frequent_Flyer_Number__c = '12456787';
        objCon.Email = 'praveen@hotmail.com';
        objCon.Phone = '0426646801';
        insert objCon;

        String type = 'Complaint';
        String recordType = 'CCC Complaints';
        List<Contact> lstCon = new List<Contact>();
        lstCon.add(objCon);

        List<Case> cases = TestUtilityDataClassQantas.insertCases(lstCon, recordType, type, 'Qantas.com','Website Functionality','','');

        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        /*User userInfo = new User(LastName = 'User4', Alias = 'User', Email = 'sampleuser4@sample.com',
                           Username = 'sampleuser4username@sample.com', ProfileId = profMap.get('Qantas CC Operational Manager').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',Location__c='Hobart',
                           TimeZoneSidKey = 'Australia/Sydney'
                           );
        insert userInfo;*/
        EnableValidationRule__c enableVal = TestUtilityDataClassQantas.createEnableValidationRuleSettingQCC(userInfo.getUserID());
        insert enableVal;
    }
    
    static TestMethod void invokePNRSearchPositiveTest() {
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","currentPassengerQuantity":"2","lastUpdatedTimeStamp":"05/12/2017 04:28:00","passengers":[{"passengerId":"8956328947991887","passengerTattoo":"2","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"STEVE","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CC","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000017"},{"passengerId":"9018991125607359","passengerTattoo":"3","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"MARK","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CD","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000018"}]}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        String response = QCC_PNRSearchController.invokePNRSearch('99PRA', 'Sampath');
        system.assert(response != Null, 'No Response returned');
        Test.stopTest();
    }
    
    static TestMethod void invokePNRSearchExceptionTest() {
        String Body = 'null';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        Boolean isException = false;
        try{
            QCC_PNRSearchController.invokePNRSearch('99PRA', 'Sampath');
        }
        catch(Exception ex){
            isException = true;
        }
        system.assert(isException == true, 'Exception is not Triggered');
        Test.stopTest();
    }
    
    static TestMethod void invokeContactSearchFFPositiveTest() {
        QCC_PNRPassengerInfoWrapper.Passengers passengerWrap = new QCC_PNRPassengerInfoWrapper.Passengers();
        passengerWrap.passengerId ='12445';
        passengerWrap.firstName = 'Praveen Mehta';
        passengerWrap.lastName ='Sampath';
        passengerWrap.qantasFFNo ='9900990099';
        String passenger = Json.serialize(passengerWrap);
        String Body = '{"customers":[{"customer":{"qantasUniqueId":"710000000018","customerMatchScore":175,"name":{"firstName":"Praveen Mehta","middleName":"","lastName":"Sampath","prefix":"mr","salutation":"Dear Mr.","birthDate":"15/11/1990","genderCode":"M"},"loyaltyDetails":[{"schemeOperatorCode":"QF","loyaltyId":"9900990099","airlineTierCode":"FFBR","startDate":"01/01/1900"}],"phone":[{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"08","phoneLineNumber":"98124567","phoneExtension":""},{"typeCode":"H","phoneCountryCode":"61","phoneAreaCode":"","phoneLineNumber":"410678909","phoneExtension":""}],"email":[{"typeCode":"B","emailId":"mark.waugh@mailinator.com"},{"typeCode":"H","emailId":"mark.waugh1@mailinator.com"}],"address":[{"typeCode":"B","line1":"647","line2":"","line3":"london court","line4":"hay st","suburb":"perth","postCode":"6000","state":"wa","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"H","line1":"15","line2":"","line3":"","line4":"hobart rd","suburb":"south launceston","postCode":"7249","state":"tas","country":"AU","countryName":"AUSTRALIA"}],"travelDoc":[{"typeCode":"P","id":"AB123462","issueCountry":"AU"}],"others":{"companyName":"Unilever","comments":"Summary Comment Text18"}}}],"totalMatchedRecords":1}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        String response = QCC_PNRSearchController.invokeContactSearch(passenger, 'K5F5ZE', '');
        system.debug('The Mocked API response'+response);
      //  system.assert(response != Null, 'No Response returned');
        Test.stopTest();
    }

    static TestMethod void invokeContactIdSearchFFTest() {

        Case objCase = [Select Id from Case limit 1];
        QCC_PNRPassengerInfoWrapper.Passengers passengerWrap = new QCC_PNRPassengerInfoWrapper.Passengers();
        passengerWrap.passengerId ='12445';
        passengerWrap.firstName = 'Praveen';
        passengerWrap.lastName ='Sampath';
        passengerWrap.qantasFFNo ='9900990099';
        String passenger = Json.serialize(passengerWrap);
        String Body = '{"customers":[{"customer":{"qantasUniqueId":"710000000018","customerMatchScore":175,"name":{"firstName":"Praveen","middleName":"","lastName":"Sampath","prefix":"mr","salutation":"Dear Mr.","birthDate":"15/11/1990","genderCode":"M"},"loyaltyDetails":[{"schemeOperatorCode":"QF","loyaltyId":"9900990099","airlineTierCode":"FFBR","startDate":"01/01/1900"}],"phone":[{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"08","phoneLineNumber":"98124567","phoneExtension":""},{"typeCode":"H","phoneCountryCode":"61","phoneAreaCode":"","phoneLineNumber":"410678909","phoneExtension":""}],"email":[{"typeCode":"B","emailId":"mark.waugh@mailinator.com"},{"typeCode":"H","emailId":"mark.waugh1@mailinator.com"}],"address":[{"typeCode":"B","line1":"647","line2":"","line3":"london court","line4":"hay st","suburb":"perth","postCode":"6000","state":"wa","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"H","line1":"15","line2":"","line3":"","line4":"hobart rd","suburb":"south launceston","postCode":"7249","state":"tas","country":"AU","countryName":"AUSTRALIA"}],"travelDoc":[{"typeCode":"P","id":"AB123462","issueCountry":"AU"}],"others":{"companyName":"Unilever","comments":"Summary Comment Text18"}}}],"totalMatchedRecords":1}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        //String response = QCC_PNRSearchController.invokeContactSearch(passenger, 'K5F5ZE', objCase.Id);
        //system.assert(response != Null, 'No Response returned');
        Test.stopTest();
    }

     static TestMethod void invokeContactIdSearchNONFFTest() {

        Case objCase = [Select Id from Case limit 1];
        QCC_PNRPassengerInfoWrapper.Passengers passengerWrap = new QCC_PNRPassengerInfoWrapper.Passengers();
        passengerWrap.passengerId ='12445';
        passengerWrap.firstName = 'Praveen';
        passengerWrap.lastName ='Sampath';
        passengerWrap.qantasFFNo ='';
        String passenger = Json.serialize(passengerWrap);
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","lastUpdatedTimeStamp":"05/12/2017 04:28:00","contacts":{"address":[{"addressId":"1601601601600001","otherTattooReference":"11","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"B","line1":"322","line2":"level 20","line3":" Indooroopilly mall","line4":"moggill rd","postBoxName":null,"cityName":" Indooroopilly","stateName":"qld","countryName":"AU","postalCode":"4000","addressText":"TEST ADDR1","airlineCarrierAlphaCode":null,"passengerIds":["12445"]},{"addressId":"1601601601600002","otherTattooReference":"12","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"H","line1":"10","line2":null,"line3":null,"line4":"king st","postBoxName":null,"cityName":"perth","stateName":"tas","countryName":"AU","postalCode":"7300","addressText":"TEST ADDR2","airlineCarrierAlphaCode":null,"passengerIds":["12445"]},{"addressId":"1601601601600003","otherTattooReference":"14","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"B","line1":"647","line2":null,"line3":"london court","line4":"hay st","postBoxName":null,"cityName":"perth","stateName":"wa","countryName":"AU","postalCode":"6000","addressText":"TEST ADDR3","airlineCarrierAlphaCode":null,"passengerIds":["12445"]},{"addressId":"1601601601600004","otherTattooReference":"15","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"H","line1":"15","line2":null,"line3":null,"line4":"hobart rd","postBoxName":null,"cityName":"south launceston","stateName":"tas","countryName":"AU","postalCode":"7249","addressText":"TEST ADDR4","airlineCarrierAlphaCode":null,"passengerIds":["12445"]}],"email":[{"emailId":"1621621621620001","otherTattooReference":"44","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"B","emailText":"steve.waugh@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["12445"]},{"emailId":"1621621621620002","otherTattooReference":"45","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"H","emailText":"steve.waugh1@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"emailId":"1621621621620003","otherTattooReference":"46","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"B","emailText":"mark.waugh@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]},{"emailId":"1621621621620004","otherTattooReference":"47","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"H","emailText":"mark.waugh1@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]}],"phone":[{"phoneId":"1244444265675389","otherTattooReference":"7","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":"07","phoneNumber":"98765448","typeCode":"B","phoneText":"98765448 B","airlineCarrierAlphaCode":null,"passengerIds":["12445"]},{"phoneId":"1641641641640002","otherTattooReference":"8","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":null,"phoneNumber":"410467890","typeCode":"H","phoneText":"410467890 H","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"phoneId":"1641641641640003","otherTattooReference":"9","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":"08","phoneNumber":"98124567","typeCode":"B","phoneText":"98124567 B","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]},{"phoneId":"1641641641640004","otherTattooReference":"10","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":null,"phoneNumber":"410678909","typeCode":"H","phoneText":"410678909 H","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]}]}}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        String response = QCC_PNRSearchController.invokeContactSearch(passenger, 'K5F5ZE', objCase.Id);
        system.assert(response != Null, 'No Response returned');
        Test.stopTest();
    }

    static TestMethod void invokeAssignContacttoCasePositiveTest() {
        Case objCase = [Select Id from Case limit 1];
        Test.startTest();
        QCC_ContactWrapper conWrap = new QCC_ContactWrapper();
        conWrap.ffNumber = '1234566'; 
        conWrap.lastName = 'Sampath';
        conWrap.firstName = 'Praveen';
        //CRM-7179
        conWrap.Phone = '12345678';
        conWrap.Email = 'test@test.com';
        conWrap.ffTier = 'Gold';
        conWrap.capId = '123477888';
        conWrap.isFF = true;
        String req = Json.serialize(conWrap);
        String response = QCC_PNRSearchController.invokeAssignContacttoCase(req, objCase.Id);
        system.assert(response != Null, 'No Response returned');
        Test.stopTest();
    }

    static TestMethod void invokeAssignContacttoCaseExceptionTest() {
        Case objCase = [Select Id from Case limit 1];
        Test.startTest();
        QCC_ContactWrapper conWrap = new QCC_ContactWrapper();
        conWrap.ffNumber = null; 
        conWrap.lastName = '';
        conWrap.firstName = '';
        conWrap.ffTier = 'Gold';
        conWrap.capId = null;
        conWrap.isFF = true;
        String req = Json.serialize(conWrap);
        Boolean isException = false;
        try{
            String response = QCC_PNRSearchController.invokeAssignContacttoCase(req, objCase.Id);
        }catch(Exception ex){
            isException = true;
        }
        system.assert(isException == true, 'No Exception Occured');
        Test.stopTest();
    }

    static TestMethod void assigntoGenericContactPositiveTest() {
        Case objCase = [Select Id from Case limit 1];
        Test.startTest();
        String response = QCC_PNRSearchController.assigntoGenericContact(objCase.Id);
        system.assert(response != Null, 'No Response returned');
        Test.stopTest();
    }

     static TestMethod void assigntoGenericContactExceptionTest() {
        Test.startTest();
        Boolean isException = false;
        try{
            QCC_PNRSearchController.assigntoGenericContact(null);
        }catch(Exception ex){
            isException = true;
        }
        system.assert(isException == true, 'No Exception Occured');
        Test.stopTest();
    }
    
    static TestMethod void invokeContactSearchNONFFPositiveTest() {
        QCC_PNRPassengerInfoWrapper.Passengers passengerWrap = new QCC_PNRPassengerInfoWrapper.Passengers();
        passengerWrap.passengerId ='12445';
        passengerWrap.firstName = 'Praveen';
        passengerWrap.lastName ='Sampath';
        passengerWrap.qantasFFNo ='';
        String passenger = Json.serialize(passengerWrap);
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","lastUpdatedTimeStamp":"05/12/2017 04:28:00","contacts":{"address":[{"addressId":"1601601601600001","otherTattooReference":"11","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"B","line1":"322","line2":"level 20","line3":" Indooroopilly mall","line4":"moggill rd","postBoxName":null,"cityName":" Indooroopilly","stateName":"qld","countryName":"AU","postalCode":"4000","addressText":"TEST ADDR1","airlineCarrierAlphaCode":null,"passengerIds":["12445"]},{"addressId":"1601601601600002","otherTattooReference":"12","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"H","line1":"10","line2":null,"line3":null,"line4":"king st","postBoxName":null,"cityName":"perth","stateName":"tas","countryName":"AU","postalCode":"7300","addressText":"TEST ADDR2","airlineCarrierAlphaCode":null,"passengerIds":["12445"]},{"addressId":"1601601601600003","otherTattooReference":"14","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"B","line1":"647","line2":null,"line3":"london court","line4":"hay st","postBoxName":null,"cityName":"perth","stateName":"wa","countryName":"AU","postalCode":"6000","addressText":"TEST ADDR3","airlineCarrierAlphaCode":null,"passengerIds":["12445"]},{"addressId":"1601601601600004","otherTattooReference":"15","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"H","line1":"15","line2":null,"line3":null,"line4":"hobart rd","postBoxName":null,"cityName":"south launceston","stateName":"tas","countryName":"AU","postalCode":"7249","addressText":"TEST ADDR4","airlineCarrierAlphaCode":null,"passengerIds":["12445"]}],"email":[{"emailId":"1621621621620001","otherTattooReference":"44","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"B","emailText":"steve.waugh@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["12445"]},{"emailId":"1621621621620002","otherTattooReference":"45","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"H","emailText":"steve.waugh1@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"emailId":"1621621621620003","otherTattooReference":"46","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"B","emailText":"mark.waugh@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]},{"emailId":"1621621621620004","otherTattooReference":"47","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"H","emailText":"mark.waugh1@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]}],"phone":[{"phoneId":"1244444265675389","otherTattooReference":"7","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":"07","phoneNumber":"98765448","typeCode":"B","phoneText":"98765448 B","airlineCarrierAlphaCode":null,"passengerIds":["12445"]},{"phoneId":"1641641641640002","otherTattooReference":"8","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":null,"phoneNumber":"410467890","typeCode":"H","phoneText":"410467890 H","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"phoneId":"1641641641640003","otherTattooReference":"9","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":"08","phoneNumber":"98124567","typeCode":"B","phoneText":"98124567 B","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]},{"phoneId":"1641641641640004","otherTattooReference":"10","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":null,"phoneNumber":"410678909","typeCode":"H","phoneText":"410678909 H","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]}]}}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        String response = QCC_PNRSearchController.invokeContactSearch(passenger, 'K5F5ZE', '');
        system.assert(response != Null, 'No Response returned');
        Test.stopTest();
    }
    
    static TestMethod void invokeContactSearchExceptionTest() {
        String passenger = '';
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","lastUpdatedTimeStamp":"05/12/2017 04:28:00","contacts":{"address":[{"addressId":"1601601601600001","otherTattooReference":"11","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"B","line1":"322","line2":"level 20","line3":" Indooroopilly mall","line4":"moggill rd","postBoxName":null,"cityName":" Indooroopilly","stateName":"qld","countryName":"AU","postalCode":"4000","addressText":"TEST ADDR1","airlineCarrierAlphaCode":null,"passengerIds":["12445"]},{"addressId":"1601601601600002","otherTattooReference":"12","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"H","line1":"10","line2":null,"line3":null,"line4":"king st","postBoxName":null,"cityName":"perth","stateName":"tas","countryName":"AU","postalCode":"7300","addressText":"TEST ADDR2","airlineCarrierAlphaCode":null,"passengerIds":["12445"]},{"addressId":"1601601601600003","otherTattooReference":"14","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"B","line1":"647","line2":null,"line3":"london court","line4":"hay st","postBoxName":null,"cityName":"perth","stateName":"wa","countryName":"AU","postalCode":"6000","addressText":"TEST ADDR3","airlineCarrierAlphaCode":null,"passengerIds":["12445"]},{"addressId":"1601601601600004","otherTattooReference":"15","keywordCode":"DOCA","sourceCode":"SSR","infoTypeCode":"H","line1":"15","line2":null,"line3":null,"line4":"hobart rd","postBoxName":null,"cityName":"south launceston","stateName":"tas","countryName":"AU","postalCode":"7249","addressText":"TEST ADDR4","airlineCarrierAlphaCode":null,"passengerIds":["12445"]}],"email":[{"emailId":"1621621621620001","otherTattooReference":"44","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"B","emailText":"steve.waugh@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["12445"]},{"emailId":"1621621621620002","otherTattooReference":"45","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"H","emailText":"steve.waugh1@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"emailId":"1621621621620003","otherTattooReference":"46","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"B","emailText":"mark.waugh@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]},{"emailId":"1621621621620004","otherTattooReference":"47","keywordCode":null,"sourceCode":"SSR","infoTypeCode":"H","emailText":"mark.waugh1@mailinator.com","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]}],"phone":[{"phoneId":"1244444265675389","otherTattooReference":"7","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":"07","phoneNumber":"98765448","typeCode":"B","phoneText":"98765448 B","airlineCarrierAlphaCode":null,"passengerIds":["12445"]},{"phoneId":"1641641641640002","otherTattooReference":"8","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":null,"phoneNumber":"410467890","typeCode":"H","phoneText":"410467890 H","airlineCarrierAlphaCode":null,"passengerIds":["8956328947991887"]},{"phoneId":"1641641641640003","otherTattooReference":"9","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":"08","phoneNumber":"98124567","typeCode":"B","phoneText":"98124567 B","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]},{"phoneId":"1641641641640004","otherTattooReference":"10","keywordCode":null,"sourceCode":"AP","infoTypeCode":"3","countryCode":"61","areaCode":null,"phoneNumber":"410678909","typeCode":"H","phoneText":"410678909 H","airlineCarrierAlphaCode":null,"passengerIds":["9018991125607359"]}]}}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        Boolean isException = false;
        try{
            QCC_PNRSearchController.invokeContactSearch(passenger, 'K5F5ZE', '');
        } catch(Exception ex){
            isException = true;
        }
        system.assert(isException == true, 'Exception is not Triggered');
        Test.stopTest();
    }


    
    static TestMethod void fetchColumnTest() {
        Test.startTest();
        String column = QCC_PNRSearchController.fetchColumn('QCC_PNRSearch');
        system.assert(column != Null, 'No Column returned');
        Test.stopTest();
    }

    @isTest
    static void testinvokePNRSearchWithoutLastName() {
        //test data
        String pnr = 'K5F5ZE';
        String creationDate = '05/12/2017';
        Boolean archivalData = false;

        // Mock the external API call
        String Body = '{"booking":{"reloc":"K5F5ZE","travelPlanId":"219976558428426","bookingId":"219976558428426","creationDate":"05/12/2017","currentPassengerQuantity":"2","lastUpdatedTimeStamp":"05/12/2017 04:28:00","passengers":[{"passengerId":"8956328947991887","passengerTattoo":"2","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"STEVE","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CC","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000017"},{"passengerId":"9018991125607359","passengerTattoo":"3","parentPassengerId":null,"ageCategoryCode":"A","typeCode":null,"passengerWithInfantIndicator":"N","firstName":"MARK","lastName":"WAUGH","prefix":"MR","genderTypeCode":"M","birthDate":null,"age":null,"birthCity":null,"birthCountry":null,"uci":"2301CA35000037CD","staffTravelType":null,"additionalText":null,"smeId":null,"corpId":null,"cemCustId":null,"qantasFFNo":"0006142104","qantasUniqueId":"710000000018"}]}}';
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock( HttpCalloutMock.class,new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        Test.stopTest();

        try {
            String result = QCC_PNRSearchController.invokePNRSearchWithoutLastName(pnr, creationDate, archivalData);
            System.assertNotEquals(null, result, 'Expected passengers list should not be null');
        } catch (AuraHandledException ex) {
            System.debug('AuraHandledException: ' + ex.getMessage());
            System.assert(false, 'No exception should have been thrown for valid PNR and creationDate with archivalData');
        }
        
    }

    @isTest
    static void testinvokePNRSearchWithoutLastNameExceptionTest() {
        String Body = 'null';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        Boolean isException = false;
        try{
            QCC_PNRSearchController.invokePNRSearchWithoutLastName('99PRA', 'Sampath', false);
        }
        catch(Exception ex){
            isException = true;
        }
        system.assert(isException == true, 'Exception is not Triggered');
        Test.stopTest();
    }
}