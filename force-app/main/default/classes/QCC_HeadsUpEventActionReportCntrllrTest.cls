/*********************************************************************************
Name         : QCC_HeadsUpEventActionReportCntrllrTest
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 29 July 2019
Usages       : This class is used for the code coverage of the apex class below:
			   - QCC_HeadsUpEventActionReportController
Modified By : Venkata Suresh Kumar (TCS Team), 18-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method. Added Test.start and Test.Stop methods
*********************************************************************************/
@isTest
public class QCC_HeadsUpEventActionReportCntrllrTest {
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

        String passengerRecordTypeId = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByName().get('QCC EventPassenger').getRecordTypeId();
        Affected_Passenger__c passengerRecord = QCC_TestDataFactory.createPassengerTestData(flightEventRecord.Id, contactRecord.Id);
        insert passengerRecord;
    }

    //This will cover the Heads Up scenario.
    static testmethod void test1(){
        String flightEventRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Heads Up').getRecordTypeId();
        Event__c flightEventRecord = [SELECT Id FROM Event__c WHERE RecordTypeId =: flightEventRecordTypeId LIMIT 1];
        Test.startTest();
        List<QCC_HeadsUpEventActionReportController.PassengerHeadsUpActionObject> wrapperList = QCC_HeadsUpEventActionReportController.retrievePassengerHeadsUpActionsPerClass(flightEventRecord.Id);
        Test.stopTest();
        System.assertNotEquals(wrapperList.size(), 0);
    }

    //This will cover the Global Heads Up scenario.
    static testmethod void test2(){
        String flightEventRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Global Heads Up').getRecordTypeId();
        Event__c flightEventRecord = [SELECT Id FROM Event__c WHERE RecordTypeId =: flightEventRecordTypeId LIMIT 1];
        Test.startTest();
        List<QCC_HeadsUpEventActionReportController.PassengerHeadsUpActionObject> wrapperList = QCC_HeadsUpEventActionReportController.retrievePassengerHeadsUpActionsPerClass(flightEventRecord.Id);
        Test.stopTest();
        System.assertNotEquals(wrapperList.size(), 0);
    }

    //This will cover the else part of the logic in QCC_HeadsUpEventActionReportController
    static testmethod void test3(){
        String flightEventRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Flight Event - Active').getRecordTypeId();
        Event__c flightEventRecord = [SELECT Id FROM Event__c WHERE RecordTypeId =: flightEventRecordTypeId LIMIT 1];
        Test.startTest();
        List<QCC_HeadsUpEventActionReportController.PassengerHeadsUpActionObject> wrapperList = QCC_HeadsUpEventActionReportController.retrievePassengerHeadsUpActionsPerClass(flightEventRecord.Id);
        Test.stopTest();
        System.assertNotEquals(wrapperList.size(), 0);
    }

    //This will cover the catch part of the logic in QCC_HeadsUpEventActionReportController
    static testmethod void test4(){
        String flightEventRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Heads Up').getRecordTypeId();
        Event__c flightEventRecord = [SELECT Id FROM Event__c WHERE RecordTypeId =: flightEventRecordTypeId LIMIT 1];
        delete flightEventRecord;
        Test.startTest();
        List<QCC_HeadsUpEventActionReportController.PassengerHeadsUpActionObject> wrapperList = QCC_HeadsUpEventActionReportController.retrievePassengerHeadsUpActionsPerClass(flightEventRecord.Id);
        Test.stopTest();
        System.assertEquals(wrapperList.size(), 0);
    }
}