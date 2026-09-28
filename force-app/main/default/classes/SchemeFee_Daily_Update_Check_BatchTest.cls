@isTest(seeAllData = false)
private class SchemeFee_Daily_Update_Check_BatchTest {
    
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
        objOppty.Forecast_MCA_Revenue__c=50000;
        insert objOppty;
        system.assert(objOppty.Id != Null, 'Opportunity is not inserted');

        //Create Contract
        Contract__c objContract = TestUtilityDataClassQantas.createContract(objAcc.Id,objOppty.Id);
        objContract.CurrencyIsoCode='AUD';
        objContract.Name = 'TestContracts';
        objContract.Qantas_Club_Join_Discount_Offer__c = '7%';
        objContract.Qantas_Club_Join_Discount_Offer__c = '21%';
        objContract.QL_Effective_Tier__c='Tier 1';
        insert objContract;
        system.assert(objContract.Id != Null, 'Contract is not inserted');

        //Create Asset 
        List<Asset> lstAsset = new List<Asset>();
        lstAsset.add(TestUtilityDataClassQantas.createAsset(objAcc.Id,objContact.Id, objContract.Id,'Corporate Scheme','Coordinator'));
        lstAsset.add(TestUtilityDataClassQantas.createAsset(objAcc.Id,objContact.Id, objContract.Id,'Public Scheme','Individual'));
        Asset objAsset = TestUtilityDataClassQantas.createAsset(objAcc.Id,objContact.Id, objContract.Id,'Corporate Scheme','Coordinator');
        objAsset.Waiver_Start_Date__c = System.TODAY();
        objAsset.Waiver_End_Date__c = System.TODAY().addDays(1);
        objAsset.Qantas_Club_Join_Discount__c = 10;
        objAsset.Member_Fee_Discount__c = 12;
        lstAsset.add(objAsset);
        Asset objAsset1 = TestUtilityDataClassQantas.createAsset(objAcc.Id,objContact.Id, objContract.Id,'Corporate Scheme','Coordinator');
        lstAsset.add(objAsset1);
        insert lstAsset;
        system.assert(lstAsset.size() != Null, 'Asset is not inserted');
        Asset objeAsset1 = [select id,CurrencyIsoCode from Asset where Id =: lstAsset[0].Id];
        system.assert(objeAsset1.CurrencyIsoCode == 'AUD', 'CurrencyIsoCode does not match');
        Asset objeAsset2 = [select id,Join_Fee_Published__c from Asset where Id =: lstAsset[1].Id];
        system.assert(objeAsset2.Join_Fee_Published__c != 200, 'JoinFeePublished does not equal to 200');
    }


    static TestMethod void SchemeFee_Daily_Update_Check_Batch_AllAsset_PostiveTest() {
        Test.startTest();
        SchemeFee_Daily_Update_Check_Batch schemeBatch = new SchemeFee_Daily_Update_Check_Batch(true, null);
        Database.executeBatch(schemeBatch);
        Test.stopTest();
    }

    static TestMethod void SchemeFee_Daily_Update_Check_Batch_SchemeChange_PostiveTest() {
        List<SchemeFees__c> lstSchemeFee = [select Id, Scheme_Type__c, Currency__c, LastModifiedDate from SchemeFees__c];
        Test.startTest();
        SchemeFee_Daily_Update_Check_Batch schemeBatch = new SchemeFee_Daily_Update_Check_Batch(false, lstSchemeFee);
        Database.executeBatch(schemeBatch);
        Test.stopTest();
    }
    
    static TestMethod void SchemeFee_Daily_Update_Check_Batch_ExceptionTest() {
        Asset objAsset = [select Id from Asset where Status != 'Inactive' limit 1];
        objAsset.Status = 'Inactive';
        update objAsset;

        Asset objAsset1 = [select Id, Status from Asset where Id =: objAsset.Id];
        System.assert(objAsset1.Status == 'Inactive', 'Status is not updated to Inactive');

        String query = 'Select Id, Batch_Run__c from Asset where Id =\''+objAsset.Id+'\'';
        Test.startTest();
        SchemeFee_Daily_Update_Check_Batch schemeBatch = new SchemeFee_Daily_Update_Check_Batch(query);
        Database.executeBatch(schemeBatch);
        Test.stopTest();
    }
    
}