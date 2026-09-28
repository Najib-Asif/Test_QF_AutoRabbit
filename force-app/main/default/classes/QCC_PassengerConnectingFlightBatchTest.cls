/*********************************************************************************
Name         : QCC_PassengerConnectingFlightBatchTest
Created By   : Francis Bagtas
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 23 August 2019
Usages       : This class is used for the code coverage of the apex class below:
         - QCC_PassengerConnectingFlightInvocable
         - QCC_PassengerConnectingFlightBatch
         - QCC_CustomerFlightsWrapper

Modified By : Venkata Suresh Kumar (TCS Team), 17-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method.
*********************************************************************************/
@isTest
public class QCC_PassengerConnectingFlightBatchTest{
    @testSetup
    static void setupTestData(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        List<Qantas_API__c> lstQantas = QCC_TestDataFactory.createQantasAPITestDataList();
        insert lstQantas;
        
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
        //  05/02/2020 23:55:00
        flightEventRecord.ScheduledDepDate__c = date.newInstance(2019, 9, 21);
        flightEventRecord.ScheduledDepTime__c = '12:40';
        flightEventRecord.ScheduledArrDateTime__c = '09/20/2019 18:55:00';
        flightEventRecord.DeparturePort__c ='LHR';
        flightEventRecord.ArrivalPort__c ='PER';
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
        
        String passengerRecordTypeId = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByName().get('QCC EventPassenger').getRecordTypeId();
        Affected_Passenger__c passengerRecord = QCC_TestDataFactory.createPassengerTestData(flightEventRecord.Id, contactRecord.Id);
        passengerRecord.FrequentFlyerNumber__c = '1234567890';
        insert passengerRecord;
    }
    
     //This will cover the QCC_PassengerConnectingFlightInvocable scenario.
    static testmethod void test1(){
        
        String headsUpRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Heads Up').getRecordTypeId();
        Event__c flightEvent = [SELECT Id,GlobalEvent__c,Scheduled_Arrival_UTC__c FROM Event__c WHERE RecordTypeId =: headsUpRecordTypeId];
        
        String globalHeadsUpRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Global Heads Up').getRecordTypeId();
        Event__c flightEventGlobal = [SELECT Id,GlobalEvent__c FROM Event__c WHERE RecordTypeId =: globalHeadsUpRecordTypeId ];
                
        Test.startTest();
        flightEvent.GlobalEvent__c = flightEventGlobal.Id;
        flightEvent.Scheduled_Arrival_UTC__c = System.now();
        flightEvent.Scheduled_Depature_UTC__c = System.now();
        update flightEvent;
        Test.stopTest();
    }
}