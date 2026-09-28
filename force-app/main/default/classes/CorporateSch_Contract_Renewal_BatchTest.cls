/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   Test Class for CorporateSch_Contract_Renewal_Batch
Inputs:
Test Class:    Not Required
************************************************************************************************
History
************************************************************************************************
26-May-2017    Praveen Sampath   InitialDesign
-----------------------------------------------------------------------------------------------------------------------*/
@isTest(seeAllData=false)
private class CorporateSch_Contract_Renewal_BatchTest {
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
        objContract.Contract_Start_Date__c = system.today().addDays(-200);
        objContract.Contract_End_Date__c = system.today().addDays(-1);
        objContract.QL_Effective_Tier__c='Tier 1';
        lstContract.add(objContract);
        Contract__c objContract1 = TestUtilityDataClassQantas.createContract(objAcc.Id,objOppty.Id);
        objContract1.CurrencyIsoCode='AUD';
        objContract1.Name = 'TestContracts1';
        objContract1.Qantas_Club_Join_Discount_Offer__c = '7%';
        objContract1.Qantas_Club_Join_Discount_Offer__c = '21%';
        objContract1.Contract_Start_Date__c = system.today();
        objContract1.Contract_End_Date__c = system.today().addDays(200);
        objContract1.QL_Discount_Model__c = 'Tiered';
        objContract1.QL_Effective_Tier__c = 'Tier 1';
        lstContract.add(objContract1);
        insert lstContract;
        system.assert(objContract.Id != Null, 'Contract is not inserted');
        system.assert(objContract1.Id != Null, 'Contract is not inserted');

        //Update prevoius Contract 
        /*objContract1.PreviousContract__c = objContract.Id;
        Update objContract1;*/

