/*********************************************************************************
Name         : QCC_QantasHostLookUpContactBatchTest
Created By   : Lora Mae S. Dapulang
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 11 November 2019
Usages       : This class is used for the code coverage of the apex class below:
- QCC_QantasHostLookUpContactBatch

Modified By : Venkata Suresh Kumar (TCS Team), 19-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method.
*********************************************************************************/
@isTest
public class QCC_QantasHostLookUpContactBatchTest {
    
    @testSetup
    static void setupTestData(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        //Create test data for Account object
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        insert accountRecord;
        
        //Create test data for Contact object
        List<Contact> contactList = new List<Contact>();
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        
        Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        contactRecord.RecordTypeId = contactRecordTypeId;
        contactRecord.Frequent_Flyer_Number__c = '12345';
        contactList.add(contactRecord);
        
        Contact contactRecord2 = QCC_TestDataFactory.createContactTestData(2, accountRecord.Id);
        contactRecord2.RecordTypeId = contactRecordTypeId;
        contactRecord2.Frequent_Flyer_Number__c = '67890';
        contactList.add(contactRecord2);
        
        Contact contactRecord3 = QCC_TestDataFactory.createContactTestData(3, accountRecord.Id);
        contactRecord3.RecordTypeId = contactRecordTypeId;
        contactRecord3.Frequent_Flyer_Number__c = null;
        contactList.add(contactRecord3);        
        insert contactList;
        
        //Set Custom Settings for Record Types
        List<QantasConfigData__c> customSettingRecordTypeLists = QCC_TestDataFactory.createRecordTypeConfigData();
        insert customSettingRecordTypeLists;  
        
        //Create test data for Qantas API object
        List<Qantas_API__c> qantasAPIRecords = QCC_TestDataFactory.createQantasAPITestDataList();
        insert qantasAPIRecords;
        
        //Set Custom Settings for Trigger_Status__c Custom settings
        List<Trigger_Status__c> customSettingTriggerStatusLists = QCC_TestDataFactory.createTriggerStatusData();
        insert customSettingTriggerStatusLists;
        
        //Create test data for Airport Code to be used in QHost record creation
        Airport_Code__c airportCodeRecord = QCC_TestDataFactory.createAirportCodeTestData();
        insert airportCodeRecord;
        
        //Create test data for Qantas Host
        List<QCC_First_Host__c> qantasHostList = new List<QCC_First_Host__c>();
        
        //Qantas Host with Contact
        QCC_First_Host__c qHostRecord = QCC_TestDataFactory.createFirstHostTestData(contactRecord.Id, airportCodeRecord.Id);        
        qHostRecord.QCC_Frequent_Flyer_Number__c = contactRecord.Frequent_Flyer_Number__c;
        qHostRecord.QCC_Contact_Lastname__c = contactRecord.LastName;
        qHostRecord.QCC_First_Host_First_Name__c = contactRecord.FirstName;
        qantasHostList.add(qHostRecord);
        
        //Qantas Host without Contact
        QCC_First_Host__c qHostRecord2 = QCC_TestDataFactory.createFirstHostTestData(contactRecord2.Id, airportCodeRecord.Id);       
        qHostRecord2.QCC_Frequent_Flyer_Number__c = contactRecord2.Frequent_Flyer_Number__c;
        qHostRecord2.QCC_Contact_Lastname__c = contactRecord2.LastName;
        qHostRecord2.QCC_First_Host_First_Name__c = contactRecord2.FirstName;
        qHostRecord2.QCC_First_Host_Contact__c = null;
        qHostRecord2.QCC_TECH_IsCreatedFromEvent__c = true;
        qantasHostList.add(qHostRecord2);
        
        //Qantas Host without FFNumber
        QCC_First_Host__c qHostRecord3 = QCC_TestDataFactory.createFirstHostTestData(contactRecord3.Id, airportCodeRecord.Id);       
        qHostRecord3.QCC_Contact_Lastname__c = contactRecord3.LastName;
        qHostRecord3.QCC_First_Host_First_Name__c = contactRecord3.FirstName;
        qHostRecord3.QCC_First_Host_Contact__c = null;
        qHostRecord3.QCC_Frequent_Flyer_Number__c = null;
        qHostRecord3.QCC_Departure_Local_Date__c = System.today().addDays(1);     
        qantasHostList.add(qHostRecord3);
        
        //Qantas Host with Call Out - Create Contact
        QCC_First_Host__c qHostRecord4 = QCC_TestDataFactory.createFirstHostTestData(contactRecord3.Id, airportCodeRecord.Id);       
        qHostRecord4.QCC_Contact_Lastname__c = 'Test LastName';
        qHostRecord4.QCC_First_Host_First_Name__c = 'Test FirstName';
        qHostRecord4.QCC_Frequent_Flyer_Number__c = '1234567890';
        qHostRecord4.QCC_First_Host_Contact__c = null;  
        qHostRecord4.QCC_TECH_IsCreatedFromEvent__c = true;
        qHostRecord4.QCC_Departure_Local_Date__c = System.today().addDays(1);        
        qantasHostList.add(qHostRecord4);
        
        //Qantas Host with Call Out - Create Case
        QCC_First_Host__c qHostRecord5 = QCC_TestDataFactory.createFirstHostTestData(contactRecord3.Id, airportCodeRecord.Id);       
        qHostRecord5.QCC_Contact_Lastname__c = 'Test LastName5';
        qHostRecord5.QCC_First_Host_First_Name__c = 'Test FirstName5';
        qHostRecord5.QCC_Frequent_Flyer_Number__c = '111111111';
        qHostRecord5.QCC_First_Host_Contact__c = null;      
        qHostRecord5.QCC_Departure_Local_Date__c = System.today().addDays(1);       
        qantasHostList.add(qHostRecord5);  
        
        insert qantasHostList;  
    }
    
