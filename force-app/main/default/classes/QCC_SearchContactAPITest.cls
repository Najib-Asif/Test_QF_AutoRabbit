/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   Test Class for QCC_SearchContactAPITest
Inputs:
Test Class:    Not Required
************************************************************************************************
History
************************************************************************************************
03-AUG-2018     Praveen Sampath     InitialDesign
17-APR-2023     Leslie Padilla      Split methods to cover scenario for Null Contact (searchContactPlaceholderPositive) and Non FF Contact (searchContactNONFFPositive)
-----------------------------------------------------------------------------------------------------------------------*/
@isTest(seeAllData = false)
private class QCC_SearchContactAPITest {
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
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC Non FF Contact Duplicate Rule Name','QCC_Non_FF_Contact_Duplicate_Rule'));
        upsert lstConfigData;

        String recordtypeId = GenericUtils.getObjectRecordTypeId('Account', 'Placeholder');
        Account objAcc = new Account();
        objAcc.RecordtypeId = recordtypeId;
        objAcc.Name = 'PlaceHolder Acc 1';
        insert objAcc;
    }

    
    static TestMethod void searchContactFFPositive(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        QCC_ContactWrapper conWrap = new QCC_ContactWrapper();
        conWrap.ffNumber = '1234566'; 
        conWrap.lastName = 'Sampath';
        conWrap.firstName = 'Praveen';
        conWrap.ffTier = 'Gold';
        conWrap.capId = '123477888';
        conWrap.isFF = true;
        String msg = Json.serialize(conWrap);
        
        req.requestURI = '/services/apexrest/QCCSearchContact';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(msg);
        
        RestContext.request = req;
        RestContext.response= res;

        
        Test.startTest();
            QCC_SearchContactAPI.searchContact();
            system.assert(res.statusCode == 200, 'Response code is not 200');
        Test.StopTest();   
    }

    //GRAPHITE-932: Scenario to cover when contact is already existing, then link the case to the existing "Individual Contact"
    static TestMethod void searchContactFFExisting(){
        //Create Individual Contact record
        Integer ffNumber = 1234566;
        Contact b2cContactRecord = QCC_TestDataFactory.createContactTestData(ffNumber, null);
        b2cContactRecord.RecordTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));
        b2cContactRecord.Frequent_Flyer_Number__c = String.valueOf(ffNumber);
        b2cContactRecord.Frequent_Flyer_Tier__c = 'Platinum One';
        b2cContactRecord.QCC_TECH_RecordType__c = 'Individual Contact';
        insert b2cContactRecord;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        QCC_ContactWrapper conWrap = new QCC_ContactWrapper();
        conWrap.ffNumber = '1234566'; 
        conWrap.lastName = 'Sampath';
        conWrap.firstName = 'Praveen';
        conWrap.ffTier = 'Gold';
        conWrap.capId = '123477888';
        conWrap.isFF = true;
        String msg = Json.serialize(conWrap);
        
        req.requestURI = '/services/apexrest/QCCSearchContact';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(msg);
        
        RestContext.request = req;
        RestContext.response= res;

        
        Test.startTest();
            QCC_SearchContactAPI.searchContact();
            //system.assert(res.statusCode != 200, 'Response code is not 200');
        Test.StopTest();   
    }
    
    static TestMethod void searchContactPlaceholderPositive(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        QCC_ContactWrapper conWrap = new QCC_ContactWrapper();
        conWrap.ffNumber = ''; 
        conWrap.lastName = '';
        conWrap.firstName = '';
        conWrap.email = '';
        conWrap.phone = '';
        conWrap.ffTier = '';
        conWrap.capId = '';
        conWrap.isFF = false;
        String msg = Json.serialize(conWrap);
        
        req.requestURI = '/services/apexrest/QCCSearchContact';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(msg);
        
        RestContext.request = req;
        RestContext.response= res;

        
        Test.startTest();
            QCC_SearchContactAPI.searchContact();
            system.assert(res.statusCode == 200, 'Response code is not 200');
        Test.StopTest();   
    }
    
    static TestMethod void searchContactNONFFPositive(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        QCC_ContactWrapper conWrap = new QCC_ContactWrapper();
        conWrap.ffNumber = ''; 
        conWrap.lastName = 'test';
        conWrap.firstName = 'test';
        conWrap.email = 'test@example.com';
        conWrap.phone = '0411234567';
        conWrap.ffTier = '';
        conWrap.capId = '';
        conWrap.isFF = false;
        String msg = Json.serialize(conWrap);
        
        req.requestURI = '/services/apexrest/QCCSearchContact';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(msg);
        
        RestContext.request = req;
        RestContext.response= res;

        
        Test.startTest();
            QCC_SearchContactAPI.searchContact();
            system.assert(res.statusCode == 200, 'Response code is not 200');
        Test.StopTest();   
    }

    static TestMethod void searchContactException(){
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        String msg = 'hello';
        
        req.requestURI = '/services/apexrest/QCCSearchContact';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(msg);
        
        RestContext.request = req;
        RestContext.response= res;

        
        Test.startTest();
            QCC_SearchContactAPI.searchContact();
            system.assert(res.statusCode == 400, 'Response code is not 200');
        Test.StopTest();   
    }

}