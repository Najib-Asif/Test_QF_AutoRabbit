@isTest
private class QCC_EmailMsgLoungePassNonFFMBatchTest {

/* @testSetup
   static void createTestData(){
        // create Account
        // create Contact
        // create Case
        // create Recovery
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> listTriggerConfigs = new List<Trigger_Status__c>();
        listTriggerConfigs.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        listTriggerConfigs.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        listTriggerConfigs.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        listTriggerConfigs.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        for(Trigger_Status__c triggerStatus : listTriggerConfigs){
            triggerStatus.Active__c = false;
        }
        insert listTriggerConfigs;
        // Create Account
        List<Account> listAccountTest = TestUtilityDataClassQantas.getAccounts();
        // CRETAE contact
        List<Contact> listContactTest = TestUtilityDataClassQantas.getContacts(listAccountTest);
        
        listContactTest[0].Frequent_Flyer_Number__c = '34095545435';
        listContactTest[0].CAP_ID__c = '710000000018';

        update listContactTest[0];

        // create Case
        Id recTypeCCCComplaint = GenericUtils.getObjectRecordTypeId('Case', CustomSettingsUtilities.getConfigDataMap('Case QCC Complaint RecType'));

        List<Case> listCaseTest = TestUtilityDataClassQantas.getCases(listAccountTest);
        listCaseTest[0].ContactId = listContactTest[0].Id;
        listCaseTest[0].RecordTypeId = recTypeCCCComplaint;
        update listCaseTest;
        List<Recovery__c> listRecoveryTest = new List<Recovery__c>();
        // create Recovery
        for(Case caseObj: listCaseTest){
            Recovery__c newRe = new Recovery__c();
            newRe.Case_Number__c = caseObj.Id;
            newRe.Type__c = CustomSettingsUtilities.getConfigDataMap('Recovery IB Lounge Passes');
            newRe.Status__c = 'Awaiting Customer Response';
            listRecoveryTest.add(newRe);
        }
        insert listRecoveryTest;
        List<Qantas_API__c> listAPIConfig = TestUtilityDataClassQantas.createQantasAPI();
        insert listAPIConfig;
    } */

    /* static testMethod void testQCC_EmailMsgLoungePassNonFFMBatchableCAPId() {
        String Body = '{"customers":[{"customer":{"qantasUniqueId":"710000000018","customerMatchScore":175,"name":{"firstName":"MARK","middleName":"","lastName":"WAUGH","prefix":"mr","salutation":"Dear Mr.","birthDate":"15/11/1990","genderCode":"M"},"loyaltyDetails":[{"schemeOperatorCode":"QF","loyaltyId":"0006142104","airlineTierCode":"FFBR","startDate":"01/01/1900"}],"phone":[{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"08","phoneLineNumber":"98124567","phoneExtension":""},{"typeCode":"H","phoneCountryCode":"61","phoneAreaCode":"","phoneLineNumber":"410678909","phoneExtension":""}],"email":[{"typeCode":"B","emailId":"mark.waugh@mailinator.com"},{"typeCode":"H","emailId":"mark.waugh1@mailinator.com"}],"address":[{"typeCode":"B","line1":"647","line2":"","line3":"london court","line4":"hay st","suburb":"perth","postCode":"6000","state":"wa","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"H","line1":"15","line2":"","line3":"","line4":"hobart rd","suburb":"south launceston","postCode":"7249","state":"tas","country":"AU","countryName":"AUSTRALIA"}],"travelDoc":[{"typeCode":"P","id":"AB123462","issueCountry":"AU"}],"others":{"companyName":"Unilever","comments":"Summary Comment Text18"}}}],"totalMatchedRecords":1}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        List<Case> cases = [SELECT Id FROM Case Limit 1];
        Set<Id> setCaseRecType = CaseTriggerHelper.qccCaseRecordTypeIds();
        Set<Id> setCaseId = new Set<Id>();
        setCaseId.add(cases[0].id);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        //Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        
        QCC_EmailMsgLoungePassNonFFMBatchable emailMsgLoungePassNonFFMBatch = new QCC_EmailMsgLoungePassNonFFMBatchable(setCaseId, setCaseRecType);
        Database.executebatch(emailMsgLoungePassNonFFMBatch, 100);
        Test.stopTest();
        
    } */

