/*********************************************************************************
Name         : QCC_PassengerDisruptionCaseCntrlerTest
Created By   : Nicole Abesamis
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 29 August 2019
Usages       : This will handle the test class and code coverage of
QCC_PassengerDisruptionCaseController APEX class

Modified By : Venkata Suresh Kumar (TCS Team), 18-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method.
*********************************************************************************/

@isTest
public class QCC_PassengerDisruptionCaseCntrlerTest {
    
    @testSetup
    static void createData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        //Create test data for Account object
        List<Trigger_Status__c> customSettingList = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusCase', null, null, null, null);
        insert customSettingList;
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        insert accountRecord;
        
        //Create test data for Contact object
        List<Contact> contactRecords = new List<Contact>();
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        contactRecord.RecordTypeId = contactRecordTypeId;
        contactRecord.Frequent_Flyer_Number__c = '000001';
        insert contactRecord;
        //contactRecords.add(contactRecord);
        
        Contact contactRecord2 = QCC_TestDataFactory.createContactTestData(2, accountRecord.Id);
        contactRecord2.RecordTypeId = contactRecordTypeId;
        contactRecord2.Frequent_Flyer_Number__c = '000002';
        contactRecords.add(contactRecord2);
        
        insert contactRecords;
        
        //Create test data for Flight Event object
        List<Trigger_Status__c> customSettingList1 = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusFlightEvent', null, null, null, null);
        insert customSettingList1;
        
        String globalEventRecType = Schema.SObjectType.Event__c.getRecordTypeInfosByDeveloperName().get('GlobalEvent').getRecordTypeId();
        Event__c flightEventRec = QCC_TestDataFactory.createFlightEventTestData();
        flightEventRec.Name = 'Important Event ';
        flightEventRec.RecordTypeId = globalEventRecType;
        flightEventRec.Scheduled_Arrival_UTC__c = System.now();
        flightEventRec.Scheduled_Departure_Date_Time__c = '2019-09-16';
        flightEventRec.Scheduled_Depature_UTC__c = System.now();
        flightEventRec.ScheduledArrDateTime__c = '16/09/2019 15:00:00';
        flightEventRec.ScheduledDepDate__c = Date.valueOf('2019-09-16');
        flightEventRec.ScheduledDepTime__c = '08:00';
        insert flightEventRec;
        
        List<Event__c> flightEventRecords = new List<Event__c>();
        String headsUpRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Heads Up').getRecordTypeId();
        Event__c flightEventRecord = QCC_TestDataFactory.createFlightEventTestData();
        flightEventRecord.Name = 'Sample Heads Up Event';
        flightEventRecord.RecordTypeId = headsUpRecordTypeId;
        flightEventRecord.Scheduled_Arrival_UTC__c = System.now();
        flightEventRecord.Scheduled_Departure_Date_Time__c = '2019-09-16';
        flightEventRecord.Scheduled_Depature_UTC__c = System.now();
        flightEventRecord.ScheduledArrDateTime__c = '16/09/2019 15:00:00';
        flightEventRecord.ScheduledDepDate__c = Date.valueOf('2019-09-16');
        flightEventRecord.ScheduledDepTime__c = '08:00';
        flightEventRecord.GlobalEvent__c = flightEventRec.Id ;
        insert flightEventRecord;
        //flightEventRecords.add(flightEventRecord);
        
        String offloadRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Flight Event - Offload').getRecordTypeId();
        Event__c flightEventRecord2 = QCC_TestDataFactory.createFlightEventTestData();
        flightEventRecord2.Name = 'Sample Offload Event';
        flightEventRecord2.RecordTypeId = offloadRecordTypeId;
        flightEventRecord2.Scheduled_Arrival_UTC__c = System.now();
        flightEventRecord2.Scheduled_Departure_Date_Time__c = '2019-09-16';
        flightEventRecord2.Scheduled_Depature_UTC__c = System.now();
        flightEventRecord2.ScheduledArrDateTime__c = '16/09/2019 15:00:00';
        flightEventRecord2.ScheduledDepDate__c = Date.valueOf('2019-09-16');
        flightEventRecord2.ScheduledDepTime__c = '08:00';
        flightEventRecord2.IntDom__c = 'International';
        flightEventRecord2.QCC_Heads_Up_Event__c = flightEventRecord.Id;
        
        insert flightEventRecord2;
        //flightEventRecords.add(flightEventRecord2);
        
        String globalHeadsUpRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Global Heads Up').getRecordTypeId();
        Event__c flightEventRecord3 = QCC_TestDataFactory.createGlobalHeadsUpEvent(globalHeadsUpRecordTypeId);
        flightEventRecords.add(flightEventRecord3);
        
        insert flightEventRecords;
        
        //Create test data for Passenger object
        List<Trigger_Status__c> customSettingList2 = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusPassenger', null, null, null, null);
        insert customSettingList2;
        
        List<Affected_Passenger__c> passengerRecords = new List<Affected_Passenger__c>();
        String passengerRecordTypeId = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByName().get('QCC EventPassenger').getRecordTypeId();
        
        //Passenger record for 000001
        Affected_Passenger__c passengerRecord = QCC_TestDataFactory.createPassengerTestData(flightEventRecord2.Id, contactRecord.Id);
        passengerRecord.QCC_Disruption_Actioned__c = true;
        insert passengerRecord;
        
        //Case Record 2
        Case caseRec2 = QCC_TestDataFactory.createCaseTestData(accountRecord.Id, contactRecord2.Id);
        caseRec2.Passenger_Id__c = passengerRecord.Id;
        insert caseRec2;
        
        Affected_Passenger__c passengerRecord2 = QCC_TestDataFactory.createPassengerTestData(flightEventRecord.Id, contactRecord.Id);
        passengerRecord2.QCC_Disruption_Actioned__c = false;
        insert passengerRecord2;
    }
    
    static testMethod void getPassengerRecordsTest(){
        Account accountRecord = [SELECT Id, RecordType.Name FROM Account WHERE RecordType.Name =: 'Person Account' ];
        Contact contactRecord = [SELECT Id, Frequent_Flyer_Number__c FROM Contact WHERE Frequent_Flyer_Number__c = '000001'];
        Event__c flightEvent2 = [SELECT Id, Name, RecordType.Name FROM Event__c WHERE Recordtype.Name = 'Flight Event - Offload'];
        Affected_Passenger__c affectedPassengerRec = [SELECT Id, Passenger__c, Event__c FROM Affected_Passenger__c WHERE Event__c =: flightEvent2.Id ];
        Case caseRecord = [SELECT Id, Passenger_Id__c FROM Case WHERE Passenger_Id__c =: affectedPassengerRec.Id ];
        Test.startTest();
        QCC_PassengerDisruptionCaseController.getPassengerRecords(caseRecord.Id);
        Test.stopTest();
    }
}