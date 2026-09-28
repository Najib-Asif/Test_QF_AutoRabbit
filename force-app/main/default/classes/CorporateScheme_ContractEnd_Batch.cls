/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath 
Company:       Capgemini
Description:   Batch Class to Remap the new Contract when old Contract expies
Inputs:        
Test Class:     
************************************************************************************************
History
************************************************************************************************

-----------------------------------------------------------------------------------------------------------------------*/
global class CorporateScheme_ContractEnd_Batch implements Database.Batchable<sObject>, Database.Stateful {
    
    String query;
    Set<String> setAssetId = new Set<String>();
    global Map<String, List<String>> mapError;
    
    global CorporateScheme_ContractEnd_Batch(String batchQuery, Set<String> setFailedAssetId) {
        setAssetId = setFailedAssetId;
        query = batchQuery+' and Id NOT IN: setAssetId';
        system.debug('query######'+query);
        system.debug('setFailedAssetId#########'+setAssetId);
        mapError = new Map<String, List<String>>();
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('query######'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Asset> lstAsset) {
        try{
            system.debug('lstAsset#######'+lstAsset);
            Id corpSchemeRecTypeId = GenericUtils.getObjectRecordTypeId('Asset', CustomSettingsUtilities.getConfigDataMap('Asset Corporate Scheme Rec Type') );
            Id publicSchemeRecTypeId = GenericUtils.getObjectRecordTypeId('Asset', CustomSettingsUtilities.getConfigDataMap('Asset Public Scheme Rec Type') );
    
            for(Asset objAsset: lstAsset){
                if(objAsset.RecordTypeId == corpSchemeRecTypeId && objAsset.Move_to_Public_Scheme__c){
                    objAsset = AssetObjectHelper.convertCorporateSchmeToPublicScheme(objAsset, publicSchemeRecTypeId);
                }else if(objAsset.RecordTypeId == publicSchemeRecTypeId){
                    objAsset.Public_Scheme_End_Date__c = system.today().addYears(3);
                }else{
                    objAsset.Status = 'Inactive';
                }
            }
            Integer i = 0;
            Database.SaveResult[] lstSaveResult = Database.update(lstAsset, False);
            for(Database.SaveResult sr : lstSaveResult){ 
                if (!sr.isSuccess()) { 
                    Id assetId = lstAsset[i].Id;
                    List<String> lstErrorMSG = new List<String>();
                    for(Database.Error err : sr.getErrors()){
                        lstErrorMSG.add(err.getMessage());
                    }
                    mapError.put(assetId, lstErrorMSG);
                }
                i++;
            }
        }catch(Exception ex){
            CreateLogs.insertLogRec( 'Log Exception Logs Rec Type', 'Loyalty Batches', 'CorporateScheme_ContractEnd_Batch', 
                                     'execute', String.valueOf(''), String.valueOf(''),false,'', ex);
        }

    }
    
    global void finish(Database.BatchableContext BC) {
        List<Log__c> lstLogException = new List<Log__c>();
        Integer i = 0;
        for(String assetId: mapError.keyset()){
            lstLogException.add(CreateLogs.insertLogBatchRec( 'Log Exception Logs Rec Type', 'Loyalty Batches', 'CorporateScheme_ContractEnd_Batch', 
                                     'execute', assetId, mapError.get(assetId)));
            i++;
        }
        insert lstLogException;
    }
    
}