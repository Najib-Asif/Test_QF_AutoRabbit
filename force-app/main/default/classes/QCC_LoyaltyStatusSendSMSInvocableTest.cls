/*********************************************************************************
Name         : QCC_LoyaltyStatusSendSMSInvocableTest
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 9 September 2019
Usages       : This class is used for the code coverage of the apex class below:
			   - QCC_LoyaltyStatusSendSMSInvocable

Modified By : Venkata Suresh Kumar (TCS Team), 18-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method. Added Test.start and Test.Stop methods
*********************************************************************************/
@isTest
public class QCC_LoyaltyStatusSendSMSInvocableTest {
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
        contactRecord.QCC_TECH_Loyalty_Point_Type__c = 'PB100K';
        contactRecord.QCC_LoyaltyBonus_Channel__c = 'SMS';
        contactRecord.QCC_TECH_MobilePhoneCountryCode__c = '+61';
        contactRecord.QCC_TECH_MobilePhoneNumber__c = '9973073476';
        insert contactRecord;
        
        //Create test data for Qantas API object
        List<Qantas_API__c> qantasAPIRecords = QCC_TestDataFactory.createQantasAPITestDataList();
        insert qantasAPIRecords;

        //Create custom setting for case trigger
        List<Trigger_Status__c> customSettingList = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusCase', null, null, null, null);
        insert customSettingList;
    }
    
    static testmethod void test1(){
        List<Contact> contactRecords = [SELECT Id, FirstName, MobilePhone, Phone_Country_Code__c FROM Contact];
        Test.startTest();
        QCC_LoyaltyStatusSendSMSInvocable.processLoyaltyStatusSMSSending(contactRecords);
        Test.stopTest();
    }
}