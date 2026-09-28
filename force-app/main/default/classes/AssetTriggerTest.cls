/*----------------------------------------------------------------------------------------------------------------------
Author:        Benazir Amir/Praveen Sampath
Company:       Capgemini
Description:   Test Class for AssetTrigger Helper
Inputs:
Test Class:    Not Required
************************************************************************************************
History
************************************************************************************************
26-May-2017    Praveen Sampath   InitialDesign
-----------------------------------------------------------------------------------------------------------------------*/
@isTest(seeAllData = false)
private class AssetTriggerTest {

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
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC Individual Contact','Individual Contact'));
        insert lstConfigData;

               
        //Insert Scheme Fees Setting
        List<SchemeFees__c> lstSchemeData = new List<SchemeFees__c>();
        lstSchemeData.add(TestUtilityDataClassQantas.createSchemeFeesSetting('SchemeFee1', 420,65000,'AUD', 60000, 420, 750, null, null,200,'Corporate Scheme'));
        lstSchemeData.add(TestUtilityDataClassQantas.createSchemeFeesSetting('SchemeFee2', 420,65000, 'NZD', 60000, 420, 750, null, null,200,'Corporate Scheme'));
        //lstSchemeData.add(TestUtilityDataClassQantas.createSchemeFeesSetting('SchemeFee3', 420, 65000, '000', 60000, 420, 750, null,  null,200,'Corporate Scheme'));
        lstSchemeData.add(TestUtilityDataClassQantas.createSchemeFeesSetting('SchemeFee4', 420, 65000,'AUD', 60000, 420, 750, 150,  1500,200,'Public Scheme'));
        lstSchemeData.add(TestUtilityDataClassQantas.createSchemeFeesSetting('SchemeFee5', 420, 65000,'NZD', 60000, 420, 750, 150,  1500,200,'Public Scheme'));
        //lstSchemeData.add(TestUtilityDataClassQantas.createSchemeFeesSetting('SchemeFee6', 420, 65000, '000', 60000, 420, 750, 150,  1500,200,'Public Scheme'));
        lstSchemeData.add(TestUtilityDataClassQantas.createSchemeFeesSetting('SchemeFee7', 420, 65000, 'AUD', 60000, 420, 750, 150,  1500,200,'Retail'));
        lstSchemeData.add(TestUtilityDataClassQantas.createSchemeFeesSetting('SchemeFee8', 420,65000, 'NZD', 60000, 420, 750, 150,  1500,200,'Retail'));
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
        //Contact objContact = TestUtilityDataClassQantas.createContact(objAcc.Id);
        //GRAPHITE-934
        Contact objContact = TestUtilityDataClassQantas.createIndividualContact(objAcc.Id);
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
        Contract__c objContract = TestUtilityDataClassQantas.createContract(objAcc.Id,objOppty.Id);
        objContract.CurrencyIsoCode='AUD';
        objContract.Name = 'TestContracts';
        objContract.Qantas_Club_Join_Discount_Offer__c = '7%';
        objContract.Qantas_Club_Join_Discount_Offer__c = '21%';
        objContract.QL_Discount_Model__c ='Tiered';
        objContract.QL_Effective_Tier__c ='Tier 1';
        insert objContract;
        system.assert(objContract.Id != Null, 'Contract is not inserted');
        
    }
    
    static TestMethod void calculateFeesandDiscountsPositiveTest() {
        Account acc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        Contact con = [Select Id, LastName From Contact where LastName = 'ContTest2'];
        Opportunity oppty = [Select Id,Name From Opportunity where Name = 'OppTest2'];
        Contract__c cont = [Select Id,Name From Contract__c where Name ='TestContracts']; 
        // Implement test code
        
        Test.startTest();
        //Create Asset 
        List<Asset> lstAsset = new List<Asset>();
        lstAsset.add(TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Corporate Scheme','Coordinator'));
        lstAsset.add(TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Public Scheme','Individual'));
        Asset objAsset = TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Corporate Scheme','Coordinator');
        objAsset.Waiver_Start_Date__c = System.TODAY();
        objAsset.Waiver_End_Date__c = System.TODAY().addDays(1);
        objAsset.Qantas_Club_Join_Discount__c = 10;
        objAsset.Member_Fee_Discount__c = 12;
        lstAsset.add(objAsset);
        insert lstAsset;
        system.assert(lstAsset.size() != Null, 'Asset is not inserted');
        Test.stopTest();
        Asset objeAsset1 = [select id,CurrencyIsoCode from Asset where Id =: lstAsset[0].Id];
        
        system.assert(objeAsset1.CurrencyIsoCode == 'AUD', 'CurrencyIsoCode does not match');
        Asset objeAsset2 = [select id,Join_Fee_Published__c from Asset where Id =: lstAsset[1].Id];
        system.assert(objeAsset2.Join_Fee_Published__c != 200, 'JoinFeePublished does not equal to 200');
    }

    static TestMethod void calculateFeesandDiscountsforOverrideTrueTest() {
        Account acc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        Contact con = [Select Id, LastName From Contact where LastName = 'ContTest2'];
        Opportunity oppty = [Select Id,Name From Opportunity where Name = 'OppTest2'];
        Contract__c cont = [Select Id,Name From Contract__c where Name ='TestContracts']; 
        // Implement test code
        
        Test.startTest();
        //Create Asset 
        List<Asset> lstAsset = new List<Asset>();
        Asset objAsset = TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Corporate Scheme','Coordinator');
        objAsset.Waiver_Start_Date__c = System.TODAY();
        objAsset.Waiver_End_Date__c = System.TODAY().addDays(1);
        objAsset.Qantas_Club_Join_Discount__c = 10;
        objAsset.Member_Fee_Discount__c = 12;
        objAsset.Override_Fees_Calculation__c = true;
        lstAsset.add(objAsset);
        insert lstAsset;
        system.assert(lstAsset.size() != Null, 'Asset is not inserted');
        Test.stopTest();
        Asset objeAsset1 = [select id,Join_Fee_Published__c from Asset where Id =: lstAsset[0].Id];
        
        system.assert(objeAsset1.Join_Fee_Published__c ==200, 'JoinFeePublished is equal to 200');
    }

    static TestMethod void calculateFeesandDiscountsExceptionTest() {
        Account acc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        Contact con = [Select Id, LastName From Contact where LastName = 'ContTest2'];
        Opportunity oppty = [Select Id,Name From Opportunity where Name = 'OppTest2'];
        Contract__c cont = [Select Id,Name From Contract__c where Name ='TestContracts']; 
        // Implement test code
        
        Test.startTest();
        //Create Asset 
        List<Asset> lstAsset = new List<Asset>();
        lstAsset.add(TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Public Scheme','Coordinator'));
        Asset objAsset = TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Corporate Scheme','Coordinator');
        objAsset.Scheme_Currency__c ='USD';
        lstAsset.add(objAsset);
        insert lstAsset;
        
        Test.stopTest();
        List<Log__c> lstLog = [select Id from Log__c where Business_Function_Name__c = 'Asset Triggers - Loyalty'];
        system.assert(lstLog.size() != 0, 'Log record is not Inserted');
        
    }

    static TestMethod void convertingAssetTypePositiveCorptoPublicTest(){
        Account acc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        Contact con = [Select Id, LastName From Contact where LastName = 'ContTest2'];
        Opportunity oppty = [Select Id,Name From Opportunity where Name = 'OppTest2'];
        Contract__c cont = [Select Id,Name From Contract__c where Name ='TestContracts'];
        //Create Asset 
        List<Asset> lstAsset = new List<Asset>();
        //lstAsset.add(TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Corporate Scheme','Coordinator'));
        //lstAsset.add(TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Public Scheme','Individual'));
        Asset objAsset = TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Corporate Scheme','Coordinator');
        objAsset.Waiver_Start_Date__c = System.TODAY();
        objAsset.Waiver_End_Date__c = System.TODAY().addDays(1);
        objAsset.Qantas_Club_Join_Discount__c = 10;
        objAsset.Member_Fee_Discount__c = 12;
        objAsset.Scheme_Number__c = '4587412';
        lstAsset.add(objAsset);
        insert lstAsset; 
        system.assert(lstAsset.size() != Null, 'Asset is not inserted');
        // Implement test code
        
        Test.startTest();
        //String corpSchemeRecTypeName = CustomSettingsUtilities.getConfigDataMap('Asset Corporate Scheme Rec Type');
        //Id corpSchemeRecTypeId = GenericUtils.getObjectRecordTypeId('Asset', corpSchemeRecTypeName );
        String publicSchemeRecTypeName = CustomSettingsUtilities.getConfigDataMap('Asset Public Scheme Rec Type');
        Id publicSchemeRecTypeId = GenericUtils.getObjectRecordTypeId('Asset', publicSchemeRecTypeName );
            
        objAsset.RecordtypeId = publicSchemeRecTypeId;
        update objAsset;

        
        Test.stopTest();
        Asset objeAsset1 = [select id,Contract__c, Waiver_Start_Date__c, Waiver_End_Date__c,
                            Scheme_Cost_Center__c,Scheme_Discount_Type__c  from Asset where Id =: objAsset.Id];
        system.assert(objeAsset1.Contract__c == Null, 'Contract is not Blanked');
        system.assert(objeAsset1.Waiver_Start_Date__c == Null, 'Wavier Check is still not Blank');
        system.assert(objeAsset1.Waiver_End_Date__c == Null, 'Wavier Check is still not Blank');        
        system.assert(objeAsset1.Scheme_Cost_Center__c == 'Public', 'Scheme Cost Center is not set to Public');        
        system.assert(objeAsset1.Scheme_Discount_Type__c == 'Public Scheme', 'Discount Type is not set to Public Scheme');        
    }

    static TestMethod void convertingAssetTypePositivePublictoCorpTest(){
        Account acc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        Contact con = [Select Id, LastName From Contact where LastName = 'ContTest2'];
        Opportunity oppty = [Select Id,Name From Opportunity where Name = 'OppTest2'];
        Contract__c cont = [Select Id,Name From Contract__c where Name ='TestContracts'];
        //Create Asset 
        List<Asset> lstAsset = new List<Asset>();
        lstAsset.add(TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Corporate Scheme','Coordinator'));
        lstAsset.add(TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Public Scheme','Individual'));
        Asset objAsset = TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Corporate Scheme','Coordinator');
        objAsset.Waiver_Start_Date__c = System.TODAY();
        objAsset.Waiver_End_Date__c = System.TODAY().addDays(1);
        objAsset.Qantas_Club_Join_Discount__c = 10;
        objAsset.Member_Fee_Discount__c = 12;
        lstAsset.add(objAsset);
        insert lstAsset; 
        system.assert(lstAsset.size() != Null, 'Asset is not inserted');
        // Implement test code
        
        Test.startTest();
        String corpSchemeRecTypeName = CustomSettingsUtilities.getConfigDataMap('Asset Corporate Scheme Rec Type');
        Id corpSchemeRecTypeId = GenericUtils.getObjectRecordTypeId('Asset', corpSchemeRecTypeName );
            
        lstAsset[1].RecordtypeId = corpSchemeRecTypeId;
        lstAsset[1].Contract__c = cont.Id;
        lstAsset[1].Scheme_Cost_Center__c = '1243';
        update lstAsset[1];

        
        Test.stopTest();
        Asset objeAsset1 = [select id, Below_Threshold__c, Scheme_Discount_Type__c  from Asset where Id =: lstAsset[1].Id];
        system.assert(objeAsset1.Below_Threshold__c != true, 'Below Threshold is set for Corp Asset');
        system.assert(objeAsset1.Scheme_Discount_Type__c == 'Corporate Scheme', 'Discount Type is not set to Corporate Scheme');
    }

    static TestMethod void convertingAssetTypeExceptionTest(){
        Account acc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        Contact con = [Select Id, LastName From Contact where LastName = 'ContTest2'];
        Opportunity oppty = [Select Id,Name From Opportunity where Name = 'OppTest2'];
        Contract__c cont = [Select Id,Name From Contract__c where Name ='TestContracts'];
        //Create Asset 
        List<Asset> lstAsset = new List<Asset>();
        lstAsset.add(TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Corporate Scheme','Coordinator'));
        Asset objAsset = TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Public Scheme','Individual');
        lstAsset.add(objAsset);
        insert lstAsset; 
        system.assert(lstAsset.size() != Null, 'Asset is not inserted');
        // Implement test code
        
        Test.startTest();
        String publicSchemeRecTypeName = CustomSettingsUtilities.getConfigDataMap('Asset Public Scheme Rec Type');
        Id publicSchemeRecTypeId = GenericUtils.getObjectRecordTypeId('Asset', publicSchemeRecTypeName );
        String corpSchemeRecTypeName = CustomSettingsUtilities.getConfigDataMap('Asset Corporate Scheme Rec Type');
        Id corpSchemeRecTypeId = GenericUtils.getObjectRecordTypeId('Asset', corpSchemeRecTypeName );
        QantasConfigData__c config = [Select id from QantasConfigData__c where Name ='Asset Corporate Scheme Rec Type'];
        delete config;
        
        objAsset = [Select Id, Scheme_Cost_Center__c from Asset where RecordtypeId =: publicSchemeRecTypeId limit 1]; 
        objAsset.RecordtypeId = corpSchemeRecTypeId;
        objAsset.Contract__c = cont.Id;
        update objAsset;
          
        Test.stopTest();
        Asset objeAsset1 = [select id, RecordtypeId, Scheme_Cost_Center__c  from Asset where Id =: objAsset.Id];
        system.assert(objeAsset1.RecordtypeId == corpSchemeRecTypeId, 'Record type Id is not changed');
    }

    //Recortype Change Validation check  -VR_To_Check_SchemeCostCenter_OnConversio
    static TestMethod void RecorTypeVRCheck(){
        Account acc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        Contact con = [Select Id, LastName,FirstName,Job_Role__c,Job_Title__c,Phone,Email,MailingCountry,MailingStreet,MailingCity,MailingState,MailingPostalCode,Salutation From Contact where LastName = 'ContTest2'];
        Opportunity oppty = [Select Id,Name From Opportunity where Name = 'OppTest2'];
        Contract__c cont = [Select Id,Name From Contract__c where Name ='TestContracts'];
        //Create Asset 
        List<Asset> lstAsset = new List<Asset>();
        lstAsset.add(TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Corporate Scheme','Coordinator'));
        Asset objAsset = TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Public Scheme','Individual');
        objAsset.Scheme_Cost_Center__c = 'Public';
        lstAsset.add(objAsset);
        insert lstAsset; 
        system.assert(lstAsset.size() != Null, 'Asset is not inserted');
        // Implement test code
        
        Test.startTest();
        String publicSchemeRecTypeName = CustomSettingsUtilities.getConfigDataMap('Asset Public Scheme Rec Type');
        Id publicSchemeRecTypeId = GenericUtils.getObjectRecordTypeId('Asset', publicSchemeRecTypeName );
        String corpSchemeRecTypeName = CustomSettingsUtilities.getConfigDataMap('Asset Corporate Scheme Rec Type');
        Id corpSchemeRecTypeId = GenericUtils.getObjectRecordTypeId('Asset', corpSchemeRecTypeName );
        objAsset = [Select Id, Scheme_Cost_Center__c from Asset where RecordtypeId =: publicSchemeRecTypeId limit 1]; 
        system.assert(objAsset.Scheme_Cost_Center__c == 'Public', 'Scheme Cost Center is not set to Public');
        lstAsset[1].RecordtypeId = corpSchemeRecTypeId;
        lstAsset[1].Contract__c = cont.Id;
        try{
            insert objAsset;
           }catch(Exception ex){
            system.assert(ex.getTypeName() == 'System.DmlException', 'VR_MandatoryCheck_Active_PublicScheme Validationrule is not Working');
        }

        Test.stopTest();
        Asset objeAsset1 = [select id, RecordtypeId, Scheme_Cost_Center__c  from Asset where Id =: lstAsset[1].Id];
        system.assert(objAsset.Scheme_Cost_Center__c == 'Public', 'Scheme Cost Center is not set to Public');
        system.assert(objeAsset1.RecordtypeId != corpSchemeRecTypeId, 'Record type Id is changed');
    }

    //Asset Mandatory Check for Active Corporate Scheme -VR_MandatoryCheck_Active_PublicScheme
     static TestMethod void mandatoryCheckActivePublicSchemeTest() {
        Account acc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        Contact con = [Select Id, LastName From Contact where LastName = 'ContTest2'];
        Opportunity oppty = [Select Id,Name From Opportunity where Name = 'OppTest2'];
        Contract__c cont = [Select Id,Name From Contract__c where Name ='TestContracts']; 

        Test.startTest();
        Asset objAsset = TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Public Scheme','Coordinator');
        objAsset.Status = 'Active';
        objAsset.Account = Null;
        objAsset.Contact = Null;
            try{
                insert objAsset;
               }catch(Exception ex){
                system.assert(ex.getTypeName() == 'System.DmlException', 'VR_MandatoryCheck_Active_PublicScheme Validationrule is not Working');
            }
 
       Test.stopTest();
    }


    //Asset Mandatory Check Before Activating Corporate Scheme -VR_MandatoryCheck_BefActivation_CorpScheme
     static TestMethod void mandatoryCheckBeforeActivatingPublicSchemeTest() {
        Account acc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        Contact con = [Select Id, LastName From Contact where LastName = 'ContTest2'];
        Opportunity oppty = [Select Id,Name From Opportunity where Name = 'OppTest2'];
        Contract__c cont = [Select Id,Name From Contract__c where Name ='TestContracts']; 

        Test.startTest();
        Asset objAsset = TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Public Scheme','Coordinator');
        objAsset.Status = 'Active';
        objAsset.Account = Null;
        objAsset.Contact = Null;
        objAsset.Contract__c = Null;
            try{
                insert objAsset;
               }catch(Exception ex){
                system.assert(ex.getTypeName() == 'System.DmlException', 'VR_MandatoryCheck_BefActivation_CorpScheme Validationrule is not Working');
            }
 
       Test.stopTest();
    }
    
    //Check if Asset is not reverted back on its Status - VR_To_Check_If_Status_Not_RevretedBack
     static TestMethod void noRevertedBackStatusTest() {
        Account acc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        Contact con = [Select Id, LastName From Contact where LastName = 'ContTest2'];
        Opportunity oppty = [Select Id,Name From Opportunity where Name = 'OppTest2'];
        Contract__c cont = [Select Id,Name From Contract__c where Name ='TestContracts']; 

        Test.startTest();
        Asset objAsset = TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Public Scheme','Coordinator');
        objAsset.Status = 'Active';
        objAsset.Account = Null;
        objAsset.Contact = Null;
        objAsset.Contract__c = Null;
            try{
                insert objAsset;
                objAsset.Status = 'Draft';
                update objAsset;
               }catch(Exception ex){
                system.assert(ex.getTypeName() == 'System.DmlException', 'VR_To_Check_If_Status_Not_RevretedBack Validationrule is not Working');
            }
 
       Test.stopTest();
    }

     //Check if Asset is not Edited with its Start Date - VR_To_Prevent_Editing_StartDate
     static TestMethod void noStartDateUpdateTest() {
        Account acc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        Contact con = [Select Id, LastName From Contact where LastName = 'ContTest2'];
        Opportunity oppty = [Select Id,Name From Opportunity where Name = 'OppTest2'];
        Contract__c cont = [Select Id,Name From Contract__c where Name ='TestContracts']; 

        Test.startTest();
        Asset objAsset = TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Public Scheme','Coordinator');
        objAsset.Status = 'Active';
        objAsset.Public_Scheme_Start_Date__c  = System.today();
            try{
                insert objAsset;
                 objAsset.Public_Scheme_Start_Date__c  = System.today().addDays(1);
                update objAsset;
               }catch(Exception ex){
                system.assert(ex.getTypeName() == 'System.DmlException', 'VR_To_Prevent_Editing_StartDate Validationrule is not Working');
            }
 
       Test.stopTest();
    }

    //Check if Asset is not Edited with Inactive Status - VR_To_Prevent_Updating_Inactive_Asset
     static TestMethod void noInactiveAssetUpdateTest() {
        Account acc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        Contact con = [Select Id, LastName From Contact where LastName = 'ContTest2'];
        Opportunity oppty = [Select Id,Name From Opportunity where Name = 'OppTest2'];
        Contract__c cont = [Select Id,Name From Contract__c where Name ='TestContracts']; 

        Test.startTest();
        Asset objAsset = TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Corporate Scheme','Coordinator');
        objAsset.Status = 'Inactive';
        
         try{
               insert objAsset;
               objAsset.Public_Scheme_Start_Date__c  = System.today().addDays(1);
               update objAsset;
               }catch(Exception ex){
                system.assert(ex.getTypeName() == 'System.DmlException', 'VR_To_Prevent_Updating_Inactive_Asset Validationrule is not Working');
            }
 
       Test.stopTest();
    }

    //Check if Asset is present with Waiver Dates - VR_To_Prevent_Wavier_Dates_Missing
     static TestMethod void noWaiverDateUpdateTest() {
        Account acc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        Contact con = [Select Id, LastName From Contact where LastName = 'ContTest2'];
        Opportunity oppty = [Select Id,Name From Opportunity where Name = 'OppTest2'];
        Contract__c cont = [Select Id,Name From Contract__c where Name ='TestContracts']; 

        Test.startTest();
        Asset objAsset = TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Corporate Scheme','Coordinator');
        objAsset.Status = 'Active';
        objAsset.Waiver_Start_Date__c = Null;
        objAsset.Waiver_End_Date__c = System.today();
        
         try{
               insert objAsset;
               }catch(Exception ex){
                system.assert(ex.getTypeName() == 'System.DmlException', 'VR_To_Prevent_Wavier_Dates_Missing Validationrule is not Working');
            }
 
       Test.stopTest();
    }

    //Check if Asset is present with Waiver Dates - VR_To_Prevent_WEndDT_Lessthan_WStartDT
     static TestMethod void waiverEndDateCheckTest() {
        Account acc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        Contact con = [Select Id, LastName From Contact where LastName = 'ContTest2'];
        Opportunity oppty = [Select Id,Name From Opportunity where Name = 'OppTest2'];
        Contract__c cont = [Select Id,Name From Contract__c where Name ='TestContracts']; 

        Test.startTest();
        Asset objAsset = TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Corporate Scheme','Coordinator');
        objAsset.Status = 'Active';
        objAsset.Waiver_Start_Date__c = Null;
        objAsset.Waiver_End_Date__c = System.today();
        
         try{
               insert objAsset;
               }catch(Exception ex){
                system.assert(ex.getTypeName() == 'System.DmlException', 'VR_To_Prevent_WEndDT_Lessthan_WStartDT Validationrule is not Working');
            }
 
       Test.stopTest();
    }

    //Check if Asset Wavier End Date is lessthan are equal to Scheme end date - VR_To_prevent_WEndDT_Lowerthan_SchEndDT
     static TestMethod void waiverEndDateTest() {
        Account acc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        Contact con = [Select Id, LastName From Contact where LastName = 'ContTest2'];
        Opportunity oppty = [Select Id,Name From Opportunity where Name = 'OppTest2'];
        Contract__c cont = [Select Id,Name From Contract__c where Name ='TestContracts']; 

        Test.startTest();
        Asset objAsset = TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Public Scheme','Individual');
        objAsset.Status = 'Active';
        objAsset.Waiver_End_Date__c = System.today();
        
         try{
               insert objAsset;
               objAsset.Public_Scheme_End_Date__c  = System.today().addDays(-2);
               update objAsset;
               }catch(Exception ex){ 
                system.assert(ex.getTypeName() == 'System.DmlException', 'VR_To_prevent_WEndDT_Lowerthan_SchEndDT Validationrule is not Working');
            } 
 
       Test.stopTest();
    }

    //Check if Asset Public Scheme Start Date is Today or Future Date - VR_To_Prevent_Past_StartDate_On_Pub_SCH
     static TestMethod void schemeStartDateTest() {
        Account acc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        Contact con = [Select Id, LastName From Contact where LastName = 'ContTest2'];
        Opportunity oppty = [Select Id,Name From Opportunity where Name = 'OppTest2'];
        Contract__c cont = [Select Id,Name From Contract__c where Name ='TestContracts']; 

        Test.startTest();
        Asset objAsset = TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Public Scheme','Individual');
        objAsset.Status = 'Complete – Pending Activation';
        objAsset.Public_Scheme_Start_Date__c  = System.today().addDays(-2);
        
         try{
               insert objAsset;
               }catch(Exception ex){ 
                system.assert(ex.getTypeName() == 'System.DmlException', 'VR_To_Prevent_Past_StartDate_On_Pub_SCH Validationrule is not Working');
            } 
 
       Test.stopTest();
    }

    //Check if Asset SchemeType is changed - VR_To_Prevent_Changing_the_Scheme_Types
     static TestMethod void changeSchemeTest() {
        Account acc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        Contact con = [Select Id, LastName From Contact where LastName = 'ContTest2'];
        Opportunity oppty = [Select Id,Name From Opportunity where Name = 'OppTest2'];
        Contract__c cont = [Select Id,Name From Contract__c where Name ='TestContracts']; 
        Id corporateSchemeId = GenericUtils.getObjectRecordTypeId('Asset', 'Corporate Scheme');

        Test.startTest();
        Asset objAsset = TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Public Scheme','Individual');
        objAsset.Status = 'Active';
        
        
         try{
               objAsset.RecordTypeId = corporateSchemeId;
               insert objAsset;
               }catch(Exception ex){ 
                system.assert(ex.getTypeName() == 'System.DmlException', 'VR_To_Prevent_Changing_the_Scheme_Types Validationrule is not Working');
            } 
 
       Test.stopTest();
    }

    //Public Scheme End Date should be greater than Public Scheme Start Date - VR_To_Check_PubSch_EndDT_Lessthan_StarDT
     static TestMethod void checkDateSchemeTest() {
        Account acc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        Contact con = [Select Id, LastName From Contact where LastName = 'ContTest2'];
        Opportunity oppty = [Select Id,Name From Opportunity where Name = 'OppTest2'];
        Contract__c cont = [Select Id,Name From Contract__c where Name ='TestContracts']; 

        Test.startTest();
        Asset objAsset = TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Public Scheme','Individual');
        objAsset.Status = 'Complete – Pending Activation';
        objAsset.Public_Scheme_Start_Date__c  = System.today();
        objAsset.Public_Scheme_End_Date__c = System.today().addDays(-2);
        
         try{
               insert objAsset;
               }catch(Exception ex){ 
                system.assert(ex.getTypeName() == 'System.DmlException', 'VR_To_Check_PubSch_EndDT_Lessthan_StarDT Validationrule is not Working');
            } 
 
       Test.stopTest();
    }

     //Check if Corporate Scheme can't be moved to Inactive when it is linked to an Active Contract. Please contact the Administrator. - VR_To_Prevent_Inactivate_Corp_Scheme
     static TestMethod void assetStatusInactiveCheckTest() {
        Account acc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        Contact con = [Select Id, LastName From Contact where LastName = 'ContTest2'];
        Opportunity oppty = [Select Id,Name From Opportunity where Name = 'OppTest2'];
        Contract__c cont = [Select Id,Name From Contract__c where Name ='TestContracts']; 

        Test.startTest();

        Asset objAsset = TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Corporate Scheme','Coordinator');
        objAsset.Status = 'Active';
        
        
         try{
               insert objAsset;
               objAsset.Status = 'Inactive';
               update objAsset;
               }catch(Exception ex){
                system.assert(ex.getTypeName() == 'System.DmlException', 'VR_To_Prevent_Inactivate_Corp_Scheme Validationrule is not Working');
            }
 
       Test.stopTest();
    }

    // check Overrride Threshold to Modify Scheme type from Reatil.- VR_To_Prevent_SchType_Change_from_Retail
     static TestMethod void assetOvevrrideThresholdCheckTest() {
        Account acc = [Select Id, Aquire_Membership_Number__c From Account where Active__c = true];
        Contact con = [Select Id, LastName From Contact where LastName = 'ContTest2'];
        Opportunity oppty = [Select Id,Name From Opportunity where Name = 'OppTest2'];
        Contract__c cont = [Select Id,Name From Contract__c where Name ='TestContracts']; 

        Test.startTest();

        Asset objAsset = TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Public Scheme','Coordinator');
        objAsset.Status = 'Active';
        objAsset.Scheme_Type__c ='Retail';
        objAsset.Override_Threshold__c = false;
        
         try{
               insert objAsset;
              }catch(Exception ex){
                system.assert(ex.getTypeName() == 'System.DmlException', 'VR_To_Prevent_SchType_Change_from_Retail Validationrule is not Working');
            }
 
       Test.stopTest();
    }

    //Override/Wavier Start Date Should be lower than Scheme Start Date-VR_To_Prevent_WavStrDT_High_of_Sch_StrDT

     static TestMethod void assetOvevrrideStartDateCheckTest() {
        Account acc = [Select Id,OwnerId, Aquire_Membership_Number__c From Account where Active__c = true];
        Contact con = [Select Id, LastName From Contact where LastName = 'ContTest2'];
        Opportunity oppty = [Select Id,Name From Opportunity where Name = 'OppTest2'];
        Contract__c cont = [Select Id,Name From Contract__c where Name ='TestContracts']; 

        Test.startTest();

        Asset objAsset = TestUtilityDataClassQantas.createAsset(acc.Id,con.Id,cont.Id,'Public Scheme','Coordinator');
        objAsset.Status = 'Active';
        objAsset.Waiver_Start_Date__c = System.today().addDays(-2);
        
         try{
               insert objAsset;
              }catch(Exception ex){
                system.assert(ex.getTypeName() == 'System.DmlException', 'VR_To_Prevent_WavStrDT_High_of_Sch_StrDT Validationrule is not Working');
            }
         AssetObjectHelper.convertPublicSchmeToCorporateSchemeUI(objAsset, acc.OwnerId); //CRM-10164
 
       Test.stopTest();
    }
    
}