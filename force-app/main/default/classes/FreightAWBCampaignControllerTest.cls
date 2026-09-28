/* 
 * Description: Test class for FreightAWBCampaignController
 * Author: Bharath Inti
 * CreatedDate: 8/6/2026 
8-Jul-2026    Truong-Capgemini        CRM-13514 Test class coverage for PSV changes 
 * 
*/
@isTest
public class FreightAWBCampaignControllerTest {

    
    @testSetup
    static void setupData() {
    
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
    
        // Trigger config (optional but safe)
        List<Trigger_Status__c> lst = new List<Trigger_Status__c>();
        lst.add(new Trigger_Status__c(Name = 'AccountTeam', Active__c = true));
        lst.add(new Trigger_Status__c(Name = 'trgCaseFieldUpdates', Active__c = true));
        insert lst;
    
        // Integration Setting
        
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
    
        // NOW THIS WILL WORK
        String rectypeName = CustomSettingsUtilities.getConfigDataMap('Acc acrUpdateRecordType');
        Id accRtId = GenericUtils.getObjectRecordTypeId('Account', rectypeName);
    
        Account acc = new Account(
            Name = 'Test Account',
            Active__c = true,
            Type = 'Freight-Country',
            RecordTypeId = accRtId
        );
        insert acc;
    
        Contact con = new Contact(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'test@test.com',
            AccountId = acc.Id
        );
        insert con;
    
        
        Campaign camp = new Campaign(
            Name = 'Test Campaign',
            Status = 'Planned'
        );
        insert camp;
    
    
        insert new CampaignMember(
            CampaignId = camp.Id,
            ContactId = con.Id,
            Status = 'Sent',
            Freight_AWB_Number__c = '081-14290113'
        );
       }
    
    
        
        // getBeforeAWBDetails
        @isTest
        static void testGetBeforeAWBDetails() {
    
            CampaignMember cm = [SELECT Id FROM CampaignMember LIMIT 1];
    
            Test.startTest();
            CampaignMember result =
                FreightAWBCampaignController.getBeforeAWBDetails(cm.Id);
            Test.stopTest();
    
            System.assertNotEquals(null, result);
        }
    
        
        // SUCCESS FLOW
        @isTest
        static void testGetRecordUpdate_Success() {
    
            CampaignMember cm = [SELECT Id FROM CampaignMember LIMIT 1];
    
            Test.setMock(HttpCalloutMock.class,
                new Freight_AWBMockRequest('yes'));
    
            Test.startTest();
            FreightAWBCampaignController res =
                FreightAWBCampaignController.getRecordUpdate(cm.Id);
            Test.stopTest();
    
            System.assertEquals(true, res.isSuccess);
            System.assertNotEquals(null, res.ControllerCampaignMember);
        }
    
        // FAILURE FLOW
        @isTest
        static void testGetRecordUpdate_Failure() {
    
            CampaignMember cm = [SELECT Id FROM CampaignMember LIMIT 1];
    
            Test.setMock(HttpCalloutMock.class,
                new Freight_AWBMockRequest('error'));
    
            Test.startTest();
            FreightAWBCampaignController res =
                FreightAWBCampaignController.getRecordUpdate(cm.Id);
            Test.stopTest();
    
            System.assertEquals(false, res.isSuccess);
        }
    
        
        // AWB BLANK
        @isTest
        static void testGetRecordUpdate_AWBBlank() {
    
            CampaignMember cm = [SELECT Id FROM CampaignMember LIMIT 1];
    
            cm.Freight_AWB_Number__c = '';
            update cm;
    
            Test.startTest();
            FreightAWBCampaignController res =
                FreightAWBCampaignController.getRecordUpdate(cm.Id);
            Test.stopTest();
    
            System.assertEquals(false, res.isSuccess);
        }
    
        // JSON EXCEPTION
        @isTest
        static void testGetRecordUpdate_JSONException() {
    
            CampaignMember cm = [SELECT Id FROM CampaignMember LIMIT 1];
    
            Test.setMock(HttpCalloutMock.class,
                new Freight_AWBMockRequest('invalid'));
    
            Test.startTest();
            FreightAWBCampaignController res =
                FreightAWBCampaignController.getRecordUpdate(cm.Id);
            Test.stopTest();
    
            System.assertNotEquals(null, res);
        }
    
        // CRM-10380: Add coverage for PSV Change
        @isTest
        static void testGetRecordUpdate_GenericException() {
            CampaignMember cm = [SELECT Id FROM CampaignMember LIMIT 1];
            Boolean auraExceptionThrown = false;

            Test.startTest();
            try {
                FreightAWBCampaignController.getRecordUpdate(cm.Id);
            } catch (AuraHandledException e) {
                auraExceptionThrown = true;
            }
            Test.stopTest();

            System.assert(auraExceptionThrown, 'Expected AuraHandledException from the generic catch block');
        }
        
        // PARSING
        @isTest
        static void testReturnParsedCampaignMember() {
    
            CampaignMember cm = [SELECT Id FROM CampaignMember LIMIT 1];
    
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
            CampaignMember result =
                FreightAWBCampaignController.returnParsedCampaignMember(json, cm);
            Test.stopTest();
    
            System.assertNotEquals(null, result);
        }
    
        
        // REQUEST STRING
        @isTest
        static void testGetRequestString() {
    
            Test.startTest();
            String req =
                FreightAWBCampaignController.getRequestString(
                    'user', 'pass', '081-12345678'
                );
            Test.stopTest();
    
            System.assertNotEquals(null, req);
     }
        
    //CRM-10380 Code Security Remediation
    @isTest
    static void test_getBeforeAWBDetails_queryException() {
        
        Id fakeId = '701000000000000AAA';
        
        Test.startTest();
        
        Boolean exceptionThrown = false;
        
        try {
            FreightAWBCampaignController.getBeforeAWBDetails(fakeId);
        } catch (Exception e) {
            exceptionThrown = true;
            
            System.debug('Exception type: ' + e.getTypeName());
            
            System.assert(
                e instanceof AuraHandledException ||
                e instanceof NullPointerException,
                'Expected AuraHandledException or NullPointerException'
            );
        }
        
        System.assert(exceptionThrown, 'Exception should have been thrown');
        
        Test.stopTest();
    }
}