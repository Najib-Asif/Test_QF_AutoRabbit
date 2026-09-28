/* ****************************************************************************************************************************
Mofified Date   Modified By         Description
------------   ---------------     ------------------------------------------------------------------------------------------------------------------------------------------------------
09-Jun-2026   Sruthi Anil        CRM 10391 Added test methods to cover the code changes for Code Security Remediation in FreightAWBOpportunitycontroller class.
**************************************************************************************************************************** */


@isTest
private class FreightAWBOpportunityControllerTest {

    @testSetup
    static void setupData() {
        
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
        TestUtilityDataClassQantas.enableTriggers();
        //Required config to create recordtypes for different objects
        TestUtilityDataClassQantas.insertQantasConfigData();
		List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue(); 
        
        Trigger_Status__c createIndividualRecord = new Trigger_Status__c();
        createIndividualRecord.Name = 'createIndividualRecord';
        createIndividualRecord.Active__c = false;
        lsttrgStatus.add(createIndividualRecord);
        
        Trigger_Status__c QCC_WelcomeToSSU = new Trigger_Status__c();
        QCC_WelcomeToSSU.Name = 'QCC_WelcomeToSSU';
        QCC_WelcomeToSSU.Active__c = false;
        lsttrgStatus.add(QCC_WelcomeToSSU);
        
        Trigger_Status__c qccUpdateConRec = new Trigger_Status__c();
        qccUpdateConRec.Name = 'QCC_UpdateContactPhoneAndAddress';
        qccUpdateConRec.Active__c = true;
        lsttrgStatus.add(qccUpdateConRec);
        
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContactTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createCaseTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createRecoveryTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createEventTriggerSetting());
        insert lsttrgStatus;
        
        // Trigger setup (your org pattern)
        insert new Trigger_Status__c(Name = 'AccountTeam', Active__c = true);
        insert new Trigger_Status__c(Name = 'trgCaseFieldUpdates', Active__c = true);
        insert new Trigger_Status__c(Name = 'trgTradeSiteResponses', Active__c = true);
        
        Integration_User_Tradesite__c ss = new Integration_User_Tradesite__c(
            Name = 'Freight_iCargo_Integration',
            Username__c = 'SALESICARGOS',
            Password__c = 'CU329VR3',
            Endpoint__c = 'https://api-stage.qantas.com/customer/freightservice/v1/trackFreight/shipment',
            NameChangeStartNumber__c = 1, 
            NameChangeEndNumber__c = 1,
            Client_Id__c = '08c64f80',
            Client_Secret__c = 'f272c21fcea5a9d661f9fe8890510622',
            Authentication_Endpoint_URL__c = 'https://api-stage.qantas.com/customer/oauth/token');
        insert ss; 


        String rectypeName = CustomSettingsUtilities.getConfigDataMap('Acc acrUpdateRecordType');
        Id accRtId = GenericUtils.getObjectRecordTypeId('Account', rectypeName);

        Account acc = new Account(
            Name = 'Test Account',
            Active__c = true,
            Type = 'Freight-Country',
            RecordTypeId = accRtId
        );
        insert acc;

