/*********************************************************************************
Name         : QCC_QantasHostTriggerHelperTest
Created By   : Rafael Escuadra
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : January 2, 2020
Usages       : This will handle the test class and code coverage of apex class below
-QCC_QantasHostTriggerHelper 

Modified By : Venkata Suresh Kumar (TCS Team), 19-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method. Added Test.start and Test.Stop methods 
*********************************************************************************/
@isTest
public class QCC_QantasHostTriggerHelperTest {
    @testsetup
    static void setupTestData(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        //Set Custom Settings for Trigger_Status__c Custom settings
        List<Trigger_Status__c> contactTriggerRecords = QCC_TestDataFactory.createRecordFromStaticResource('Trigger_Status__c', 'QCCTestDataTriggerStatusContact');
        insert contactTriggerRecords;
        List<Trigger_Status__c> customSettingList1 = QCC_TestDataFactory.createRecordFromStaticResource('Trigger_Status__c', 'QCCTestDataTriggerStatusQantasHost');
        insert customSettingList1;
        //Create custom setting for case trigger
        List<Trigger_Status__c> customSettingList2 = QCC_TestDataFactory.createRecordFromStaticResource('Trigger_Status__c', 'QCCTestDataTriggerStatusCase');
        insert customSettingList2;
        //Create test data for Account object
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        insert accountRecord;
        
        //Create test data for Contact object
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        contactRecord.RecordTypeId = contactRecordTypeId;
        contactRecord.QCC_Preferred_Contact_Channel__c = 'Email';
        contactRecord.QCC_Qantas_Host_Always_Call__c = false;
        contactRecord.Frequent_Flyer_Number__c = '0123456789';
        insert contactRecord;
        
        //Create test data for Airport object
        Airport_Code__c airportRecord = QCC_TestDataFactory.createAirportCodeTestData();
        
        insert airportRecord;
        
        //Create test data for Qantas Host (QCC_First_Host__c) object
        /**
        1. PNR*                     QCC_PNR__c
        2. Flight No                QCC_Flight_No__c
        3. Departure Port           QCC_Departure_Airport__c
        4. Departure Local Date     QCC_Departure_Local_Date__c   (Date) 
        5. Departure Local Time     QCC_Flight_Departure_Time__c (Time)
        **/
        List<QCC_First_Host__c> firstHostList = new List<QCC_First_Host__c>();
        Time timeNow = system.now().time();
        QCC_First_Host__c firstHostRecord1 = QCC_TestDataFactory.createFirstHostTestData(contactRecord.id, airportRecord.id);
        firstHostRecord1.QCC_PNR__c = 'ABCDEF';
        firstHostRecord1.QCC_Flight_No__c = '0123';
        //firstHostRecord1.QCC_Departure_Airport_Code__c = 'SYD';
        firstHostRecord1.QCC_Departure_Local_Date__c = date.parse('28/09/2019');
        firstHostRecord1.QCC_Flight_Departure_Time__c = timeNow;
        //firstHostRecord1.QCC_Online_Form_Submission_Date__c = System.now();
        firstHostList.add(firstHostRecord1);
        
        QCC_First_Host__c firstHostRecord2 = QCC_TestDataFactory.createFirstHostTestData(contactRecord.id, airportRecord.id);
        firstHostRecord2.QCC_PNR__c = 'ABCDEF';
        firstHostRecord2.QCC_Flight_No__c = '0123';
        //firstHostRecord2.QCC_Departure_Airport_Code__c = 'SYD';
        firstHostRecord2.QCC_Departure_Local_Date__c = date.parse('28/09/2019');
        firstHostRecord2.QCC_Flight_Departure_Time__c = timeNow;
        firstHostList.add(firstHostRecord2);
        
        QCC_First_Host__c firstHostRecord3 = QCC_TestDataFactory.createFirstHostTestData(contactRecord.id, airportRecord.id);
        firstHostRecord3.QCC_PNR__c = 'ABCDEF';
        firstHostRecord3.QCC_Flight_No__c = '0123';
        //firstHostRecord3.QCC_Departure_Airport_Code__c = 'SYD';
        firstHostRecord3.QCC_Departure_Local_Date__c = date.parse('28/09/2019');
        firstHostRecord3.QCC_Flight_Departure_Time__c = timeNow;
        
        try{
            insert firstHostRecord3; //1 data with similar QCC_PNR__c, QCC_Flight_No__c, QCC_Departure_Airport_Code__c, QCC_Departure_Local_Date__c, QCC_Flight_Departure_Time__c saved in object
            //insert data with duplicate
            insert firstHostList; //2 data with similar QCC_PNR__c, QCC_Flight_No__c, QCC_Departure_Airport_Code__c, QCC_Departure_Local_Date__c, QCC_Flight_Departure_Time__c
        }catch(Exception ex){
            System.debug('>>>Exception: '+ex);
        }
    }
    
    public static testMethod void checkQantasHostDuplicateTest()
    { 
        List<QCC_First_Host__c> firstHostRecords  = new List<QCC_First_Host__c>([SELECT id,QCC_First_Host_Contact__r.Name FROM QCC_First_Host__c]);
    }
    
    public static testMethod void sendOnlineFormSubmissionNotificationTest(){
        Test.startTest();
        Contact contactRec = [SELECT id from Contact LIMIT 1];
        contactRec.QCC_Preferred_Contact_Channel__c = 'SMS';
        update contactRec;
        
        QCC_First_Host__c qantasHostRec = [SELECT id FROM QCC_First_Host__c LIMIT 1];
        qantasHostRec.QCC_Online_Form_Submission_Date__c = System.now() - 1;
        qantasHostRec.QCC_Cabin__c = 'P';
        update qantasHostRec;
        Test.stopTest();
    }
    
    public static testMethod void sendSpaBookingStatusNotificationTest(){
        Test.startTest();
        Contact contactRec = [SELECT id from Contact LIMIT 1];
        contactRec.QCC_Preferred_Contact_Channel__c = 'Email';
        contactRec.QCC_Travel_Email__c = 'test@test.com';
        update contactRec;
        
        QCC_First_Host__c qantasHostRec = [SELECT id FROM QCC_First_Host__c LIMIT 1];
        qantasHostRec.QCC_Online_Form_Submission_Date__c = System.now() - 2;
        qantasHostRec.QCC_Spa_Booking_Status__c = 'Confirmed';
        qantasHostRec.QCC_Spa_Request_Outcome__c = 'Sending';
        update qantasHostRec;
        Test.stopTest();
    }
}