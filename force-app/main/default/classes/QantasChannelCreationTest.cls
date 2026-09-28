/* 
* Created By : Ajay Bharathan | TCS | Cloud Developer 
* Main Class : QantasChannelCreation
*/
@isTest
public class QantasChannelCreationTest {
    
    @testSetup
    public static void setup() {
        
        system.debug('inside test setup**');
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
        String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Agency_Channel').getRecordTypeId();
        String tmcRTID = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByDeveloperName().get('GDS').getRecordTypeId();

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
        Account channelAccount = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                        Channel_Subscription_Date__c=Date.today(),Channel_Member__c=true,
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '2020202');
        insert channelAccount;
        
        Account nonchannelAccount = new Account(Name = 'Sample2', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '1010101');
        insert nonchannelAccount;
        
        // inserting GDS Reference
        list<GDS_Reference__c> gdsList = new list<GDS_Reference__c>();
        GDS_Reference__c gds1 = new GDS_Reference__c(Name='Amadeus',Channel_Enabled__c=true,Active__c=true,PCC_Max_Length__c=8,PCC_Min_Length__c=3);
        GDS_Reference__c gds2 = new GDS_Reference__c(Name='Sabre',Channel_Enabled__c=true,Active__c=true,PCC_Max_Length__c=6,PCC_Min_Length__c=3);
        gdsList.add(gds1);
        gdsList.add(gds2);
        insert gdsList;
        
        // inserting Asset
        list<Asset> allAssets = new list<Asset>();
        Asset myAsset1 = new Asset(Name='Sample',RecordTypeId = assetRTId,AccountId=channelAccount.Id,Status='New',GDS__c=gds1.id,Customer_ID__c='12345',Channel_Effective_Date__c=Date.today()); 
        Asset myAsset2 = new Asset(Name='Sample2',RecordTypeId = assetRTId,AccountId=channelAccount.Id,Status='New',GDS__c=gds2.id,Customer_ID__c='67890',Channel_Effective_Date__c=Date.today()); 
        allAssets.add(myAsset1);
        allAssets.add(myAsset2);
        insert allAssets;
        
        //Inserting TMC Info
        Agency_Info__c Agencyinfo = new Agency_Info__c();
        Agencyinfo.Account__c = channelAccount.Id;
        Agencyinfo.RecordTypeId = tmcRTID;        
        Agencyinfo.Active__c=true;
        Agencyinfo.Email_Id__c='test@test.com';
        Agencyinfo.Code__c  ='Amadeus';
        Agencyinfo.PCC__c   ='AS2P';
        Agencyinfo.Market_Segment__c ='Corporate';
        insert Agencyinfo;

