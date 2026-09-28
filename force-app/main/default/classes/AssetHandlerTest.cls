/* 
* Created By : Ajay Bharathan | TCS | Cloud Developer 
* Main Class : AssetHandler
*/
@isTest
public class AssetHandlerTest {
    
    @testSetup
    public static void setup() {
        
        system.debug('inside test setup**');
        /*String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency Account').getRecordTypeId();
        String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Agency Channel').getRecordTypeId();
        String tmcRTId = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByName().get('GDS').getRecordTypeId();*/
        
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
        String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Agency_Channel').getRecordTypeId();
        String tmcRTId = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByDeveloperName().get('GDS').getRecordTypeId();        

        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();
        Trigger_Status__c calculateFeesAndDiscounts = new Trigger_Status__c(Name = 'AssetCalculateFeesandDiscounts',Active__c = false);
        lsttrgStatus.add(calculateFeesAndDiscounts);
        Trigger_Status__c AssetConvertingAssetType  = new Trigger_Status__c(Name = 'AssetConvertingAssetType',Active__c = false);
        lsttrgStatus.add(AssetConvertingAssetType);
        Trigger_Status__c chAsset = new Trigger_Status__c(Name = 'AssetChannel',Active__c = true);
        lsttrgStatus.add(chAsset);

        lsttrgStatus.addAll(TestUtilityDataClassQantas.createAccountTriggerSetting());
        insert lsttrgStatus;
        TestUtilityDataClassQantas.createQantasConfigDataAccRecType();
        
        QantasConfigData__c qcd = new QantasConfigData__c(Name = 'Log Integration Logs Rec Type',Config_Value__c = 'Integration Logs');
        insert qcd;
        
        QantasConfigData__c qcd2 = new QantasConfigData__c(Name = 'Log Exception Logs Rec Type',Config_Value__c = 'Exception Logs');
        insert qcd2;
        
        //Inserting Account
        list<Account> accList = new list<Account>();
        Account myAccount = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                        Channel_Subscription_Date__c=Date.today(),Channel_Member__c=true,
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '2020202');
        //insert myAccount;
        
        Account blankAccount = new Account(Name = 'Sample2', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '1010101');
    
        //insert blankAccount;
        
        Account blankAccount2 = new Account(Name = 'Sample3', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565365',
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '1010102');
        
        Account blankAccount3 = new Account(Name = 'Sample4', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = agencyRecordTypeId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565366',
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '1010103');
        accList.add(myAccount);
        accList.add(blankAccount);
        accList.add(blankAccount2);
        accList.add(blankAccount3);
        insert accList;
        
        
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

        list<Agency_Info__c> toUpdateTMC = new list<Agency_Info__c>();
        Agency_Info__c eachTMC = new Agency_Info__c();
        eachTMC.Account__c = blankAccount.Id;
        eachTMC.RecordTypeId = tmcRTId;
        eachTMC.PCC__c = 'ABC123';
        eachTMC.Code__c = 'Amadeus';
        eachTMC.Active__c = true;
        toUpdateTMC.add(eachTMC);

        Agency_Info__c eachTMC2 = new Agency_Info__c();
        eachTMC2.Account__c = blankAccount2.Id;
        eachTMC2.RecordTypeId = tmcRTId;
        eachTMC2.PCC__c = 'XYZ123';
        eachTMC2.Code__c = 'Sabre';
        eachTMC2.Active__c = true;
        eachTMC2.GDS_Status__c = 'New';
        toUpdateTMC.add(eachTMC2);
        
        Agency_Info__c eachTMC3 = new Agency_Info__c();
        eachTMC3.Account__c = blankAccount2.Id;
        eachTMC3.RecordTypeId = tmcRTId;
        eachTMC3.PCC__c = 'XYZ123';
        eachTMC3.Code__c = 'Sabre';
        eachTMC3.Active__c = true;
        eachTMC3.GDS_Status__c = 'Active';
        toUpdateTMC.add(eachTMC3);
        
        Agency_Info__c eachTMC4 = new Agency_Info__c();
        eachTMC4.Account__c = blankAccount3.Id;
        eachTMC4.RecordTypeId = tmcRTId;
        eachTMC4.PCC__c = 'XYZ123';
        eachTMC4.Code__c = 'Sabre';
        eachTMC4.Active__c = true;
        eachTMC4.GDS_Status__c = 'Deregistered';
        toUpdateTMC.add(eachTMC4);
        
