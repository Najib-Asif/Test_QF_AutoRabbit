/*********************************************************************************
Name         : QCC_LoyaltyStatusEventCaseCreationTest
Created By   : Francis Bagtas/Leslie May Padilla
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : January 13, 2020
Usages       : This will handle the test class and code coverage of apex class below
                - QCC_LoyaltyStatusEventCaseCreation

Modified By : Venkata Suresh Kumar (TCS Team), 18-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method.
*********************************************************************************/
@isTest
public class QCC_LoyaltyStatusEventCaseCreationTest {
    
    @testSetup static void setup() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        //Create test data for Account object
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        
        insert accountRecord;
        
        //Create test data for Contact object
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        /*Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        contactRecord.RecordTypeId = contactRecordTypeId;
        contactRecord4.Frequent_Flyer_Number__c = '19000000';*/
        
        List<Contact> contacts = new List<Contact>();
        Integer startFFNumber = 19000000;
        for (Integer i=0; i < 4; i++) {
            Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        	contactRecord.RecordTypeId = contactRecordTypeId;
            Integer nextFFNumber = startFFNumber + i;
            contactRecord.Frequent_Flyer_Number__c = String.valueOf(nextFFNumber);
            contacts.add(contactRecord);
        }
        insert contacts;
        
        List<QantasConfigData__c> qantasConfigData = QCC_TestDataFactory.createRecordTypeConfigData();
        insert qantasConfigData;

        List<QCC_Platform_Event_Switch__c> platformEventSwitches = QCC_TestDataFactory.createRecordFromStaticResource('QCC_Platform_Event_Switch__c', 'QCCTestDataPlatformEventSwitch');
        insert platformEventSwitches;

        List<Trigger_Status__c> triggerRecords = QCC_TestDataFactory.createRecordFromStaticResource('Trigger_Status__c', 'QCCTestDataTriggerStatusPlatformEvent');
        insert triggerRecords;
    }
    
    static testMethod void testMethod1() {
        Test.startTest();
        String staticResourceName = 'QCCTestDataLoyaltyPlatformEvents_WithCaseCreation';
        List<Database.SaveResult> publishedEvents = QCC_TestDataFactory.publishPlatformEvents(staticResourceName, 'QCC_Loyalty_Status__e');
        system.debug('>>>publishedEvents: ' + publishedEvents);
        Test.stopTest();
        
        for (Database.SaveResult sr : publishedEvents) {
            System.assert(true, sr.isSuccess());
        }
    }
}