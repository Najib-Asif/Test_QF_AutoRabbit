/********
* Created By : Darwin Herbert Lubas| ACN | Developer 
* Purpose : test class for QCC_CaseHistoryTable Controller
* Purpose : Apex controler Class for QCC_CaseHistoryTable LWC
* REST API : No Rest API Needed

Modified Date   : 24/03/23 (DD/MM/YYYY)
Modified By     : Darwin Herbert Lubas
JIRA            : ADT-202
Version         : 1.1 -Initial Development | Darwin

Modified By : Venkata Suresh Kumar (TCS Team), 17-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method. Added Test.start and Test.Stop methods 
*/

@isTest
public with sharing class QCC_CaseHistoryTableControllerTest {
    @TestSetup
    static void createData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        
        List<Trigger_Status__c> onScreenCase = TestUtilityDataClassQantas.enableTriggers();
        List<Trigger_Status__c> statToUpdate = new List<Trigger_Status__c>();
        for(Trigger_Status__c triggerStat : onScreenCase){
            triggerStat.Active__c = false;
            statToUpdate.add(triggerStat);
        }
        update statToUpdate;
        
        Trigger_Status__c ts1 = new Trigger_Status__c();
        ts1.Name = 'QCC_SetNonFFContactOnCase';
        ts1.Active__c = false;
        insert ts1;
        
        //create a test account
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        insert accountRecord;
        
        //create a test contact
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Map<String, StaticResource> resourceMap = new Map<String, StaticResource>();
        for(StaticResource sr : [SELECT Id, Name, Body FROM StaticResource WHERE Name LIKE 'QCCTestData%']) {
            resourceMap.put(sr.Name, sr);
        }
        String contactJSON = resourceMap.get('QCCTestData_ADT_Contact').Body.toString();
        contactJSON = contactJSON.replaceAll('RecordTypeIdValue', contactRecordTypeId);
        List<sObject> contactRecord = (List<sObject>) JSON.deserialize(contactJSON, List<sObject>.class);
        insert contactRecord;
        
        /*List<Contact> contactList = new List<Contact>();
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        contactRecord.RecordTypeId = contactRecordTypeId;
        contactRecord.Frequent_Flyer_Number__c = '123456789';
        insert contactRecord;*/
        
        List<Case> caseRecordList = new List<Case>();
        List<PNR__c> pnrRecordList = new List<PNR__c>();
        
        //Create custom setting for case trigger
        List<Trigger_Status__c> customSettingList = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusCase', null, null, null, null);
        insert customSettingList;
        
        //create a test case
        String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CCC_Voice').getRecordTypeId();
        Case caseRecord = QCC_TestDataFactory.createCaseTestData(accountRecord.Id, contactRecord[0].Id);
        caseRecord.RecordTypeId = caseRecordTypeId;
        caseRecord.Subject = 'Test CCC Voice';
        caseRecord.Description = 'Test CCC Voice';
        caseRecord.Status = 'New';
        caseRecord.Booking_PNR__c = 'TEST13';
        caseRecordList.add(caseRecord);
        
        Case caseRecord2 = QCC_TestDataFactory.createCaseTestData(accountRecord.Id, contactRecord[0].Id);
        caseRecord2.RecordTypeId = caseRecordTypeId;
        caseRecord2.Subject = 'Test CCC Voice';
        caseRecord2.Description = 'Test CCC Voice';
        caseRecord2.Status = 'New';
        caseRecord2.Booking_PNR__c = 'TEST13';
        caseRecordList.add(caseRecord2);
        
        Case caseRecord3 = QCC_TestDataFactory.createCaseTestData(accountRecord.Id, contactRecord[0].Id);
        caseRecord3.RecordTypeId = caseRecordTypeId;
        caseRecord3.Subject = 'Test CCC Voice';
        caseRecord3.Description = 'Test CCC Voice';
        caseRecord3.Status = 'New';
        caseRecord3.Booking_PNR__c = 'TEST13';
        caseRecordList.add(caseRecord3);
        
        Case caseRecord4 = QCC_TestDataFactory.createCaseTestData(accountRecord.Id, contactRecord[0].Id);
        caseRecord4.RecordTypeId = caseRecordTypeId;
        caseRecord4.Subject = 'Test CCC Voice';
        caseRecord4.Description = 'Test CCC Voice';
        caseRecord4.Status = 'New';
        //caseRecord4.Booking_PNR__c = 'TEST13';
        caseRecordList.add(caseRecord4);
        
        Case caseRecord5 = new Case();
        caseRecord5.RecordTypeId = caseRecordTypeId;
        caseRecord5.Subject = 'Test CCC Voice 5';
        caseRecord5.Description = 'Test CCC Voice 5';
        caseRecord5.Status = 'New';
        caseRecord5.Frequent_Flyer_Number__c = '1002918361';
        caseRecordList.add(caseRecord5);
        insert caseRecordList;
        
        PNR__c pnr1 = new PNR__c();
        pnr1.case__c = caseRecord.id;
        pnr1.pnr__c = 'ADD123';
        pnrRecordList.add(pnr1);
        
        PNR__c pnr2 = new PNR__c();
        pnr2.case__c = caseRecord.id;
        pnr2.pnr__c = 'ADD456';
        pnrRecordList.add(pnr2);
        
        PNR__c pnr3 = new PNR__c();
        pnr3.case__c = caseRecord.id;
        pnr3.pnr__c = 'ADD123';
        pnrRecordList.add(pnr3);
        
        insert pnrRecordList;
        
        //Create CaseComment records
        List<CaseComment> commentRecords = new List <CaseComment>();
        CaseComment mComment = new CaseComment(
            CommentBody = 'Test Comment1 body',
            ParentId = caseRecord.Id
        );
        commentRecords.add(mComment);
        CaseComment mComment2 = new CaseComment(
            CommentBody = 'Test Comment2 body',
            ParentId = caseRecord2.Id
        );
        commentRecords.add(mComment2);
        
        CaseComment mComment3 = new CaseComment(
            CommentBody = 'Test Comment3 body',
            ParentId = caseRecord3.Id
        );
        commentRecords.add(mComment3);
        CaseComment mComment4 = new CaseComment(
            CommentBody = 'Test Comment4 body',
            ParentId = caseRecord4.Id
        );
        
        commentRecords.add(mComment4);
        CaseComment mComment5 = new CaseComment(
            CommentBody = 'Test Comment5 body',
            ParentId = caseRecord5.Id
        );
        
        commentRecords.add(mComment5);
        insert commentRecords;
        
        // Create a related Task record
        Task task = new Task(
            TECH_Case_Comment_Id__c = mComment4.Id,
            Subject = 'Test Task',
            CallDurationInSeconds=56656
            // Add any required fields for the Task object
        );
        insert task;
    }
    
    /***************************
    *   Purpose             : Test for getCaseCommentFromPNR method on QCC_CaseHistoryTableController class
    *   Parameters          : 
    *   Returns             : 
    * 
    *   Throws
    *   Expectations        : There should be CaseComment records to return when called the method getCaseCommentFromPNR
    */
    @isTest
    public static void getCaseCommentFromPNRTest(){
        Case testCase = [SELECT Id, Booking_PNR__c FROM Case WHERE Booking_PNR__c = 'TEST13' LIMIT 1];
        String pnrNumber = testCase.Booking_PNR__c;
        String caseId = testCase.Id;
        
        Test.startTest();
        // Call the method with test data
        //List<QCC_CaseHistoryTableController.PNRHistoryWrapper> pnrHistoryList = QCC_CaseHistoryTableController.retrieveCaseComments(pnrNumber, caseId, 200, 0);
        List<QCC_CaseHistoryTableController.PNRHistoryWrapper> emptyList = QCC_CaseHistoryTableController.retrieveCaseComments(pnrNumber, caseId, 10, 2100);
        List<QCC_CaseHistoryTableController.PNRHistoryWrapper> pnrHistoryList = QCC_CaseHistoryTableController.retrieveCaseComments(pnrNumber, caseId, 10, 0);
        Test.stopTest();
        System.assertEquals(0, emptyList.size(), 'PNR history list should be empty if offset is greater than 2000');
        System.assertNotEquals(0, pnrHistoryList.size(), 'PNR history list should not be empty');
        QCC_CaseHistoryTableController.PNRHistoryWrapper firstWrapper = pnrHistoryList[0];
        System.assertEquals(pnrNumber, firstWrapper.PNRNumber, 'PNR Number does not match expected value');
        
        // Example assertion for the first case comment history within the first wrapper
        // QCC_CaseHistoryTableController.CaseCommentHistory firstComment = firstWrapper.caseCommentHistoryList[0];
        //  System.assertEquals('Test Comment1 body', firstComment.CommentBody, 'Case Comment Body does not match expected value');
        
        
        // Validate the results
        /*System.assertNotEquals(null, pnrHistoryList);
        System.assert(pnrHistoryList.size() > 0, 'Expected non-empty list of PNRHistoryWrapper objects.');
        System.assert(pnrHistoryList[0].PNRNumber == pnrNumber, 'Expected PNR number to match.');
        System.assert(pnrHistoryList[0].caseCommentHistoryList.size() > 0, 'Expected non-empty list of CaseCommentHistory objects.');*/
    }
    
    /***************************
    *   Purpose             : Test for getCaseCommentFromContact method on QCC_CaseHistoryTableController class
    *   Parameters          : 
    *   Returns             : 
    * 
    *   Throws
    *   Expectations        : There should be CaseComment records to return when called the method getCaseCommentFromContact
    */
    @isTest
    public static void getCaseCommentFromContactTest(){
        List <Case> mCase =[SELECT Id, CaseNumber, Booking_PNR__c FROM Case];
        List <Case> caseData = QCC_CaseHistoryTableController.getCaseData(mCase[0].Id);
        Test.startTest();
        List<CaseComment> result = QCC_CaseHistoryTableController.getCaseCommentFromContact(caseData[0].ContactId);
        QCC_CaseHistoryTableController.retrieveCaseCommentsContact(caseData[0].ContactId,caseData[0].Id, 200, 0);
        Test.stopTest();
        System.assertEquals(4, result.size());
    }
    
    /***************************
    *   Purpose             : Test for getCaseCommentFromFFNumber method on QCC_CaseHistoryTableController class
    *   Parameters          : 
    *   Returns             : 
    * 
    *   Throws
    *   Expectations        : There should be CaseComment records to return when called the method getCaseCommentFromFFNumber
    */
    @isTest
    public static void getCaseCommentFromFFNumberTest(){
        List <Case> mCase = [SELECT Id, CaseNumber, Frequent_Flyer_Number__c FROM Case
                             WHERE Frequent_Flyer_Number__c <> null];
        List <Case> caseData = QCC_CaseHistoryTableController.getCaseData(mCase[0].Id);
        Test.startTest();
        List<CaseComment> result = QCC_CaseHistoryTableController.getCaseCommentFromFFNumber(caseData[0].Frequent_Flyer_Number__c);
        Test.stopTest();
        System.assertEquals(4, result.size());                   
    }
}