        insert toUpdateTMC;
    }
    
    @isTest
    public static void assetDuplicateCheck()
    {
        //map<Id,Asset> oldAssets = new map<Id,Asset>([Select id,AccountId,GDS__c,GDS__r.Name,Name from Asset]);

        Account myAccount = [Select Id from Account where Name = 'Sample'];
        GDS_Reference__c gds1 = [Select Id from GDS_Reference__c where Name = 'Amadeus'];
        //String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Agency Channel').getRecordTypeId();
        String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Agency_Channel').getRecordTypeId();

        Test.startTest();
        try{
            list<Asset> allAssets = new list<Asset>();
            Asset myAsset1 = new Asset(Name='Sample',RecordTypeId = assetRTId,AccountId=myAccount.Id,Status='New',GDS__c=gds1.id,Customer_ID__c='12345',Channel_Effective_Date__c=Date.today());
            insert myAsset1;        
            Asset myAsset2 = new Asset(Name='Sample',RecordTypeId = assetRTId,AccountId=myAccount.Id,Status='New',GDS__c=gds1.id,Customer_ID__c='12345',Channel_Effective_Date__c=Date.today()); 
            insert myAsset2;            
        }
        catch(Exception e){
            Boolean expectedException = e.getMessage().contains('DUPLICATE: GDS') ? true : false;
            System.AssertEquals(expectedException, true);    
        }
        Test.stopTest();
    }

     @isTest
    public static void assetTMCInfoUpdateCheck(){
        Account blankAccount = [Select Id from Account where Name = 'Sample2'];
        GDS_Reference__c gds1 = [Select Id from GDS_Reference__c where Name = 'Amadeus'];
        //String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Agency Channel').getRecordTypeId();
        String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Agency_Channel').getRecordTypeId();

        Test.startTest();
            list<Asset> allAssets = new list<Asset>();
            Asset myAsset1 = new Asset(Name='Sample',RecordTypeId = assetRTId,AccountId=blankAccount.Id,Status='New',GDS__c=gds1.id,Customer_ID__c='12345',Channel_Effective_Date__c=Date.today()); 
            allAssets.add(myAsset1);
            insert allAssets;
            //AssetHandler.QCH_doTMCInfoUpdate(allAssets);
        Test.stopTest();
    }

    @isTest
    public static void assetTMCUpdaGDSstatusupdate(){
        Account blankAccount2 = [Select Id from Account where Name = 'Sample3'];
        GDS_Reference__c gds2 = [Select Id from GDS_Reference__c where Name = 'Sabre'];
        String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Agency_Channel').getRecordTypeId();
        list<Asset> allAssets = new list<Asset>();
        Asset myAsset2 = new Asset(Name='Sample1',RecordTypeId = assetRTId,AccountId=blankAccount2.Id,Status='New',GDS__c=gds2.id,Customer_ID__c='12345',Channel_Effective_Date__c=Date.today());            
        allAssets.add(myAsset2);
        insert allAssets;

        Test.startTest();
            myAsset2.Status = 'Pending deregistration';
            update myAsset2;
            //AssetHandler.QCH_doTMCInfoUpdate(allAssets);
        Test.stopTest();
    }
    
     @isTest
    public static void activeAssetTMCstatusupdate(){
        Account blankAccount3 = [Select Id from Account where Name = 'Sample4'];
        GDS_Reference__c gds3 = [Select Id from GDS_Reference__c where Name = 'Sabre'];
        String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Agency_Channel').getRecordTypeId();
        list<Asset> allAssets = new list<Asset>();
        Asset myAsset3 = new Asset(Name='Sample4',RecordTypeId = assetRTId,AccountId=blankAccount3.Id,Status='New',GDS__c=gds3.id,Customer_ID__c='12345',Channel_Effective_Date__c=Date.today());            
        allAssets.add(myAsset3);
        insert allAssets;
        myAsset3.Active__c = FALSE ;
        update myAsset3;

        Test.startTest();
           Asset myAsset4 = new Asset(Name='Sample4',RecordTypeId = assetRTId,AccountId=blankAccount3.Id,Status='New',GDS__c=gds3.id,Customer_ID__c='12345',Channel_Effective_Date__c=Date.today());            
           insert myAsset4;
        Test.stopTest();
    }
}