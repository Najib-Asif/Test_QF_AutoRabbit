/*********************************************************************************
Name         : QCC_StartWorkResolveCaseControllerTest
Created By   : Lora Mae S. Dapulang
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 12 March 2020
Usages       : This class is used for the code coverage of the apex class below:
- QCC_StartWorkAndResolveCaseController

Modified By : Venkata Suresh Kumar (TCS Team), 19-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method.
*********************************************************************************/
@isTest
public class QCC_StartWorkResolveCaseControllerTest {    
    
    @testSetup
    static void setupTestData(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        List<Trigger_Status__c> caseCustomSettingList = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusCase', null, null, null, null);
        insert caseCustomSettingList;
        
        //Create test data for Account object
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        insert accountRecord;
        
        //Create test data for Contact object
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
        contactRecord.RecordTypeId = contactRecordTypeId;
        contactRecord.Frequent_Flyer_Number__c = '1234567891';
        insert contactRecord;
        
        //Create test data for Case object
        String caseEliteRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('QCC Elite Process').getRecordTypeId();
        String caseBaggageTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CCC Baggage').getRecordTypeId();
        List<Case> caseList = new List<Case>();        
        Case caseRec1 =  QCC_TestDataFactory.createCaseTestData(accountRecord.Id, contactRecord.Id);
        caseRec1.RecordTypeId = caseEliteRecordTypeId;
        caseList.add(caseRec1);
        
        Case caseRec2 =  QCC_TestDataFactory.createCaseTestData(accountRecord.Id, contactRecord.Id);
        caseRec2.RecordTypeId = caseEliteRecordTypeId;
        caseRec2.Status = 'Closed';
        caseRec2.Resolution_Method__c = 'Email';
        caseList.add(caseRec2);
        
        Case caseRec3 =  QCC_TestDataFactory.createCaseTestData(accountRecord.Id, contactRecord.Id);
        caseRec3.RecordTypeId = caseEliteRecordTypeId;
        caseRec3.Status = 'In Progress';
        caseList.add(caseRec3);
        
        Case caseRec4 =  QCC_TestDataFactory.createCaseTestData(accountRecord.Id, contactRecord.Id);
        caseRec4.RecordTypeId = caseBaggageTypeId;
        caseRec4.Status = 'New';
        caseList.add(caseRec4);
        insert caseList;
        
        //Set Custom Settings for Trigger_Status__c Custom settings
        List<Trigger_Status__c> customSettingTriggerStatusLists = QCC_TestDataFactory.createTriggerStatusData();
        insert customSettingTriggerStatusLists;
    }
    
    static TestMethod void testchangeNewCaseRecordStatus(){        
        Case caseRec = [SELECT Id, Status FROM Case WHERE Status = 'New' LIMIT 1];
        Test.startTest();
        QCC_StartWorkAndResolveCaseController.changeCaseRecordStatus(caseRec.Id);
        Test.stopTest();        
    }   
    
    static TestMethod void testchangeInProgressCaseRecordStatus(){        
        Case caseRec = [SELECT Id, Status, Resolution_Method__c FROM Case WHERE Status = 'In progress' AND Resolution_Method__c = NULL LIMIT 1];
        caseRec.Resolution_Method__c = 'Email';
        update caseRec;
        Test.startTest();
        QCC_StartWorkAndResolveCaseController.changeCaseRecordStatus(caseRec.Id);
        Test.stopTest();        
    }
    
    static TestMethod void testchangeCaseException(){       
        Case caseRec = [SELECT Id, Status FROM Case WHERE Status = 'In progress' AND Resolution_Method__c = NULL LIMIT 1];
        caseRec.ContactId = null;
        update caseRec;
        Test.startTest();
        QCC_StartWorkAndResolveCaseController.changeCaseRecordStatus(caseRec.Id);
        Test.stopTest();        
    }
    
    static TestMethod void testchangeCaseException1(){    
        Test.startTest();
        String caseBaggageTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CCC Baggage').getRecordTypeId();
        Case caseRec = [SELECT Id, Status FROM Case WHERE Status = 'New' AND RecordTypeId = :caseBaggageTypeId LIMIT 1];
        caseRec.Status ='closed';
        caseRec.Resolution_Method__c ='';
        caseRec.Baggage_Assessment_Outcome__c ='';
        update caseRec;
        QCC_StartWorkAndResolveCaseController.changeCaseRecordStatus(caseRec.Id);
        Test.stopTest();        
    }
}