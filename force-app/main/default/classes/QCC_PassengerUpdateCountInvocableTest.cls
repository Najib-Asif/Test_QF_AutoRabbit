/*********************************************************************************
Name         : QCC_HeadsUpEventActionReportCntrllrTest
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 16 September 2019
Usages       : This class is used for the code coverage of the apex class below:
			   - QCC_PassengerUpdateCountInvocable

Modified By : Venkata Suresh Kumar (TCS Team), 18-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method. Added Test.start and Test.Stop methods
*********************************************************************************/
@isTest
public class QCC_PassengerUpdateCountInvocableTest {
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
        contactRecord.SSU__c = true;
        insert contactRecord;
        
        //Create test data for Flight Event object
        List<Event__c> flightEventRecords = new List<Event__c>();
        List<Trigger_Status__c> customSettingList1 = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusFlightEvent', null, null, null, null);
        insert customSettingList1;
        
        String headsUpRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Heads Up').getRecordTypeId();
        Event__c flightEventRecord = QCC_TestDataFactory.createFlightEventTestData();
        flightEventRecord.RecordTypeId = headsUpRecordTypeId;
        flightEventRecords.add(flightEventRecord);
        
        insert flightEventRecords;
        
        //Create test data for Passenger object
        List<Trigger_Status__c> customSettingList2 = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusPassenger', null, null, null, null);
        insert customSettingList2;
        
        String passengerRecordTypeId = Schema.SObjectType.Affected_Passenger__c.getRecordTypeInfosByName().get('QCC EventPassenger').getRecordTypeId();
        Affected_Passenger__c passengerRecord = QCC_TestDataFactory.createPassengerTestData(flightEventRecord.Id, contactRecord.Id);
        insert passengerRecord;
    }
    
    static testmethod void test1(){
        List<Affected_Passenger__c> passengerRecords = new List<Affected_Passenger__c>();
        Affected_Passenger__c passengerRecord = [SELECT Id, Event__c FROM Affected_Passenger__c LIMIT 1];
        passengerRecords.add(passengerRecord);
        Test.startTest();
        QCC_PassengerUpdateCountInvocable.processData(passengerRecords);
        
        Event__c flightEventRecord = [
            SELECT Id, QCC_Number_of_VIPs__c, QCC_Number_of_SSUs__c, 
            QCC_Number_of_VIP_with_DOM_IN_CONX__c, QCC_Number_of_VIP_with_DOM_OUT_CONX__c, 
            QCC_Number_of_VIP_with_INTL_IN_CONX__c, QCC_Number_of_VIP_with_INTL_OUT_CONX__c 
            FROM Event__c WHERE Id =: passengerRecord.Event__c
        ];
        Test.stopTest();
        System.assertNotEquals(flightEventRecord.QCC_Number_of_VIPs__c, 0);
    }
}