/*********************************************************************************
Name         : QCC_LoyaltyCreateContactQueueableTest
Created By   : Lora Mae S. Dapulang
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 13 December 2019
Usages       : This class is used for the code coverage of the apex class below:
				- QCC_LoyaltyStatusCreateContactQueueable
Modified By : Venkata Suresh Kumar (TCS Team), 17-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method.
*********************************************************************************/
@isTest
public class QCC_LoyaltyCreateContactQueueableTest {

    @testSetup
    static void setupTestData(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        //Create test data for Account object
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        insert accountRecord;
        
        //Create test data for Contact object
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        contactRecord.RecordTypeId = contactRecordTypeId;
        contactRecord.Frequent_Flyer_Number__c = '1234567891';
        insert contactRecord;
        
        //Set Custom Settings for QantasConfigData__c custom settings
        List<QantasConfigData__c> customSettingRecordTypeLists = QCC_TestDataFactory.createRecordTypeConfigData();
        insert customSettingRecordTypeLists;  
        
        //Set Custom Settings for Trigger_Status__c Custom settings
        List<Trigger_Status__c> customSettingTriggerStatusLists = QCC_TestDataFactory.createTriggerStatusData();
        insert customSettingTriggerStatusLists;
        
        //Create test data for Qantas_API__c custom settings
        List<Qantas_API__c> qantasAPIRecords = QCC_TestDataFactory.createQantasAPITestDataList();
        insert qantasAPIRecords;
        
        //Set Custom Settings for Platform Event Switch custom settings
        List<QCC_Platform_Event_Switch__c> platformEventSwitches = QCC_TestDataFactory.createRecordFromStaticResource('QCC_Platform_Event_Switch__c', 'QCCTestDataPlatformEventSwitch');
        insert platformEventSwitches;
    }
    
    static testmethod void testMethod1(){
        Id individualContactRecordTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));  
        Contact con = [SELECT Name, LastName, Frequent_Flyer_Number__c FROM Contact WHERE RecordTypeId =: individualContactRecordTypeId];
        
        Test.startTest();
        List<QCC_Loyalty_Status__e> loyaltyStatusToCreateContactList = new  List<QCC_Loyalty_Status__e>();
        QCC_Loyalty_Status__e le = new QCC_Loyalty_Status__e(
            memberId__c = '1234567890',
            previousTier__c = 'CLPO',
            effectiveTier__c = 'FFPO',
            eventType__c = 'MEMBER_TIER_DOWNGRADE'
        );
        
        loyaltyStatusToCreateContactList.add(le);
        Database.SaveResult producer = EventBus.publish(le);  
        System.assertEquals(true, producer.isSuccess(),'Loyalty Status Event insert should be a success');        
        Test.getEventBus().deliver();
        String staticResourceName = 'QCC_Loyalty_Callout_Response';
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = : staticResourceName LIMIT 1];
        String body = sr.Body.toString();
        //This will just check that the static resource string fits the QCC_LoyaltyResponseWrapper format
        QCC_LoyaltyresponseWrapper responseWrapper = (QCC_LoyaltyresponseWrapper)JSON.deserialize(body, QCC_LoyaltyresponseWrapper.class);
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');    
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', body, mapHeader));            

        QCC_LoyaltyStatusCreateContactQueueable queueableJob = new QCC_LoyaltyStatusCreateContactQueueable();
        queueableJob.loyaltyStatusList = loyaltyStatusToCreateContactList;            

        System.enqueueJob(queueableJob);
        
        Test.stopTest();        
    }
}