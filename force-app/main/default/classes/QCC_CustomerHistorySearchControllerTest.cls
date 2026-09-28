/*********************************************************************************
Name         : QCC_TransformActionToObjectScheduleTest
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 14 August 2019
Usages       : This class is used for the code coverage of the apex class below:
			   - QCC_CustomerHistorySearchController

Modified By : Venkata Suresh Kumar (TCS Team), 17-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method. Added Test.start and Test.Stop methods 
*********************************************************************************/
@isTest
public class QCC_CustomerHistorySearchControllerTest {
    static String searchKey = 'Test Class';
    
	@testSetup
    static void setupTestData(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
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
        contactRecord.Frequent_Flyer_Number__c = '000001';
        contactRecord.Frequent_Flyer_Tier__c = 'Platinum One';
        contactRecord.Status_Credits__c = 2024;
        insert contactRecord;
        
        //Create custom setting for case trigger
        List<Trigger_Status__c> customSettingList = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusCase', null, null, null, null);
        insert customSettingList;

        //Create test data for Case object
        Integer recordCount = 10;
        List<Case> caseRecords = new List<Case>();
        String caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('QCC Elite Process').getRecordTypeId();
        for (Integer x = 0; x <= recordCount; x++) {
            Case caseRecord = QCC_TestDataFactory.createCaseTestData(accountRecord.Id, contactRecord.Id);
            caseRecord.RecordTypeId = caseRecordTypeId;
            caseRecord.Subject = searchKey;
            caseRecords.add(caseRecord);
        }
        insert caseRecords;
    }
    
    /**
    * 	Test for initial search
    */
    static testmethod void test1(){
        Test.startTest();
        Contact contactRecord = [SELECT Id FROM Contact WHERE Frequent_Flyer_Number__c = '000001' LIMIT 1];
        List<QCC_CustomerHistorySearchController.DataTableWrapper> wrapperList = QCC_CustomerHistorySearchController.generateCustomerHistoryTables(searchKey, contactRecord.Id);
    	Test.stopTest();
    }
    
    /**
    * 	Test for load more
    */
    static testmethod void test2(){
        Test.startTest();
        Contact contactRecord = [SELECT Id FROM Contact WHERE Frequent_Flyer_Number__c = '000001' LIMIT 1];
        List<sObject> recordList = QCC_CustomerHistorySearchController.generateCustomerHistoryPerPage(searchKey, contactRecord.Id, 1, 'Case');
    	Test.stopTest();
    }
}