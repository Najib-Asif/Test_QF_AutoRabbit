/***********************************************************************************************************************************

Description: Apex Test class for QAC_AccountRetrievalAPI Class 

History:
======================================================================================================================
Name                          Description                                                 Tag
======================================================================================================================
Abhijeet                      Test class for TMC retrieval class                      T01
                                    
Created Date    :   16/02/18 (DD/MM/YYYY)

Main Class      :   QAC_AgencyPrimaryDetailsUpdate

Modified By : Venkata Suresh Kumar (TCS Team), 02-Apr-2026
Desc : Remediated test class failures. Updated setup() method.
**********************************************************************************************************************************/

@IsTest
public class QAC_AgencyPrimaryDetailsUpdate_Test {
    public Map<id,string> nOpenCases;
    
    @testSetup
    public static void setup() {
        
        system.debug('inside test setup**');
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        
        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Integration Logs Rec Type',Config_Value__c = 'Integration Logs');
        insert qcd;
        
        QantasConfigData__c qcd2 = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd2;
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();                       //CIAM
        //Inserting Account
        Account acc = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                  RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                  Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '4364557', QAC_Request_Pending__c=false);
        
        insert acc;
        
        Account acc1 = new Account(Name = 'Sample1', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                  RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565366',
                                  Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '4364558', QAC_Request_Pending__c=true);
        
        insert acc1;
        
        Account acc2 = new Account(Name = 'Sample2', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                  RecordTypeId = agencyRecordTypeId, Migrated__c = true,
                                  Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '4364559');
        
        insert acc2;
        
        Account relatedAcc = new Account(Name = 'Sample2', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                         RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                         Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '1000000', Qantas_Industry_Centre_ID__c = '1000000');
        
        insert relatedAcc;
        
        List<Trigger_Status__c> lsttrgStatus = TestUtilityDataClassQantas.createCaseTriggerSetting();
        insert lsttrgStatus;
        
        TestUtilityDataClassQantas.insertQantasConfigData();
        List<Qantas_API__c> lstQantas = TestUtilityDataClassQantas.createQantasAPI();
        insert lstQantas;

        List<QantasConfigData__c> lstConfigData = new List<QantasConfigData__c>();
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Exception Logs Rec Type','Exception Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('Log Integration Logs Rec Type','Integration Logs'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('RecoveryStatusApproved','Approved'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_FligjtCode Domestic','Domestic'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeDomestic','Emergency Expense - Domestic Stage'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_FligjtCode International','International'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeInternational','   Emergency Expense - International Stage'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('QCC_EmergencyOutcomeNotEligible','Not Eligible for Emergency Expenses'));
        lstConfigData.add(TestUtilityDataClassQantas.createQantasConfigData('CaseStatusClosed','Closed'));
            
        insert lstConfigData;
        
    } 
    
    // Testing positive scenario
    @isTest
    public static void testParse() 
    {
        string caseRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Maintenance').getRecordTypeId();
        Account agencyAccount = [SELECT Id, IATA_Number__c,QAC_Request_Pending__c FROM Account WHERE IATA_Number__c = '4364557' LIMIT 1];
        
        /**Case relatedCase = new Case(RecordTypeId = caseRecordTypeID, Accountid=agencyAccount.Id, Subject = 'Agency ('+agencyAccount.IATA_Number__c+ ') - Primary Details Update', 
                                    Description='Description', Origin = 'QAC Website', Type = 'Agency Account', Sub_Type_1__c = 'Account Update', status='Open');
        
        insert relatedCase;
        
        Map<ID,String> openCases = new Map<ID,String>();
        
         if(relatedCase != null && relatedCase.Status != 'Closed')
            openCases.Put(relatedCase.Id,relatedCase.Status);**/
        
        QAC_AgencyPrimaryParsing primaryAgencyInfo = new QAC_AgencyPrimaryParsing(new Account());
        
        primaryAgencyInfo.accountId = agencyAccount.Id;
        primaryAgencyInfo.active    = TRUE;
        primaryAgencyInfo.agencyCode = '1244';
        primaryAgencyInfo.agencyABN = '1111111111';
        primaryAgencyInfo.agencySubChain = 'Test';
        primaryAgencyInfo.agencyTradingName =' Test';
        primaryAgencyInfo.isManualRequestPending = TRUE;
        primaryAgencyInfo.agencyChain = 'Test';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QACAgencyPrimaryInfo/4364557';  
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf(JSON.serializePretty(primaryAgencyInfo));
        
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        QAC_AgencyPrimaryDetailsUpdate.doTMCPrimaryUpdate();
        test.stopTest();
    
    }
    
