/*********************************************************************************
Name         : ContactTriggerHelperTest
Created By   : Lora Mae S. Dapulang
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 02 October 2019
Usages       : This class is used for the code coverage of the apex class below:
- ContactTriggerHelper

Modified By : Hari B (TCS Team), 27-Feb-2026
Desc : Rmediated test class failures. Updated setupTestData() method.

Modified By : Venkata Suresh Kumar Yalla (TCS Team), 29-May-2026
Desc : Rmediated test class failures. Updated setupTestData() method.Updated 'Qantas Sales' profile ref with 'QL_Sales' 
**********************************************************************************
History
21-Jul-2026		Jonathan-Capgemini			RBAC SND
*********************************************************************************/
@isTest
public class ContactTriggerHelperTest {
    static Account accountRecord;    
    static String contactRecordTypeId;
    static String individualContactRecordTypeId;
    static User qantasB2CConsultantUser;
    static User qantaB2BUser;
    static Integer startFFNumber = 1000001;
    
    @testSetup static void setupTestData(){
        Test.startTest();
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
        Test.stopTest();
        contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId();
        //individualContactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();

        List<User> testUsers = new List<User>();
        Map<String, Profile> profilesMap = TestUtilityDataClassQantas.getProfileMap();
        //GRAPHITE-154/155: Contact Model Redesign - Set the role for the running user
        Map<String, UserRole> rolesMap = TestUtilityDataClassQantas.getRoles();
        
        Profile qantasCcConsultantProfile = profilesMap.get('Qantas CC Consultant');
        UserRole qantasCcConsultantRole = rolesMap.get('QF-QDC-OM-MNL-TL');
        system.debug('>>>qantasCcConsultantRole: ' + qantasCcConsultantRole);
        qantasB2CConsultantUser = QCC_TestDataFactory.createUserTestData(qantasCcConsultantProfile.Id);
        qantasB2CConsultantUser.UserName = 'testB2CUser@qantas.com.au';
        qantasB2CConsultantUser.UserRoleId = qantasCcConsultantRole.Id;
        testUsers.add(qantasB2CConsultantUser);

        Profile qantasB2BProfile = profilesMap.get('Sales and Distribution-Sales'); // CRM-11408 Test class fix //RBAC SND - Profile Update
        UserRole qantasB2BRole = rolesMap.get('QF-Sales & Distribution');
        qantaB2BUser = QCC_TestDataFactory.createUserTestData(qantasB2BProfile.Id);
        qantaB2BUser.UserName = 'testB2BUser@qantas.com.au';
        qantaB2BUser.UserRoleId = qantasB2BRole.Id;
        testUsers.add(qantaB2BUser);
        //insert testUsers;
		
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId()];
        System.runAs(thisUser) {
            //Set Custom Settings for Record Types
            List<QantasConfigData__c> customSettingRecordTypeLists = QCC_TestDataFactory.createRecordTypeConfigData();
            insert customSettingRecordTypeLists;

            //Set Custom Settings for Trigger_Status__c Custom settings
            List<Trigger_Status__c> customSettingTriggerStatusLists = QCC_TestDataFactory.createTriggerStatusData();
            insert customSettingTriggerStatusLists;

            //TO-DO for Feb Release: Create custom setting for case trigger
            /*List<QantasConfigData__c> customSettingList = QCC_UtilityHelper.createDynamicObjectRecords('QantasConfigData__c', 'QCCTestDataQantasConfigData', null, null, null, null);
            insert customSettingList;*/

            //Create test data for Account object
            String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect Account').getRecordTypeId();
            accountRecord = QCC_TestDataFactory.createAccountTestData(1);
            accountRecord.RecordTypeId = accountRecordTypeId;
            insert accountRecord;

            //Create test data for B2B Contact
            List<Contact> contactRecords = new List<Contact>();
            system.debug('>>>Contact - startFFNumber: ' + startFFNumber);
            for (Integer i=startFFNumber; i < (startFFNumber + 10); i++) {
                system.debug('>>>Create B2B Contacts - count: ' + i);
                Contact b2bContactRecord = QCC_TestDataFactory.createContactTestData(i, accountRecord.Id);
                b2bContactRecord.RecordTypeId = contactRecordTypeId;
                b2bContactRecord.Frequent_Flyer_Number__c = String.valueOf(i);
                b2bContactRecord.Frequent_Flyer_Tier__c = 'Platinum One';
				b2bContactRecord.QAC_Contact__c = 'No';
                contactRecords.add(b2bContactRecord);
            }
            system.debug('>>>createIndividualRecordTest - contactRecords: ' + contactRecords);
            insert contactRecords;
        }
    }

    static testMethod void createIndividualRecordTest_0() {
        List<Trigger_Status__c> contactTriggerRecords = QCC_TestDataFactory.createRecordFromStaticResource('Trigger_Status__c', 'QCCTestDataTriggerStatusContact');
        insert contactTriggerRecords;

        Map<String,User> testUsers_ProfileMap = new Map<String,User>();
        for (User u : [SELECT Id, Name, Profile.Name FROM User WHERE isActive = TRUE]) {
            testUsers_ProfileMap.put(u.Profile.Name, u);
        }

        Test.startTest();
        //Scenario: When B2C Consultant view a contact record out of the search frequent flyer page which at the background creates a single contact record
        //Note: No need to set AccountId as there is a trigger that automatically creates the person account for B2C Contact
        system.runAs(testUsers_ProfileMap.get('Qantas CC Consultant')) {
            //Create test data for B2C Contact
            Contact b2cContactRecord = QCC_TestDataFactory.createContactTestData(startFFNumber, null);
            //b2cContactRecord.RecordTypeId = individualContactRecordTypeId;
            b2cContactRecord.RecordTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));
            b2cContactRecord.Frequent_Flyer_Number__c = String.valueOf(startFFNumber);
            b2cContactRecord.Frequent_Flyer_Tier__c = 'Platinum One';
            b2cContactRecord.QAC_Contact__c = 'No';
            b2cContactRecord.QCC_TECH_RecordType__c = 'Individual Contact';
            b2cContactRecord.SSU__c = TRUE;
            try {
                insert b2cContactRecord;
            } catch (Exception e) {
                system.debug('>>>b2cContactRecord - Exception: ' + e.getMessage());
            }
            system.debug('>>>b2cContactRecord: ' + b2cContactRecord);
        }
        Test.stopTest();
        
        //Check for the test resuls
        List<Contact> contactsInserted = new List<Contact>([SELECT Id, Name, RecordType.Name, QCC_TECH_RecordType__c, Frequent_Flyer_Number__c, AccountId, IndividualId FROM Contact WHERE Frequent_Flyer_Number__c != null AND AccountId != NULL AND IndividualId != NULL]);
        system.debug('>>>contactsInserted: ' + contactsInserted);
        system.debug('>>>contactsInserted.size(): ' + contactsInserted.size());
        List<Individual> individualLists = [SELECT Id, QCC_Frequent_Flyer_Number__c FROM Individual];
        system.debug('>>>individualLists: ' + individualLists);
        system.debug('>>>individualLists.size(): ' + individualLists.size());
        //The number of contact records inserted are: 10 B2B, 1 B2C
      //  system.assertEquals(1, contactsInserted.size());
        //The number of contact records inserted are: 10 unique FF Numbers
      //  system.assertEquals(1, individualLists.size());
    }

    static testMethod void updatingToSSUTest(){
        List<Trigger_Status__c> contactTriggerRecords = QCC_TestDataFactory.createRecordFromStaticResource('Trigger_Status__c', 'QCCTestDataTriggerStatusContact');
        insert contactTriggerRecords;

        Test.startTest();
        contact contactRec = [SELECT id FROM Contact WHERE ssu__c != TRUE LIMIT 1];
        contactRec.SSU__c = TRUE;
        update contactRec;
        Test.stopTest();
    }

    static testMethod void updatePhoneAndAddressFields() {
        List<Trigger_Status__c> contactTriggerRecords = QCC_TestDataFactory.createRecordFromStaticResource('Trigger_Status__c', 'QCCTestDataTriggerStatusContact');
        insert contactTriggerRecords;
        //Create test data for Account object
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
        contactRecord.QCC_TECH_BusinessPhoneCountryCode__c = '+63';
        insert contactRecord;

        Test.startTest();
        contactRecord.QCC_TECH_BusinessPhoneCountryCode__c = '+61';
        contactRecord.QCC_TECH_BusinessPhoneNumber__c = '1231231231';
        contactRecord.QCC_TECH_HomePhoneCountryCode__c = '+61';
        contactRecord.QCC_TECH_HomePhoneNumber__c = '1231231231';
        contactRecord.QCC_TECH_MobilePhoneCountryCode__c = '+61';
        contactRecord.QCC_TECH_MobilePhoneNumber__c = '1231231231';
        contactRecord.QCC_TECH_TravelSMSPhoneCountryCode__c = '+61';
        contactRecord.QCC_TECH_TravelSMSPhoneNumber__c = '1231231231';
        contactRecord.QCC_TECH_MailingStreetHomeLineOne__c = 'Sample';
        contactRecord.QCC_TECH_MailingStreetBusinessLineOne__c = 'Sample';

        update contactRecord;
        Test.stopTest();
    }
    
}