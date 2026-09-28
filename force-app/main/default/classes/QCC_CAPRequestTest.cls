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
private class QCC_CAPRequestTest {
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
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_DisplayBookingController System','CAPCRE_CC'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_DisplayBookingController Count','10'));
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

    static TestMethod void createReqbodyForCAPDetailTest() {
        Contact objCon = [Select Id, LastName, FirstName, CAP_ID__c, Frequent_Flyer_Number__c from Contact limit 1];
        Test.startTest();
        QCC_CAPRequest.createReqbodyForCAPDetail(objCon);
        Test.stopTest();
    }
    
    static TestMethod void createBodyForBookingTest() {
        Contact objCon = [Select Id, LastName, FirstName, CAP_ID__c, Frequent_Flyer_Number__c from Contact limit 1];
        Test.startTest();
        QCC_CAPRequest.createBodyForBooking(objCon);
        Test.stopTest();
    }
    static TestMethod void createBodyForBookingFFTest() {
        Contact objCon = [Select Id, LastName, FirstName, CAP_ID__c, Frequent_Flyer_Number__c from Contact limit 1];
        Test.startTest();
        objCon.Frequent_Flyer_Number__c ='1234';
        objCon.CAP_ID__c = null;
        QCC_CAPRequest.createReqbodyForCAPDetail(objCon);
        Test.stopTest();
    }
    static TestMethod void createReqbodyForCAPDetailFFTest() {
        Contact objCon = [Select Id, LastName, FirstName, CAP_ID__c, Frequent_Flyer_Number__c from Contact limit 1];
        Test.startTest();
        objCon.Frequent_Flyer_Number__c ='1234';
        objCon.CAP_ID__c = null;
        QCC_CAPRequest.createBodyForBooking(objCon);
        Test.stopTest();
    }
    
}