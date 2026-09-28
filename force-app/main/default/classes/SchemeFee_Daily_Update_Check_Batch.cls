/*----------------------------------------------------------------------------------------------------------------------
Author:        Praveen Sampath
Company:       Capgemini
Description:   Batch Class to Update the Scheme Fees when there is a chnage on the Scheme Fee Custom Setting Value
Test Class:    
*********************************************************************************************************************************
*********************************************************************************************************************************
History
*********************************************************************************************************************************

**********************************************************************************************************************************/
global class SchemeFee_Daily_Update_Check_Batch implements Database.Batchable<sObject>, Database.Stateful{
    
    String query;
    Set<Id> setAssetRecTypeId = new Set<Id>();
    Set<String> setCurrency = new Set<String>();
    Set<String> setSchemetype = new Set<String>(); 
    global Map<String, List<String>> mapError;
   


    /*----------------------------------------------------------------------------------------------------      
    Method Name:        SchemeFee_Daily_Update_Check_Batch
    Description:        Daily Update Batch Method
    Parameter:          List of Scheme Fee Record and a Boolean check to determine the Schedule Run
    -----------------------------------------------------------------------------------------------------*/             
    global SchemeFee_Daily_Update_Check_Batch(Boolean isAllRun, List<SchemeFees__c> lstSchemeFee) {
        mapError = new Map<String, List<String>>();
        String corpSchemeRecTypeName = CustomSettingsUtilities.getConfigDataMap('Asset Corporate Scheme Rec Type');
        setAssetRecTypeId.add(GenericUtils.getObjectRecordTypeId('Asset', corpSchemeRecTypeName ));
        
        String publicSchemeRecTypeName = CustomSettingsUtilities.getConfigDataMap('Asset Public Scheme Rec Type');
        setAssetRecTypeId.add(GenericUtils.getObjectRecordTypeId('Asset', publicSchemeRecTypeName ));
       
        query = 'Select Id, Batch_Run__c from Asset where ';
        query += 'RecordTypeId IN: setAssetRecTypeId and status != \'Inactive\'';
        if(lstSchemeFee != Null && lstSchemeFee.size()>0){
            for(SchemeFees__c fee: lstSchemeFee){
                setSchemetype.add(fee.Scheme_Type__c);
                setCurrency.add(fee.Currency__c);
            }
            query += ' and Scheme_Currency__c IN: setCurrency and Scheme_Discount_Type__c IN: setSchemetype';
        }
    }
    
    /*----------------------------------------------------------------------------------------------------      
    Method Name:        SchemeFee_Daily_Update_Check_Batch
    Description:        Daily Update Batch Method
    Parameter:          List of Scheme Fee Records 
    -----------------------------------------------------------------------------------------------------*/  
    global SchemeFee_Daily_Update_Check_Batch(String batchQuery){
        mapError = new Map<String, List<String>>();
        query = batchQuery;
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        system.debug('query######'+query);
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Asset> lstAssets) {
        system.debug('lstAssets#######'+lstAssets);
        for(Asset objAsset: lstAssets){
            objAsset.Batch_Run__c = true;
        }
        Integer i = 0;
        Database.SaveResult[] lstSaveResult = Database.update(lstAssets, False);
        for(Database.SaveResult sr : lstSaveResult){ 
            if (!sr.isSuccess()) { 
                Id assetId = lstAssets[i].Id;
                List<String> lstErrorMSG = new List<String>();
                for(Database.Error err : sr.getErrors()){
                    lstErrorMSG.add(err.getMessage());
                }
                mapError.put(assetId, lstErrorMSG);
            }
            i++;
        }
    }

    global void finish(Database.BatchableContext BC) {
        List<Log__c> lstLogException = new List<Log__c>();
        Integer i = 0;

        for(String assetId: mapError.keyset()){
            lstLogException.add(CreateLogs.insertLogBatchRec( 'Log Exception Logs Rec Type', 'Loyalty Batches', 'SchemeFee_Daily_Update_Check_Batch', 
                                     'execute', assetId, mapError.get(assetId)));
            i++;
        }
        insert lstLogException;
    }
    
}