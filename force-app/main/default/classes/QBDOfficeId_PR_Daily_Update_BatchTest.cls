/*==================================================================================================================================
Author:         Praveen Sampath
Company:        Capgemini
Purpose:        Test Class for QBDOfficeId_PR_Daily_Update_Batch Class
Date:           19/12/2016          
History:

==================================================================================================================================

==================================================================================================================================*/

@isTest(SeeAllData = false)
private class QBDOfficeId_PR_Daily_Update_BatchTest {
	
	@testSetup
	static void createTestData(){

		List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSetting();
		lsttrgStatus.addAll(TestUtilityDataClassQantas.createProductRegTriggerSetting());
		insert lsttrgStatus;

		List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
		lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg QBD Registration Rec Type','QBD Registration'));
		lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg Aquire Registration Rec Type','Aquire Registration'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg AEQCC Registration Rec Type','AEQCC Registration'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
		insert lstConfigData;

		List<QBD_Online_Office_ID__c> lstQBDOff = TestUtilityDataClassQantas.createQBDOnlineOfficeId();
		system.assert(lstQBDOff.size() != 0, 'QBD_Online_Office_ID__c List is empty');
		insert lstQBDOff;

		List<Account> lstAcc = TestUtilityDataClassQantas.getAccounts();
		system.assert(lstAcc.size() != 0, 'Account List is zero');
		Account objAcc = lstAcc[0];
		system.assert(objAcc != Null, 'Account is not inserted');

		List<Product_Registration__c> lstObjProdReg = new List<Product_Registration__c>();
		Product_Registration__c objAcqProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'Acquire');
		objAcqProdReg.Key_Contact_Office_ID__c ='abc 1233';
		lstObjProdReg.add(objAcqProdReg);
		Product_Registration__c objQBDProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'QBD Registration');
		objQBDProdReg.Key_Contact_Office_ID__c ='abc 1234';
		lstObjProdReg.add(objQBDProdReg);
		insert lstObjProdReg;
		
		system.assert(lstObjProdReg != Null , 'Product Registration is not Inserted');
	}

	static TestMethod void invokeBatch(){
		Test.startTest();
		QBDOfficeId_PR_Daily_Update_Batch qbdBatch = new QBDOfficeId_PR_Daily_Update_Batch(true);
		Database.executeBatch(qbdBatch);
		Test.stopTest();
		Product_Registration__c objProdReg = [select Id, Key_Contact_Office_ID__c from Product_Registration__c  limit 1];
		system.assert(objProdReg.Key_Contact_Office_ID__c == Null, 'Key contact is not blank');
		
	}
}