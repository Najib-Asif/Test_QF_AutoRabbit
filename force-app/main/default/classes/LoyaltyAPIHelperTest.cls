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
private class LoyaltyAPIHelperTest {
    
    @testSetup
    static void createTestData(){ 
        Id recoveryRTId = SObjectType.Recovery__c.getRecordTypeInfosByDeveloperName().get('Other_Recovery').getRecordTypeId();
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        insert lsttrgStatus;

        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        //TestUtilityDataClassQantas.insertQantasConfigData();

        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusApproved','Approved'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusFinalised','Finalised'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusFinalisation Declined','Finalisation Declined'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryType','Qantas Points'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('SubmitForFinalisation','Submit For Finalisation'));
        
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
        String type = 'Compliment';
        List<Case> lstCase = TestUtilityDataClassQantas.insertCases(lstContact, recordType, type, 'Qantas.com','','','');
        system.assert(lstCase.size()>0, 'Case List is Zero');
        system.assert(lstCase[0].Id != Null, 'Case is not inserted');

        //Create Recovery
        List<Recovery__c> lstRecovery = TestUtilityDataClassQantas.insertRecoverieswithRecType(lstCase, recoveryRTId, 'New', 'Qantas Points');
        system.assert(lstRecovery.size()>0, 'Recovery List is Zero');
        system.assert(lstRecovery[0].Id != Null, 'Recovery is not inserted');
    }
    
    static TestMethod void invokeLoyaltyAPIPostitiveTest() {
        Recovery__c objRecovery = [select Id, Case_Number__c, CaseNumber__c from Recovery__c where RecordType.DeveloperName='Other_Recovery' limit 1];
        Case objCas = [Select id, status, ownerId from case where Id =: objRecovery.Case_Number__c];
        system.assert(objCas.status != 'Closed', 'Case is Closed');
        system.debug('CaseEEEEEEEEEE'+objCas);

        String Body = '{ "success": true, "message": "Point Accrual information successfully updated", "member": {'+
                      '"memberid": 1900007871, "pointsbalance": 2 }, "othermemberdetails": { "emailid": "kevinliu@qantas.com.au"'+
                      '}, "reference": { "identifier": 787987122 }, "outcome": { "status": "SUCCESS", "reason": 0, "reasoncode": 0'+
                      '}}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        Test.startTest();
        LoyaltyAPIHelper.invokeLoyaltyAPI('1234576', 10, 'Sampath', objRecovery.CaseNumber__c, objRecovery.Id );
        Test.stopTest();
        Recovery__c newRecovery = [select Id, Status__c from Recovery__c where RecordType.DeveloperName='Other_Recovery' and Id =: objRecovery.Id];
        system.debug('newRecovery.Status__c$$$$$$$$$$'+newRecovery.Status__c);
        //system.assert(newRecovery.Status__c == 'Finalisation Declined', 'Recovery Status is not Updates as Finalized Declined');
    }

    static TestMethod void invokeLoyaltyAPINegativeTest() {
        Recovery__c objRecovery = [select Id, Case_Number__c, CaseNumber__c from Recovery__c where RecordType.DeveloperName='Other_Recovery' limit 1];
        objRecovery.Status__c = 'New';
        update objRecovery;

        String Body = '{ "success": false, "message": "Invalid request", "details": { "reason": "Duplicate Request - entry already exists", "reasoncode": 8025 }}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(400, 'Bad Request', Body, mapHeader));
        
        Test.startTest();
        //LoyaltyAPIHelper.invokeLoyaltyAPI('1234576', 10, 'Sampath', objRecovery.CaseNumber__c, objRecovery.Id );
        LoyaltyAPIHelper.invokeLoyaltyAPI(null, 10, 'Sampath', objRecovery.CaseNumber__c, objRecovery.Id );
        Test.stopTest();
        Recovery__c newRecovery = [select Id, Status__c from Recovery__c where RecordType.DeveloperName='Other_Recovery' and Id =: objRecovery.Id];
        system.debug('newRecovery.Status__c$$$$$$$$$$'+newRecovery.Status__c);
        system.assert(newRecovery.Status__c == 'Further Action Required', 'Recovery Status is not Updated as Exception');
    }

    static TestMethod void invokeLoyaltyAPIExceptionTest() {
        Recovery__c objRecovery = [select Id, Case_Number__c, CaseNumber__c from Recovery__c where RecordType.DeveloperName='Other_Recovery' limit 1];
        objRecovery.Status__c = 'New';
        update objRecovery;

        String Body = '{ "success": false, "message": "Invalid request", "details": { "reason": "Duplicate Request - entry already exists", "reasoncode": 8025 }}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(400, 'Bad Request', Body, mapHeader));
        
        Test.startTest();
        LoyaltyAPIHelper.invokeLoyaltyAPI('1234576', 10, 'Sampath', objRecovery.CaseNumber__c, 'abc' );
        Test.stopTest();
        Recovery__c newRecovery = [select Id, Status__c from Recovery__c where RecordType.DeveloperName='Other_Recovery' and Id =: objRecovery.Id];
        system.debug('newRecovery.Status__c$$$$$$$$$$'+newRecovery.Status__c);
        system.assert(newRecovery.Status__c == 'New', 'Recovery Status is not Updates as Open');
        
    }
    
}