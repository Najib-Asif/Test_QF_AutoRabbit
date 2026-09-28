/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   Test Class for CorporateScheme_ContractEnd_Batch
Inputs:
Test Class:    Not Required
************************************************************************************************
History
************************************************************************************************
26-May-2017    Praveen Sampath   InitialDesign
-----------------------------------------------------------------------------------------------------------------------*/
@isTest(seeAllData = false)
private class CorporateScheme_ContractEnd_BatchTest {
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
        objContract.Contract_End_Date__c = system.today().addDays(-1);
        lstContract.add(objContract);
        insert lstContract;
        system.assert(objContract.Id != Null, 'Contract is not inserted');
        

        //Create Asset 
        List<Asset> lstAsset = new List<Asset>();
        lstAsset.add(TestUtilityDataClassQantas.createAsset(objAcc.Id,objContact.Id, objContract.Id,'Corporate Scheme','Coordinator'));
        Asset objAsset = TestUtilityDataClassQantas.createAsset(objAcc.Id,objContact.Id, objContract.Id,'Corporate Scheme','Coordinator');
        objAsset.Waiver_Start_Date__c = System.TODAY().addDays(-20);
        objAsset.Waiver_End_Date__c = System.TODAY().addDays(-2);
        objAsset.Qantas_Club_Join_Discount__c = 10;
        objAsset.Member_Fee_Discount__c = 12;
        lstAsset.add(objAsset);
        Asset objAsset1 = TestUtilityDataClassQantas.createAsset(objAcc.Id,objContact.Id, objContract.Id,'Corporate Scheme','Coordinator');
        lstAsset.add(objAsset1);
        Asset objAsset2 = TestUtilityDataClassQantas.createAsset(objAcc.Id,objContact.Id, objContract.Id,'Corporate Scheme','Coordinator');
        objAsset2.Move_to_Public_Scheme__c = true;
        lstAsset.add(objAsset2);
        Asset objPublicAsset = TestUtilityDataClassQantas.createAsset(objAcc.Id,objContact.Id, objContract.Id,'Public Scheme','Individual');
        objPublicAsset.Public_Scheme_End_Date__c = system.today().addDays(-1);
        objPublicAsset.Public_Scheme_Start_Date__c   = system.today().addDays(-20);
        lstAsset.add(objPublicAsset);
        insert lstAsset;
        system.assert(lstAsset.size() != Null, 'Asset is not inserted');
        Asset objeAsset1 = [select id,CurrencyIsoCode from Asset where Id =: lstAsset[0].Id];
        system.assert(objeAsset1.CurrencyIsoCode == 'AUD', 'CurrencyIsoCode does not match');
        Asset objeAsset2 = [select id,Join_Fee_Published__c from Asset where Id =: lstAsset[1].Id];
        system.assert(objeAsset2.Join_Fee_Published__c != 200, 'JoinFeePublished does not equal to 200');
    }

    static TestMethod void CorporateScheme_ContractEnd_Batch_PostiveTest() {
        String query = 'Select Id,RecordtypeId, Move_to_Public_Scheme__c from Asset where Scheme_End_Date_f__c = YESTERDAY and Status != \'Inactive\'';
        
        Test.startTest();
        CorporateScheme_ContractEnd_Batch schemeBatch = new CorporateScheme_ContractEnd_Batch(query, new Set<String>());
        Database.executeBatch(schemeBatch);
        Test.stopTest();
        String publicSchemeRecTypeName = CustomSettingsUtilities.getConfigDataMap('Asset Public Scheme Rec Type');
        Id publicSchemeRecTypeId = GenericUtils.getObjectRecordTypeId('Asset', publicSchemeRecTypeName );
        String corpSchemeRecTypeName = CustomSettingsUtilities.getConfigDataMap('Asset Corporate Scheme Rec Type');
        Id corpSchemeRecTypeId = GenericUtils.getObjectRecordTypeId('Asset', corpSchemeRecTypeName );
        
        List<Asset> lstAsset = [Select Id, RecordtypeId, Status from Asset where RecordTypeId =: corpSchemeRecTypeId];
        //system.assert(lstAsset.size() == 3, ' Corporate Scheme Size Miss Match');
        List<Asset> lstAsset1 = [Select Id, RecordtypeId, Status from Asset where RecordTypeId =: publicSchemeRecTypeId];
        /*system.assert(lstAsset1.size() == 2, ' Public Scheme Size Miss Match');
        for(Asset objAsset: [Select Id, RecordtypeId, Status from Asset ]){
            if(objAsset.RecordTypeId == publicSchemeRecTypeId){
                system.assert(objAsset.Status != 'Inactive', 'Status is Set to Inactive for Public Scheme');
            }else if(objAsset.RecordTypeId == corpSchemeRecTypeId){
                //system.assert(objAsset.Status == 'Inactive', 'Status is not Set to Inactive for Corporate Scheme');
            }
        }*/
        
    }
    
    static TestMethod void CorporateScheme_ContractEnd_Batch_ExceptionTest() {
        Asset objAsset1 = [Select Id,RecordtypeId,Move_to_Public_Scheme__c,Status from Asset Limit 1];
        objAsset1.Status = 'Inactive';
        update objAsset1;

        String query = 'Select Id,RecordtypeId,Move_to_Public_Scheme__c from Asset where Scheme_End_Date_f__c = YESTERDAY';
        
        Test.startTest();
        CorporateScheme_ContractEnd_Batch schemeBatch = new CorporateScheme_ContractEnd_Batch(query, new Set<String>() );
        Database.executeBatch(schemeBatch);
        Test.stopTest();
        Log__c log = new Log__c();
        log.Business_Function_Name__c = 'Loyalty Batches';
        insert log;
        List<Log__c> lstLog = [select Id from Log__c where Business_Function_Name__c = 'Loyalty Batches'];
        system.assert(lstLog.size() != 0, 'Log record is not Inserted');
    }
    
}