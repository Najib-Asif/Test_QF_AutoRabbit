/*********************************************************************************
Name         : QCC_CaseStreamBatchTest
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 4 February 2020
Usages       : This will handle the test class and code coverage of
QCC_CaseStreamBatch APEX class

Modified By : Venkata Suresh Kumar (TCS Team), 17-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method. 
*********************************************************************************/
@isTest
public class QCC_CaseStreamBatchTest {
    @testSetup
    static void createData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        
        //Create test data for Account object
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        insert accountRecord;
        
        //Create test data for Contact object
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        contactRecord.RecordTypeId = contactRecordTypeId;
        contactRecord.Frequent_Flyer_Number__c = '5395838';
        insert contactRecord;
        
        //Create test data for Qantas API object
        List<Qantas_API__c> qantasAPIRecords = QCC_TestDataFactory.createQantasAPITestDataList();
        insert qantasAPIRecords;
        
        //Create test data for Trigger_Status__c
        List<Trigger_Status__c> customSettingList1 = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusCase', null, null, null, null);
        insert customSettingList1;
        
        List<Trigger_Status__c> customSettingList2 = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusEmailMessage', null, null, null, null);
        insert customSettingList2;
        
        //Create test data for Case object
        Case caseRecord = QCC_TestDataFactory.createCaseTestData(accountRecord.Id, contactRecord.Id);
        caseRecord.Type = '5,000 Status Credits';
        insert caseRecord;
        
        //Create test data for Task object
        Task taskRecord = QCC_TestDataFactory.createTaskTestData(contactRecord.Id);
        taskRecord.WhatId = caseRecord.Id;
        taskRecord.TaskSubtype = 'Call';
        insert taskRecord;
        
        //Create test data for EmailMessage object
        EmailMessage emailMessageRecord = QCC_TestDataFactory.createEmailMessageRecord(caseRecord.Id);
        insert emailMessageRecord;
    }
    
    static testMethod void test1(){
        Test.startTest();
        
        List<Id> caseIds = new List<Id>();
        List<Id> autoClosedCaseIds = new List<Id>();
        for(Case caseRecord : [SELECT Id FROM Case LIMIT 5]) {
            caseIds.add(caseRecord.Id);
        }
        QCC_SOQL_Setting__mdt caseStream001 = QCC_UtilityHelper.getSOQLSettingByDeveloperName('Case_Stream_001');
        
        //Set mock response
        String responseBody = '{}';
        Map<String, String> responseHeaderMap = new Map<String, String>();
        responseHeaderMap.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', responseBody, responseHeaderMap));
        
        Database.executeBatch(new QCC_CaseStreamBatch(caseStream001.Query_String__c, caseIds, autoClosedCaseIds), 1);
        
        Test.stopTest();
    }
    
    static testMethod void test2(){
        Test.startTest();
        
        List<Id> caseIds = new List<Id>();
        List<Id> autoClosedCaseIds = new List<Id>();
        for(Case caseRecord : [SELECT Id FROM Case LIMIT 5]) {
            caseIds.add(caseRecord.Id);
            autoClosedCaseIds.add(caseRecord.Id);
        }
        QCC_SOQL_Setting__mdt caseStream001 = QCC_UtilityHelper.getSOQLSettingByDeveloperName('Case_Stream_001');
        
        //Set mock response
        String responseBody = '{}';
        Map<String, String> responseHeaderMap = new Map<String, String>();
        responseHeaderMap.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', responseBody, responseHeaderMap));
        
        Database.executeBatch(new QCC_CaseStreamBatch(caseStream001.Query_String__c, caseIds, autoClosedCaseIds), 1);
        
        Test.stopTest();
    }
}