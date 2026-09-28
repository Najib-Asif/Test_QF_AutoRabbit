/*----------------------------------------------------------------------------------------------------------------------
Author:        Benazir Amir/Praveen Sampath
Company:       Capgemini
Description:   Test Class for AssetTrigger Helper
Inputs:
Test Class:    Not Required
************************************************************************************************
History
************************************************************************************************
31-Jan-2018    Praveen Sampath   InitialDesign
-----------------------------------------------------------------------------------------------------------------------*/
@isTest(seeAllData = false)
private class QCC_CAP_DetailControllerTest {
    
    @testSetup
    static void createTestData(){
        //Enable Account, Contact,Case Triggers
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        insert lsttrgStatus;

        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;

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
    }

    static TestMethod void fetchAddressTest() {
        Contact objCon = [select Id from Contact];
        String Body = '{"customers":[{"customer":{"qantasUniqueId":"710000000018","customerMatchScore":175,"name":{"firstName":"MARK","middleName":"","lastName":"WAUGH","prefix":"mr","salutation":"Dear Mr.","birthDate":"15/11/1990","genderCode":"M"},"loyaltyDetails":[{"schemeOperatorCode":"QF","loyaltyId":"0006142104","airlineTierCode":"FFBR","startDate":"01/01/1900"}],"phone":[{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"08","phoneLineNumber":"98124567","phoneExtension":""},{"typeCode":"H","phoneCountryCode":"61","phoneAreaCode":"","phoneLineNumber":"410678909","phoneExtension":""}],"email":[{"typeCode":"B","emailId":"mark.waugh@mailinator.com"},{"typeCode":"H","emailId":"mark.waugh1@mailinator.com"}],"address":[{"typeCode":"B","line1":"647","line2":"","line3":"london court","line4":"hay st","suburb":"perth","postCode":"6000","state":"wa","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"H","line1":"15","line2":"","line3":"","line4":"hobart rd","suburb":"south launceston","postCode":"7249","state":"tas","country":"AU","countryName":"AUSTRALIA"}],"travelDoc":[{"typeCode":"P","id":"AB123462","issueCountry":"AU"}],"others":{"companyName":"Unilever","comments":"Summary Comment Text18"}}}],"totalMatchedRecords":1}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        List<QCC_CAP_DetailController.DisplayAddressWrapper> lstDisWrap = QCC_CAP_DetailController.fetchAddress(objCon.Id);
        system.assert(lstDisWrap != null, 'Addres component is not diplayed');
        Test.stopTest();
    }
    
    static TestMethod void fetchMultipleAddressTest() {
        Contact objCon = [select Id from Contact];
        String Body = '{"customers":[{"customer":{"qantasUniqueId":"710000000017","customerMatchScore":100,"name":{"firstName":"GOLD","middleName":"","lastName":"FREQUENTFLYER","prefix":"Ms.","salutation":"Dear Ms.","birthDate":"10/10/1984","genderCode":"F"},"loyaltyDetails":[{"schemeOperatorCode":"QF","loyaltyId":"0006142209","airlineTierCode":"FFGD","startDate":"01/01/1900"}],"phone":[{"typeCode":"H","phoneCountryCode":"61","phoneAreaCode":"02","phoneLineNumber":"99789034","phoneExtension":""},{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"02","phoneLineNumber":"99545678","phoneExtension":""}],"email":[{"typeCode":"H","emailId":"gold.frequentflyer1@mailinator.com"},{"typeCode":"B","emailId":"gold.frequentflyer2@mailinator.com"}],"address":[{"typeCode":"H","line1":"15","line2":"","line3":"","line4":"hassall st","suburb":"westmead","postCode":"2145","state":"nsw","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"B","line1":"55","line2":"","line3":"bellavue","line4":"good st","suburb":"westmead","postCode":"2145","state":"nsw","country":"AU","countryName":"AUSTRALIA"}],"travelDoc":[{"typeCode":"P","id":"AB123469","issueCountry":"AU"}],"others":{"companyName":"BHP Mining","comments":"Summary Comment Text25"}}},{"customer":{"qantasUniqueId":"700000000037","customerMatchScore":75,"loyaltyDetails":[{"schemeOperatorCode":"QF","loyaltyId":"0006142209","airlineTierCode":"FFGD","startDate":"01/01/1900"}],"email":[{"typeCode":"","emailId":"HARI.SRINIVASAN@QANTAS.COM.AU"}],"address":[{"typeCode":"","line1":"123 BOTANY STREET","line2":"LEVEL 7","line3":"","line4":"","suburb":"SYDNEY","postCode":"2020","state":"NSW","country":"AU","countryName":"AUSTRALIA"}],"others":{"companyName":"BHP Mining","comments":""}}}],"totalMatchedRecords":2}'; 
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        List<QCC_CAP_DetailController.DisplayAddressWrapper> lstDisWrap = QCC_CAP_DetailController.fetchAddress(objCon.Id);
        system.assert(lstDisWrap != null, 'Addres component is not diplayed');
        Test.stopTest();
    }

