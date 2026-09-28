/**********************************************************************************************************************************

Created Date    : 15/11/19 (DD/MM/YYYY)
Added By        : Vinothkumar Balasubramanian
Description     : Deregistration - Revert Asset and PCC GDS status after 45 days
JIRA            : TS-4823
Version         : V1.0 - 15/11/19 - Initial version

**********************************************************************************************************************************/


global class QC_PCCreregistrationBatch implements Database.Batchable<sObject> 
{
    
    String tmcRTId = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByDeveloperName().get('GDS').getRecordTypeId();
    String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Agency_Channel').getRecordTypeId();
    public static String[] gdsValues = new String[]{'New','Validating', 'Accepted'};
        
        global Database.QueryLocator start(Database.BatchableContext BC){
            
            return Database.getQueryLocator([SELECT Id,AccountId,GDS_Name__c, Status, Active__c, GDS__c FROM Asset where RecordTypeId =: assetRTId
                                             AND Status = 'Pending deregistration' AND AccountId != null AND GDS__c != null]);
        }
    
    global void execute(Database.BatchableContext ctx, List<Asset> assetInfo )
    {
        List<Asset> assetList = new list<Asset>();
        Set<Id> accIds = new Set<Id>();
        Set<String> assetGDSNames = new Set<String>();
        Set<String>  tmcGDSNames = new Set<String>();
        Set<Id> tmcAccIds = new Set<Id>();
        Set<Id>tmcderegRec = new Set<Id>();
        Set<Id>tmcGDSNew = new Set<Id>();
        Set<Id>tmcGDSValidating = new Set<Id>();
        Set<Id>tmcGDSAccepted = new Set<Id>();
        List<Agency_Info__c> agencyInfoList = new List<Agency_Info__c>();
        List<Agency_Info__c> deregPCCList = new List<Agency_Info__c>();
        
        for(Asset eachAst : assetInfo){
            accIds.add(eachAst.AccountId);
            assetGDSNames.add(eachAst.GDS_Name__c);
            System.debug('Asset AccountIds:' +accIds);
            System.debug('Asset GDS Names:' +assetGDSNames);
        }
        
        if(!accIds.isEmpty() && !assetGDSNames.isEmpty()){
            QC_TMC_GDS_Status__mdt tmcGDSStatus = [Select DeveloperName, Days_from_Pending_Dereg_GDS_Status__c from QC_TMC_GDS_Status__mdt where Days_from_Pending_Dereg_GDS_Status__c != NULL AND DeveloperName = 'QC_PCC_Asset_Status'];
            Decimal gdsStatusdays =  tmcGDSStatus.Days_from_Pending_Dereg_GDS_Status__c;
            Integer gdsPendingderegdays = gdsStatusdays.intValue();
            Date gdsPendingderegdate = system.today().addDays(-gdsPendingderegdays);
            for (Agency_Info__c tmcderegInfo : [SELECT Id, Account__c, Code__c, GDS_Status__c, GDS_Status_Change_Date__c FROM Agency_Info__c WHERE Account__c IN: accIds AND Code__c IN: assetGDSNames AND RecordTypeId =: tmcRTId 
                                                AND GDS_Status__c = 'Pending deregistration' AND GDS_Status_Change_Date__c <= :gdsPendingderegdate]){
                                                    
                                                    if(tmcderegInfo != NULL){
                                                        tmcderegRec.add(tmcderegInfo.Id);
                                                        deregPCCList.add(tmcderegInfo);
                                                        System.debug('TMC Info' +tmcderegInfo);
                                                    }
                                                }
        }
        
        if(!tmcderegRec.isEmpty()){
            for(Agency_Info__History agencyinfoHistory : [Select Field,OldValue, ParentId, NewValue From Agency_Info__History 
                                                          where ParentId IN: tmcderegRec AND Field = 'GDS_Status__c']){
                                                              System.debug('Agency Info History :'+agencyinfoHistory);
                                                              if(agencyinfoHistory != NULL){
                                                                  if(agencyinfoHistory.OldValue == 'New' && agencyinfoHistory.NewValue  == 'Pending deregistration') tmcGDSNew.add(agencyinfoHistory.ParentId);
                                                                  if(agencyinfoHistory.OldValue == 'Validating' && agencyinfoHistory.NewValue == 'Pending deregistration') tmcGDSValidating.add(agencyinfoHistory.ParentId);
                                                                  if(agencyinfoHistory.OldValue == 'Accepted' && agencyinfoHistory.NewValue == 'Pending deregistration') tmcGDSAccepted.add(agencyinfoHistory.ParentId);
                                                              }
                                                          }
        }
        
        if(!tmcGDSNew.isEmpty() || !tmcGDSValidating.isEmpty() || !tmcGDSAccepted.isEmpty()){
            for(Agency_Info__c deregPCC : deregPCCList){
                if(tmcGDSNew.contains(deregPCC.Id)) deregPCC.GDS_Status__c = 'New';
                if(tmcGDSValidating.contains(deregPCC.Id)) deregPCC.GDS_Status__c = 'Validating';
                if(tmcGDSAccepted.contains(deregPCC.Id)) deregPCC.GDS_Status__c = 'Accepted';
                agencyInfoList.add(deregPCC);
            }
        }
        
        if(!agencyInfoList.isEmpty())
        {
            for(Agency_Info__c deregPCCs : agencyInfoList){
                tmcGDSNames.add(deregPCCs.Code__c);
                tmcAccIds.add(deregPCCs.Account__c);
            }
        }
        
        
        if(!tmcGDSNames.isEmpty() && !tmcAccIds.isEmpty() ){
            
            for(Asset eachAsset : [SELECT Id,AccountId,GDS_Name__c, Status, Active__c FROM Asset where AccountId IN: tmcAccIds and RecordTypeId =: assetRTId
                                   AND GDS_Name__c IN: tmcGDSNames and Status = 'Pending deregistration']){
                                       
                                       if(eachAsset != null){
                                           eachAsset.Status = 'Accepted';
                                           assetList.add(eachAsset);
                                           System.debug('Asset List Update' +assetList);
                                       }
                                   }
        }
        
        if(!agencyInfoList.isEmpty())Database.SaveResult[] srtmcListUpdate = Database.update(agencyInfoList, false);
        
        if(!assetList.isEmpty())Database.SaveResult[] srassetListUpdate = Database.update(assetList, false);
    }
    
    global void finish(Database.BatchableContext ctx){
        
    }
}