        Agency_Info__c Agencyinfo2 = new Agency_Info__c();
        Agencyinfo2.Account__c = channelAccount.Id;
        Agencyinfo2.RecordTypeId = tmcRTID;        
        Agencyinfo2.Active__c=true;
        Agencyinfo2.Email_Id__c='test@test.com';
        Agencyinfo2.Code__c  ='Sabre';
        Agencyinfo2.PCC__c   ='2yMT';
        insert Agencyinfo2;
    }
    
    @isTest
    public static void nonchannelAssetCreation()
    {
        list<QantasChannelCreationAPI> myApi = QantasChannelCreationAPI_Test.testParse();
        Test.startTest();
        QantasChannelCreationTest.restLogic(myApi,null,'1010101','POST',true);
        Test.stopTest();
    }
	
	@isTest
    public static void channelAssetCreation()
    {
		String json = '['+
		'	{'+
		'		\"gdsCode\" : \"Sabre\",'+
		'		\"customerId\" : \"12345\"'+
		'	}'+
		']';

        list<QantasChannelCreationAPI> myApi = QantasChannelCreationAPI.parse(json);
		
        QantasChannelCreationTest.restLogic(myApi,null,'2020202','POST',false);
		Test.startTest();
		QantasChannelCreation.doChannelCreation();
		Test.stopTest();
        
    }
    
	@isTest
    public static void channelAssetUpdation()
    {
        list<Asset> myAsset = new list<Asset>();
        Set<Id> eachIds = new Set<Id>();
        Set<String> eachGDSNames = new Set<String>();
        for(Asset eachAst : [Select Id,GDS__c,GDS_Name__c from Asset]){
            myAsset.add(eachAst);
        }
        myAsset[1].Status = 'Accepted';
        update myAsset[1];
        system.debug('my asset**'+myAsset);
        
        String json = '['+
            '	{'+
            '		\"gdsCode\" : \"'+myAsset[0].GDS_Name__c+'\",'+
            '		\"assetId\" : \"'+myAsset[0].Id+'\",'+
            '		\"customerId\" : \"12345\"'+
            '	},'+
            '	{'+
            '		\"gdsCode\" : \"'+myAsset[1].GDS_Name__c+'\",'+
            '		\"assetId\" : \"'+myAsset[1].Id+'\",'+
            '		\"customerId\" : \"78901\"'+
            '	}'+
            ']';        
        system.debug('my json**'+json);
        list<QantasChannelCreationAPI> myApi = QantasChannelCreationAPI.parse(json);
		QantasChannelCreationTest.restLogic(myApi,null,'2020202','PATCH',false);
		Test.startTest();
        QantasChannelCreation.doChannelUpdation();
		Test.stopTest();
    }    
    
    @isTest
    public static void channelAssetConflict()
    {
		String json = '['+
		'	{'+
		'		\"gdsCode\" : \"Amadeus\",'+
		'		\"customerId\" : \"12345\"'+
		'	}'+
		']';

        Test.startTest();
        list<QantasChannelCreationAPI> myApi = QantasChannelCreationAPI.parse(json);
        QantasChannelCreationTest.restLogic(myApi,null,'2020202','POST',true);
        Test.stopTest();
    }
    
    @isTest
    public static void channelAssetInvalid()
    {
        String json;
        list<QantasChannelCreationAPI> myApi;
        
        Test.startTest();
        json = '['+
            '	{'+
            '		\"gdsCode\" : \"dummyvalue\",'+
            '		\"assetId\" : \"dummy value\",'+
            '		\"customerId\" : \"12345\"'+
            '	},'+
            '	{'+
            '		\"gdsCode\" : \"somevalue\",'+
            '		\"assetId\" : \"test value\",'+
            '		\"customerId\" : \"78901\"'+
            '	}'+
            ']';        
        
        myApi = QantasChannelCreationAPI.parse(json);
        QantasChannelCreationTest.restLogic(myApi,null,'2020202','POST',true);
        QantasChannelCreationTest.restLogic(myApi,null,'1010101','PATCH',true);
        Test.stopTest();
    }

    @isTest
    public static void blankIATA()
    {
        Test.startTest();
        list<QantasChannelCreationAPI> myApi = QantasChannelCreationAPI_Test.testParse();
        QantasChannelCreationTest.restLogic(myApi,null,'','POST',true);
        QantasChannelCreationTest.restLogic(myApi,null,'','PATCH',true);
        QantasChannelCreationTest.restLogic(myApi,null,'9999999999999','POST',true);
        QantasChannelCreationTest.restLogic(myApi,null,'9999999999999','PATCH',true);
        Test.stopTest();
    }
    
    @isTest
    public static void testwithExcepJSON()
    {
        try{
            String myExcepJson = '';
            Test.startTest();
            QantasChannelCreationTest.restLogic(null,myExcepJson,'1010101','POST',true);
            QantasChannelCreationTest.restLogic(null,myExcepJson,'1010101','PATCH',true);
            Test.stopTest();
        }
        catch(Exception myException){
            system.debug('inside exception test'+myException.getTypeName());
        }
    }

    public static void restLogic(list<QantasChannelCreationAPI> theApi, String theExcepJson,String agencyCode, String method, Boolean runBoth){
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/QantasChannelCreation/'+agencyCode;  
        req.httpMethod = method;
        req.requestBody = (theApi != null) ? Blob.valueOf(JSON.serializePretty(theApi)) : (theExcepJson != null) ? Blob.valueOf(theExcepJson) : null ;
        //req.requestBody = Blob.valueOf(JSON.serializePretty(myApi));
        
        RestContext.request = req;
        RestContext.response = res;
		if(runBoth) runTest();
    }
    
    public static void runTest()
    {
        QantasChannelCreation.doChannelCreation();
        QantasChannelCreation.doChannelUpdation();
    }
}