  /*  static testMethod void testQCC_EmailMsgLoungePassNonFFMBatchableNonCAPId() {
        String Body = '{"customers":[{"customer":{"qantasUniqueId":"710000000018","customerMatchScore":175,"name":{"firstName":"MARK","middleName":"","lastName":"WAUGH","prefix":"mr","salutation":"Dear Mr.","birthDate":"15/11/1990","genderCode":"M"},"loyaltyDetails":[{"schemeOperatorCode":"QF","loyaltyId":"0006142104","airlineTierCode":"FFBR","startDate":"01/01/1900"}],"phone":[{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"08","phoneLineNumber":"98124567","phoneExtension":""},{"typeCode":"H","phoneCountryCode":"61","phoneAreaCode":"","phoneLineNumber":"410678909","phoneExtension":""}],"email":[{"typeCode":"B","emailId":"mark.waugh@mailinator.com"},{"typeCode":"H","emailId":"mark.waugh1@mailinator.com"}],"address":[{"typeCode":"B","line1":"647","line2":"","line3":"london court","line4":"hay st","suburb":"perth","postCode":"6000","state":"wa","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"H","line1":"15","line2":"","line3":"","line4":"hobart rd","suburb":"south launceston","postCode":"7249","state":"tas","country":"AU","countryName":"AUSTRALIA"}],"travelDoc":[{"typeCode":"P","id":"AB123462","issueCountry":"AU"}],"others":{"companyName":"Unilever","comments":"Summary Comment Text18"}}}],"totalMatchedRecords":1}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        List<Case> cases = [SELECT Id FROM Case Limit 1];

        Set<Id> setCaseRecType = CaseTriggerHelper.qccCaseRecordTypeIds();
        Set<Id> setCaseId = new Set<Id>();
        setCaseId.add(cases[0].id);


        List<Contact> contacts = [SELECT Id FROM Contact Limit 1];
        contacts[0].CAP_ID__c = '';
        update contacts;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        
        QCC_EmailMsgLoungePassNonFFMBatchable emailMsgLoungePassNonFFMBatch = new QCC_EmailMsgLoungePassNonFFMBatchable(setCaseId, setCaseRecType);
        Database.executebatch(emailMsgLoungePassNonFFMBatch, 100);
        Test.stopTest();
        
    } */

  /* static testMethod void testQCC_EmailMsgLoungePassNonFFMBatchableCloseBySydney() {
        String Body = '{"customers":[{"customer":{"qantasUniqueId":"710000000018","customerMatchScore":175,"name":{"firstName":"MARK","middleName":"","lastName":"WAUGH","prefix":"mr","salutation":"Dear Mr.","birthDate":"15/11/1990","genderCode":"M"},"loyaltyDetails":[{"schemeOperatorCode":"QF","loyaltyId":"0006142104","airlineTierCode":"FFBR","startDate":"01/01/1900"}],"phone":[{"typeCode":"B","phoneCountryCode":"61","phoneAreaCode":"08","phoneLineNumber":"98124567","phoneExtension":""},{"typeCode":"H","phoneCountryCode":"61","phoneAreaCode":"","phoneLineNumber":"410678909","phoneExtension":""}],"email":[{"typeCode":"B","emailId":"mark.waugh@mailinator.com"},{"typeCode":"H","emailId":"mark.waugh1@mailinator.com"}],"address":[{"typeCode":"B","line1":"647","line2":"","line3":"london court","line4":"hay st","suburb":"perth","postCode":"6000","state":"wa","country":"AU","countryName":"AUSTRALIA"},{"typeCode":"H","line1":"15","line2":"","line3":"","line4":"hobart rd","suburb":"south launceston","postCode":"7249","state":"tas","country":"AU","countryName":"AUSTRALIA"}],"travelDoc":[{"typeCode":"P","id":"AB123462","issueCountry":"AU"}],"others":{"companyName":"Unilever","comments":"Summary Comment Text18"}}}],"totalMatchedRecords":1}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        List<Case> cases = [SELECT Id FROM Case Limit 1];
        Id spnQueue = [SELECT SobjectType, Id, QueueId, Queue.DeveloperName FROM QueueSobject 
                           WHERE SobjectType ='Case' 
                           AND Queue.DeveloperName = 'QCC_Specific_Needs_Bounce_Back_Queue'].Id;
        system.debug('queueid' +spnQueue.id);
        for(Case objCase : cases){
            objCase.ClosedBylocation__c = 'Sydney';  
              objCase.Closed_By__c = UserInfo.getUserId();
              objCase.Closed_By__c = spnQueue;
        }

        update cases;

        Set<Id> setCaseRecType = CaseTriggerHelper.qccCaseRecordTypeIds();
        Set<Id> setCaseId = new Set<Id>();
        setCaseId.add(cases[0].id);

        List<Contact> contacts = [SELECT Id FROM Contact Limit 1];
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        
        QCC_EmailMsgLoungePassNonFFMBatchable emailMsgLoungePassNonFFMBatch = new QCC_EmailMsgLoungePassNonFFMBatchable(setCaseId, setCaseRecType);
        Database.executebatch(emailMsgLoungePassNonFFMBatch, 100);
        Test.stopTest();       
    } */
}