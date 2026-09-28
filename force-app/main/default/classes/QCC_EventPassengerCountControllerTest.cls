/*********************************************************************************
Name         : QCC_EventPassengerCountControllerTest
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 4 February 2020
Usages       : This class is used for the code coverage of the apex class below:
			   - QCC_EventPassengerCountController
Modified By : Venkata Suresh Kumar (TCS Team), 18-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method. Added Test.start and Test.Stop methods
*********************************************************************************/
@isTest
public class QCC_EventPassengerCountControllerTest {
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
        contactRecord.Frequent_Flyer_Number__c = '000001';
        contactRecord.Frequent_Flyer_Tier__c = 'Platinum One';
        contactRecord.Status_Credits__c = 2024;
        insert contactRecord;
        
        //Create test data for Flight Event object
        List<Event__c> flightEventRecords = new List<Event__c>();
        List<Trigger_Status__c> customSettingList1 = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusFlightEvent', null, null, null, null);
        insert customSettingList1;
        
        String headsUpRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Heads Up').getRecordTypeId();
        Event__c flightEventRecord = QCC_TestDataFactory.createFlightEventTestData();
        flightEventRecord.RecordTypeId = headsUpRecordTypeId;
        flightEventRecords.add(flightEventRecord);
        
        String globalHeadsUpRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Global Heads Up').getRecordTypeId();
        Event__c flightEventRecord2 = QCC_TestDataFactory.createFlightEventTestData();
        flightEventRecord2.RecordTypeId = globalHeadsUpRecordTypeId;
        flightEventRecords.add(flightEventRecord2);
        
        String flightEventActiveRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Flight Event - Active').getRecordTypeId();
        Event__c flightEventRecord3 = QCC_TestDataFactory.createFlightEventTestData();
        flightEventRecord3.RecordTypeId = flightEventActiveRecordTypeId;
        flightEventRecords.add(flightEventRecord3);
        
        insert flightEventRecords;
        
        //Create test data for Passenger object
        List<Trigger_Status__c> customSettingList2 = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusPassenger', null, null, null, null);
        insert customSettingList2;
        
        List<Affected_Passenger__c> passengerRecords = new List<Affected_Passenger__c>();
        String passengerRecordTypeId = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByName().get('QCC EventPassenger').getRecordTypeId();
        
        Affected_Passenger__c firstClassPassengerRecord = QCC_TestDataFactory.createPassengerTestData(flightEventRecord.Id, contactRecord.Id);
        firstClassPassengerRecord.Cabin__c = 'First Class';
        passengerRecords.add(firstClassPassengerRecord);
        
        Affected_Passenger__c businessPassengerRecord = QCC_TestDataFactory.createPassengerTestData(flightEventRecord.Id, contactRecord.Id);
        businessPassengerRecord.Cabin__c = 'Business';
        passengerRecords.add(businessPassengerRecord);
        
        Affected_Passenger__c premiumEconomyPassengerRecord = QCC_TestDataFactory.createPassengerTestData(flightEventRecord.Id, contactRecord.Id);
        premiumEconomyPassengerRecord.Cabin__c = 'Premium Economy';
        passengerRecords.add(premiumEconomyPassengerRecord);
        
        Affected_Passenger__c economyPassengerRecord = QCC_TestDataFactory.createPassengerTestData(flightEventRecord.Id, contactRecord.Id);
        economyPassengerRecord.Cabin__c = 'Economy';
        passengerRecords.add(economyPassengerRecord);
        
        insert passengerRecords;
    }
    
    //Scenario: Parameter is Event__c Id
    static testmethod void test1(){
        String headsUpRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Heads Up').getRecordTypeId();
        Event__c record = [SELECT Id FROM Event__c WHERE RecordTypeId =: headsUpRecordTypeId LIMIT 1];
        Test.startTest();
        QCC_EventPassengerCountController.getData(record.Id);
        Test.stopTest();
    }
    
    //Scenario: Parameter is Affected_Passenger__c Id
    static testmethod void test2(){
        Affected_Passenger__c record = [SELECT Id FROM Affected_Passenger__c LIMIT 1];
        Test.startTest();
        QCC_EventPassengerCountController.getData(record.Id);
        Test.stopTest();
    }
}