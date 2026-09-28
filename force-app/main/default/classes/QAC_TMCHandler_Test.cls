/* 
* Created By : Ajay Bharathan | TCS | Cloud Developer 
* Main Class : QAC_TMCHandler
*/
@isTest
public class QAC_TMCHandler_Test {
    
    @testSetup
    public static void setup() {
        
        system.debug('inside test setup**');
        String agencyRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
        String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Agency_Channel').getRecordTypeId();
        
        List<Trigger_Status__c> lsttrgStatus = new List<Trigger_Status__c>();
        Trigger_Status__c tmcTrigger = new Trigger_Status__c(Name = 'TMCInfoTrigger',Active__c = true);
        lsttrgStatus.add(tmcTrigger);
        Trigger_Status__c tmcAfterTrigger = new Trigger_Status__c(Name = 'TMCInfoAfterTrigger',Active__c = true);
        lsttrgStatus.add(tmcAfterTrigger);
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
        Asset myAsset1 = new Asset(Name='Sample',RecordTypeId = assetRTId,AccountId=myAccount.Id,Status='New', Active__c = TRUE, GDS__c=gds1.id,Customer_ID__c='12345',Channel_Effective_Date__c=Date.today()); 
        Asset myAsset2 = new Asset(Name='Sample2',RecordTypeId = assetRTId,AccountId=myAccount.Id,Status='New', Active__c = TRUE, GDS__c=gds2.id,Customer_ID__c='12345',Channel_Effective_Date__c=Date.today()); 
        allAssets.add(myAsset1);
        allAssets.add(myAsset2);
        insert allAssets;
        
    }
    
    @isTest
    public static void updateTMCInfoCheck(){
        
        Account myAccount = [Select Id from Account where Name = 'Sample'];
        String tmcRTId = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByDeveloperName().get('GDS').getRecordTypeId();
        
        list<Agency_Info__c> toUpdateTMC = new list<Agency_Info__c>();
        Agency_Info__c eachTMC = new Agency_Info__c();
        eachTMC.Account__c = myAccount.Id;
        eachTMC.RecordTypeId = tmcRTId;
        eachTMC.PCC__c = 'ABC123';
        eachTMC.Code__c = 'Amadeus';
        eachTMC.Active__c = true;
        toUpdateTMC.add(eachTMC);
        
        Agency_Info__c eachTMC2 = new Agency_Info__c();
        eachTMC2.Account__c = myAccount.Id;
        eachTMC2.RecordTypeId = tmcRTId;
        eachTMC2.PCC__c = 'XYZ12';
        eachTMC2.Code__c = 'Amadeus';
        eachTMC2.Active__c = true;
        toUpdateTMC.add(eachTMC2);
        
        Test.startTest();
        IsRecursive.run = true;
        insert toUpdateTMC;
        toUpdateTMC[0].Active__c = false;
        IsRecursive.run = true;
        update toUpdateTMC[0];
        toUpdateTMC[0].Active__c = true;
        IsRecursive.run = true;
        update toUpdateTMC[0];
        
        Test.stopTest();
    }
    @isTest
    public static void pccValidation()
    {
        Account myAccount = [Select Id from Account where Name = 'Sample'];
        String tmcRTId = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByDeveloperName().get('GDS').getRecordTypeId();
        list<Agency_Info__c> toUpdateTMC = new list<Agency_Info__c>();
        Agency_Info__c eachTMC2 = new Agency_Info__c();
        eachTMC2.Account__c = myAccount.Id;
        eachTMC2.RecordTypeId = tmcRTId;
        eachTMC2.PCC__c = 'XY';
        eachTMC2.Code__c = 'Amadeus';
        eachTMC2.Active__c = true;
        toUpdateTMC.add(eachTMC2);
        Test.startTest();
        try{
            IsRecursive.run = true;
            insert toUpdateTMC;
            toUpdateTMC[0].pcc__c='XYZ12';
            IsRecursive.run = true;
            update toUpdateTMC[0];
        }Catch(Exception e){}
        Test.stopTest();
    }
    
