/*----------------------------------------------------------------------------------------------------------------------
    Author:        Ram Kolli
    Company:       TCS
    Description:   Test Class for CTIRouteController
    Date 	: 16-Mar-2021

Modified By : Venkata Suresh Kumar (TCS Team), 19-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method. Added Test.start and Test.Stop methods 
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class CTIRouteControllerTest {

    @TestSetup
    public static void insertContact(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        //Create test data for Account object
        List<account> accountList= new List<account>();
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord.RecordTypeId = accountRecordTypeId;
        accountList.add(accountRecord);
        Account accountRecord1 = QCC_TestDataFactory.createAccountTestData(1);
        accountRecord1.RecordTypeId = accountRecordTypeId;
        accountList.add(accountRecord1);
        insert accountList;
        
        //Create test data for Contact object
        List<Contact> contactRecords = new List<Contact>();
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountList[0].Id);
        contactRecord.RecordTypeId = contactRecordTypeId;
        contactRecord.Frequent_Flyer_Number__c = '000001';
        contactRecord.QCC_TECH_BusinessPhoneCountryCode__c = '+63';
        contactRecords.add(contactRecord);
        
        Contact secondcontact = QCC_TestDataFactory.createContactTestData(1, accountList[1].Id);
        secondcontact.RecordTypeId = contactRecordTypeId;
        secondcontact.Frequent_Flyer_Number__c = '000001';
        secondcontact.QCC_TECH_BusinessPhoneCountryCode__c = '+61';
        contactRecords.add(secondcontact);
        insert contactRecord;
    }
    
    static testMethod void invokecontact(){
        Test.startTest();
        CTIRouteController.getContact('000001');
        CTIRouteController.getContact('000001');
        Test.stopTest();
    }
}