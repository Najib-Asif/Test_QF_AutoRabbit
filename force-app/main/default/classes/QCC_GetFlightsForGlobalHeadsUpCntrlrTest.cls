/*********************************************************************************
Name         : QCC_GetFlightsForGlobalHeadsUpCntrlrTest
Created By   : Lora Mae Dapulang
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 17 September 2019
Usages       : This class is used for the code coverage of the apex class below:
- QCC_GetFlightsForGlobalHeadsUpController
Modified By : Venkata Suresh Kumar (TCS Team), 18-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method.
*********************************************************************************/
@isTest
public class QCC_GetFlightsForGlobalHeadsUpCntrlrTest {
    
    static Event__c globalHeadsUpEvent;
    
    static testMethod void setupTestData(){
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
        contactRecord.Frequent_Flyer_Number__c = '000001';
        contactRecord.Frequent_Flyer_Tier__c = 'Platinum One';
        contactRecord.Status_Credits__c = 2024;
        insert contactRecord;
        
        //Create test data for Qantas API object
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        
        //Set Custom Settings Trigger_Status__c to false
        List<Trigger_Status__c> customSettingList1 = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusFlightEvent', null, null, null, null);
        insert customSettingList1;
        
       //Set Custom Settings Trigger_Status__c to false
        List<QantasConfigData__c> customSettingListRecordType = QCC_TestDataFactory.createRecordTypeConfigData();
        insert customSettingListRecordType;           
        
        //insert Global HeadsUp Event record
        Id recordTypeId = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Event__c' and Name = 'Global Heads Up'].Id;
        globalHeadsUpEvent = QCC_TestDataFactory.createGlobalHeadsUpEvent(recordTypeId);
        insert globalHeadsUpEvent;              
    }
    
    static testMethod void testMethod1() {  
        setupTestData();
        Test.startTest();        
        
        String staticResourceName = 'QCCTestDataGlobalHeadsUpController';
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = : staticResourceName LIMIT 1];
        String body = sr.Body.toString();
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
                
        QCC_GetFlightsForGlobalHeadsUpController.getAllFlights(globalHeadsUpEvent.Id);
        Test.stopTest();        
    }
}