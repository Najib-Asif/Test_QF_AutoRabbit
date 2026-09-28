/*********************************************************************************
Name         : QCC_TransformActionToObjectScheduleTest
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 29 July 2019
Usages       : This class is used for the code coverage of the apex class below:
- QCC_TransformActionToObjectBatch
- QCC_UtilityHelper
- QCC_TransformActionToObjectSchedulable
- QCC_SpecialLogicUtilityHelper

Modified By : Venkata Suresh Kumar (TCS Team), 19-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method.
*********************************************************************************/
@isTest
public class QCC_TransformActionToObjectScheduleTest {
    @testSetup
    static void setupTestData(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        //Create test data for Account object
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        insert accountRecord;
        
        Integer recordCount = 1;
        //Create test data for Contact object
        List<Contact> contactList = new List<Contact>();
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        for(Integer x = 0; x < recordCount; x++) {
            Contact contactRecord = QCC_TestDataFactory.createContactTestData(x, accountRecord.Id);
            contactRecord.RecordTypeId = contactRecordTypeId;
            contactRecord.Frequent_Flyer_Number__c = String.valueOf(x).leftPad(10, '0');
            contactRecord.QCC_Last_Activity_Date__c = System.today().addDays(-90);
            
            contactRecord.QCC_Last_Flight_Date__c = System.today().addDays(-70);
            
            contactRecord.QCC_Frequent_Flyer_Expiry_Date__c = System.today().addDays(90);
            contactRecord.Frequent_Flyer_Tier__c = 'Platinum One';
            contactRecord.Status_Credits__c = 2024;
            contactList.add(contactRecord);
        }
        
        insert contactList;
        
        List<QCC_Contact_Watchlist__c> watchlistRecords = new List<QCC_Contact_Watchlist__c>();
        for(Integer x = 0; x < recordCount; x++) {
            QCC_Contact_Watchlist__c record = QCC_TestDataFactory.createWatchlistTestData(x, contactList[x].Id);
            record.QCC_Watchlist_End_Date__c = System.today().addDays(7);
            watchlistRecords.add(record);
        }
        
        insert watchlistRecords;
        
        List<Trigger_Status__c> customSettingList = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusCase', null, null, null, null);
        insert customSettingList;
        
        List<QCC_Platform_Event_Switch__c> platformEventSwitchRecords = QCC_TestDataFactory.createRecordFromStaticResource('QCC_Platform_Event_Switch__c', 'QCCTestDataPlatformEventSwitch');
        insert platformEventSwitchRecords;
    }
    
    /**
    * 	Test for Quarterly Health Check Call
    */
    static testmethod void test1(){
        Test.startTest();
        QCC_TransformActionToObjectSchedulable batchJob = new QCC_TransformActionToObjectSchedulable(Label.QCC_Quarterly_ModuleName); 
        batchJob.execute(null);
        Test.stopTest();
    }
    
    /**
    * 	Test for No Flight Health Check
    */
    static testmethod void test2(){
        Test.startTest();
        QCC_TransformActionToObjectSchedulable batchJob = new QCC_TransformActionToObjectSchedulable(Label.QCC_NoFlight_ModuleName); 
        batchJob.execute(null);
        Test.stopTest();
    }
    
    /**
    * 	Test for Watchlist Expiring
    */
    static testmethod void test4(){
        Test.startTest();
        QCC_TransformActionToObjectSchedulable batchJob = new QCC_TransformActionToObjectSchedulable(Label.QCC_WatchlistExpiring_ModuleName);
        batchJob.execute(null);
        Test.stopTest();
    }
}