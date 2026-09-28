/*********************************************************************************
Name         : QCC_RESTAPIInboundQantasHostTest
Created By   : Raymart Airon Tolentino
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 30 October 2019
Usages       : This will handle the test class and code coverage of
QCC_RESTAPIInboundQantasHost APEX class

Modified By : Venkata Suresh Kumar (TCS Team), 19-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method.
*********************************************************************************/
@isTest
public class QCC_RESTAPIInboundQantasHostTest {
    @testSetup
    static void createData() {
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
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        contactRecord.RecordTypeId = contactRecordTypeId;
        contactRecord.Frequent_Flyer_Number__c = '000001';
        insert contactRecord;
        
        //Create test data for Airport object
        Airport_Code__c airportRecord = QCC_TestDataFactory.createAirportCodeTestData();
        
        insert airportRecord;
        
        //Create test data for QCC_First_Host__c
        QCC_First_Host__c qantasHostRecord = QCC_TestDataFactory.createFirstHostTestData(contactRecord.Id, airportRecord.id);
        qantasHostRecord.QCC_Flight_No__c = '0001';
        qantasHostRecord.QCC_PNR__c = '123123';
        qantasHostRecord.QCC_Qantas_First_Spa_Lounge__c = true;
        qantasHostRecord.QCC_Qantas_Porter_Service__c = true;
        qantasHostRecord.QCC_Number_of_Bags__c = 5;
        qantasHostRecord.QCC_Other_Details__c = 'Sample';
        insert qantasHostRecord;
    }
    
    static testMethod void test1(){
        QCC_First_Host__c qantasHostRecord = [SELECT Id, QCC_Qantas_First_Spa_Lounge__c, QCC_Qantas_Porter_Service__c, QCC_Number_of_Bags__c, QCC_Other_Details__c FROM QCC_First_Host__c LIMIT 1];
        
        String recordString = '{"Id":"<Id>","QCC_Qantas_First_Spa_Lounge__c":"false","QCC_Qantas_Porter_Service__c":"false","QCC_Number_of_Bags__c":1,"QCC_Other_Details__c":"None"}';
        recordString = recordString.replace('<Id>', qantasHostRecord.Id);
        System.debug('recordString: ' + recordString);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/AccessQantasHost/';
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueof(recordString);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        QCC_RESTAPIInboundQantasHost.start();
        Test.stopTest();
    }
    
    static testMethod void test2(){
        QCC_First_Host__c qantasHostRecord = [SELECT Id, QCC_Qantas_First_Spa_Lounge__c, QCC_Qantas_Porter_Service__c, QCC_Number_of_Bags__c, QCC_Other_Details__c FROM QCC_First_Host__c LIMIT 1];
        
        String recordString = '{"Id":"<Id>","QCC_Qantas_First_Sa_Lounge__c":"false","QCC_Qantas_Porter_Service__c":"false","QCC_Number_of_Bags__c":1,"QCC_Other_Details__c":"None"}';
        recordString = recordString.replace('<Id>', qantasHostRecord.Id);
        System.debug('recordString: ' + recordString);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/AccessQantasHost/';
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueof(recordString);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        QCC_RESTAPIInboundQantasHost.start();
        Test.stopTest();
    }
}