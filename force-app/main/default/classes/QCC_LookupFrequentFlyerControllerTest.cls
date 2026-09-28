/*----------------------------------------------------------------------------------------------------------------------
Author:        Purushotham B
Company:       Capgemini
Description:   Test class for  QCC_LookupFrequentFlyerController
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
03-Aug-2018             Purushotham B          Initial Design 
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QCC_LookupFrequentFlyerControllerTest {
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
    }
    
    static testMethod void testLookupCustomerPositive() {
        QCC_LookupFrequentFlyerController.CustomerWrapper cw = new QCC_LookupFrequentFlyerController.CustomerWrapper();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        String str = QCC_LookupFrequentFlyerController.lookupCustomer('0006142207','','');
        //CRM-6427: CIP Decommissioning
        if(String.isNotBlank(str)){
            cw = (QCC_LookupFrequentFlyerController.CustomerWrapper)JSON.deserialize(str, QCC_LookupFrequentFlyerController.CustomerWrapper.Class);
        }
        //cw = (QCC_LookupFrequentFlyerController.CustomerWrapper)JSON.deserialize(str, QCC_LookupFrequentFlyerController.CustomerWrapper.Class);
       
        Test.stopTest();
        //System.assertEquals('Chairmanslounge', cw.lastName);
    }
    
    static testMethod void testLookupCustomerNegative() {
        QCC_LookupFrequentFlyerController.CustomerWrapper cw = new QCC_LookupFrequentFlyerController.CustomerWrapper();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CAPServicesMock());
        String str = QCC_LookupFrequentFlyerController.lookupCustomer('0006142207','FrequentFlyer','');
        Test.stopTest();
        //System.assertEquals('NameMismatch', str);
    }
    
    static testMethod void testLookupCustomerException() {
        QCC_LookupFrequentFlyerController.CustomerWrapper cw = new QCC_LookupFrequentFlyerController.CustomerWrapper();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new QCC_CalloutExceptionMock());
        String str = QCC_LookupFrequentFlyerController.lookupCustomer('0006142212','FrequentFlyer','');
        Test.stopTest();
        System.assertEquals(null, str);
        List<Log__c> logs = [SELECT Id FROM Log__c Where Class_Name__c = 'QCC_LookupFrequentFlyerController'];
        System.assertEquals(1, logs.size(), 'Log for QCC_LookupFrequentFlyerController not found');
    }
}