        // Contact
        Contact con = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'test@test.com',
            AccountId = acc.Id
        );
        insert con;

        // Opportunity (CORE OBJECT)
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            AccountId = acc.Id,
            CloseDate = Date.today().addDays(10),
            StageName = 'Prospecting',
            Freight_AWB_Number__c = '081-14290113'
        );
        insert opp;
    }

    
    // getBeforeAWBDetails
    @isTest
    static void testGetBeforeAWBDetails() {

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.startTest();
        Opportunity result =
            FreightAWBOpportunitycontroller.getBeforeAWBDetails(opp.Id);
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    
    // SUCCESS FLOW (MAIN COVERAGE)
    @isTest
    static void testGetRecordUpdate_Success() {

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.setMock(HttpCalloutMock.class,
            new Freight_AWBMockRequest('yes'));

        Test.startTest();
        FreightAWBOpportunitycontroller res =
            FreightAWBOpportunitycontroller.getRecordUpdate(opp.Id);
        Test.stopTest();

        System.assertEquals(true, res.isSuccess);
        System.assertNotEquals(null, res.ControllerOpportunity);
    }

    
    // FAILURE FLOW
    @isTest
    static void testGetRecordUpdate_Failure() {

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.setMock(HttpCalloutMock.class,
            new Freight_AWBMockRequest('error'));

        Test.startTest();
        FreightAWBOpportunitycontroller res =
            FreightAWBOpportunitycontroller.getRecordUpdate(opp.Id);
        Test.stopTest();

        System.assertEquals(false, res.isSuccess);
    }


    // AWB BLANK
    @isTest
    static void testGetRecordUpdate_AWBBlank() {

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        opp.Freight_AWB_Number__c = '';
        update opp;

        Test.startTest();
        FreightAWBOpportunitycontroller res =
            FreightAWBOpportunitycontroller.getRecordUpdate(opp.Id);
        Test.stopTest();

        System.assertEquals(false, res.isSuccess);
        System.assert(res.msg.contains('AWB Number not provided'));
    }

    
    // JSON EXCEPTION
    @isTest
    static void testGetRecordUpdate_JSONException() {

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        Test.setMock(HttpCalloutMock.class,
            new Freight_AWBMockRequest('invalid'));

        Test.startTest();
        FreightAWBOpportunitycontroller res =
            FreightAWBOpportunitycontroller.getRecordUpdate(opp.Id);
        Test.stopTest();

        System.assertNotEquals(null, res);
    }

    
    // PARSING
    @isTest
    static void testReturnParsedOpportunity() {

        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        String json =
        '{' +
        '"shipmentSummary": {' +
        '"statedWeight": "50",' +
        '"handlingCodes": "AVI",' +
        '"statedPieces": 2,' +
        '"origin": "SYD",' +
        '"destination": "MNL",' +
        '"shipmentDescription": "Test Shipment"' +
        '},' +
        '"unitOfMeasures": {' +
        '"weight": "kg"' +
        '}' +
        '}';

        Test.startTest();
        Opportunity result =
            FreightAWBOpportunitycontroller.returnParsedCampaignMember(json, opp);
        Test.stopTest();

        System.assertNotEquals(null, result);
    }

    
    // REQUEST STRING
    @isTest
    static void testGetRequestString() {

        Test.startTest();
        String req =
            FreightAWBOpportunitycontroller.getRequestString(
                'user', 'pass', '081-12345678'
            );
        Test.stopTest();

        System.assertNotEquals(null, req);
    }

    @isTest
    static void userNoAccess_testgetBeforeAWBDetails(){
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce'];
    User u1 = new User(
          Username = 'testu045600ser@example.com',
          Email = 'testus11145611er@qantas.com.au',
          LastName = 'Test',
          FirstName = 'User',
          Alias = 'testu',
          ProfileId = p.Id,
          TimeZoneSidKey = 'America/Los_Angeles',
          LocaleSidKey = 'en_US',
          EmailEncodingKey = 'UTF-8',
          LanguageLocaleKey = 'en_US'
       );
    insert u1;
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    Test.startTest();
        System.runAs(u1) {
          try{
              Opportunity result =
                         FreightAWBOpportunitycontroller.getBeforeAWBDetails(opp.Id);
          } catch (Exception e) {
                System.assertNotEquals(null, e);
          }
        }
    Test.stopTest();
    }

    @isTest
    static void userNoAccess_testgetRecordUpdate(){
    Profile p = [SELECT Id FROM Profile WHERE Name = 'Minimum Access - Salesforce'];
    User u1 = new User(
          Username = 'testu045600ser@example.com',
          Email = 'testus11145611er@qantas.com.au',
          LastName = 'Test',
          FirstName = 'User',
          Alias = 'testu',
          ProfileId = p.Id,
          TimeZoneSidKey = 'America/Los_Angeles',
          LocaleSidKey = 'en_US',
          EmailEncodingKey = 'UTF-8',
          LanguageLocaleKey = 'en_US'
       );
    insert u1;
    Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
    Test.setMock(HttpCalloutMock.class,
            new Freight_AWBMockRequest('yes'));

    Test.startTest();
        System.runAs(u1) {
          try{
              FreightAWBOpportunitycontroller res =
                       FreightAWBOpportunitycontroller.getRecordUpdate(opp.Id);
          } catch (Exception e) {
                System.assertNotEquals(null, e);
          }
        }
    Test.stopTest();
    }

}