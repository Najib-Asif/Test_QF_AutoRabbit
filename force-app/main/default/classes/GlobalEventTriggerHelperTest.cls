/*--------------------------------------------------------------------------------------------------------------------------
Author:        Felix Nilam
Company:       Capgemini
Description:   Test class for GlobalEventTriggerHelper
************************************************************************************************
History
************************************************************************************************
11-Jul-2018     Felix Nilam      Created the test class
-----------------------------------------------------------------------------------------------------------------------------*/
@isTest
public class GlobalEventTriggerHelperTest {
    // setup test data
    @testSetup
    static void setup() {
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createGlobalEventTriggerSetting();
        insert lsttrgStatus;
        
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                               Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('Qantas CC Journey Manager').Id,
                               EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',Location__c='Sydney',
                               TimeZoneSidKey = 'Australia/Sydney'
                              );
        insert u1;
    }
    
    @isTest
    static void testUpdateAuditFieldsAirportEventType(){
        User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
        String airportEvents = 'Snowfall;High Winds;Volcano';
        Global_Event__c testEvent = new Global_Event__c();
        Id recTypeId = Schema.SObjectType.Global_Event__c.getRecordTypeInfosByName().get('Airport Event').getRecordTypeId();
        testEvent.Name = 'test global event';
        testEvent.Airport_Event_Type__c = airportEvents;
        testEvent.RecordTypeId = recTypeId;
        
        Test.startTest();
        System.runAs(u1){
            insert testEvent;
            
            testEvent = [SELECT Id, TECH_Airport_Event_Type__c FROM Global_Event__c WHERE Id =: testEvent.Id];
            // check that the airport event audit field is set
            System.assert(testEvent.TECH_Airport_Event_Type__c == airportEvents, 'TECH Airport Event Type set to the multi picklist value');
            
            testEvent.Airport_Event_Type__c = 'Snowfall';
            update testEvent;
        }
        Test.stopTest();
        
        testEvent = [SELECT Id, TECH_Airport_Event_Type__c FROM Global_Event__c WHERE Id =: testEvent.Id];
        // check that the airport event audit field is updated
        System.assert(testEvent.TECH_Airport_Event_Type__c == 'Snowfall', 'TECH Airport Event Type updated');
    }
    
    @isTest
    static void testUpdateAuditFieldsInflightEventType(){
        User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
        String inflightEvents = 'Baggage;Catering';
        Global_Event__c testEvent = new Global_Event__c();
        Id recTypeId = Schema.SObjectType.Global_Event__c.getRecordTypeInfosByName().get('Aircraft Rego').getRecordTypeId();
        testEvent.Name = 'test global event';
        testEvent.Inflight_Event_Type__c = inflightEvents;
        testEvent.RecordTypeId = recTypeId;
        
        Test.startTest();
        System.runAs(u1){
            insert testEvent;
            
            testEvent = [SELECT Id, TECH_Inflight_Event_Type__c FROM Global_Event__c WHERE Id =: testEvent.Id];
            // check that the inflight event audit field is set
            System.assert(testEvent.TECH_Inflight_Event_Type__c == inflightEvents, 'TECH Inflight Event Type set to the multi picklist value');
            
            testEvent.Inflight_Event_Type__c = 'Catering';
            update testEvent;
        }
        Test.stopTest();
        
        testEvent = [SELECT Id, TECH_Inflight_Event_Type__c FROM Global_Event__c WHERE Id =: testEvent.Id];
        // check that the inflight event audit field is updated
        System.assert(testEvent.TECH_Inflight_Event_Type__c == 'Catering', 'TECH Inflight Event Type updated');
    }
    
    @isTest
    static void testUpdateAuditFieldsUnchanged(){
        User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
        String airportEvents = 'Snowfall;High Winds;Volcano';
        Global_Event__c testEvent = new Global_Event__c();
        Id recTypeId = Schema.SObjectType.Global_Event__c.getRecordTypeInfosByName().get('Airport Event').getRecordTypeId();
        testEvent.Name = 'test global event';
        testEvent.Airport_Event_Type__c = airportEvents;
        testEvent.RecordTypeId = recTypeId;
        
        Test.startTest();
        System.runAs(u1){
            insert testEvent;
            
            testEvent = [SELECT Id, TECH_Airport_Event_Type__c FROM Global_Event__c WHERE Id =: testEvent.Id];
            // check that the airport event audit field is set
            System.assert(testEvent.TECH_Airport_Event_Type__c == airportEvents, 'TECH Airport Event Type set to the multi picklist value');
            
            testEvent.Name = 'test change';
            update testEvent;
        }
        Test.stopTest();
        
        testEvent = [SELECT Id, TECH_Airport_Event_Type__c FROM Global_Event__c WHERE Id =: testEvent.Id];
        // check that the airport event audit field is not updated
        System.assert(testEvent.TECH_Airport_Event_Type__c == airportEvents, 'TECH Airport Event Type not updated');
    }
    
    @isTest
    static void testUpdateAuditFieldsBulk(){
        User u1 = [Select Username from User where Username = 'sampleuser1username@sample.com'];
        String inflightEvents = 'Baggage;Catering';
        Id recTypeId = Schema.SObjectType.Global_Event__c.getRecordTypeInfosByName().get('Aircraft Rego').getRecordTypeId();
        
        Test.startTest();
        System.runAs(u1){
            List<Global_Event__c> testEvents = new List<Global_Event__c>();
            
            for(Integer i = 0; i < 200; i++) {
                Global_Event__c testEvent = new Global_Event__c();
                testEvent.Name = 'test global event';
                testEvent.Inflight_Event_Type__c = inflightEvents;
                testEvent.RecordTypeId = recTypeId;
                testEvents.add(testEvent);
            }
            
            insert testEvents;
        }
        Test.stopTest();
        
        // check inflight event type text version
        List<Global_Event__c> testRes = [SELECT Id, TECH_Inflight_Event_Type__c FROM Global_Event__c Where TECH_Inflight_Event_Type__c =: inflightEvents];
        System.assert(testRes.size() == 200, 'TECH Inflight Event Type updated for 200 records');
    }
}