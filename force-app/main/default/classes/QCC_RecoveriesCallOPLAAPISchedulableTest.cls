@isTest
private class QCC_RecoveriesCallOPLAAPISchedulableTest {
	
	static{
		// create Account
		// create Contact
		// create Case
		// create Recovery
		TestUtilityDataClassQantas.insertQantasConfigData();
        List<Trigger_Status__c> listTriggerConfigs = new List<Trigger_Status__c>();
    	listTriggerConfigs.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        listTriggerConfigs.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        listTriggerConfigs.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        listTriggerConfigs.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        for(Trigger_Status__c triggerStatus : listTriggerConfigs){
            triggerStatus.Active__c = false;
        }
    	insert listTriggerConfigs;
    	// Create Account
    	List<Account> listAccountTest = TestUtilityDataClassQantas.getAccounts();
    	// CRETAE contact
    	List<Contact> listContactTest = TestUtilityDataClassQantas.getContacts(listAccountTest);
        
        listContactTest[0].Frequent_Flyer_Number__c = '0006142208';

        update listContactTest[0];

        // create Case
        List<Case> listCaseTest = TestUtilityDataClassQantas.getCases(listAccountTest);
        listCaseTest[0].ContactId = listContactTest[0].Id;
        update listCaseTest;
        List<Recovery__c> listRecoveryTest = new List<Recovery__c>();
        // create Recovery
        for(Case caseObj: listCaseTest){
            Recovery__c newRe = new Recovery__c();
            newRe.Case_Number__c = caseObj.Id;
            newRe.Type__c = CustomSettingsUtilities.getConfigDataMap('Recovery DQC Lounge Passes');
            newRe.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusFinalisation Declined');
            listRecoveryTest.add(newRe);
        }
        listRecoveryTest[1].API_Attempts__c = 2;
        insert listRecoveryTest;
        List<Qantas_API__c> listAPIConfig = TestUtilityDataClassQantas.createQantasAPI();
        insert listAPIConfig;
	}
	@isTest static void testRecoveriesCallOPLAAPISchedulable() {
        Test.startTest();
		String body = '{ "success": true, "referenceNo": "R-0213412", "errorMessage": ""}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(202, 'Success', body, mapHeader));
        QCC_RecoveriesCallOPLAAPISchedulable m = new QCC_RecoveriesCallOPLAAPISchedulable();
		String sch = '0 0 1 * * ?';
		String jobID = system.schedule('QCC Recoveries Call OPLAAPIS Job test', sch, m); 
        Test.stopTest();

	}
	
}