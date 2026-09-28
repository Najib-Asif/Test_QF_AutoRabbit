/*********************************************************************************
Name         : QCC_PreDepartureEventTriggerHelperTest
Created By   : Francis Bagtas
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 11 Dec 2019
Usages       : This will handle the test class and code coverage of apex class below
                -QCC_PreDepartureEventTriggerHelper 

Modified By : Venkata Suresh Kumar (TCS Team), 18-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method.
*********************************************************************************/

@isTest
public class QCC_PreDepartureEventTriggerHelperTest {
	
    @testSetup
    static void setupTestData(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
       	List<Trigger_Status__c> triggerRecords = QCC_TestDataFactory.createRecordFromStaticResource('Trigger_Status__c', 'QCCTestDataTriggerStatusPlatformEvent');
       	insert triggerRecords;

       	List<Trigger_Status__c> triggerRecords2 = QCC_TestDataFactory.createRecordFromStaticResource('Trigger_Status__c', 'QCCTestDataTriggerStatusQantasHost');
		insert triggerRecords2;

        //Set Custom Settings for QantasConfigData__c custom settings
        List<QantasConfigData__c> customSettingRecordTypeLists = QCC_TestDataFactory.createRecordTypeConfigData();
        insert customSettingRecordTypeLists;

        //Create test data for Qantas_API__c custom settings
        List<Qantas_API__c> qantasAPIRecords = QCC_TestDataFactory.createQantasAPITestDataList();
        insert qantasAPIRecords;

        //Set Custom Settings for Platform Event Switch custom settings
        List<QCC_Platform_Event_Switch__c> platformEventSwitches = QCC_TestDataFactory.createRecordFromStaticResource('QCC_Platform_Event_Switch__c', 'QCCTestDataPlatformEventSwitch');
        insert platformEventSwitches;

        //Create test data for Account object
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        insert accountRecord;

        //Create test data for Contact object
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact contactRecord01 = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        contactRecord01.RecordTypeId = contactRecordTypeId;
        contactRecord01.Frequent_Flyer_Number__c = '1947727507';

        insert contactRecord01;

        Contact contactRecord02 = QCC_TestDataFactory.createContactTestData(2, accountRecord.Id);
        contactRecord02.RecordTypeId = contactRecordTypeId;
        contactRecord01.Frequent_Flyer_Number__c = '1900000001';

        insert contactRecord02;

        //Create test data for Contact Watchlist object
        QCC_Contact_Watchlist__c conWatchListRecord01 = QCC_TestDataFactory.createWatchlistTestData(1, contactRecord01.Id);
        conWatchListRecord01.QCC_Watchlist_End_Date__c = Date.today();
        conWatchListRecord01.QCC_Watchlist_Start_Date__c = Date.today();
        insert conWatchListRecord01;

        QCC_Contact_Watchlist__c conWatchListRecord02 = QCC_TestDataFactory.createWatchlistTestData(2, contactRecord02.Id);
        conWatchListRecord02.QCC_Watchlist_End_Date__c = Date.today();
        conWatchListRecord02.QCC_Watchlist_Start_Date__c = Date.today();
        insert conWatchListRecord02;

        //Create test data for Airport object
        Airport_Code__c airportRecord = new Airport_Code__c(
            Name = 'MEL');
        
        insert airportRecord;
        
        //Create test data for Qantas Host (QCC_First_Host__c) object
        List<QCC_First_Host__c> firstHostList = new List<QCC_First_Host__c>();
        Time timeNow = system.now().time();
        Id individualContactRecordTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));   
		
        QCC_First_Host__c firstHostRecord1 = QCC_TestDataFactory.createFirstHostTestData(contactRecord01.Id, airportRecord.Id);
        firstHostRecord1.QCC_PNR__c = 'MEUBMG';
        firstHostRecord1.QCC_Flight_No__c = '0037';
        firstHostRecord1.QCC_Departure_Local_Date__c = Date.valueOf('2019-09-26T00:43:35.000000050Z');
        firstHostRecord1.QCC_Flight_Departure_Time__c = timeNow;
        firstHostRecord1.QCC_Frequent_Flyer_Number__c = '1947727507';
        firstHostList.add(firstHostRecord1);
        
        QCC_First_Host__c firstHostRecord2 = QCC_TestDataFactory.createFirstHostTestData(contactRecord02.Id, airportRecord.Id);
        firstHostRecord2.QCC_PNR__c = 'MEUBMG';
        firstHostRecord2.QCC_Flight_No__c = '0037';
        firstHostRecord2.QCC_Departure_Local_Date__c = Date.valueOf('2019-09-26T00:43:35.000000050Z');
        firstHostRecord2.QCC_Flight_Departure_Time__c = timeNow;
        firstHostList.add(firstHostRecord2);
        
        insert firstHostList; 
    }
    
    static testMethod void testMethod1() {
        Test.startTest();
        
        List<Database.SaveResult> publishedEvents = QCC_TestDataFactory.publishPlatformEvents('QCCTestDataPreDeparturePlatformEvent', 'QCC_Pre_Departure_Event__e');
        Test.getEventBus().deliver();
        
        Test.stopTest();
   	}
}