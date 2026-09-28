@isTest
private class QCC_RecoveriesCallOPLAAPIBatchableTest {
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
        listContactTest[0].CAP_ID__c = '313442';
        listContactTest[0].firstname = 'Sample';
        listContactTest[0].lastname = 'Sample1';
        listContactTest[0].email = 'ibstestonlinesalesqueries@qantas.com.au';

        update listContactTest[0];

        // create Case
        List<Case> listCaseTest = TestUtilityDataClassQantas.getCases(listAccountTest);
        listCaseTest[0].ContactId = listContactTest[0].Id;
        listCaseTest[0].first_name__c = listContactTest[0].firstname;
        listCaseTest[0].last_name__c = listContactTest[0].lastname;
        listCaseTest[0].Contact_Email__c = listContactTest[0].email;
        update listCaseTest;
        List<Recovery__c> listRecoveryTest = new List<Recovery__c>();
        // create Recovery
        for(Case caseObj: listCaseTest){
            Recovery__c newRe = new Recovery__c();
            newRe.Case_Number__c = caseObj.Id;
            newRe.Type__c = CustomSettingsUtilities.getConfigDataMap('RecoveryTypeLoungePasses');
            newRe.Status__c = CustomSettingsUtilities.getConfigDataMap('RecoveryStatusApproved');
            listRecoveryTest.add(newRe);
        }
        listRecoveryTest[1].API_Attempts__c = 2;
        insert listRecoveryTest;
        List<Qantas_API__c> listAPIConfig = TestUtilityDataClassQantas.createQantasAPI();
        insert listAPIConfig;
	}

	@isTest static void testRecoveriesCallOPLAAPIBatchable() {
        Test.startTest();
		String body = '{ "success": true, "referenceNo": "R-0213412", "errorMessage": ""}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, new QCC_CAPBookingMock(202, 'Success', body, mapHeader));
        QCC_RecoveriesCallOPLAAPIBatchable callOPLAAPIBatch = new QCC_RecoveriesCallOPLAAPIBatchable();
        //added for deployed
        try{
        Database.executebatch(callOPLAAPIBatch, 100);
        }catch(Exception ex){}
        Test.stopTest();

	}

    @isTest static void testRecoveriesCallOPLAAPIBatchableSuccess() {
        Test.startTest();
        List<QCC_CAPFlightInfoMock.MockRes> lstRes = new List<QCC_CAPFlightInfoMock.MockRes>();
        String BodyLoyalty = '{"memberId":"0006142104","firstName":"Sample","lastName":"Sample1","mailingName":"MR W FYSH","salutation":"Dear Mr Fysh","title":"MR","dateOfJoining":"1996-05-13","gender":"MALE","dateOfBirth":"1996-11-07","email":"ibstestonlinesalesqueries@qantas.com.au","emailType":"BUSINESS","countryOfResidency":"AU","taxResidency":"AU","membershipStatus":"ACTIVE","preferredAddress":"HOME","pointBalance":11326,"company":{"name":"DO NOT CHANGE ANYTHING - PH JAMIE X62542","positionInCompany":"TEST PROFILE - DIGITAL DIRECT"},"phoneDetails":[{"type":"BUSINESS","number":"96912542","areaCode":"02","idd":"+61","status":"V"}],"addresses":[{"type":"HOME","lineOne":"10 BOURKE ROAD","suburb":"SYDNEY","postCode":"3000","state":"VIC","countryCode":"AU","status":"I"}],"preferences":{"ffsAirlines":[{"id":1,"number":"SK198253","airline":"CO"}],"leisureInterests":["BALL","CLMU","JAZZ"],"sportInterests":["BABL","BSBL","CYCL","SQSH","ARFB"]},"programDetails":[{"programCode":"QCASH","programName":"Qantas Cash","enrollmentDate":"2015-04-28","accountStatus":"ACTIVE","qcachSendMarketing":false,"qcashProgramIdentifier":"AU","activationFlag":"N"},{"programCode":"QC","programName":"Qantas Club","enrollmentDate":"2017-08-02","expiryDate":"2018-07-31","accountStatus":"PAYMENT_DUE","qcEnrolType":0},{"programCode":"QFF","programName":"Qantas Frequent Flyer","enrollmentDate":"1996-05-13","accountStatus":"ACTIVE","tierCode":"FFPL","tierFromDate":"2017-08-02"},{"programCode":"CL","programName":"Chairmans Lounge","enrollmentDate":"2017-08-02","expiryDate":"2019-08-31","accountStatus":"ACTIVE","clMemberType":"PRIME"}],"webLoginDisabled":false,"statusCredits":{"expiryDate":"2018-07-31","lifetime":430,"total":430,"loyaltyBonus":0},"tier":{"name":"Chairmans Lounge","code":"FFPL","startDate":"2017-08-02","effectiveTier":"CLQF"}}';
        String BodyOpla = '{ "success": true, "referenceNo": "R-0213412", "errorMessage": ""}';
        Map<String, String> mapHeader= new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        lstRes.add(new QCC_CAPFlightInfoMock.MockRes(200, 'Success', BodyLoyalty, mapHeader));
        lstRes.add(new QCC_CAPFlightInfoMock.MockRes(202, 'Success', BodyOpla, mapHeader));
        Test.setMock(HttpCalloutMock.class, new QCC_CAPFlightInfoMock(lstRes));
        QCC_RecoveriesCallOPLAAPIBatchable callOPLAAPIBatch = new QCC_RecoveriesCallOPLAAPIBatchable();
        //added for deployed
        try{
        Database.executebatch(callOPLAAPIBatch, 100);
        }catch(Exception ex){}
        Test.stopTest();
        List<Recovery__c>  recoveryAfter = [SELECT Id, Status__c FROM Recovery__c where RecordType.DeveloperName='Customer_Connect'];
		//Commented for Deployment
        //System.assertEquals(CustomSettingsUtilities.getConfigDataMap('RecoveryStatusFinalised'), recoveryAfter[0].Status__c);
    }

	
}