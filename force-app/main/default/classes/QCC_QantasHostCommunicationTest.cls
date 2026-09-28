/*********************************************************************************
Name         : QCC_QantasHostCommunicationTest
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 12 November 2019
Usages       : This class is used for the code coverage of the apex class below:
			   - QCC_QantasHostCommunication

Modified By : Venkata Suresh Kumar (TCS Team), 19-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method.
*********************************************************************************/
@isTest
public class QCC_QantasHostCommunicationTest {
	@testSetup
    static void setupTestData(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        //Create test data for Flight Event object
        List<Trigger_Status__c> customSettingListQantasHost = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusQantasHost', null, null, null, null);
        insert customSettingListQantasHost;

        //Create test data for Account object
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        insert accountRecord;
        
        //Create test data for Contact object
        List<Contact> contactList = new List<Contact>();
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        
        //QCC_Qantas_Host_Always_Call__c = false
        Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        contactRecord.RecordTypeId = contactRecordTypeId;
        contactRecord.Frequent_Flyer_Number__c = '000001';
        contactRecord.Frequent_Flyer_Tier__c = 'Platinum One';
        contactRecord.QCC_Qantas_Host_Always_Call__c = false;
        contactList.add(contactRecord);
        
        //QCC_Qantas_Host_Always_Call__c = true
        Contact contactRecord2 = QCC_TestDataFactory.createContactTestData(2, accountRecord.Id);
        contactRecord2.RecordTypeId = contactRecordTypeId;
        contactRecord2.Frequent_Flyer_Number__c = '000002';
        contactRecord2.Frequent_Flyer_Tier__c = 'Platinum One';
        contactRecord2.QCC_Qantas_Host_Always_Call__c = true;
        contactList.add(contactRecord2);
        
        //QCC_Qantas_Host_Always_Call__c = false
        //QCC_Preferred_Contact_Channel__c = 'Email'
        Contact contactRecord3 = QCC_TestDataFactory.createContactTestData(3, accountRecord.Id);
        contactRecord3.RecordTypeId = contactRecordTypeId;
        contactRecord3.Frequent_Flyer_Number__c = '000003';
        contactRecord3.Frequent_Flyer_Tier__c = 'Platinum One';
        contactRecord3.QCC_Qantas_Host_Always_Call__c = false;
        contactRecord3.QCC_Preferred_Contact_Channel__c = 'Email';
        contactRecord3.Email = 'sample@test.com';
        contactRecord3.QCC_TECH_MobilePhoneNumber__c = '1234123412';
        contactRecord3.QCC_TECH_MobilePhoneCountryCode__c = '61';
        contactList.add(contactRecord3);
        
        //QCC_Qantas_Host_Always_Call__c = false
        //QCC_Preferred_Contact_Channel__c = 'SMS'
        Contact contactRecord4 = QCC_TestDataFactory.createContactTestData(4, accountRecord.Id);
        contactRecord4.RecordTypeId = contactRecordTypeId;
        contactRecord4.Frequent_Flyer_Number__c = '000004';
        contactRecord4.Frequent_Flyer_Tier__c = 'Platinum One';
        contactRecord4.QCC_Qantas_Host_Always_Call__c = false;
        contactRecord4.QCC_Preferred_Contact_Channel__c = 'SMS';
        contactRecord4.Email = 'sample@test.com';
        contactRecord4.QCC_TECH_MobilePhoneNumber__c = '1234123413';
        contactRecord4.QCC_TECH_MobilePhoneCountryCode__c = '61';
        contactList.add(contactRecord4);
        
        insert contactList;
        
        //Create test data for Qantas API object
        List<Qantas_API__c> qantasAPIRecords = QCC_TestDataFactory.createQantasAPITestDataList();
        insert qantasAPIRecords;
        
        //Create test data for Airport Code to be used in QHost record creation
        Airport_Code__c airportCodeRecord = QCC_TestDataFactory.createAirportCodeTestData();
        insert airportCodeRecord;
        
        Airport_Code__c airportCodeRecord2 = QCC_TestDataFactory.createAirportCodeTestData();
        airportCodeRecord2.Name = 'SIN';
        insert airportCodeRecord2;
        
        //Create test data for Airport Code to be used in QHost record creation
        Airport_Code__c airportCodeRecord3 = QCC_TestDataFactory.createAirportCodeTestData();
        airportCodeRecord3.Name = 'MEL';
        insert airportCodeRecord3;
        
        //Create test data for Qantas Host
        List<QCC_First_Host__c> qantasHostList = new List<QCC_First_Host__c>();
        QCC_First_Host__c qantasHostRecord = QCC_TestDataFactory.createFirstHostTestData(contactRecord.Id, airportCodeRecord.Id);
        qantasHostRecord.QCC_Flight_No__c = '0001';
        qantasHostRecord.QCC_Carrier_Code__c = 'QF';
        qantasHostList.add(qantasHostRecord);
        
        QCC_First_Host__c qantasHostRecord2 = QCC_TestDataFactory.createFirstHostTestData(contactRecord2.Id, airportCodeRecord.Id);
        qantasHostRecord2.QCC_Flight_No__c = '0009';
        qantasHostRecord2.QCC_Carrier_Code__c = 'QF';
        qantasHostList.add(qantasHostRecord2);
        
        QCC_First_Host__c qantasHostRecord3 = QCC_TestDataFactory.createFirstHostTestData(contactRecord3.Id, airportCodeRecord.Id);
        qantasHostRecord3.QCC_Flight_No__c = '0002';
        qantasHostRecord3.QCC_Carrier_Code__c = 'QF';
        qantasHostRecord3.QCC_Cabin__c = 'P';
        qantasHostList.add(qantasHostRecord3);
        
        QCC_First_Host__c qantasHostRecord4 = QCC_TestDataFactory.createFirstHostTestData(contactRecord4.Id, airportCodeRecord.Id);
        qantasHostRecord4.QCC_Flight_No__c = '0003';
        qantasHostRecord4.QCC_Carrier_Code__c = 'QF';
        qantasHostRecord4.QCC_Cabin__c = 'P';
        qantasHostList.add(qantasHostRecord4);
        
        QCC_First_Host__c qantasHostRecord5 = QCC_TestDataFactory.createFirstHostTestData(contactRecord2.Id, airportCodeRecord3.Id);
        qantasHostRecord5.QCC_Flight_No__c = '0004';
        qantasHostRecord5.QCC_Carrier_Code__c = 'QF';
        qantasHostRecord5.QCC_Cabin__c = 'P';
        qantasHostList.add(qantasHostRecord5);
        
        QCC_First_Host__c qantasHostRecord6 = QCC_TestDataFactory.createFirstHostTestData(contactRecord2.Id, airportCodeRecord2.Id);
        qantasHostRecord6.QCC_Flight_No__c = '0004';
        qantasHostRecord6.QCC_Carrier_Code__c = 'QF';
        qantasHostRecord6.QCC_Cabin__c = 'P';
        qantasHostList.add(qantasHostRecord6);
        
        insert qantasHostList;  
    }
    
