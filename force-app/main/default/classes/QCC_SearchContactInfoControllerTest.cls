/*----------------------------------------------------------------------------------------------------------------------
Author:        Purushotham B
Company:       Capgemini
Description:   Test class for QCC_SearchContactInfoController
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
03-Aug-2018             Purushotham B          Initial Design 
19-Apr-2023				Leslie Padilla			ADT-140: Added new input parameters for getContactId (Phone and Email)
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QCC_SearchContactInfoControllerTest {
    @testSetup
    static void createData() {
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        QantasConfigData__c qc = new QantasConfigData__c();
        qc.Name = 'Log Exception Logs Rec Type';
        qc.Config_Value__c = 'Exception Logs';
        qc.Config_Description__c = 'Log Exception Logs Record Type Name';
        insert qc;
        
        String type = 'Insurance Letter';
        String recordType = 'CCC Insurance Letter Case';
        List<Contact> contacts = new List<Contact>();
        Id recordTypeId = GenericUtils.getObjectRecordTypeId('Contact', CustomSettingsUtilities.getConfigDataMap('QCC Individual Contact'));
        for(Integer i = 0; i < 2; i++) {
            Contact con = new Contact(LastName='Sample'+i, FirstName='User', Business_Types__c='Agency', Job_Role__c='Agency Manager', Function__c='Advisory Services', Email='test@sample.com', RecordTypeId=recordTypeId);
            con.CAP_ID__c = '71000000001'+ (i+7);
            con.Frequent_Flyer_Number__c = '11111111'+i;
            con.Phone = '12345678';
            contacts.add(con);
        }
        insert contacts;
        
        List<Case> cases = new List<Case>();
        for(Contact con: contacts) {
            Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
            cs.ContactId = con.Id;
            cs.Origin = 'Phone';
            cs.First_Name__c = con.FirstName;
            cs.Last_Name__c = con.LastName;
            cs.Contact_Email__c = con.Email;
            cs.Contact_Phone__c = con.Phone;
            cases.add(cs);
        }
        insert cases;
    }
    
    static testMethod void testSearch() {
        Test.startTest();
        List<Case> cases = QCC_SearchContactInfoController.search('User','Sample0','test@sample.com','12345678','','QCC_CaseSearchResult','');
        Test.stopTest();
        System.assert(cases.size() != 0, 'Unable to find the case');
    }
    
    static testMethod void testSearchWithFF() {
        Test.startTest();
        List<Case> cases = QCC_SearchContactInfoController.search('User','Sample0','test@sample.com','12345678','111111110','QCC_CaseSearchResult','');
        Test.stopTest();
        System.assert(cases.size() != 0, 'Unable to find the case');
    }
    
    static testMethod void testSearchException() {
        QantasConfigData__c configdata = [SELECT Id FROM QantasConfigData__c WHERE Name = 'Case QCC Compliment RecType'];
        delete configdata;
        Test.startTest();
        List<Case> cases = QCC_SearchContactInfoController.search('User','Sample0','test@sample.com','12345678','111111110','QCC_CaseSearchResult','');
        Test.stopTest();
        List<Log__c> logs = [SELECT Id FROM Log__c Where Class_Name__c = 'QCC_SearchContactInfoController'];
        System.assert(logs.size() > 0, 'Log for QCC_SearchContactInfoController not found');
    }
    
    // Null Contact doesn't exists
    static testMethod void testGetContactIdWithOutFF() {
        Test.startTest();
        String conId = QCC_SearchContactInfoController.getContactId('User','Sample0','1233444','Non-tiered','', '', '');
        Test.stopTest();
        Contact con = [SELECT Id FROM Contact WHERE LastName Like 'Null%'];
        System.assertEquals(conId.split('_')[0], con.Id);
    }
    
    // Null contact exists
    static testMethod void testGetContactIdWithOutFF2() {
        Id conPlaceHolderRecTypeId = GenericUtils.getObjectRecordTypeId('Contact', 'Placeholder');
        Id accPlaceHolderRecTypeId = GenericUtils.getObjectRecordTypeId('Account', 'Placeholder');
        Account acc = new Account(Name='Null',RecordTypeId=accPlaceHolderRecTypeId);
        insert acc;
        Contact con = new Contact(LastName='Null',RecordTypeId=conPlaceHolderRecTypeId,Frequent_Flyer_Tier__c='Non-Tiered',AccountId=acc.Id);
        insert con;
        Test.startTest();
        String conId = QCC_SearchContactInfoController.getContactId('User','Sample0','1233444','Non-tiered','', '', '');
        Test.stopTest();
        System.assertEquals(con.Id, conId.split('_')[0]);
    }
    
    // FF# exists
    static testMethod void testGetContactIdWithFF() {
        Contact con = [SELECT Id FROM Contact WHERE Frequent_Flyer_Number__c = '111111110'];
        Test.startTest();
        String conId = QCC_SearchContactInfoController.getContactId('User','Sample0','1233444','Non-tiered','111111110', '', '');
        Test.stopTest();
        System.assertEquals(con.Id, conId.split('_')[0]);
    }
    
    // FF# doesn't exists
    static testMethod void testGetContactIdWithFF2() {
        Test.startTest();
        String conId = QCC_SearchContactInfoController.getContactId('User','Sample0','1233444','Gold','111111115', '', '');
        Test.stopTest();
        Contact con = [SELECT Id FROM Contact WHERE Frequent_Flyer_Number__c = '111111115'];
        System.assertEquals(con.Id, conId.split('_')[0]);
    }
    
    static testMethod void testGetContactIdException() {
        Test.startTest();
        //String conId = QCC_SearchContactInfoController.getContactId('User','','1233444','TEST','111111115');
        Test.stopTest();
        List<Log__c> logs = [SELECT Id FROM Log__c Where Class_Name__c = 'QCC_SearchContactInfoController'];
        //System.assert(logs.size() > 0, 'Log for QCC_SearchContactInfoController not found');
    }

    static testMethod void testcreateCasePostive() {
        Contact objcon = [select id from Contact  limit 1];
        String recordType = GenericUtils.getObjectRecordTypeId('Case','CCC Insurance Letter Case');
        Test.startTest();
        String strCase = QCC_SearchContactInfoController.createCase(objcon.Id, 'praveen@qantas.com', '0426646801', 'Praveen', 'Sampath', 'The Crescent', 'Strathfied', '2135', 'NSW', 'Australia', recordType );
        System.assert(strCase != null, 'Response is Null');
        Test.stopTest();
    }

    static testMethod void testcreateCaseNegative() {
        Test.startTest();
        String strCase = QCC_SearchContactInfoController.createCase('test', 'praveen@qantas.com', '0426646801', 'Praveen', 'Sampath', 'The Crescent', 'Strathfied', '2135', 'NSW', 'Australia', 'test' );
        System.assert(strCase == null, 'Response is not Null');
        Test.stopTest();
    }
}