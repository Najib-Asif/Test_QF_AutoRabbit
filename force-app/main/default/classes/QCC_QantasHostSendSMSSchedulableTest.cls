/*********************************************************************************
Name         : QCC_QantasHostSendSMSSchedulableTest
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 12 November 2019
Usages       : This class is used for the code coverage of the apex class below:
			   - QCC_QantasHostSendSMSSchedulable

Modified By : Venkata Suresh Kumar (TCS Team), 19-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method. Added Test.start and Test.Stop methods
*********************************************************************************/
@isTest
public class QCC_QantasHostSendSMSSchedulableTest {
	@testSetup
    static void setupTestData(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        List<Trigger_Status__c> customSettingList = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusCase', null, null, null, null);
        insert customSettingList;

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
        contactRecord3.MobilePhone = '1234123412';
        contactRecord3.Phone_Country_Code__c = '61';
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
        contactRecord4.MobilePhone = '1234123412';
        contactRecord4.Phone_Country_Code__c = '61';
        contactList.add(contactRecord4);
        
        insert contactList;
        
        //Create test data for Qantas API object
        List<Qantas_API__c> qantasAPIRecords = QCC_TestDataFactory.createQantasAPITestDataList();
        insert qantasAPIRecords;
        
        //Create test data for Airport Code to be used in QHost record creation
        Airport_Code__c airportCodeRecord = QCC_TestDataFactory.createAirportCodeTestData();
        insert airportCodeRecord;
        
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
        qantasHostRecord3.QCC_TECH_SMS_Need_To_Send__c = true;
        qantasHostList.add(qantasHostRecord3);
        
        QCC_First_Host__c qantasHostRecord4 = QCC_TestDataFactory.createFirstHostTestData(contactRecord4.Id, airportCodeRecord.Id);
        qantasHostRecord4.QCC_Flight_No__c = '0003';
        qantasHostRecord4.QCC_Carrier_Code__c = 'QF';
        qantasHostRecord4.QCC_Cabin__c = 'P';
        qantasHostRecord4.QCC_TECH_SMS_Need_To_Send__c = true;
        qantasHostList.add(qantasHostRecord4);
        
        insert qantasHostList;  
    }
    
    static testmethod void test1(){
		String Body = '{"token_type":"bearer","expires_in":172800,"access_token":"71c6f08c68fac962cf08b4667206043e79a66ef6"}';
		Map<String, String> mapHeader= new Map<String, String>();
		mapHeader.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        QCC_QantasHostSendSMSSchedulable batchJob = new QCC_QantasHostSendSMSSchedulable(); 
        Test.startTest();
        batchJob.execute(null);
        Test.stopTest();
    }
}