    static testmethod void test1(){
        List<QCC_First_Host__c> qantasHostRecords = [
            SELECT Id FROM QCC_First_Host__c 
            WHERE QCC_First_Host_Contact__r.QCC_Qantas_Host_Always_Call__c = true
        ];
        List<Id> qantasHostIds = new List<Id>();
        for(QCC_First_Host__c qantasHostRecord : qantasHostRecords) {
            qantasHostIds.add(qantasHostRecord.Id);
        }
        
        QCC_QantasHostCommunication.getQantasHostTemplateByContactPreference(qantasHostIds);
    }
    
    static testmethod void test2(){
        Test.startTest();
        List<QCC_First_Host__c> qantasHostRecords = [
            SELECT Id FROM QCC_First_Host__c 
            WHERE QCC_First_Host_Contact__r.QCC_Qantas_Host_Always_Call__c = false
            AND QCC_First_Host_Contact__r.QCC_Preferred_Contact_Channel__c = 'Email'
        ];
        List<Id> qantasHostIds = new List<Id>();
        for(QCC_First_Host__c qantasHostRecord : qantasHostRecords) {
            qantasHostIds.add(qantasHostRecord.Id);
        }
        
        QCC_QantasHostCommunication.getQantasHostTemplateByContactPreference(qantasHostIds);
        Test.stopTest();
    }
    
    static testmethod void test3(){
        Test.startTest();
        List<QCC_First_Host__c> qantasHostRecords = [
            SELECT Id FROM QCC_First_Host__c 
            WHERE QCC_First_Host_Contact__r.QCC_Qantas_Host_Always_Call__c = false
            AND QCC_First_Host_Contact__r.QCC_Preferred_Contact_Channel__c = 'SMS'
        ];
        List<Id> qantasHostIds = new List<Id>();
        for(QCC_First_Host__c qantasHostRecord : qantasHostRecords) {
            qantasHostIds.add(qantasHostRecord.Id);
        }
        
		String Body = '{"token_type":"bearer","expires_in":172800,"access_token":"71c6f08c68fac962cf08b4667206043e79a66ef6"}';
		Map<String, String> mapHeader= new Map<String, String>();
		mapHeader.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_QantasHostCommunication.getQantasHostTemplateByContactPreference(qantasHostIds);
        Test.stopTest();
    }
    
    static testmethod void alwaysCallcreateCase(){ //Test for always call customer. No email or SMS to be sent, only case creation
        Test.startTest();
        List<QCC_First_Host__c> qantasHostRecords = [
            SELECT Id FROM QCC_First_Host__c 
            WHERE QCC_First_Host_Contact__r.QCC_Qantas_Host_Always_Call__c = true
            AND QCC_Departure_Airport__c = 'MEL'
        ];
        System.debug('>>>alwaysCallcreateCase: '+ qantasHostRecords);
        List<Id> qantasHostIds = new List<Id>();
        for(QCC_First_Host__c qantasHostRecord : qantasHostRecords) {
            qantasHostIds.add(qantasHostRecord.Id);
        }
        
		String Body = '{"token_type":"bearer","expires_in":172800,"access_token":"71c6f08c68fac962cf08b4667206043e79a66ef6"}';
		Map<String, String> mapHeader= new Map<String, String>();
		mapHeader.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_QantasHostCommunication.getQantasHostTemplateByContactPreference(qantasHostIds);
        Test.stopTest();
    }
    
    static testmethod void alwaysCallNotMELorSYD(){ //Test for always call customer but not departing in MEL or SYD
        Test.startTest();
        List<QCC_First_Host__c> qantasHostRecords = [
            SELECT Id FROM QCC_First_Host__c 
            WHERE QCC_First_Host_Contact__r.QCC_Qantas_Host_Always_Call__c = true
            AND QCC_Departure_Airport__c = 'SIN' LIMIT 1
        ];
        List<Id> qantasHostIds = new List<Id>();
        for(QCC_First_Host__c qantasHostRecord : qantasHostRecords) {
            qantasHostIds.add(qantasHostRecord.Id);
        }
        
		String Body = '{"token_type":"bearer","expires_in":172800,"access_token":"71c6f08c68fac962cf08b4667206043e79a66ef6"}';
		Map<String, String> mapHeader= new Map<String, String>();
		mapHeader.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_QantasHostCommunication.getQantasHostTemplateByContactPreference(qantasHostIds);
        Test.stopTest();
    }
}