        //Create Asset 
        List<Asset> lstAsset = new List<Asset>();
        lstAsset.add(TestUtilityDataClassQantas.createAsset(objAcc.Id,objContact.Id, objContract.Id,'Corporate Scheme','Coordinator'));
        lstAsset.add(TestUtilityDataClassQantas.createAsset(objAcc.Id,objContact.Id, objContract.Id,'Public Scheme','Individual'));
        Asset objAsset = TestUtilityDataClassQantas.createAsset(objAcc.Id,objContact.Id, objContract.Id,'Corporate Scheme','Coordinator');
        objAsset.Waiver_Start_Date__c = System.TODAY().addDays(-20);
        objAsset.Waiver_End_Date__c = System.TODAY().addDays(-2);
        objAsset.Qantas_Club_Join_Discount__c = 10;
        objAsset.Member_Fee_Discount__c = 12;
        lstAsset.add(objAsset);
        Asset objAsset1 = TestUtilityDataClassQantas.createAsset(objAcc.Id,objContact.Id, objContract.Id,'Corporate Scheme','Coordinator');
        lstAsset.add(objAsset1);
        Asset objAsset2 = TestUtilityDataClassQantas.createAsset(objAcc.Id,objContact.Id, objContract.Id,'Corporate Scheme','Coordinator');
        objAsset2.Override_Fees_Calculation__c = true;
        objAsset2.Name = 'Test Asset Override';
        lstAsset.add(objAsset2);
        insert lstAsset;
        system.assert(lstAsset.size() != Null, 'Asset is not inserted');
        Asset objeAsset1 = [select id,CurrencyIsoCode from Asset where Id =: lstAsset[0].Id];
        system.assert(objeAsset1.CurrencyIsoCode == 'AUD', 'CurrencyIsoCode does not match');
        Asset objeAsset2 = [select id,Join_Fee_Published__c from Asset where Id =: lstAsset[1].Id];
        system.assert(objeAsset2.Join_Fee_Published__c != 200, 'JoinFeePublished does not equal to 200');
        Asset objeAsset3 = [select id,Join_Fee_Published__c from Asset where Id =: objAsset2.Id];
        system.assert(objeAsset3.Join_Fee_Published__c == Null, 'JoinFeePublished is equal to Null');
    }

    static TestMethod void CorporateScheme_Contract_Renewal_Batch_PostiveTest() {
        String query;
        query = 'select Id, PreviousContract__c, Type__c,  Contract_Start_Date__c, Contract_End_Date__c, Account__c  from Contract__c';
        query += ' where Contract_End_Date__c = YESTERDAY and Status__c = \'Signed by Customer\'';
                    
        Test.startTest();
        CorporateScheme_Contract_Renewal_Batch schemeBatch = new CorporateScheme_Contract_Renewal_Batch(query);
        Database.executeBatch(schemeBatch);
        Test.stopTest();
        Contract__c objCon = [select Id from Contract__c where Name = 'TestContracts1' limit 1];
        for(Asset objAsset: [select Id, Contract__c, Name, Override_Fees_Calculation__c from Asset 
                            where Scheme_Type__c = 'Coordinator'])
        {
            System.assert(objAsset.Contract__c == objCon.Id, ' Contract did not change');
            if(objAsset.Name == 'Test Asset Override'){
                system.assert(objAsset.Override_Fees_Calculation__c == false, 'Override Fees Calculation does  equal to true');
            }
        }
    }
    
    static TestMethod void CorporateScheme_Contract_Renewal_Batch_ExceptionTest() { 
        // Implement test code
        QantasConfigData__c config = [Select id from QantasConfigData__c where Name ='Asset Corporate Scheme Rec Type'];
        delete config;
        String query;
         query = 'select Id, PreviousContract__c, Type__c,  Contract_Start_Date__c, Contract_End_Date__c, Account__c  from Contract__c';
        query += ' where Contract_End_Date__c = YESTERDAY  and Status__c = \'Signed by Customer\'';
       
        Test.startTest();
        CorporateScheme_Contract_Renewal_Batch schemeBatch = new CorporateScheme_Contract_Renewal_Batch(query);
        Database.executeBatch(schemeBatch);
        Test.stopTest();
        Contract__c objCon = [select Id from Contract__c where Name = 'TestContracts' limit 1];
        system.debug('objCon#####'+objCon);
        for(Asset objAsset: [select Id, Contract__c,RecordTypeId from Asset where Scheme_Type__c = 'Coordinator']){
            system.debug('objAsset#########'+objAsset.Contract__c);
            System.assert(objAsset.Contract__c == objCon.Id, ' Contract changed durring exception');
        }
    }

    static TestMethod void CorporateScheme_Contract_Renewal_Batch_ValidationExceptionTest() { 
        // Implement test code
        String query;
        query = 'select Id, PreviousContract__c, Type__c,  Contract_Start_Date__c, Contract_End_Date__c, Account__c  from Contract__c';
        query += ' where Contract_End_Date__c = YESTERDAY  and Status__c = \'Signed by Customer\'';
        TestUtilityDataClassQantas.createDisableValidationRuleSetting();
        
        Account objAcc = [select Id from Account Limit 1];
        Contact objContact = TestUtilityDataClassQantas.createContact(objAcc.Id);
        objContact.LastName = 'ContTest4';
        objContact.Email = 'aa.as@as.com';
        objContact.Job_Title__c = '';
        insert objContact;

        system.assert(objContact.Id != Null, 'Contact is not inserted');
        Asset objAsset2 = [Select Id, Contract__c from Asset where Name = 'Test Asset Override' ];
        Id contractId = objAsset2.Contract__c;
        objAsset2.ContactId = objContact.Id;
        objAsset2.Status = 'Complete – Pending Activation';
        update objAsset2;
        Asset objAssets = [Select Status from Asset where Name = 'Test Asset Override'];
        system.debug(objAssets);
        system.assert(objAssets.Status == 'Active', 'Status is not Active');
        EnableValidationRule__c delValidation = [select id from EnableValidationRule__c where SetupOwnerId =: UserInfo.getUserId()];
        delete delValidation;

        Test.startTest();
        CorporateScheme_Contract_Renewal_Batch schemeBatch = new CorporateScheme_Contract_Renewal_Batch(query);
        Database.executeBatch(schemeBatch);
        Test.stopTest();
        
        /*for(Asset objAsset: [select Id, Contract__c,RecordTypeId, Name, Status from Asset where Scheme_Type__c = 'Coordinator']){
            system.debug('objAsset#########'+objAsset.Contract__c);
            system.debug('contractId'+contractId);
            if(objAsset.Name == 'Test Asset Override'){
                system.assert(objAsset.Contract__c != contractId, ' Contract changed durring exception');
                system.assert(objAsset.Status == 'Active', 'Asset Status is not Active');
            }
        }*/
        
        Contract__c objCon = [select Id from Contract__c where Name = 'TestContracts' limit 1];
        system.debug('objCon#####'+objCon);
        Asset objAsset = [select Id, Contract__c,RecordTypeId from Asset where Scheme_Type__c = 'Coordinator' limit 1];
            system.debug('objAsset#########'+objAsset.Contract__c);
            System.assert(objAsset.Contract__c != objCon.Id, ' Contract changed durring exception');
        }
     
    
}