    @isTest
    public static void tmcDuplicateCheck()
    {
        Account myAccount = [Select Id, Name from Account where Name = 'Sample'];
        String tmcRTId = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByDeveloperName().get('GDS').getRecordTypeId();
        
        Test.startTest();
        try{
            Agency_Info__c agencyInfo1 = new Agency_Info__c(RecordTypeId = tmcRTId,Account__c = myAccount.Id, PCC__c = 'XYZ1',Code__c = 'Amadeus',Active__c = false);
            IsRecursive.run = true;      
            insert agencyInfo1;
            Agency_Info__c agencyInfo2 = new Agency_Info__c(RecordTypeId = tmcRTId,Account__c = myAccount.Id,PCC__c = 'XYZ1',Code__c = 'Amadeus',Active__c = true); 
            IsRecursive.run = true;
            insert agencyInfo2;
        }
        catch(Exception e){
            Boolean expectedException = e.getMessage().contains('already exists on this Account') ? true : false;
            System.AssertEquals(expectedException, true);           
        }
        Test.stopTest();
    }
    
    @isTest
    public static void updateTMCGDsStatusCheck(){
        Account blankAccount = [Select Id from Account where Name = 'Sample2'];
        Account myAccount = [Select Id from Account where Name = 'Sample'];
        String tmcRTId = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByDeveloperName().get('GDS').getRecordTypeId();
        List<Agency_Info__c> toInsertTMC = new List<Agency_Info__c>();
        List<Agency_Info__c> toInsertTMC2 = new List<Agency_Info__c>();
        
        Agency_Info__c agencyInfo1 = new Agency_Info__c(RecordTypeId = tmcRTId,Account__c = myAccount.Id, PCC__c = 'XYZ1',Code__c = 'Amadeus',Active__c = true, GDS_Status__c = 'New');
        toInsertTMC.add(agencyInfo1);
        
        Agency_Info__c agencyInfo3 = new Agency_Info__c(RecordTypeId = tmcRTId,Account__c = myAccount.Id, PCC__c = 'XYZ1',Code__c = 'Sabre',Active__c = true, GDS_Status__c = 'Active'); 
        toInsertTMC.add(agencyInfo3);
        
        Agency_Info__c agencyInfo5 = new Agency_Info__c(RecordTypeId = tmcRTId,Account__c = myAccount.Id, PCC__c = 'XYZ1',Code__c = 'Galileo',Active__c = true, GDS_Status__c = 'Active'); 
        toInsertTMC.add(agencyInfo5);
        
        IsRecursive.run = true; 
        insert toInsertTMC;

        Test.startTest();

            Agency_Info__c agencyInfo2 = new Agency_Info__c(RecordTypeId = tmcRTId,Account__c = blankAccount.Id,PCC__c = 'XYZ1',Code__c = 'Amadeus',Active__c = true, GDS_Status__c = 'Accepted', ATPCO_Status__c = 'Accepted', Surcharge_Exemption_Status__c = 'Accepted', QDP_Status__c = 'Accepted'); 
            toInsertTMC2.add(agencyInfo2);
            
            Agency_Info__c agencyInfo4 = new Agency_Info__c(RecordTypeId = tmcRTId,Account__c = blankAccount.Id,PCC__c = 'XYZ1',Code__c = 'Sabre',Active__c = false, GDS_Status__c = 'Inactive', ATPCO_Status__c = 'Inactive', Surcharge_Exemption_Status__c = 'Inactive', QDP_Status__c = 'Inactive'); 
            toInsertTMC2.add(agencyInfo4);
            
            Agency_Info__c agencyInfo6 = new Agency_Info__c(RecordTypeId = tmcRTId,Account__c = blankAccount.Id,PCC__c = 'XYZ1',Code__c = 'Galileo',Active__c = true, GDS_Status__c = 'Deregistered', ATPCO_Status__c = 'Deregistered', Surcharge_Exemption_Status__c = 'Deregistered', QDP_Status__c = 'Deregistered'); 
            toInsertTMC2.add(agencyInfo6);
            
            IsRecursive.run = true;
            insert toInsertTMC2;

        Test.stopTest();
    }
}