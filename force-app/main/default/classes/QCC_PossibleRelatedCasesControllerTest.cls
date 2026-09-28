/*----------------------------------------------------------------------------------------------------------------------
Author:        Purushotham B
Company:       Capgemini
Description:   Test class for QCC_PossibleRelatedCasesController
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
06-Aug-2018             Purushotham B          Initial Design 
-----------------------------------------------------------------------------------------------------------------------*/
@isTest
public class QCC_PossibleRelatedCasesControllerTest {
	static testMethod void test() {
        Test.startTest();
        String str = QCC_PossibleRelatedCasesController.getColumns('QCC_PossibleRelatedCases');
        Test.stopTest();
        System.assert(str != null, 'No columns defined in "QCC Data Table" custom metadata for QCC_PossibleRelatedCases LC');
        List<QCC_CaseSearchResultController.displayColumn> columns = (List<QCC_CaseSearchResultController.displayColumn>)JSON.deserialize(str, List<QCC_CaseSearchResultController.displayColumn>.Class);
        System.assert(columns.size() != 0);
    }
    
    static testMethod void testSearch() {
        TestUtilityDataClassQantas.insertQantasConfigData();
        Test.startTest();
        List<Case> cases = QCC_PossibleRelatedCasesController.search('User','Sample0','test@sample.com','12345678','');
        Test.stopTest();
        System.assert(cases.size() == 0, 'Found cases');
    }
    
    static testMethod void testSearchWithExistingCases() {
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.insertQantasConfigData();
        Map<String, Profile> profMap = TestUtilityDataClassQantas.getProfileMap();
        User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com', 
                           Username = 'sampleuser1username@sample.com', ProfileId = profMap.get('System Administrator').Id,
                           EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
                           TimeZoneSidKey = 'Australia/Sydney', City='Manila', location__c = 'Manila'
                          );
        
        Id conPlaceHolderRecTypeId = GenericUtils.getObjectRecordTypeId('Contact', 'Placeholder');
        Id accPlaceHolderRecTypeId = GenericUtils.getObjectRecordTypeId('Account', 'Placeholder');
        Account acc = new Account(Name='Null',RecordTypeId=accPlaceHolderRecTypeId);
        insert acc;
        Contact con = new Contact(LastName='Null',RecordTypeId=conPlaceHolderRecTypeId,Frequent_Flyer_Tier__c='Non-Tiered',AccountId=acc.Id);
        insert con;
        System.runAs(u1) {
            String type = 'Insurance Letter';
            String recordType = 'CCC Insurance Letter Case';
            List<Case> caseList = new List<Case>();
            Case cs = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
            cs.ContactId = con.Id;
            cs.Origin = 'Phone';
            cs.First_Name__c = 'TestFN';
            cs.Last_Name__c = 'TestLN';
            cs.Contact_Email__c = 'test@test.com';
            cs.Contact_Phone__c = '12345678';
            caseList.add(cs);
            
            Case cs2 = TestUtilityDataClassQantas.createCaseWithCodingValues(recordType, type, 'Proof of Boarding or No Show','','','');
            cs2.ContactId = con.Id;
            cs2.Origin = 'Phone';
            cs2.First_Name__c = 'TestFN';
            cs2.Last_Name__c = 'TestLN';
            cs2.Contact_Email__c = 'test@test.com';
            cs2.Contact_Phone__c = '12345678';
            caseList.add(cs2);
            insert caseList;
        
            Test.startTest();
            List<Case> cases = QCC_PossibleRelatedCasesController.search('TestFN','TestLN','test@test.com','12345678',caseList[0].Id);
            Test.stopTest();
                
            System.assert(cases.size() == 1, 'Found more than one case');
        }
    }
}