    @isTest
    public static void testParse_1() 
    {
        string caseRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Maintenance').getRecordTypeId();
        Account agencyAccount = [SELECT Id, IATA_Number__c,QAC_Request_Pending__c FROM Account WHERE IATA_Number__c = '4364557' LIMIT 1];
        
        Case relatedCase = new Case(RecordTypeId = caseRecordTypeID, Accountid=agencyAccount.Id, Subject = 'Agency ('+agencyAccount.IATA_Number__c+ ') - Primary Details Update', 
                                    Description='Description', Origin = 'QAC Website', Type = 'Agency Account', Sub_Type_1__c = 'Account Update', status='Open');
        
        insert relatedCase;
        
        Map<ID,String> openCases = new Map<ID,String>();
        
         if(relatedCase != null && relatedCase.Status != 'Closed')
            openCases.Put(relatedCase.Id,relatedCase.Status);
        
        QAC_AgencyPrimaryParsing primaryAgencyInfo = new QAC_AgencyPrimaryParsing(new Account());
        
        primaryAgencyInfo.accountId = agencyAccount.Id;
        primaryAgencyInfo.active    = TRUE;
        primaryAgencyInfo.agencyCode = '1244';
        primaryAgencyInfo.agencyABN = '1111111111';
        primaryAgencyInfo.agencySubChain = 'Test';
        primaryAgencyInfo.agencyTradingName =' Test';
        primaryAgencyInfo.isManualRequestPending = TRUE;
        primaryAgencyInfo.agencyChain = 'Test';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QACAgencyPrimaryInfo/4364557';  
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf(JSON.serializePretty(primaryAgencyInfo));
        
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        QAC_AgencyPrimaryDetailsUpdate.doTMCPrimaryUpdate();
        test.stopTest();
    
    }
    @isTest
    public static void testParse_2() 
    {
        string caseRecordTypeID = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Account Maintenance').getRecordTypeId();
        Account agencyAccount = [SELECT Id, IATA_Number__c,QAC_Request_Pending__c FROM Account WHERE IATA_Number__c = '4364558' LIMIT 1];
        
        Case relatedCase = new Case(RecordTypeId = caseRecordTypeID, Accountid=agencyAccount.Id, Subject = 'Agency ('+agencyAccount.IATA_Number__c+ ') - Primary Details Update', 
                                    Description='Description', Origin = 'QAC Website', Type = 'Agency Account', Sub_Type_1__c = 'Account Update', status='Open');
        
        insert relatedCase;
        
        Map<ID,String> openCases = new Map<ID,String>();
        
         if(relatedCase != null && relatedCase.Status != 'Closed')
            openCases.Put(relatedCase.Id,relatedCase.Status);
        
        QAC_AgencyPrimaryParsing primaryAgencyInfo = new QAC_AgencyPrimaryParsing(new Account());
        
        primaryAgencyInfo.accountId = agencyAccount.Id;
        primaryAgencyInfo.active    = TRUE;
        primaryAgencyInfo.agencyCode = '1244';
        primaryAgencyInfo.agencyABN = '1111111111';
        primaryAgencyInfo.agencySubChain = 'Test';
        primaryAgencyInfo.agencyTradingName =' Test';
        primaryAgencyInfo.isManualRequestPending = TRUE;
        primaryAgencyInfo.agencyChain = 'Test';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QACAgencyPrimaryInfo/4364558';  
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf(JSON.serializePretty(primaryAgencyInfo));
        
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        QAC_AgencyPrimaryDetailsUpdate.doTMCPrimaryUpdate();
        test.stopTest();
    
    }
    
    @isTest
    public static void testParse_Exception_1() {
        
        Account agencyAccount = [SELECT Id, IATA_Number__c FROM Account WHERE IATA_Number__c = '1000000' LIMIT 1];
        
        QAC_AgencyPrimaryParsing primaryAgencyInfo = new QAC_AgencyPrimaryParsing(new Account());
        
        primaryAgencyInfo.accountId = agencyAccount.Id;
        primaryAgencyInfo.active    = TRUE;
        primaryAgencyInfo.agencyCode = '1244';
        primaryAgencyInfo.agencyABN = '1111111111';
        primaryAgencyInfo.agencySubChain = 'Test';
        primaryAgencyInfo.agencyTradingName =' Test';
        primaryAgencyInfo.isManualRequestPending = TRUE;
        primaryAgencyInfo.agencyChain = 'Test';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QACAgencyPrimaryInfo/';  
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf(JSON.serializePretty(primaryAgencyInfo));
        
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        QAC_AgencyPrimaryDetailsUpdate.doTMCPrimaryUpdate();
        test.stopTest();
    
    }
    
    @isTest
    public static void testParse_Exception_2() {
        
        Account agencyAccount = [SELECT Id, IATA_Number__c FROM Account WHERE IATA_Number__c = '1000000' LIMIT 1];
        
        QAC_AgencyPrimaryParsing primaryAgencyInfo = new QAC_AgencyPrimaryParsing(new Account());
        
        primaryAgencyInfo.accountId = agencyAccount.Id;
        primaryAgencyInfo.active    = TRUE;
        primaryAgencyInfo.agencyCode = '1244';
        primaryAgencyInfo.agencyABN = '1111111111';
        primaryAgencyInfo.agencySubChain = 'Test';
        primaryAgencyInfo.agencyTradingName =' Test';
        primaryAgencyInfo.isManualRequestPending = TRUE;
        primaryAgencyInfo.agencyChain = 'Test';
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        
        req.requestURI = '/services/apexrest/QACAgencyPrimaryInfo/1000001';  
        req.httpMethod = 'PATCH';
        req.requestBody = Blob.valueOf(JSON.serializePretty(primaryAgencyInfo));
        
        RestContext.request = req;
        RestContext.response = res;
        
        test.startTest();
        QAC_AgencyPrimaryDetailsUpdate.doTMCPrimaryUpdate();
        test.stopTest();
    
    }
    
    @isTest
    public static void testParse_Exception_3() {
        String myExcepJson = '';
        QAC_AgencyPrimaryDetailsUpdate_Test.restLogic(null,myExcepJson,'4364559');
                
        test.startTest();
        QAC_AgencyPrimaryDetailsUpdate.doTMCPrimaryUpdate();
        test.stopTest();
    }
    
    public static void restLogic(QAC_AgencyPrimaryParsing theApi, String theExcepJson, String myURL){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();  
        
        req.requestURI = '/services/apexrest/QACAgencyPrimaryInfo/'+myURL;  
        req.httpMethod = 'POST';
        req.requestBody = (theApi != null) ? Blob.valueOf(JSON.serializePretty(theApi)) : (theExcepJson != null) ? Blob.valueOf(theExcepJson) : null ;
        //req.requestBody = Blob.valueOf(JSON.serializePretty(myApi));
        
        RestContext.request = req;
        RestContext.response = res;
    } 

}