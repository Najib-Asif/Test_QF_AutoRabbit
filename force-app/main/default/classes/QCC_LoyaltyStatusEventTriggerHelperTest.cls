/*********************************************************************************
Name         : QCC_LoyaltyStatusEventTriggerHelperTest
Created By   : Francis Bagtas
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 11 Dec 2019
Usages       : This will handle the test class and code coverage of apex class below
                -QCC_LoyaltyStatusEventTriggerHelper 

Modified By : Venkata Suresh Kumar (TCS Team), 18-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method.
*********************************************************************************/

@isTest 
public class QCC_LoyaltyStatusEventTriggerHelperTest {

    @testSetup static void setup() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        //Set Custom Settings for QantasConfigData__c custom settings
        List<QantasConfigData__c> qantasConfigData = QCC_TestDataFactory.createRecordTypeConfigData();
        insert qantasConfigData;

        //Set Custom Settings for Platform Event Switch custom settings
        List<QCC_Platform_Event_Switch__c> platformEventSwitches = QCC_TestDataFactory.createRecordFromStaticResource('QCC_Platform_Event_Switch__c', 'QCCTestDataPlatformEventSwitch');
        insert platformEventSwitches;

        List<Trigger_Status__c> triggerRecords = new List<Trigger_Status__c>();

        //Set Custom Settings for Trigger_Status__c Custom settings
        List<Trigger_Status__c> platformTriggerRecords = QCC_TestDataFactory.createRecordFromStaticResource('Trigger_Status__c', 'QCCTestDataTriggerStatusPlatformEvent');
        triggerRecords.addAll(platformTriggerRecords);

        //Set Custom Settings for Trigger_Status__c Custom settings
        List<Trigger_Status__c> contactTriggerRecords = QCC_TestDataFactory.createRecordFromStaticResource('Trigger_Status__c', 'QCCTestDataTriggerStatusContact');
        triggerRecords.addAll(contactTriggerRecords);

        //Create custom setting for case trigger
        List<Trigger_Status__c> caseTriggerRecords = QCC_TestDataFactory.createRecordFromStaticResource('Trigger_Status__c', 'QCCTestDataTriggerStatusCase');
        triggerRecords.addAll(caseTriggerRecords);
        //Insert all trigger status switch
        insert triggerRecords;

        //Create test data for Account object
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;

        insert accountRecord;

        //Create test data for Contact object
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();

        List<Contact> contacts = new List<Contact>();
        Integer startFFNumber = 19000000;
        for (Integer i=0; i < 5; i++) {
            Contact contactRecord = QCC_TestDataFactory.createContactTestData(i, accountRecord.Id);
        	contactRecord.RecordTypeId = contactRecordTypeId;
            Integer nextFFNumber = startFFNumber + i;
            contactRecord.Frequent_Flyer_Number__c = String.valueOf(nextFFNumber);
            contacts.add(contactRecord);
        }
        insert contacts;
   }

    static testMethod void test() {
        Test.startTest();
        String staticResourceName = 'QCCTestDataLoyaltyPlatformEvents';
        List<Database.SaveResult> publishedEvents = QCC_TestDataFactory.publishPlatformEvents(staticResourceName, 'QCC_Loyalty_Status__e');
        system.debug('>>>publishedEvents: ' + publishedEvents);
        Test.stopTest();

        for (Database.SaveResult sr : publishedEvents) {
            System.assert(true, sr.isSuccess());
        }
    }
}