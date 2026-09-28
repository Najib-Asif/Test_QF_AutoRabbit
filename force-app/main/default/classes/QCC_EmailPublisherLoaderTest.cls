/*------------------------------------------------------------
   Author:         Venkat Amiya
   Company:        Salesforce
   Description:    Test Class for QCC_EmailPublisherLoaderTest.

   History
   Date            Author                  Comments
   -------------------------------------------------------------
   05-May-2021      Venkat Amiya            Initial Release
   -------------------------------------------------------------
*/
@isTest
public class QCC_EmailPublisherLoaderTest {

	@testSetup
	static void createData() {
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
		Test.startTest();
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
	@isTest static void dynamicEmailTemplateSelectionSuccess(){
		Case caseRecord = [SELECT Id FROM Case LIMIT 1];
		QuickAction.SendEmailQuickActionDefaults sendEmailDefaults = Test.newSendEmailQuickActionDefaults(caseRecord.Id, null);
		QuickAction.QuickActionDefaults defaultqa = sendEmailDefaults;
		QuickAction.QuickActionDefaults[]  defaults = new  QuickAction.QuickActionDefaults[] {};
		defaults.add(defaultqa);

		Test.startTest();

		QCC_EmailPublisherLoader emailPublisherLoader = new QCC_EmailPublisherLoader();
		emailPublisherLoader.onInitDefaults(defaults);
		Test.stopTest();
		EmailMessage emailMessage = (EmailMessage) sendEmailDefaults.getTargetSObject();
		System.assertNotEquals(null, emailMessage, 'Some Error happened!');
	}
}