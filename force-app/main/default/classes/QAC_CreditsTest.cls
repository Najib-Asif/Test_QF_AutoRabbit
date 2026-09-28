/************************************************************************************************************************
 * Description: Test Class for QAC_Credits RestAPI, Created as part of QAC Credits Project
 * Author: Sobhan - TCS
 ************************************************************************************************************************/ 

@isTest
public class QAC_CreditsTest {
    @testSetup
    public static void setup() {
        
        system.debug('inside test setup**');
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
        String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Agency_Credit').getRecordTypeId();

        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();
        Trigger_Status__c calculateFeesAndDiscounts = new Trigger_Status__c(Name = 'AssetCalculateFeesandDiscounts',Active__c = false);
        lsttrgStatus.add(calculateFeesAndDiscounts);
        Trigger_Status__c AssetConvertingAssetType  = new Trigger_Status__c(Name = 'AssetConvertingAssetType',Active__c = false);
        lsttrgStatus.add(AssetConvertingAssetType);

        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAccountTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
        
        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Integration Logs Rec Type',Config_Value__c = 'Integration Logs');
        insert qcd;
        
        QantasConfigData__c qcd2 = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd2;
        
        //Inserting Account
        List<Account> lstAccount = new List<Account>();
        Account channelAccount1 = new Account(Name = 'Sample', Active__c = true,tradesite__c=true, Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                        Channel_Subscription_Date__c=Date.today(),Channel_Member__c=true,
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '2020202',Qantas_Industry_Centre_ID__c='2020202');
        
        Account channelAccount2 = new Account(Name = 'SampleOne', Active__c = true,tradesite__c=true, Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                        Channel_Subscription_Date__c=Date.today(),Channel_Member__c=true,
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '1010101',Qantas_Industry_Centre_ID__c='1010101');
        Account channelAccount3 = new Account(Name = 'Sampletwo', Active__c = true,tradesite__c=true, Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                        Channel_Subscription_Date__c=Date.today(),Channel_Member__c=true,
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '3030303',Qantas_Industry_Centre_ID__c='3030303');
        
        Account channelAccount4 = new Account(Name = 'Sample3', Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                        Channel_Subscription_Date__c=Date.today(),Channel_Member__c=true,
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '4040404',Qantas_Industry_Centre_ID__c='4040404');
        Account channelAccount5 = new Account(Name = 'Sample4',Active__c = true,tradesite__c=true,Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                        Channel_Subscription_Date__c=Date.today(),Channel_Member__c=true,
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '5050505',Qantas_Industry_Centre_ID__c='5050505');
        
        
        lstAccount.add(channelAccount1);
        lstAccount.add(channelAccount2);
        lstAccount.add(channelAccount3);
        lstAccount.add(channelAccount4);
        lstAccount.add(channelAccount5);
        insert lstAccount;
        list<Asset> allAssets = new list<Asset>();
        Asset myAsset1 = new Asset(Name='Sample',RecordTypeId = assetRTId,AccountId=lstAccount[0].Id,Status='New',Active__c=true,Customer_ID__c='12345',Channel_Effective_Date__c=Date.today()); 
        allAssets.add(myAsset1);
        
        Asset myAsset2 = new Asset(Name='Sample',RecordTypeId = assetRTId,AccountId=lstAccount[0].Id,Status='New',Active__c=true,Customer_ID__c='12346',Channel_Effective_Date__c=Date.today()); 
        allAssets.add(myAsset2);
        
        Asset myAsset3 = new Asset(Name='Sample',RecordTypeId = assetRTId,AccountId=lstAccount[1].Id,Status='Inactive',Active__c=false,Customer_ID__c='12346',Channel_Effective_Date__c=Date.today()); 
        allAssets.add(myAsset3);
        
        Asset myAsset4 = new Asset(Name='Sample',RecordTypeId = assetRTId,AccountId=lstAccount[2].Id,Status='Active',Active__c=true,Customer_ID__c='12347',Channel_Effective_Date__c=Date.today()); 
        allAssets.add(myAsset4);
        insert allAssets;
        
        List<Ledger__c> ledgerObj = new List<Ledger__c>();
        Ledger__c ledger1 = new Ledger__c(Account__c=lstAccount[0].Id,Asset__c=allAssets[0].Id,Transaction_date__c=system.today());
        ledgerObj.add(ledger1);
        
        Ledger__c ledger2 = new Ledger__c(Account__c=lstAccount[1].Id,Asset__c=allAssets[2].Id,Transaction_date__c=system.today());
        ledgerObj.add(ledger2);
        
        Ledger__c ledger3 = new Ledger__c(Account__c=lstAccount[2].Id,Asset__c=allAssets[3].Id,Transaction_date__c=system.today());
        ledgerObj.add(ledger3);
        
        insert ledgerObj;
}
    @isTest
    public static void inActiveAsset()
    {      
        String fromDate;
        statementReq('1010101','Statement',fromDate);
        test.startTest();
        QAC_Credits.doCreditsRetrieval();
        test.stopTest();
    }
    @isTest
    public static void ActiveAsset()
    {      
        String fromDate;
        statementReq('3030303','Statement',fromDate);
        test.startTest();
        QAC_Credits.doCreditsRetrieval();
        test.stopTest();
    }
    @isTest
    public static void inActiveAccount()
    {      
        restRequest('GET','4040404');
        test.startTest();
        QAC_Credits.doCreditsRetrieval();
        test.stopTest();
    }
     @isTest
    public static void noAsset()
    {      
        restRequest('GET','5050505');
        test.startTest();
        QAC_Credits.doCreditsRetrieval();
        test.stopTest();
    }
   
    @isTest
    public static void balance()
    {
        restRequest('GET','2020202');
        test.startTest();
        QAC_Credits.doCreditsRetrieval();
        test.stopTest();
    }
    @isTest
    public static void balanceReport()
    {
        restRequest('GET','3030303');
        test.startTest();
        QAC_Credits.doCreditsRetrieval();
        test.stopTest();
    }
    @isTest
    public static void noIATA()
    {
        restRequest('GET','');
        test.startTest();
        QAC_Credits.doCreditsRetrieval();
        test.stopTest();
    }
    @isTest
    public static void statement()
    {
        String fromDate;
        statementReq('2020202','Statement',fromDate);
        test.startTest();
        QAC_Credits.doCreditsRetrieval();
        test.stopTest();
    }
    @isTest
    public static void pastfromDate()
    {
        
        String fromDate=(system.today().addMonths(-16)).format();
        System.debug('fromDate'+fromDate);
        statementReq('2020202','Statement',fromDate);
        test.startTest();
        QAC_Credits.doCreditsRetrieval();
        test.stopTest();
    }
    @isTest
    public static void testwithExcepJSON()
    {
        try{
            system.debug('Inside JSON Excep');
            
            Test.startTest();
            QAC_Credits.doCreditsRetrieval();
            Test.stopTest();
        }
        catch(Exception myException){
            system.debug('inside exception test'+myException.getTypeName());
        }
    }
    public static void statementReq(String agencyCode,String filter,String fromDate)
    {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QACCredits/'+agencyCode;
        if(filter!=null)
        req.addParameter('filter', filter);
        if(fromDate!=null)
        req.addParameter('fromDate', fromDate);   
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response = res;

       
    }
    public static void restRequest(String method, String agencyCode){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QACCredits/'+agencyCode;
        req.httpMethod = method;
        
        RestContext.request = req;
        RestContext.response = res;
    } 
}