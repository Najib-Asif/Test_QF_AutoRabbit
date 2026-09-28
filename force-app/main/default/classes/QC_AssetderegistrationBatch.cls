/**********************************************************************************************************************************

Created Date    : 18/10/19 (DD/MM/YYYY)
Added By        : Vinothkumar Balasubramanian
Description     : Channel Deregistration : Batch job - Update Asset Status and Active flag in Asset
JIRA            : TS-4816
Version         : V1.0 - 18/10/19 - Initial version

Modified Date   : 31/10/19 (DD/MM/YYYY)
Modified By     : Vinothkumar Balasubramanian
JIRA            : CRM-4015
Version         : V2.0 - Include GDS Status "Service"

**********************************************************************************************************************************/


global class QC_AssetderegistrationBatch implements Database.Batchable<sObject> 
{
    
    String tmcRTId = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByDeveloperName().get('GDS').getRecordTypeId();
    String accAgencyRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
    String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Agency_Channel').getRecordTypeId(); 
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        return Database.getQueryLocator([SELECT Id,AccountId,GDS_Name__c, Status, Active__c, GDS__c FROM Asset where RecordTypeId =: assetRTId
                                         AND Status = 'Pending deregistration' AND AccountId != null AND GDS__c != null]);
    }
    
    global void execute(Database.BatchableContext ctx, List<Asset> assetInfo )
    {
        List<Asset> assetList = new list<Asset>();
        Set<Id> accIds = new Set<Id>();
        Set<Id>tmcderegAccIds = new Set<Id>();
        Set<String>tmcderegAccGDScombo = new Set<String>();
        Set<String>tmcAccGDScombo = new Set<String>();
        Set<Id>tmcderegIds = new Set<Id>();
        Set<Id>tmcAccountId = new Set<Id>();
        Set<String> assetGDSNames = new Set<String>();
        
        for(Asset eachAst : assetInfo){
            accIds.add(eachAst.AccountId);
            assetGDSNames.add(eachAst.GDS_Name__c);
            System.debug('Asset AccountIds:' +accIds);
            System.debug('Asset GDS Names:' +assetGDSNames);
        }
        
        if(!accIds.isEmpty() && !assetGDSNames.isEmpty()){
            for (Agency_Info__c tmcInfo : [SELECT Id, Account__c, Code__c, GDS_Status__c, ATPCO_Status__c, Surcharge_Exemption_Status__c, QDP_Status__c FROM Agency_Info__c WHERE Account__c IN: accIds AND Code__c IN: assetGDSNames AND RecordTypeId =: tmcRTId 
                                           AND((GDS_Status__c = 'Deregistered' AND ATPCO_Status__c = '' AND Surcharge_Exemption_Status__c = '' AND QDP_Status__c = '') OR
                                               (GDS_Status__c = 'Deregistered' AND ATPCO_Status__c = 'Deregistered' AND Surcharge_Exemption_Status__c = 'Deregistered' AND QDP_Status__c = 'Deregistered') OR
                                               (GDS_Status__c = 'Rejected' AND ATPCO_Status__c = '' AND Surcharge_Exemption_Status__c = '' AND QDP_Status__c = '') OR
                                               (GDS_Status__c = 'Inactive' AND ATPCO_Status__c = 'Inactive' AND Surcharge_Exemption_Status__c = 'Inactive' AND QDP_Status__c = 'Inactive') OR
                                               (GDS_Status__c = 'Inactive' AND ATPCO_Status__c = '' AND Surcharge_Exemption_Status__c = '' AND QDP_Status__c = '') OR
                         //Changes added by Vinoth for CRM-4015
                         (GDS_Status__c = 'Service' AND ATPCO_Status__c = '' AND Surcharge_Exemption_Status__c = '' AND QDP_Status__c = ''))]){
                          //Changes ends for CRM-4015
                                                   
                                                   if(tmcInfo != NULL){
                                                       tmcderegAccIds.add(tmcInfo.Account__c);
                                                       tmcderegIds.add(tmcInfo.Id);
                                                       tmcderegAccGDScombo.add(tmcInfo.Account__c+'_'+tmcInfo.Code__c);
                                                       
                                                       System.debug('Dereg Account IDS:' +tmcderegAccIds);
                                                       System.debug('TMC Info' +tmcInfo);
                                                   }
                                               }
        }
        
        if(!tmcderegAccIds.isEmpty() && !assetGDSNames.isEmpty()){
            for (Agency_Info__c tmcInfo : [SELECT Id, Account__c, Code__c, GDS_Status__c, ATPCO_Status__c, Surcharge_Exemption_Status__c, QDP_Status__c  FROM Agency_Info__c WHERE Account__c IN: tmcderegAccIds AND Code__c IN: assetGDSNames AND RecordTypeId =: tmcRTId 
                                           AND Id NOT IN:tmcderegIds]){
                                               
                                               if(tmcInfo != NULL){
                                                   tmcAccGDScombo.add(tmcInfo.Account__c+'_'+tmcInfo.Code__c);
                                                   System.debug('TMC Info for Reg Accids' +tmcInfo);
                                               }
                                           }
        }
        
        
        if(tmcderegAccGDScombo != NULL && tmcAccGDScombo != NULL){
            for (String tmcAccGDS : tmcAccGDScombo){
                if(tmcderegAccGDScombo.contains(tmcAccGDS)) tmcderegAccGDScombo.remove(tmcAccGDS);
                System.debug('Dereg final Account IDS:' +tmcderegAccIds);
                
            }
        }
        
        for(String tmcAccountGDS : tmcderegAccGDScombo){
            String tmcAccount = tmcAccountGDS.substringBefore('_');
            System.debug('TMC Account:' +tmcAccount);
            tmcAccountId.add(tmcAccount);
            System.debug('TMC Account Id:' +tmcAccountId);
        }
        
        if(!tmcAccountId.isEmpty()){
            
            for(Asset eachAsset : [SELECT Id,AccountId,GDS_Name__c, Status, Active__c FROM Asset where AccountId IN: tmcAccountId and RecordTypeId =: assetRTId
                                   AND GDS_Name__c IN: assetGDSNames and Status = 'Pending deregistration']){
                                       
                                       if(eachAsset != null){
                                           eachAsset.Status = 'Deregistered';
                                           eachAsset.Active__c = FALSE;
                                           assetList.add(eachAsset);
                                           System.debug('Asset List Update' +assetList);
                                       }
                                   }
        }
        
        Database.SaveResult[] srListUpdate = Database.update(assetList, false);
    }
    
    global void finish(Database.BatchableContext ctx){
        
    }
}