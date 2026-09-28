/*==================================================================================================================================
   Author:         Praveen Sampath
   Company:        Capgemini
   Purpose:        Test Class for QCC_CaseOwnerSLABatch Class
   Date:           18/05/2018
   History:

   ==================================================================================================================================

   ==================================================================================================================================*/

@isTest(SeeAllData = false)
private class QCC_CaseOwnerSLABatchTest {

	@testSetup
	static void createTestData(){

		List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
		insert lstQantas;

		TestUtilityDataClassQantas.insertQantasConfigData();

		List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
		lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('LoyaltyAPIValidationLevel','NUMBER'));
		lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('LoyaltyAPIPartnerID','DIAMD01'));
		lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
		lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
		lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusApproved','Approved'));
		lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusFinalised','Finalised'));
		lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusFinalisation Declined','Finalisation Declined'));
		lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryType','Qantas Points'));
		insert lstConfigData;



		List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
		lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
		lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
		lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
		insert lsttrgStatus;

		//Create Account
		Account objAcc = TestUtilityDataClassQantas.createAccount();
		objAcc.Airline_Level__c = '1';
		objAcc.Active__c = true;
		insert objAcc;
		system.assert (objAcc != Null, 'Account is not inserted');

		//Create Contact
		Contact objContact = TestUtilityDataClassQantas.createContact(objAcc.Id);
		objContact.LastName='ContTest2';
		objContact.CAP_ID__c='710000000017';
		insert objContact;
		system.assert (objContact.Id != Null, 'Contact is not inserted');

		//Create Case
		List<Contact> lstContact = new List<Contact>();
		lstContact.add(objContact);
		String recordType = 'CCC Complaints';
		String type = 'Compliment';
		List<Case> lstCase = TestUtilityDataClassQantas.insertCases(lstContact, recordType, type, 'Qantas.com','','','');
		system.assert (lstCase.size()>0, 'Case List is Zero');
		system.assert (lstCase[0].Id != Null, 'Case is not inserted');




	}

	static TestMethod void invokeBatch(){
		Group g1 = new Group(Name='QCC Test Low', type='Queue');
		insert g1;
		QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
		insert q1;
		Group g2 = new Group(Name='QCC Test SLA', type='Queue');
		insert g2;
		QueuesObject q2 = new QueueSObject(QueueID = g2.id, SobjectType = 'Case');
		insert q2;
		User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com',
		                   Username = 'sampleuser1username@sample.com', ProfileId = UserInfo.getProfileId(),
		                   EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
		                   TimeZoneSidKey = 'Australia/Sydney', Location__c='Hobart'
		                   );
		insert u1;
		system.runAs(u1){
			Case objCase = [select id, OwnerId, SLA_Queue__c from Case limit 1];
			objCase.Due_Date__c = system.today().adddays(-1);
			objCase.Valid_SLA_Queue_Migration__c = true;
			objCase.OwnerId = g1.Id;
			objCase.SLA_Queue__c = g2.Id;
			update objCase;

			objCase = [select id, OwnerId, SLA_Queue__c from Case limit 1];
			system.assert (objCase.OwnerId == g1.Id, 'Ownwer Update failed ');
			Test.startTest();
			Date yesterday = system.today().adddays(-1);
			String query = 'select Id, SLA_Queue__c from Case where Valid_SLA_Queue_Migration__c = true  and Due_Date__c =: yesterday';

			QCC_CaseOwnerSLABatch qccSLABatch = new QCC_CaseOwnerSLABatch(query);
			ID batchprocessid =  DataBase.executeBatch(qccSLABatch);

			Database.QueryLocator ql = qccSLABatch.start(null);
			List<Case> lstCase = new List<Case>();
			lstCase.add(objCase);
			qccSLABatch.execute(null,lstCase);
			qccSLABatch.Finish(null);
			Test.stopTest();
			Case objCase1 = [select id, OwnerId, owner.name, Priority from Case limit 1];//(User Story: QSFR-23). Added Priority.
			//system.assert(objCase1.OwnerId == g2.Id, 'Batch failed'); As queue Owner does not change now.
			system.assert (objCase1.OwnerId == g1.Id, 'Batch failed');//(User Story: QSFR-23)
			system.assert (objCase1.Priority == 'SLA', 'Batch failed');//(User Story: QSFR-23)
		}
	}

	static TestMethod void invokeExceptionBatch(){
		Group g1 = new Group(Name='QCC Test Low', type='Queue');
		insert g1;
		QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
		insert q1;
		Group g2 = new Group(Name='QCC Test SLA', type='Queue');
		insert g2;
		QueuesObject q2 = new QueueSObject(QueueID = g2.id, SobjectType = 'Case');
		insert q2;
		User u1 = new User(LastName = 'User1', Alias = 'User', Email = 'sampleuser1@sample.com',
		                   Username = 'sampleuser1username@sample.com', ProfileId = UserInfo.getProfileId(),
		                   EmailEncodingKey = 'UTF-8', LanguageLocaleKey = 'en_US', LocaleSidKey = 'en_AU',
		                   TimeZoneSidKey = 'Australia/Sydney', Location__c='Hobart'
		                   );
		insert u1;
		system.runAs(u1){
			Case objCase = [select id, OwnerId, SLA_Queue__c from Case limit 1];
			objCase.Due_Date__c = system.today().adddays(-1);
			objCase.Valid_SLA_Queue_Migration__c = true;
			objCase.OwnerId = g1.Id;
			objCase.SLA_Queue__c = g2.Id;
			update objCase;
		}

		Case objCase = [select id, OwnerId, SLA_Queue__c from Case limit 1];
		system.assert (objCase.OwnerId == g1.Id, 'Ownwer Update failed ');
		Test.startTest();
		Date yesterday = system.today().adddays(-1);
		String query = 'select Id, SLA_Queue__c from Case where Valid_SLA_Queue_Migration__c = true  and Due_Date__c =: yesterday';
		try{
			QCC_CaseOwnerSLABatch qccSLABatch = new QCC_CaseOwnerSLABatch(query);
			ID batchprocessid =  DataBase.executeBatch(qccSLABatch);

			Database.QueryLocator ql = qccSLABatch.start(null);
			List<Case> lstCase = new List<Case>();
			lstCase.add(objCase);
			qccSLABatch.execute(null,lstCase);
			qccSLABatch.Finish(null);
		}catch(Exception ex) {

		}
		Test.stopTest();


	}

}