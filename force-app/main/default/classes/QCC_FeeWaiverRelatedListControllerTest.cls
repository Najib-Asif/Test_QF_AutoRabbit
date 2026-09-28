/*********************************************************************************
Name         : QCC_FeeWaiverRelatedListControllerTest
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 4 November 2019
Usages       : This will handle the test class and code coverage of
				QCC_FeeWaiverRelatedListController APEX class
*********************************************************************************/
@isTest
public class QCC_FeeWaiverRelatedListControllerTest {
    @testSetup
    static void createData() {
        Test.startTest();  
         List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Account RecType1','Agency Account;Charter Account;Customer Account;Global Account;Other Account;Prospect Account;Regional Account;Person Account'));        
        insert lstConfigData;
        
		//Create test data for Account object
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        system.debug('accountRecordTypeId----'+accountRecordTypeId);
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        system.debug('accountRecord----'+accountRecord);
        accountRecord.RecordTypeId = accountRecordTypeId;
        insert accountRecord;
        
        //Create test data for Contact object
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        contactRecord.RecordTypeId = contactRecordTypeId;
        contactRecord.Frequent_Flyer_Number__c = '5395838';
        insert contactRecord;
        
        Contact contactRecord2 = QCC_TestDataFactory.createContactTestData(2, accountRecord.Id);
        contactRecord2.RecordTypeId = contactRecordTypeId;
        contactRecord2.Frequent_Flyer_Number__c = '6142208';
        insert contactRecord2;
        
        //Create test data for Qantas API object
        List<Qantas_API__c> qantasAPIRecords = QCC_TestDataFactory.createQantasAPITestDataList();
        insert qantasAPIRecords;
        Test.stopTest();
    }

    static testMethod void test1(){
        List<Qantas_API__c> qantasAPIs = [SELECT Id, LastModifiedDate FROM Qantas_API__c];
        System.debug('qantasAPIs: ' + qantasAPIs);
        Contact contact = [SELECT Id FROM Contact WHERE Frequent_Flyer_Number__c = '5395838'];
        
		String body1 = '{}';
		Map<String, String> mapHeader1 = new Map<String, String>();
		mapHeader1.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', body1, mapHeader1));
        
        Test.startTest();
        QCC_FeeWaiverRelatedListController.getAllFeeWaiverData(contact.Id);
        Test.stopTest();
    }

   static testMethod void test2() {
       
       Trigger_Status__c triggerStatus = new Trigger_Status__c();
        triggerStatus.Name = 'UseNamedCred';
        triggerStatus.Active__c = True;
        insert triggerStatus;
                
        String staticResourceName = 'QCCMockResponseInvokeFeeWaiverAPI';
    	StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = : staticResourceName LIMIT 1];
       system.debug('sr---' +sr);
    	String Body = sr.Body.toString();
		Map<String, String> mapHeader2= new Map<String, String>();
         mapHeader2.put('Content-Type', 'application/json');
        Contact contact = [SELECT Id FROM Contact WHERE Frequent_Flyer_Number__c = '6142208'];
		Test.startTest();
		Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(200, 'Success', Body, mapHeader2));
		QCC_FeeWaiverRelatedListController.getAllFeeWaiverData(contact.Id);
		Test.stopTest();
}
    
        static testMethod void test3(){
        String allNonFreightAccRecType = String.isBlank(CustomSettingsUtilities.getConfigDataMap('Account RecType1'))?'':CustomSettingsUtilities.getConfigDataMap('Account RecType1');
        system.debug('allNonFreightAccRecType++++++++'+allNonFreightAccRecType);
        List<Qantas_API__c> qantasAPIs = [SELECT Id, LastModifiedDate FROM Qantas_API__c];
        System.debug('qantasAPIs: ' + qantasAPIs);
        Contact contact = [SELECT Id FROM Contact WHERE Frequent_Flyer_Number__c = '5395838'];
        
        Test.startTest();
        QCC_FeeWaiverRelatedListController.getAllFeeWaiverData('0035D00001FqjdcQAC');
        Test.stopTest();
    }

}