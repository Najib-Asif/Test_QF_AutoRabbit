/*********************************************************************************
Name         : QCC_FlightEventCloseHeadsUpTest
Created By   : Rafael Escuadra
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 7 October 2019
Usages       : This will handle the test class and code coverage of apex class below
                - QCC_FlightEventCloseHeadsUpSchedulable
				- QCC_FlightEventCloseHeadsUpBatch
*********************************************************************************/
@isTest(seeAllData = false)
public class QCC_FlightEventCloseHeadsUpTest {
@testsetup
    static void setupTestData(){  
       //Create test data for Flight Event object
        List<Event__c> flightEventRecords = new List<Event__c>();
        List<Trigger_Status__c> customSettingList1 = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusFlightEvent', null, null, null, null);
        insert customSettingList1;
        
        String headsUpRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Heads Up').getRecordTypeId();
        Event__c flightEventRecord = QCC_TestDataFactory.createFlightEventTestData();
        flightEventRecord.Status__c = 'Open';
        flightEventRecord.IntDom__c =  'Domestic';
        flightEventRecord.RecordTypeId = headsUpRecordTypeId;
        flightEventRecord.ScheduledArrDateTime__c = '19/09/2019 12:25:00';
        flightEventRecords.add(flightEventRecord);
                
        insert flightEventRecords;
    }
    
    public static testMethod void test()
    { 
        String headsUpRecordTypeId = Schema.SObjectType.Event__c.getRecordTypeInfosByName().get('Heads Up').getRecordTypeId();
        List<Event__c> flightEventRecords =  new List<event__c>([SELECT Id, Status__c, ScheduledArrDateTime__c FROM Event__c WHERE RecordTypeId =:headsUpRecordTypeId AND Status__c != 'Closed' AND ScheduledArrDateTime__c != '']);
        System.debug('>>>flightEventRecords: '+flightEventRecords);
        
        Test.StartTest();
        QCC_FlightEventCloseHeadsUpSchedulable flightEventCloseHeadsUp= new QCC_FlightEventCloseHeadsUpSchedulable();
        String CRON_EXP = '0 0 * * * ?'; 
        System.schedule('QCC Flight Event Close Heads-Up events Test', CRON_EXP, flightEventCloseHeadsUp);
        flightEventCloseHeadsUp.execute(null);
       
        Test.stopTest();
      
        Event__c flightEventRecord =  [SELECT Id, Status__c, ScheduledArrDateTime__c FROM Event__c WHERE RecordTypeId =:headsUpRecordTypeId AND  ScheduledArrDateTime__c != ''];
        System.assertEquals('Closed', flightEventRecord.Status__c, 'Flight event should be closed after if scheduled arrival date time (ScheduledArrDateTime__c) is 5hrs prior.' );
        
    }
 
}