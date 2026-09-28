/*********************************************************************************
Name         : QCC_SurveyResponseTriggerHelperTest
Created By   : Rafael Escuadra
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 12 December 2019
Usages       : This class is used for the code coverage of the apex class below:
- QCC_SurveyResponseTriggerHelper

Modified By : Venkata Suresh Kumar (TCS Team), 19-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method.
*********************************************************************************/
@isTest
public class QCC_SurveyResponseTriggerHelperTest{
    @testSetUp
    public static void setupTestData(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        List<Trigger_Status__c> customSettingList = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusSurveyResponse', null, null, null, null);
        insert customSettingList;
        List<Trigger_Status__c> caseCustomSettingList = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusCase', null, null, null, null);
        insert caseCustomSettingList;
        
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
        contactRecord.Frequent_Flyer_Number__c = '1234567890';
        contactRecord.Frequent_Flyer_Tier__c = 'Platinum One';
        insert contactRecord;
    }
    
    static testmethod void createCaseFromSurveyResponseTest(){
        test.startTest();
        Id objectRecordTypeId = Schema.SObjectType.CASE.getRecordTypeInfosByDeveloperName().get('CCC_Complaints').getRecordTypeId();
        Survey_Response__c SurveyResponseRecord = new Survey_Response__c();
        SurveyResponseRecord.QCC_Arrival_Port__c = 'Sydney';
        SurveyResponseRecord.QCC_Departure_Airport__c = 'Singapore';
        SurveyResponseRecord.QCC_Cabin_Class__c = 'J';
        SurveyResponseRecord.QCC_Contact_Method__c = 'Email';
        SurveyResponseRecord.QCC_Flight_Number__c = '0003';
        Date departureDate = Date.today() + 3;
        SurveyResponseRecord.QCC_Departure_Date__c = departureDate;
        SurveyResponseRecord.QCC_Frequent_Flyer_Number__c =  '1234567890';
        SurveyResponseRecord.QCC_Survey_Type__c = 'Qantas INT Ops CX Survey';
        SurveyResponseRecord.QCC_Crew_CSAT_Score__c = 1;
        SurveyResponseRecord.QCC_Customer_Service_Feedback__c = 'testing createCaseFromSurveyResponseTest ';
        SurveyResponseRecord.QCC_Post_Flight_Score__c= 5;
        SurveyResponseRecord.QCC_Delay_CSAT_Score__c = 5;
        
        insert SurveyResponseRecord;
        test.stopTest();
        
        //check if Case record was created
        Case caseRecord = [SELECT 
                           Arrival_Airport__c,
                           Frequent_Flyer_Number__c, 
                           recordType.DeveloperName,
                           Subject,
                           OwnerName__c
                           FROM Case LIMIT 1];
        
        System.assertEquals('Sydney',caseRecord.Arrival_Airport__c ,  'Arrival_Airport__c should be same with survey response record');
        System.assertEquals('1234567890', caseRecord.Frequent_Flyer_Number__c, 'Frequent_Flyer_Number__c should be same with survey response record');
        System.assertEquals('CCC_Complaints', caseRecord.RecordType.DeveloperName, 'Record Type should be CCC_Complaints');
        //System.assertEquals('QANTAS_VIP_Post_Travel_Queue', caseRecord.OwnerName__c, 'Case record should belong to QANTAS_VIP_Post_Travel_Queue');
    }
}