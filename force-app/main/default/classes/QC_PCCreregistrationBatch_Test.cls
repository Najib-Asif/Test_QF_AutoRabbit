/*
* Created By  : Vinothkumar Balasubramanian

Main class Name: QC_PCCreregistrationBatch
*/
@isTest
private class QC_PCCreregistrationBatch_Test {
    
    @testsetup
    public static void setup() {
        
        String accAgencyRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
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
        
        Account myAccount = new Account(Name = 'Sample', Active__c = true, Aquire__c = true, Type = 'Agency Account', 
                                        RecordTypeId = accAgencyRTId, Migrated__c = true, ABN_Tax_Reference__c  ='34563565364',
                                        Channel_Subscription_Date__c=Date.today(),Channel_Member__c=true,
                                        Estimated_Total_Air_Travel_Spend__c = 0,IATA_Number__c = '2020209');
        insert myAccount;
        
        GDS_Reference__c myGds = new GDS_Reference__c(Name='Amadeus',Channel_Enabled__c=true,Active__c=true,PCC_Max_Length__c=8,PCC_Min_Length__c=3);
        insert myGds;
        
        Asset myAsset = new Asset(Name='Sample',RecordTypeId = assetRTId,AccountId=myAccount.Id,Status='New',GDS__c=myGds.id,Customer_ID__c='12345',Channel_Effective_Date__c=Date.today(), Active__c = TRUE); 
        insert myAsset;
        
        Agency_Info__c tmcInfo = new Agency_Info__c(Account__c = myAccount.Id, RecordTypeId = tmcRTId, PCC__c = 'ABC123', Code__c = 'Amadeus', Active__c = true, GDS_Status__c = 'New');
        insert tmcInfo;
        
        Agency_Info__History tmcInfoHistory = new Agency_Info__History (ParentId = tmcInfo.Id, Field = 'GDS_Status__c');
        insert tmcInfoHistory;
        
        
    }
    
    static testMethod void testBatchAssetandPCCStatusupdate() {
        
        Account myAccount = [Select Id from Account where Name = 'Sample'];
        
        QC_TMC_GDS_Status__mdt tmcGDSStatus = [Select Days_from_Pending_Dereg_GDS_Status__c from QC_TMC_GDS_Status__mdt where Days_from_Pending_Dereg_GDS_Status__c != NULL AND DeveloperName = 'QC_PCC_Asset_Status'];
        Decimal gdsStatusdays =  tmcGDSStatus.Days_from_Pending_Dereg_GDS_Status__c;
        Integer gdsPendingderegdays = gdsStatusdays.intValue();
        
        Asset myAsset = [Select Id, GDS__c, GDS__r.Name, AccountId, Status from Asset where Name = 'Sample'];
        myAsset.Status = 'Pending deregistration';
        update myAsset;
        
        Agency_Info__c tmcInfo = [Select Id, Code__c, GDS_Status__c from Agency_Info__c where Code__c = 'Amadeus'];
        tmcInfo.GDS_Status__c = 'Pending deregistration';
        tmcInfo.GDS_Status_Change_Date__c = system.today().addDays(-gdsPendingderegdays);
        update tmcInfo;
        
        Test.startTest();
        QC_PCCreregistrationBatch batchObj = new QC_PCCreregistrationBatch();
        Database.executeBatch(batchObj);
        Test.stopTest();
    }
    
}