/* 
* Created By : Ajay Bharathan | TCS | Cloud Developer 
* Main Class : QantasChannelRetrieval
*/
@isTest
public class QantasChannelRetrievalTest {
    
    @testSetup
    public static void setup() {
        
        system.debug('inside test setup**');
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Agency Channel').getRecordTypeId();

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
        Account myAccount = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                        Channel_Subscription_Date__c=Date.today(),Channel_Member__c=true,
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '2020202');
        insert myAccount;
        
        Account blankAccount = new Account(Name = 'Sample2', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                        Channel_Subscription_Date__c=Date.today(),Channel_Member__c=true,
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '1010101');
        insert blankAccount;
        
        // inserting GDS Reference
        list<GDS_Reference__c> gdsList = new list<GDS_Reference__c>();
        GDS_Reference__c gds1 = new GDS_Reference__c(Name='Amadeus',Channel_Enabled__c=true,Active__c=true,PCC_Max_Length__c=8,PCC_Min_Length__c=3);
        GDS_Reference__c gds2 = new GDS_Reference__c(Name='Sabre',Channel_Enabled__c=true,Active__c=true,PCC_Max_Length__c=6,PCC_Min_Length__c=3);
        gdsList.add(gds1);
        gdsList.add(gds2);
        insert gdsList;
        
        // inserting Asset
        list<Asset> allAssets = new list<Asset>();
        Asset myAsset1 = new Asset(Name='Sample',RecordTypeId = assetRTId,AccountId=myAccount.Id,Status='New',GDS__c=gds1.id,Customer_ID__c='12345',Channel_Effective_Date__c=Date.today()); 
        Asset myAsset2 = new Asset(Name='Sample2',RecordTypeId = assetRTId,AccountId=myAccount.Id,Status='New',GDS__c=gds2.id,Customer_ID__c='12345',Channel_Effective_Date__c=Date.today()); 
        allAssets.add(myAsset1);
        allAssets.add(myAsset2);
        insert allAssets;
    }
    
    @isTest
    public static void validAssetRetrieval()
    {
        String myURL = '/services/apexrest/QantasChannelRetrieval/2020202';
        QantasChannelRetrievalTest.restLogic(myURL);
        
        Test.startTest();
        QantasChannelRetrieval.doChannelRetrieve();
        Test.stopTest();
    }
    
    @isTest
    public static void invalidAssetRetrieval()
    {
        String myURL = '/services/apexrest/QantasChannelRetrieval/1010101';
        QantasChannelRetrievalTest.restLogic(myURL);
        
        Test.startTest();
        QantasChannelRetrieval.doChannelRetrieve();
        Test.stopTest();
    }

    @isTest
    public static void invalidIATARetrieval()
    {
        String myURL = '/services/apexrest/QantasChannelRetrieval/8888888';
        QantasChannelRetrievalTest.restLogic(myURL);
        
        Test.startTest();
        QantasChannelRetrieval.doChannelRetrieve();
        Test.stopTest();
    }
    
    @isTest
    public static void blankIATARetrieval()
    {
        String myURL = '/services/apexrest/QantasChannelRetrieval/';
        QantasChannelRetrievalTest.restLogic(myURL);
        
        Test.startTest();
        QantasChannelRetrieval.doChannelRetrieve();
        Test.stopTest();
    }

    @isTest
    public static void testwithExcepJSON()
    {
        Test.startTest();
        
        String myURL = null;
        QantasChannelRetrievalTest.restLogic(myURL);
        QantasChannelRetrieval.doChannelRetrieve();
        Test.stopTest();
    }
    
    public static void restLogic(String theRequestURL){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = theRequestURL;  
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response = res;
    }  
}