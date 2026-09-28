/*********************************************************************************
Name         : QCC_OpenAqireContactPageControllerTest
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 22 October 2019
Usages       : This class is used for the code coverage of the apex class below:
			   - QCC_OpenAqireContactPageController
Modified By : Venkata Suresh Kumar (TCS Team), 17-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method. Added Test.start and Test.Stop methods 
*********************************************************************************/
@isTest
public class QCC_OpenAqireContactPageControllerTest {
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
        contactRecord.QCC_Qantas_Status_Credits__c = 5000;
        contactRecord.QCC_Status_credits_till_next_Level__c = 5000;
        contactRecord.QCC_SMS_for_5000_Sent__c = false;
        contactRecord.QCC_SMS_for_7000_Sent__c = false;
        insert contactRecord;
    }
    
    static testmethod void test1(){
        Contact contactRecord = [SELECT Id, Frequent_Flyer_Number__c FROM Contact LIMIT 1];	
        //QCC_OpenAqireContactPageController testController = new QCC_OpenAqireContactPageController();
        //testController.openAqire();
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(contactRecord);		
        QCC_OpenAqireContactPageController testController = new QCC_OpenAqireContactPageController(sc);
        
        PageReference pageRef = Page.QCC_OpenAqireWithContactPage;
        pageRef.getParameters().put('paramFFNo', contactRecord.Frequent_Flyer_Number__c);
        Test.setCurrentPage(pageRef);
        
        testController.openAqire();
        Test.stopTest();
    }
}