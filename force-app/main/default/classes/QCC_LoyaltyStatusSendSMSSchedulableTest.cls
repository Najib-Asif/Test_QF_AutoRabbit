/*********************************************************************************
Name         : QCC_LoyaltyStatusSendSMSSchedulableTest
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 10 October 2019
Usages       : This class is used for the code coverage of the apex class below:
			   - QCC_LoyaltyStatusSendSMSSchedulable

Modified By : Venkata Suresh Kumar (TCS Team), 18-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method.
*********************************************************************************/
@isTest
public class QCC_LoyaltyStatusSendSMSSchedulableTest {
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
        contactRecord.QCC_TECH_Loyalty_Point_Type__c = 'PB75K';
        contactRecord.QCC_LoyaltyBonus_Channel__c = 'SMS';

        insert contactRecord;
        
        List<Trigger_Status__c> customSettingList = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusCase', null, null, null, null);
        insert customSettingList;
    }
    
    static testmethod void test1(){
		String Body = '{"token_type":"bearer","expires_in":172800,"access_token":"71c6f08c68fac962cf08b4667206043e79a66ef6"}';
		Map<String, String> mapHeader= new Map<String, String>();
		mapHeader.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader));
        
        QCC_LoyaltyStatusSendSMSSchedulable batchJob = new QCC_LoyaltyStatusSendSMSSchedulable(); 
        Test.startTest();
        batchJob.execute(null);
        Test.stopTest();
    }
}