/*********************************************************************************
Name         : QCC_SendQantasReportToSPSchedTest
Created By   : Francis Bagtas
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 23 August 2019
Usages       : This class is used for the code coverage of the apex class below:
- QCC_GenerateQatasHostReportSchedulable
- QCC_SendQantasReportToSharepointBatch

Modified By : Venkata Suresh Kumar (TCS Team), 19-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method.
*********************************************************************************/
@isTest
public class QCC_SendQantasReportToSPSchedTest {
    @testSetup
    static void setupTestData(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        List<Trigger_Status__c> customSettingList = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusCase', null, null, null, null);
        insert customSettingList;
        
        //Create test data for Flight Event object
        List<Trigger_Status__c> customSettingListQantasHost = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusQantasHost', null, null, null, null);
        insert customSettingListQantasHost;
        
        //Create test data for Account object
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        insert accountRecord;
        
        Integer recordCount = 10;
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
        
        List<QCC_First_Host__c> qantasHostRecord = new List<QCC_First_Host__c>();
        //Sydney
        for(Integer x = 0; x < recordCount; x++) {
            QCC_First_Host__c record = new QCC_First_Host__c();
            record.QCC_Departure_Local_Date__c = System.today().addDays(1);
            //record.QCC_Departure_Airport_Code__c = 'SYD';
            record.QCC_First_Host_Contact__c = contactList[x].Id;
            record.QCC_Flight_No__c = '0002';
            record.QCC_PNR__c = '000002';
            qantasHostRecord.add(record);
        }
        
        //Melbourne
        for(Integer x = 0; x < recordCount; x++) {
            QCC_First_Host__c record = new QCC_First_Host__c();
            record.QCC_Departure_Local_Date__c = System.today().addDays(1);
            //record.QCC_Departure_Airport_Code__c = 'MEL';
            record.QCC_First_Host_Contact__c = contactList[x].Id;
            record.QCC_Flight_No__c = '0001';
            record.QCC_PNR__c = '000002';
            qantasHostRecord.add(record);
        }
        
        insert qantasHostRecord;
    }
    
    /**
    *   Test for Batch Job
    */
    static testmethod void test1(){
        Test.startTest();
        //QCC_GenerateQatasHostReportSchedulable batchJob = new QCC_GenerateQatasHostReportSchedulable();
        QCC_SendQantasReportToSPSchedulable batchJob = new QCC_SendQantasReportToSPSchedulable(Label.QCC_SendHost_ModuleName);
        batchJob.execute(null);
        Test.stopTest();
    }
}