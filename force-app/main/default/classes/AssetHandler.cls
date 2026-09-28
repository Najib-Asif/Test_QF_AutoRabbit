/* Created By : Ajay Bharathan | TCS | Cloud Developer
 * Purpose : To include business logic for Channel functionality
 * Description : To update TMC Info records when an asset is inserted & To perform duplicate check on Assets
 * References : AssetTrigger
 
  Modified Date   : 11/07/19 (DD/MM/YYYY)
  Modified By     : Vinothkumar Balasubramanian
  JIRA            : CRM-3777
  Version         : V2.0 - Added the Condition not to run this on record modification except Agency Channel

  Modified Date   : 30/09/19 (DD/MM/YYYY)
  Modified By     : Vinothkumar Balasubramanian
  JIRA            : TS-4813
  Version         : V3.0 - Deregistration - Update PCC GDS status in Salesforce
  
  Modified Date   : 15/11/2019 (DD/MM/YYYY)
  Modified By     : Vinothkumar Balasubramanian
  JIRA            : TS-4822
  Version         : V4.0 - Allow duplicate Assets in Salesforce as long as only one is ACTIVE

*/
public with sharing class AssetHandler 
{
    // to prevent duplicates on Channel Asset records
    public static void QCH_checkDuplicates(list<Asset> newAssets, map<Id,Asset> oldAssets)
    {
        String accRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agency_Account').getRecordTypeId();
        String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Agency_Channel').getRecordTypeId();
        Set<String> accGDSCombo = new Set<String>();
        Set<String> incomingAsset = new Set<String>();
        //Boolean checkAllAssets = false;
        list<Asset> existingAssets;
        Set<String> gdsValues = new Set<String>();
        Set<Id> accountIds = new Set<Id>();
        
        
        /*for(Asset eachAst : newAssets)
        {
            if(eachAst.RecordTypeId == assetRTId)
                checkAllAssets = true;
        }
        
        // query for existing assets 
        if(checkAllAssets)
        {
            existingAssets = [SELECT Id,AccountId,GDS__c,GDS__r.Name FROM Asset WHERE Account.RecordTypeId =: accRTID AND RecordTypeId =: assetRTId];
            if(existingAssets.size() > 0)
            for(Asset eachAsset : existingAssets)
            {
                if(eachAsset != null){
                    accGDSCombo.add(eachAsset.AccountId+'_'+eachAsset.GDS__r.Name);
                }    
            }       
        }*/
        
         for(Asset eachAst : newAssets)
        {
            if(eachAst != null && eachAst.RecordTypeId == assetRTId)
            {
                 if(eachAst.GDS__c != null && eachAst.AccountId != null && (oldAssets == null || (oldAssets != null && ((eachAst.AccountId != oldAssets.get(eachAst.Id).AccountId)|| (eachAst.GDS__c != oldAssets.get(eachAst.Id).GDS__c)))))
                {
                    gdsValues.add(eachAst.GDS__c);
                    accountIds.add(eachAst.AccountId);
                }
            }
        }
        
        if(!accountIds.isEmpty() && !gdsValues.isEmpty())
        {
      //Added Active is True on the below query for the TS-4822
            existingAssets = [SELECT Id, AccountId, GDS__c, GDS__r.Name, Active__c FROM Asset WHERE AccountId IN: accountIds AND GDS__c IN: gdsValues AND Active__c = TRUE];
      //Changes ends TS-4822
            if(existingAssets.size()>0){
                for(Asset eachAsset : existingAssets){
                    accGDSCombo.add(eachAsset.AccountId+'_'+eachAsset.GDS__r.Name);
                    system.debug('Existing Account GDS Combo***'+accGDSCombo);
                }
            }
        }

        
        for(Asset eachAst : newAssets)
        {
            Asset existingAsset = oldAssets != null ? oldAssets.get(eachAst.Id) : null;

            if(eachAst.RecordTypeId == assetRTId && eachAst != null &&
               (existingAsset == null || 
               (existingAsset != null && (eachAst.AccountId != existingAsset.AccountId || eachAst.GDS__c != existingAsset.GDS__c))))

            {
                String assetCombo = eachAst.AccountId+'_'+eachAst.GDS_Name__c;
                if(!accGDSCombo.isEmpty() && accGDSCombo.contains(assetCombo)){
                    eachAst.GDS__c.addError('DUPLICATE: GDS ' + eachAst.GDS_Name__c + ' exists for the Asset');
                }
                
                if(!incomingAsset.add(assetCombo)){
                    eachAst.GDS__c.addError('DUPLICATE: GDS ' + eachAst.GDS_Name__c + ' exists for the Asset');                    
                }
                
            }
            if(eachAst.RecordTypeId == assetRTId && eachAst != null && existingAsset == null){
                eachAst.Active__c = true;
            }
        }
    }
    // to update on TMC Info Update for Channel Assets
    public static void QCH_doTMCInfoUpdate(list<Asset> newAssets, map<Id,Asset> oldAssets)
    {
        /*String tmcRTId = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByName().get('GDS').getRecordTypeId();
        String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByName().get('Agency Channel').getRecordTypeId();*/
        String tmcRTId = Schema.SObjectType.Agency_Info__c.getRecordTypeInfosByDeveloperName().get('GDS').getRecordTypeId();
        String assetRTId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get('Agency_Channel').getRecordTypeId();
        
        Set<Id> accIds = new Set<Id>();
        Set<String> accChannelSet = new Set<String>();
        Set<String> accGDSCombo = new Set<String>();
        list<Agency_Info__c> toUpdateTMC = new list<Agency_Info__c>();
        list<Account> toUpdateAccount = new list<Account>();
        Set<String> pendingderegisterAssetStatus = new Set<String>();
        Set<String> gdsValues = new Set<String>();
        List<Asset> existingAssets;
        Boolean checkinactiveAssets = false;
        
        for(Asset eachAst : newAssets){
            if(eachAst != null && eachAst.AccountId != null && eachAst.GDS__c != null
               && eachAst.RecordTypeId == assetRTId)
            {
                accIds.add(eachAst.AccountId);
                if (eachAst.GDS_Name__c != Label.QAC_Channel_Exception_GDS) { 
                    accChannelSet.add(eachAst.AccountId + '_' +eachAst.is_Channel_Account__c);
                }
                accGDSCombo.add(eachAst.AccountId+'_'+eachAst.GDS_Name__c);
                gdsValues.add(eachAst.GDS__c);
            }
            if(eachAst != null && eachAst.AccountId != null && eachAst.GDS__c != null
               && eachAst.RecordTypeId == assetRTId && eachAst.Status == 'Pending deregistration' &&(oldAssets == null || 
                    (oldAssets != null && (eachAst.Status != oldAssets.get(eachAst.Id).Status))))
            {
                pendingderegisterAssetStatus.add(eachAst.Status);
                System.debug('pendingDeregister' +pendingderegisterAssetStatus);
            }
        }
        system.debug('account gds**'+accGDSCombo);
        
        // Check if already a channel member , otherwise update account with channel member and date
        if(!accChannelSet.isEmpty()){
            for(String eachACCombo : accChannelSet){
                if(Boolean.valueOf(eachACCombo.split('_')[1]) == false){
                    Account myAcc = new Account(Id = eachACCombo.split('_')[0],
                                                Channel_Member__c = true,
                                                Channel_Subscription_Date__c = Date.today());
                    toUpdateAccount.add(myAcc);
                }
            }
        }
        system.debug('Account Infos**'+toUpdateAccount);
        if(!toUpdateAccount.isEmpty())
            update toUpdateAccount;
        
        if(!accIds.isEmpty() && !gdsValues.isEmpty())
        {
         existingAssets = [SELECT Id, AccountId, GDS__c, GDS__r.Name, Active__c FROM Asset WHERE AccountId IN: accIds AND GDS__c IN: gdsValues AND Active__c = FALSE];
            if(existingAssets.size()>0)
               checkinactiveAssets = true;       
        }
        
        if(!accIds.isEmpty() && !accGDSCombo.isEmpty())
        {
            for(Agency_Info__c eachTMC : [SELECT Id,Account__c,PCC__c,Code__c,Active__c,GDS_Effective_Date__c,
                                          GDS_Status__c,QDP_Status__c,Surcharge_Exemption_Status__c,ATPCO_Status__c
                                          FROM Agency_Info__c
                                          WHERE Account__c IN: accIds AND RecordTypeId =: tmcRTId AND Active__c = TRUE])
            {
                if(eachTMC != null)
                {
                    String TMCCombo = eachTMC.Account__c+'_'+eachTMC.Code__c;
                    if(accGDSCombo.contains(TMCCombo))
                    {
                        if(string.isblank(eachTMC.GDS_Status__c) && checkinactiveAssets == false)
                        {
                            // check if status are blank (or) null
                            // if(String.isBlank(eachTMC.GDS_Status__c))
                            eachTMC.GDS_Status__c = 'New';
                            toUpdateTMC.add(eachTMC);
                        }

                        else if(!pendingderegisterAssetStatus.isEmpty() && checkinactiveAssets == false)
                        {
                            if(eachTMC.GDS_Status__c == 'New' || eachTMC.GDS_Status__c == 'Accepted' || eachTMC.GDS_Status__c == 'Validating')
                            {
                                eachTMC.GDS_Status__c = 'Pending deregistration';
                                toUpdateTMC.add(eachTMC);
                            }
                            if(eachTMC.GDS_Status__c == 'Active')
                            {
                                eachTMC.GDS_Status__c = 'Deregistered';
                                eachTMC.Channel_End_Date__c = system.today();
                                toUpdateTMC.add(eachTMC);
                            }
                        }
                        //Changes Starts for TS-4822
                        /*else if(eachTMC.GDS_Status__c == 'Deregistered' && checkinactiveAssets == true)
                        {
                           eachTMC.GDS_Status__c = 'New'; 
                           eachTMC.ATPCO_Status__c = '';
                           eachTMC.Surcharge_Exemption_Status__c = '';
                           eachTMC.QDP_Status__c = '';
                           eachTMC.Channel_End_Date__c = NULL;
                           toUpdateTMC.add(eachTMC);
                        }*/
                        //Changes Ends
                    }
                }
            }
        }

        system.debug('TMC Infos**'+toUpdateTMC);
        if(!toUpdateTMC.isEmpty())
            update toUpdateTMC;
    }
}