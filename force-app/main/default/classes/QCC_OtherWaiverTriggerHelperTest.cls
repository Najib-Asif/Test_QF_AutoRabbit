/*********************************************************************************
Name         : QCC_OtherWaiverTriggerHelperTest
Created By   : Rafael Escuadra
Company Name : Accenture
Project      : Pre-Travel, GRAPHITE
Created Date : 21 FEB 2020
Usages       : This class is used for the code coverage of the apex class QCC_OtherWaiverTriggerHelper

Modified By : Venkata Suresh Kumar (TCS Team), 18-Mar-2026
Desc : Remediated test class failures. Updated testSetUPMethod() method. Added Test.start and Test.Stop methods 
*********************************************************************************/
@isTest
public class QCC_OtherWaiverTriggerHelperTest {
    
 
    static QCC_Other_Waiver__c otherWaiver;
    
    @testSetUp
    public static void setupTestData(){
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType(); //Added as part of test class refactor CRM-11408
        List<Trigger_Status__c> customSettingTriggerStatusLists = QCC_TestDataFactory.createTriggerStatusData();
   		insert customSettingTriggerStatusLists;
        List<Trigger_Status__c> customSettingList = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusOtherWaiver', null, null, null, null);
        insert customSettingList;
        
        //create test data  for User object
        Profile qantasCcConsultantProfile = [Select Id, Name from Profile where Name = 'Qantas CC Consultant'];
       	User qantasCcConsultantUser = QCC_TestDataFactory.createUserTestData(qantasCcConsultantProfile.Id);
        qantasCcConsultantUser.username  = 'consultant@user.com';
        insert qantasCcConsultantUser;
        
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
        
        //Create test data for Other_Waiver__c object
        otherWaiver = QCC_TestDataFactory.createOtherWaiverTestData(qantasCcConsultantUser.Id, contactRecord.Id);
        otherWaiver.QCC_Status__c = 'Open';
        otherWaiver.QCC_Amount__c = 5000;
        otherWaiver.QCC_Reason__c = 'Delete Me';
        insert otherWaiver;
    }
    
    static testMethod void testDeleteOtherWaiver() {        
        //As Qantas Cc Consultant, you would not be able to delete QCC_Other_Waiver__c records.
        User qantasCcConsultantUser = [SELECT id FROM User WHERE Username = 'consultant@user.com'];
        Test.startTest();
        QCC_Other_Waiver__c otherWaiverRecord = [SELECT id FROM QCC_Other_Waiver__c WHERE QCC_Reason__c = 'Delete Me'];
        System.runAs(qantasCcConsultantUser){    
            try{
                Delete otherWaiverRecord;
            }catch(exception ex){
                System.assert(ex.getMessage().contains('User does not have the right access to delete this record'));
            }
        }
        
       	//deleting as administrator should be successful
        Delete otherWaiverRecord;
        List<QCC_Other_Waiver__c> OtherWaivers  = new List<QCC_Other_Waiver__c>([SELECT id FROM QCC_Other_Waiver__c WHERE QCC_Reason__c = 'Delete Me']);
		System.assertEquals(0,OtherWaivers.size(), 'No record should be retrieved since it will be successfully deleted by Admin');
        Test.stopTest();        
    }
}