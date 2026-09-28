/***********************************************************************************************************************
Author:        Gnanavelu
Description:   Test Class for QL_AccountHandover
************************************************************************************************************************/
@isTest
public class QL_AccountHandoverTest {
    @testSetup
    static void createTestData(){     
        
        //Enable Asset Triggers
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createAccountTriggerSettingasTrue();
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAssetTriggerSetting());
        lsttrgStatus.addAll(TestUtilityDataClassQantas.createContractTriggerSetting());
        TestUtilityDataClassQantas.enableTriggers();
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
        objAcc.Type = 'Customer Account';
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
        objContract.QL_Effective_Tier__c = 'Tier 1';
        lstContract.add(objContract);
        insert lstContract;
        system.assert(objContract.Id != Null, 'Contract is not inserted');
        
        
        //Create Asset 
        List<Asset> lstAsset = new List<Asset>();
        lstAsset.add(TestUtilityDataClassQantas.createAsset(objAcc.Id,objContact.Id, objContract.Id,'Corporate Scheme','Coordinator'));
        Asset objAsset = TestUtilityDataClassQantas.createAsset(objAcc.Id,objContact.Id, objContract.Id,'Corporate Scheme','Coordinator');
        lstAsset.add(objAsset);
        insert lstAsset;
        
        //Create case
        List<Case> cases = new List<Case>();
        Id accHandoverRecordType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Account_Handover').getRecordTypeId();
        Case caseObj = new Case(AccountId = objAcc.Id, Status = 'with Salesforce Support Admin Team', New_Portfolio__c = 'Other',
                                New_Owner__c = 'Data UpdatesUser', RecordTypeId = accHandoverRecordType);
        cases.add(caseObj);
        Case caseObj1 = new Case(AccountId = objAcc.Id, Status = 'with Salesforce Support Admin Team', New_Portfolio__c = 'Resources',
                                New_Owner__c = 'Data UpdatesUser', RecordTypeId = accHandoverRecordType, Approved__c = true);        
        cases.add(caseObj1);
        insert cases;
        
        //Create related list
        List<sObject> relatedLists =  new List<sObject>();
        Account_Relation__c accRelation = new Account_Relation__c(Related_Account__c = objAcc.Id, Relationship__c = 'Group Travel Manager Of',
                                                                  Start_Date__c = system.today(), End_Date__c = system.today(), Group_Agent_Name__c = 'HP solutions',
                                                                  Group_Agent_Email__c = 'hpsolutions@hplaptops.com');
        relatedLists.add(accRelation); 
        
        Strategic_Account_Plan__c sap = new Strategic_Account_Plan__c(Name = 'Jan 2020', Status__c = 'Active', Account__c = objAcc.Id,
                                                                      Account_Manager_user__c = UserInfo.getUserId(), Plan_Start_Date__c = system.today(),
                                                                      Plan_End_Date__c = system.today(), Review_Cycle__c = 'Quarterly',Business_Overview__c = 'No matter what the project, you will be happy you chose Beaumonts.');
        relatedLists.add(sap);
        
        Id campRecordtype = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Learning_Development').getRecordTypeId();
        Campaign camp = new Campaign(Name = 'Your Business',RecordTypeId = campRecordtype, LookupAccount__c = objAcc.Id);
        relatedLists.add(camp);
        
        insert relatedLists;
        
    }
    
    @isTest
    static void HandoverAccountTest()
    {
        List<Group> salesANDadminQueue = [select Id, Name from Group where Type = 'Queue' 
                                          AND (DeveloperName = 'Sales_Performance_Team' OR DeveloperName = 'System_Admin_Request_Queue') 
                                          ORDER BY Name];
        Test.startTest();
        //Checking Close case
        QL_AccountHandover.HandoverAccounts(salesANDadminQueue[1].Id, 0);
        Test.stopTest();
    }
}