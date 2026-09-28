/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath/Benazir Amir
Company:       Capgemini
Description:   Https callout to fetch the Scheme Active Member Count received from LSL
Inputs:
Test Class:     
************************************************************************************************
History
************************************************************************************************
25-AUG-2017    Praveen Sampath               Initial Design

-----------------------------------------------------------------------------------------------------------------------*/

@isTest(seeAllData = False)
private class FetchSchemeMemberCountAPITest{
    @testSetup
    static void createTestData(){
        //Enable Asset Triggers
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAssetTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createProductRegTriggerSetting()); 
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContractTriggerSetting());
        insert lsttrgStatus;
        
        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg QBD Registration Rec Type','QBD Registration'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg Aquire Registration Rec Type', 'Aquire Registration'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg AEQCC Registration Rec Type','AEQCC Registration'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Asset Public Scheme Rec Type','Public Scheme'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Asset Corporate Scheme Rec Type','Corporate Scheme'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Prd Reg Aquire Registration Status','Active'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('GST Rate NZD','15'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('GST Rate AUD','10'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('SchemesPointRoundOffNumber','500'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('AssetHeaderName','Basic    '));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('AssetStatusCode','200'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('createIntegrationLogSchemeMemCountAPI','Yes'));
        insert lstConfigData;
        
        //Insert Scheme Fees Setting
        List<SchemeFees__c> lstSchemeData = new List<SchemeFees__c>();
        lstSchemeData.add(TestUtilityDataClassQantas.createSchemeFeesSetting('SchemeFee1', 420, 65000, 'AUD', 60000, 420, 750, null,  null,200,'Corporate Scheme'));
        lstSchemeData.add(TestUtilityDataClassQantas.createSchemeFeesSetting('SchemeFee2', 420, 65000, 'NZD', 60000, 420, 750, null,  null,200,'Corporate Scheme'));
        //lstSchemeData.add(TestUtilityDataClassQantas.createSchemeFeesSetting('SchemeFee3', 420, 65000, '000', 60000, 420, 750, null,  null,200,'Corporate Scheme'));
        lstSchemeData.add(TestUtilityDataClassQantas.createSchemeFeesSetting('SchemeFee4', 420, 65000, 'AUD', 60000, 420, 750, 150,  1500,200,'Public Scheme'));
        lstSchemeData.add(TestUtilityDataClassQantas.createSchemeFeesSetting('SchemeFee5', 420, 65000, 'NZD', 60000, 420, 750, 150,  1500,200,'Public Scheme'));
        //lstSchemeData.add(TestUtilityDataClassQantas.createSchemeFeesSetting('SchemeFee6', 420, 65000, '000', 60000, 420, 750, 150,  1500,200,'Public Scheme'));
        lstSchemeData.add(TestUtilityDataClassQantas.createSchemeFeesSetting('SchemeFee7', 420, 65000, 'AUD', 60000, 420, 750, 150,  1500,200,'Retail'));
        lstSchemeData.add(TestUtilityDataClassQantas.createSchemeFeesSetting('SchemeFee8', 420, 65000, 'NZD', 60000, 420, 750, 150,  1500,200,'Retail'));
        //lstSchemeData.add(TestUtilityDataClassQantas.createSchemeFeesSetting('SchemeFee9', 420, 65000, '000', 60000, 420, 750, 150,  1500,200,'Retail'));
        insert lstSchemeData; 
        
        //Enable Validation
        TestUtilityDataClassQantas.createEnableValidationRuleSetting(); 
        
        //Create Account 
        Account objAcc = TestUtilityDataClassQantas.createAccount(); 
        objAcc.Airline_Level__c = '1';
        objAcc.Active__c = true;
        insert objAcc;
        system.assert(objAcc.Id != Null, 'Account is not inserted');
        
        //Create Contact
        Contact objContact = TestUtilityDataClassQantas.createContact(objAcc.Id);
        objContact.LastName='ContTest2';
        objContact.FirstName = 'Sample';
        objContact.Job_Role__c ='BDM';
        objContact.Job_Title__c ='Developer';
        objContact.Phone='8907654321';
        objContact.Email='abc@gmail.com';
        objContact.MailingCountry = 'AU';
        objContact.MailingStreet = 'xyz';
        objContact.MailingCity = 'abc';
        objContact.MailingState = 'VIC';
        objContact.MailingPostalCode = '123456';
        objContact.Salutation ='Mr.';
        insert objContact;
        system.assert(objContact.Id != Null, 'Contact is not inserted');
        
        //Create Opportunity
        Opportunity objOppty = TestUtilityDataClassQantas.CreateOpportunity(objAcc.Id);
        objOppty.Name='OppTest2';
        objOppty.Type='Business and Government';
        objOppty.Forecast_MCA_Revenue__c=20000;
        insert objOppty;
        system.assert(objOppty.Id != Null, 'Opportunity is not inserted');
        
        //Create Contract
        List<Contract__c> lstContract = new List<Contract__c>();
        Contract__c objContract = TestUtilityDataClassQantas.createContract(objAcc.Id,objOppty.Id);
        objContract.CurrencyIsoCode='AUD';
        objContract.Name = 'TestContracts';
        objContract.Qantas_Club_Join_Discount_Offer__c = '7%';
        objContract.Qantas_Club_Join_Discount_Offer__c = '21%';
        objContract.QL_Effective_Tier__c='Tier 1';
        objContract.Contract_Start_Date__c = system.today().addDays(-200);
        objContract.Contract_End_Date__c = system.today().addDays(200);
        lstContract.add(objContract);
        insert lstContract;
        system.assert(objContract.Id != Null, 'Contract is not inserted');
        
        //Create Asset 
        List<Asset> lstAsset = new List<Asset>();
        for(Integer i=0;i<50;i++){
            lstAsset.add(TestUtilityDataClassQantas.createAsset(objAcc.Id,objContact.Id, objContract.Id,'Corporate Scheme','Coordinator'));
            lstAsset.add(TestUtilityDataClassQantas.createAsset(objAcc.Id,objContact.Id, objContract.Id,'Public Scheme','Individual'));
        }
        insert lstAsset;
    }
    
    private static testmethod void FetchSchemeMemberCountAPITPostiveResponce() {
        String resBody = FetchSchemeMemberCountAPITest.postiveBody();
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        FetchSchemeMemberCountAPIMock postiveMock = new FetchSchemeMemberCountAPIMock(200,'OK', resBody, mapHeader);
        Test.setMock(HttpCalloutMock.class, postiveMock);
        Test.startTest();
        FetchSchemeMemberCountAPI.getActiveMemberCount();
        Test.stopTest();
        
        Id corpSchemeRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Corporate_Scheme').getRecordTypeId();
        Id publicSchemeRecTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Public_Scheme').getRecordTypeId();            
        for(Asset objAsset: [select Id, Scheme_Active_Member_Count__c from Asset where RecordTypeId=:corpSchemeRecTypeId OR RecordTypeId=:publicSchemeRecTypeId]){
            //system.assert(objAsset.Scheme_Active_Member_Count__c == 9, 'Asset Count is not Updated');
        }
    }
    
    private static testmethod void FetchSchemeMemberCountAPITNegativeResponce() {
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        FetchSchemeMemberCountAPIMock postiveMock = new FetchSchemeMemberCountAPIMock(400,'FAILED', '', mapHeader);
        Test.setMock(HttpCalloutMock.class, postiveMock);
        Test.startTest();
        FetchSchemeMemberCountAPI.getActiveMemberCount();
        Test.stopTest();
        List<Log__c> lstLog = [select Id from Log__c];
        system.assert(lstLog.size() != 1, 'Log record is not Inserted');
    }
    
    private static testmethod void FetchSchemeMemberCountAPITExceptionResponce() {
        String resBody = FetchSchemeMemberCountAPITest.exceptionBody();
        Map<String, String> mapHeader = new Map<String, String>();
        mapHeader.put('Content-Type', 'application/json');
        FetchSchemeMemberCountAPIMock postiveMock = new FetchSchemeMemberCountAPIMock(200,'OK', resBody, mapHeader);
        Test.setMock(HttpCalloutMock.class, postiveMock);
        Test.startTest();
        FetchSchemeMemberCountAPI.getActiveMemberCount();
        Test.stopTest();
        List<Log__c> lstLog = [select Id from Log__c];
        system.assert(lstLog.size() != 1, 'Log record is not Inserted');
    }
    
    private static String postiveBody(){
        String resBody = '{"schemes":[';
        for(Asset objAsset: [select Id from Asset]){
            resBody += '{"schemeId":"0000104022","nomineeCount":9,"salesforceId":"';
            resBody += objAsset.Id;
            resBody += '"},';
        }
        resBody = resBody.substring(0, resBody.length()-1);
        resBody += ']}';
        return resBody;
    }
    
    private static String exceptionBody(){
        String resBody = '{"schemes":[';
        for(Asset objAsset: [select Id from Asset]){
            resBody += '{"schemeId":"0000104022","nomineeCount":09,"salesforceId":"';
            resBody += objAsset.Id;
            resBody += '"},';
        }
        resBody = resBody.substring(0, resBody.length()-1);
        resBody += ']}';
        return resBody;
    }
    
}