    static testmethod void testqHostContactPopulated(){
        Set<Id> qantasHostIds = new Set<Id>();
        List <QCC_First_Host__c> qHostRecord = [SELECT Id,QCC_Frequent_Flyer_Number__c,QCC_Contact_Lastname__c,QCC_Departure_Airport__c, QCC_Flight_No__c 
                                                FROM QCC_First_Host__c WHERE QCC_Frequent_Flyer_Number__c = '12345'];        
        for (QCC_First_Host__c qh : qHostRecord){
            qantasHostIds.add(qh.Id);         
        }        
        Test.startTest();
        Id batchJobId = Database.executeBatch(new QCC_QantasHostLookUpContactBatch(qantasHostIds), 1);
        Test.stopTest();  
    }
    
    static testmethod void testqHostContactNotPopulated(){
        Set<Id> qantasHostIds = new Set<Id>();
        List <QCC_First_Host__c> qHostRecord = [SELECT Id,QCC_Frequent_Flyer_Number__c,QCC_Contact_Lastname__c,QCC_Departure_Airport__c, QCC_Flight_No__c 
                                                FROM QCC_First_Host__c WHERE QCC_Frequent_Flyer_Number__c = '67890'];
        for (QCC_First_Host__c qh : qHostRecord){
            qantasHostIds.add(qh.Id);       
        }
        Test.startTest();
        String body = 'sample';
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');   
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', body, mapHeader));   
        
        Id batchJobId = Database.executeBatch(new QCC_QantasHostLookUpContactBatch(qantasHostIds), 1);
        Test.stopTest(); 
    }
    
    static testmethod void testqHostCreateCase(){
        Set<Id> qantasHostIds = new Set<Id>();
        List <QCC_First_Host__c> qHostRecord = [SELECT Id,QCC_Frequent_Flyer_Number__c,QCC_Contact_Lastname__c,QCC_Departure_Airport__c, QCC_Flight_No__c 
                                                FROM QCC_First_Host__c WHERE QCC_Frequent_Flyer_Number__c = null];
        for (QCC_First_Host__c qh : qHostRecord){
            qantasHostIds.add(qh.Id);         
        }
        Test.startTest();
        Id batchJobId = Database.executeBatch(new QCC_QantasHostLookUpContactBatch(qantasHostIds), 1);
        Test.stopTest(); 
    }
    
    static testmethod void testCallOutCreateContact(){
        Set<Id> qantasHostIds = new Set<Id>();
        List <QCC_First_Host__c> qHostRecord = [SELECT Id,QCC_Frequent_Flyer_Number__c,QCC_Contact_Lastname__c,QCC_Departure_Airport__c, QCC_Flight_No__c 
                                                FROM QCC_First_Host__c WHERE QCC_Frequent_Flyer_Number__c = '1234567890'];
        for (QCC_First_Host__c qh : qHostRecord){
            qantasHostIds.add(qh.Id);
        }       
        Test.startTest();
        String staticResourceName = 'QCCTestDataMockResponseQantasHostCreateContact';
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = : staticResourceName LIMIT 1];
        String body = sr.Body.toString();
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');   
       // Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', body, mapHeader));                
       // Id batchJobId = Database.executeBatch(new QCC_QantasHostLookUpContactBatch(qantasHostIds), 1);
        Test.stopTest(); 
    }
    
    static testmethod void testCallOutCreateCase(){
        Set<Id> qantasHostIds = new Set<Id>();
        List <QCC_First_Host__c> qHostRecord = [SELECT Id,QCC_Frequent_Flyer_Number__c,QCC_Contact_Lastname__c,QCC_Departure_Airport__c, QCC_Flight_No__c 
                                                FROM QCC_First_Host__c WHERE QCC_Frequent_Flyer_Number__c = '111111111'];
        for (QCC_First_Host__c qh : qHostRecord){
            qantasHostIds.add(qh.Id);
        }       
        Test.startTest();
        String staticResourceName = 'QCCTestDataMockResponseQantasHostCreateContact';
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = : staticResourceName LIMIT 1];
        String body = sr.Body.toString();
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');    
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', body, mapHeader));        
        Id batchJobId = Database.executeBatch(new QCC_QantasHostLookUpContactBatch(qantasHostIds), 1);
        Test.stopTest(); 
    }
}