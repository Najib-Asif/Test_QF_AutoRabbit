@isTest
public class QCC_EscalateCaseToQueueTest {

	@testSetup
	static void createData() {
		Test.startTest();
        
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Account RecType1','Agency Account;Charter Account;Customer Account;Global Account;Other Account;Prospect Account;Regional Account;Person Account'));        
        insert lstConfigData;
        
		//Create test data for Account object
		String accountRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
		Account accountRecord = QCC_TestDataFactory.createAccountTestData(1);
		accountRecord.RecordTypeId = accountRecordTypeId;
		insert accountRecord;

		//Create test data for Contact object
		List<Contact> contactRecords = new List<Contact>();
		String contactRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Individual Contact').getRecordTypeId();
		Contact contactRecord = QCC_TestDataFactory.createContactTestData(1, accountRecord.Id);
		contactRecord.RecordTypeId = contactRecordTypeId;
		contactRecord.Frequent_Flyer_Number__c = '000001';
		insert contactRecord;

		List<Trigger_Status__c> customSettingList = QCC_UtilityHelper.createDynamicObjectRecords('Trigger_Status__c', 'QCCTestDataTriggerStatusCase', null, null, null, null);
		insert customSettingList;

		//Create test data for Case object
		Case caseRecord = QCC_TestDataFactory.createCaseTestData(accountRecord.Id, contactRecord.Id);
		insert caseRecord;
		Test.stopTest();
	}

	static testMethod void testEscalation(){
		Test.startTest();
		Case caseRecord = [SELECT Id, OwnerId, FF_Tier__c,Last_Queue_Owner__c FROM Case LIMIT 1];//(User Story: QSFR-23) Added Last_Queue_Owner__c
		List<Case> listCase = new List<Case> {caseRecord};
		QCC_EscalateCaseToQueue.EscalateCaseWithWaitingStatus(listCase);
		Test.stopTest();
		//(User Story: QSFR-23) Start
		Group g1 = [Select Id, Name from group where developername = 'CCC_R1_Post_Travel_Q' Limit 1];
		caseRecord = [SELECT Id, OwnerId, FF_Tier__c,Last_Queue_Owner__c FROM Case LIMIT 1];
		system.assert (caseRecord.OwnerId == g1.Id, 'Escalation failed');
		//(User Story: QSFR-23) End
	}
}