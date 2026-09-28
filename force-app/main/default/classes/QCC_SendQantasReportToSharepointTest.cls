/*********************************************************************************
Name         : QCC_SendQantasReportToSharepointTest
Created By   : Francis Bagtas
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : January 2, 2020
Usages       : This will handle the test class and code coverage of apex class below
-QCC_SendQantasHostReportToSharepointBatch

Modified By : Venkata Suresh Kumar (TCS Team), 19-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method. Added Test.start and Test.Stop methods
*********************************************************************************/
@isTest
public class QCC_SendQantasReportToSharepointTest {
    @testSetup
    static void setupTestData(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
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
        List<QCC_Platform_Event_Switch__c> platformEventSwitchList = QCC_TestDataFactory.createPlatformEventSwitchData();
        insert platformEventSwitchList;
        
        //Create test data for Account object
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        insert accountRecord;
        
        //Create test data for Contact object
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        contactRecord.RecordTypeId = contactRecordTypeId;
        
        insert contactRecord;
        
        //Create test data for Airport object
        List<Airport_Code__c> airportCodes = QCC_TestDataFactory.createRecordFromStaticResource('Airport_Code__c', 'QCCTestDataAirportCodes');
        insert airportCodes;
        Map<String,Id> airportCodesMap = new Map<String,Id>();
        for (Airport_Code__c airport : airportCodes) {
            airportCodesMap.put(airport.Name, airport.Id);
        }
        system.debug('>>>airportCodesMap: ' + airportCodesMap);
        
        Airport_Code__c airportRecord = new Airport_Code__c(
            Name = 'MEL');
        
        insert airportRecord;
        
        //Create test data for Qantas Host (QCC_First_Host__c) object
        List<QCC_First_Host__c> firstHostList = new List<QCC_First_Host__c>();
        Time timeNow = system.now().time();
        Id individualContactRecordTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));   
        
        QCC_First_Host__c firstHostRecord1 = QCC_TestDataFactory.createFirstHostTestData(contactRecord.Id, airportCodesMap.get('MEL'));
        firstHostRecord1.QCC_PNR__c = 'MEUBMG';
        firstHostRecord1.QCC_Flight_No__c = '0037';
        firstHostRecord1.QCC_Departure_Local_Date__c = Date.today() + 1;
        firstHostRecord1.QCC_Flight_Departure_Time__c = timeNow;
        firstHostRecord1.QCC_Frequent_Flyer_Number__c = '1947727507';
        firstHostRecord1.QCC_Qantas_Porter_Service__c= True;
        firstHostList.add(firstHostRecord1);
        
        QCC_First_Host__c firstHostRecord2 = QCC_TestDataFactory.createFirstHostTestData(contactRecord.Id, airportCodesMap.get('SYD'));
        firstHostRecord2.QCC_PNR__c = 'MEUBMG';
        firstHostRecord2.QCC_Flight_No__c = '0001';
        firstHostRecord2.QCC_Departure_Local_Date__c = Date.today() + 1;
        firstHostRecord2.QCC_Flight_Departure_Time__c = timeNow;
        firstHostRecord2.QCC_Frequent_Flyer_Number__c = '1947727508';
        firstHostRecord2.QCC_Qantas_Porter_Service__c= True;
        firstHostList.add(firstHostRecord2);
        
        
        insert firstHostList; 
        system.debug('>>>firstHostList: ' + firstHostList);
        
        //Create test data for Flight Event object
        List<Trigger_Status__c> customSettingList1 = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusFlightEvent', null, null, null, null);
        insert customSettingList1;
        
        String flightActiveRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Flight Event - Active').getRecordTypeId();
        //Arrival Time for flight delay
        DateTime schedArrivalDateTimeRed = System.now().addHours(Integer.valueOf(Label.QCC_DisruptionWarningRedFlightDelay));
        String schedArrivalDateTimeDelay = schedArrivalDateTimeRed.format('dd/MM/yyyy HH:MM:ss');
        String schedDepartureDateTimeForDelay = System.now().format('yyyy-MM-dd');
        system.debug('>>>schedArrivalDateTimeDelay: ' + schedArrivalDateTimeDelay);
        
        Event__c flightEventActive = QCC_TestDataFactory.createFlightEventTestData();
        flightEventActive.Name = 'Sample Active Event';
        flightEventActive.RecordTypeId = flightActiveRecordTypeId;
        flightEventActive.Scheduled_Arrival_UTC__c = System.now();
        flightEventActive.Scheduled_Departure_Date_Time__c = schedDepartureDateTimeForDelay;
        flightEventActive.Scheduled_Depature_UTC__c = System.now();
        flightEventActive.ScheduledArrDateTime__c = schedArrivalDateTimeDelay;
        flightEventActive.ScheduledDepDate__c = Date.valueOf(schedDepartureDateTimeForDelay);
        flightEventActive.ScheduledDepTime__c = '08:00';
        flightEventActive.IntDom__c = 'International';
        flightEventActive.Status__c = 'Open';
        flightEventActive.DelayFailureCode__c = 'Flight Delay';
        insert flightEventActive;
        
        //Create test data for Passenger object
        List<Trigger_Status__c> customSettingList2 = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusPassenger', null, null, null, null);
        insert customSettingList2;
        
        //Passenger record for 000001 on Flight Delay NOT Actioned
        Affected_Passenger__c passengerRecord = QCC_TestDataFactory.createPassengerTestData(flightEventActive.Id, contactRecord.Id);
        passengerRecord.QCC_Disruption_Actioned__c = false;
        insert passengerRecord;
    }
    
    @isTest
    static void exceptionCheck(){
        List<QCC_First_Host__c> qantasHosts = new List<QCC_First_Host__c>([SELECT QCC_First_Host_Contact__c,QCC_First_Host_First_Name__c,QCC_Contact_Lastname__c,QCC_Departure_Airport__c,QCC_First_Host_Contact__r.SSU__c,QCC_Flight_No__c,tolabel(QCC_Cabin__c),QCC_Class_of_Service__c,QCC_Flight_Departure_Time__c,QCC_Qantas_Porter_Service__c,QCC_Expected_Arrival_Time__c,QCC_Number_of_Bags__c,QCC_Other_Details__c,QCC_Qantas_First_Spa_Lounge__c,QCC_Spa_Booking_Time__c,QCC_Spa_Booking_Status__c,QCC_Additional_Comments__c FROM QCC_First_Host__c]);
        system.debug('>>>exceptionCheck - qantasHosts: ' + qantasHosts);
        Test.startTest();
        
        QCC_SOQL_Setting__mdt customMetadataRecord = [SELECT Id, Query_String__c, Module_Name__c, Target_Object__c, Target_Record_Type__c, Batch_Size__c, Filter_Condition__c FROM QCC_SOQL_Setting__mdt WHERE Module_Name__c = 'Send Qantas Host Report' LIMIT 1];
        QCC_SendQantasReportToSharepointBatch batchObj = new QCC_SendQantasReportToSharepointBatch(
            customMetadataRecord.Target_Object__c,
            customMetadataRecord.Query_String__c,
            customMetadataRecord.Module_Name__c,
            null
        );
        DataBase.executeBatch(batchObj);
        
        Test.stopTest();
    }
}