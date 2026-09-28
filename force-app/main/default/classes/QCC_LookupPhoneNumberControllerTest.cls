/*----------------------------------------------------------------------------------------------------------------------
Author:        Sherin Yohannan
Company:       Accenture
Description:   Test class for QCC_LookupPhoneNumberControllerTest
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************

-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QCC_LookupPhoneNumberControllerTest {
    @testSetup
    static void createData() {
        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;
        
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;
        
        //Set Custom Settings for Trigger_Status__c Custom settings
        List<Trigger_Status__c> customSettingTriggerStatusLists = QCC_TestDataFactory.createTriggerStatusData();
        insert customSettingTriggerStatusLists;
        
        String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        Account acc = QCC_TestDataFactory.createAccountTestData(1);
        acc.RecordTypeId = accountRecordTypeId;
        insert acc;
        
        String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
        Contact con = QCC_TestDataFactory.createContactTestData(1, acc.Id);
        con.RecordTypeId = contactRecordTypeId;
        con.Phone = String.valueOf(1234123412);
        con.Frequent_Flyer_Number__c = '6142207';
        con.Frequent_Flyer_Tier__c = 'Platinum One';
        con.QCC_Qantas_Host_Always_Call__c = false;
        insert con;
        Contact con1 = [select Id,Phone from contact];
        system.debug('the contact  and acoount created'+ con1);
    }
    
    static testMethod void testLookupCustomerPositive() {
        QCC_LookupPhoneNumberController.CustomerWrapper cw = new QCC_LookupPhoneNumberController.CustomerWrapper();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        List<String> str = QCC_LookupPhoneNumberController.lookupCustomer('6142207','','');
        system.debug('from lookuptester'+str);
        //CRM-6427: CIP Decommissioning
        //cw = (QCC_LookupPhoneNumberController.CustomerWrapper)JSON.deserialize(str[0], QCC_LookupPhoneNumberController.CustomerWrapper.Class);
        Test.stopTest();
        //System.assertEquals('Chairmanslounge', cw.lastName);
    }
    
    static testMethod void testLookupCustomerPhoneNumber() {
        QCC_LookupPhoneNumberController.CustomerWrapper cw = new QCC_LookupPhoneNumberController.CustomerWrapper();
        Test.startTest();
        List<String> str = QCC_LookupPhoneNumberController.lookupCustomer('','1234123412','');
        Test.stopTest();
        System.assertEquals(1, str.size());
    }
    
    static testMethod void testLookupCustomerException() {
        QCC_LookupPhoneNumberController.CustomerWrapper cw = new QCC_LookupPhoneNumberController.CustomerWrapper();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CalloutExceptionMock());
        List<String> str = QCC_LookupPhoneNumberController.lookupCustomer('0006142212','','');
        Test.stopTest();
        System.assertEquals(null, str);
        
    }
}