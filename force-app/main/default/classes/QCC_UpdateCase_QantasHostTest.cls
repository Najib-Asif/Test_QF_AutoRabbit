/*********************************************************************************
Name         : QCC_UpdateCase_QantasHostTest
Created By   : Rafael Escuadra
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 28 August 2019
Usages       : This will handle the test class and code coverage of 
QCC_UpdateCase_QantasHost APEX class

Modified By : Venkata Suresh Kumar (TCS Team), 19-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method.
*********************************************************************************/
@isTest
public class QCC_UpdateCase_QantasHostTest {
    @testsetup
    static void setupTestData(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        //Create test data for Flight Event object
        List<Trigger_Status__c> customSettingListQantasHost = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusQantasHost', null, null, null, null);
        insert customSettingListQantasHost;
        
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
        
        insert contactRecord;
        
        //Create custom setting for case trigger
        List<Trigger_Status__c> customSettingList = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusCase', null, null, null, null);
        insert customSettingList;
        
        //Create test data for Airport object
        Airport_Code__c airportRecord = QCC_TestDataFactory.createAirportCodeTestData();
        
        insert airportRecord;
        
        Qcc_first_host__c firstHost = QCC_TestDataFactory.createFirstHostTestData(contactRecord.Id, airportRecord.id);
        insert firstHost;
        
        //get firsthost name as firstHost.name is not available upon insert
        Qcc_first_host__c newFirstHost = [SELECT name  FROM Qcc_first_host__c LIMIT 1];
        
        //Create test data for Case object
        List<Case> caseRecords = new List<Case>();
        String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CCC VIP Assistance').getRecordTypeId();
        
        Case caseRecord = QCC_TestDataFactory.createCaseTestData(accountRecord.Id, contactRecord.Id);
        caseRecord.RecordTypeId = caseRecordTypeId;
        caseRecord.Subject = 'Test Qantas Host';
        caseRecord.Description = 'Test from test class Ref#'+newFirstHost.Name;
        caseRecord.qantas_host__c = newFirstHost.Id;
        caseRecords.add(caseRecord);
        
        Case caseRecord2 = QCC_TestDataFactory.createCaseTestData(accountRecord.Id, contactRecord.Id);
        caseRecord2.RecordTypeId = caseRecordTypeId;
        caseRecord2.Subject = 'Test Qantas Host';
        caseRecord2.Description = 'Test from test class No Refernce Number';
        caseRecords.add(caseRecord2);
        System.debug(caseRecord2);
        
        insert caseRecords;
    }
    
    public static testMethod void testUpdateHostNumber()
    { 
        Test.startTest();
        List<Case>  caseRecords = [SELECT qantas_host__c, contactId, qantas_host__r.QCC_First_Host_Contact__c FROM Case WHERE qantas_host__c != null];
        Test.stopTest();
        
        System.assertEquals(1, caseRecords.size(), 'Only one record is expected to be inserted') ;
        for(Case caseRecord : caseRecords){
            System.assertEquals(caseRecord.qantas_host__r.QCC_First_Host_Contact__c , caseRecord.ContactId , 'case contact and host contact should be the same');
        }
    }
}