    static TestMethod void fetchAddressExceptionTest() {
        Contact objCon = [select Id from Contact];
        String Body = '{nono}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        List<QCC_CAP_DetailController.DisplayAddressWrapper> lstDisWrap = QCC_CAP_DetailController.fetchAddress(objCon.Id);
        system.assert(lstDisWrap == null, 'Addres component is  diplayed');
        Test.stopTest();
    }

    static TestMethod void updateSelectedTest() {
        Contact objCon = [select Id from Contact];
        String Body = '{"customers":[{"customer":{"qantasUniqueId":"710000000018","customerMatchScore":175,"name":{"firstName":"MARK","middleName":"","lastName":"WAUGH","prefix":"mr","salutation":"Dear Mr.","birthDate":"15/11/1990","genderCode":"M"},"loyaltyDetails":[{"schemeOperatorCode":"QF","loyaltyId":"0006142104","airlineTierCode":"FFBR","startDate":"01/01/1900"}],"phone":[{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"08","phoneLineNumber":"98124567","phoneExtension":""},{"typeCode":"H","phoneCountryCode":"61","phoneAreaCode":"","phoneLineNumber":"410678909","phoneExtension":""}],"email":[{"typeCode":"B","emailId":"mark.waugh@mailinator.com"},{"typeCode":"H","emailId":"mark.waugh1@mailinator.com"}],"address":[{"typeCode":"B","line1":"647","line2":"","line3":"london court","line4":"hay st","suburb":"perth","postCode":"6000","state":"wa","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"H","line1":"15","line2":"","line3":"","line4":"hobart rd","suburb":"south launceston","postCode":"7249","state":"tas","country":"AU","countryName":"AUSTRALIA"}],"travelDoc":[{"typeCode":"P","id":"AB123462","issueCountry":"AU"}],"others":{"companyName":"Unilever","comments":"Summary Comment Text18"}}}],"totalMatchedRecords":1}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        List<QCC_CAP_DetailController.DisplayAddressWrapper> lstDisWrap = QCC_CAP_DetailController.fetchAddress(objCon.Id);
        system.assert(lstDisWrap != null, 'Addres component is not diplayed');
        string allstring =  JSON.serialize(lstDisWrap);
        lstDisWrap = QCC_CAP_DetailController.updateSelected(objCon.Id, allstring);
        system.assert(lstDisWrap != null, 'Addres component is not diplayed');

        Test.stopTest();
    }

    static TestMethod void updateSelectedExceptionTest() {
        Contact objCon = [select Id from Contact];
        String Body = '{"customers":[{"customer":{"qantasUniqueId":"710000000018","customerMatchScore":175,"name":{"firstName":"MARK","middleName":"","lastName":"WAUGH","prefix":"mr","salutation":"Dear Mr.","birthDate":"15/11/1990","genderCode":"M"},"loyaltyDetails":[{"schemeOperatorCode":"QF","loyaltyId":"0006142104","airlineTierCode":"FFBR","startDate":"01/01/1900"}],"phone":[{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"08","phoneLineNumber":"98124567","phoneExtension":""},{"typeCode":"H","phoneCountryCode":"61","phoneAreaCode":"","phoneLineNumber":"410678909","phoneExtension":""}],"email":[{"typeCode":"B","emailId":"mark.waugh@mailinator.com"},{"typeCode":"H","emailId":"mark.waugh1@mailinator.com"}],"address":[{"typeCode":"B","line1":"647","line2":"","line3":"london court","line4":"hay st","suburb":"perth","postCode":"6000","state":"wa","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"H","line1":"15","line2":"","line3":"","line4":"hobart rd","suburb":"south launceston","postCode":"7249","state":"tas","country":"AU","countryName":"AUSTRALIA"}],"travelDoc":[{"typeCode":"P","id":"AB123462","issueCountry":"AU"}],"others":{"companyName":"Unilever","comments":"Summary Comment Text18"}}}],"totalMatchedRecords":1}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        List<QCC_CAP_DetailController.DisplayAddressWrapper> lstDisWrap = QCC_CAP_DetailController.fetchAddress(objCon.Id);
        system.assert(lstDisWrap != null, 'Addres component is not diplayed');
        string allstring =  'hi';
        lstDisWrap = QCC_CAP_DetailController.updateSelected(objCon.Id, allstring);
        system.assert(lstDisWrap == null, 'Addres component is diplayed');

        Test.stopTest();
    }
    
}