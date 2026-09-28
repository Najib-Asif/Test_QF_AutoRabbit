/*==================================================================================================================================
Author:         Benazir Amir/Praveen Sampath
Company:        Capgemini
Purpose:        Test Class for CreateQBRAPI Class
Date:           28/04/2017        
History:

==================================================================================================================================

==================================================================================================================================*/

@isTest(SeeAllData = false)
private class CreateQBRAPITest{

	@testSetup
    static void createTestData(){
    	

    	List<user> lstUserUpdate = new List<User>();
        List<User> lstUser = TestUtilityDataClassQantas.getUsers('Data Administrator', 'MAS Team', 'QF-DOM-Sales-SME-QIS-Operations');
        system.assert(lstUser[0].Id != Null, 'User list is not Inserted');
        system.assert(lstUser.size()==2, 'List size is small');

        User objUser = lstUser[0];
        objUser.Id = lstUser[0].Id;
        objUser.IsActive = true;
        objUser.Email = 'test@QIs.com';
        lstUserUpdate.add(objUser);
        
        update lstUserUpdate;
        User objActiveUser = [select Id, UserRoleId from User where Id =: objUser.Id ];
        system.assert(objActiveUser.UserRoleId != Null, 'User Role is Null');

        system.runAs(objActiveUser){
        	List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSetting();
	        lsttrgStatus.addAll(TestUtilityDataClassQantas.createProductRegTriggerSetting());
	        insert lsttrgStatus;
			
			List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
			lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg Aquire Registration Rec Type', 'Aquire Registration'));
            lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg AEQCC Registration Rec Type','AEQCC Registration'));
	        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
	        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
	        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('createIntegrationLogQBRAPI','Yes'));
	        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg Aquire Registration Status','Active'));
            insert lstConfigData;
	        Account objAcc = TestUtilityDataClassQantas.createAccount();
			objAcc.ABN_Tax_Reference__c = '99999999999';
			insert objAcc;
			system.assert(objAcc.Id != Null, 'Account is not inserted');

			Product_Registration__c objQBDProdReg = TestUtilityDataClassQantas.createProductRegistration(objAcc.Id, 'AEQCC');
			insert objQBDProdReg;
			Product_Registration__c amexProduct = [ Select Id,Type__c, Active__c from Product_Registration__c where Id =: objQBDProdReg.Id];
			system.assert(amexProduct.Type__c == 'AEQCC' , 'Amex Product Registration is not Inserted');
			system.assert(amexProduct.Active__c == true , 'Amex Product Registration is not Inserted');
		}
    }

    static TestMethod void CreateQBRProductTest(){
		
		Product_Registration__c amexProduct = [ Select Id from Product_Registration__c where Type__c = 'AEQCC'];
		User testUsr = [select Id from User where Email = 'test@QIs.com' LIMIT 1];
		Test.startTest();
       
        List<QBRProductRegWrapper> lstprodRegistrations = new list<QBRProductRegWrapper>();
        QBRProductRegWrapper qbrWrapper = new QBRProductRegWrapper();

        qbrWrapper.enrolmentStatusCode = 'S00';
        qbrWrapper.amexProductId = amexProduct.Id;
        qbrWrapper.enrolmentStatusDescription = 'Success!!!!';

        QBRProductRegWrapper.QBRProduct qbrInfos = new QBRProductRegWrapper.QBRProduct();
        qbrInfos.membershipNumber = '779922';
        qbrInfos.membershipStatus = 'Active';
        qbrInfos.membershipStartDate = System.today();
        qbrInfos.membershipEndDate = null;
        qbrInfos.companyIndustry = 'Manufacturing';
		qbrInfos.companyAirlineLevel = '1';
		qbrInfos.companyGSTRegistered = 'Y';
		qbrInfos.companyEntityType = 'Australian Public Company';

		qbrWrapper.qbrInfo = qbrInfos;
        
        lstprodRegistrations.add(qbrWrapper);

        system.runAs(testUsr){
	        CreateQBRAPI.create(lstprodRegistrations);
	    }
	    Test.stopTest();

	    List<Account> lstAcc = [Select Id,No_of_Aquires__c from Account LIMIT 1];
	    system.assert(lstAcc.size() == 1 , 'Account is not fetched');
	    system.assert(lstAcc[0].No_of_Aquires__c == 1 , 'QBR Product Registration is not Inserted');
	}

	static TestMethod void CreateQBRExceptionTest(){
		Test.startTest();
        List<QBRProductRegWrapper> lstprodRegistrations = new list<QBRProductRegWrapper>();
        QBRProductRegWrapper qbrWrapper = new QBRProductRegWrapper();

        lstprodRegistrations.add(qbrWrapper);
        CreateQBRAPI.create(lstprodRegistrations);
	    Test.stopTest();

        List<Log__c> lstLog = [select Id from Log__c];
	    system.assert(lstLog.size() != 0, 'Log record is not Inserted');
	}


}